# Figures

These are pixel-preserving crops of QGIS map canvases. QGIS menus, panels, and status bars were removed; the map pixels themselves were not resampled or changed.

| File | Use | Notes |
|---|---|---|
| `figure_01_gfm_reference_overlay_20240730.png` | Visual evidence of the GFM 30 July 2024 reference flood layer over Sentinel-1 imagery | Display figure; not ground truth by itself. |
| `figure_02_seasonal_vs_gfm_overview_20240730.png` | Whole-area comparison of the seasonal SAR proxy and GFM | Codes: 0 both non-flood, 1 both flood, 2 seasonal proxy only, 3 GFM only. |
| `figure_03_seasonal_vs_gfm_zoom_20240730.png` | Zoomed comparison detail | Use with the code legend above; this is an illustrative area, not a random validation sample. |
| `figure_04_gfm_overlay_sentinel1_reference_20240624.png` | GFM flood reference over the Sentinel-1 pre-event/reference scene (24 June 2024) | Before-event visual context. |
| `figure_05_gfm_overlay_sentinel1_event_20240730.png` | GFM flood reference over the Sentinel-1 event scene (30 July 2024) | Event-date visual context. |

The full quantitative comparison is documented in the project README: the seasonal SAR proxy and the 30 July 2024 GFM reference agree on 71.30% of comparable pixels. This comparison is not model accuracy and is not independent ground-truth validation.
