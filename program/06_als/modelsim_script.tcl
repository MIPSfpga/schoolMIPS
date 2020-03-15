
vlib work

set p0 -sv
set p1 +define+SIMULATION
set p2 +define+SIMULATION_CYCLES=1200

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1 $p2  $i0 $i1  $s0 $s1

vsim work.sm_testbench

add wave -radix hex sim:/sm_testbench/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/rf

run -all

wave zoom full
