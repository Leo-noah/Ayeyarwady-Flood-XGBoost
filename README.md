# Ayeyarwady Flood Mapping with XGBoost

This repository documents an XGBoost-based flood-mapping and flood-susceptibility workflow for the Ayeyarwady study area in Myanmar.

## Status

The completed work covers 2016–2025. The next planned independent temporal test is 2026, after complete 2026 rainfall, humidity, and Dynamic World land-cover data are available.

## Study area and grid

- Study area: Ayeyarwady, Myanmar
- Boundary: 94.8–95.8 E and 16.8–17.8 N
- Approximate area: 11,804.84 km²
- Common analysis grid: EPSG:32646, 30 m
- Raster dimensions: 3,733 rows × 3,590 columns

## Predictor factors

Fourteen predictor groups were prepared:

1. DEM
2. Slope
3. Aspect, represented as sine and cosine
4. Profile curvature
5. Plan curvature
6. Topographic Wetness Index (TWI)
7. Stream Power Index (SPI), transformed with `log1p`
8. Distance to river centreline
9. Drainage density
10. Soil clay content
11. Rainfall
12. Relative humidity
13. Dynamic World land-cover class
14. GLiM rock-unit class

Categorical predictors are one-hot encoded. The final XGBoost input has 28 columns.

## Data period

- Dynamic data: 2016–2025
- Static terrain, geology, soil, hydrology factors: reused across all years
- Yearly cleaned feature tables: 13,082,401 pixels per year
- Training sample: 100,000 labelled pixels per year, 1,000,000 samples total for V4

Large raster, Parquet, GeoTIFF, and model files are intentionally excluded from this repository. See `.gitignore` and `docs/PROJECT_STATUS.md`.

## Label construction

The training labels are experimental seasonal Sentinel-1 SAR proxy labels, not verified ground truth.

For each year:

- Dry reference: November of the previous year to May of the current year
- Wet season: June to October
- Positive proxy label: dry VV > -14 dB, wet VV < -17 dB, and dry-minus-wet change > 3 dB
- Negative proxy label: dry VV > -14 dB, wet VV > -14 dB, and absolute change < 1.5 dB
- Other pixels: unknown/excluded

SAR backscatter and SAR-derived change are used only to create labels. They are not used as XGBoost predictors.

## Model versions

| Model | Evaluation design | Held-out test data |
|---|---|---|
| V1 | 2016 geographic block split | 2016 unseen blocks |
| V2 | Train 2016–2018, validate 2019, test 2020 | Whole year 2020 |
| V3 | Train 2016–2023, validate 2024, test 2025 | Whole year 2025 |
| V4 | 5 km spatial blocks across 2016–2025 | Unseen blocks from every year |

V4 is the main spatial-generalization model. Its test blocks are not used for training in any year.

## Held-out evaluation results

| Model | Accuracy | Precision | Recall | F1 | ROC-AUC | Average precision |
|---|---:|---:|---:|---:|---:|---:|
| V1 | 0.9011 | 0.7621 | 0.6054 | 0.6748 | 0.9415 | 0.7761 |
| V2 | 0.8874 | 0.3750 | 0.6916 | 0.4863 | 0.9086 | 0.5101 |
| V3 | 0.9002 | 0.6103 | 0.5847 | 0.5973 | 0.9317 | 0.6744 |
| V4 | 0.9147 | 0.5994 | 0.5994 | 0.5994 | 0.9368 | 0.6642 |

These scores are not directly interchangeable because each model has a different split design. V4 is the most spatially strict evaluation because every test block is excluded from training for all years.

## V4 spatial evaluation

V4 uses 5 km × 5 km geographic blocks:

- Training: 70% of blocks
- Validation: 15% of blocks
- Test: 15% of geographically unseen blocks

The same block stays in only one split across every year. This prevents the same location from appearing in both training and test data in different years.

V4 held-out spatial-test results:

| Metric | Value |
|---|---:|
| Accuracy | 0.9147 |
| Precision | 0.5994 |
| Recall | 0.5994 |
| F1 | 0.5994 |
| ROC-AUC | 0.9368 |
| Average precision | 0.6642 |

These values measure agreement with experimental seasonal SAR proxy labels. They are not verified real-flood accuracy.

## GFM comparison

A Global Flood Monitoring (GFM) observed-flood product from 30 July 2024 was prepared as an external event-level comparison layer.

- GFM event: 2024-07-30T11:46:38 UTC
- Seasonal-proxy versus GFM agreement: 71.30% over comparable pixels
- V3 2024 model-class versus GFM agreement: 61.61% over comparable pixels

GFM and the project labels both use Sentinel-1-derived information and represent different time windows. These comparisons are corroborative label assessments, not independent ground-truth validation.

## Current limitations

- Labels are seasonal SAR proxy labels and may include crop, vegetation, or short-duration flood effects.
- Full-year rainfall, humidity, and LULC make the existing models retrospective classifications, not real-time forecasts.
- Dynamic World LULC has high feature importance and should be tested in a no-LULC sensitivity model.
- The final models are refit using all available data; reported test metrics belong to the separate evaluation models.

## Planned 2026 test

The final V4 model is frozen using 2016–2025 data. A proper 2026 future-year test requires complete calendar-year 2026 rainfall, humidity, and Dynamic World LULC data, calculated using the same method as earlier years.

Once data are complete:

1. Create `features_2026.parquet` with the same schema as 2016–2025.
2. Predict with the frozen V4 final model; do not retrain using 2026.
3. Compare with GFM and other available event evidence.
4. Describe the result as a 2026 external temporal test or event-level agreement, according to the reference used.

## Local data layout

The original project data are stored locally and are not uploaded to GitHub:

```text
E:\Ayeyarwady\
├── Cleaned_Data\features_2016.parquet ... features_2025.parquet
├── Model_V3\
├── Model_V4_Spatial10Year\
├── Validation_2024\
└── Sentinel-1, terrain, climate, soil, geology, and LULC rasters
```

See [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md) for detailed steps, file names, and update instructions.
