
create_clock -period "50.0 MHz" [get_ports CLOCK_50]
create_clock -period "50.0 MHz" [get_ports CLOCK_50_2]

derive_clock_uncertainty
create_generated_clock -name {clk} -divide_by 2 -source [get_ports {CLOCK_50}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LEDG[*]}]
set_false_path -from * -to [get_ports {HEX0_D[*]}]
set_false_path -from * -to [get_ports {HEX1_D[*]}]
set_false_path -from * -to [get_ports {HEX2_D[*]}]
set_false_path -from * -to [get_ports {HEX3_D[*]}]
set_false_path -from * -to [get_ports {HEX0_DP}]
set_false_path -from * -to [get_ports {HEX1_DP}]
set_false_path -from * -to [get_ports {HEX2_DP}]
set_false_path -from * -to [get_ports {HEX3_DP}]

set_false_path -from [get_ports {BUTTON[*]}] -to [all_clocks]
set_false_path -from [get_ports {SW[*]}] -to [all_clocks]
