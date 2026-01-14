# FPGA-Based Oscilloscope Waveform Display System

## 📌 Overview
Project about the design and implementation of an FPGA-based oscilloscope waveform
display system using Verilog HDL. The system is capable of generating, processing,
and displaying multiple waveform types in real time. All functionalities are
implemented entirely in hardware on FPGA without the use of a microcontroller.

## 🎯 Key Features
- Multiple waveform generation:
  - Sine wave
  - Triangle wave
  - Square wave
  - Sawtooth wave
  - ECG waveform
- Real-time waveform display on oscilloscope-style interface
- Adjustable waveform parameters:
  - Frequency control
  - Amplitude control
- Optional noise injection for signal testing
- Digital signal filtering:
  - FIR filter
  - IIR filter
  - Independent filter enable/disable control
- Fully hardware-based FPGA implementation using Verilog HDL

## 🛠 Hardware Platform
- FPGA Board: DE10-Standard (Cyclone V)
- Clock source: On-board FPGA clock
- Output interface: Oscilloscope-compatible signal output
- User inputs: Switches / buttons for waveform selection, parameter adjustment, and filter control

## 🧠 System Design Description
The system is designed following a modular RTL architecture. A waveform generator
module produces different signal types based on user selection. Frequency and
amplitude adjustment logic allows real-time parameter control. Optional noise
injection can be enabled to evaluate filter performance.

Digital FIR and IIR filter modules are implemented to process the generated signals.
Filtering can be dynamically enabled or disabled, allowing direct comparison
between raw and filtered waveforms. The final processed signal is routed to the
output stage for visualization on an oscilloscope.

## 📂 Project Structure


## 🧩 Source Code Overview
- Waveform generator modules (sine, triangle, square, sawtooth, ECG)
- Frequency and amplitude control logic
- Noise generation and injection module
- FIR and IIR digital filter modules
- Control logic for filter enable/disable
- Top-level integration module

## 🧪 Simulation & Verification
- Functional verification using Verilog testbenches
- Waveform-based simulation to validate signal generation and filtering
- Verification of noise injection and filter effectiveness
- Simulation results provided in the `images/` directory

## 🎓 Project Context
- Project type: FPGA / Digital Signal Processing Project
- Implementation language: Verilog HDL
- Focus areas:
  - RTL design
  - Digital signal processing (DSP)
  - Real-time waveform generation
  - Hardware-based filtering
  - FPGA system integration

## 👤 Author
- Name: Viet Hoang
- GitHub: https://github.com/viethoang2k3fov

## 📎 Notes
This project is intended for academic and learning purposes.
Auto-generated build files and FPGA programming files are excluded from this repository.
