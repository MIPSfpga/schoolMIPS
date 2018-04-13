#!/bin/bash

rm -rf sim
mkdir sim
cd sim

cp ../*.hex .

vsim -novopt -do ../modelsim_script.tcl

cd ..
