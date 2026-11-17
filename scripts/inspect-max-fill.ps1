Add-Type -AssemblyName System.Drawing

$files = @('16x16', '32x32', '48x48', '64x64', '128x128', '256x256', '512x512')
foreach ($sz in $files) {
    $path = "resources/icons/max-fill/max_fill_icon_${sz}.png"
    if (Test-Path $path) {
        $img = [System.Drawing.Image]::FromFile((Resolve-Path $path))
        $bmp = New-Object System.Drawing.Bitmap $img
        $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0

        for ($y = 0; $y -lt $bmp.Height; $y++) {
            for ($x = 0; $x -lt $bmp.Width; $x++) {
                $p = $bmp.GetPixel($x, $y)
                if ($p.A -gt 10) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
        $w = if ($maxX -ge $minX) { $maxX - $minX + 1 } else { 0 }
        $h = if ($maxY -ge $minY) { $maxY - $minY + 1 } else { 0 }
        Write-Output ("$sz : Bounds X=[$minX, $maxX] Y=[$minY, $maxY] Content=${w}x${h} (Canvas: $($bmp.Width)x$($bmp.Height))")
        $bmp.Dispose()
        $img.Dispose()
    }
}
