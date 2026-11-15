!macro customInit
  ; 1. Terminate any running LatticeLedger process
  nsExec::Exec 'taskkill /f /im "LatticeLedger.exe"'
  Pop $0

  ; 2. Clear old uninstaller string from registry so uninstallOldVersion
  ; will not execute legacy uninstaller binaries that deadlock or fail with exit code 2.
  SetRegView 64
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\7365d292-9c0d-5b61-b023-65799577d6fd" "UninstallString"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\7365d292-9c0d-5b61-b023-65799577d6fd" "UninstallString"
  SetRegView 32
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\7365d292-9c0d-5b61-b023-65799577d6fd" "UninstallString"
  DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\7365d292-9c0d-5b61-b023-65799577d6fd" "UninstallString"
  SetRegView 64

  ; 3. If an old uninstaller binary is sitting in $INSTDIR, remove it so it cannot be run in-place
  ${if} ${FileExists} "$INSTDIR\Uninstall LatticeLedger.exe"
    Delete "$INSTDIR\Uninstall LatticeLedger.exe"
  ${endif}
!macroend

!macro customUnInit
  ; Terminate any running LatticeLedger process before uninstaller proceeds
  nsExec::Exec 'taskkill /f /im "LatticeLedger.exe"'
  Pop $0
!macroend

!macro customCheckAppRunning
  ; Replace electron-builder's default process checker.
  ; The default checker runs a PowerShell query that checks if ANY process path starts with $INSTDIR.
  ; When the uninstaller runs in $INSTDIR, it matches itself, causing a false-positive deadlock
  ; with error "LatticeLedger cannot be closed. Please close it manually and retry to continue."
  nsExec::Exec 'taskkill /f /im "LatticeLedger.exe"'
  Pop $0
  Sleep 500
!macroend

!macro customRemoveFiles
  ; Replace electron-builder's fragile un.atomicRMDir which attempts to rename
  ; the currently running uninstaller into $PLUGINSDIR\old-install, causing abort with exit code 2.
  SetOutPath $TEMP
  RMDir /r $INSTDIR
!macroend

!macro customUnInstallCheck
  ; Prevent any old uninstaller return code from blocking installation
  ClearErrors
  Push 0
  Pop $R0
!macroend

!macro customUnInstallCheckCurrentUser
  ; Prevent any old uninstaller return code from blocking installation
  ClearErrors
  Push 0
  Pop $R0
!macroend

!macro customInstall
  ; When running silently, exit successfully without waiting on the finish page
  ${if} ${Silent}
    !insertmacro quitSuccess
  ${endif}
!macroend
