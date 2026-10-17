# idrac-gpu-fan-updater - Development Context

## What This Project Does

This is a Docker-based GPU fan controller for Dell servers. It reads GPU temperatures from an AMD temperature API and uses a hysteresis controller to set fan speed offsets via Dell iDRAC.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────────────────────────┐
│  AMD GPU Temp API    │────▶│  Fan Controller (this app)              │
│  http://gpu-temp:5000│     │  - Reads temp from API                  │
│  /gpu-temp           │     │  - Applies hysteresis logic             │
└─────────────────────┘     │  - Writes offset to iDRAC                │
                            │  - Persists state to disk                │
                            └─────────────────────────────────────────┘
                                       │
                                       ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        Dell iDRAC                                       │
│  - set system.thermalsettings.FanSpeedOffset                           │
└────────────────────────────────────────────────────────────────────────┘
```

## Key Files

| File | Purpose |
|------|---------|
| `app.py` | Main loop: polls GPU temp → applies hysteresis → sets iDRAC offset |
| `docker-compose.yaml` | Defines the `fan-controller` service with volumes |
| `config.yaml` | Hysteresis rules mapping last offset → temp thresholds → new offset |
| `Dockerfile` | Ubuntu 22.04 base, installs racadm, copies app |
| `.env` | Credentials: `IDRAC_HOST`, `IDRAC_USER`, `IDRAC_PASS`, `GPU_API_URL` |

## How Hysteresis Works

The controller uses an offset-based fan speed system (0 = slowest, 255 = fastest, 3 = fail-safe max).

Each "level" is a target offset. When GPU temp rises above a threshold for that level, it transitions to a lower (slower) level. When temp falls below the threshold, it transitions back.

Example from `config.yaml`:
- If currently at offset 3 (hot), and temp ≥ 90°C → stay at 3
- If currently at offset 3, and temp ≥ 85°C but < 90°C → transition to offset 1
- This prevents constant thrashing between states

## Environment Variables

| Var | Default | Description |
|-----|---------|-------------|
| `IDRAC_HOST` | — | iDRAC IP address |
| `IDRAC_USER` | — | iDRAC username |
| `IDRAC_PASS` | — | iDRAC password |
| `GPU_API_URL` | `http://gpu-temp:5000/gpu-temp` | GPU temperature API endpoint |
| `STATE_FILE` | `/data/fan_state.txt` | Path to persistent state file |
| `CONFIG_FILE` | `/config/config.yaml` | Path to config file (volumed) |

## Common Tasks

### Rebuild container
```bash
docker-compose up --build
```

### Check current offset
```bash
docker exec fan-controller cat /data/fan_state.txt
```

### View recent logs
```bash
docker logs --tail 50 fan-controller
```

## Security Considerations

- `IDRAC_USER`/`IDRAC_PASS` are in `.env` (gitignored)
- `.env` should not be committed
- Consider using a secrets manager in production

## External Dependencies

- [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader) - GPU temp API
- Dell iDRAC with RACLI support
