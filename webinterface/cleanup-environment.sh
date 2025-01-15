#!/bin/bash

# Takes the following parameters
# authtoken = API Token from XC
# tenant = The Tenant of the User in XC
# namespace = The Namespace of the User in XC
# friendlyname = Part of the Hostname, CTFd or AppY will be prepended
# xcconsole = The Hostname of the User's Console

# Initialize variables
authtoken=""
tenant=""
namespace=""
friendlyname=""
xcconsole=""

# Function to display usage
usage() {
    echo "Usage: $0 [--authtoken <value>] [--tenant <value>] [--namespace <value>] [--friendlyname <value>] [--xcconsole <value>]"
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
        --tenant)
            tenant="$2"
            shift 2
            ;;
        --namespace)
            namespace="$2"
            shift 2
            ;;
        --friendlyname)
            friendlyname="$2"
            shift 2
            ;;
        --xcconsole)
            xcconsole="$2"
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

if [[ -z "$tenant" ]]; then
    read -p "Enter tenant: " tenant
fi

if [[ -z "$namespace" ]]; then
    read -p "Enter namespace: " namespace
fi

if [[ -z "$friendlyname" ]]; then
    read -p "Enter friendly name: " friendlyname
fi

if [[ -z "$xcconsole" ]]; then
    read -p "Enter XC Console URL: " xcconsole
fi


# Remove AppY LB
curl --silent --location --request DELETE 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/http_loadbalancers/'$friendlyname'-appy' --header 'Authorization: APIToken '$authtoken''
# Remove AppY Pool
curl --silent --location --request DELETE 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/origin_pools/'$friendlyname'-appy-pool' --header 'Authorization: APIToken '$authtoken''

# Remove CTFd LB
curl --silent --location --request DELETE 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/http_loadbalancers/'$friendlyname'-ctfd' --header 'Authorization: APIToken '$authtoken''
# Remove CTFd Pool

curl --silent --location --request DELETE 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/origin_pools/'$friendlyname'-ctfd-pool' --header 'Authorization: APIToken '$authtoken''

