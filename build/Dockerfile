FROM ubuntu:latest

ENV AGENT_DIR="/actions-runner"
ENV RUNNER_VERSION="2.328.0"
ENV RUNNER_TGZ="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
ENV RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TGZ}"

RUN apt-get update -y && \
    apt-get install -y curl libicu-dev && \
    useradd -m agent && \
    mkdir -p ${AGENT_DIR} && \
    cd ${AGENT_DIR} && \
    curl -o ${RUNNER_TGZ} -L ${RUNNER_URL} && \
    tar xzf ${RUNNER_TGZ} && \
    chmod +x config.sh run.sh

COPY agent-startup.sh ${AGENT_DIR}/

RUN chown -R agent:agent ${AGENT_DIR}

USER agent
WORKDIR ${AGENT_DIR}
ENTRYPOINT ["/bin/bash", "./agent-startup.sh"]