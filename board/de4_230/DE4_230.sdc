
create_clock -period 20 [get_ports OSC_50_BANK2]
create_clock -period 20 [get_ports OSC_50_BANK3]
create_clock -period 20 [get_ports OSC_50_BANK4]
create_clock -period 20 [get_ports OSC_50_BANK5]
create_clock -period 20 [get_ports OSC_50_BANK6]
create_clock -period 20 [get_ports OSC_50_BANK7]

derive_pll_clocks

derive_clock_uncertainty
create_generated_clock -name {clk} -divide_by 2 -source [get_ports {OSC_50_BANK2}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LED[*]}]
set_false_path -from * -to [get_ports {SEG0_D[*]}]
set_false_path -from * -to [get_ports {SEG1_D[*]}]
set_false_path -from * -to [get_ports {SEG0_DP}]
set_false_path -from * -to [get_ports {SEG1_DP}]
set_false_path -from * -to [get_ports {HEX4[*]}]
set_false_path -from * -to [get_ports {HEX5[*]}]

set_false_path -from [get_ports {SLIDE_SW[*]}] -to [all_clocks]
set_false_path -from [get_ports {BUTTON[*]}] -to [all_clocks]
set_false_path -from [get_ports {SW[*]}] -to [all_clocks]
set_false_path -from [get_ports {CPU_RESET_n}] -to [all_clocks]
