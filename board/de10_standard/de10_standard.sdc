
create_clock -period "50.000000 MHz" [get_ports CLOCK2_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK3_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK4_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK_50]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

derive_clock_uncertainty
create_generated_clock -name {clk} -divide_by 2 -source [get_ports {CLOCK_50}] [get_registers {sm_top:sm_top|sm_clk_divider:sm_clk_divider|sm_register_we:r_cntr|q[*]}]

set_false_path -from * -to [get_ports {LEDR[*]}]
set_false_path -from * -to [get_ports {HEX0[*]}]
set_false_path -from * -to [get_ports {HEX1[*]}]
set_false_path -from * -to [get_ports {HEX2[*]}]
set_false_path -from * -to [get_ports {HEX3[*]}]
set_false_path -from * -to [get_ports {HEX4[*]}]
set_false_path -from * -to [get_ports {HEX5[*]}]

set_false_path -from [get_ports {KEY[*]}] -to [all_clocks]
set_false_path -from [get_ports {SW[*]}] -to [all_clocks]


