# StrokeScope: stroke risk screening application

A logistic regression that flags patients with a stroke-like risk profile for a check. On 1,022 held-out patients, its screening line **finds 42 of the 50 stroke patients (recall 84%)**, against 9 of 50 for the first version of the model on the same patients, with AUC-ROC 0.839 and calibrated risks. The price is false alarms: about 1 flagged patient in 8 had a stroke (precision 12%, 2.5 times the base rate), which this data cannot improve much.

| | |
|---|---|
| **Live app** | [strokescope-screening-application.streamlit.app](https://strokescope-screening-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/strokescope-screening-application](https://github.com/ahmadhassan-aiops/strokescope-screening-application) |
| **Notebook** | [Stroke data Analysis + Stroke Prediction model (Complete code with loops based graph).ipynb](Stroke%20data%20Analysis%20%2B%20Stroke%20Prediction%20model%20%28Complete%20code%20with%20loops%20based%20graph%29.ipynb) |
| **Saved model** | [model/](model) (scikit-learn pipeline + logistic regression, with both thresholds and test metrics in `metadata.json`) |

The notebook keeps the original exploratory analysis and corrects the modelling. The first version reported 93% accuracy but found only 4 of 63 stroke patients: it dropped the patients without a BMI (16% of all stroke cases), applied SMOTE before cross-validation (so its 95% scores were measured on synthetic copies), label-encoded categories before SMOTE, compared models on accuracy, did not use its tuned parameters and kept a 0.5 threshold. The rebuilt notebook confirms that all stroke patients are the first 249 rows of the file (every split is shuffled and stratified), compares six models and four ways of handling the imbalance inside cross-validation, sets the screening line out of fold to find 85% of stroke patients, and shows who the model still misses.
