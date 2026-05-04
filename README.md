# idrac-gpu-fan-updater
A docker compose stack that will get the GPU Temperature from the `/gpu-temp` endpoint provided by [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader) and set an offset to the Dell iDRAC.

## Requirements

- python
- docker
- racadm

### Racadm

```bash
apt update
apt install -y alien wget
wget --header="User-Agent: Mozilla/5.0" \
     --header="Referer: https://www.dell.com/" \
     "https://dl.dell.com/FOLDER05920767M/1/DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz"
tar xvf DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz
cd iDRACTools
cd racadm
cd RHEL8
cd x86_64
alien srvadmin-*.rpm
sudo dpkg -i *.deb
sudo ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/bin/racadm
```



## Running

To start the stack, run:

```bash
docker-compose up --build
```

Make sure the GPU temperature API is running and accessible at the URL specified in `GPU_API_URL` (default: `http://gpu-temp:5000/gpu-temp`).

For the GPU temperature API, see [amd-gpu-temp-reader](https://github.com/ml3rc/amd-gpu-temp-reader).
