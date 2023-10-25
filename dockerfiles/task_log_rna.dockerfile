############################################################
# Dockerfile for IGVF pipeline
# Based on Debian slim
############################################################

FROM debian@sha256:3ecce669b6be99312305bc3acc90f91232880c68b566f257ae66647e9414174f

LABEL maintainer = "Siddarth Wekhande"
LABEL software = "IGVF pipeline"
LABEL software.version="0.0.1"
LABEL software.organization="Broad Institute of MIT and Harvard"
LABEL software.version.is-production="No"
LABEL software.task="log-rna"

RUN apt-get update && apt-get install -y \
    jq 