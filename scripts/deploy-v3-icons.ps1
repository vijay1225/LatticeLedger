Add-Type -AssemblyName System.Drawing

$srcDir = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3"
$projectRoot = "C:\Users\Vijay\Documents\LatticeLedger"
$brainDir = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\v3_icons"

# Load source 512x512 bitmap for downsampling missing sizes
$src512 = [System.Drawing.Bitmap]::FromFile("$srcDir\icon_v3_512x512.png")

function Resample-Image {
    param([System.Drawing.Bitmap]$source, [int]$targetSize, [string]$outputPath)
    $dest = New-Object System.Drawing.Bitmap $targetSize, $targetSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($source, 0, 0, $targetSize, $targetSize)
    $g.Dispose()
    $dest.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
    Write-Output "Resampled $targetSize x $targetSize -> $outputPath"
}

# 1. Generate missing sizes in srcDir and brainDir
Resample-Image -source $src512 -targetSize 96 -outputPath "$srcDir\icon_v3_96x96.png"
Resample-Image -source $src512 -targetSize 72 -outputPath "$srcDir\icon_v3_72x72.png"
Resample-Image -source $src512 -targetSize 24 -outputPath "$srcDir\icon_v3_24x24.png"
Resample-Image -source $src512 -targetSize 20 -outputPath "$srcDir\icon_v3_20x20.png"

Copy-Item "$srcDir\icon_v3_96x96.png" "$brainDir\" -Force
Copy-Item "$srcDir\icon_v3_72x72.png" "$brainDir\" -Force
Copy-Item "$srcDir\icon_v3_24x24.png" "$brainDir\" -Force
Copy-Item "$srcDir\icon_v3_20x20.png" "$brainDir\" -Force

# 2. Deploy to build/
Copy-Item "$srcDir\icon_v3_512x512.png" "$projectRoot\build\icon.png" -Force

# 3. Deploy to public/
Copy-Item "$srcDir\icon_v3_512x512.png" "$projectRoot\public\icon-512.png" -Force
Copy-Item "$srcDir\icon_v3_192x192.png" "$projectRoot\public\icon-192.png" -Force

# 4. Deploy Android mipmaps
$androidMap = @{
    "mipmap-mdpi" = "$srcDir\icon_v3_48x48.png"
    "mipmap-hdpi" = "$srcDir\icon_v3_72x72.png"
    "mipmap-xhdpi" = "$srcDir\icon_v3_96x96.png"
    "mipmap-xxhdpi" = "$srcDir\icon_v3_144x144.png"
    "mipmap-xxxhdpi" = "$srcDir\icon_v3_192x192.png"
}

foreach ($entry in $androidMap.GetEnumerator()) {
    $dir = "$projectRoot\android\app\src\main\res\$($entry.Key)"
    if (Test-Path $dir) {
        Copy-Item $entry.Value "$dir\ic_launcher.png" -Force
        Copy-Item $entry.Value "$dir\ic_launcher_round.png" -Force
        Copy-Item $entry.Value "$dir\ic_launcher_foreground.png" -Force
        Write-Output "Updated Android $($entry.Key)"
    }
}

# 5. Build proper multi-resolution icon.ico and favicon.ico
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$pngDataList = [System.Collections.Generic.List[byte[]]]::new()

foreach ($sz in $icoSizes) {
    $file = "$srcDir\icon_v3_${sz}x${sz}.png"
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $pngDataList.Add($bytes)
    Write-Output "ICO entry: ${sz}x${sz} ($($bytes.Length) bytes)"
}

function Write-MultiResIco {
    param([string]$targetPath)
    $fs = [System.IO.File]::Create($targetPath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    $count = $icoSizes.Count
    $bw.Write([uint16]0) # Reserved
    $bw.Write([uint16]1) # Type 1 = ICO
    $bw.Write([uint16]$count)

    $offset = 6 + (16 * $count)

    for ($i = 0; $i -lt $count; $i++) {
        $sz = $icoSizes[$i]
        $len = $pngDataList[$i].Length
        $bWidth = if ($sz -ge 256) { 0 } else { [byte]$sz }
        $bHeight = if ($sz -ge 256) { 0 } else { [byte]$sz }

        $bw.Write([byte]$bWidth)
        $bw.Write([byte]$bHeight)
        $bw.Write([byte]0) # Palette
        $bw.Write([byte]0) # Reserved
        $bw.Write([uint16]1) # Planes
        $bw.Write([uint16]32) # Bit count
        $bw.Write([uint32]$len) # Data length
        $bw.Write([uint32]$offset) # Offset
        $offset += $len
    }

    for ($i = 0; $i -lt $count; $i++) {
        $bytes = $pngDataList[$i]
        $bw.Write($bytes, 0, $bytes.Length)
    }

    $bw.Flush()
    $bw.Close()
    $fs.Close()
    Write-Output "Successfully generated: $targetPath ($((Get-Item $targetPath).Length) bytes)"
}

Write-MultiResIco -targetPath "$projectRoot\build\icon.ico"
Write-MultiResIco -targetPath "$projectRoot\public\favicon.ico"
Write-MultiResIco -targetPath "$brainDir\icon.ico"

$src512.Dispose()
Write-Output "All icon optimizations and deployments completed!"
