Add-Type -AssemblyName System.Drawing

$rawPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\pencils_and_l_only\raw_full_uncropped.png"
$rawImg = [System.Drawing.Bitmap]::FromFile($rawPath)
$w = $rawImg.Width
$h = $rawImg.Height

# 1. Get exact tight bounds of the uncropped content
$minX = $w; $maxX = 0; $minY = $h; $maxY = 0
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $rawImg.GetPixel($x, $y)
        if ($c.A -gt 25) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

$cW = $maxX - $minX + 1 # 740
$cH = $maxY - $minY + 1 # 823
Write-Output "Tight uncropped bounds: X=[$minX, $maxX], Y=[$minY, $maxY], Size=${cW}x${cH}"

# 2. Crop to tight content
$cropBmp = New-Object System.Drawing.Bitmap($cW, $cH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cropG = [System.Drawing.Graphics]::FromImage($cropBmp)
$cropG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$cropG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$cropG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$cropG.DrawImage($rawImg, 0, 0, (New-Object System.Drawing.Rectangle($minX, $minY, $cW, $cH)), [System.Drawing.GraphicsUnit]::Pixel)
$cropG.Dispose()
$rawImg.Dispose()

$projectRoot = "C:\Users\Vijay\Documents\LatticeLedger"
$outDir = "$projectRoot\resources\icons\pencils_and_l_only"

# 3. Create Desktop 1024x1024 Master on TRANSPARENT background with subtle dark shadow for light wallpaper contrast
$DESKTOP_TARGET_H = 840
$scale = $DESKTOP_TARGET_H / $cH
$drawW = [int]($cW * $scale) # 755
$drawH = [int]($cH * $scale) # 840
$drawX = [int]((1024 - $drawW) / 2)
$drawY = [int]((1024 - $drawH) / 2)

$desktopMaster = New-Object System.Drawing.Bitmap(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$dg = [System.Drawing.Graphics]::FromImage($desktopMaster)
$dg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$dg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$dg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$dg.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$dg.Clear([System.Drawing.Color]::Transparent)

# Subtle dark shadow contour (offset by 3px in 4 directions) for light wallpaper visibility
$shadowAttr = New-Object System.Drawing.Imaging.ImageAttributes
$shadowMatrix = New-Object System.Drawing.Imaging.ColorMatrix
$shadowMatrix.Matrix00 = 0.0
$shadowMatrix.Matrix11 = 0.0
$shadowMatrix.Matrix22 = 0.0
$shadowMatrix.Matrix33 = 0.45
$shadowAttr.SetColorMatrix($shadowMatrix)

$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($drawX + 3), ($drawY + 3), $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($drawX - 2), $drawY, $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($drawX + 2), $drawY, $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($drawX, ($drawY - 2), $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($drawX, ($drawY + 2), $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)

# Draw primary crisp white icon
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($drawX, $drawY, $drawW, $drawH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel)
$dg.Dispose()

$desktopMasterPath = "$outDir\desktop_master_transparent.png"
$desktopMaster.Save($desktopMasterPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved desktop master transparent: $desktopMasterPath"

# 4. Generate all Desktop ICO resolutions on TRANSPARENT background
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$pngDataList = [System.Collections.Generic.List[byte[]]]::new()

foreach ($sz in $icoSizes) {
    $dest = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($desktopMaster, 0, 0, $sz, $sz)
    $g.Dispose()

    $dest.Save("$outDir\desktop_icon_${sz}x${sz}.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $ms = New-Object System.IO.MemoryStream
    $dest.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngDataList.Add($ms.ToArray())
    $ms.Dispose()
    $dest.Dispose()
}

# Write multi-resolution ICO binary
function Write-IcoFile($targetPath, $sizes, $pngList) {
    $fs = [System.IO.File]::Create($targetPath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    $count = $sizes.Count
    $bw.Write([uint16]0)
    $bw.Write([uint16]1)
    $bw.Write([uint16]$count)

    $headerSize = 6 + ($count * 16)
    $currentOffset = $headerSize

    for ($i = 0; $i -lt $count; $i++) {
        $sz = $sizes[$i]
        $bWidth = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
        $bHeight = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
        $bw.Write($bWidth)
        $bw.Write($bHeight)
        $bw.Write([byte]0)
        $bw.Write([byte]0)
        $bw.Write([uint16]1)
        $bw.Write([uint16]32)
        $bw.Write([uint32]$pngList[$i].Length)
        $bw.Write([uint32]$currentOffset)
        $currentOffset += $pngList[$i].Length
    }

    for ($i = 0; $i -lt $count; $i++) {
        $bw.Write($pngList[$i])
    }

    $bw.Flush()
    $bw.Close()
    $fs.Close()
}

Write-IcoFile "$projectRoot\build\icon.ico" $icoSizes $pngDataList
Write-IcoFile "$projectRoot\public\favicon.ico" $icoSizes $pngDataList
Write-Output "Generated multi-resolution ICOs with 100% uncropped pencils"

# 5. Save 512x512 transparent for build/icon.png and public/icon-512.png
$bmp512 = New-Object System.Drawing.Bitmap(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g512 = [System.Drawing.Graphics]::FromImage($bmp512)
$g512.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g512.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g512.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g512.Clear([System.Drawing.Color]::Transparent)
$g512.DrawImage($desktopMaster, 0, 0, 512, 512)
$g512.Dispose()
$bmp512.Save("$projectRoot\build\icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp512.Save("$projectRoot\public\icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp512.Dispose()

# Save 192x192 transparent for public/icon-192.png
$bmp192 = New-Object System.Drawing.Bitmap(192, 192, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g192 = [System.Drawing.Graphics]::FromImage($bmp192)
$g192.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g192.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g192.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g192.Clear([System.Drawing.Color]::Transparent)
$g192.DrawImage($desktopMaster, 0, 0, 192, 192)
$g192.Dispose()
$bmp192.Save("$projectRoot\public\icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp192.Dispose()

# 6. Generate Android Adaptive Icons with STRICT safe-zone guarantee (Zero Cropping!)
# Canvas: 108dp. Safe mask: inner 66dp diameter (radius 33dp out of 54dp).
# Content height ratio: 0.563 of canvas.
# Content width ratio: 0.506 of canvas.
# This guarantees that the farthest tip of ANY pencil is at radius <= 0.287 of canvas,
# leaving a comfortable safety margin inside the 0.305 squircle / 0.333 circle mask!
$androidDensities = @(
    @{ Name = "mdpi";    ForeSize = 108; LegacySize = 48 },
    @{ Name = "hdpi";    ForeSize = 162; LegacySize = 72 },
    @{ Name = "xhdpi";   ForeSize = 216; LegacySize = 96 },
    @{ Name = "xxhdpi";  ForeSize = 324; LegacySize = 144 },
    @{ Name = "xxxhdpi"; ForeSize = 432; LegacySize = 192 }
)

foreach ($d in $androidDensities) {
    $dir = "$projectRoot\android\app\src\main\res\mipmap-$($d.Name)"

    # A) ic_launcher_foreground.png: Scaled strictly within circular safe zone
    $fSize = $d.ForeSize
    $fgBmp = New-Object System.Drawing.Bitmap($fSize, $fSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $fgG = [System.Drawing.Graphics]::FromImage($fgBmp)
    $fgG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fgG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $fgG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $fgG.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $fgG.Clear([System.Drawing.Color]::Transparent)

    $iconH = [int]($fSize * 0.563)
    $iconW = [int]($cW * ($iconH / $cH)) # maintain exact aspect ratio
    $posX = [int](($fSize - $iconW) / 2)
    $posY = [int](($fSize - $iconH) / 2)
    $fgG.DrawImage($cropBmp, $posX, $posY, $iconW, $iconH)
    $fgG.Dispose()

    $fgBmp.Save("$dir\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $fgBmp.Dispose()

    # B) ic_launcher_round.png: Circular dark badge with pencils and L inside (Chrome-style!)
    $lSize = $d.LegacySize
    $rndBmp = New-Object System.Drawing.Bitmap($lSize, $lSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $rndG = [System.Drawing.Graphics]::FromImage($rndBmp)
    $rndG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $rndG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $rndG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rndG.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $rndG.Clear([System.Drawing.Color]::Transparent)

    # Draw circular dark badge
    $circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 14, 23))
    $rndG.FillEllipse($circleBrush, 1, 1, $lSize - 2, $lSize - 2)
    $circleBrush.Dispose()

    $lIconH = [int]($lSize * 0.72)
    $lIconW = [int]($cW * ($lIconH / $cH))
    $lPosX = [int](($lSize - $lIconW) / 2)
    $lPosY = [int](($lSize - $lIconH) / 2)
    $rndG.DrawImage($cropBmp, $lPosX, $lPosY, $lIconW, $lIconH)
    $rndG.Dispose()

    $rndBmp.Save("$dir\ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $rndBmp.Save("$dir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $rndBmp.Dispose()
    Write-Output "Updated Android $($d.Name) with zero-crop safe badges"
}

$cropBmp.Dispose()
$desktopMaster.Dispose()
Write-Output "SUCCESS: All icons generated from 100% uncut pencils!"
