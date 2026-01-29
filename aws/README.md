# GROMACS GPU Installation on AWS

This directory contains scripts for installing and running GROMACS with GPU acceleration on AWS EC2 instances, specifically optimized for G5 instances with NVIDIA GPUs.

## 📋 Prerequisites

- **AWS EC2 Instance**: G5 instance type (e.g., `g5.xlarge`, `g5.2xlarge`, `g5.4xlarge`)
- **Operating System**: Ubuntu 24.04 LTS
- **Instance Access**: SSH access with sudo privileges
- **Storage**: At least 20GB free space for installation

## 🚀 Quick Start

### 1. Launch an AWS G5 Instance

1. Log in to AWS Console
2. Launch an EC2 instance:
   - **Instance Type**: `g5.xlarge` or larger (for GPU support)
   - **AMI**: Ubuntu Server 24.04 LTS
   - **Storage**: Minimum 30GB
   - **Security Group**: Ensure SSH (port 22) access is enabled

### 2. Install GROMACS with GPU Support

SSH into your instance and run:

```bash
# Clone the repository or upload the script
git clone <your-repo-url>
cd gromacs-gpu-cloud/aws

# Make the script executable
chmod +x install_gromacs_gpu.sh

# Run the installation script
./install_gromacs_gpu.sh
```

**Note**: The installation process takes approximately 20-30 minutes depending on your instance CPU cores.

### 3. Verify Installation

After installation completes, verify GROMACS is installed correctly:

```bash
# Check GROMACS version
gmx --version

# Verify GPU detection
nvidia-smi

# Check CUDA availability
nvcc --version
```

## 📦 What Gets Installed

The `install_gromacs_gpu.sh` script installs:

- **System Dependencies**:
  - Build essentials (gcc, g++, cmake)
  - FFTW3 libraries
  - OpenMPI for parallel execution
  - Git and other build tools

- **NVIDIA Drivers**:
  - NVIDIA driver version 535
  - NVIDIA DKMS modules

- **CUDA Toolkit**:
  - CUDA Toolkit 12.2
  - CUDA compiler (nvcc)
  - CUDA libraries

- **GROMACS**:
  - Latest GROMACS from GitHub
  - Built with GPU support (CUDA)
  - MPI support enabled
  - FFTW support enabled
  - Single precision (GMX_DOUBLE=OFF)

## 🔧 Configuration Details

The GROMACS build is configured with:
- `GMX_GPU=CUDA` - GPU acceleration via CUDA
- `GMX_MPI=ON` - MPI parallelization support
- `GMX_BUILD_OWN_FFTW=ON` - Build FFTW internally
- `GMX_DOUBLE=OFF` - Single precision (faster, less memory)

## 🏃 Running Molecular Dynamics Simulations

After installation, use `run_md_aws.sh` to run your MD simulations:

```bash
# Make the script executable
chmod +x run_md_aws.sh

# Run your simulation
./run_md_aws.sh
```

### Running MD Simulations Directly

You can also run GROMACS MD simulations directly with GPU acceleration:

```bash
# Disable GPU compatibility check (useful for compatibility issues)
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1

# Run MD simulation with GPU acceleration
# -deffnm MD: uses MD.tpr, MD.gro, MD.mdp files
# -nb gpu: use GPU for non-bonded interactions
# -v: verbose output
gmx mdrun -deffnm MD -nb gpu -v
```

**Note**: Ensure you have prepared your GROMACS input files (`.tpr`, `.gro`, `.mdp`, etc.) before running simulations. The `-deffnm MD` flag expects files named `MD.tpr` (topology), `MD.gro` (structure), and `MD.mdp` (parameters).

## 💰 Cost Considerations

- **G5.xlarge**: ~$1.00/hour (1 GPU, 4 vCPUs, 16GB RAM)
- **G5.2xlarge**: ~$1.50/hour (1 GPU, 8 vCPUs, 32GB RAM)
- **G5.4xlarge**: ~$2.50/hour (1 GPU, 16 vCPUs, 64GB RAM)

**Tip**: Stop or terminate instances when not in use to minimize costs.

## 🐛 Troubleshooting

### GPU Not Detected
```bash
# Check if NVIDIA driver is loaded
nvidia-smi

# If not, reboot the instance
sudo reboot
```

### CUDA Not Found
```bash
# Verify CUDA paths are set
echo $PATH | grep cuda
echo $LD_LIBRARY_PATH | grep cuda

# If missing, reload bashrc
source ~/.bashrc
```

### Build Failures
- Ensure you have sufficient disk space: `df -h`
- Check available memory: `free -h`
- Review build logs for specific error messages

### Permission Issues
- Ensure scripts are executable: `chmod +x *.sh`
- Use `sudo` when required by the installation script

## 📚 Additional Resources

- [GROMACS Documentation](https://manual.gromacs.org/)
- [AWS EC2 G5 Instances](https://aws.amazon.com/ec2/instance-types/g5/)
- [CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/)
- [NVIDIA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html)

## 🔄 Next Steps

1. Prepare your molecular dynamics input files
2. Upload your simulation files to the instance
3. Run simulations using `run_md_aws.sh`
4. Monitor GPU utilization with `nvidia-smi`
5. Download results and terminate the instance to save costs

## 📝 Notes

- The installation script modifies `~/.bashrc` to add CUDA and GROMACS to PATH
- A system reboot may be required after NVIDIA driver installation
- For production workloads, consider using AWS Batch or ECS for job scheduling
- Consider using spot instances for cost savings on long-running simulations
