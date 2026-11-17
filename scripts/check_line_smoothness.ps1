Add-Type -AssemblyName System.Drawing

$img1024 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png")

# Check if the 1024x1024 image is actually a true 1024x1024, or if it has blurry / blocky pixels
# Let's check a slanted line (e.g. on the hexagon upper-right edge)
# Hexagon upper right goes from (512, ~50) to (~950, ~270)
$edgeChanges = 0
for ($y = 100; $y -lt 200; $y++) {
    $row = ""
    for ($x = 600; $x -lt 680; $x++) {
        $c = $img1024.GetPixel($x, $y)
        if ($c.A -gt 128) { $row += "#" }
        elseif ($c.A -gt 20) { $row += "." }
        else { $row += " " }
    }
    if ($y % 10 -eq 0) {
        Write-Output "Y=$($y): $row"
    }
}

$img1024.Dispose()
