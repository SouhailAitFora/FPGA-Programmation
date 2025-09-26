# FPGA Programming

This repository contains the source code and testbenches for the 3 micro-projects of the lab *"Reconfigurable Architectures and HDL Languages"* (Télécom Paris): **MP1 — Median Filter**, **MP2 — Memory Controller (Avalon BRAM)**, and **MP3 — Video Controller**.

### Main Objectives

* Learn hardware design in SystemVerilog
* Implement Avalon interfaces (master/slave)
* Simulate with QuestaSim
* Synthesize and target a DE10‑Nano board (Cyclone V SoC)

## Project Context

The repository includes three consecutive mini-projects:

* **MP1 — Median Filter**: implement a hardware operator that, from 9 pixels (3×3 neighborhood), computes the median value. Focus is on designing a Compare-Exchange block (MCE), a MED operator, and the associated sequencer.
* **MP2 — Memory Controller (Avalon BRAM)**: implement an Avalon agent controlling an internal BRAM (simple transfer, then burst mode).
* **MP3 — Video Controller**: build a video controller that reads image memory via Avalon and drives a video output (targeting the DE10‑Nano board).

Authors & Credits:

* Project Creators and Supervisors : Prof. Tarik Graba and Prof. Yves Mathieu.
* Project team : Said Agouzal and Souhail (repo owner).

## Executing the Program

**Hardware**

* Target board: **DE10‑Nano** (Cyclone V SoC — FPGA + HPS).

**Software / Tools**

* QuestaSim (simulation) — testbenches and Makefile are written for these tools.
* Quartus Prime (synthesis / programming for DE10‑Nano).
* Yosys (synthesis tool).

### MP1 — Median Filter (`median`)

**Goal**: implement MCE, MED, and MEDIAN (median extraction from 9 sequentially received pixels).

**Simulation example**

```bash
cd median/simulation
vlib work
vlog +acc ../src/test_(MCE/MED/MEDIAN).sv
vsim test_(MCE/MED/MEDIAN)
```

**Synthesis / place & route**

```bash
cd median/synthese
make syn
make pr
vlog +acc ../src/test_(MCE/MED/MEDIAN).sv
vsim test_(MCE/MED/MEDIAN)
```

### MP2 — Memory Controller (`controleur_memoire`)

**Goal**: implement an Avalon agent controlling a synchronous BRAM.

**Simulation and Synthesis**

```bash
make compile       # compile sources + testbench
make simu_batch    # run simulation (batch)
make simu_gui      # run simulation with GUI
make exam_packets  # detailed examination of failed packets
make syn           # synthesis
make clean         # clean all builds
```

### MP3 — Video Controller (`controleur_video`)

**Goal**: build a video pipeline reading an image memory via Avalon and driving a video interface (display) on DE10‑Nano.

**Simulation and Synthesis**

```bash
#Simulation
cd SoCFPGA/sim
make simu_gui

#Synthesis
cd SoCFPGA/syn
make syn
```

**Test on FPGA**

```bash
cd SoCFPGA/syn
make program
```

## Project GIF

![GIF showing video on the DE10‑Nano](se203-gif.gif)