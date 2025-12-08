FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_ARCH_LIST="8.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

# --------------------------------------------------------
# 1. Base system packages
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev python3-venv python-is-python3 \
    vim git tmux wget curl ca-certificates openssh-server nginx \
    ninja-build pkgconf \
    libxcb1-dev libx11-dev libgl1-mesa-glx libgl-dev libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Make python/pip the default commands
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# --------------------------------------------------------
# 2. CMake
# --------------------------------------------------------
RUN mkdir ~/temp && \
    cd ~/temp && \
    wget -nv https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-linux-x86_64.sh && \
    mkdir /opt/cmake && \
    sh cmake-4.1.2-linux-x86_64.sh --prefix=/usr/local --skip-license && \
    cmake --version

# --------------------------------------------------------
# 3. PyTorch 2.8.0 + CUDA 12.8 и fVDB
#    https://fvdb.ai/installation.html#pytorch-2-8-0-cuda-12-8
# --------------------------------------------------------
RUN pip install --upgrade pip setuptools wheel && \
    pip install \
      fvdb-reality-capture \
      fvdb-core==0.3.0+pt28.cu128 \
      --extra-index-url="https://d36m13axqqhiit.cloudfront.net/simple" \
      torch==2.8.0 \
      --extra-index-url https://download.pytorch.org/whl/cu128

# --------------------------------------------------------
# 4. JupyterLab
# --------------------------------------------------------
RUN pip install jupyterlab

# --------------------------------------------------------
# 5. Clone fvdb-core for examples/notebooks
# --------------------------------------------------------
WORKDIR /workspace
RUN git clone https://github.com/openvdb/fvdb-core.git /workspace/fvdb-core

# --------------------------------------------------------
# 6. Start Script
# --------------------------------------------------------
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /workspace
CMD ["/start.sh"]
