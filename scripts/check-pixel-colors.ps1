Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.user_uploaded\media_1794924013253_93c67160.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($imgPath)

# Sample along some rows and columns
$hist = @{}
for ($y = 0; $y -lt $bmp.Height; $y += 8) {
    for ($x = 0; $x -lt $bmp.Width; $x += 8) {
        $px = $bmp.GetPixel($x, $y)
        $brightness = [int]($px.GetBrightness() * 10)
        $hist[$brightness] = [int]$hist[$brightness] + 1
    }
}
Write-Output "Brightness distribution (0=black, 10=white):"
$hist.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key): $($_.Value)" }

$bmp.Dispose()
