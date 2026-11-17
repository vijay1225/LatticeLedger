Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

# Check if there is an outer hexagon:
# Check top center pixel around (512, 10..50)
$topCenter = @()
for ($y = 0; $y -lt 100; $y++) {
    $px = $bmp.GetPixel(512, $y)
    if ($px.A -gt 50) { $topCenter += $y }
}
Write-Output "Top center pixels (x=512, y=0..100) with alpha: $($topCenter.Count) (y from $($topCenter[0]) to $($topCenter[-1]))"

# Check side pixels around (50..100, 512)
$leftSide = @()
for ($x = 0; $x -lt 100; $x++) {
    $px = $bmp.GetPixel($x, 512)
    if ($px.A -gt 50) { $leftSide += $x }
}
Write-Output "Left side pixels (x=0..100, y=512) with alpha: $($leftSide.Count)"

$bmp.Dispose()
