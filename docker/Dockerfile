# Create a working directory
FROM nvidia/cuda:11.1.1-devel-ubuntu20.04

# ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe
ARG HOST_UNAME
ARG HOST_UID
ARG HOST_GID

# Install some basic utilities
RUN rm -f /etc/apt/sources.list.d/*.list \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone\
    && apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    ffmpeg \
    libsm6 \
    libxext6 \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /deps

COPY docker/inputrc /root/.inputrc

SHELL ["/bin/bash", "-c"]

RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh
    
ENV PATH=/opt/conda/bin:$PATH


# bootstrap conda
RUN source /opt/conda/etc/profile.d/conda.sh \
    && conda activate base \
    && conda update -n base conda -y \
    && conda install python=3.8 \
    && python --version \
    && source /opt/conda/etc/profile.d/conda.sh \
    && conda init bash \
    && conda config --set auto_activate_base true

ENV FORCE_CUDA="1"

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# We use cuda-11.1 by default
RUN conda install cudatoolkit=11.1.1 -c conda-forge --yes \
&& pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# Install python packages
RUN pip3 install -U pip && pip3 install -U setuptools==59.5.0

# install mmdet universe
ARG MMCV="1.7.0"
ARG MMDET="2.28.0"
ARG MMSEG="0.30.0"
ARG MMDET3D="1.0.0rc6"


# install deps in dev mode (for developement / debugging)
RUN cd /deps \
    && git clone https://github.com/open-mmlab/mmcv.git \
    && cd mmcv \
    && git checkout tags/v${MMCV} \
    && MMCV_WITH_OPS=1 pip install -e .

RUN cd /deps \
    && git clone https://github.com/open-mmlab/mmdetection.git \
    && cd mmdetection \
    && git checkout tags/v${MMDET} \
    && pip install -e .

RUN cd /deps \
    && git clone https://github.com/open-mmlab/mmsegmentation.git \
    && cd mmsegmentation \
    && git checkout tags/v${MMSEG} \
    && pip install -e .

RUN cd /deps \
    && git clone https://github.com/open-mmlab/mmdetection3d.git \
    && cd mmdetection3d \
    && git checkout tags/v${MMDET3D} \
    && pip install scipy==1.7.3 \
    && pip install scikit-image==0.20.0 \
    && pip install -v -e .

# new versions of yapf cause issues with mmcv config -> pin
RUN pip install flash-attn==0.2.2 ipython \
    && pip install yapf==0.40.1 \
    && pip install wandb

# add user of current host system
RUN groupadd -g ${HOST_GID} -o ${HOST_UNAME}
RUN useradd -l -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash ${HOST_UNAME}

# make sure conda env is always active on startup there as well
USER ${HOST_UNAME}


RUN source /opt/conda/etc/profile.d/conda.sh \
    && conda init bash \
    && conda config --set auto_activate_base true

# switch back to root as default user
USER root

# copy inputrc to user for a nicer bash experience
RUN cp /root/.inputrc /home/${HOST_UNAME}/.inputrc \
    && chown ${HOST_UNAME}:${HOST_GID} /home/${HOST_UNAME}/.inputrc

WORKDIR /workspace