
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION
set p2 +define+SIMULATION_CYCLES=1500

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1 $p2  $i0 $i1  $s0 $s1

vsim -novopt work.sm_testbench

add wave -radix unsigned sim:/sm_testbench/cycle 
# add wave -radix hex sim:/sm_testbench/*
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/*
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/*
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/rf/rf

add wave -radix hex sim:/sm_testbench/clk 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_StatusIE 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_CauseTI 
add wave -height 74 -scale 0.2 -radix hex -format analog-step  sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_Count 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_Compare 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_Cause 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_Status 

#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/debug 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_control/branch 
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_ExcAsync 
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_RequestForAsync 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_StatusEXL 

#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/cp0_ExcSync
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/cp0_ExcAsync
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/pc 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_EPC 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_cpz/cp0_ExcHandler 

add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_control/exception 
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/irqRequest_D 
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/irqRequest_E 
#add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_flush_n_D 

# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/excRiFound_D
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/excRiFound_E 
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/excRiFound_M 
# 
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/epcNext_D 
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/epcNext_E 
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/epcNext_E_new 
# add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/epcNext_M 

add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/irqRequest_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/epcNext_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/pc_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/pc_F 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/pcFlow_F 

add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_cancel_branch_F 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_forwardEPC_E 

run -all

wave zoom full
