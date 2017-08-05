
create_clock -period "100.0 MHz" [get_ports CLK100MHZ]

derive_clock_uncertainty
create_generated_clock -name {clk} -divide_by 2 -source [get_ports {CLK100MHZ}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LED[*]}]

set_false_path -from [get_ports {KEY0}] -to [all_clocks]
set_false_path -from [get_ports {KEY1}] -to [all_clocks]
