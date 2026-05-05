FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# base tools + dependencies
RUN apt-get update && apt-get install -y \
    wget \
    python3 \
    python3-pip \
    tar \
    alien \
    libssl3 \
    libargtable2-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# download Dell iDRAC tools and install racadm
RUN wget --header="User-Agent: Mozilla/5.0" \
         --header="Referer: https://www.dell.com/" \
         "https://dl.dell.com/FOLDER05920767M/1/DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz" \
    && tar xvf DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz \
    && cd iDRACTools/racadm/RHEL7/x86_64 \
    && alien --scripts srvadmin-hapi-*.rpm \
    && alien --scripts srvadmin-idracadm7-*.rpm \
    && dpkg -i srvadmin-hapi_*.deb srvadmin-idracadm7_*.deb \
    && ln -s /opt/dell/srvadmin/bin/idracadm7 /usr/bin/racadm \
    && rm -rf /tmp/iDRACTools /tmp/DellEMC-iDRACTools*

# ensure loader finds Dell libs
ENV LD_LIBRARY_PATH=/opt/dell/srvadmin/lib64/openmanage/private

WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir requests pyyaml

CMD ["python3", "app.py"]