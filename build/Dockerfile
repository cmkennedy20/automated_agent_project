FROM ubuntu:22.04

# --- Environment Variables ---
ENV AGENT_DIR="/actions-runner"
ENV SANDBOX_VOLUMES="_work/:${AGENT_DIR}/_work/code"
# NOTE: The version 2.328.0 does not exist. Using a recent, valid version.
ENV RUNNER_VERSION="2.311.0"
ENV RUNNER_TGZ="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
ENV RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TGZ}"
ENV RUNNER_ALLOW_RUNASROOT=1

# --- Install Dependencies, Runner, and create user ---
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl libicu-dev git python3 python3-pip \
    ca-certificates gnupg lsb-release sudo tini && \
    # Create the agent user with a home directory
    useradd -m agent && \
    # Add agent to the sudo group and allow passwordless sudo for permission handling
    usermod -aG sudo agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Create the runner directory
    mkdir -p ${AGENT_DIR} ${SANDBOX_VOLUMES} && \
    # Download and extract the runner in one step
    curl -o /tmp/${RUNNER_TGZ} -L ${RUNNER_URL} && \
    tar xzf /tmp/${RUNNER_TGZ} -C ${AGENT_DIR} --strip-components=1 && \
    rm /tmp/${RUNNER_TGZ} && \
    # Set correct ownership for the agent directory
    # chown -R agent:agent ${AGENT_DIR} && \
    # Clean up apt cache
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Install Docker CLI only (not the full engine) ---
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -y && \
    # Install only the client and containerd
    apt-get install -y --no-install-recommends docker-ce-cli containerd.io && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Finalizing Container Configuration ---
# Copy the startup script and ensure it's owned by the agent user
# COPY --chown=agent:agent ./build/agent-startup.sh ${AGENT_DIR}/
COPY ./build/agent-startup.sh ${AGENT_DIR}/

# Switch to the non-root user
# USER agent
WORKDIR ${AGENT_DIR}


# Use tini as the init process to properly handle signals
ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "./agent-startup.sh"]