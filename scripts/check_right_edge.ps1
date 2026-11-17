Add-Type -AssemblyName System.Drawing

$img1024 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png")

Write-Output "Sampling right edge at X=850-980, Y=200-800:"
$found = 0
for ($y = 200; $y -lt 800; $y += 50) {
    for ($x = 850; $x -lt 980; $x += 10) {
        $c = $img1024.GetPixel($x, $y)
        if ($c.A -gt 50) {
            $found++
            Write-Output "Pixel at X=$($x), Y=$($y): A=$($c.A)"
        }
    }
}
Write-Output "Total non-transparent pixels in right region: $found"
$img1024.Dispose()
