
create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty
create_generated_clock -name {clk} -divide_by 2 -source [get_ports {CLK}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LED[*]}]
set_false_path -from * -to [get_ports {HEX0[*]}]
set_false_path -from * -to [get_ports {HEX1[*]}]

set_false_path -from [get_ports {SW[*]}] -to [all_clocks]
