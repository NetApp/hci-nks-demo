#!/bin/bash

set -e
#set -x

usage() {
    echo "Usage: $0 --action (build|destroy) --component (gce,ec2,etc..) --env (ex. my-demo-cluster)"
    exit 1
}

# Map script arguments
while true; do
    case "$1" in
        -c|--component) COMPONENT=$2 ; shift 2 ;;
        -e|--env)  DEPLOY_ENV=$2 ; shift 2 ;;
        -a|--action) ACTION=$2 ; shift 2 ;;
        -d|--debug) DEBUG="true" ; shift ;;
        -h|--help) usage ;;
        --) shift ; break ;;
        *) break ;;
    esac
done

# Make sure none of the required arguments are omitted
[[ -z "$COMPONENT" || -z "$DEPLOY_ENV" ]] && usage

# If no action is specified, set to build
case "$ACTION" in
    build) ACTION="build" ;;
    destroy) ACTION="destroy" ;;
    plan) ACTION="plan" ;;
    *) ACTION="build" ;;
esac

echo "COMPONENT: $COMPONENT"
echo "DEPLOY_ENV: $DEPLOY_ENV"
echo "ACTION: $ACTION"
echo "API URL: $NKS_API_URL"
echo "APIKEY: $NKS_API_TOKEN"

if [[ "$ACTION" = 'build' || "$ACTION" = 'plan' || "$ACTION" = 'destroy' ]]; then
    docker build -t nks-tf \
        --build-arg deploy_env=$DEPLOY_ENV \
        --build-arg nks_api_token=$NKS_API_TOKEN \
        --build-arg nks_api_url=$NKS_API_URL \
        --build-arg component=$COMPONENT \
        .

    # A key must be mounted to /root/.ssh/id_rsa in order for the build to trigger. 
    # This key should have read access to all dependent module repos in main.tf
    if [[ "$DEBUG" = 'true' ]]; then 
        docker run -ti \
            -v $(pwd)/env/$COMPONENT/$DEPLOY_ENV:/src/env/$COMPONENT/$DEPLOY_ENV \
            --entrypoint /bin/bash \
            nks-tf:latest
    else
    # Optionally override the entrypoint to boot into an interactive shell- useful for debugging
        docker run -ti \
            -v $(pwd)/env/$COMPONENT/$DEPLOY_ENV:/src/env/$COMPONENT/$DEPLOY_ENV \
            nks-tf:latest --$ACTION
    fi
else
    echo "ACTION: $ACTION is set to neither 'build', 'plan', or 'destroy'"
    usage
fi


