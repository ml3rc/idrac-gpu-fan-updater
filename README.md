# idrac-gpu-fan-updater
A docker compose stack that will get the GPU Temperature from the `/gpu-temp` endpoint provided by [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader) and set an offset to the Dell iDRAC.

## Running

To start the stack, run:

```bash
docker-compose up --build
```

Make sure the GPU temperature API is running and accessible at the URL specified in `GPU_API_URL` (default: `http://gpu-temp:5000/gpu-temp`).

For the GPU temperature API, see [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader).
