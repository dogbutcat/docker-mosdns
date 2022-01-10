#!/bin/sh

cd $WORKDIR

if [[ $ENABLE_WEBPROC == 1 ]]; then
    webproc -c ./config.yaml -c ./smartdns.conf -- ./scripts/start-dns.sh
else
    echo "starting without webproc..."
    ./scripts/start-dns.sh
fi