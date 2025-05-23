############################################################
# Dockerfile for the kallisto-bustool module task in the
# IGVF single-cell pipeline.
# Based on Python
############################################################

FROM python:3.10.16-slim

LABEL maintainer="Eugenio Mattei"
LABEL software="IGVF single-cell pipeline"
LABEL software.version="1.1"
LABEL software.organization="IGVF consortium"
LABEL software.version.is-production="Yes"
LABEL software.task="run-kallisto-bustools-module"
LABEL software.description="Run the kallisto-bustools module of the IGVF single-cell pipeline"

RUN mkdir /software
COPY docs/README.md /software
COPY run_kallisto.py /software
COPY pyproject.toml /software
RUN cd /software && pip install --upgrade pip && pip install --editable .

# Create and setup new user
ENV USER=igvf
WORKDIR /home/$USER

RUN groupadd -r $USER &&\
    useradd -r -g $USER --home /home/$USER -s /sbin/nologin -c "Docker image user" $USER &&\
    chown $USER:$USER /home/$USER

USER ${USER}

