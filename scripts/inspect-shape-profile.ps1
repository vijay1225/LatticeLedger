Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

# Check bounds of non-alpha pixels
# Find horizontal slices at y = 100, 200, 300, 400, 500, 600, 700, 800, 900
for ($y = 100; $y -lt 1000; $y += 100) {
    $min = 1024; $max = 0
    for ($x = 0; $x -lt 1024; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 30) {
            if ($x -lt $min) { $min = $x }
            if ($x -gt $max) { $max = $x }
        }
    }
    Write-Output "Y=$y : MinX=$min, MaxX=$max (Width=$($max - $min))"
}

$bmp.Dispose()
