#!/bin/bash

rm -rf sim
mkdir sim
cd sim

cp ../*.hex .

# default simulation params
SIMULATION_CYCLESS=120

# read local simulation params
source ../icarus.cfg

# compile
iverilog -g2005 -D SIMULATION -D ICARUS -I ../../../src -I ../../../testbench -s sm_testbench ../../../src/*.v ../../../testbench/*.v

# simulation
vvp -la.lst -n a.out -vcd

# output
gtkwave dump.vcd

cd ..
