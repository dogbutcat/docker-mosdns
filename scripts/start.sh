#!/bin/sh

cd $WORKDIR

webproc -c ./config.yaml -c ./smartdns.conf -- ./scripts/start-dns.sh
# webproc -c ./config.yaml -c ./smartdns.conf -- ./mosdns