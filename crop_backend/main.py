from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
import json
import io
import requests

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("Loading AI Model...")
model = tf.keras.models.load_model('crop_disease_model.keras')

with open('labels.json', 'r') as f:
    labels = json.load(f)
print("Model and labels loaded successfully!")

@app.post("/predict")
async def predict_disease(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    
    image = image.resize((224, 224))
    image_array = np.array(image) / 255.0
    image_array = np.expand_dims(image_array, axis=0)
    
    predictions = model.predict(image_array)
    predicted_class_index = np.argmax(predictions[0])
    confidence = round(float(np.max(predictions[0])) * 100, 2)
    predicted_disease = labels[str(predicted_class_index)]
    
    # Calculate a mock severity score based on confidence (for yield calculation)
    severity_score = confidence / 100.0
    
    return {
        "disease": predicted_disease,
        "confidence": confidence,
        "severity": severity_score
    }

@app.post("/predict-yield")
async def predict_yield(disease: str = Form(...), severity: float = Form(...), city: str = Form(...)):
    # 1. Fetch live weather data (Using a free mock API here)
    # In a real FYP, you can use OpenWeather API. For now, we simulate it.
    # Let's assume base yield for a healthy crop is 1000 kg per hectare.
    base_yield = 1000.0 
    
    # 2. If the leaf is healthy, no yield loss
    if "healthy" in disease.lower():
        estimated_yield = base_yield
        status = "Healthy Crop"
    else:
        # 3. If diseased, reduce yield based on severity (confidence of AI)
        # E.g., if severity is 98%, we lose about 40% of the yield
        yield_loss_percentage = (severity * 0.4) 
        estimated_yield = base_yield * (1 - yield_loss_percentage)
        status = f"Diseased Crop ({disease})"
    
    # 4. Return the estimation
    return {
        "city": city,
        "status": status,
        "estimated_yield_kg_per_hectare": round(estimated_yield, 2),
        "yield_loss_percentage": round((1 - (estimated_yield / base_yield)) * 100, 2)
    }