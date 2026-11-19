"""Create pixel-preserving, map-only crops from the QGIS screenshots.

Requirements:
    pip install Pillow

The script crops the QGIS map canvas only. It does not resample or alter
scientific map pixels.
"""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path(r"E:\ayeyarwady image")
OUTPUT = ROOT / "figures"

# (input filename, output filename, x, y, width, height)
FIGURES = [
    (
        "Screenshot 2026-11-12 215847.png",
        "figure_01_gfm_reference_overlay_20240730.png",
        603, 158, 812, 842,
    ),
    (
        "Screenshot 2026-11-13 213621.png",
        "figure_02_seasonal_vs_gfm_overview_20240730.png",
        344, 242, 616, 649,
    ),
    (
        "Screenshot 2026-11-13 213800.png",
        "figure_03_seasonal_vs_gfm_zoom_20240730.png",
        300, 134, 700, 861,
    ),
]

# Current-chat screenshots. Change these paths if the files were moved.
CHAT_FIGURES = [
    (
        Path(r"C:\Users\ASUSVI~1\AppData\Local\Temp\codex-clipboard-d35da95c-72c1-437d-a36a-f74a9e6c999a.png"),
        "figure_04_gfm_overlay_sentinel1_reference_20240624.png",
        612, 166, 803, 824,
    ),
    (
        Path(r"C:\Users\ASUSVI~1\AppData\Local\Temp\codex-clipboard-c540bd95-86e5-4f4c-9e08-6e7c60b9f078.png"),
        "figure_05_gfm_overlay_sentinel1_event_20240730.png",
        612, 166, 803, 824,
    ),
]


def crop_image(input_path: Path, output_name: str, x: int, y: int, width: int, height: int) -> None:
    """Save an exact rectangular crop without resampling."""
    if not input_path.exists():
        print(f"Skipped (source not found): {input_path}")
        return

    with Image.open(input_path) as image:
        cropped = image.crop((x, y, x + width, y + height))
        output_path = OUTPUT / output_name
        cropped.save(output_path)
        print(f"Created: {output_path}")


def main() -> None:
    OUTPUT.mkdir(exist_ok=True)
    for filename, output_name, x, y, width, height in FIGURES:
        crop_image(SOURCE / filename, output_name, x, y, width, height)
    for input_path, output_name, x, y, width, height in CHAT_FIGURES:
        crop_image(input_path, output_name, x, y, width, height)


if __name__ == "__main__":
    main()
