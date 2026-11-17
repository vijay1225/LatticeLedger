Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

# Check bottom right area for non-black pixels
$brPixels = @()
for ($y = 900; $y -lt 1024; $y++) {
    for ($x = 900; $x -lt 1024; $x++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.R -gt 30) {
            $brPixels += @{ X = $x; Y = $y; R = $px.R; G = $px.G; B = $px.B }
        }
    }
}
Write-Output "Found $($brPixels.Count) bright pixels in bottom-right (900..1024, 900..1024):"
if ($brPixels.Count -gt 0) {
    $minX = ($brPixels | Measure-Object -Property X -Minimum).Minimum
    $maxX = ($brPixels | Measure-Object -Property X -Maximum).Maximum
    $minY = ($brPixels | Measure-Object -Property Y -Minimum).Minimum
    $maxY = ($brPixels | Measure-Object -Property Y -Maximum).Maximum
    Write-Output "Watermark sparkle bounds: X=[$minX, $maxX], Y=[$minY, $maxY]"
}

$bmp.Dispose()
