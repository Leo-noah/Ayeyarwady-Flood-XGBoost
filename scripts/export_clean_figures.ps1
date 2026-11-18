Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$source = 'E:\ayeyarwady image'
$output = Join-Path $root 'figures'
New-Item -ItemType Directory -Force -Path $output | Out-Null

# These rectangles contain only the map canvas in the original QGIS screenshots.
# Cropping is pixel-preserving: it does not resample or alter the scientific map.
$figures = @(
    @{ Input = 'Screenshot 2026-11-12 215847.png'; Output = 'figure_01_gfm_reference_overlay_20240730.png'; X = 603; Y = 158; Width = 812; Height = 842 },
    @{ Input = 'Screenshot 2026-11-13 213621.png'; Output = 'figure_02_seasonal_vs_gfm_overview_20240730.png'; X = 344; Y = 242; Width = 616; Height = 649 },
    @{ Input = 'Screenshot 2026-11-13 213800.png'; Output = 'figure_03_seasonal_vs_gfm_zoom_20240730.png'; X = 300; Y = 134; Width = 700; Height = 861 }
)

# The two additional images came from the current chat attachments.  Their map
# canvases are cropped below and saved alongside the other GitHub figures.
$chatFigures = @(
    @{ Input = 'C:\Users\ASUSVI~1\AppData\Local\Temp\codex-clipboard-d35da95c-72c1-437d-a36a-f74a9e6c999a.png'; Output = 'figure_04_gfm_overlay_sentinel1_reference_20240624.png'; X = 612; Y = 166; Width = 803; Height = 824 },
    @{ Input = 'C:\Users\ASUSVI~1\AppData\Local\Temp\codex-clipboard-c540bd95-86e5-4f4c-9e08-6e7c60b9f078.png'; Output = 'figure_05_gfm_overlay_sentinel1_event_20240730.png'; X = 612; Y = 166; Width = 803; Height = 824 }
)

foreach ($figure in $figures) {
    $inputPath = Join-Path $source $figure.Input
    $outputPath = Join-Path $output $figure.Output
    $image = [System.Drawing.Bitmap]::FromFile($inputPath)
    $rect = [System.Drawing.Rectangle]::new($figure.X, $figure.Y, $figure.Width, $figure.Height)
    $crop = $image.Clone($rect, $image.PixelFormat)
    $crop.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $crop.Dispose()
    $image.Dispose()
    Write-Host "Created: $outputPath"
}

foreach ($figure in $chatFigures) {
    $outputPath = Join-Path $output $figure.Output
    $image = [System.Drawing.Bitmap]::FromFile($figure.Input)
    $rect = [System.Drawing.Rectangle]::new($figure.X, $figure.Y, $figure.Width, $figure.Height)
    $crop = $image.Clone($rect, $image.PixelFormat)
    $crop.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $crop.Dispose()
    $image.Dispose()
    Write-Host "Created: $outputPath"
}
