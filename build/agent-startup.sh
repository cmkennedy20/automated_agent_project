#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

DOCKER_SOCKET=/var/run/docker.sock

# Check if the Docker socket is mounted
if [ -S "$DOCKER_SOCKET" ]; then
    # Get the Group ID (GID) of the mounted Docker socket
    DOCKER_GID=$(stat -c '%g' "$DOCKER_SOCKET")

    # Check if a 'docker' group with that GID already exists in the container
    if ! getent group "$DOCKER_GID" >/dev/null; then
        # If not, create a new 'docker' group with the correct GID
        echo "Creating docker group with GID ${DOCKER_GID}"
        sudo groupadd -for -g "${DOCKER_GID}" docker
    fi

    # Add the current user (agent) to the docker group
    echo "Adding agent user to docker group"
    sudo usermod -aG docker "$(whoami)"

    DOCKER_GROUP=docker

    echo "Docker permissions configured successfully."
else
    echo "Warning: Docker socket not found at $DOCKER_SOCKET. Docker CLI will not work."
fi

AGENT_NAME="agent-$(date +%s%N)"
./config.sh --url https://github.com/cmkennedy20/automated_agent_project --token $AGENT_TOKEN --name  "$AGENT_NAME"

exec sg "${DOCKER_GROUP}" -c "./run.sh"