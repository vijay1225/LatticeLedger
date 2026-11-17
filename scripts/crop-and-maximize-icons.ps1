Add-Type -AssemblyName System.Drawing

$srcPath = Resolve-Path "resources/icons/max-fill/max_fill_icon_1024x1024.png"
if (-not (Test-Path $srcPath)) {
    $srcPath = Resolve-Path "resources/icons/max-fill/max_fill_icon_512x512.png"
}

Write-Output "Loading source image from $srcPath..."
$srcImg = [System.Drawing.Image]::FromFile($srcPath)
$srcBmp = New-Object System.Drawing.Bitmap $srcImg

# 1. Detect exact non-transparent bounding box
$minX = $srcBmp.Width; $maxX = 0
$minY = $srcBmp.Height; $maxY = 0

for ($y = 0; $y -lt $srcBmp.Height; $y++) {
    for ($x = 0; $x -lt $srcBmp.Width; $x++) {
        $p = $srcBmp.GetPixel($x, $y)
        if ($p.A -gt 15) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

$cropW = $maxX - $minX + 1
$cropH = $maxY - $minY + 1
Write-Output "Detected tightly cropped bounds: X=[$minX, $maxX], Y=[$minY, $maxY], ContentSize=${cropW}x${cropH}"

# 2. Extract cropped bitmap (0 margins)
$cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)
$croppedBmp = $srcBmp.Clone($cropRect, $srcBmp.PixelFormat)

# Function to generate zero-margin icon at exact canvas size
function New-ZeroMarginIcon {
    param([int]$CanvasSize)

    $destBmp = New-Object System.Drawing.Bitmap $CanvasSize, $CanvasSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($destBmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # Scale uniformly to fill the canvas to the absolute edge (0 margin)
    $scale = [double]$CanvasSize / [Math]::Max($cropW, $cropH)
    $drawW = [int][Math]::Round($cropW * $scale)
    $drawH = [int][Math]::Round($cropH * $scale)
    $destX = [int][Math]::Floor(($CanvasSize - $drawW) / 2.0)
    $destY = [int][Math]::Floor(($CanvasSize - $drawH) / 2.0)

    $destRect = New-Object System.Drawing.Rectangle($destX, $destY, $drawW, $drawH)
    $srcRect = New-Object System.Drawing.Rectangle(0, 0, $cropW, $cropH)

    $g.DrawImage($croppedBmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    return $destBmp
}

# 3. Create output directory
$outDir = "resources/icons/max-fill/tight"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$sizes = @(16, 20, 24, 32, 48, 64, 72, 96, 128, 144, 192, 256, 512, 1024)
foreach ($sz in $sizes) {
    $bmp = New-ZeroMarginIcon -CanvasSize $sz
    $bmp.Save("$outDir/icon_${sz}x${sz}.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Generated tight icon: $outDir/icon_${sz}x${sz}.png"
}

# 4. Generate build/icon.png (512x512) and public/icon-*.png
Write-Output "Updating build/icon.png and web icons..."
$bmp512 = New-ZeroMarginIcon -CanvasSize 512
$bmp512.Save("build/icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp512.Save("public/icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp512.Dispose()

$bmp192 = New-ZeroMarginIcon -CanvasSize 192
$bmp192.Save("public/icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp192.Dispose()

# 5. Generate Multi-Resolution build/icon.ico & public/favicon.ico
Write-Output "Generating multi-resolution build/icon.ico (16, 20, 24, 32, 48, 64, 128, 256)..."
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$icoEntries = @()

foreach ($sz in $icoSizes) {
    $bmp = New-ZeroMarginIcon -CanvasSize $sz
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $icoEntries += [PSCustomObject]@{
        Size = $sz
        Bytes = $ms.ToArray()
    }
    $ms.Dispose()
    $bmp.Dispose()
}

function Write-IcoFile {
    param([string]$FilePath, [array]$Entries)
    $fs = [System.IO.File]::Create($FilePath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    $bw.Write([uint16]0) # Reserved
    $bw.Write([uint16]1) # Type 1 = ICO
    $bw.Write([uint16]$Entries.Count) # Image count

    $offset = 6 + (16 * $Entries.Count)

    foreach ($entry in $Entries) {
        $w = if ($entry.Size -eq 256) { 0 } else { [byte]$entry.Size }
        $h = if ($entry.Size -eq 256) { 0 } else { [byte]$entry.Size }
        $bw.Write([byte]$w)
        $bw.Write([byte]$h)
        $bw.Write([byte]0) # Palette
        $bw.Write([byte]0) # Reserved
        $bw.Write([uint16]1) # Color planes
        $bw.Write([uint16]32) # Bit count
        $bw.Write([uint32]$entry.Bytes.Length) # Image bytes
        $bw.Write([uint32]$offset) # File offset
        $offset += $entry.Bytes.Length
    }

    foreach ($entry in $Entries) {
        $bw.Write($entry.Bytes, 0, $entry.Bytes.Length)
    }

    $bw.Flush()
    $bw.Close()
    $fs.Close()
}

Write-IcoFile -FilePath "build/icon.ico" -Entries $icoEntries
Write-IcoFile -FilePath "public/favicon.ico" -Entries $icoEntries

# 6. Update Android Mipmaps
$androidDensities = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $androidDensities.Keys) {
    $sz = $androidDensities[$folder]
    $dir = "android/app/src/main/res/$folder"
    if (Test-Path $dir) {
        Write-Output "Updating Android $folder (${sz}x${sz})..."
        $bmp = New-ZeroMarginIcon -CanvasSize $sz
        $bmp.Save("$dir/ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
}

$croppedBmp.Dispose()
$srcBmp.Dispose()
$srcImg.Dispose()
Write-Output "SUCCESS: Zero-margin icons generated and deployed to build/, public/, and android/!"
