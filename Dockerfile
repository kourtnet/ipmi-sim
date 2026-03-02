FROM debian:11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential wget ca-certificates \
    libssl-dev libncurses-dev libglib2.0-dev \
    libpopt-dev \
    && rm -rf /var/lib/apt/lists/*

# Build OpenIPMI 2.0.25 from source
WORKDIR /tmp
RUN wget https://sourceforge.net/projects/openipmi/files/OpenIPMI-2.0.25.tar.gz -O OpenIPMI-2.0.25.tar.gz && \
    tar xzf OpenIPMI-2.0.25.tar.gz && \
    cd OpenIPMI-2.0.25 && \
    ./configure --prefix=/opt/openipmi-2.0.25 --without-perl --without-python && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig && \
    rm -rf /tmp/OpenIPMI-2.0.25*

ENV PATH=/opt/openipmi-2.0.25/bin:$PATH

WORKDIR /ipmisim

# Copy simulator config files
COPY lan.conf sim.emu sim.sdrs ./

# Compile SDR
RUN mkdir -p ./state/ipmi_sim/IPMI-SIM-SERVER && \
    sdrcomp -o ./state/ipmi_sim/IPMI-SIM-SERVER/sdr.20.main ./sim.sdrs

# Create stub scripts referenced by lan.conf
RUN mkdir -p /etc/ipmi /tmp/ipmisim/bin && \
    printf '#!/bin/sh\nexit 0\n' > /etc/ipmi/lancontrol && chmod +x /etc/ipmi/lancontrol && \
    printf '#!/bin/sh\nexit 0\n' > /tmp/ipmisim/bin/chassis_control.sh && chmod +x /tmp/ipmisim/bin/chassis_control.sh

# Create poll file directory
RUN mkdir -p /tmp/ipmi

# Copy dynamic value generator and entrypoint
COPY dynamic.sh entrypoint.sh ./
RUN chmod +x dynamic.sh entrypoint.sh

# IPMI RMCP port
EXPOSE 623/udp

# dynamic.sh interval (seconds), override with -e DYNAMIC_INTERVAL=N
ENV DYNAMIC_INTERVAL=5

ENTRYPOINT ["/ipmisim/entrypoint.sh"]
