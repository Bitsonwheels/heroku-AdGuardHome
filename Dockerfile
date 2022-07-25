FROM alpine:latest AS builder
#RUN adduser -D bits
#USER bits


#RUN sudo apt update
RUN apk add bash make build-base yarn npm vim mc go && \
    rm -rf /var/cache/apk/*
    
# install cap package and set the capabilities on busybox
RUN apk add --update --no-cache libcap && \
    setcap cap_setgid=ep /bin/AdGuardHome && \
    setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' ./AdGuardHome && \
    setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' ./bin/AdGuardHome

RUN apk add --no-cache git=2.22.2-r0 \
    --repository https://alpine.global.ssl.fastly.net/alpine/v3.10/community \
    --repository https://alpine.global.ssl.fastly.net/alpine/v3.10/main

WORKDIR /src/AdGuardHome
COPY . /src/AdGuardHome
RUN npm update
RUN make

FROM alpine:latest
LABEL maintainer="AdGuard Team <devteam@adguard.com>"

# Update CA certs
RUN rm -rf /var/cache/apk/* && mkdir -p /opt/adguardhome

COPY --from=build /src/AdGuardHome/AdGuardHome /opt/adguardhome/AdGuardHome

#EXPOSE 8080/tcp 1443/tcp 1853/tcp 1853/udp 3000/tcp

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]
CMD ["-h", "0.0.0.0", "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", "-w", "/opt/adguardhome/work"]
