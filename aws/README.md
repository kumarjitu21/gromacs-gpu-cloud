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
# Clone the repository or upload the script (replace <repo-url> with your repository URL)
git clone <repo-url>
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

## 📤 Preparing Input Files

Before running MD simulations, you need to copy your GROMACS input files to the EC2 instance. Prepare your input files locally and then transfer them using `scp`.

**Generating input files:** For the full workflow to prepare ligand/receptor, build the system, and produce `MD.tpr` and related files, see the [Linux & GROMACS Universal Tutorial](../docs/LINUX_GROMACS_TUTORIAL.md).

### Required Input Files

- **MD.tpr**: Binary input file containing system topology and simulation parameters
- **MD.cpt**: Checkpoint file (if continuing from a previous simulation)
- **MD.gro**: Structure file (optional, if needed)
- **MD.mdp**: MD parameters file (if generating new .tpr file)

### Placeholders

Replace these with your own values (do not commit real values to the repo):

| Placeholder        | Description |
|--------------------|-------------|
| `<EC2-IP>`         | EC2 instance public IP or hostname |
| `<instance-user>` | SSH user (e.g. `ubuntu` for Ubuntu AMI, `ec2-user` for Amazon Linux) |
| `<remote-path>`   | Path on the instance (e.g. `/home/ubuntu/mdrun` or `/home/ec2-user/mdrun`) |
| `<your-key.pem>`  | Your SSH private key filename (keep keys out of the repo; use `.gitignore`) |

### Copying Files to EC2 Instance

From your local machine, use `scp` to copy files to the EC2 instance:

```bash
# Create the mdrun directory on the EC2 instance (if it doesn't exist)
ssh <instance-user>@<EC2-IP> "mkdir -p <remote-path>"

# Copy input files to the EC2 instance
scp MD.tpr MD.cpt <instance-user>@<EC2-IP>:<remote-path>/
```

**Note**: 
- If you have additional files (e.g., `MD.gro`, `MD.mdp`), include them in the `scp` command.
- Ensure your SSH key has proper permissions: `chmod 400 <your-key.pem>` (do not commit key files).

### Example with Additional Files

```bash
scp MD.tpr MD.cpt MD.gro MD.mdp <instance-user>@<EC2-IP>:<remote-path>/
```

### Using SSH Key File

If you use a specific SSH key file (replace with your key path; do not commit keys):

```bash
scp -i /path/to/<your-key.pem> MD.tpr MD.cpt <instance-user>@<EC2-IP>:<remote-path>/
```

### Verify Files Are Copied

```bash
ssh <instance-user>@<EC2-IP> "ls -lh <remote-path>/"
```

## 🏃 Running Molecular Dynamics Simulations

After copying your input files to the EC2 instance, navigate to the directory containing your files and run the simulation.

### Using the Run Script

```bash
# Navigate to the directory with your input files (use your <remote-path>)
cd <remote-path>

# Copy the run script to this directory (or navigate to where it is)
# Make the script executable
chmod +x run_md_aws.sh

# Run your simulation
./run_md_aws.sh
```

### Running MD Simulations Directly

You can also run GROMACS MD simulations directly with GPU acceleration:

```bash
# Navigate to the directory with your input files (use your <remote-path>)
cd <remote-path>

# Disable GPU compatibility check (useful for compatibility issues)
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1

# Run MD simulation with GPU acceleration
# -deffnm MD: uses MD.tpr, MD.gro, MD.mdp files
# -nb gpu: use GPU for non-bonded interactions
# -v: verbose output
gmx mdrun -deffnm MD -nb gpu -v
```

**Note**: 
- Ensure you have copied your input files to the EC2 instance before running simulations (see [Preparing Input Files](#-preparing-input-files) section)
- The `-deffnm MD` flag expects files named `MD.tpr` (topology/run input), `MD.cpt` (checkpoint), and optionally `MD.gro` (structure) and `MD.mdp` (parameters)
- Make sure you're in the correct directory where your input files are located

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

1. Prepare your molecular dynamics input files locally (`.tpr`, `.cpt`, `.gro`, `.mdp`)
2. Copy input files to the EC2 instance using `scp` (see [Preparing Input Files](#-preparing-input-files))
3. SSH into the instance and navigate to the directory with your files
4. Run simulations using `run_md_aws.sh` or directly with `gmx mdrun`
5. Monitor GPU utilization with `nvidia-smi` during simulation
6. Download results using `scp` and terminate the instance to save costs

## 📝 Notes

- The installation script modifies `~/.bashrc` to add CUDA and GROMACS to PATH
- A system reboot may be required after NVIDIA driver installation
- For production workloads, consider using AWS Batch or ECS for job scheduling
- Consider using spot instances for cost savings on long-running simulations
