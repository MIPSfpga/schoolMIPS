create_clock -period "50.0 MHz" [get_ports clk_50]

derive_clock_uncertainty
create_generated_clock -name {clk}     -divide_by 2 -source [get_ports {clk_50}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]
create_generated_clock -name {clk_hex} -divide_by 2 -source [get_ports {clk_50}] [get_registers {sm_clk_divider:hex_clk_divider|sm_register_we:r_cntr|q[16]}]

set_false_path -from [get_ports {key[*]}] -to [all_clocks]
set_false_path -from [get_ports {sw[*]}]  -to [all_clocks]

set_false_path -from * -to [get_ports {led[*]}]
set_false_path -from * -to [get_ports {hex[*]}]
set_false_path -from * -to [get_ports {digit[*]}]
set_false_path -from * -to buzzer
