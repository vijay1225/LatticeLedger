Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile((Resolve-Path "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/media_1794923596196_ffbf6d52.png"))
Write-Output "Image Dimensions: $($img.Width) x $($img.Height)"
$bmp = New-Object System.Drawing.Bitmap $img
$p00 = $bmp.GetPixel(0, 0)
Write-Output "Pixel at (0,0): A=$($p00.A) R=$($p00.R) G=$($p00.G) B=$($p00.B)"
$pCenter = $bmp.GetPixel([int]($img.Width/2), [int]($img.Height/2))
Write-Output "Pixel at Center: A=$($pCenter.A) R=$($pCenter.R) G=$($pCenter.G) B=$($pCenter.B)"

$bmp.Dispose()
$img.Dispose()
