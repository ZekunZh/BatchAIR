FROM rocker/r-base

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Install Anaconda

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    zlib1g-dev \
    libssl-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev
    
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

# Install tensorflow gpu
ENV TENSORFLOW_PYTHON /opt/conda/bin/python
RUN pip install tensorflow keras

RUN mkdir /setup
ADD . /setup
RUN Rscript /setup/install_R_packages.R