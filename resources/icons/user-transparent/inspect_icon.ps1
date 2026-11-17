Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path "resources/icons/user-transparent/transparent_icon_512x512.png"))
$bmp = New-Object System.Drawing.Bitmap $img
$minX = $bmp.Width
$maxX = 0
$minY = $bmp.Height
$maxY = 0

for ($y = 0; $y -lt $bmp.Height; $y += 4) {
    for ($x = 0; $x -lt $bmp.Width; $x += 4) {
        $pixel = $bmp.GetPixel($x, $y)
        if ($pixel.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
Write-Output "Bounds: X=[$minX, $maxX], Y=[$minY, $maxY], Width=$($maxX - $minX), Height=$($maxY - $minY)"
$bmp.Dispose()
$img.Dispose()
