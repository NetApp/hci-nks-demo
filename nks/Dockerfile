FROM sgryczan/nks-cs:latest

VOLUME /root/.ssh
ENV PORT 8080

COPY scripts/docker_ssh_config /root/.ssh/config

ARG deploy_env
ARG nks_api_token
ARG nks_api_url
ARG component

ENV DEPLOY_ENV=$deploy_env
ENV NKS_API_TOKEN=$nks_api_token
ENV NKS_API_URL=$nks_api_url
ENV COMPONENT=$component

COPY ./providers/$component /src/providers/$component
COPY ./modules /src/providers/$component/modules
WORKDIR /src/providers/$component

COPY scripts/docker-entrypoint.sh /src/
COPY scripts/deploy-jenkins.sh /src/

ENTRYPOINT [ "/src/docker-entrypoint.sh" ]

