#!/bin/sh

cd $WORKDIR

[[ -n "$SUPERVISOR_PASS" ]] && sed -i "s/;username=user/username=$SUPERVISOR_USER/g; s/;password=123/password=$SUPERVISOR_PASS/g" /etc/supervisord.conf

if [[ $ENABLE_WEBPROC == 1 ]]; then
    webproc -c ./config.yaml -c ./smartdns.conf -c /etc/supervisord.conf -- /usr/bin/supervisord -c /etc/supervisord.conf
else
    echo "starting without webproc..."
    /usr/bin/supervisord -c /etc/supervisord.conf
fi