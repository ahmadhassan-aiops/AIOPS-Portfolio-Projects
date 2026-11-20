# FairTag: used-car valuation application

A LightGBM model that tells a seller what their used car is worth, built for Rusty Bargain's app. On 61,861 held-out ads it has a typical error (RMSE) of **€1,502**, explains **89%** of price variation (R² 0.891), and gives each price an 80% range that holds **80.3%** of real asking prices. It trains in about 16 seconds and prices a car in a few milliseconds.

| | |
|---|---|
| **Live app** | [fairtag-car-valuation-application.streamlit.app](https://fairtag-car-valuation-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/fairtag-car-valuation-application](https://github.com/ahmadhassan-aiops/fairtag-car-valuation-application) (the deployed model, `train.py` that rebuilds it, tests) |
| **Notebook** | [Rusty Bargain Company ML Model To Attract New Buyers For The Used Cars.ipynb](Rusty%20Bargain%20Company%20ML%20Model%20To%20Attract%20New%20Buyers%20For%20The%20Used%20Cars.ipynb) |
| **Data** | `car_data.csv` (354,369 ads from a German classifieds site, 2014 to 2016) |

The notebook was audited and rebuilt. The first version reported CatBoost with an RMSE of 984, which came from target leakage: a `PriceGroup` column made by binning the target price was given to the model as a feature, and zero power values were filled from the same price groups. It also kept reposted ads (so copies of training ads sat in the test set), deleted real prices above €14,425 as outliers, kept registration years from 1000 to 9999, left diesel cars labelled "gasoline", dropped `Model` and `Brand` for most models, and chose between models on the test set.

The rebuilt notebook cleans the data step by step with counts, keeps the exploratory analysis, compares six models with 5-fold cross-validation on quality, prediction speed and training time (LightGBM €1,518, XGBoost €1,540, CatBoost €1,548 at 21 times LightGBM's training time, linear regression €2,631), tunes LightGBM over 24 settings (all within €1,512 to €1,525), builds the price range from cross-validated errors and tests once on held-out ads. The app ships a lighter setting from the same search (11 MB instead of 48 MB, €2 higher held-out RMSE). Running the notebook writes the best setting's model to `model/`.
