Add-Type -AssemblyName System.Drawing

$img32 = [System.Drawing.Bitmap]::FromFile("C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_32x32.png")
Write-Output "32x32 ASCII Art preview:"
for ($y = 0; $y -lt 32; $y++) {
    $row = ""
    for ($x = 0; $x -lt 32; $x++) {
        $c = $img32.GetPixel($x, $y)
        if ($c.A -gt 180) { $row += "#" }
        elseif ($c.A -gt 60) { $row += "+" }
        elseif ($c.A -gt 15) { $row += "." }
        else { $row += " " }
    }
    Write-Output $row
}
$img32.Dispose()
