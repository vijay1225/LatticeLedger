Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3"
$files = Get-ChildItem $dir -Filter "*.png"

foreach ($f in $files) {
    $bmp = [System.Drawing.Bitmap]::FromFile($f.FullName)
    
    # Check bounds of pixels with alpha > 10
    $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
    $hasAlpha = $false
    $nonZeroAlphaCount = 0
    
    # Sample 4 corners
    $c00 = $bmp.GetPixel(0, 0)
    $c01 = $bmp.GetPixel($bmp.Width - 1, 0)
    $c10 = $bmp.GetPixel(0, $bmp.Height - 1)
    $c11 = $bmp.GetPixel($bmp.Width - 1, $bmp.Height - 1)

    for ($y = 0; $y -lt $bmp.Height; $y++) {
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            $px = $bmp.GetPixel($x, $y)
            if ($px.A -lt 255) { $hasAlpha = $true }
            if ($px.A -gt 15 -and ($px.R -gt 20 -or $px.G -gt 20 -or $px.B -gt 20)) {
                $nonZeroAlphaCount++
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    $w = if ($maxX -ge $minX) { $maxX - $minX + 1 } else { 0 }
    $h = if ($maxY -ge $minY) { $maxY - $minY + 1 } else { 0 }
    
    Write-Output "File: $($f.Name) | Dim: $($bmp.Width)x$($bmp.Height) | HasAlpha: $hasAlpha | Corner(0,0): A=$($c00.A) R=$($c00.R) | Content: X=[$minX, $maxX], Y=[$minY, $maxY], Size=${w}x${h}"
    $bmp.Dispose()
}
