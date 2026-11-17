Add-Type -AssemblyName System.Drawing

$f = "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/media_1794924013253_93c67160.jpg"
$b = [System.Drawing.Bitmap]::FromFile($f)

Write-Output "Image size: $($b.Width)x$($b.Height)"
$c00 = $b.GetPixel(0, 0)
Write-Output "Corner(0,0): R=$($c00.R), G=$($c00.G), B=$($c00.B)"

# Check pixel stats
$blackCount = 0
$whiteCount = 0
$otherCount = 0

for ($y = 0; $y -lt $b.Height; $y += 8) {
    for ($x = 0; $x -lt $b.Width; $x += 8) {
        $c = $b.GetPixel($x, $y)
        if ($c.R -lt 25 -and $c.G -lt 25 -and $c.B -lt 25) { $blackCount++ }
        elseif ($c.R -gt 230 -and $c.G -gt 230 -and $c.B -gt 230) { $whiteCount++ }
        else { $otherCount++ }
    }
}

Write-Output "Black count: $blackCount, White count: $whiteCount, Other count: $otherCount"
$b.Dispose()
