FROM ubuntu:18.04

RUN apt-get update; apt-get -y dist-upgrade; apt-get -y install wget jq
RUN wget "https://github.com/fioprotocol/fio/releases/download/v3.4.0/fioprotocol-3.4.0-rc1-ubuntu-18.04-amd64.deb" && \
	apt-get install -y ./fioprotocol-3.4.0-rc1-ubuntu-18.04-amd64.deb && rm -f ./fioprotocol-3.4.0-rc1-ubuntu-18.04-amd64.deb

EXPOSE 8888/tcp
EXPOSE 3856/tcp

USER fio
WORKDIR /var/lib/fio

CMD ["/usr/local/bin/fio-nodeos-run"]
