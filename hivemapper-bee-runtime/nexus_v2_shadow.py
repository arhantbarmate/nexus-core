import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
import time
import random
import hashlib
import json
import sys
import statistics
from datetime import datetime, timezone

# --- CONFIGURATION (V2 REFINED) ---
VIBRATION_THRESHOLD_G = 0.12 
SPEED_THRESHOLD_KMH = 8.0     
WINDOW_SIZE = 10  # For entropy/jitter checks

class NexusGatekeeperV2:
    def __init__(self):
        self.device_id = "BEE-ARM-A53-X99-V2"
        self.session_key = hashlib.sha256(b"simulated-hardware-key").hexdigest()[:16]
        self.vib_buffer = [] # Rolling window for Cross-Modal Entropy

    def _generate_telemetry(self, scenario):
        timestamp = datetime.now(timezone.utc).isoformat()
        
        if scenario == "REAL_DRIVE":
            speed = random.uniform(15.0, 55.0) 
            # V2 Logic: Real vibration scales with speed + road noise
            vibration = (speed * 0.006) + random.uniform(0.1, 0.4)
            
        elif scenario == "SPOOF_ATTACK":
            # Simulator: Speed is constant, Vibration is synthetic/flat
            speed = random.uniform(29.5, 30.5) 
            vibration = random.uniform(0.13, 0.14) # Passes V1 threshold but fails V2 Entropy
            
        else: # IDLE
            speed = random.uniform(0.0, 3.5)
            vibration = random.uniform(0.01, 0.05)

        return {
            "ts": timestamp,
            "speed_kmh": round(speed, 2),
            "vib_g": round(vibration, 4)
        }

    def calculate_confidence(self, speed, vib):
        score = 100
        self.vib_buffer.append(vib)
        if len(self.vib_buffer) > WINDOW_SIZE: self.vib_buffer.pop(0)

        # 1. Physics Correlation: Is it too smooth for this speed?
        expected_min_vib = (speed * 0.004) + 0.07
        if speed > SPEED_THRESHOLD_KMH and vib < expected_min_vib:
            score -= 35 

        # 2. Entropy Check: Is the vibration "too perfect"? (Jitter Detection)
        if len(self.vib_buffer) == WINDOW_SIZE:
            jitter = statistics.stdev(self.vib_buffer)
            if jitter < 0.005: # Threshold for "Synthetic" noise
                score -= 45

        return max(0, score)

    def run_cycle(self):
        print(f"🚀 NEXUS RUNTIME v2.0-SHADOW | Device: {self.device_id}")
        print("Mode: Consistency Validation (Cross-Modal Entropy)\n")

        cycle_state = "REAL_DRIVE"
        cycle_timer = 0
        
        try:
            while True:
                if cycle_timer <= 0:
                    cycle_timer = random.randint(5, 10)
                    cycle_state = random.choice(["REAL_DRIVE", "SPOOF_ATTACK", "IDLE"])
                
                cycle_timer -= 1
                data = self._generate_telemetry(cycle_state)
                
                # --- V2 SHADOW LOGIC ---
                confidence = self.calculate_confidence(data['speed_kmh'], data['vib_g'])
                
                # --- OUTPUT MAPPING ---
                sys.stdout.write(f"[{data['ts']}] SPD: {data['speed_kmh']:05.2f} | VIB: {data['vib_g']:0.4f} | ")

                if confidence >= 75:
                    sys.stdout.write(f"\033[92m✅ SIGNED ({confidence}%)\033[0m\n")
                elif confidence >= 40:
                    sys.stdout.write(f"\033[93m⚠️  SOFT-FAIL ({confidence}%)\033[0m\n")
                else:
                    sys.stdout.write(f"\033[91m⛔ BLOCK ({confidence}%)\033[0m\n")

                time.sleep(1.0) 

        except KeyboardInterrupt:
            print("\n🛑 Nexus V2 Stopped.")

if __name__ == "__main__":
    daemon = NexusGatekeeperV2()
    daemon.run_cycle()