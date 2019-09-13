FROM sgryczan/nks-cs:latest

VOLUME /root/.ssh
ENV PORT 8080

COPY scripts/docker_ssh_config /root/.ssh/config

ARG deploy_env
ARG component
ARG nks_api_token
ARG nks_api_url

ENV DEPLOY_ENV=$deploy_env
ENV COMPONENT=$component
ENV NKS_API_TOKEN=$nks_api_token
ENV NKS_API_URL=$nks_api_url

COPY ./providers/$component /src/providers/$component
COPY ./modules /src/providers/$component/modules
WORKDIR /src/providers/$component

COPY scripts/docker-entrypoint.sh /src/
COPY scripts/deploy-jenkins.sh /src/

CMD [ "/bin/bash" ]

