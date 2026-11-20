# TurboLife: turbofan engine remaining useful life

How many flight cycles does a turbofan engine have left before it fails? Using NASA's C-MAPSS FD001 data (100 engines run to failure, 100 test engines stopped before failure), a **LightGBM** model reads each engine's sensor log so far and predicts its remaining useful life, capped at 125 cycles. Features come from each engine's own history (readings, 10- and 30-cycle means, 20-cycle slopes of 14 sensors) and models are compared with cross-validation grouped by engine. On the test engines it scores an **RMSE of 13.8 cycles** (MAE 9.8, NASA score 338), against 41.9 for an average-life baseline. An 80% range from out-of-fold errors gives each engine a safe life that sorts it into ground, plan or fly; none of the 16 test engines within 20 cycles of failure is cleared to fly.

| | |
|---|---|
| **Live app** | [turbolife-engine-health-application.streamlit.app](https://turbolife-engine-health-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/turbolife-engine-health-application](https://github.com/ahmadhassan-aiops/turbolife-engine-health-application) |
| **Notebook** | [RUL_Safety_Application.ipynb](RUL_Safety_Application.ipynb) |
| **Saved model** | [model/](model) (LightGBM, the range bands and all scores in `metadata.json`) |

The notebook was rebuilt. The first version clipped every column at 125 instead of only the target, which turned ten of the fourteen sensors into constants; grouped the test set's rolling features by the training engines' ids, so windows ran across engines; cross-validated on shuffled rows, which reports about half the real error; and had no baseline or view of late predictions. Its test RMSE was 22.7. The earlier Flask app on Hugging Face fed the model randomly generated sensor values and has been replaced by TurboLife, which replays the real test engines.
