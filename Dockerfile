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
ENV MOSDNS_VERSION v2.1.1
ENV MOSDNS_URL https://github.com/IrineSistiana/mosdns/releases/download/${MOSDNS_VERSION}/mosdns-linux-amd64.zip

RUN curl -sL $MOSDNS_URL | busybox unzip - \
	&& chmod +x /opt/dns/mosdns

# RUN apk del .build-deps

ENV SMARTDNS_RELEASE=Release35
ENV SMARTDNS_URL https://github.com/pymumu/smartdns/releases/download/${SMARTDNS_RELEASE}/smartdns-x86_64

RUN curl -sL $SMARTDNS_URL -o smartdns \
	&& chmod +x /opt/dns/smartdns

COPY ./scripts /opt/dns/scripts
COPY mosdns.yaml /opt/dns/config.yaml
COPY smartdns.conf /opt/dns/smartdns.conf

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s CMD drill @127.0.0.1 -p 53 cloudflare.com | grep NOERROR || exit 1

#run!
ENTRYPOINT ["/opt/dns/scripts/start.sh"]
