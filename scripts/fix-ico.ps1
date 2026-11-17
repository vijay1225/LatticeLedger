$outDir = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\new_icon_test"
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$pngDataList = [System.Collections.Generic.List[byte[]]]::new()

foreach ($sz in $icoSizes) {
    $bytes = [System.IO.File]::ReadAllBytes("$outDir\icon_${sz}x${sz}.png")
    $pngDataList.Add($bytes)
    Write-Output "Size ${sz} - $($bytes.Length) bytes"
}

function Create-ValidIco {
    param([string]$targetPath)
    $fs = [System.IO.File]::Create($targetPath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    $count = $icoSizes.Count
    $bw.Write([uint16]0) # Reserved
    $bw.Write([uint16]1) # Type 1 = ICO
    $bw.Write([uint16]$count) # Image count

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
    Write-Output "Successfully wrote $targetPath ($((Get-Item $targetPath).Length) bytes)"
}

Create-ValidIco -targetPath "$outDir\icon.ico"
Create-ValidIco -targetPath "build\icon.ico"
Create-ValidIco -targetPath "public\favicon.ico"
