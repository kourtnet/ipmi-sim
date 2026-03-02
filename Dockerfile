# ========== Stage 1: builder ==========
FROM alpine:3.19 AS builder

RUN apk add --no-cache \
    build-base wget \
    openssl-dev ncurses-dev glib-dev popt-dev \
    linux-headers

WORKDIR /tmp
RUN wget https://sourceforge.net/projects/openipmi/files/OpenIPMI-2.0.25.tar.gz -O OpenIPMI-2.0.25.tar.gz && \
    tar xzf OpenIPMI-2.0.25.tar.gz && \
    cd OpenIPMI-2.0.25 && \
    ./configure \
      --prefix=/opt/openipmi \
      --without-perl \
      --without-python \
      --without-tcl && \
    make -j"$(nproc)" && \
    make install

# ========== Stage 2: runtime ==========
FROM alpine:3.19

ENV DYNAMIC_INTERVAL=5

RUN apk add --no-cache \
    openssl \        # даёт libcrypto.so.3/libssl.so.3[web:181]
    ncurses-libs \
    glib \
    popt \           # даёт libpopt.so.0[web:167][web:168]
    bash

WORKDIR /ipmisim

COPY --from=builder /opt/openipmi /opt/openipmi
ENV PATH=/opt/openipmi/bin:$PATH

# В musl ldconfig по сути не нужен, можно не вызывать
# Если очень хочется, можно добавить:
# ENV LD_LIBRARY_PATH=/opt/openipmi/lib

COPY --from=builder /build/state ./state
COPY lan.conf sim.emu sim.sdrs ./
COPY dynamic.sh entrypoint.sh ./
RUN chmod +x dynamic.sh entrypoint.sh

RUN mkdir -p /etc/ipmi /tmp/ipmisim/bin /tmp/ipmi && \
    printf '#!/bin/sh\nexit 0\n' > /etc/ipmi/lancontrol && chmod +x /etc/ipmi/lancontrol && \
    printf '#!/bin/sh\nexit 0\n' > /tmp/ipmisim/bin/chassis_control.sh && chmod +x /tmp/ipmisim/bin/chassis_control.sh

EXPOSE 623/udp
ENTRYPOINT ["/ipmisim/entrypoint.sh"]
