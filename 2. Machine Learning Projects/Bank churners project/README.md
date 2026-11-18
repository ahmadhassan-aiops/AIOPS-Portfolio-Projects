# Credit card churn prediction

An XGBoost model that flags credit card customers likely to close their card: on 2,026 held-out customers it catches 94% of churners, and 84% of the customers it flags really churn (PR-AUC 0.968).

| | |
|---|---|
| **Live app** | [bank-churn-prediction.streamlit.app](https://bank-churn-prediction.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/bank-churn-prediction](https://github.com/ahmadhassan-aiops/bank-churn-prediction) |
| **Notebook** | [bank churners.ipynb](bank%20churners.ipynb) |
| **Saved model** | [model/](model) (scikit-learn pipeline + XGBoost, with threshold and test metrics in `metadata.json`) |

The notebook covers the EDA, 25 candidate models, tuning, threshold choice and SHAP explanations; the app scores single customers and customer lists with the saved model.
