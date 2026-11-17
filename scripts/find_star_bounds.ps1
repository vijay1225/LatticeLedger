Add-Type -AssemblyName System.Drawing

$src = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($src)

# Find exact bounds of the star in the bottom right corner
$starMinX = 1024; $starMaxX = 0; $starMinY = 1024; $starMaxY = 0

for ($y = 800; $y -lt 1024; $y++) {
    for ($x = 800; $x -lt 1024; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt 50 -or $c.G -gt 50 -or $c.B -gt 50) {
            if ($x -lt $starMinX) { $starMinX = $x }
            if ($x -gt $starMaxX) { $starMaxX = $x }
            if ($y -lt $starMinY) { $starMinY = $y }
            if ($y -gt $starMaxY) { $starMaxY = $y }
        }
    }
}

Write-Output "Star bounds: X=[$starMinX, $starMaxX], Y=[$starMinY, $starMaxY]"

# Also check bottom vertex of hexagon to make sure star is separate from the hexagon
$hexBottomY = 0
for ($y = 800; $y -lt 1024; $y++) {
    for ($x = 450; $x -lt 574; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt 100) {
            if ($y -gt $hexBottomY) { $hexBottomY = $y }
        }
    }
}
Write-Output "Hexagon bottom vertex reaches Y=$hexBottomY"
$bmp.Dispose()
