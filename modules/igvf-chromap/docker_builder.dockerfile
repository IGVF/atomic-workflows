############################################################
# Dockerfile for the kallisto-bustool module task in the
# IGVF single-cell pipeline.
# Based on Python
############################################################

FROM --platform="linux/amd64" python:3.10-slim



############################################################
# Dockerfile for chromap
# Based on Debian slim
############################################################

FROM debian@sha256:3ecce669b6be99312305bc3acc90f91232880c68b566f257ae66647e9414174f AS builder

# To prevent time zone prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV CHROMAP_VERSION=0.2.7

# Install softwares from apt repo
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    liblz4-dev \
    liblzma-dev \
    libncurses5-dev \
    libbz2-dev \
    unzip \
    wget \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Make directory for all softwares
RUN mkdir /software
WORKDIR /software
ENV PATH="/software:${PATH}"

RUN wget https://github.com/haowenz/chromap/archive/refs/tags/v${CHROMAP_VERSION}.zip && unzip v${CHROMAP_VERSION}.zip && \
    mv chromap-${CHROMAP_VERSION} chromap && cd chromap && make STATIC_BUILD=1


FROM --platform="linux/amd64" python:3.10-slim

LABEL maintainer="Eugenio Mattei"
LABEL software="IGVF single-cell pipeline"
LABEL software.version="1"
LABEL software.organization="IGVF consortium"
LABEL software.version.is-production="Yes"
LABEL software.task="run-chromap-module"
LABEL software.description="Run the chromap module of the IGVF single-cell pipeline"
# Install softwares from apt repo
RUN apt-get update && apt-get install -y \
    samtools \
    tabix \
    python3 \
    gcc \
    pigz && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /software
COPY run_chromap.py /software
COPY pyproject.toml /software
RUN cd /software && python3 -m pip install --upgrade pip && python3 -m pip install --editable .

# Create and setup new user
ENV USER=igvf
WORKDIR /home/$USER

RUN groupadd -r $USER &&\
    useradd -r -g $USER --home /home/$USER -s /sbin/nologin -c "Docker image user" $USER &&\
    chown $USER:$USER /home/$USER

# Add folder with software to the path
ENV PATH="/software/:${PATH}"

# Copy the compiled software from the builder
COPY --from=builder --chown=$USER:$USER /software/chromap /software/
COPY --from=builder --chown=$USER:$USER /usr/include/* /usr/include/
COPY --from=builder --chown=$USER:$USER /usr/local/include/* /usr/local/include/

USER $USER
