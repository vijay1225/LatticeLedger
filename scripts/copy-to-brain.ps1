$src = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3"
$dst = "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\v3_icons"
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Copy-Item "$src\*" $dst -Force
Write-Output "Copied to $dst"
