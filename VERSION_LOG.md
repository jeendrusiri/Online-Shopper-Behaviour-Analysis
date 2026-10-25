# Version Log — Online Shopper Case Study

This log documents the development stages of the case study. It is a manually maintained version history, not a Git commit history.

## V1 — Initial analysis
- Loaded the Online Shoppers Purchasing Intention dataset in R.
- Inspected dataset dimensions, variable types, missing values, duplicate rows, and the target variable.
- Recorded initial data-quality observations.

## V2 — Data preparation
- Prepared the variables for analysis, including categorical/factor variables where appropriate.
- Checked missing values and duplicate records.
- Documented the handling of duplicate rows in the report.

## V3 — Exploratory data analysis and model development
- Created visualisations to examine shopping-session behaviour and purchase patterns.
- Developed a Logistic Regression model to predict `Revenue`.
- Split the data into training and testing sets and evaluated predictions using classification metrics.

## V4 — Final report and evaluation
- Organised explanations, R code, outputs, visualisations, model evaluation, limitations, conclusion, references, and session information in R Markdown.
- Knitted `OnlineShopper_Final.Rmd` to `OnlineShopper_Final.html`.
- The current report records a final threshold of 0.25 and test-set results of 87.75% accuracy, 60.39% precision, 57.18% recall, and 58.74% F1-score.
- Added this README and version log to document the project and its stages.

## Future changes
For each substantial change, add a new dated entry with:
- version number and date;
- files changed;
- reason for the change;
- analysis or result affected;
- whether the R Markdown document was knitted successfully.


