from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import auth

app = FastAPI(title="PharmaLocator API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)

from .routes import auth, medicines, geolocation, orders

app.include_router(auth.router)
app.include_router(medicines.router)
app.include_router(geolocation.router)
app.include_router(orders.router)

@app.get("/")
async def root():
    return {"message": "Welcome to PharmaLocator FastAPI backend"}
