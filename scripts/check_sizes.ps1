Add-Type -AssemblyName System.Drawing

$dir = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3"
$sizes = @(16, 20, 24, 32, 48, 64, 128, 256, 512, 1024)

foreach ($s in $sizes) {
    $path = "$dir\icon_v3_${s}x${s}.png"
    if (Test-Path $path) {
        $bmp = [System.Drawing.Bitmap]::FromFile($path)
        Write-Output "Size ${s}x${s}: File size=$((Get-Item $path).Length) bytes"
        $bmp.Dispose()
    }
}
