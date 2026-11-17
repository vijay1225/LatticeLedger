Add-Type -AssemblyName System.Drawing

$srcDir = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\generated_high_res"
$projectRoot = "C:\Users\Vijay\Documents\LatticeLedger"
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$pngDataList = [System.Collections.Generic.List[byte[]]]::new()

foreach ($sz in $icoSizes) {
    $file = "$srcDir\icon_${sz}x${sz}.png"
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
    Write-Output "Generated: $targetPath ($((Get-Item $targetPath).Length) bytes)"
}

Write-MultiResIco -targetPath "$projectRoot\build\icon.ico"
Write-MultiResIco -targetPath "$projectRoot\public\favicon.ico"
Copy-Item "$srcDir\icon_512x512.png" "$projectRoot\build\icon.png" -Force
Copy-Item "$srcDir\icon_512x512.png" "$projectRoot\public\icon-512.png" -Force
Write-Output "Deployed new high-res master icon to build/ and public/"
