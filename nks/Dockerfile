FROM sgryczan/nks-cs:latest

VOLUME /root/.ssh

COPY scripts/docker_ssh_config /root/.ssh/config

ARG deploy_env
ARG nks_api_token
ARG nks_api_url
ARG component

ENV DEPLOY_ENV=$deploy_env
ENV NKS_API_TOKEN=$nks_api_token
ENV NKS_API_URL=$nks_api_url
ENV COMPONENT=$component

COPY ./env/$component /src/env/$component
COPY ./modules /src/env/$component/modules
WORKDIR /src/env/$component

COPY scripts/docker-entrypoint.sh /src/
COPY scripts/deploy-jenkins.sh /src/

ENTRYPOINT [ "/src/docker-entrypoint.sh" ]

