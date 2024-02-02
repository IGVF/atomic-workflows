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
    build-essential && \
    rm -rf /var/lib/apt/lists/*
    
# Install kb-python
RUN pip install --quiet seqspec 
RUN pip install --quiet kb-python==0.28.2

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