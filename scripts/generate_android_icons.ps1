Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\master_reference_no_star.png"
if (-not (Test-Path $srcPath)) {
    $srcPath = "build/icon.png"
}
$srcImg = [System.Drawing.Bitmap]::new($srcPath)
Write-Output "Source image: $srcPath ($($srcImg.Width)x$($srcImg.Height))"

$densities = @(
    @{ Name = "mdpi";    ForeSize = 108; LegacySize = 48 },
    @{ Name = "hdpi";    ForeSize = 162; LegacySize = 72 },
    @{ Name = "xhdpi";   ForeSize = 216; LegacySize = 96 },
    @{ Name = "xxhdpi";  ForeSize = 324; LegacySize = 144 },
    @{ Name = "xxxhdpi"; ForeSize = 432; LegacySize = 192 }
)

# For adaptive icon foreground: safe zone is inner 62% of the 108dp canvas
# 62% ensures that even with a tight 66dp circular mask, every pixel of the hexagon and pencils has breathing room
$FOREGROUND_SCALE = 0.62

# For legacy icons (48-192px): content scaled to 72% on pure black background
$LEGACY_SCALE = 0.72

foreach ($d in $densities) {
    $dir = "android/app/src/main/res/mipmap-$($d.Name)"
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # 1. Generate ic_launcher_foreground.png (Adaptive icon layer)
    $fSize = $d.ForeSize
    $fgBmp = New-Object System.Drawing.Bitmap($fSize, $fSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $fgG = [System.Drawing.Graphics]::FromImage($fgBmp)
    $fgG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fgG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $fgG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $fgG.Clear([System.Drawing.Color]::Transparent)

    $iconW = [int]($fSize * $FOREGROUND_SCALE)
    $iconH = [int]($fSize * $FOREGROUND_SCALE)
    $posX = [int](($fSize - $iconW) / 2)
    $posY = [int](($fSize - $iconH) / 2)
    $fgG.DrawImage($srcImg, $posX, $posY, $iconW, $iconH)
    $fgG.Dispose()

    $fgPath = "$dir/ic_launcher_foreground.png"
    $fgBmp.Save($fgPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $fgBmp.Dispose()
    Write-Output "Generated $fgPath ($fSize x $fSize)"

    # 2. Generate ic_launcher.png (Legacy launcher square)
    $lSize = $d.LegacySize
    $legBmp = New-Object System.Drawing.Bitmap($lSize, $lSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $legG = [System.Drawing.Graphics]::FromImage($legBmp)
    $legG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $legG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $legG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $legG.Clear([System.Drawing.Color]::FromArgb(255, 0, 0, 0)) # Pure black background

    $lIconW = [int]($lSize * $LEGACY_SCALE)
    $lIconH = [int]($lSize * $LEGACY_SCALE)
    $lPosX = [int](($lSize - $lIconW) / 2)
    $lPosY = [int](($lSize - $lIconH) / 2)
    $legG.DrawImage($srcImg, $lPosX, $lPosY, $lIconW, $lIconH)
    $legG.Dispose()

    $legPath = "$dir/ic_launcher.png"
    $legBmp.Save($legPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $legBmp.Dispose()
    Write-Output "Generated $legPath ($lSize x $lSize)"

    # 3. Generate ic_launcher_round.png (Legacy round launcher)
    $rndBmp = New-Object System.Drawing.Bitmap($lSize, $lSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $rndG = [System.Drawing.Graphics]::FromImage($rndBmp)
    $rndG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $rndG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $rndG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rndG.Clear([System.Drawing.Color]::Transparent)

    # Draw circular black background
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
    $rndG.FillEllipse($brush, 0, 0, $lSize, $lSize)
    $brush.Dispose()

    # Draw centered icon inside the circle
    $rndG.DrawImage($srcImg, $lPosX, $lPosY, $lIconW, $lIconH)
    $rndG.Dispose()

    $rndPath = "$dir/ic_launcher_round.png"
    $rndBmp.Save($rndPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $rndBmp.Dispose()
    Write-Output "Generated $rndPath ($lSize x $lSize)"
}

$srcImg.Dispose()
Write-Output "All Android icons generated successfully."
