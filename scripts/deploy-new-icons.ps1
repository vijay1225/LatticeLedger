$srcDir = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\new_icon_test"
$projectRoot = "C:\Users\Vijay\Documents\LatticeLedger"

# 1. Update build/
Copy-Item "$srcDir\icon.ico" "$projectRoot\build\icon.ico" -Force
Copy-Item "$srcDir\icon_512x512.png" "$projectRoot\build\icon.png" -Force

# 2. Update public/
Copy-Item "$srcDir\icon.ico" "$projectRoot\public\favicon.ico" -Force
Copy-Item "$srcDir\icon_512x512.png" "$projectRoot\public\icon-512.png" -Force
Copy-Item "$srcDir\icon_192x192.png" "$projectRoot\public\icon-192.png" -Force

# 3. Update Android mipmaps
$densities = @{
    "mipmap-mdpi" = "$srcDir\icon_48x48.png"
    "mipmap-hdpi" = "$srcDir\icon_72x72.png"
    "mipmap-xhdpi" = "$srcDir\icon_96x96.png"
    "mipmap-xxhdpi" = "$srcDir\icon_144x144.png"
    "mipmap-xxxhdpi" = "$srcDir\icon_192x192.png"
}

foreach ($entry in $densities.GetEnumerator()) {
    $folder = "$projectRoot\android\app\src\main\res\$($entry.Key)"
    if (Test-Path $folder) {
        Copy-Item $entry.Value "$folder\ic_launcher.png" -Force
        Copy-Item $entry.Value "$folder\ic_launcher_round.png" -Force
        Copy-Item $entry.Value "$folder\ic_launcher_foreground.png" -Force
        Write-Output "Updated Android $($entry.Key)"
    }
}

Write-Output "All app icon assets successfully updated from new icon test directory!"
