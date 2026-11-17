Add-Type -AssemblyName System.Drawing

$img1024 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_1024x1024.png")
$img512 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_512x512.png")
$img256 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_256x256.png")

Write-Output "1024 Size: $($img1024.Width)x$($img1024.Height)"
Write-Output "512 Size: $($img512.Width)x$($img512.Height)"
Write-Output "256 Size: $($img256.Width)x$($img256.Height)"

# Check build/icon.ico structure
$icoBytes = [System.IO.File]::ReadAllBytes("C:\Users\Vijay\Documents\LatticeLedger\build\icon.ico")
$count = [System.BitConverter]::ToUInt16($icoBytes, 4)
Write-Output "build/icon.ico contains $count images:"

for ($i = 0; $i -lt $count; $i++) {
    $offset = 6 + ($i * 16)
    $w = $icoBytes[$offset]
    $h = $icoBytes[$offset + 1]
    $planes = [System.BitConverter]::ToUInt16($icoBytes, $offset + 4)
    $bpp = [System.BitConverter]::ToUInt16($icoBytes, $offset + 6)
    $size = [System.BitConverter]::ToUInt32($icoBytes, $offset + 8)
    $imgOffset = [System.BitConverter]::ToUInt32($icoBytes, $offset + 12)
    $wDisp = if ($w -eq 0) { 256 } else { $w }
    $hDisp = if ($h -eq 0) { 256 } else { $h }
    Write-Output "  [$i] ${wDisp}x${hDisp}, bpp=$bpp, size=$size, offset=$imgOffset"
}

$img1024.Dispose()
$img512.Dispose()
$img256.Dispose()
