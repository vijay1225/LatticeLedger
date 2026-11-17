Add-Type -AssemblyName System.Drawing

$img1024 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png")

for ($x = 0; $x -lt 1024; $x += 10) {
    $c = $img1024.GetPixel($x, 200)
    if ($c.A -gt 20) {
        Write-Output "Found non-transparent pixel at X=$($x), Y=200: A=$($c.A), R=$($c.R)"
    }
}

$img1024.Dispose()
