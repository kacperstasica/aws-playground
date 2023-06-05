from typing import Any

import joblib
from fastapi import FastAPI, Query

app = FastAPI()
model = joblib.load("app/models/sota_model.joblib")


@app.get("/")
def read_root() -> dict[str, str]:
    return {"API status": "Hello World!"}


@app.post("/predict/")
def predict_price(
    location: str = Query(..., description="Location", min_length=1),
    size: float = Query(..., description="Size in square meters", ge=10.0),
    bedrooms: int = Query(2, description="Number of bedrooms", ge=0, le=50),
) -> dict[str, Any]:
    try:
        return {"prediction": int(model.predict([[location, size, bedrooms]])[0])}
    except (ValueError, TypeError) as exc:
        return {"error": str(exc)}
