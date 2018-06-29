FROM angusrtaylor/kerasr-gpu

# Install Azure CLI

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    lsb-release

RUN AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-get install apt-transport-https && \
    apt-get update && apt-get install azure-cli

CMD /bin/bash