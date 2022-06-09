#create_clock -period 10.000 -name diff_clk_in_0_clk_p -waveform {0.000 6.000} [get_ports diff_clk_in_0_clk_p]
set_clock_groups -asynchronous -group [get_clocks clk_fpga_1] -group [get_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks clk_fpga_1]

#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks -of_objects [get_pins design_2_i/selectio_wiz_0/inst/clkout_buf_inst/O]]

create_clock -period 10.000 -name adc_clk_clk_p -waveform {0.000 5.000} [get_ports adc_clk_clk_p]

#set_false_path -to [get_pins -hierarchical *sync1_reg/D]
#set_false_path -to [get_pins -hierarchical *sync1_reg[0]/D]

#set_false_path -to [get_pins -hierarchical *ack_reg/D]

#set_false_path -to [get_pins -hierarchical {sync1_reg[*]/D}]
#set_false_path -to [get_pins -hierarchical sync1_ss_reg/D]
#set_false_path -to [get_pins -hierarchical sync1_s_reg/D]

#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_2]
#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks -of_objects [get_pins design_2_full_i/selectio_wiz_0/inst/clkout_buf_inst/O]]

set_clock_groups -asynchronous -group [get_clocks clk_fpga_1] -group [get_clocks -of_objects [get_pins design_2_full_i/adc_input/inst/clkout_buf_inst/O]]
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks -of_objects [get_pins design_2_full_i/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT*]]
# set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins design_2_full_i/adc_input/inst/clkout_buf_inst/O]] -group [get_clocks clk_fpga_0]

set_false_path -from [get_clocks clk_fpga_1] -to [get_pins -hierarchical {sync1_reg[*]/D}]
