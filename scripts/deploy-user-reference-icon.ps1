Add-Type -AssemblyName System.Drawing

$projectRoot = "C:\Users\Vijay\Documents\LatticeLedger"
$userImgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"

if (-not (Test-Path $userImgPath)) {
    Write-Error "Source image not found: $userImgPath"
    exit 1
}

$raw = [System.Drawing.Bitmap]::FromFile($userImgPath)
$w = $raw.Width
$h = $raw.Height

Write-Output "Processing source image: ${w}x${h}"

# 1. Clean extraction & remove star watermark in bottom right
$clean = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)

$srcData = $raw.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$dstData = $clean.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$srcBytes = New-Object byte[] ($srcData.Stride * $h)
$dstBytes = New-Object byte[] ($dstData.Stride * $h)

[System.Runtime.InteropServices.Marshal]::Copy($srcData.Scan0, $srcBytes, 0, $srcBytes.Length)

$minX = $w; $maxX = 0; $minY = $h; $maxY = 0

for ($y = 0; $y -lt $h; $y++) {
    $srcRow = $y * $srcData.Stride
    $dstRow = $y * $dstData.Stride
    for ($x = 0; $x -lt $w; $x++) {
        $si = $srcRow + ($x * 3)
        $di = $dstRow + ($x * 4)

        # Star watermark region in bottom right: wipe clean
        if ($x -ge 860 -and $y -ge 860) {
            $dstBytes[$di] = 0; $dstBytes[$di+1] = 0; $dstBytes[$di+2] = 0; $dstBytes[$di+3] = 0
            continue
        }

        $b = $srcBytes[$si]
        $g = $srcBytes[$si+1]
        $r = $srcBytes[$si+2]

        $lum = [int](0.299 * $r + 0.587 * $g + 0.114 * $b)

        if ($lum -lt 25) {
            $dstBytes[$di] = 0; $dstBytes[$di+1] = 0; $dstBytes[$di+2] = 0; $dstBytes[$di+3] = 0
        } else {
            $alpha = 0
            if ($lum -ge 200) {
                $alpha = 255
            } else {
                $alpha = [int]((($lum - 25) / 175.0) * 255)
            }

            if ($alpha -gt 15) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }

            $dstBytes[$di] = 255
            $dstBytes[$di+1] = 255
            $dstBytes[$di+2] = 255
            $dstBytes[$di+3] = [byte]$alpha
        }
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($dstBytes, 0, $dstData.Scan0, $dstBytes.Length)
$clean.UnlockBits($dstData)
$raw.UnlockBits($srcData)
$raw.Dispose()

$cW = $maxX - $minX + 1
$cH = $maxY - $minY + 1
Write-Output "Cleaned content bounds: X=[$minX, $maxX], Y=[$minY, $maxY], Size=${cW}x${cH}"

# 2. Crop to exact content bounding box
$cropBmp = New-Object System.Drawing.Bitmap($cW, $cH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cropG = [System.Drawing.Graphics]::FromImage($cropBmp)
$cropG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$cropG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$cropG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$cropG.Clear([System.Drawing.Color]::Transparent)
$cropG.DrawImage($clean, 0, 0, (New-Object System.Drawing.Rectangle($minX, $minY, $cW, $cH)), [System.Drawing.GraphicsUnit]::Pixel)
$cropG.Dispose()
$clean.Dispose()

# 3. Create Master Desktop Graphic (1024x1024, Transparent, Subtle Dark Contour for Light Wallpapers)
# Center the content with comfortable margin
$desktopMaster = New-Object System.Drawing.Bitmap(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$dg = [System.Drawing.Graphics]::FromImage($desktopMaster)
$dg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$dg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$dg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$dg.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$dg.Clear([System.Drawing.Color]::Transparent)

# Scale content to 840px height inside 1024 canvas
$dtH = 840
$scale = $dtH / $cH
$dtW = [int]($cW * $scale)
$dtX = [int]((1024 - $dtW) / 2)
$dtY = [int]((1024 - $dtH) / 2)

# Add subtle dark contour shadow (3px offset in 4 directions) for visibility on white wallpaper
$shadowAttr = New-Object System.Drawing.Imaging.ImageAttributes
$shadowMatrix = New-Object System.Drawing.Imaging.ColorMatrix
$shadowMatrix.Matrix00 = 0.0; $shadowMatrix.Matrix11 = 0.0; $shadowMatrix.Matrix22 = 0.0
$shadowMatrix.Matrix33 = 0.45 # 45% alpha dark contour
$shadowAttr.SetColorMatrix($shadowMatrix)

$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($dtX + 3), ($dtY + 3), $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($dtX - 2), $dtY, $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle(($dtX + 2), $dtY, $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($dtX, ($dtY - 2), $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($dtX, ($dtY + 2), $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel, $shadowAttr)

# Draw crisp pure white pencils & L
$dg.DrawImage($cropBmp, (New-Object System.Drawing.Rectangle($dtX, $dtY, $dtW, $dtH)), 0, 0, $cW, $cH, [System.Drawing.GraphicsUnit]::Pixel)
$dg.Dispose()

# Save desktop master & build icons
$desktopMaster.Save("$projectRoot\build\icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$desktopMaster.Save("$projectRoot\public\icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)

$ico192 = New-Object System.Drawing.Bitmap(192, 192, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g192 = [System.Drawing.Graphics]::FromImage($ico192)
$g192.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g192.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g192.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g192.Clear([System.Drawing.Color]::Transparent)
$g192.DrawImage($desktopMaster, 0, 0, 192, 192)
$g192.Dispose()
$ico192.Save("$projectRoot\public\icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$ico192.Dispose()

# 4. Generate True Windows ICO with 256 PNG + DIB Bitmaps
function Write-TrueWindowsIcoFile($sourceBmp, $targetIcoPath) {
    $sizes = @(256, 128, 64, 48, 32, 24, 20, 16)
    $count = $sizes.Count
    $entryDataList = [System.Collections.Generic.List[byte[]]]::new()

    foreach ($sz in $sizes) {
        $dest = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($dest)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($sourceBmp, 0, 0, $sz, $sz)
        $g.Dispose()

        if ($sz -eq 256) {
            $ms = New-Object System.IO.MemoryStream
            $dest.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
            $entryDataList.Add($ms.ToArray())
            $ms.Dispose()
        } else {
            $ms = New-Object System.IO.MemoryStream
            $bw = New-Object System.IO.BinaryWriter($ms)

            $bw.Write([uint32]40)
            $bw.Write([int32]$sz)
            $bw.Write([int32]($sz * 2))
            $bw.Write([uint16]1)
            $bw.Write([uint16]32)
            $bw.Write([uint32]0)
            $bw.Write([uint32]($sz * $sz * 4))
            $bw.Write([int32]0)
            $bw.Write([int32]0)
            $bw.Write([uint32]0)
            $bw.Write([uint32]0)

            $rect = New-Object System.Drawing.Rectangle(0, 0, $sz, $sz)
            $bmpData = $dest.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $rowBytes = $sz * 4
            $buf = New-Object byte[] ($rowBytes * $sz)
            [System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $buf, 0, $buf.Length)
            $dest.UnlockBits($bmpData)

            for ($y = $sz - 1; $y -ge 0; $y--) {
                $rowOffset = $y * $rowBytes
                $bw.Write($buf, $rowOffset, $rowBytes)
            }

            $andRowBytes = [int]([Math]::Ceiling($sz / 32.0) * 4)
            $andMask = New-Object byte[] ($andRowBytes * $sz)
            $bw.Write($andMask)

            $bw.Flush()
            $entryDataList.Add($ms.ToArray())
            $ms.Dispose()
        }
        $dest.Dispose()
    }

    $fs = [System.IO.File]::Create($targetIcoPath)
    $icoWriter = New-Object System.IO.BinaryWriter($fs)

    $icoWriter.Write([uint16]0)
    $icoWriter.Write([uint16]1)
    $icoWriter.Write([uint16]$count)

    $headerSize = 6 + ($count * 16)
    $currentOffset = $headerSize

    for ($i = 0; $i -lt $count; $i++) {
        $sz = $sizes[$i]
        $bWidth = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
        $bHeight = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
        $icoWriter.Write($bWidth)
        $icoWriter.Write($bHeight)
        $icoWriter.Write([byte]0)
        $icoWriter.Write([byte]0)
        $icoWriter.Write([uint16]1)
        $icoWriter.Write([uint16]32)
        $icoWriter.Write([uint32]$entryDataList[$i].Length)
        $icoWriter.Write([uint32]$currentOffset)
        $currentOffset += $entryDataList[$i].Length
    }

    for ($i = 0; $i -lt $count; $i++) {
        $icoWriter.Write($entryDataList[$i])
    }

    $icoWriter.Flush()
    $icoWriter.Close()
    $fs.Close()
    Write-Output "Written ICO: $targetIcoPath"
}

Write-TrueWindowsIcoFile $desktopMaster "$projectRoot\build\icon.ico"
Write-TrueWindowsIcoFile $desktopMaster "$projectRoot\public\favicon.ico"

# 5. Generate Android Adaptive Icons & Round Badges (Zero Cropping Guarantee!)
$androidDensities = @(
    @{ Name = "mdpi";    ForeSize = 108; LegacySize = 48 },
    @{ Name = "hdpi";    ForeSize = 162; LegacySize = 72 },
    @{ Name = "xhdpi";   ForeSize = 216; LegacySize = 96 },
    @{ Name = "xxhdpi";  ForeSize = 324; LegacySize = 144 },
    @{ Name = "xxxhdpi"; ForeSize = 432; LegacySize = 192 }
)

foreach ($d in $androidDensities) {
    $dir = "$projectRoot\android\app\src\main\res\mipmap-$($d.Name)"

    # A) ic_launcher_foreground.png: Scaled to 55% of canvas (height = ForeSize * 0.55)
    # This guarantees max radius <= 0.28 of canvas, strictly inside the 0.33 safe circle!
    $fSize = $d.ForeSize
    $fgBmp = New-Object System.Drawing.Bitmap($fSize, $fSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $fgG = [System.Drawing.Graphics]::FromImage($fgBmp)
    $fgG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $fgG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $fgG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $fgG.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $fgG.Clear([System.Drawing.Color]::Transparent)

    $iconH = [int]($fSize * 0.55)
    $iconW = [int]($cW * ($iconH / $cH))
    $posX = [int](($fSize - $iconW) / 2)
    $posY = [int](($fSize - $iconH) / 2)
    $fgG.DrawImage($cropBmp, $posX, $posY, $iconW, $iconH)
    $fgG.Dispose()

    $fgBmp.Save("$dir\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $fgBmp.Dispose()

    # B) ic_launcher_round.png and ic_launcher.png: Circular dark badge (Chrome-style!)
    $lSize = $d.LegacySize
    $rndBmp = New-Object System.Drawing.Bitmap($lSize, $lSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $rndG = [System.Drawing.Graphics]::FromImage($rndBmp)
    $rndG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $rndG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $rndG.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rndG.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $rndG.Clear([System.Drawing.Color]::Transparent)

    # Circular dark badge (#0a0e17)
    $circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 14, 23))
    $rndG.FillEllipse($circleBrush, 1, 1, ($lSize - 2), ($lSize - 2))
    $circleBrush.Dispose()

    # Subtle sleek ring around circular badge
    $ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 1.0)
    $rndG.DrawEllipse($ringPen, 1, 1, ($lSize - 2), ($lSize - 2))
    $ringPen.Dispose()

    # Scale icon inside circle
    $lIconH = [int]($lSize * 0.68)
    $lIconW = [int]($cW * ($lIconH / $cH))
    $lPosX = [int](($lSize - $lIconW) / 2)
    $lPosY = [int](($lSize - $lIconH) / 2)
    $rndG.DrawImage($cropBmp, $lPosX, $lPosY, $lIconW, $lIconH)
    $rndG.Dispose()

    $rndBmp.Save("$dir\ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $rndBmp.Save("$dir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $rndBmp.Dispose()

    Write-Output "Generated Android icons for $($d.Name)"
}

$cropBmp.Dispose()
$desktopMaster.Dispose()
Write-Output "COMPLETED: All icons updated with zero pencil cropping & true Windows DIB ICOs!"
