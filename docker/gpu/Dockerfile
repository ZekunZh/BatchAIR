ARG cuda_version=9.0
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    zlib1g-dev \
    libssl-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev

# Install R (based on https://hub.docker.com/r/rocker/ml/~/dockerfile/)
RUN sh -c 'echo "deb http://cloud.r-project.org/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list' \
    && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
    && gpg -a --export E084DAB9 | apt-key add -

RUN apt-get install -y --no-install-recommends r-base \
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >> /etc/R/Rprofile.site

# Install Anaconda
    
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda

# Install tensorflow gpu
ENV TENSORFLOW_PYTHON /opt/conda/bin/python
RUN pip install tensorflow-gpu keras

RUN mkdir /setup
ADD . /setup
RUN Rscript /setup/install_R_packages.R