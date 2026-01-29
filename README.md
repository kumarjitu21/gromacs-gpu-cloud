# GROMACS GPU Cloud Computing

A comprehensive repository for running GROMACS molecular dynamics simulations with GPU acceleration on cloud platforms. This repository provides scripts and configurations for deploying GROMACS on AWS EC2 and Azure Machine Learning platforms.

## 🎯 Overview

This repository contains cloud-optimized scripts and configurations to:
- Install GROMACS with GPU support on cloud instances
- Run molecular dynamics simulations with GPU acceleration
- Deploy GROMACS jobs on AWS EC2 and Azure ML platforms
- Optimize performance and cost for cloud-based MD simulations

## 📁 Repository Structure

```
gromacs-gpu-cloud/
├── aws/                    # AWS EC2 deployment scripts
│   ├── install_gromacs_gpu.sh    # Automated GROMACS installation script
│   ├── run_md_aws.sh             # Script to run MD simulations on AWS
│   └── README.md                 # AWS-specific documentation
├── azure-ml/               # Azure Machine Learning deployment
│   ├── run_md.sh                 # Script to run MD simulations on Azure ML
│   ├── gromacs-job.yml           # Azure ML job configuration
│   └── README.md                 # Azure ML-specific documentation
├── .gitignore              # Git ignore patterns
└── README.md               # This file
```

## 🚀 Quick Start

### AWS EC2 Deployment

1. **Launch an AWS G5 instance** (Ubuntu 24.04 LTS)
2. **Install GROMACS**:
   ```bash
   cd aws
   chmod +x install_gromacs_gpu.sh
   ./install_gromacs_gpu.sh
   ```
3. **Run simulations**:
   ```bash
   chmod +x run_md_aws.sh
   ./run_md_aws.sh
   ```

For detailed AWS instructions, see [aws/README.md](aws/README.md).

### Azure ML Deployment

1. **Configure Azure ML workspace**
2. **Submit job** using the provided YAML configuration
3. **Monitor** job execution in Azure ML portal

For detailed Azure ML instructions, see [azure-ml/README.md](azure-ml/README.md).

## 🔧 Features

### AWS EC2
- ✅ Automated installation of GROMACS with CUDA GPU support
- ✅ NVIDIA driver and CUDA Toolkit 12.2 setup
- ✅ Optimized for G5 instance types (g5.xlarge, g5.2xlarge, etc.)
- ✅ GPU-accelerated MD simulation execution
- ✅ Cost-effective cloud computing for MD simulations

### Azure ML
- ✅ YAML-based job configuration
- ✅ Integration with Azure ML compute clusters
- ✅ GPU-enabled compute targets
- ✅ Scalable job submission and monitoring

## 📋 Prerequisites

### AWS EC2
- AWS account with EC2 access
- G5 instance type (GPU-enabled)
- Ubuntu 24.04 LTS AMI
- SSH access with sudo privileges

### Azure ML
- Azure subscription
- Azure Machine Learning workspace
- GPU-enabled compute target

## 💻 Usage Examples

### Running MD Simulation on AWS

```bash
# After installation, run your simulation
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1
gmx mdrun -deffnm MD -nb gpu -v
```

### Key GROMACS Commands

- **Check version**: `gmx --version`
- **Verify GPU**: `nvidia-smi`
- **Run simulation**: `gmx mdrun -deffnm <prefix> -nb gpu -v`
- **Monitor GPU**: `watch -n 1 nvidia-smi`

## 💰 Cost Optimization Tips

1. **Use Spot Instances**: Save up to 90% on AWS EC2 costs
2. **Right-size Instances**: Choose instance type based on simulation size
3. **Auto-shutdown**: Configure instances to stop when idle
4. **Batch Processing**: Group multiple simulations to maximize utilization
5. **Monitor Usage**: Track GPU utilization to optimize instance selection

## 🔍 What Gets Installed

### System Components
- Build tools (gcc, g++, cmake)
- NVIDIA drivers (version 535)
- CUDA Toolkit 12.2
- OpenMPI for parallel execution
- FFTW libraries

### GROMACS Configuration
- GPU acceleration via CUDA
- MPI parallelization support
- Single precision build (faster, less memory)
- Optimized for cloud GPU instances

## 🐛 Troubleshooting

### Common Issues

**GPU not detected**
- Verify instance type has GPU support
- Check NVIDIA driver installation: `nvidia-smi`
- Reboot instance if needed

**CUDA not found**
- Verify CUDA paths: `echo $PATH | grep cuda`
- Reload environment: `source ~/.bashrc`

**Build failures**
- Check disk space: `df -h`
- Verify memory: `free -h`
- Review installation logs

For platform-specific troubleshooting, refer to the respective README files.

## 📚 Resources

- [GROMACS Documentation](https://manual.gromacs.org/)
- [AWS EC2 G5 Instances](https://aws.amazon.com/ec2/instance-types/g5/)
- [Azure Machine Learning](https://azure.microsoft.com/services/machine-learning/)
- [CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/)

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Scripts are tested on respective cloud platforms
- Documentation is updated
- Code follows existing style conventions

## 📝 License

This repository is provided as-is for educational and research purposes.

## 🔄 Version Information

- **GROMACS**: Latest from GitHub repository
- **CUDA**: 12.2
- **NVIDIA Driver**: 535
- **Ubuntu**: 24.04 LTS

## 📧 Support

For issues or questions:
1. Check the platform-specific README files
2. Review troubleshooting sections
3. Consult GROMACS and cloud provider documentation

---

**Note**: Always ensure you have proper input files (`.tpr`, `.gro`, `.mdp`) prepared before running simulations. Monitor GPU utilization and instance costs regularly to optimize your cloud computing expenses.
