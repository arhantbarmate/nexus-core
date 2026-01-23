import asyncio
import httpx
import time
import random
import os
import sqlite3

# CONFIGURATION
TARGET_URL = "http://localhost:8000/api/execute_split"
TOTAL_REQUESTS = 1000000
BATCH_SIZE = 100  # Simultaneous requests per wave
REPORT_INTERVAL = 5000

# Absolute path anchoring to find the DB for the reset function
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.abspath(os.path.join(BASE_DIR, "..", "backend", "nexus_vault.db"))

def reset_vault():
    """
    Wipes the transaction history for a clean-slate test.
    Fixed to handle SQLite Transaction/VACUUM rules correctly.
    """
    if os.path.exists(DB_PATH):
        print(f"🧹 [CLEANUP] Resetting Vault at {DB_PATH}...")
        
        # Connect to the DB
        conn = sqlite3.connect(DB_PATH)
        
        try:
            # OPTIONAL: Micro-optimizations for the cleanup process
            conn.execute("PRAGMA journal_mode=WAL;")
            conn.execute("PRAGMA temp_store=MEMORY;")
            conn.execute("PRAGMA mmap_size=268435456;") # 256MB mmap

            # 1. Clear ledger (Explicit Transaction)
            conn.execute("DELETE FROM transactions;")
            conn.execute("DELETE FROM sqlite_sequence WHERE name='transactions';")
            
            # 🛑 CRITICAL FIX: Commit the deletion BEFORE Vacuuming
            # VACUUM cannot run inside an open transaction.
            conn.commit() 

            # 2. WAL Checkpoint (Flush WAL to main DB file)
            conn.execute("PRAGMA wal_checkpoint(FULL);")
            conn.commit()

            # 3. Optimize Storage (Must be isolated)
            print("   ↳ Vacuuming database (reclaiming space)...")
            conn.execute("VACUUM;") 
            
            print("✨ [OK] Vault Purged and Optimized.")
            
        except Exception as e:
            print(f"❌ [ERROR] Failed to reset vault: {e}")
        finally:
            conn.close()

async def execute_node_hit(client, user_id):
    """Simulates a single Sovereign Split transaction."""
    payload = {
        "amount": round(random.uniform(1.0, 1000.0), 2),
        "nonce": int(time.time() * 1000)
    }
    headers = {
        "X-Nexus-Backup-ID": str(user_id),
        "Content-Type": "application/json"
    }
    try:
        start = time.perf_counter()
        resp = await client.post(TARGET_URL, json=payload, headers=headers)
        latency = time.perf_counter() - start
        return resp.status_code == 200, latency
    except Exception:
        return False, 0

async def main():
    # 1. Start with a clean slate
    print(f"🎯 Target Database: {DB_PATH}")
    choice = input("⚠️  Reset database before starting? (y/n): ")
    if choice.lower() == 'y':
        reset_vault()

    print(f"\n🚀 IGNITING 1M STRESS TEST: {TOTAL_REQUESTS} Transactions")
    print(f"📡 TARGET: {TARGET_URL} | BATCH_SIZE: {BATCH_SIZE}")
    
    success_count = 0
    total_latency = 0
    start_time = time.perf_counter()

    # Limit connection pooling to prevent Windows socket exhaustion
    limits = httpx.Limits(max_keepalive_connections=BATCH_SIZE, max_connections=BATCH_SIZE)
    
    async with httpx.AsyncClient(timeout=15.0, limits=limits) as client:
        for i in range(0, TOTAL_REQUESTS, BATCH_SIZE):
            tasks = [execute_node_hit(client, random.randint(1000000, 9999999)) for _ in range(BATCH_SIZE)]
            results = await asyncio.gather(*tasks)
            
            for success, latency in results:
                if success:
                    success_count += 1
                    total_latency += latency

            if i % REPORT_INTERVAL == 0 and i > 0:
                elapsed = time.perf_counter() - start_time
                tps = i / elapsed
                avg_lat = total_latency / max(1, success_count)
                print(f"📊 [PROG] {i}/{TOTAL_REQUESTS} | TPS: {tps:.1f} | Latency: {avg_lat:.4f}s")

    end_time = time.perf_counter()
    duration = end_time - start_time
    print("\n" + "="*50)
    print(f"✅ STRESS TEST COMPLETE")
    print(f"⏱️ Total Time: {duration:.2f}s")
    print(f"📈 Final Throughput: {TOTAL_REQUESTS / duration:.2f} TPS")
    print(f"🛡️ Integrity: {success_count}/{TOTAL_REQUESTS} Success Rate")
    print("="*50)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n🛑 Test Aborted by Operator.")