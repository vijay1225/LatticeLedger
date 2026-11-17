Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/media_1794923596196_ffbf6d52.png"))
$bmp = New-Object System.Drawing.Bitmap $img

$minX = $bmp.Width; $maxX = 0
$minY = $bmp.Height; $maxY = 0
$opaqueBlackCount = 0
$opaqueWhiteCount = 0

for ($y = 0; $y -lt $bmp.Height; $y += 4) {
    for ($x = 0; $x -lt $bmp.Width; $x += 4) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
            if ($p.R -lt 50 -and $p.G -lt 50 -and $p.B -lt 50) {
                $opaqueBlackCount++
            } elseif ($p.R -gt 200 -and $p.G -gt 200 -and $p.B -gt 200) {
                $opaqueWhiteCount++
            }
        }
    }
}

Write-Output "Bounds with A > 20: X=[$minX, $maxX], Y=[$minY, $maxY]"
Write-Output "Opaque black pixels sampled: $opaqueBlackCount"
Write-Output "Opaque white pixels sampled: $opaqueWhiteCount"

$bmp.Dispose()
$img.Dispose()
