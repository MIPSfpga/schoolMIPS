
vlib work

set p0 -sv
set p1 +define+SIMULATION

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench
set i2 +incdir+../../../testbench/dpi

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v
set s2 ../../../testbench/dpi/*

vlog $p0 $p1  $i0 $i1 $i2  $s0 $s1 $s2

vsim work.sm_testbench

# add wave -radix hex sim:/sm_testbench/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/rf

run -all

wave zoom full
