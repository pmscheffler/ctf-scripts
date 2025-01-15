#! /bin/bash

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

# Output the variables (for demonstration purposes)
echo "Authtoken: $authtoken"
echo "Tenant: $tenant"
echo "Namespace: $namespace"
echo "Friendly Name: $friendlyname"
echo "XC Console: $xcconsole"

# get the URL for the CTF
ctfd=$(curl --silent --location 'http://metadata.udf/deployment/components' --header 'Content-Type: application/json'| jq -r '.[] | .accessMethods.https[]? | select(.label == "CTFd") | .host' )
echo CTFd: $ctfd

# get the URL for the Target Server
appy=$(curl --silent --location 'http://metadata.udf/deployment/components' --header 'Content-Type: application/json'| jq -r '.[] | .accessMethods.https[]? | select(.label == "AppY") | .host' )
echo CTFd: $appy


# Create the AppY Load Balancer in XC
# Pool
appypool=$(curl --silent --location 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/origin_pools' --header 'Content-Type: application/json' --header 'Authorization: APIToken '$authtoken'' --data '{"metadata":{"name":"'$friendlyname'-appy-pool","disable":false},"spec":{"origin_servers":[{"public_name":{"dns_name":"'$appy'","refresh_interval":300}}],"use_tls":{"use_host_header_as_sni":{},"tls_config":{"default_security":{}},"volterra_trusted_ca":{},"no_mtls":{},"default_session_key_caching":{}},"port":443,"same_as_endpoint_port":{},"loadbalancer_algorithm":"LB_OVERRIDE","endpoint_selection":"LOCAL_PREFERRED"}}')  
echo AppYPool ID: $appypool
# LB
curl --silent --location 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/http_loadbalancers' --header 'Content-Type: application/json' --header 'Authorization: APIToken '$authtoken'' --data '{"metadata":{"name":"'$friendlyname'-appy","disable":false},"spec":{"domains":["'$friendlyname'-appy.sa.f5demos.com"],"http":{"dns_volterra_managed":true,"port":80},"advertise_on_public_default_vip":{},"default_route_pools":[{"pool":{"tenant":"'$tenant'","namespace":"'$namespace'","name":"'$friendlyname'-appy-pool","kind":"origin_pool"},"weight":1,"priority":1,"endpoint_subsets":{}}],"routes":[{"simple_route":{"path":{"prefix":"/*"},"incoming_port":{"no_port_match":{}},"origin_pools":[{"pool":{"tenant":"'$tenant'","namespace":"'$namespace'","name":"'$friendlyname'-appy-pool","kind":"origin_pool"},"weight":1,"priority":1,"endpoint_subsets":{}}],"host_rewrite":"'$appy'","query_params":{"retain_all_params":{}}}}],"disable_waf":{},"add_location":true,"no_challenge":{},"user_id_client_ip":{},"disable_rate_limit":{},"service_policies_from_namespace":{},"round_robin":{},"disable_trust_client_ip_headers":{},"disable_malicious_user_detection":{},"disable_api_discovery":{},"disable_bot_defense":{},"default_sensitive_data_policy":{},"disable_api_definition":{},"disable_ip_reputation":{},"disable_client_side_defense":{},"system_default_timeouts":{},"disable_threat_mesh":{},"l7_ddos_action_default":{}}}'


# Create the CTFd Load Balancer in XC
# Pool
curl --silent --location 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/origin_pools' --header 'Content-Type: application/json' --header 'Authorization: APIToken '$authtoken'' --data '{"metadata":{"name":"'$friendlyname'-ctfd-pool","disable":false},"spec":{"origin_servers":[{"public_name":{"dns_name":"'$ctfd'","refresh_interval":300}}],"use_tls":{"use_host_header_as_sni":{},"tls_config":{"default_security":{}},"volterra_trusted_ca":{},"no_mtls":{},"default_session_key_caching":{}},"port":443,"same_as_endpoint_port":{},"loadbalancer_algorithm":"LB_OVERRIDE","endpoint_selection":"LOCAL_PREFERRED"}}'
# LB
curl --silent --location 'https://'$xcconsole'.console.ves.volterra.io/api/config/namespaces/'$namespace'/http_loadbalancers' --header 'Content-Type: application/json' --header 'Authorization: APIToken '$authtoken'' --data '{"metadata":{"name":"'$friendlyname'-ctfd","disable":false},"spec":{"domains":["'$friendlyname'-ctfd.sa.f5demos.com"],"http":{"dns_volterra_managed":true,"port":80},"advertise_on_public_default_vip":{},"default_route_pools":[{"pool":{"tenant":"'$tenant'","namespace":"'$namespace'","name":"'$friendlyname'-ctfd-pool","kind":"origin_pool"},"weight":1,"priority":1,"endpoint_subsets":{}}],"routes":[{"simple_route":{"path":{"prefix":"/*"},"incoming_port":{"no_port_match":{}},"origin_pools":[{"pool":{"tenant":"'$tenant'","namespace":"'$namespace'","name":"'$friendlyname'-ctfd-pool","kind":"origin_pool"},"weight":1,"priority":1,"endpoint_subsets":{}}],"host_rewrite":"'$ctfd'","query_params":{"retain_all_params":{}}}}],"disable_waf":{},"add_location":true,"no_challenge":{},"user_id_client_ip":{},"disable_rate_limit":{},"service_policies_from_namespace":{},"round_robin":{},"disable_trust_client_ip_headers":{},"disable_malicious_user_detection":{},"disable_api_discovery":{},"disable_bot_defense":{},"default_sensitive_data_policy":{},"disable_api_definition":{},"disable_ip_reputation":{},"disable_client_side_defense":{},"system_default_timeouts":{},"disable_threat_mesh":{},"l7_ddos_action_default":{}}}'


