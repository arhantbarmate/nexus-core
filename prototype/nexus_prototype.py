import time
import random
import hashlib
import json
import sys
from datetime import datetime

# --- CONFIGURATION (TUNED FOR REALITY) ---
# Lowered to 0.12G to account for EVs on smooth roads.
# Anything below this is physically impossible for a 2-ton object moving > 10km/h.
VIBRATION_THRESHOLD_G = 0.12 

# Raised to 8.0 km/h to ignore GPS "Drift" when parked.
SPEED_THRESHOLD_KMH = 8.0     

class NexusGatekeeper:
    def __init__(self):
        self.device_id = "BEE-ARM-A53-X99"
        # In Prod: This comes from the ATECC608 secure element, never hardcoded.
        self.session_key = hashlib.sha256(b"simulated-hardware-key").hexdigest()[:16]

    def _generate_telemetry(self, scenario):
        timestamp = datetime.utcnow().isoformat() + "Z"
        
        if scenario == "REAL_DRIVE":
            # Added "noise" to speed to simulate real throttle fluctuation
            speed = random.uniform(15.0, 55.0) 
            # Vibration scales slightly with speed in real physics
            vibration = random.uniform(0.15, 1.8) + (speed * 0.005)
            
        elif scenario == "SPOOF_ATTACK":
            # Simulator: Perfectly constant speed is a dead giveaway
            speed = random.uniform(29.5, 30.5) 
            vibration = random.uniform(0.00, 0.02) # Dead silent
            
        else:
            # IDLE / GPS DRIFT (The Parking Lot Test)
            speed = random.uniform(0.0, 3.5) # Drifting slightly
            vibration = random.uniform(0.01, 0.05) # Engine idling

        return {
            "ts": timestamp,
            "speed_kmh": round(speed, 2),
            "vib_g": round(vibration, 4),
            "lat": 37.7749,
            "lon": -122.4194
        }

    def sign_packet(self, data):
        payload = json.dumps(data, sort_keys=True).encode()
        signature = hashlib.sha256(payload + self.session_key.encode()).hexdigest()
        return signature

    def run_cycle(self):
        print(f"\n🚀 NEXUS RUNTIME v1.4.1 (PATCHED) | Device: {self.device_id}")
        print("Listening for sensor streams... (Press Ctrl+C to stop)\n")

        # Randomized State Machine for Simulation
        cycle_state = "REAL_DRIVE"
        cycle_timer = 0
        
        try:
            while True:
                # Logic to randomly switch scenarios every 5-10 seconds
                if cycle_timer <= 0:
                    cycle_timer = random.randint(5, 10)
                    # Randomly pick a scenario for this batch
                    cycle_state = random.choice(["REAL_DRIVE", "SPOOF_ATTACK", "IDLE"])
                
                cycle_timer -= 1
                
                # 1. READ SENSORS
                data = self._generate_telemetry(cycle_state)
                
                # 2. EXECUTE LOGIC (The Gatekeeper)
                is_moving = data['speed_kmh'] > SPEED_THRESHOLD_KMH
                feels_road = data['vib_g'] > VIBRATION_THRESHOLD_G
                
                sys.stdout.write(f"[{data['ts']}] SPD: {data['speed_kmh']:05.2f} km/h | VIB: {data['vib_g']:0.4f} G | ")

                # LOGIC MATRIX
                if is_moving and not feels_road:
                    # Case: Fast + Smooth = SPOOF
                    sys.stdout.write("\033[91m⛔ BLOCKED (SPOOF)\033[0m\n")
                
                elif is_moving and feels_road:
                    # Case: Fast + Bumpy = VALID
                    sig = self.sign_packet(data)
                    sys.stdout.write(f"\033[92m✅ SIGNED: {sig[:8]}...\033[0m\n")
                
                elif not is_moving:
                    # Case: Slow/Stopped = IGNORE (Do not sign, Do not block)
                    sys.stdout.write("\033[90m💤 IDLE / DRIFT\033[0m\n")
                
                else:
                    # Case: Stopped but High Vibration (e.g., Construction Zone)
                    sys.stdout.write("\033[93m⚠️  NOISE (DISCARD)\033[0m\n")

                time.sleep(1.0) 

        except KeyboardInterrupt:
            print("\n\n🛑 Nexus Runtime Stopped.")

if __name__ == "__main__":
    daemon = NexusGatekeeper()
    daemon.run_cycle()