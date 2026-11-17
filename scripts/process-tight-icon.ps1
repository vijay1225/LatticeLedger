Add-Type -AssemblyName System.Drawing
$srcPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$src = [System.Drawing.Bitmap]::FromFile($srcPath)

# 1. First create 1024x1024 transparent bitmap
$transBmp = [System.Drawing.Bitmap]::new(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt 1024; $y++) {
    for ($x = 0; $x -lt 1024; $x++) {
        # ignore watermark in bottom right
        if ($x -gt 890 -and $y -gt 890) {
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 255, 255, 255))
            continue
        }
        $px = $src.GetPixel($x, $y)
        # Use maximum of R,G,B as alpha
        $alpha = [int][Math]::Max($px.R, [Math]::Max($px.G, $px.B))
        if ($alpha -lt 15) {
            # clean cutoff for compression artifacts in black background
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 255, 255, 255))
        } else {
            # Normalize slightly for crispness
            $clampedAlpha = [int][Math]::Min(255, [Math]::Round(($alpha - 15) * (255.0 / 235.0)))
            if ($clampedAlpha -gt 255) { $clampedAlpha = 255 }
            if ($clampedAlpha -lt 0) { $clampedAlpha = 0 }
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($clampedAlpha, 255, 255, 255))
        }
    }
}

# 2. Find exact tight content bounds
$minX = 1024; $maxX = 0; $minY = 1024; $maxY = 0
for ($y = 0; $y -lt 1024; $y++) {
    for ($x = 0; $x -lt 1024; $x++) {
        $p = $transBmp.GetPixel($x, $y)
        if ($p.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Tight transparent bounds: X=[$minX, $maxX], Y=[$minY, $maxY]"
$contentW = $maxX - $minX + 1
$contentH = $maxY - $minY + 1
Write-Output "Content size: $contentW x $contentH"

# 3. Create square max-fill cropped version
# Center the content into a square with minimal padding (e.g. 2% padding so it touches edges without clipping)
$maxDim = [Math]::Max($contentW, $contentH)
$padding = [int]($maxDim * 0.02)
$squareDim = $maxDim + ($padding * 2)

$squareBmp = [System.Drawing.Bitmap]::new(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($squareBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

# Source rectangle from transBmp
$offsetX = ($maxDim - $contentW) / 2.0
$offsetY = ($maxDim - $contentH) / 2.0

$srcRect = [System.Drawing.Rectangle]::new($minX, $minY, $contentW, $contentH)
# Destination in 1024x1024
$destW = [int]((1024.0 - ($padding * 2.0 / $squareDim * 1024.0)) * ($contentW / [double]$maxDim))
$destH = [int]((1024.0 - ($padding * 2.0 / $squareDim * 1024.0)) * ($contentH / [double]$maxDim))
$destX = [int]((1024 - $destW) / 2)
$destY = [int]((1024 - $destH) / 2)

$destRect = [System.Drawing.Rectangle]::new($destX, $destY, $destW, $destH)
$g.DrawImage($transBmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$outDir = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\new_icon_test"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$squareBmp.Save("$outDir\tight_1024.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved $outDir\tight_1024.png"

$src.Dispose()
$transBmp.Dispose()
$squareBmp.Dispose()
