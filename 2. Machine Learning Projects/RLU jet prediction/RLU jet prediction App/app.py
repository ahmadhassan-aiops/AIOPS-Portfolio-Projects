from flask import Flask, render_template, request
import joblib
import pandas as pd
import numpy as np
import json

app = Flask(__name__)

# -----------------------------
# Load trained model
# -----------------------------
model = joblib.load("rul_rf_model.pkl")

# -----------------------------
# Feature order (MUST match training)
# -----------------------------
FEATURE_COLUMNS = [
    'op_setting1','op_setting2','op_setting3','sensor2','sensor3','sensor4',
    'sensor6','sensor7','sensor8','sensor9','sensor11','sensor12','sensor13',
    'sensor14','sensor15','sensor17','sensor20','sensor21','sensor2_mean5',
    'sensor2_std5','sensor2_diff','sensor3_mean5','sensor3_std5','sensor3_diff',
    'sensor4_mean5','sensor4_std5','sensor4_diff','sensor7_mean5','sensor7_std5',
    'sensor7_diff','sensor8_mean5','sensor8_std5','sensor8_diff','sensor9_mean5',
    'sensor9_std5','sensor9_diff','sensor11_mean5','sensor11_std5','sensor11_diff',
    'sensor12_mean5','sensor12_std5','sensor12_diff','sensor13_mean5','sensor13_std5',
    'sensor13_diff','sensor14_mean5','sensor14_std5','sensor14_diff','sensor15_mean5',
    'sensor15_std5','sensor15_diff','sensor17_mean5','sensor17_std5','sensor17_diff',
    'sensor20_mean5','sensor20_std5','sensor20_diff','sensor21_mean5','sensor21_std5',
    'sensor21_diff'
]

# -----------------------------
# Maintenance Recommendation Engine
# -----------------------------
def maintenance_advice(rul):
    if rul < 10:
        return "🚨 STOP engine. Immediate maintenance required."
    elif rul < 30:
        return "⚠️ Schedule urgent inspection & parts replacement."
    elif rul < 60:
        return "🛠 Plan maintenance during next service window."
    else:
        return "✅ Engine operating normally."

# -----------------------------
# Realistic Simulated Data Generator
# -----------------------------
def generate_simulated_data(num_records=1):
    """
    Simulate engine sensor data with realistic degradation states.
    Produces healthy, degrading, and critical engines.
    """

    data = []

    for _ in range(num_records):

        # Assign engine health state
        health_state = np.random.choice(
            ["Healthy", "Degrading", "Critical"],
            p=[0.6, 0.3, 0.1]
        )

        # degradation intensity
        if health_state == "Healthy":
            drift = np.random.uniform(0, 1)
        elif health_state == "Degrading":
            drift = np.random.uniform(5, 15)
        else:
            drift = np.random.uniform(20, 35)

        record = {
            "op_setting1": np.random.normal(0, 0.002),
            "op_setting2": np.random.normal(0, 0.002),
            "op_setting3": 100.0,

            "sensor2": np.random.uniform(640, 645) + drift,
            "sensor3": np.random.uniform(1580, 1605) + drift * 2,
            "sensor4": np.random.uniform(1390, 1430) + drift * 2,
            "sensor6": np.random.uniform(20, 22) + drift * 0.02,
            "sensor7": np.random.uniform(550, 555) + drift,
            "sensor8": np.random.uniform(2385, 2390) + drift * 2,
            "sensor9": np.random.uniform(9040, 9160) + drift * 5,
            "sensor11": np.random.uniform(45, 50) + drift * 0.2,
            "sensor12": np.random.uniform(515, 525) + drift,
            "sensor13": np.random.uniform(2385, 2390) + drift * 2,
            "sensor14": np.random.uniform(8100, 8200) + drift * 5,
            "sensor15": np.random.uniform(8, 9) + drift * 0.05,
            "sensor17": np.random.uniform(390, 400) + drift,
            "sensor20": np.random.uniform(38, 39) + drift * 0.05,
            "sensor21": np.random.uniform(22, 24) + drift * 0.05,
        }

        # create rolling statistics
        for s in [2,3,4,7,8,9,11,12,13,14,15,17,20,21]:
            record[f"sensor{s}_mean5"] = record[f"sensor{s}"] + np.random.uniform(-1,1)
            record[f"sensor{s}_std5"] = abs(np.random.normal(0.5, 0.3))
            record[f"sensor{s}_diff"] = np.random.uniform(-2,2) + drift * 0.05

        # helpful demo label (not used by model)
        record["Simulated Health"] = health_state

        data.append(record)

    return data

# -----------------------------
# Routes
# -----------------------------
@app.route("/")
def home():
    return render_template("index.html")

@app.route("/predict", methods=["GET","POST"])
def predict():
    if request.method == "POST":

        num_records = int(request.form.get("num_records", 5))

        input_data = generate_simulated_data(num_records)

        df = pd.DataFrame(input_data)

        # Preserve health label for display
        health_labels = df["Simulated Health"]

        # Ensure correct feature order
        df = df[FEATURE_COLUMNS]

        # Predict RUL
        rul_preds = model.predict(df)
        df["Predicted RUL"] = rul_preds.astype(int)

        # -----------------------------
        # Fleet Health Summary Counts
        # -----------------------------
        critical_count = (df["Predicted RUL"] < 30).sum()
        warning_count = ((df["Predicted RUL"] >= 30) & (df["Predicted RUL"] < 60)).sum()
        healthy_count = (df["Predicted RUL"] >= 60).sum()


        # Status classification
        df["Status"] = df["Predicted RUL"].apply(
            lambda x: "🔴 Critical" if x < 10
            else ("🟠 Warning" if x < 50 else "🟢 Healthy")
        )

        # Maintenance recommendations
        df["Recommendation"] = df["Predicted RUL"].apply(maintenance_advice)

        # Add simulated health for interpretation
        df["Simulated Health"] = health_labels

        # -------- Gauge value (latest engine) --------
        latest_rul = int(df["Predicted RUL"].iloc[-1])

        # -------- Trend Data --------
        trend_data = df["Predicted RUL"].tolist()

        # -------- Summary Insights --------
        avg_rul = int(df["Predicted RUL"].mean())
        critical_count = int((df["Predicted RUL"] < 30).sum())

        return render_template(
            "predict.html",
            tables=[df.to_html(classes="data", index=False, escape=False)],
            titles=df.columns.values,
            gauge_value=latest_rul,
            trend_data=json.dumps(trend_data),
            critical_count=critical_count,
            warning_count=warning_count,
            healthy_count=healthy_count
        )


    return render_template("predict.html", tables=None)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=7860, debug=True)