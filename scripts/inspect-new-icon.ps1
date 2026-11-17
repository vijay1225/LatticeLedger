Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)
Write-Output "Dimensions: $($bmp.Width) x $($bmp.Height)"
$minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
for ($y = 0; $y -lt $bmp.Height; $y += 2) {
    for ($x = 0; $x -lt $bmp.Width; $x += 2) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.R -gt 30 -or $px.G -gt 30 -or $px.B -gt 30) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
Write-Output "Content Bounds: X=[$minX, $maxX], Y=[$minY, $maxY]"
Write-Output "Width: $($maxX - $minX), Height: $($maxY - $minY)"

# Also let's check corner pixels to verify background
$c0 = $bmp.GetPixel(0, 0)
$c1 = $bmp.GetPixel(10, 10)
Write-Output "Corner (0,0): R=$($c0.R) G=$($c0.G) B=$($c0.B) A=$($c0.A)"
Write-Output "Corner (10,10): R=$($c1.R) G=$($c1.G) B=$($c1.B) A=$($c1.A)"
$bmp.Dispose()
