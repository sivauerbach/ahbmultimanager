# AHB Multimanager

An implementation of the AHB Multimanager spec using round robin arbitration. Currently still experimenting with build setups, so it's subject to change in the future. To compile and simulate in Questasim run the following command:

```bash
vsim -do setup.tcl
```

I've added Verilator compilation and simulation with a Makefile. Type `make` to compile and simulate.