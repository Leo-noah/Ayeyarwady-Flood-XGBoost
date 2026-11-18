# Data Processing and Model Training Stages

## 1. Study grid and common alignment

- Study area: Ayeyarwady, Myanmar.
- Coordinate reference system: **EPSG:32646** (UTM Zone 46N).
- Analysis resolution: **30 m**.
- All raster predictors and labels were aligned to the same grid before sampling or modelling.

## 2. Input data preparation

### Static factors

These factors are spatially static, so the same values are used for every year:

1. DEM
2. Slope
3. Aspect (sine and cosine transformation)
4. Profile curvature
5. Plan curvature
6. Topographic Wetness Index (TWI)
7. Stream Power Index (SPI; `log1p` transformation used for modelling)
8. Distance to river/stream
9. Drainage density
10. Soil clay content
11. Rock/geological unit

### Year-specific factors

These vary for each year from 2016 to 2025:

1. Rainfall
2. Relative humidity
3. Dynamic World land-cover class (LULC)
4. Sentinel-1 dry/reference composite (November–May)
5. Sentinel-1 wet-season composite (June–October)

## 3. Sentinel-1 proxy-label creation

Sentinel-1 was used to construct an **experimental seasonal SAR proxy label**, not an independently verified flood label.

- Dry/reference period: November to May.
- Wet period: June to October.
- A pixel is proxy-positive where backscatter is sufficiently low in the wet composite and decreases sufficiently relative to the dry composite.
- Stable dry pixels are proxy-negative.
- Pixels without reliable observations or with uncertain water conditions are assigned `255` (unknown) and are excluded from model samples.

The Sentinel-1 dry/wet backscatter and change values are used only to make the proxy label. They are **not** used as XGBoost predictors, which avoids directly learning the same rule used to create the label.

## 4. Cleaning and feature tables

- Invalid raster values and nodata values were converted to missing values.
- Curvature missing values were retained as `NaN`; XGBoost handles missing values during tree learning.
- No standardisation was applied because tree-based XGBoost does not require it.
- One aligned feature table was saved for each year:

```text
Cleaned_Data/
  features_2016.parquet
  ...
  features_2025.parquet
```

Each Parquet table has approximately 13.08 million grid cells and contains coordinates, static factors, annual factors, and LULC. Large raw rasters, Parquet files, and model binaries are intentionally not stored in this GitHub repository.

## 5. Predictor encoding

The model uses 28 encoded predictor columns:

- Numeric terrain/hydrology/climate factors.
- One-hot encoded Dynamic World LULC classes plus an unknown category.
- One-hot encoded rock-unit classes plus an unknown category.

## 6. Model-training stages

### V1 — 2016 baseline

- One-year experiment using 2016 data.
- Random train/validation/test sample split.
- Used to confirm that the complete data pipeline and modelling workflow run correctly.

### V2 — five-year temporal experiment

- Training years: 2016–2018.
- Validation year: 2019.
- Held-out test year: 2020.
- Tested whether the earlier model transferred to a future year.

### V3 — ten-year temporal experiment

- Training years: 2016–2023.
- Validation year: 2024.
- Held-out test year: 2025.
- Tested temporal generalisation to an unseen future year.

### V4 — ten-year spatial experiment

- Data: samples from all 10 years (2016–2025).
- The study area was divided into approximately 5 km spatial blocks.
- Entire blocks, across all years, were allocated to train (70%), validation (15%), and test (15%).
- This avoids putting nearby pixels in both training and test sets, producing a more conservative spatial generalisation test.
- Final V4 was fitted using all ten years only after evaluation was complete.

## 7. Evaluation

Reported metrics:

- Accuracy
- Precision
- Recall
- F1 score
- ROC-AUC
- Average precision (PR-AUC)
- Confusion matrix (TN, FP, FN, TP)

The classification threshold was selected using validation data, not the test data.

## 8. Independent event comparison

A 30 July 2024 Global Flood Monitoring (GFM) observed flood extent was aligned to the project grid and compared with:

1. The seasonal Sentinel-1 proxy label; and
2. A V3 model map.

This is an event/date comparison, not a replacement for field-verified ground truth. Seasonal labels cover June–October, while GFM represents a single event date; disagreement can therefore arise from real temporal differences as well as classification error.

## 9. Current limitation and next stage

All V1–V4 metrics evaluate agreement with the experimental SAR proxy label, not verified flood occurrence. Future work should add event-specific flood maps, field records, optical-image checks, or other independent labels.

The 2026 test dataset must wait until full-year rainfall, humidity, and LULC data are available through 31 December 2026. Then it can be processed on the same 30 m grid and evaluated using the final V4 model without retraining.
