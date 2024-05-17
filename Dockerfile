
# Stage 1: Main Build
# Python 3.11 tag
FROM python:3.11.9-bookworm AS main-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "/bin/bash", "-c" ]

# Stage 2: Dev tests build
FROM main-build AS dev-tests-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install --no-install-recommends -y shellcheck=0.9.0-1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --progress=dot:giga -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && \
    chmod +x /bin/hadolint && \
    wget --progress=dot:giga https://github.com/rhysd/actionlint/releases/download/v1.6.27/actionlint_1.6.27_linux_amd64.tar.gz && \
    mkdir actionlint_folder && \
    tar -xf actionlint_1.6.27_linux_amd64.tar.gz -C actionlint_folder && \
    mv actionlint_folder/actionlint /usr/local/bin/ && \
    rm -rf actionlint_folder && \
    chmod +x /usr/local/bin/actionlint

COPY requirements-pip-tools.txt requirements-pip-tools.txt
RUN pip install --no-cache-dir -r requirements-pip-tools.txt


COPY requirements-dev.txt requirements-dev.txt
RUN pip install --no-cache-dir -r requirements-dev.txt
ENTRYPOINT [ "/bin/bash", "-c" ]

# Stage 3: Dev-env build: This stage is used as development environment.
FROM dev-tests-build AS dev-env-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Give your host machine's docker GID 'getent group docker | cut -d: -f3'
ARG HOST_DOCKER_GID=999
ARG HOST_UID=1000
ARG HOST_GID=1003

ENV DEVUSER=devroot

# hadolint ignore=SC2034
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    docker.io=20.10.24+dfsg1-1+b3 \
    vim=2:9.0.1378-2 \
    less=590-2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    if ! getent group "$HOST_GID" > /dev/null; then groupadd -g "$HOST_GID" user_host; fi && \
    useradd -s /bin/bash -mlou "$HOST_UID" -g "$HOST_GID" "$DEVUSER" && \
    if ! getent group "$HOST_DOCKER_GID" > /dev/null; then groupadd -g "$HOST_DOCKER_GID" docker_host; fi && \
    usermod -aG "$(getent group $HOST_DOCKER_GID | cut -d: -f1)" "$DEVUSER"

USER "$DEVUSER"

ENTRYPOINT [ "/bin/bash", "-c" ]