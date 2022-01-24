CUR_PATH := $(shell pwd)


build: stop
	docker build --rm -t docker-mosdns .

stop:
	@if [ "$(shell docker ps -a --format '{{.Names}}' |grep test_mosdns)" == "test_mosdns" ]; then \
		docker stop test_mosdns; \
	fi

test: build
	docker run --rm -v $(CUR_PATH)/data:/opt/dns/data \
		-v $(CUR_PATH)/conf/:/etc/supervisor.d/ \
		-d --name test_mosdns \
		-p 154:53/tcp -p 54:53/udp -p 8899:8080 -p 9001:9001 \
		docker-mosdns