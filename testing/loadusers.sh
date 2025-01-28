#!/bin/bash

host=""
authtoken=""
wait=""
startid=""
endid=""

# Function to display usage
usage() {
    echo "Usage: $0 [--authtoken <value>] [--host <value>] [--startid <value>] [--endid <value>] [--wait <value>]"
    echo "If no parameters are provided, you will be prompted to enter the values interactively."
    exit 1
}

# Parse named parameters
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --authtoken)
            authtoken="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --startid)
            startid="$2"
            shift 2
            ;;
        --endid)
            endid="$2"
            shift 2
            ;;
        --wait)
            wait="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
done

# Prompt user for input if any value is missing
if [[ -z "$authtoken" ]]; then
    read -p "Enter authtoken: " authtoken
fi

if [[ -z "$host" ]]; then
    read -p "Enter host: " host
fi

if [[ -z "$startid" ]]; then
    read -p "Enter startid: " startid
fi

if [[ -z "$endid" ]]; then
    read -p "Enter endid: " endid
fi


if [[ -z "$wait" ]]; then
    read -p "Enter wait time in seconds: " wait
fi



for i in $(seq $startid $endid); do
  curl --location 'https://'$host'/api/v1/users' \
    --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    --header 'Accept-Language: en-US,en;q=0.5' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Token '$authtoken'' \
    --data-raw "{\"name\":\"test$i\",\"email\":\"test$i@test.com\",\"password\":\"test123\",\"type\":\"user\",\"verified\":false,\"hidden\":false,\"banned\":false}"
  sleep $wait
done
