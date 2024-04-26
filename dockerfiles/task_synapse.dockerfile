############################################################
# Dockerfile for IGVF single-cell pipeline task synapse
# Based on Debian slim
############################################################

# Use a Python base image
FROM python:3.11-slim-bullseye

LABEL maintainer = "Siddarth Wekhande"
LABEL software = "IGVF single-cell pipeline"
LABEL software.version="0.0.1"
LABEL software.organization="IGVF"
LABEL software.version.is-production="No"
LABEL software.task="task_synapse"

RUN pip install wget

# Install synapseclient package
RUN pip install synapseclient==2.7.2

# Mount the Docker secret containing the Synapse token
RUN --mount=type=secret,id=synapse_token TOKEN=$(cat /run/secrets/synapse_token) && \
synapse login -p $TOKEN --remember-me

# docker must be built locally using command: 
# docker build -t your_image_name -f /path/to/dockerfile \
#--secret id=synapse_token,src=/path/to/synapse_token .