#!/bin/bash
set -e
#set -x

echo "ARG: $1"

init() {
    export TF_WARN_OUTPUT_ERRORS=1
    echo "****************"
    echo "TERRAFORM - INIT"
    echo "****************"
    terraform init -input=false
}

plan() {
    
    init

    echo "****************"
    echo "TERRAFORM - PLAN"
    echo "Deploy_Env: $DEPLOY_ENV"
    echo "****************"
    terraform plan -input=false -var-file=$DEPLOY_ENV/terraform.tfvars -state=$DEPLOY_ENV/terraform.tfstate
}

build() {
    #plan
    init

    echo "****************"
    echo "TERRAFORM - APPLY"
    echo "****************"
    terraform apply --state=$DEPLOY_ENV/terraform.tfstate -var-file=$DEPLOY_ENV/terraform.tfvars -auto-approve

    echo "****************"
    echo "TERRAFORM - OUTPUTS"
    echo "****************"
    terraform output -json --state=$DEPLOY_ENV/terraform.tfstate

    cat $DEPLOY_ENV/terraform.tfstate | jq -r '.modules[1].resources."nks_cluster.terraform-cluster".primary.attributes.kubeconfig' > $DEPLOY_ENV/kubeconfig
    export KUBECONFIG=$DEPLOY_ENV/kubeconfig
    export CLUSTER_ID=$(cat $DEPLOY_ENV/terraform.tfstate | jq -r '.modules[1].resources."nks_cluster.terraform-cluster".primary.attributes.id')
}

destroy() {

    cp $DEPLOY_ENV/terraform.tfvars terraform.tfvars

    init

    echo "****************"
    echo "TERRAFORM - DESTROY"
    echo "Deploy_Env: $DEPLOY_ENV"
    echo "****************"
    export TF_WARN_OUTPUT_ERRORS=1
    terraform destroy --state=$DEPLOY_ENV/terraform.tfstate -auto-approve
    rm -rf $DEPLOY_ENV/*
}

console() {
    init

    echo "*******************"
    echo "TERRAFORM - CONSOLE"
    echo "*******************"
    terraform console --state=$DEPLOY_ENV/terraform.tfstate
}

getOrgs() {
    echo "--> Retrieving Orgs.."
    export ORGS=$(curl -s $NKS_API_URL/orgs -H "Authorization: Bearer $NKS_API_TOKEN")
    export ORG_ID=$(echo $ORGS | jq -r '.[0].pk')
    export ORG_NAME=$(echo $ORGS | jq -r '.[0].name')
}

getKeySets() {
    # Find GCE Keyset
    echo "--> Retrieving KeySets.."
    export KEYSETS=$(curl -s $NKS_API_URL/orgs/$ORG_ID/keysets -H "Authorization: Bearer $NKS_API_TOKEN")
}

getProviderKeySet() {
    getKeySets
    export PROVIDER_KEYSETS=$(echo $KEYSETS | jq '.[] | select(.category == "provider") | select(.entity == "$PROVIDER")')
    export PROVIDER_KEYSET_NAME=$(echo $PROVIDER_KEYSETS | jq -r '. |[{pk: .pk, name: .name,entity: .entity}] | .[0] |.name ')
    export PROVIDER_KEYSET_LEN=$(echo $PROVIDER_KEYSETS | jq '. |[{pk: .pk, name: .name,entity: .entity}] | length')
}

getProviderKeySetByName() {
    export PROVIDER_KEYSETS=$(echo $KEYSETS | jq '.[] | select(.category == "provider") | select(.entity == "$PROVIDER")')
    export PROVIDER_KEYSET_NAME=$(echo $PROVIDER_KEYSETS | jq -r '. |[{pk: .pk, name: .name,entity: .entity}] | .[0] |.name ')
    export PROVIDER_KEYSET_LEN=$(echo $PROVIDER_KEYSETS | jq '. |[{pk: .pk, name: .name,entity: .entity}] | length')
}

mapProviderKey() {
    if [[ -z $PROVIDER_KEY ]]; then
        getProviderKeySet
    else
        getProviderKeySetByName
    fi
}

getDefaultSSHKeySet() {
    # Find SSH Keyset
    export SSH_KEYSETS=$(echo $KEYSETS | jq '.[] | select(.category == "user_ssh")')
    export DEFAULT_KEYSET=$(echo $SSH_KEYSETS | jq '. | select(.name == "Default SPC SSH Keypair")')
}

# Check GCE keys present
if [[ $PROVIDER_KEYSET_LEN = 0 ]]; then 
    echo "NO GCP Provider Keys Found!"
    exit 1 
fi

getOrgs
mapProviderKey
getDefaultSSHKeySet


case "$1" in
    --plan) plan ;;
    --build) build ;;
    --destroy) destroy ;;
    --console) console ;;
    *) echo "$1 is not a valid action" ;;
esac

exec /bin/bash
