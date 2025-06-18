from fastapi import APIRouter, Query
from typing import List
from pydantic import BaseModel

router = APIRouter(prefix="/geolocation", tags=["geolocation"])

class PharmacyLocation(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float
    is_open: bool

# Dummy data for demonstration
pharmacies_locations = [
    {"id": 1, "name": "Pharmacy A", "latitude": 40.7128, "longitude": -74.0060, "is_open": True},
    {"id": 2, "name": "Pharmacy B", "latitude": 40.7138, "longitude": -74.0050, "is_open": False},
    {"id": 3, "name": "Pharmacy C", "latitude": 40.7148, "longitude": -74.0040, "is_open": True},
]

@router.get("/nearby", response_model=List[PharmacyLocation])
async def get_nearby_pharmacies(lat: float = Query(...), lon: float = Query(...), radius_km: float = Query(5.0)):
    # TODO: Implement geolocation logic to find pharmacies within radius_km of (lat, lon)
    # For now, return all open pharmacies
    return [p for p in pharmacies_locations if p["is_open"]]
