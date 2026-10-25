# Online Shopper Behaviour Analysis and Purchase Prediction Using R

## Project overview
This case study analyses online shopping session behaviour and builds a Logistic Regression model to predict whether a session results in a purchase (`Revenue`).

## Dataset
- File: `online_shoppers_intention.csv`
- Observations: 12,330 sessions
- Variables: 18
- Target variable: `Revenue`
- The dataset is from the Online Shoppers Purchasing Intention dataset hosted by the UCI Machine Learning Repository.

Keep the dataset in the project folder so the analysis can access it.

## Main project files
- `OnlineShopper_Final.R` — original R analysis script. Preserve this file.
- `OnlineShopper_Final.Rmd` — R Markdown source used to combine explanation, code, results, and visualisations.
- `OnlineShopper_Final.html` — knitted report generated from the R Markdown source.
- `online_shoppers_intention.csv` — source dataset.
- `model_evaluation_results.csv` — model evaluation output, if present.

File extensions may be hidden in Windows File Explorer. Confirm the full extension before renaming files.

## How to reproduce the report
1. Open `OnlineShopperCaseStudy` as the working project folder in RStudio.
2. Confirm that `online_shoppers_intention.csv` is available in the folder.
3. Open `OnlineShopper_Final.Rmd`.
4. Use **Knit** in RStudio to regenerate `OnlineShopper_Final.html`.
5. Check the rendered report for the analysis, plots, model metrics, conclusion, and session information.

The separate `.R` script uses `choose.files()` to let the user select the dataset. Do not remove or overwrite that original script when working on the R Markdown report.

## Main reported results
The current knitted report records a dataset of 12,330 sessions and 18 variables. Its final Logistic Regression evaluation reports 87.75% accuracy, 60.39% precision, 57.18% recall, and 58.74% F1-score at a probability threshold of 0.25. These values describe the current report and should be regenerated if the analysis changes.

## Reproducibility and version documentation
See `VERSION_LOG.md` for the documented stages of the project. Keep earlier versions or backups rather than overwriting them when making substantial changes.
