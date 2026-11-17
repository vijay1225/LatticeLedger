Add-Type -AssemblyName System.Drawing

# 1. Load user_reference_black.jpg
$refPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\user_reference_black.jpg"
$src = [System.Drawing.Bitmap]::FromFile($refPath)

# 2. Clone to 1024x1024 ARGB
$master = New-Object System.Drawing.Bitmap(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($master)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($src, 0, 0, 1024, 1024)

# 3. Cleanly erase the bottom-right star (X: 930-1024, Y: 930-1024) with pure black #000000
$blackBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
$g.FillRectangle($blackBrush, 930, 930, 94, 94)
$blackBrush.Dispose()
$g.Dispose()
$src.Dispose()

$cleanMasterPath = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\master_reference_no_star.png"
$master.Save($cleanMasterPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved clean 1024x1024 master without star: $cleanMasterPath"

# 4. Generate all icon sizes using bicubic supersampling
$sizes = @(16, 20, 24, 32, 48, 64, 128, 256, 512)
$genDir = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\generated_high_res"
if (-not (Test-Path $genDir)) { New-Item -ItemType Directory -Path $genDir -Force | Out-Null }

foreach ($sz in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::FromArgb(255, 0, 0, 0))
    $g.DrawImage($master, 0, 0, $sz, $sz)
    $g.Dispose()

    $outPng = "$genDir\icon_${sz}x${sz}.png"
    $bmp.Save($outPng, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Generated $outPng"
}

$master.Dispose()
Write-Output "All high-res sizes generated successfully."
