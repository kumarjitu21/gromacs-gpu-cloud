#!/bin/bash
set -e  # Stop on error
echo "🚀 Starting GROMACS GPU installation on AWS G5 instance..."

# 1️⃣ Update system
sudo apt update && sudo apt upgrade -y

# 2️⃣ Install build essentials & dependencies
sudo apt install -y build-essential gcc g++ cmake git pkg-config \
    libfftw3-dev libopenmpi-dev openmpi-bin wget

# 3️⃣ Install NVIDIA drivers
echo "🔧 Installing NVIDIA drivers..."
sudo apt install -y nvidia-driver-535 nvidia-dkms-535

# 4️⃣ Install CUDA Toolkit 12.2
echo "🔧 Installing CUDA Toolkit..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/ /"
sudo apt update
sudo apt install -y cuda-toolkit-12-2

# 5️⃣ Export CUDA environment
echo 'export PATH=/usr/local/cuda-12.2/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# 6️⃣ Check NVIDIA and CUDA
echo "🖥 Checking NVIDIA GPU and CUDA..."
nvidia-smi
nvcc --version

# 7️⃣ Clone GROMACS
echo "📥 Cloning GROMACS repository..."
cd ~
git clone https://github.com/gromacs/gromacs.git
cd gromacs
mkdir -p build && cd build

# 8️⃣ Configure build with CMake (GPU enabled)
echo "⚙️ Configuring GROMACS with GPU support..."
cmake .. \
    -DGMX_GPU=CUDA \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
    -DGMX_MPI=ON \
    -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_DOUBLE=OFF

# 9️⃣ Compile and install
echo "💻 Building GROMACS (this may take 20-30 min depending on CPU cores)..."
make -j$(nproc)
sudo make install

# 1️⃣0️⃣ Add GROMACS to PATH
echo 'export PATH=/usr/local/gromacs/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 1️⃣1️⃣ Verify installation
echo "✅ GROMACS installation complete. Verify by running:"
echo "gmx --version"
