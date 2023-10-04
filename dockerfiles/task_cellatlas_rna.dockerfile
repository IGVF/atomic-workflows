############################################################
# Dockerfile for cellatlas
# Based on Debian slim
############################################################

FROM python:3.11-slim-bullseye as builder

# To prevent time zone prompt
ENV DEBIAN_FRONTEND=noninteractive

ENV SAMTOOLS_VERSION 1.9

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
    
# Install kb-python
RUN pip install kb-python

# Install minimap
RUN wget --quiet "https://github.com/lh3/minimap2/releases/download/v2.24/minimap2-2.24_x64-linux.tar.bz2" \
    && tar -jxf minimap2-2.24_x64-linux.tar.bz2 \
    && cp minimap2-2.24_x64-linux/minimap2 /usr/local/bin

# Install samtools 1.9
RUN git clone --branch ${SAMTOOLS_VERSION} --single-branch https://github.com/samtools/samtools.git && \
    git clone --branch ${SAMTOOLS_VERSION} --single-branch https://github.com/samtools/htslib.git && \
    cd samtools && make && make install && cd ../ && rm -rf samtools* htslib*

RUN pip uninstall -y --quiet seqspec        
RUN pip install --quiet git+https://github.com/IGVF/seqspec.git 
RUN pip install --quiet gget kb-python 

# Create and setup new user
#ENV USER=igvf
#WORKDIR /home/$USER

#RUN groupadd -r $USER &&\
 #   useradd -r -g $USER --home /home/$USER -s /sbin/nologin -c "Docker image user" $USER &&\
  #  chown $USER:$USER /home/$USER

#COPY --chown=$USER:$USER src/bash/monitor_script.sh /usr/local/bin
COPY src/bash/monitor_script.sh /usr/local/bin

USER $USER
