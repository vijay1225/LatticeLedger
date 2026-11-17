$src = "C:\Users\Vijay\Documents\LatticeLedger\resources\icons\final_app_icons_no_star_v3\icon_v3_512x512.png"
$bytes = [System.IO.File]::ReadAllBytes($src)
$b64 = [Convert]::ToBase64String($bytes)
$dataUri = "data:image/png;base64,$b64"

# 1. Update public/icon.svg
$svgContent = @"
<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
  <image href="$dataUri" width="512" height="512" />
</svg>
"@
[System.IO.File]::WriteAllText("C:\Users\Vijay\Documents\LatticeLedger\public\icon.svg", $svgContent)
[System.IO.File]::WriteAllText("C:\Users\Vijay\Documents\LatticeLedger\public\favicon.svg", $svgContent)
Write-Output "Updated public/icon.svg and public/favicon.svg with base64 embedded v3 icon"

# 2. Update src/components/LatticeLedgerLogo.tsx
$tsxContent = @"
import React from 'react';

const LOGO_DATA_URI = '$dataUri';

export const LatticeLedgerLogo: React.FC<{ className?: string; size?: number }> = ({
  className = 'w-5 h-5',
  size = 20
}) => {
  return (
    <img
      src={LOGO_DATA_URI}
      alt="LatticeLedger Logo"
      className={className}
      width={size}
      height={size}
      style={{ display: 'inline-block', verticalAlign: 'middle' }}
    />
  );
};
"@
[System.IO.File]::WriteAllText("C:\Users\Vijay\Documents\LatticeLedger\src\components\LatticeLedgerLogo.tsx", $tsxContent)
Write-Output "Updated src/components/LatticeLedgerLogo.tsx with pixel-perfect v3 logo"
