# Network on Chip (NOC)
This design adds a Network On a Chip interface to the CRC block.

## Overview of Network on a chip bus (NOC bus)
The Network on a chip is a pair of low pin count uni-directional bus. The data is transferred in packets on a nine bit bus. Bit 8 is a control bit indicating a framing byte. The bus supports a few basic packets.

* Detailed description: Please go through the attached document "NOC.pdf" for the complete design specification of the NOC bus.

* The commands used are specific to the Synopsys tool (VCS tool for simulation and design compiler for synthesis) and might not run on other tool.

* The sv_uvm script will run the simulator. Use command "./sv_uvm tbcrcn.sv"
