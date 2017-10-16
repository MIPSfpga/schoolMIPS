
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1  $i0 $i1  $s0 $s1

vsim work.sm_testbench

# add wave -radix hex sim:/sm_testbench/*
add wave -radix hex sim:/sm_testbench/sm_cpu/*
add wave -radix hex sim:/sm_testbench/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_cpu/rf/rf

run -all

wave zoom full
