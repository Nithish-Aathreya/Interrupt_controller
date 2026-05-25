# 16-Line Priority Interrupt Controller — Verilog

## Overview

A fully synthesisable, 16-line **priority interrupt controller (PIC)** implemented in Verilog HDL. The design arbitrates among 16 simultaneous interrupt sources, services the highest-priority pending request first, and completes each transaction with a formal interrupt-acknowledge cycle. A comprehensive testbench stress-tests arbitration correctness across in-order, reverse-order, and randomised interrupt sequences.

---

## Block Diagram


<img width="1408" height="768" alt="Gemini_Generated_Image_75k6975k6975k697" src="https://github.com/user-attachments/assets/0dee5d4d-2232-44d2-b5e3-4863518316bb" />

### Interrupt Register
<img width="1408" height="768" alt="Gemini_Generated_Image_bm1t0sbm1t0sbm1t" src="https://github.com/user-attachments/assets/01aa6411-9779-4a70-b6f7-265df75abebc" />

---
## FSM
<img width="1408" height="650" alt="Gemini_Generated_Image_jx9hy2jx9hy2jx9h" src="https://github.com/user-attachments/assets/ee638ac0-870b-4316-af66-a07aec13f1cb" />

