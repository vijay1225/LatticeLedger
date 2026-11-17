Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path "build/icon.png"))
$bmp = New-Object System.Drawing.Bitmap $img
$minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0

for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 15) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
$w = $maxX - $minX + 1
$h = $maxY - $minY + 1
Write-Output ("build/icon.png : Bounds X=[$minX, $maxX] Y=[$minY, $maxY] Content=${w}x${h} (Canvas: $($bmp.Width)x$($bmp.Height))")
$bmp.Dispose()
$img.Dispose()
