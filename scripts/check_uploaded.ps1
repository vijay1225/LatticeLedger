Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem "C:/Users/Vijay/.gemini/antigravity/brain/824b44a9-25f6-4ab3-978c-1edfb0458d87/.user_uploaded/"
foreach ($f in $files) {
    $img = [System.Drawing.Bitmap]::new($f.FullName)
    Write-Output "$($f.Name) -> $($img.Width)x$($img.Height)"
    $img.Dispose()
}
