# Linux and GROMACS Universal Tutorial

A comprehensive guide for setting up Ubuntu, installing GROMACS (and related tools), and running a full molecular dynamics workflow from system preparation through analysis.

---

## Table of Contents

1. [Install and Update Ubuntu](#1-install-ubuntu--system-update)
2. [GROMACS Installation Options](#2-gromacs-installation-options)
3. [Additional Software](#3-additional-software)
4. [Manual GROMACS Compilation](#4-manual-gromacs-compilation)
5. [Molecular Dynamics Workflow](#5-molecular-dynamics-workflow)
6. [Trajectory Analysis](#6-trajectory-analysis)

---

## 1. Install Ubuntu & System Update

Upgrade and update libraries before installing GROMACS or other software.

### Commands

```bash
sudo apt update
sudo apt upgrade
sudo apt install gcc
sudo apt install cmake
sudo apt install build-essential
sudo apt install libfftw3-dev
# OR
sudo apt-get install -y libfftw3-dev
```

Once the above commands complete and the system is updated, proceed to install GROMACS.

---

## 2. GROMACS Installation Options

### Quick (package) installation

```bash
sudo apt install gromacs
```

To remove:

```bash
sudo apt remove gromacs
```

**Note:** For GPU support and latest features, use [manual compilation](#4-manual-gromacs-compilation) or the cloud scripts in `aws/install_gromacs_gpu.sh`.

---

## 3. Additional Software

### PyMOL

```bash
sudo apt-get install -y pymol
```

### Google Chrome

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

### Chimera

1. Download the installer from [Chimera Download](https://www.cgl.ucsf.edu/chimera/download.html).
2. Move the file to the desired folder and open a terminal in that folder.

```bash
ls                                    # Check the name of the setup file
chmod +x CHIMERA-INSTALLER.bin        # Replace with actual filename
./CHIMERA-INSTALLER.bin
```

### AutoDock Vina

1. Go to [AutoDock Vina Download](http://vina.scripps.edu/download.html).
2. Move the file to the desired folder and open a terminal there.

```bash
ls                                    # Check the name of the setup file
tar -xzvf autodock_vina_1_1_2_linux_x86.tgz
```

### Grace (plotting)

```bash
sudo apt-get install grace
```

### VMD

1. Download from [VMD Download](https://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD).
2. Save the `.tar.gz` file in your working folder.
3. Extract, then in the extracted folder run:

```bash
./configure
```

4. In the `src` folder:

```bash
sudo make install
```

5. Run VMD:

```bash
vmd
```

---

## 4. Manual GROMACS Compilation

For GPU support and control over build options, compile GROMACS manually.

### Prerequisites

- **GROMACS source:** [GROMACS Download](https://manual.gromacs.org/current/download.html)
- **CUDA Toolkit:** [NVIDIA CUDA Downloads](https://developer.nvidia.com/cuda-downloads) — follow the steps and use the provided commands for your system.

### Compilation steps

```bash
tar xfz gromacs-2020.2.tar.gz
cd gromacs-2020.2
mkdir build
cd build
cmake .. -DGMX_GPU=CUDA -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
make
make check
sudo make install
source /usr/local/gromacs/bin/GMXRC
```

**Note:** For cloud GPU instances, see `aws/install_gromacs_gpu.sh` for an automated build with CUDA.

---

## 5. Molecular Dynamics Workflow

### 5.1 Prepare ligand and receptor in Chimera

1. Open the best pose ligand with the receptor `Protein.pdb`.
2. Delete the protein chain; on the remaining ligand, add hydrogens and save as `LIG.mol2`.

#### Corrections in LIG.mol2

Open `LIG.mol2` in a text editor (e.g. `gedit`).

- **2.1** Ensure `@<TRIPOS>MOLECULE` is the first line; remove any extra header or blank lines.
- **2.2** On the line after `@<TRIPOS>MOLECULE`, change the molecule name to `LIG` (replace any other name).
- **2.3** Bond orders under `@<TRIPOS>BOND` can cause errors if unsorted. Sort them:

  ```bash
  perl sort_mol2_bonds.pl LIG.mol2 LIG.mol2
  ```

3. Go to [SwissParam](http://www.swissparam.ch/) and upload `LIG.mol2`.
4. Download the generated `.zip` file.
5. In Chimera: open best pose ligand with receptor, delete the ligand, run **DockPrep** on the protein, and save as `REC.pdb`.
6. Create a working folder for GROMACS; copy the contents of the SwissParam zip and the `REC.pdb` into it.
7. Copy all required `.mdp` files into this working folder.
8. Open a terminal in this folder for the following GROMACS steps.

### 5.2 GROMACS setup (Ubuntu tutorial)

Source GROMACS (only if manually compiled; not needed for `apt install`):

```bash
source /usr/local/gromacs/bin/GMXRC
```

#### System building

```bash
gmx pdb2gmx -f REC.pdb -ignh
# Choose: 8 (CHARMM27), 1 (TIP3P)

gmx editconf -f LIG.pdb -o LIG.gro
gedit conf.gro LIG.gro
```

- Copy from the 3rd line of `LIG.gro` into `conf.gro` up to the second-to-last line.
- In `conf.gro`, check the column where the `LIG.gro` data ends (e.g. value **x**), and set the value in the 2nd line to **x - 3**.
- Optionally open the file in Chimera to verify ligand and receptor.

#### Edit topol.top

```bash
gedit topol.top
```

- After `#include "amberGS.ff/forcefield.itp"` (or your forcefield), add:

  ```
  ; Include ligand topology
  #include "LIG.itp"
  ```

- At the bottom of the file, under the molecule count line (e.g. `Protein_chain_E     1`), add:

  ```
  LIG 1
  ```
  (aligned with the protein line.)

#### Edit LIG.itp

```bash
gedit lig.itp
```

- In `[ moleculetype ]`, change the name from `lig_gmx2` to `LIG` (if not already `LIG`):

  ```
  [ moleculetype ]
  ; Name    nrexcl
  LIG       3
  ```

#### Box, solvation, and ions

```bash
gmx editconf -f conf.gro -d 1.0 -bt triclinic -o box.gro
gmx solvate -cp box.gro -cs spc216.gro -p topol.top -o box_sol.gro
gmx grompp -f ions.mdp -c box_sol.gro -p topol.top -o ION.tpr
# OR if you need to allow warnings:
gmx grompp -f ions.mdp -c box_sol.gro -maxwarn 2 -p topol.top -o ION.tpr

gmx genion -s ION.tpr -p topol.top -conc 0.1 -neutral -o box_sol_ion.gro
# Choose group 15 (SOL) for ion replacement
```

#### Energy minimization

```bash
gmx grompp -f EM.mdp -c box_sol_ion.gro -p topol.top -o EM.tpr
# OR
gmx grompp -f EM.mdp -c box_sol_ion.gro -maxwarn 2 -p topol.top -o EM.tpr

gmx mdrun -v -deffnm EM
```

#### Index and position restraints for ligand

```bash
gmx make_ndx -f LIG.gro -o index_LIG.ndx
# > 0 & ! a H*
# > q

gmx genrestr -f LIG.gro -n index_LIG.ndx -o posre_LIG.itp -fc 1000 1000 1000
# Select group "3"
```

Edit `topol.top`: after the protein position restraint block:

```
; Include Position restraint file
#ifdef POSRES
#include "posre.itp"
#endif
```

add:

```
; Ligand position restraints
#ifdef POSRES
#include "posre_LIG.itp"
#endif
```

#### System index for NVT/NPT/MD

```bash
gmx make_ndx -f EM.gro -o index.ndx
# > 1 | 13
# > q
```

### 5.3 NVT (constant volume)

```bash
gedit NVT.mdp   # Use or adjust as needed

gmx grompp -f NVT.mdp -c EM.gro -r EM.gro -p topol.top -n index.ndx -maxwarn 2 -o NVT.tpr
gmx mdrun -deffnm NVT
```

### 5.4 NPT (constant pressure)

```bash
gedit NPT.mdp   # Use or adjust as needed

gmx grompp -f NPT.mdp -c NVT.gro -r NVT.gro -p topol.top -n index.ndx -maxwarn 2 -o NPT.tpr
gmx mdrun -deffnm NPT
```

### 5.5 Production MD run

```bash
gedit MD.mdp   # Set MD run time as needed

gmx grompp -f MD.mdp -c NPT.gro -t NPT.cpt -p topol.top -n index.ndx -maxwarn 2 -o MD.tpr
gmx mdrun -deffnm MD
```

For GPU-accelerated run (e.g. on AWS):

```bash
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1
gmx mdrun -deffnm MD -nb gpu -v
```

---

## 6. Trajectory Analysis

### 6.1 Recentering and rewrapping

```bash
gmx trjconv -s MD.tpr -f MD.xtc -o MD_center.xtc -center -pbc mol -ur compact
# Choose "Protein" for centering and "System" for output
```

Extract first frame (t = 0 ns):

```bash
gmx trjconv -s MD.tpr -f MD_center.xtc -o start.pdb -dump 0
```

### 6.2 RMSD

```bash
gmx rms -s MD.tpr -f MD_center.xtc -o rmsd.xvg
gmx rms -s MD.tpr -f MD_center.xtc -o rmsd.xvg -tu ns
# Select groups 4 and 13 (e.g. Backbone and LIG)
```

View:

```bash
xmgrace rmsd.xvg
```

### 6.3 RMSF

```bash
gmx rmsf -s MD.tpr -f MD_center.xtc -o rmsf.xvg
# Select Backbone (e.g. 4)
```

```bash
xmgrace rmsf.xvg
```

### 6.4 Hydrogen bonds

```bash
gmx hbond -s MD.tpr -f MD_center.xtc -num hb.xvg
gmx hbond -s MD.tpr -f MD_center.xtc -num hb.xvg -tu ns
# Select groups 1 and 13
```

```bash
xmgrace hb.xvg
```

### 6.5 Radius of gyration

```bash
gmx gyrate -s MD.tpr -f MD_center.xtc -o gyrate1.xvg
# Choose the group of your choice
```

```bash
xmgrace gyrate1.xvg
```

### 6.6 Energy terms

```bash
gmx energy -f MD.edr -o energy1.xvg
# Choose the energy term(s) of interest
```

```bash
xmgrace -nxy energy1.xvg
```

---

## See also

- **Cloud GPU setup:** [AWS README](../aws/README.md) for installation and running MD on AWS.
- **Root overview:** [Repository README](../README.md) for repository structure and quick start.
