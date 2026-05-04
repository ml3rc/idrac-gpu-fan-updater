FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# base tools + dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    alien \
    libssl3 \
    libargtable2-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# download Dell iDRAC tools
RUN wget --header="User-Agent: Mozilla/5.0" \
         --header="Referer: https://www.dell.com/" \
         "https://dl.dell.com/FOLDER05920767M/1/DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz" \
    && tar xvf DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz \
    && cd iDRACTools/racadm/RHEL8/x86_64 \
    && alien srvadmin-*.rpm \
    && dpkg -i *.deb || apt-get -f install -y

# fix binary path
RUN ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/local/bin/racadm || true

# ensure loader finds Dell libs
ENV LD_LIBRARY_PATH=/opt/dell/srvadmin/lib64/openmanage/private

WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir requests pyyaml

CMD ["python", "app.py"]