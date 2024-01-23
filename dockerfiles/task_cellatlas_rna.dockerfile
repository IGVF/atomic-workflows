############################################################
# Dockerfile for IGVF single-cell pipeline cellatlas RNA task
# Based on Debian slim
############################################################

FROM python:3.11-slim-bullseye as builder

LABEL maintainer = "Siddarth Wekhande"
LABEL software = "IGVF single-cell pipeline"
LABEL software.version="0.0.1"
LABEL software.organization="IGVF"
LABEL software.version.is-production="No"
LABEL software.task="cellatlas_rna"

# To prevent time zone prompt
ENV DEBIAN_FRONTEND=noninteractive

# Install softwares from apt repo
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    liblz4-dev \
    liblzma-dev \
    libncurses5-dev \
    libbz2-dev \
    wget \
    tar \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x jq-linux64 \
    && mv jq-linux64 /usr/local/bin/jq
    
# Install cellatlas
RUN git clone https://github.com/cellatlas/cellatlas.git \
    && cd cellatlas \
    && pip install .
    
RUN pip uninstall -y --quiet seqspec        
RUN pip install --quiet seqspec 
RUN pip install --quiet kb-python 

# Create and setup new user
#ENV USER=igvf
#WORKDIR /home/$USER

#RUN groupadd -r $USER &&\
 #   useradd -r -g $USER --home /home/$USER -s /sbin/nologin -c "Docker image user" $USER &&\
  #  chown $USER:$USER /home/$USER

#COPY --chown=$USER:$USER src/bash/monitor_script.sh /usr/local/bin
COPY src/bash/monitor_script.sh /usr/local/bin
COPY src/python/modify_barcode_h5.py /usr/local/bin

USER $USER
