FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# base tools + dependencies
RUN apt-get update
RUN apt-get install -y \
    wget tar rpm2cpio cpio

RUN apt-get install -y \
    python3 python3-pip

RUN apt-get install -y \
    libssl3 libargtable2-0

RUN apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# download Dell iDRAC tools and install racadm
RUN wget --header="User-Agent: Mozilla/5.0" \
         --header="Referer: https://www.dell.com/" \
         "https://dl.dell.com/FOLDER05920767M/1/DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz"

RUN tar xvf DellEMC-iDRACTools-Web-LX-9.4.0-3732_A00.tar.gz \
    && cd iDRACTools/racadm/RHEL7/x86_64 \
    && rpm2cpio srvadmin-hapi-*.rpm      | cpio -idmv \
    && rpm2cpio srvadmin-idracadm7-*.rpm | cpio -idmv \
    && cp -a opt/ /  \
    && ln -sf /opt/dell/srvadmin/bin/idracadm7 /usr/bin/racadm \
    && rm -rf /tmp/iDRACTools /tmp/DellEMC-iDRACTools*

RUN ln -s /usr/lib/x86_64-linux-gnu/libssl.so.3    /usr/lib/x86_64-linux-gnu/libssl.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so


# ensure loader finds Dell libs
ENV LD_LIBRARY_PATH=/opt/dell/srvadmin/lib64/openmanage/private



WORKDIR /app

COPY app.py .

RUN pip install --no-cache-dir requests pyyaml

CMD ["python3", "app.py"]