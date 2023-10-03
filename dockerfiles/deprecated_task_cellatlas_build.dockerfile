# Use a base image with Python
FROM python:3.9-slim-buster

# Install wget, tar, and other basic utilities
RUN apt-get update && apt-get install -y wget tar make g++ autoconf cmake git

# Install tree
RUN wget --quiet ftp://mama.indstate.edu/linux/tree/tree-2.1.0.tgz \
    && tar -xf tree-2.1.0.tgz \
    && cd tree-2.1.0 \
    && make -j16 \
    && make install

# Install jq
RUN wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x jq-linux64 \
    && mv jq-linux64 /usr/local/bin/jq

# Install cellatlas
RUN git clone https://github.com/cellatlas/cellatlas.git \
    && cd cellatlas \
    && python3 -m pip install --break-system-packages .

# Install kb-python
RUN pip install kb-python

# Install minimap
RUN wget --quiet "https://github.com/lh3/minimap2/releases/download/v2.24/minimap2-2.24_x64-linux.tar.bz2" \
    && tar -jxf minimap2-2.24_x64-linux.tar.bz2 \
    && cp minimap2-2.24_x64-linux/minimap2 /usr/local/bin

# Install samtools
RUN wget --quiet https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 \
    && tar -jxf samtools-1.17.tar.bz2 \
    && cd samtools-1.17/ \
    && ./configure --prefix=$(pwd) \
    && make \
    && make install \
    && cp samtools-1.17/samtools /usr/local/bin

# Install Genrich
RUN git clone https://github.com/jsh58/Genrich.git \
    && cd Genrich \
    && make \
    && cp Genrich /usr/local/bin

# Install bedtools
RUN wget --quiet https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary \
    && chmod +x bedtools.static.binary \
    && mv bedtools.static.binary /usr/local/bin/bedtools

# Install kallisto and bustools
RUN git clone https://github.com/pachterlab/kallisto \
    && cd kallisto \
    && git checkout shareseq \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && cp src/kallisto /usr/local/bin \
    && cp src/kallisto $(pip show kb-python | grep "Location" | cut -f2 -d":")/kb_python/bins/linux/kallisto/kallisto \
    && cp $(pip show kb-python | grep "Location" | cut -f2 -d":")/kb_python/bins/linux/bustools/bustools /usr/local/bin
