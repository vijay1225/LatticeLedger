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
      {/* 1. Outer Hexagonal Lattice Frame */}
      <polygon
        points="256,28 454,142 454,370 256,484 58,370 58,142"
        stroke="currentColor"
        strokeWidth="20"
        strokeLinejoin="round"
      />

      {/* 6 Vertex Nodes */}
      <g fill="currentColor">
        <circle cx="256" cy="28" r="24" />
        <circle cx="454" cy="142" r="24" />
        <circle cx="454" cy="370" r="24" />
        <circle cx="256" cy="484" r="24" />
        <circle cx="58" cy="370" r="24" />
        <circle cx="58" cy="142" r="24" />
      </g>

      {/* 2. Three Stylized Orbiting Pencils */}
      {/* Top-Left Pencil */}
      <g transform="translate(182, 146) rotate(-35)">
        <path d="M -56 -14 C -68 -14, -70 14, -56 14 Z" fill="currentColor" />
        <rect x="-54" y="-14" width="8" height="28" fill="#090d16" />
        <rect x="-44" y="-14" width="70" height="28" fill="currentColor" rx="2" />
        <rect x="-40" y="-3.5" width="62" height="7" fill="#090d16" />
        <polygon points="26,-14 58,0 26,14" fill="currentColor" />
        <polygon points="42,-7 58,0 42,7" fill="#090d16" />
      </g>

      {/* Right Pencil */}
      <g transform="translate(362, 256) rotate(90)">
        <path d="M -62 -14 C -74 -14, -76 14, -62 14 Z" fill="currentColor" />
        <rect x="-60" y="-14" width="8" height="28" fill="#090d16" />
        <rect x="-50" y="-14" width="76" height="28" fill="currentColor" rx="2" />
        <rect x="-46" y="-3.5" width="68" height="7" fill="#090d16" />
        <polygon points="26,-14 60,0 26,14" fill="currentColor" />
        <polygon points="44,-7 60,0 44,7" fill="#090d16" />
      </g>

      {/* Bottom-Left Pencil */}
      <g transform="translate(182, 366) rotate(35)">
        <polygon points="-60,0 -26,-14 -26,14" fill="currentColor" />
        <polygon points="-60,0 -44,-7 -44,7" fill="#090d16" />
        <rect x="-26" y="-14" width="76" height="28" fill="currentColor" rx="2" />
        <rect x="-22" y="-3.5" width="68" height="7" fill="#090d16" />
        <rect x="50" y="-14" width="8" height="28" fill="#090d16" />
        <path d="M 60 -14 C 72 -14, 74 14, 60 14 Z" fill="currentColor" />
      </g>

      {/* 3. Central L Monogram */}
      <g stroke="currentColor" strokeWidth="20" strokeLinecap="round" strokeLinejoin="round">
        <line x1="220" y1="180" x2="220" y2="332" />
        <line x1="220" y1="332" x2="296" y2="332" />
      </g>

      <g fill="currentColor">
        <circle cx="220" cy="180" r="18" />
        <circle cx="220" cy="332" r="18" />
        <circle cx="296" cy="332" r="18" />
      </g>

      <path
        d="M 206 278 C 252 278, 298 252, 302 198 C 304 162, 274 162, 252 194 C 230 226, 224 280, 256 332"
        stroke="currentColor"
        strokeWidth="18"
        strokeLinecap="round"
      />
    </svg>
  );
};
