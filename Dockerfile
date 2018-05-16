FROM alpine:latest

LABEL maintainer="Danil Ibragimov <difeids@gmail.com>" \
      description="VPN (PPTP) server for Docker"

RUN apk add --no-cache iptables ppp pptpd && \
    sed -i "/^debug/s/^/#/" /etc/pptpd.conf

EXPOSE 1723

ENV SUBNET 172.20.10.0/24
ENV LOCAL_IP 172.20.10.1
ENV REMOTE_IP 172.20.10.100-199

COPY ./ppp /etc/ppp
COPY ./bin /usr/local/bin

ENTRYPOINT ["pptpd_init"]
CMD ["pptpd_run"]
