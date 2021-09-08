#!/bin/bash
set -e

cd $WORKDIR

./scripts/get-latest-info.sh

start_smartdns(){
    ./smartdns -c smartdns.conf -f &
    ./mosdns &
}

kill_dns(){
    kill -SIGTERM $(ps -e|grep smartdns|grep -v grep|awk '{print $1}')
    kill -SIGTERM $(ps -e|grep mosdns|grep -v grep|awk '{print $1}')
}


interrupt(){
    exit_proc
    kill_dns
}

exit_proc(){
    kill -SIGTERM $(ps -e|grep sleep|grep -v grep|awk '{print $1}')
}

trap exit_proc SIGTERM
trap interrupt SIGINT

start_smartdns

while sleep 3600 & wait $!; do :; done