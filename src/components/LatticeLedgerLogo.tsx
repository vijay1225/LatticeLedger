import React from 'react';

export const LatticeLedgerLogo: React.FC<{ className?: string; size?: number }> = ({
  className = 'w-5 h-5',
  size = 20
}) => {
  return (
    <svg
      viewBox="0 0 512 512"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      width={size}
      height={size}
    >
      {/* 1. Three Stylized Orbiting Pencils */}
      {/* Top-Left Pencil */}
      <g transform="translate(170, 130) rotate(-35)">
        <path d="M -56 -15 C -70 -15, -72 15, -56 15 Z" fill="currentColor" />
        <rect x="-54" y="-15" width="9" height="30" fill="#090d16" />
        <rect x="-43" y="-15" width="72" height="30" fill="currentColor" rx="2" />
        <rect x="-39" y="-4" width="64" height="8" fill="#090d16" />
        <polygon points="29,-15 62,0 29,15" fill="currentColor" />
        <polygon points="46,-7.5 62,0 46,7.5" fill="#090d16" />
      </g>

      {/* Right Pencil */}
      <g transform="translate(376, 256) rotate(90)">
        <path d="M -64 -15 C -78 -15, -80 15, -64 15 Z" fill="currentColor" />
        <rect x="-62" y="-15" width="9" height="30" fill="#090d16" />
        <rect x="-51" y="-15" width="78" height="30" fill="currentColor" rx="2" />
        <rect x="-47" y="-4" width="70" height="8" fill="#090d16" />
        <polygon points="27,-15 62,0 27,15" fill="currentColor" />
        <polygon points="46,-7.5 62,0 46,7.5" fill="#090d16" />
      </g>

      {/* Bottom-Left Pencil */}
      <g transform="translate(170, 382) rotate(35)">
        <polygon points="-62,0 -27,-15 -27,15" fill="currentColor" />
        <polygon points="-62,0 -46,-7.5 -46,7.5" fill="#090d16" />
        <rect x="-27" y="-15" width="78" height="30" fill="currentColor" rx="2" />
        <rect x="-23" y="-4" width="70" height="8" fill="#090d16" />
        <rect x="53" y="-15" width="9" height="30" fill="#090d16" />
        <path d="M 64 -15 C 78 -15, 80 15, 64 15 Z" fill="currentColor" />
      </g>

      {/* 2. Central Bold L Monogram */}
      <g stroke="currentColor" strokeWidth="32" strokeLinecap="round" strokeLinejoin="round">
        <line x1="216" y1="170" x2="216" y2="345" />
        <line x1="216" y1="345" x2="310" y2="345" />
      </g>

      <g fill="currentColor">
        <circle cx="216" cy="170" r="26" />
        <circle cx="216" cy="345" r="26" />
        <circle cx="310" cy="345" r="26" />
      </g>

      <path
        d="M 194 275 C 248 275, 308 245, 314 185 C 316 142, 276 142, 250 182 C 220 226, 212 284, 250 345"
        stroke="currentColor"
        strokeWidth="30"
        strokeLinecap="round"
      />
    </svg>
  );
};
