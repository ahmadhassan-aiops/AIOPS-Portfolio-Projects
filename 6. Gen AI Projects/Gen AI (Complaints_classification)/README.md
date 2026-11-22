# CaseRoute: routing financial complaints with open models

Each consumer complaint goes to the team that handles the product (credit reporting, debt collection, mortgages and
loans, credit cards, retail banking) with a confidence and a short brief: summary, issue, company and what the customer
asks for. Open-weight models served by Groq answer in a strict JSON schema. On the 235 unique complaints,
`openai/gpt-oss-120b` (zero-shot) routes **84.7% to the right team** with a **macro F1 of 0.805**, against 0.776 for a
TF-IDF + logistic regression classifier trained on the same labels and 0.14 for always answering credit reporting.
High-confidence routes are right 87% of the time, Medium 59%; 65% of the summaries checked by a second model contain
nothing outside the complaint.

| | |
|---|---|
| **Live app** | [caseroute-complaint-routing-application.streamlit.app](https://caseroute-complaint-routing-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/caseroute-complaint-routing-application](https://github.com/ahmadhassan-aiops/caseroute-complaint-routing-application) |
| **Notebook** | [Complaint_Routing.ipynb](Complaint_Routing.ipynb) |
| **Data** | `Complains_classification.csv` (500 complaints, 240 unique), `test_complaints.csv` (10 written for the evaluation) |
| **Model calls** | `llm_cache/`: every call, so the notebook re-runs without a key or cost |

The first version (Mistral 7B on a Colab GPU) scored samples full of duplicates (13 of its 30 zero-shot rows were the
same legal passage), its few-shot run never sent its examples, its labels were parsed so that `credit\_reporting`
counted as wrong, and its conclusion contradicted its own outputs. Its answers are rebuilt and re-scored in
`first_version_outputs.csv` and the notebook.
