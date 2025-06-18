from fastapi import APIRouter, HTTPException, Depends
from typing import List
from pydantic import BaseModel
from ..models import Order, OrderItem  # Assuming models are defined in fast_api/models
from ..dependencies import get_db  # Assuming a dependency to get DB session

router = APIRouter(prefix="/orders", tags=["orders"])

class OrderItemSchema(BaseModel):
    medicine_name: str
    quantity: int
    price: float

class OrderSchema(BaseModel):
    id: int
    client_id: int
    pharmacy_id: int
    status: str
    total_price: float
    items: List[OrderItemSchema] = []

    class Config:
        orm_mode = True

@router.get("/", response_model=List[OrderSchema])
async def list_orders(db=Depends(get_db)):
    orders = db.query(Order).all()
    return orders

@router.get("/{order_id}", response_model=OrderSchema)
async def get_order(order_id: int, db=Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order
