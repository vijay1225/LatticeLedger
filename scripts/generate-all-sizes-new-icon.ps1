Add-Type -AssemblyName System.Drawing
$tight1024Path = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\new_icon_test\tight_1024.png"
$baseImg = [System.Drawing.Bitmap]::FromFile($tight1024Path)

$outDir = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\new_icon_test"
$sizes = @(512, 256, 192, 144, 128, 96, 72, 64, 48, 32, 24, 20, 16)

foreach ($sz in $sizes) {
    $bmp = [System.Drawing.Bitmap]::new($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($baseImg, 0, 0, $sz, $sz)
    $g.Dispose()

    $destPath = "$outDir\icon_${sz}x${sz}.png"
    $bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "Generated: icon_${sz}x${sz}.png"
}

# Also generate a multi-resolution ICO file
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$icoPngStreams = @()
foreach ($s in $icoSizes) {
    $file = "$outDir\icon_${s}x${s}.png"
    $icoPngStreams += [System.IO.File]::ReadAllBytes($file)
}

$icoFs = [System.IO.File]::Create("$outDir\icon.ico")
$bw = [System.IO.BinaryWriter]::new($icoFs)

$bw.Write([uint16]0)
$bw.Write([uint16]1)
$bw.Write([uint16]$icoSizes.Count)

$offset = 6 + ($icoSizes.Count * 16)
for ($i = 0; $i -lt $icoSizes.Count; $i++) {
    $s = $icoSizes[$i]
    $bWidth = if ($s -ge 256) { 0 } else { [byte]$s }
    $bHeight = if ($s -ge 256) { 0 } else { [byte]$s }
    $bw.Write([byte]$bWidth)
    $bw.Write([byte]$bHeight)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([uint16]1)
    $bw.Write([uint16]32)
    $dataLen = [uint32]$icoPngStreams[$i].Length
    $bw.Write($dataLen)
    $bw.Write([uint32]$offset)
    $offset += $dataLen
}

for ($i = 0; $i -lt $icoSizes.Count; $i++) {
    $bw.Write($icoPngStreams[$i])
}

$bw.Flush()
$bw.Close()
$icoFs.Close()
Write-Output "Generated multi-resolution icon.ico"

$baseImg.Dispose()
