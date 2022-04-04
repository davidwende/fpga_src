create_clock -period 10.000 -name ADC_CLK -waveform {0.000 5.000} [get_ports adc_clk_clk_p]
#create_clock -period 4.350 -name STREAM_CLK -waveform {0.000 2.175} [get_pins design_2_full_i/processing_system7_0/FCLK_CLK0]
#create_clock -period 10.000 -name CONTROL_CLK -waveform {0.000 5.000} [get_pins design_2_full_i/processing_system7_0/FCLK_CLK1]
set_clock_groups -name g1 -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks -of_objects [get_pins multiphase_i/clk_wiz_0/inst/plle2_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins multiphase_i/clk_wiz_0/inst/plle2_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins multiphase_i/clk_wiz_0/inst/plle2_adv_inst/CLKOUT2]]
set_clock_groups -name g2 -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks clk_fpga_1]
set_clock_groups -name g3 -asynchronous -group [get_clocks clk_fpga_1] -group [get_clocks -of_objects [get_pins multiphase_i/adc_input/inst/clkout_buf_inst/O]]

set_false_path -to [get_pins -hierarchical {*sync1_s_reg/D *sync1_ss_reg/D ack_reg/D *sync1_reg/D {*sync1_reg[*]/D}}]

#create_clock -period 100.000 -name ADC_SPI_SCLK [get_ports sclk_adc]
create_generated_clock -name SCLK_ADC_V -source [get_pins multiphase_i/processing_system7_0/FCLK_CLK1] -divide_by 10 [get_ports sclk_adc]

#set_max_delay -from [get_pins design_2_full_i/all_rstn_sync_0/inst/sel_io_rst_reg/C] -to [get_pins {design_2_full_i/adc_input/inst/pins[*].iserdese2_master/RST}] 10.000

#set_max_delay -from [get_pins -hierarchical sel_io_rst_reg/C] -to [get_pins -hierarchical {pins[*].iserdese2_master/RST}] 10.000
set_false_path -from [get_pins -hierarchical sel_io_rst_reg/C] -to [get_pins -hierarchical {pins[*].iserdese2_master/RST}]
set_false_path -from [get_pins -hierarchical sel_io_rst_reg/C] -to [get_pins -hierarchical {pins[*].iserdese2_slave/RST}]

# output delays for SPI
#Galvo
# input data setup 5 (sclk falling)
# input data hold 4 (sclk falling)
# output sclk rising to data max 25
create_generated_clock -name GALVO_SCLK -source [get_pins multiphase_i/processing_system7_0/FCLK_CLK1] -divide_by 10 [get_ports galvo_sclk]
#set_output_delay -clock GALVO_SCLK -min -4 -clock_fall [get_ports galvo_mosi]

#set galvo_period 50;
#set galvo_tsu 5;
#set galvo_thd 4;
#set tdif_max [expr $galvo_period / 2];
#set tdif_min [expr $galvo_period / 2];
#set dat_port [get_ports galvo_mosi]
#set clk_port [get_ports galvo_sclk]
#set fclk_nam FCLK
#set fclk_src [get_pins design_2_full_i/processing_system7_0/inst/buffer_fclk_clk_1.FCLK_CLK_1_BUFG/O]
#create_generated_clock -name $fclk_nam -source $fclk_src -divide_by 10 [get_ports $clk_port]
#set_output_delay -clock $fclk_nam -max [expr $tdif_max + $tsu] [get_ports $dat_port]
#set_output_delay -clock $fclk_nam -min [expr $tdif_min - $thd] [get_ports $dat_port]


set_max_delay -to [get_pins {multiphase_i/peak_top_2_0/inst/index_to_write_s_reg[*]/D}] 10.000
set_max_delay -to [get_pins {multiphase_i/peak_top_2_0/inst/peak_to_write_s_reg[*]/D}] 10.000


