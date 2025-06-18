from fastapi import APIRouter, HTTPException, Query
from typing import List
from pydantic import BaseModel

router = APIRouter(prefix="/medicines", tags=["medicines"])

class Medicine(BaseModel):
    id: int
    name: str
    description: str = None
    price: float
    available_quantity: int

# Dummy data for demonstration
medicines_db = [
    {"id": 1, "name": "Paracetamol", "description": "Pain reliever", "price": 2.5, "available_quantity": 100},
    {"id": 2, "name": "Ibuprofen", "description": "Anti-inflammatory", "price": 3.0, "available_quantity": 50},
    {"id": 3, "name": "Amoxicillin", "description": "Antibiotic", "price": 5.0, "available_quantity": 30},
]

@router.get("/", response_model=List[Medicine])
async def search_medicines(query: str = Query(None, min_length=1)):
    if query:
        results = [m for m in medicines_db if query.lower() in m["name"].lower()]
        return results
    return medicines_db
