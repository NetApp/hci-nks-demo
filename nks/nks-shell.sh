#!/bin/bash

set -e

# Map script arguments
while true; do
    case "$1" in
        -p|--provider) PROVIDER=$2 ; shift 2 ;;
        -k|--provider-key)  export PROVIDER_KEY=$2 ; shift 2 ;;
        -a|--action) COMMAND=$2 ; shift 2 ;;
        -n|--cluster-name) CLUSTER_NAME=$2 ; shift 2 ;;
        -u|--url) URL=$2 ; shift ;;
        -h|--help) usage ;;
        --) shift ; break ;;
        *) break ;;
    esac
done

echo "--> Enter your NKS API Token: "
read nks_api_key
export NKS_API_TOKEN=$nks_api_key

usage() {
    echo "Most of the arguments are stubs and have not yet been implemented. Please run the script with no arguments"
    exit 1
}

mapArgs() {
    [[ -z $URL ]] && export NKS_API_URL="https://api.nks.netapp.io"
    [[ -z $PROVIDER ]] && export PROVIDER="gce"
    [[ -z $CLUSTER_NAME ]] && export CLUSTER_NAME="nks-demo-gce"
    mapAction  
}

mapAction() {
    if [[ -z $COMMAND ]]; then
        COMMAND="deploy-cluster"
    else
        case "$COMMAND" in
            destroy-cluster) COMMAND="destroy-cluster" ;;
            shell) COMMAND="shell" ;;
            *) echo "Invalid action specified" ; usage ;;
        esac
    fi
}

# Prepare deployment environment
createProjectFolder() {
    mkdir -p providers/$PROVIDER/$CLUSTER_NAME

    cat > providers/$PROVIDER/$CLUSTER_NAME/terraform.tfvars << EOF
# Organization
organization_name = "$ORG_NAME"

# Cluster
cluster_name = "$CLUSTER_NAME"

# Keyset
provider_keyset_name = "$PROVIDER_KEYSET_NAME"
ssh_keyset_name = "Default SPC SSH Keypair"

# Provider
provider_code = "$PROVIDER"
provider_k8s_version = "v1.13.2"
provider_platform = "coreos"
provider_region = "us-west1-c"
provider_network_id = "__new__"
provider_network_cidr = "172.23.0.0/16"
provider_subnet_id = "__new__"
provider_subnet_cidr = "172.23.1.0/24"
provider_master_size = "n1-standard-1"
provider_worker_size = "n1-standard-1"
provider_channel = "stable"
provider_etcd_type = "classic"

EOF
}

mapArgs

case "$COMMAND" in
    deploy-cluster)
        createProjectFolder
        # deploy project
        exec ./scripts/deploy.sh -a build -c gce -e $CLUSTER_NAME
        ;;
    destroy-cluster)
        exec ./scripts/deploy.sh -a destroy -c $PROVIDER -e $CLUSTER_NAME
        ;;
    shell)
        exec ./scripts/deploy.sh -c $PROVIDER -e $CLUSTER_NAME -d
        ;;
    *)
        echo "No more actions to try"
        ;;
esac





