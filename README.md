[![](https://images.microbadger.com/badges/image/difeid/pptpd.svg)](https://microbadger.com/images/difeid/pptpd "Get your own image badge on microbadger.com")
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fdifeid%2Fdocker-pptpd.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fdifeid%2Fdocker-pptpd?ref=badge_shield)

# VPN (PPTP) server for Docker

This is a docker image with VPN (PPTP) server with _chap-secrets_ authentication.

PPTP uses _/etc/ppp/chap-secrets_ file to authenticate VPN users.

Example of _chap-secrets_ file:

````
# Secrets for authentication using PAP
# client    server      secret      acceptable local IP addresses
username    *           password    *
````

## Starting VPN server
### Usage
To start VPN server as a docker container run:

````
docker run -d --cap-add=NET_ADMIN --device=/dev/ppp -p 1723:1723 -v pptpd:/etc/ppp/ --name=pptpd difeid/pptpd
````

Edit your local _chap-secrets_ file, to add or modify VPN users whenever you need.
When adding new users to _chap-secrets_ file, you don't need to restart Docker container.

You can edit _options.pptp_ file for modify pptpd configuration.
When modifying configuration, you need to restart container.

If you have fails, please try run the docker container with --privileged

### Simple usage
````
docker run -d --cap-add=NET_ADMIN --device=/dev/ppp -p 1723:1723 -e USER={your user} -e PASS={your pass} difeid/pptpd
````

## Connecting to VPN service
You can use any VPN (PPTP) client to connect to the service.
To authenticate use credentials provided in _chap-secrets_ file.

## Environment variables
* USER, PASS - create USER with PASSword
* SUBNET - interface ppp0 inet addr. Default: 172.20.10.0/24
* LOCAL_IP - pptpd local IP address. Default: 172.20.10.1
* REMOTE_IP - pptpd remote IP address ranges. Default: 172.20.10.100-199

## Troubleshooting
In case of permission denied inside container, you can try to start container with --privileged key.

