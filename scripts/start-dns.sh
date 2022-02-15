#!/bin/bash
set -e

cd $WORKDIR

update_geo_data(){
    ./scripts/get-latest-info.sh 2> /dev/null
}

start_smartdns(){
    cp -rf ./data/. . 2> /dev/null
    # ./smartdns -c smartdns.conf -f &
    ./mosdns 2>&1 & # mosdns use os.Stderr writing log...
    sleep 2
    update_geo_data
}

kill_dns(){
    # kill -SIGTERM $(ps -e|grep smartdns|grep -v grep|awk '{print $1}')
    echo
    echo "Killing dns "$(ps -e|grep mosdns|grep -v grep|awk '{print $1}')
    kill -SIGTERM $(ps -e|grep mosdns|grep -v grep|awk '{print $1}')
}


interrupt(){
    kill_dns
    exit_proc
}

exit_proc(){
    echo
    echo "Killing handler "$(ps -e|grep sleep|grep -v grep|awk '{print $1}')
    kill -SIGTERM $(ps -e|grep sleep|grep -v grep|awk '{print $1}')
    echo
}

trap interrupt SIGTERM SIGINT SIGQUIT SIGKILL

start_smartdns

while sleep 3600 & wait $!; do :; done