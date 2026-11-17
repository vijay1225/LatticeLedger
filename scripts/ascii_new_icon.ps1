Add-Type -AssemblyName System.Drawing

$img32 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\generated_high_res\icon_32x32.png")
Write-Output "New High-Res 32x32 ASCII Art preview:"
for ($y = 0; $y -lt 32; $y++) {
    $row = ""
    for ($x = 0; $x -lt 32; $x++) {
        $c = $img32.GetPixel($x, $y)
        # R value on black background
        if ($c.R -gt 180) { $row += "#" }
        elseif ($c.R -gt 80) { $row += "+" }
        elseif ($c.R -gt 25) { $row += "." }
        else { $row += " " }
    }
    Write-Output $row
}
$img32.Dispose()
