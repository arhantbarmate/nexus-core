from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

# 1. DATABASE CONFIGURATION
DATABASE_URL = "sqlite:///./nexus_vault.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 2. DATA MODELS (Persistence Schema)
class Creator(Base):
    __tablename__ = "creators"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True)
    balance = Column(Float, default=0.0)

class GlobalLedger(Base):
    __tablename__ = "global_ledger"
    id = Column(Integer, primary_key=True)
    user_pool = Column(Float, default=0.0)
    network_fee = Column(Float, default=0.0)

class Transaction(Base):
    __tablename__ = "transactions"
    id = Column(Integer, primary_key=True)
    amount = Column(Float)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

# 3. INITIALIZE DATABASE
Base.metadata.create_all(bind=engine)

app = FastAPI()

# 4. SECURITY (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 5. THE CORE LOGIC (60-30-10)
@app.post("/execute_split/{amount}")
def execute_split(amount: float):
    # FIX 1: Prevent invalid or negative amounts
    if amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")

    # FIX 2: Use context-managed DB session for safety
    with SessionLocal() as db:
        try:
            # NOTE: Float used for feasibility testing only.
            # Future versions will migrate to fixed-point integers.
            creator_cut = amount * 0.60
            user_pool_cut = amount * 0.30
            network_cut = amount * 0.10

            # Phase 1: Single hardcoded creator for feasibility testing
            creator = db.query(Creator).filter(Creator.name == "arhan").first()
            if not creator:
                creator = Creator(name="arhan", balance=0.0)
                db.add(creator)
            
            creator.balance += creator_cut

            # FIX 3: Singleton-safe ledger query using a constant ID
            ledger = db.query(GlobalLedger).filter(GlobalLedger.id == 1).first()
            if not ledger:
                ledger = GlobalLedger(id=1, user_pool=0.0, network_fee=0.0)
                db.add(ledger)
            
            ledger.user_pool += user_pool_cut
            ledger.network_fee += network_cut

            db.add(Transaction(amount=amount))
            db.commit()
            
            return {"status": "success", "creator_balance": creator.balance}
        except Exception as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/ledger")
def get_ledger():
    with SessionLocal() as db:
        creator = db.query(Creator).filter(Creator.name == "arhan").first()
        ledger = db.query(GlobalLedger).filter(GlobalLedger.id == 1).first()
        return {
            "user_profile": "arhan",
            "total_earned": creator.balance if creator else 0,
            "global_user_pool": ledger.user_pool if ledger else 0,
            "protocol_fees": ledger.network_fee if ledger else 0
        }

@app.get("/transactions")
def get_transactions():
    with SessionLocal() as db:
        # Fetch the last 10 transactions, newest first
        txs = db.query(Transaction).order_by(Transaction.timestamp.desc()).limit(10).all()
        
        # ISO 8601 format is standard for economic audits
        return [
            {
                "id": t.id, 
                "amount": t.amount, 
                "timestamp": t.timestamp.isoformat()
            } 
            for t in txs
        ]