from fastapi import APIRouter, HTTPException, Depends
from typing import List
from pydantic import BaseModel
from ..models import MedicineStock, Order  # Assuming models are defined in fast_api/models
from ..dependencies import get_db  # Assuming a dependency to get DB session
from sqlalchemy.orm import Session
import datetime

router = APIRouter(prefix="/stock_prediction", tags=["stock_prediction"])

class StockPredictionRequest(BaseModel):
    pharmacy_id: int
    medicine_id: int

class StockPredictionResponse(BaseModel):
    medicine_id: int
    predicted_stock: int
    prediction_date: datetime.date

@router.post("/", response_model=StockPredictionResponse)
async def predict_stock(data: StockPredictionRequest, db: Session = Depends(get_db)):
    # Simple example: Predict stock based on average daily sales in last 7 days
    try:
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)

        # Get total quantity sold for the medicine in the last 7 days
        total_sold = db.query(Order).join(Order.items).filter(
            Order.pharmacy_id == data.pharmacy_id,
            Order.items.any(medicine_id=data.medicine_id),
            Order.created_at >= week_ago
        ).with_entities(func.sum(Order.items.quantity)).scalar() or 0

        avg_daily_sold = total_sold / 7

        # Get current stock
        stock = db.query(MedicineStock).filter(
            MedicineStock.pharmacy_id == data.pharmacy_id,
            MedicineStock.medicine_id == data.medicine_id
        ).first()

        if not stock:
            raise HTTPException(status_code=404, detail="Stock not found")

        predicted_stock = max(0, stock.quantity - int(avg_daily_sold))

        return StockPredictionResponse(
            medicine_id=data.medicine_id,
            predicted_stock=predicted_stock,
            prediction_date=today + datetime.timedelta(days=1)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
