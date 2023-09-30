#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Set Clock 
#**************************************************************

set sysclk ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]
set subclk ${topmodule}pll|altpll_component|auto_generated|pll1|clk[1]
set sdram_clk ${topmodule}pll|altpll_component|auto_generated|pll1|clk[0]

set_clock_groups -asynchronous -group [get_clocks $subclk] -group spiclk
set_clock_groups -asynchronous -group [get_clocks $sysclk] -group spiclk
set_clock_groups -asynchronous -group [get_clocks $subclk] -group [get_clocks $supportclk]
set_clock_groups -asynchronous -group [get_clocks $sysclk] -group [get_clocks $supportclk]

#**************************************************************
# Set Input Delay
#**************************************************************
#set_input_delay -clock [get_clocks $sysclk] -max 6.4 [get_ports $RAM_IN]
#set_input_delay -clock [get_clocks $sysclk] -min 3.2 [get_ports $RAM_IN]
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min 3.2 [get_ports ${RAM_IN}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock [get_clocks $sdram_clk] -reference_pin [get_ports ${RAM_CLK}] -min -0.8 [get_ports ${RAM_OUT}]
#set_output_delay -clock [get_clocks $sysclk] -max 1.5 [get_ports $RAM_OUT]
#set_output_delay -clock [get_clocks $sysclk] -min -0.8 [get_ports $RAM_OUT]


#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to ${VGA_OUT}
set_false_path -to ${FALSE_OUT}
set_false_path -from ${FALSE_IN}

