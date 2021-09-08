# docker-mosdns

mosdns in a docker container, configurable via a [simple web UI](https://github.com/jpillora/webproc)

## Usage

*. Run the container

   ```shell
   $ docker run \
       --name mosdns \
       -d \
       -p 53:53/udp \
       -p 5380:8080 \
       -v /opt/mosdns.yaml:/opt/dns/config.yaml \
       -v /opt/smartdns.conf:/opt/dns/smartdns.conf \
       --log-opt "max-size=100m" \
       -e "HTTP_USER=foo" \
       -e "HTTP_PASS=bar" \
       --restart always \
       dogbutcat/mosdns
   ```
