Add-Type -AssemblyName System.Drawing
$sizes = @(16, 20, 24, 32, 48)
foreach ($sz in $sizes) {
    $path = "resources/icons/max-fill/tight/icon_${sz}x${sz}.png"
    $img = [System.Drawing.Image]::FromFile((Resolve-Path $path))
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
    $w = if ($maxX -ge $minX) { $maxX - $minX + 1 } else { 0 }
    $h = if ($maxY -ge $minY) { $maxY - $minY + 1 } else { 0 }
    Write-Output ("Tight ${sz}x${sz} : Bounds X=[$minX, $maxX] Y=[$minY, $maxY] Content=${w}x${h} (Canvas: ${sz}x${sz})")
    $bmp.Dispose()
    $img.Dispose()
}
