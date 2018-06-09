FROM alpine:latest

LABEL maintainer="Danil Ibragimov <difeids@gmail.com>" \
      description="VPN (PPTP) server for Docker"

RUN apk add --no-cache iptables ppp pptpd && \
    sed -i "/^debug/s/^/#/" /etc/pptpd.conf

EXPOSE 1723

ENV SUBNET 172.31.255.0/24
ENV LOCAL_IP 172.31.255.1
ENV REMOTE_IP 172.31.255.100-199

COPY ./ppp /etc/ppp
COPY ./docker-entrypoint.sh /.

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["pptpd_run"]
