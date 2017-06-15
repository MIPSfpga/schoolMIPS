
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION

set i0 +incdir+../../../src

set s0 ../../../src/*.v

vlog $p0 $p1  $i0  $s0

vsim work.sm_testbench

# add wave -radix hex sim:/sm_testbench/*
add wave -radix hex sim:/sm_testbench/sm_cpu/*

run -all

wave zoom full
