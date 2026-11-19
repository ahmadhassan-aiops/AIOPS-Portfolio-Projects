# Beta Bank Retention Desk: customer attrition application

An XGBoost model that predicts which Beta Bank customers will leave. On 2,000 held-out customers it reaches **F1 0.631** (the project target was 0.59) and **AUC-ROC 0.864**, with calibrated probabilities; the 20% of customers it scores highest include 62% of those who left.

| | |
|---|---|
| **Live app** | [beta-retention-desk-application.streamlit.app](https://beta-retention-desk-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/beta-retention-desk-application](https://github.com/ahmadhassan-aiops/beta-retention-desk-application) |
| **Notebook** | [customer attrition at Beta Bank using ML.ipynb](customer%20attrition%20at%20Beta%20Bank%20using%20ML.ipynb) |
| **Saved model** | [model/](model) (scikit-learn pipeline + XGBoost, with threshold and test metrics in `metadata.json`) |

The notebook adds the exploratory analysis the first version lacked, compares SMOTE, undersampling, class weights and threshold moving inside cross-validation, tunes three models, picks the F1-optimal threshold out of fold and explains the model with SHAP. It also fixes the first version's leakage (tenure imputed before the split), unstratified split, an XGBoost search that tuned nothing, and a final model choice that contradicted its own comparison.
