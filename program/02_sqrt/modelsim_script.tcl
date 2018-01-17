
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION
set p2 +define+SIMULATION_CYCLES=200

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1 $p2  $i0 $i1  $s0 $s1

vsim -novopt work.sm_testbench

# add wave -radix hex sim:/sm_testbench/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/*
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_control/*
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/alu/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/rf
add wave            sim:/sm_testbench/cycle

run -all

wave zoom full
