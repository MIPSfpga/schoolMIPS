
create_clock -period "50.0 MHz" [get_ports CLOCK_50]

derive_pll_clocks

derive_clock_uncertainty

create_generated_clock -name {clk} -divide_by 2 -source [get_ports {CLOCK_50}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LED[*]}]

set_false_path -from [get_ports {KEY[*]}] -to [all_clocks]
set_false_path -from [get_ports {SW[*]}] -to [all_clocks]

