# FPGA Programming

This repository contains the code for three miniprojects : Median Filter (./median), Memory Controller (./controleur_memoire), and a Video Controller (./controleur_video). 

Those projects main objective is to learn how to program an FPGA using VHDL, and to communicate with peripherals using an avalon bus.

### Main Objectives

* Learn how to program an FPGA using SystemVerilog.
* Learn how to use an Avalon bus to communicate with peripherals : successfully programming an avalon master and slave.
* Simulate and test the designs using Quartus.

## Project Context

This project is part of the course **"Reconfigurable architectures and HDL languages"** at Télécom Paris, second year, Embedded Systems major.

The project was created and supervised by Prof. Tarik Graba, and Prof. Yves Mathieu.

The project was carried out by a team of 2 students: Said Agouzal and myself.

## Executing the Program

The three projects were designed to be run on a DE10-Nano, that groupes a classical FPGA architecture with HPS (Hard Processor System) based on an ARM Cortex-A9 double processor.

For the Median Filter :

1. First simulate it using :

```bash
cd median
cd simulation
vlib work
vlog +acc ../src/test_(MCE/MED/MEDIAN).sv
vsim
```
