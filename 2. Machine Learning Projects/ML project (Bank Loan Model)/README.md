# LoanLift: personal loan campaign targeting application

An XGBoost model that ranks AllLife Bank's depositors by their chance of accepting a personal loan, so the next campaign contacts the few who will say yes. On 1,000 held-out customers it finds 97% of the buyers, 90% of the customers it targets take the loan (PR-AUC 0.991), and the top 10% of scores hold 97% of the buyers.

| | |
|---|---|
| **Live app** | [loanlift-campaign-application.streamlit.app](https://loanlift-campaign-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/loanlift-campaign-application](https://github.com/ahmadhassan-aiops/loanlift-campaign-application) |
| **Notebook** | [PG_AIML_ML_Project_full_code_notebook.ipynb](PG_AIML_ML_Project_full_code_notebook.ipynb) |
| **Saved model** | [model/](model) (scikit-learn pipeline + XGBoost, with threshold and test metrics in `metadata.json`) |

The notebook covers the EDA, decision trees with pre- and post-pruning, 18 candidate models, tuning, threshold choice, SHAP explanations and the target segments. It also corrects the first version: outlier removal had thrown out 151 of the 480 buyers, and the pruning was chosen on the test set.
