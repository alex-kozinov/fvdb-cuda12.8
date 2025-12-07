FROM nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04

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

# Install CMake
RUN mkdir ~/temp && \
cd ~/temp && \
wget -nv https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-linux-x86_64.sh && \
mkdir /opt/cmake && \
sh cmake-4.1.2-linux-x86_64.sh --prefix=/usr/local --skip-license && \
cmake --version

# --------------------------------------------------------
# 2. Install PyTorch with CUDA 12.1 support
# --------------------------------------------------------
RUN pip install --upgrade pip setuptools wheel
RUN pip install "torch>=2.3" torchvision --index-url https://download.pytorch.org/whl/cu121


# --------------------------------------------------------
# 3. Install JupyterLab
# --------------------------------------------------------
RUN pip install jupyterlab

# --------------------------------------------------------
# 4. Clone some project repository
# --------------------------------------------------------
WORKDIR /workspace

# --------------------------------------------------------
# 5. Install project dependencies
# --------------------------------------------------------


# --------------------------------------------------------
# 6. Default working directory and entrypoint
# --------------------------------------------------------
# Start Script
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh
WORKDIR /workspace
CMD ["/start.sh"]
