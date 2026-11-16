Add-Type -AssemblyName System.Drawing

function Draw-MaximizedIcon {
    param([int]$Size)

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $scale = $Size / 512.0
    $g.ScaleTransform($scale, $scale)

    # Brushes & Pens
    $whiteBrush = [System.Drawing.Brushes]::White
    $blackBrush = [System.Drawing.Brushes]::Black
    $whitePen20 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 20.0)
    $whitePen20.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $whitePen20.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen20.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    $whitePen18 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 18.0)
    $whitePen18.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen18.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    $darkShieldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 0, 0, 0), 28.0)
    $darkShieldPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $darkShieldPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $darkShieldPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Hexagon points
    [System.Drawing.PointF[]]$hexPoints = @(
        [System.Drawing.PointF]::new(256.0, 28.0),
        [System.Drawing.PointF]::new(454.0, 142.0),
        [System.Drawing.PointF]::new(454.0, 370.0),
        [System.Drawing.PointF]::new(256.0, 484.0),
        [System.Drawing.PointF]::new(58.0, 370.0),
        [System.Drawing.PointF]::new(58.0, 142.0)
    )

    # Dark shield under-stroke
    $g.DrawPolygon($darkShieldPen, $hexPoints)

    # Hexagon outer ring
    $g.DrawPolygon($whitePen20, $hexPoints)

    # 6 Vertex nodes (radius 24)
    $r = 24.0
    foreach ($pt in $hexPoints) {
        $g.FillEllipse($whiteBrush, [float]($pt.X - $r), [float]($pt.Y - $r), [float]($r * 2.0), [float]($r * 2.0))
    }

    # Pencils helper function
    function Draw-Pencil {
        param([float]$x, [float]$y, [float]$angle, [bool]$reverse)
        $state = $g.Save()
        $g.TranslateTransform($x, $y)
        $g.RotateTransform($angle)

        if (-not $reverse) {
            # Eraser Dome
            $g.FillPie($whiteBrush, -70.0, -14.0, 28.0, 28.0, 90.0, 180.0)
            $g.FillRectangle($whiteBrush, -56.0, -14.0, 12.0, 28.0)
            # Ferrule
            $g.FillRectangle($blackBrush, -54.0, -14.0, 8.0, 28.0)
            # Body
            $g.FillRectangle($whiteBrush, -44.0, -14.0, 70.0, 28.0)
            # Center Slit
            $g.FillRectangle($blackBrush, -40.0, -3.5, 62.0, 7.0)
            # Wood Cone Collar
            [System.Drawing.PointF[]]$conePts = @(
                [System.Drawing.PointF]::new(26.0, -14.0),
                [System.Drawing.PointF]::new(58.0, 0.0),
                [System.Drawing.PointF]::new(26.0, 14.0)
            )
            $g.FillPolygon($whiteBrush, $conePts)
            # Graphite Lead
            [System.Drawing.PointF[]]$leadPts = @(
                [System.Drawing.PointF]::new(42.0, -7.0),
                [System.Drawing.PointF]::new(58.0, 0.0),
                [System.Drawing.PointF]::new(42.0, 7.0)
            )
            $g.FillPolygon($blackBrush, $leadPts)
        } else {
            # Reversed Pencil (Bottom-Left)
            # Tip pointing left
            [System.Drawing.PointF[]]$conePts = @(
                [System.Drawing.PointF]::new(-60.0, 0.0),
                [System.Drawing.PointF]::new(-26.0, -14.0),
                [System.Drawing.PointF]::new(-26.0, 14.0)
            )
            $g.FillPolygon($whiteBrush, $conePts)
            [System.Drawing.PointF[]]$leadPts = @(
                [System.Drawing.PointF]::new(-60.0, 0.0),
                [System.Drawing.PointF]::new(-44.0, -7.0),
                [System.Drawing.PointF]::new(-44.0, 7.0)
            )
            $g.FillPolygon($blackBrush, $leadPts)
            # Body
            $g.FillRectangle($whiteBrush, -26.0, -14.0, 76.0, 28.0)
            $g.FillRectangle($blackBrush, -22.0, -3.5, 68.0, 7.0)
            # Ferrule
            $g.FillRectangle($blackBrush, 50.0, -14.0, 8.0, 28.0)
            # Eraser
            $g.FillPie($whiteBrush, 46.0, -14.0, 28.0, 28.0, 270.0, 180.0)
            $g.FillRectangle($whiteBrush, 44.0, -14.0, 14.0, 28.0)
        }

        $g.Restore($state)
    }

    # Draw 3 Pencils
    Draw-Pencil -x 182.0 -y 146.0 -angle -35.0 -reverse $false
    Draw-Pencil -x 362.0 -y 256.0 -angle 90.0 -reverse $false
    Draw-Pencil -x 182.0 -y 366.0 -angle 35.0 -reverse $true

    # Central L Monogram
    # Dark shield under L
    $g.DrawLine($darkShieldPen, 220.0, 180.0, 220.0, 332.0)
    $g.DrawLine($darkShieldPen, 220.0, 332.0, 296.0, 332.0)

    # Rigid L
    $g.DrawLine($whitePen20, 220.0, 180.0, 220.0, 332.0)
    $g.DrawLine($whitePen20, 220.0, 332.0, 296.0, 332.0)

    # Three L Nodes
    $nr = 18.0
    $g.FillEllipse($whiteBrush, [float](220.0 - $nr), [float](180.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))
    $g.FillEllipse($whiteBrush, [float](220.0 - $nr), [float](332.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))
    $g.FillEllipse($whiteBrush, [float](296.0 - $nr), [float](332.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))

    # Cursive Ledger L Loop
    $bezierPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(206.0, 278.0),
        [System.Drawing.PointF]::new(270.0, 278.0),
        [System.Drawing.PointF]::new(304.0, 240.0),
        [System.Drawing.PointF]::new(302.0, 198.0)
    )
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(302.0, 198.0),
        [System.Drawing.PointF]::new(300.0, 160.0),
        [System.Drawing.PointF]::new(265.0, 160.0),
        [System.Drawing.PointF]::new(252.0, 194.0)
    )
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(252.0, 194.0),
        [System.Drawing.PointF]::new(235.0, 226.0),
        [System.Drawing.PointF]::new(224.0, 280.0),
        [System.Drawing.PointF]::new(256.0, 332.0)
    )

    $g.DrawPath($darkShieldPen, $bezierPath)
    $g.DrawPath($whitePen18, $bezierPath)

    # Cleanup
    $bezierPath.Dispose()
    $whitePen20.Dispose()
    $whitePen18.Dispose()
    $darkShieldPen.Dispose()
    $g.Dispose()

    return $bmp
}

# 1. Generate Master build/icon.png (512x512)
Write-Output "Generating build/icon.png..."
$master512 = Draw-MaximizedIcon -Size 512
$master512.Save("build/icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$master512.Save("public/icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Generate public/icon-192.png
$icon192 = Draw-MaximizedIcon -Size 192
$icon192.Save("public/icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon192.Dispose()

# 3. Generate Android Mipmaps
$densities = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $densities.Keys) {
    $sz = $densities[$folder]
    $dir = "android/app/src/main/res/$folder"
    if (Test-Path $dir) {
        Write-Output "Generating Android icons for $folder (${sz}x${sz})..."
        $bmp = Draw-MaximizedIcon -Size $sz
        $bmp.Save("$dir/ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
}

# 4. Generate Multi-Resolution Windows build/icon.ico & public/favicon.ico
Write-Output "Building multi-resolution icon.ico..."
$icoSizes = @(256, 128, 64, 48, 32, 24, 16)
$icoEntries = @()

foreach ($sz in $icoSizes) {
    $bmp = Draw-MaximizedIcon -Size $sz
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $icoEntries += [PSCustomObject]@{
        Size = $sz
        Bytes = $ms.ToArray()
    }
    $ms.Dispose()
    $bmp.Dispose()
}

function Write-IcoFile {
    param([string]$FilePath, [array]$Entries)
    $fs = [System.IO.File]::Create($FilePath)
    $bw = New-Object System.IO.BinaryWriter($fs)

    # ICONDIR
    $bw.Write([uint16]0) # Reserved
    $bw.Write([uint16]1) # Type 1 = ICO
    $bw.Write([uint16]$Entries.Count) # Image count

    $offset = 6 + (16 * $Entries.Count)

    # ICONDIRENTRY list
    foreach ($entry in $Entries) {
        $w = if ($entry.Size -eq 256) { 0 } else { [byte]$entry.Size }
        $h = if ($entry.Size -eq 256) { 0 } else { [byte]$entry.Size }
        $bw.Write([byte]$w)
        $bw.Write([byte]$h)
        $bw.Write([byte]0) # Palette
        $bw.Write([byte]0) # Reserved
        $bw.Write([uint16]1) # Color planes
        $bw.Write([uint16]32) # Bit count
        $bw.Write([uint32]$entry.Bytes.Length) # Image bytes
        $bw.Write([uint32]$offset) # File offset
        $offset += $entry.Bytes.Length
    }

    # Image Data
    foreach ($entry in $Entries) {
        $bw.Write($entry.Bytes, 0, $entry.Bytes.Length)
    }

    $bw.Flush()
    $bw.Close()
    $fs.Close()
}

Write-IcoFile -FilePath "build/icon.ico" -Entries $icoEntries
Write-IcoFile -FilePath "public/favicon.ico" -Entries $icoEntries

$master512.Dispose()
Write-Output "All icons successfully generated with 0 errors!"
