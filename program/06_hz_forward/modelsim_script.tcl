
vlib work

set p0 -vlog01compat
set p1 +define+SIMULATION
set p2 +define+SIMULATION_CYCLES=20

set i0 +incdir+../../../src
set i1 +incdir+../../../testbench

set s0 ../../../src/*.v
set s1 ../../../testbench/*.v

vlog $p0 $p1 $p2  $i0 $i1  $s0 $s1

vsim -novopt work.sm_testbench

add wave -radix hex                         sim:/sm_testbench/sm_top/sm_cpu/clk
add wave -radix hex                         sim:/sm_testbench/sm_top/sm_cpu/rst_n

# A
add wave -radix dec -label instrRs_E        sim:/sm_testbench/sm_top/sm_cpu/instrRs_E
add wave -radix hex -label regData1_E       sim:/sm_testbench/sm_top/sm_cpu/regData1_E
add wave -radix hex -label aluSrcA_E        sim:/sm_testbench/sm_top/sm_cpu/aluSrcA_E 
add wave -radix hex -label hz_forwardA_E    sim:/sm_testbench/sm_top/sm_cpu/sm_hazard_unit/hz_forwardA_E

# B
add wave -radix dec -label instrRt_E        sim:/sm_testbench/sm_top/sm_cpu/instrRt_E
add wave -radix hex -label aluSrcB_E        sim:/sm_testbench/sm_top/sm_cpu/aluSrcB_E 
add wave -radix hex -label regData2_E       sim:/sm_testbench/sm_top/sm_cpu/regData2_E
add wave -radix hex -label hz_forwardB_E    sim:/sm_testbench/sm_top/sm_cpu/sm_hazard_unit/hz_forwardB_E

# result
add wave -radix dec -label writeReg_E       sim:/sm_testbench/sm_top/sm_cpu/writeReg_E
add wave -radix dec -label writeReg_M       sim:/sm_testbench/sm_top/sm_cpu/writeReg_M
add wave -radix hex -label cw_regWrite_M    sim:/sm_testbench/sm_top/sm_cpu/cw_regWrite_M
add wave -radix dec -label writeReg_W       sim:/sm_testbench/sm_top/sm_cpu/writeReg_W
add wave -radix hex -label cw_regWrite_W    sim:/sm_testbench/sm_top/sm_cpu/cw_regWrite_W

# regs
add wave -radix hex -label rf_t0_8          sim:/sm_testbench/sm_top/sm_cpu/rf/rf\[8\] 
add wave -radix hex -label rf_t1_9          sim:/sm_testbench/sm_top/sm_cpu/rf/rf\[9\]
add wave -radix hex -label rf_t2_10         sim:/sm_testbench/sm_top/sm_cpu/rf/rf\[10\]
add wave -radix hex -label rf_t3_11         sim:/sm_testbench/sm_top/sm_cpu/rf/rf\[11\]
add wave -radix hex -label rf               sim:/sm_testbench/sm_top/sm_cpu/rf/rf

run -all

wave zoom full
