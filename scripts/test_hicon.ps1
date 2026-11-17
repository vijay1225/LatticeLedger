Add-Type -AssemblyName System.Drawing

# Test if Bitmap.GetHicon() creates a valid Windows Icon
$src = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($src)
$resized = New-Object System.Drawing.Bitmap(48, 48)
$g = [System.Drawing.Graphics]::FromImage($resized)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($bmp, 0, 0, 48, 48)
$g.Dispose()

$hIcon = $resized.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = [System.IO.File]::Create("test_48.ico")
$icon.Save($fs)
$fs.Close()
$icon.Dispose()
$resized.Dispose()
$bmp.Dispose()

$bytes = [System.IO.File]::ReadAllBytes("test_48.ico")
Write-Output "Generated test_48.ico: $($bytes.Length) bytes"
Write-Output "Header Type: $([System.BitConverter]::ToUInt16($bytes, 2))"
Write-Output "Image Count: $([System.BitConverter]::ToUInt16($bytes, 4))"
$bpp = [System.BitConverter]::ToUInt16($bytes, 12)
Write-Output "Bits Per Pixel: $bpp"
# Check if image data starts with PNG header (0x89 0x50 0x4E 0x47) or BITMAPINFOHEADER (size 40)
$offset = [System.BitConverter]::ToUInt32($bytes, 18)
$bihSize = [System.BitConverter]::ToUInt32($bytes, $offset)
Write-Output "Image data starts at $offset with header size: $bihSize"
Remove-Item "test_48.ico" -Force
