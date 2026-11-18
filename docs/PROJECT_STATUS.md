# Project status and reproducibility notes

## Completed workflow

### 1. Study grid and static factors

- Created a 30 m EPSG:32646 common grid.
- Collected DEM, terrain derivatives, MERIT-based TWI/SPI, river distance, drainage density, soil clay, and rock units.
- Kept curvature missing values as `NaN`; XGBoost handles missing values directly.
- Did not standardize numerical predictors because tree-based XGBoost does not require it.

### 2. Dynamic yearly factors

For 2016–2025, created yearly rainfall, relative-humidity, and Dynamic World LULC layers and built a Parquet feature table per year.

Common table columns:

```text
pixel_id, year, row, col, x, y,
DEM, Slope, Aspect_sin, Aspect_cos,
Profile_curvature, Plan_curvature, TWI, SPI,
River_distance, Drainage_density, Soil_clay, Rock_units,
Rainfall, Humidity, LULC
```

### 3. Seasonal Sentinel-1 proxy labels

Generated dry and wet Sentinel-1 composites for every year.

- 2016: descending relative orbit 106
- 2017–2025: ascending relative orbit 143

Proxy labels exclude permanent water and insufficient-observation pixels.

### 4. Model evaluation

V1, V2, and V3 were trained as progressive baselines. V4 is the main spatially blocked model.

V4 uses existing labelled sample files:

```text
E:\Ayeyarwady\Model_V3\samples_2016.parquet
...
E:\Ayeyarwady\Model_V3\samples_2025.parquet
```

Each file contains 100,000 labelled samples and the raw factor fields needed to regenerate the 28 model columns.

### 5. 2024 GFM event assessment

Downloaded and processed GFM layers for 30 July 2024:

- Observed Flood Extent
- Reference Water Mask
- Exclusion Mask
- Likelihood Values

Built a 30 m EPSG:32646 GFM reference layer:

```text
1 = GFM flood
0 = GFM did not map flood
255 = unknown, reference water, exclusion, or NoData
```

Visual checks used 24 June and 30 July 2024 Sentinel-1 scenes. Some code-3 areas, where GFM identified flood but seasonal labels did not, became darker on the event date. This is consistent with possible short-duration inundation that a seasonal median can miss.

## Files to preserve locally

```text
E:\Ayeyarwady\Cleaned_Data\features_2016.parquet ... features_2025.parquet
E:\Ayeyarwady\Model_V3\
E:\Ayeyarwady\Model_V4_Spatial10Year\
E:\Ayeyarwady\Validation_2024\
E:\Ayeyarwady\S1_2026_NovMay_reference_orbit143_30m.tif
E:\Ayeyarwady\S1_2026_JunOct_median_orbit143_30m.tif
```

## 2026 test checklist

Do not modify the V4 final model before the 2026 test.

When full 2026 data are available:

1. Download or export annual 2026 rainfall, humidity, and Dynamic World LULC using the same sources and processing logic.
2. Ensure the source data cover through 31 December 2026.
3. Build `features_2026.parquet` with the exact same columns and data types as the 2016–2025 tables.
4. Use `Model_V4_final_spatial_2016_2025.ubj` to predict 2026.
5. Export a score TIFF and class TIFF.
6. Compare valid prediction pixels against a 2026 GFM event reference and available optical or field evidence.
7. Add a new section to README with the 2026 result, reference dates, and limitations.

## GitHub update procedure

Do not upload raw raster layers, Parquet tables, large SAR images, or model outputs unless an external data archive is prepared.

For a later update:

1. Add scripts and small CSV/JSON reports.
2. Update the results table in `README.md`.
3. Update this status file with the 2026 feature source dates and test design.
4. Commit with a descriptive message, for example:

```text
Add 2026 external temporal test results
```

5. Push to the same GitHub repository.
