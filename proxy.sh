#!/bin/bash
HTTP_PROXY_USER=JimLin
HTTP_PROXY=10.241.121.21
HTTP_PROXY_PORT=3128
read -p "Proxy password:" -s passwd
echo
env "http_proxy=http://$HTTP_PROXY_USER:$passwd@$HTTP_PROXY:$HTTP_PROXY_PORT" git "$@"
