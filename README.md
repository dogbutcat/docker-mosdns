# docker-mosdns

mosdns with smartdns in a docker container, hold by supervisord, configurable via a [simple web UI](https://github.com/jpillora/webproc)

## Usage

* Run the container

   ```shell
   $ docker run \
       --name mosdns \
       -d \
       -p 53:53/udp \
       -p 5380:8080 \
       -p 9001:9001 \
       -v /opt/mosdns.yaml:/opt/dns/config.yaml \
       -v /opt/smartdns.conf:/opt/dns/smartdns.conf \
       --log-opt "max-size=100m" \
       -e "ENABLE_WEBPROC=1" \ # enable webproc
       -e "HTTP_USER=foo" \
       -e "HTTP_PASS=bar" \
       -e "SUPERVISOR_USER=user" \ # supervisor http server username, only availiable when set password below
       -e "SUPERVISOR_PASS=123" \ # supervisor http server password, empty for default
       --restart always \
       dogbutcat/mosdns
   ```
