# RankCast: airport taxi demand forecast application

One ridge regression per horizon forecasts Sweet Lift's airport taxi orders 1 to 24 hours ahead. On the 442 held-out hours (13 to 31 August 2018, the busiest weeks in the data), the next-hour forecast has an **RMSE of 34.8 orders** against the brief's limit of 48, 12% better than repeating the same hour last week (39.5), and its 80% range holds **81.7%** of actual counts. The 24-hours-ahead forecast is almost as good (RMSE 35.5).

| | |
|---|---|
| **Live app** | [rankcast-demand-forecast-application.streamlit.app](https://rankcast-demand-forecast-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/rankcast-demand-forecast-application](https://github.com/ahmadhassan-aiops/rankcast-demand-forecast-application) |
| **Notebook** | [Forecasting Orders of Sweet Lift Taxi Company Using ML.ipynb](Forecasting%20Orders%20of%20Sweet%20Lift%20Taxi%20Company%20Using%20ML.ipynb) |
| **Saved model** | [model/](model) (24 scikit-learn pipelines, one per horizon, with the forecast ranges and all scores in `metadata.json`) |

The notebook was rebuilt. The first version chose LightGBM (test RMSE 42) without a baseline, and the simple rule "same hour last week" scores 39.5 on the same hours. It also compared 18-day-ahead ARIMA and Prophet forecasts with one-hour-ahead regressions, never used the settings its searches found, picked the final model by its test score, relied on calendar features (`month`, `day`, `year`) that cannot generalise from six months of data, and read a KPSS rejection as proof of stationarity. The rebuilt notebook scores every model one hour ahead with time-ordered cross-validation, adds same-hour-yesterday and last-week features, tunes on the folds only, trains one model per horizon for a 24-hour plan, sets an 80% range from cross-validated errors, and tests once.
