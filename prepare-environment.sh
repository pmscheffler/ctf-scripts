#! /bin/sh

ctfd=$(curl --silent --location 'http://metadata.udf/deployment/components' --header 'Content-Type: application/json'| jq -c '[ .[] | select(.label | contains("CTFd")) ]' .host)

echo 'CTFd: $host'
