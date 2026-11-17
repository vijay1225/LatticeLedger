Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg")

Write-Output "Size: $($img.Width)x$($img.Height)"
# Check sample of L in center (around X=450-550, Y=450-550)
$whitePixels = 0
for ($y = 450; $y -lt 550; $y += 5) {
    for ($x = 450; $x -lt 550; $x += 5) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -gt 200) { $whitePixels++ }
    }
}
Write-Output "White pixels in center 100x100: $whitePixels (out of 400)"

$img.Dispose()
