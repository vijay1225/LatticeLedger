Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

$minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        # ignore bottom-right corner sparkle (x > 900 and y > 900)
        if ($x -gt 900 -and $y -gt 900) { continue }
        $px = $bmp.GetPixel($x, $y)
        if ($px.R -gt 35) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
Write-Output "Actual Icon Content Bounds (excluding watermark):"
Write-Output "X=[$minX, $maxX], Y=[$minY, $maxY]"
Write-Output "Width=$($maxX - $minX + 1), Height=$($maxY - $minY + 1)"
$bmp.Dispose()
