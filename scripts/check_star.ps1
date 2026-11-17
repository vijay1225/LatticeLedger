Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg")

# Check bottom right area for star/sparkle (e.g. X from 800 to 1000, Y from 800 to 1000)
$starFound = $false
for ($y = 800; $y -lt 1000; $y++) {
    for ($x = 800; $x -lt 1000; $x++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 100 -and $c.G -gt 100 -and $c.B -gt 100) {
            $starFound = $true
            break
        }
    }
    if ($starFound) { break }
}

Write-Output "Star in bottom right in user_reference_black.jpg: $starFound"
$img.Dispose()
