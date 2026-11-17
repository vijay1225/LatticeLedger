const { app, BrowserWindow, ipcMain, dialog, session, Menu, MenuItem } = require('electron');
const path = require('path');
const fs = require('fs');

let mainWindow = null;
let activeWatcher = null;
let lastSelfWriteTimestamp = 0;
let lastSelfWriteMtime = 0;
let lastSelfWriteSize = 0;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 840,
    minWidth: 960,
    minHeight: 640,
    backgroundColor: '#09090b',
    title: 'LatticeLedger',
    autoHideMenuBar: true,
    icon: path.join(__dirname, '../build/icon.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.cjs'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
      webSecurity: false
    }
  });

  // Register application menu with standard Edit accelerators (Ctrl+C, Ctrl+V, Ctrl+X, Ctrl+A, Ctrl+Z, Ctrl+Y)
  // In Windows Electron, having an application menu is required for OS keyboard accelerators to be registered.
  const appMenuTemplate = [
    {
      label: 'Edit',
      submenu: [
        { role: 'undo', accelerator: 'CmdOrCtrl+Z' },
        { role: 'redo', accelerator: 'CmdOrCtrl+Y' },
        { type: 'separator' },
        { role: 'cut', accelerator: 'CmdOrCtrl+X' },
        { role: 'copy', accelerator: 'CmdOrCtrl+C' },
        { role: 'paste', accelerator: 'CmdOrCtrl+V' },
        { role: 'pasteAndMatchStyle', accelerator: 'CmdOrCtrl+Shift+V' },
        { role: 'delete' },
        { type: 'separator' },
        { role: 'selectAll', accelerator: 'CmdOrCtrl+A' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    }
  ];
  const appMenu = Menu.buildFromTemplate(appMenuTemplate);
  Menu.setApplicationMenu(appMenu);

  // Keep menu bar visually hidden for a clean modern app look while accelerators remain active
  mainWindow.setMenuBarVisibility(false);

  // Guarantee Ctrl+C, Ctrl+V, Ctrl+X, Ctrl+A, Ctrl+Z, Ctrl+Y dispatch via before-input-event fail-safe
  mainWindow.webContents.on('before-input-event', (_event, input) => {
    if (input.type === 'keyDown' && (input.control || input.meta)) {
      const k = input.key.toLowerCase();
      if (k === 'v' && !input.shift && !input.alt) {
        mainWindow.webContents.paste();
      } else if (k === 'c' && !input.shift && !input.alt) {
        mainWindow.webContents.copy();
      } else if (k === 'x' && !input.shift && !input.alt) {
        mainWindow.webContents.cut();
      } else if (k === 'a' && !input.shift && !input.alt) {
        mainWindow.webContents.selectAll();
      } else if (k === 'z' && !input.shift && !input.alt) {
        mainWindow.webContents.undo();
      } else if ((k === 'y' && !input.alt) || (k === 'z' && input.shift && !input.alt)) {
        mainWindow.webContents.redo();
      }
    }
  });

  // Forward renderer console logs to main process for diagnostics
  mainWindow.webContents.on('console-message', (_event, level, message, line, sourceId) => {
    if (level >= 2) {
      console.error(`[Renderer Error] ${message} (${sourceId}:${line})`);
    } else {
      console.log(`[Renderer] ${message}`);
    }
  });

  // Enable desktop native right-click context menu (Copy, Cut, Paste, Select All)
  mainWindow.webContents.on('context-menu', (_event, params) => {
    const menu = new Menu();

    if (params.selectionText && params.selectionText.trim()) {
      menu.append(new MenuItem({
        label: 'Copy',
        accelerator: 'CmdOrCtrl+C',
        role: 'copy'
      }));
    }

    if (params.isEditable) {
      if (params.selectionText && params.selectionText.trim()) {
        menu.append(new MenuItem({
          label: 'Cut',
          accelerator: 'CmdOrCtrl+X',
          role: 'cut'
        }));
      }
      menu.append(new MenuItem({
        label: 'Paste',
        accelerator: 'CmdOrCtrl+V',
        role: 'paste'
      }));
      menu.append(new MenuItem({ type: 'separator' }));
      menu.append(new MenuItem({
        label: 'Select All',
        accelerator: 'CmdOrCtrl+A',
        role: 'selectAll'
      }));
    } else if (params.selectionText && params.selectionText.trim()) {
      menu.append(new MenuItem({ type: 'separator' }));
      menu.append(new MenuItem({
        label: 'Select All',
        accelerator: 'CmdOrCtrl+A',
        role: 'selectAll'
      }));
    }

    if (params.linkURL) {
      menu.append(new MenuItem({
        label: 'Copy Link Address',
        click: () => {
          const { clipboard } = require('electron');
          clipboard.writeText(params.linkURL);
        }
      }));
    }

    if (menu.items.length > 0) {
      menu.popup({ window: mainWindow, x: params.x, y: params.y });
    }
  });

  const devServerUrl = process.env.VITE_DEV_SERVER_URL;
  if (devServerUrl) {
    mainWindow.loadURL(devServerUrl);
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
    if (activeWatcher) {
      try { activeWatcher.close(); } catch {}
      activeWatcher = null;
    }
  });
}

// ----------------------------------------------------
// IPC Handlers for Vault Folder & SQLite File Sync
// ----------------------------------------------------

ipcMain.handle('dialog:select-vault-folder', async () => {
  if (!mainWindow) return null;
  const result = await dialog.showOpenDialog(mainWindow, {
    title: 'Select LatticeLedger Vault Folder (Google Drive / Local)',
    properties: ['openDirectory', 'createDirectory']
  });

  if (result.canceled || !result.filePaths || result.filePaths.length === 0) {
    return null;
  }
  return result.filePaths[0];
});

ipcMain.handle('vault:check-file-info', async (_event, { folderPath, fileName = 'lattice_vault.db' }) => {
  if (!folderPath) return { exists: false };
  try {
    const fullPath = path.join(folderPath, fileName);
    if (!fs.existsSync(fullPath)) {
      return { exists: false, fullPath };
    }
    const stats = await fs.promises.stat(fullPath);
    return {
      exists: true,
      fullPath,
      size: stats.size,
      mtime: stats.mtimeMs
    };
  } catch (err) {
    return { exists: false, error: err.message };
  }
});

ipcMain.handle('vault:read-file', async (_event, { folderPath, fileName = 'lattice_vault.db' }) => {
  if (!folderPath) throw new Error('No vault folder path provided');
  const fullPath = path.join(folderPath, fileName);
  if (!fs.existsSync(fullPath)) {
    return null;
  }
  const buffer = await fs.promises.readFile(fullPath);
  return buffer;
});

ipcMain.handle('vault:write-file', async (_event, { folderPath, data, fileName = 'lattice_vault.db' }) => {
  if (!folderPath) throw new Error('No vault folder path provided');
  const fullPath = path.join(folderPath, fileName);
  const parentDir = path.dirname(fullPath);
  if (!fs.existsSync(parentDir)) {
    await fs.promises.mkdir(parentDir, { recursive: true });
  }
  
  // Mark self write timestamp to ignore echo from fs.watch
  lastSelfWriteTimestamp = Date.now();
  
  const buffer = Buffer.isBuffer(data) ? data : Buffer.from(data);
  await fs.promises.writeFile(fullPath, buffer);
  
  const stats = await fs.promises.stat(fullPath);
  lastSelfWriteMtime = stats.mtimeMs;
  lastSelfWriteSize = stats.size;
  return { success: true, mtime: stats.mtimeMs, size: stats.size };
});

ipcMain.handle('vault:watch-folder', async (_event, { folderPath, fileName = 'lattice_vault.db' }) => {
  if (activeWatcher) {
    try { activeWatcher.close(); } catch {}
    activeWatcher = null;
  }

  if (!folderPath || !fs.existsSync(folderPath)) return false;

  let debounceTimer = null;
  const targetFile = path.normalize(fileName);

  try {
    activeWatcher = fs.watch(folderPath, (eventType, filename) => {
      if (!filename) return;
      if (path.normalize(filename) === targetFile) {
        // Debounce external sync notifications
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(async () => {
          // If we wrote this file ourselves within the last 5000ms, ignore self-write echo
          if (Date.now() - lastSelfWriteTimestamp < 5000) return;
          
          if (mainWindow && !mainWindow.isDestroyed()) {
            try {
              const fullPath = path.join(folderPath, fileName);
              if (fs.existsSync(fullPath)) {
                const stats = await fs.promises.stat(fullPath);
                // If file size and mtime match our self-write, ignore
                if (stats.size === lastSelfWriteSize && Math.abs(stats.mtimeMs - lastSelfWriteMtime) < 100) {
                  return;
                }
                mainWindow.webContents.send('vault:file-changed', {
                  fileName,
                  mtime: stats.mtimeMs,
                  size: stats.size
                });
              }
            } catch {}
          }
        }, 800);
      }
    });
    return true;
  } catch (err) {
    console.warn('[Electron] Failed to start folder watcher:', err);
    return false;
  }
});

ipcMain.handle('vault:unwatch-folder', async () => {
  if (activeWatcher) {
    try { activeWatcher.close(); } catch {}
    activeWatcher = null;
  }
  return true;
});

ipcMain.handle('vault:get-wasm-binary', async () => {
  const possiblePaths = [
    path.join(__dirname, '../dist/sql-wasm.wasm'),
    path.join(__dirname, 'sql-wasm.wasm'),
    path.join(app.getAppPath(), 'dist/sql-wasm.wasm'),
    path.join(process.resourcesPath || '', 'dist/sql-wasm.wasm'),
    path.join(process.resourcesPath || '', 'app.asar/dist/sql-wasm.wasm'),
    path.join(__dirname, '../node_modules/sql.js/dist/sql-wasm.wasm')
  ];
  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      try {
        const buffer = await fs.promises.readFile(p);
        return buffer;
      } catch (err) {
        console.error('[Electron] Failed to read wasm from', p, err);
      }
    }
  }
  return null;
});

ipcMain.handle('vault:ensure-assets-dir', async (_event, { folderPath }) => {
  if (!folderPath) return false;
  try {
    const assetsPath = path.join(folderPath, 'assets');
    if (!fs.existsSync(assetsPath)) {
      await fs.promises.mkdir(assetsPath, { recursive: true });
    }
    return true;
  } catch (err) {
    console.error('[Electron] Failed to ensure assets dir:', err);
    return false;
  }
});

// Ensure Single Instance Lock so duplicate processes never linger or lock files
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });

  // App Lifecycle
  app.whenReady().then(() => {
    // Intercept YouTube and video embed requests to ensure valid Referer and Origin headers in Electron
    if (session && session.defaultSession) {
      session.defaultSession.webRequest.onBeforeSendHeaders(
        { urls: ['*://*.youtube.com/*', '*://*.youtube-nocookie.com/*', '*://*.googlevideo.com/*'] },
        (details, callback) => {
          details.requestHeaders['Referer'] = 'https://www.youtube.com/';
          details.requestHeaders['Origin'] = 'https://www.youtube.com';
          callback({ cancel: false, requestHeaders: details.requestHeaders });
        }
      );
    }

    createWindow();

    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
      }
    });
  });

  app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
      app.quit();
    }
  });

  app.on('before-quit', () => {
    if (activeWatcher) {
      try { activeWatcher.close(); } catch {}
      activeWatcher = null;
    }
  });
}
