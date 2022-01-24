FROM alpine:latest

LABEL maintainer="dogbutcat@hotmail.com"
# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_amd64.gz
# fetch dnsmasq and webproc binary
RUN apk --no-cache add curl git bash unzip drill \
	# && apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc

# mosdns
WORKDIR /opt/dns

ENV WORKDIR /opt/dns
ENV MOSDNS_VERSION v3.0.0
ENV MOSDNS_URL https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VERSION}/mosdns-linux-amd64.zip

RUN curl -sL $MOSDNS_URL | busybox unzip - \
	&& chmod +x /opt/dns/mosdns

# RUN apk del .build-deps

ENV SMARTDNS_RELEASE=Release35
ENV SMARTDNS_URL https://github.com/pymumu/smartdns/releases/download/${SMARTDNS_RELEASE}/smartdns-x86_64

ENV DOWNLOAD_LINK_GEOIP https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
ENV DOWNLOAD_LINK_GEOSITE https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

ENV ENABLE_WEBPROC=1

RUN apk add --no-cache supervisor
RUN mkdir -p /var/log/supervisor

RUN curl -sL $SMARTDNS_URL -o smartdns \
	&& chmod +x /opt/dns/smartdns

RUN mkdir ${WORKDIR}/data

RUN curl -sL $DOWNLOAD_LINK_GEOIP -o ${WORKDIR}/data/geoip.dat
RUN curl -sL $DOWNLOAD_LINK_GEOSITE -o ${WORKDIR}/data/geosite.dat
RUN cp ${WORKDIR}/data/* ${WORKDIR}/

RUN cp /etc/supervisord.conf /etc/supervisord.conf.example
RUN echo -e '\
[unix_http_server]\n\
file=/run/supervisord.sock  ; the path to the socket file\n\
[inet_http_server]        ; inet (TCP) server disabled by default\n\
port=0.0.0.0:9001         ; ip_address:port specifier, *:port for all iface\n\
;username=user            ; default is no username (open server)\n\
;password=123             ; default is no password (open server)\n\
[supervisorctl]\n\
serverurl=unix:///run/supervisord.sock ; use a unix:// URL for a unix socket\n\
serverurl=http://0.0.0.0:9001       ; use an http:// url to specify an inet socket\n\
;username=user                        ; should be same as in [*_http_server] if set\n\
;password=123                          ; should be same as in [*_http_server] if set\n\
;prompt=mysupervisor                   ; cmd line prompt (default "supervisor")\n\
;history_file=~/.sc_history            ; use readline history if available\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface\n\
[supervisord]\n\
nodaemon=true\n\
user=root\n\
[include]\n\
files = /etc/supervisor.d/*.ini\n\
' > /etc/supervisord.conf

ENV SUPERVISOR_USER=user
# no pass for default
ENV SUPERVISOR_PASS=

COPY ./conf /etc/supervisor.d/
COPY ./scripts /opt/dns/scripts
COPY mosdns.yaml /opt/dns/config.yaml
COPY smartdns.conf /opt/dns/smartdns.conf

HEALTHCHECK --interval=60s --timeout=60s --start-period=30s CMD drill @127.0.0.1 -p 53 cloudflare.com | grep NOERROR || exit 1

#run!
ENTRYPOINT ["/opt/dns/scripts/start.sh"]
