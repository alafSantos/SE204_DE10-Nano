#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
# for enhancing USB BlasterII to be reliable, 25MHz
#create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
#set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
#set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
#set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


