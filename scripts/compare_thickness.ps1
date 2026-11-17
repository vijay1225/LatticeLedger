Add-Type -AssemblyName System.Drawing

$imgRef = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg")
$imgV3 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png")

# Measure stroke thickness of vertical pencil at X=700-750, Y=500
$refPencilWidth = 0
for ($x = 650; $x -lt 850; $x++) {
    $c = $imgRef.GetPixel($x, 500)
    if ($c.R -gt 100) { $refPencilWidth++ }
}

$v3PencilWidth = 0
for ($x = 650; $x -lt 850; $x++) {
    $c = $imgV3.GetPixel($x, 500)
    if ($c.A -gt 100) { $v3PencilWidth++ }
}

Write-Output "User reference pencil width: $refPencilWidth px"
Write-Output "V3 folder pencil width: $v3PencilWidth px"

# Measure hexagon line thickness on top-left diagonal (around Y=300)
$refHexWidth = 0
for ($x = 100; $x -lt 250; $x++) {
    $c = $imgRef.GetPixel($x, 300)
    if ($c.R -gt 100) { $refHexWidth++ }
}

$v3HexWidth = 0
for ($x = 100; $x -lt 250; $x++) {
    $c = $imgV3.GetPixel($x, 300)
    if ($c.A -gt 100) { $v3HexWidth++ }
}

Write-Output "User reference hexagon thickness at Y=300: $refHexWidth px"
Write-Output "V3 folder hexagon thickness at Y=300: $v3HexWidth px"

$imgRef.Dispose()
$imgV3.Dispose()
