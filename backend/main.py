from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home():
    return {"message": "Nexus Core Online"}

@app.get("/split/{revenue}")
def split_revenue(revenue: float):
    # The Nexus Constitution: 60-30-10 Split
    return {
        "User_Pool_60": revenue * 0.60,
        "Platform_Ops_30": revenue * 0.30,
        "Community_10": revenue * 0.10
    }