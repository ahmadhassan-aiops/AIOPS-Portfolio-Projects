# WellScout: oil region selection application

OilyGiant will develop 200 wells in one of three regions, choosing the model's best 200 of 500 surveyed points, with a $100 million budget and a risk of loss under 2.5%. A bootstrap of 10,000 simulated surveys shows that the answer depends on the model. With the brief's **linear regression**, only **region 1** passes the risk limit (mean profit $4.8 million, risk 0.9%). Region 2's reserves grow with the square of two features, so **linear regression with squared terms** (still a linear regression) picks **region 2** ($5.3 million, risk 2.3%), and **LightGBM** makes region 2 clearly best ($6.6 million, risk 0.8%).

| | |
|---|---|
| **Live app** | [wellscout-region-selection-application.streamlit.app](https://wellscout-region-selection-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/wellscout-region-selection-application](https://github.com/ahmadhassan-aiops/wellscout-region-selection-application) |
| **Notebook** | [optimal oil well location selection using ML.ipynb](optimal%20oil%20well%20location%20selection%20using%20ML.ipynb) |
| **Saved models** | [model/](model) (three models for each of the three regions, with all risk and profit figures in `metadata.json`) |

The notebook was rebuilt. The first version's conclusion mislabelled the regions and suggested "region 2" for profit, while the brief's rule selected region 1; its bootstrap was unseeded (risks changed on every run) with only 1,000 draws, and its duplicate check missed 18 point ids measured twice with different values. The rebuilt notebook removes those points, uses 10,000 seeded draws, explains why region 1's model is nearly exact (its reserves take 12 values and follow `f2`), finds the curved pattern in region 2, and compares the decision under three models.
