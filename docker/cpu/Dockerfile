FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    zlib1g-dev \
    libssl-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev \
    bzip2 \
    build-essential

# Install R

ENV R_BASE_VERSION 3.5.0

RUN sh -c 'echo "deb http://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" >> /etc/apt/sources.list' \
    && gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 \
    && gpg -a --export E084DAB9 | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends r-base=${R_BASE_VERSION}-* \
    && echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >> /etc/R/Rprofile.site

# Install Anaconda
    
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash Miniconda3-4.5.4-Linux-x86_64.sh -b -p /opt/conda

# Install tensorflow (cpu version) and keras

ENV TENSORFLOW_PYTHON /opt/conda/bin/python
RUN pip install tensorflow==1.8.0 keras==2.2.0

# Install additional R packages

ADD install_R_packages.R install_R_packages.R
RUN Rscript install_R_packages.R

CMD /bin/bash