$src = 'c:\Users\Vijay\Downloads\final_app_icons_no_star_v3'
$dst = 'C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3'
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Copy-Item "$src\*" $dst -Force
Write-Host "Copied files successfully:"
Get-ChildItem $dst | Select-Object Name, Length
