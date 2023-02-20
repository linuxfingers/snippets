# Apache or NGINX?
curl -v website.com 2>&1 | grep -i server | awk -F: '{print $2}'
