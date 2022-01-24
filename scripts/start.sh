#!/bin/sh

cd $WORKDIR

if [[ $ENABLE_WEBPROC == 1 ]]; then
    webproc -c ./config.yaml -c ./smartdns.conf -- /usr/bin/supervisord
else
    echo "starting without webproc..."
    /usr/bin/supervisord
fi