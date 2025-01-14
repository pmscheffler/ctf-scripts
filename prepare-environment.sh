#! /bin/sh

ctfd=$(curl --silent --location 'http://metadata.udf/deployment/components' --header 'Content-Type: application/json'| jq -r '.[] | .accessMethods.https[]? | select(.label == "CTFd") | .host' )

echo 'CTFd: $ctfd'
