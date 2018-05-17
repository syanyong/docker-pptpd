#!/bin/sh

set -e

# enable IP forwarding
if [[ $(sysctl -n net.ipv4.ip_forward) -eq 0 ]]; then
    echo "Enabling IPv4 Forwarding"
    # If this fails, ensure the docker container is run with --privileged
    sysctl -w net.ipv4.ip_forward=1 || echo "Failed to enable IPv4 Forwarding"
fi

# configure firewall
echo "Configuring iptables"
set -x
iptables -t nat -A POSTROUTING -s ${SUBNET} ! -d ${SUBNET} -j MASQUERADE
iptables -A FORWARD -s ${SUBNET} -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
iptables -A INPUT -i ppp0 -j ACCEPT
iptables -A OUTPUT -o ppp0 -j ACCEPT
iptables -A FORWARD -i ppp0 -j ACCEPT
iptables -A FORWARD -o ppp0 -j ACCEPT
{ set +x ;} 2> /dev/null

# configure pptp IP address ranges
sed -i "s/^localip.*/localip ${LOCAL_IP}/" /etc/pptpd.conf
sed -i "s/^remoteip.*/remoteip ${REMOTE_IP}/" /etc/pptpd.conf
echo -e "\nLocal ip: \t${LOCAL_IP}\nRemote ip: \t${REMOTE_IP}"

# configure pptp user
if [ x"${USER}" != "x" -a x"${PASS}" != "x" ]; then
    if grep -q -E ^${USER} /etc/ppp/chap-secrets; then
        echo "User ${USER} already exist"
    else
        echo -e "\n${USER} \t* \t${PASS} \t\t*" >> /etc/ppp/chap-secrets
        echo -e "PPTP user: \t${USER}\nPPTP pass: \t${PASS}"
    fi
fi

echo -e "\n## PPTPD configuration ##"
cat /etc/ppp/options.pptp
echo -e "#########################\n"

if [ "$1" = "pptpd_run" ]; then
    echo "Starting syslogd and pptpd"
    syslogd -n -O- & exec "pptpd" "--fg"
else
    exec "$@"
fi
