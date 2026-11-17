Add-Type -AssemblyName System.Drawing

$f1 = "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/media_1794923596196_ffbf6d52.png"
$f2 = "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/media_1794924013253_93c67160.jpg"
$f3 = "C:/Users/Vijay/Documents/LatticeLedger/resources/icons/final_app_icons_no_star_v3/icon_v3_1024x1024.png"

$b1 = [System.Drawing.Bitmap]::FromFile($f1)
$b2 = [System.Drawing.Bitmap]::FromFile($f2)
$b3 = [System.Drawing.Bitmap]::FromFile($f3)

Write-Output "f1 (user upload 1 png): $($b1.Width)x$($b1.Height)"
Write-Output "f2 (user upload 2 jpg): $($b2.Width)x$($b2.Height)"
Write-Output "f3 (v3 1024x1024): $($b3.Width)x$($b3.Height)"

# Inspect edge sharpness of f3 vs f1
# Check transition on a horizontal line through the 'L' or hexagon
$y = 512
Write-Output "Line at Y=512 for f3 (sample pixels from X=450 to 550):"
for ($x = 450; $x -le 520; $x += 5) {
    $c = $b3.GetPixel($x, $y)
    Write-Output "  x=$($x): R=$($c.R), G=$($c.G), B=$($c.B), A=$($c.A)"
}

$b1.Dispose()
$b2.Dispose()
$b3.Dispose()
