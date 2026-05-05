import os
import time
import requests
import subprocess
import yaml
import logging

# ===== LOGGING CONFIG =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ===== CONFIG FROM ENV =====
IDRAC = os.getenv("IDRAC_HOST")
USER = os.getenv("IDRAC_USER")
PASS = os.getenv("IDRAC_PASS")
GPU_API = os.getenv("GPU_API_URL", "http://gpu-temp:5000/gpu-temp")
STATE_FILE = os.getenv("STATE_FILE", "/data/fan_state.txt")
CONFIG_PATH = os.getenv("CONFIG_FILE", "/config/config.yaml")


# ===== HYSTERESIS CONFIG =====


with open(CONFIG_PATH, "r") as f:
    CONFIG = yaml.safe_load(f)

# ===== INIT STATE =====
try:
    with open(STATE_FILE, "r") as f:
        last = int(f.read().strip())
except:
    last = 0

fails = 0

# ===== RACADM =====
def set_offset(val):
    try:
        result = subprocess.run(
            [
                "racadm",
                "-r", IDRAC,
                "-u", USER,
                "-p", PASS,
                "set",
                "system.thermalsettings.FanSpeedOffset",
                str(val),
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0 and "Object value modified successfully" in result.stdout:
            logger.info(f"OK offset={val}")
        else:
            logger.error(f"ERROR offset={val} result={result.stdout} {result.stderr}")

    except Exception as e:
        logger.error(f"ERROR calling racadm: {e}")


# ===== MAIN LOOP =====
while True:
    try:
        r = requests.get(GPU_API, timeout=3)
        data = r.json()

        # take first GPU value
        temp = list(data.values())[0]
        temp = round(float(temp))

        logger.info(f"GPU temp = {temp}")
        fails = 0

    except Exception as e:
        fails += 1
        logger.warning(f"FAIL SAFE ({fails}) → MAX FAN ({e})")

        if fails >= 2:
            set_offset(3)
            last = 3

        time.sleep(5)
        continue

    # ===== HYSTERESIS =====
    target = last
    rules = CONFIG["levels"].get(str(last), {})

    # check upward transition
    if "up" in rules and temp >= rules["up"]["temp"]:
        target = rules["up"]["target"]

    # check downward transition
    elif "down" in rules and temp <= rules["down"]["temp"]:
        target = rules["down"]["target"]

    # ===== APPLY =====
    if target != last:
        logger.info(f"CHANGE {last} → {target} (temp={temp})")

        set_offset(target)

        last = target
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        with open(STATE_FILE, "w") as f:
            f.write(str(target))

    time.sleep(5)