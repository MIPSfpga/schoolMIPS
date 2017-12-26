
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION
set p2 +define+SIMULATION_CYCLES=22

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1 $p2  $i0 $i1  $s0 $s1

vsim -novopt work.sm_testbench

add wave -radix hex                         sim:/sm_testbench/sm_top/sm_cpu/clk
add wave -radix hex                         sim:/sm_testbench/sm_top/sm_cpu/rst_n

add wave -radix hex sim:/sm_testbench/cycle 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_flush_n_E 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_forwardA_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_forwardA_E 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_forwardB_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_forwardB_E 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_stall_n_D 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/hz_stall_n_F 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_hazard_unit/hz_branch_stall 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/sm_hazard_unit/hz_mem_stall 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/cw_pcSrc_D 
add wave -radix hex {sim:/sm_testbench/sm_top/sm_cpu/rf/rf[2]} 
add wave -radix hex {sim:/sm_testbench/sm_top/sm_cpu/rf/rf[8]} 
add wave -radix hex {sim:/sm_testbench/sm_top/sm_cpu/rf/rf[10]} 
add wave -radix hex {sim:/sm_testbench/sm_top/sm_cpu/rf/rf[9]} 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/writeData_E 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/writeData_M 
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/instr_D
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/pc_F
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/instr_F
add wave -radix hex sim:/sm_testbench/sm_top/sm_cpu/instr_D 

run -all

wave zoom full
