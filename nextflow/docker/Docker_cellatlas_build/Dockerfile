# Use an official Miniconda3 as a parent image
FROM continuumio/miniconda3


RUN conda create -n cellatlas_env -y python=3.8  && \
  conda install -y -n cellatlas_env -c conda-forge jupyterlab tar tree jq && \
  conda install -y -n cellatlas_env -c anaconda wget git && \
  conda install -y -n cellatlas_env -c bioconda gget && \
  echo "conda activate cellatlas_env" >> ~/.bashrc


# Clone the cellatlas repo and install the package
RUN conda activate cellatlas_env && \
    git clone https://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@github.com/cellatlas/cellatlas.git > /dev/null && \
    cd cellatlas && \
    pip install --quiet . > /dev/null
#RUN git clone https://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@github.com/cellatlas/cellatlas.git > /dev/null
#RUN cd cellatlas && pip install --quiet . > /dev/null

# Install dependencies
RUN conda activate cellatlas_env && \
    yes | pip uninstall --quiet seqspec && \
    pip install --quiet git+https://github.com/IGVF/seqspec.git > /dev/null && \
    pip install --quiet gget kb-python > /dev/null
#RUN yes | pip uninstall --quiet seqspec
#RUN pip install --quiet git+https://github.com/IGVF/seqspec.git > /dev/null
# RUN pip install --quiet gget kb-python > /dev/null


# # FOR DEBUG on local machine
# Expose port 8888 for Jupyter Notebook
# EXPOSE 8888

# Start Jupyter Notebook on container startup
# CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

# OPTION 1: without wdl:
# 1. add the expose and the jupyter lab execution
# 2. docker build -t eilalan/cellatlas_env .
# 3. docker run -it -p 8888:8888 eilalan/cellatlas_env
# 4. docker push eilalan/cellatlas_env

# sudo docker build -t eilalan/chromap_env:latest -f Dockerfile_chromap .
# sudo docker run -it eilalan/chromap_env:latest bash
# sudo docker push eilalan/chromap_env:latest
