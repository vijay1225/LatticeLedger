Add-Type -AssemblyName System.Drawing

function Draw-ThickMaxIcon {
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

    # Thicker Hexagon Pen (26px)
    $whitePen26 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 26.0)
    $whitePen26.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $whitePen26.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen26.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Thicker L Stem Pen (24px)
    $whitePen24 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 24.0)
    $whitePen24.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen24.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Thicker Cursive Loop Pen (22px)
    $whitePen22 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 22.0)
    $whitePen22.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $whitePen22.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Dark shield pen for contrast (36px)
    $darkShieldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 0, 0, 0), 36.0)
    $darkShieldPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $darkShieldPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $darkShieldPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    # Hexagon points (fills full 512x512 edge to edge)
    [System.Drawing.PointF[]]$hexPoints = @(
        [System.Drawing.PointF]::new(256.0, 20.0),
        [System.Drawing.PointF]::new(460.0, 138.0),
        [System.Drawing.PointF]::new(460.0, 374.0),
        [System.Drawing.PointF]::new(256.0, 492.0),
        [System.Drawing.PointF]::new(52.0, 374.0),
        [System.Drawing.PointF]::new(52.0, 138.0)
    )

    # Dark shield under-stroke
    $g.DrawPolygon($darkShieldPen, $hexPoints)

    # Thick Hexagon outer ring (26px)
    $g.DrawPolygon($whitePen26, $hexPoints)

    # 6 Vertex nodes (radius 28)
    $r = 28.0
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
            $g.FillPie($whiteBrush, -72.0, -15.0, 30.0, 30.0, 90.0, 180.0)
            $g.FillRectangle($whiteBrush, -57.0, -15.0, 14.0, 30.0)
            # Ferrule Gap
            $g.FillRectangle($blackBrush, -54.0, -15.0, 9.0, 30.0)
            # Body
            $g.FillRectangle($whiteBrush, -43.0, -15.0, 72.0, 30.0)
            # Center Slit
            $g.FillRectangle($blackBrush, -39.0, -4.0, 64.0, 8.0)
            # Wood Cone Collar
            [System.Drawing.PointF[]]$conePts = @(
                [System.Drawing.PointF]::new(29.0, -15.0),
                [System.Drawing.PointF]::new(62.0, 0.0),
                [System.Drawing.PointF]::new(29.0, 15.0)
            )
            $g.FillPolygon($whiteBrush, $conePts)
            # Graphite Lead
            [System.Drawing.PointF[]]$leadPts = @(
                [System.Drawing.PointF]::new(46.0, -7.5),
                [System.Drawing.PointF]::new(62.0, 0.0),
                [System.Drawing.PointF]::new(46.0, 7.5)
            )
            $g.FillPolygon($blackBrush, $leadPts)
        } else {
            # Reversed Pencil (Bottom-Left)
            # Tip pointing left
            [System.Drawing.PointF[]]$conePts = @(
                [System.Drawing.PointF]::new(-62.0, 0.0),
                [System.Drawing.PointF]::new(-27.0, -15.0),
                [System.Drawing.PointF]::new(-27.0, 15.0)
            )
            $g.FillPolygon($whiteBrush, $conePts)
            [System.Drawing.PointF[]]$leadPts = @(
                [System.Drawing.PointF]::new(-62.0, 0.0),
                [System.Drawing.PointF]::new(-46.0, -7.5),
                [System.Drawing.PointF]::new(-46.0, 7.5)
            )
            $g.FillPolygon($blackBrush, $leadPts)
            # Body
            $g.FillRectangle($whiteBrush, -27.0, -15.0, 78.0, 30.0)
            $g.FillRectangle($blackBrush, -23.0, -4.0, 70.0, 8.0)
            # Ferrule
            $g.FillRectangle($blackBrush, 53.0, -15.0, 9.0, 30.0)
            # Eraser
            $g.FillPie($whiteBrush, 50.0, -15.0, 30.0, 30.0, 270.0, 180.0)
            $g.FillRectangle($whiteBrush, 48.0, -15.0, 16.0, 30.0)
        }

        $g.Restore($state)
    }

    # Draw 3 Pencils
    Draw-Pencil -x 180.0 -y 142.0 -angle -35.0 -reverse $false
    Draw-Pencil -x 366.0 -y 256.0 -angle 90.0 -reverse $false
    Draw-Pencil -x 180.0 -y 370.0 -angle 35.0 -reverse $true

    # Central L Monogram (Thicker & Prominent)
    # Dark shield under L
    $g.DrawLine($darkShieldPen, 216.0, 175.0, 216.0, 338.0)
    $g.DrawLine($darkShieldPen, 216.0, 338.0, 300.0, 338.0)

    # Rigid L (24px)
    $g.DrawLine($whitePen24, 216.0, 175.0, 216.0, 338.0)
    $g.DrawLine($whitePen24, 216.0, 338.0, 300.0, 338.0)

    # Three L Nodes (r=20)
    $nr = 20.0
    $g.FillEllipse($whiteBrush, [float](216.0 - $nr), [float](175.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))
    $g.FillEllipse($whiteBrush, [float](216.0 - $nr), [float](338.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))
    $g.FillEllipse($whiteBrush, [float](300.0 - $nr), [float](338.0 - $nr), [float]($nr * 2.0), [float]($nr * 2.0))

    # Cursive Ledger L Loop (22px)
    $bezierPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(200.0, 275.0),
        [System.Drawing.PointF]::new(260.0, 275.0),
        [System.Drawing.PointF]::new(306.0, 240.0),
        [System.Drawing.PointF]::new(308.0, 190.0)
    )
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(308.0, 190.0),
        [System.Drawing.PointF]::new(310.0, 152.0),
        [System.Drawing.PointF]::new(276.0, 152.0),
        [System.Drawing.PointF]::new(252.0, 188.0)
    )
    $bezierPath.AddBezier(
        [System.Drawing.PointF]::new(252.0, 188.0),
        [System.Drawing.PointF]::new(226.0, 226.0),
        [System.Drawing.PointF]::new(220.0, 282.0),
        [System.Drawing.PointF]::new(254.0, 338.0)
    )

    $g.DrawPath($darkShieldPen, $bezierPath)
    $g.DrawPath($whitePen22, $bezierPath)

    # Cleanup
    $bezierPath.Dispose()
    $whitePen26.Dispose()
    $whitePen24.Dispose()
    $whitePen22.Dispose()
    $darkShieldPen.Dispose()
    $g.Dispose()

    return $bmp
}

# 1. Generate Master build/icon.png (512x512)
Write-Output "Generating build/icon.png and public/icon-512.png..."
$master512 = Draw-ThickMaxIcon -Size 512
$master512.Save("build/icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$master512.Save("public/icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Generate public/icon-192.png
$icon192 = Draw-ThickMaxIcon -Size 192
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
        $bmp = Draw-ThickMaxIcon -Size $sz
        $bmp.Save("$dir/ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Save("$dir/ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
    }
}

# 4. Generate Multi-Resolution Windows build/icon.ico & public/favicon.ico
Write-Output "Building multi-resolution icon.ico..."
$icoSizes = @(256, 128, 64, 48, 32, 24, 20, 16)
$icoEntries = @()

foreach ($sz in $icoSizes) {
    $bmp = Draw-ThickMaxIcon -Size $sz
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

    $bw.Write([uint16]0) # Reserved
    $bw.Write([uint16]1) # Type 1 = ICO
    $bw.Write([uint16]$Entries.Count) # Image count

    $offset = 6 + (16 * $Entries.Count)

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
Write-Output "All thicker icons successfully generated!"
