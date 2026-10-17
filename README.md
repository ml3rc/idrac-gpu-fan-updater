# idrac-gpu-fan-updater

A Docker-based GPU fan controller for Dell servers. It reads GPU temperatures from an AMD temperature API and uses a hysteresis controller to set fan speed offsets via Dell iDRAC.

## What It Does

- Reads GPU temperature from an external API
- Applies hysteresis logic to prevent fan speed thrashing
- Sets iDRAC fan speed offsets (0 = slowest, 255 = fastest, 3 = fail-safe)
- Persists state to disk between restarts

## Hysteresis Controller

The controller uses an offset-based fan speed system with configurable thresholds. When GPU temperature rises above a threshold, it transitions to a slower fan level. When temperature falls below a threshold, it transitions back up.

Example from `config.yaml`:
- At offset 3 (hot), temp ≥ 90°C → stay at 3
- At offset 3, temp ≥ 85°C but < 90°C → transition to offset 1

## Requirements

- Docker & Docker Compose
- Dell iDRAC with RACLI support
- External GPU temperature API (default: `http://gpu-temp:5000/gpu-temp`)

## Quick Start

```bash
# Create .env from the template and fill in your iDRAC credentials
cp .env.tmpl .env

# Pull and start
docker-compose up --build

# View current fan offset
docker exec fan-controller cat /data/fan_state.txt

# View recent logs
docker logs --tail 50 fan-controller
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|------|---------|-------------|
| `IDRAC_HOST` | — | iDRAC IP address |
| `IDRAC_USER` | — | iDRAC username |
| `IDRAC_PASS` | — | iDRAC password |
| `GPU_API_URL` | `http://gpu-temp:5000/gpu-temp` | GPU temperature API endpoint |
| `STATE_FILE` | `/data/fan_state.txt` | Path to persistent state file |
| `CONFIG_FILE` | `/config/config.yaml` | Path to configuration file |

### Hysteresis Config

Edit `config.yaml` to adjust thresholds:

```yaml
offsets:
  - current: 3
    threshold_low: 85
    threshold_high: 90
    new_offset: 1
  - current: 1
    threshold_low: 70
    threshold_high: 80
    new_offset: 2
```

## External Dependencies

- [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader) - GPU temperature API

## Security

- `.env` should never be committed (contains credentials)
- Consider using a secrets manager in production
