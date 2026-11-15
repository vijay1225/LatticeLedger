import React from 'react';

export const LatticeLedgerLogo: React.FC<{ className?: string; size?: number }> = ({
  className = 'w-5 h-5',
  size = 20
}) => {
  return (
    <svg
      viewBox="0 0 32 32"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      width={size}
      height={size}
    >
      <defs>
        <linearGradient id="ll-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#38bdf8" />
          <stop offset="50%" stopColor="#10b981" />
          <stop offset="100%" stopColor="#059669" />
        </linearGradient>
      </defs>
      {/* Background Rounded Tile */}
      <rect x="1" y="1" width="30" height="30" rx="7" fill="#090d16" stroke="#1e293b" strokeWidth="1" />
      {/* Subtle Ledger spine */}
      <line x1="16" y1="16" x2="16" y2="26" stroke="#334155" strokeWidth="1" strokeDasharray="1,1" opacity="0.6" />
      {/* Outer Lattice Edges */}
      <g stroke="url(#ll-grad)" strokeWidth="1.2" opacity="0.85">
        <line x1="16" y1="6" x2="8" y2="12" />
        <line x1="16" y1="6" x2="24" y2="12" />
        <line x1="8" y1="12" x2="8" y2="20" />
        <line x1="24" y1="12" x2="24" y2="20" />
        <line x1="8" y1="20" x2="16" y2="25" />
        <line x1="24" y1="20" x2="16" y2="25" />
        {/* Core Connections */}
        <line x1="16" y1="6" x2="16" y2="15" strokeWidth="1.4" />
        <line x1="8" y1="12" x2="16" y2="15" />
        <line x1="24" y1="12" x2="16" y2="15" />
        <line x1="8" y1="20" x2="16" y2="15" />
        <line x1="24" y1="20" x2="16" y2="15" />
      </g>
      {/* Nodes */}
      <circle cx="16" cy="6" r="1.5" fill="#38bdf8" />
      <circle cx="8" cy="12" r="1.3" fill="#0ea5e9" />
      <circle cx="24" cy="12" r="1.3" fill="#0ea5e9" />
      <circle cx="8" cy="20" r="1.3" fill="#10b981" />
      <circle cx="24" cy="20" r="1.3" fill="#10b981" />
      <circle cx="16" cy="25" r="1.4" fill="#059669" />
      {/* Central Radiant AI Core */}
      <circle cx="16" cy="15" r="2.2" fill="#10b981" stroke="#ffffff" strokeWidth="0.8" />
    </svg>
  );
};
