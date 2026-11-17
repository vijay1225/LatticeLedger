Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

# Let's find bounding box of the central L (around x=350..650, y=300..700)
$lMinX = $bmp.Width; $lMaxX = 0; $lMinY = $bmp.Height; $lMaxY = 0
for ($y = 300; $y -lt 720; $y++) {
    for ($x = 350; $x -lt 680; $x++) {
        $px = $bmp.GetPixel($x, $y)
        if ($px.R -gt 40) {
            if ($x -lt $lMinX) { $lMinX = $x }
            if ($x -gt $lMaxX) { $lMaxX = $x }
            if ($y -lt $lMinY) { $lMinY = $y }
            if ($y -gt $lMaxY) { $lMaxY = $y }
        }
    }
}
Write-Output "Central L Bounds: X=[$lMinX, $lMaxX], Y=[$lMinY, $lMaxY]"
Write-Output "L Width=$($lMaxX - $lMinX + 1), Height=$($lMaxY - $lMinY + 1)"

# Check stroke thickness of the vertical bar of L
# Sample horizontally across the vertical bar of L (x=380..420 at y=500)
$barXs = @()
for ($x = 360; $x -lt 440; $x++) {
    $px = $bmp.GetPixel($x, 500)
    if ($px.R -gt 50) { $barXs += $x }
}
if ($barXs.Count -gt 0) {
    Write-Output "Vertical bar at y=500: X from $($barXs[0]) to $($barXs[-1]) (Thickness = $($barXs.Count)px)"
}

$bmp.Dispose()
