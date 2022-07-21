/* # ########################################################################
# Copyright (C) 2019, Xilinx Inc - All rights reserved

# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
# ######################################################################## */

`timescale 1ps / 1ps

module tb_full;

parameter BASE_REG            = 32'h43D00000;
parameter A_MC_REG            = BASE_REG + 32'h00;

parameter A_PM0_CTRL_REG      = BASE_REG + 32'h04;
parameter A_PM1_CTRL_REG      = BASE_REG + 32'h08;
parameter A_PM2_CTRL_REG      = BASE_REG + 32'h0C;

parameter A_GALVO_CTRL_REG    = BASE_REG + 32'h10;
parameter A_GALVO_MAN_REG     = BASE_REG + 32'h14;

parameter A_SPI_ADC_CS_REG    = BASE_REG + 32'h18;
parameter A_SPI_ADC_DATA_REG  = BASE_REG + 32'h1C;

parameter A_SPI_DAC0_CS_REG   = BASE_REG + 32'h20; // 7
parameter A_SPI_DAC0_DATA_REG = BASE_REG + 32'h24;
parameter A_SPI_DAC1_CS_REG   = BASE_REG + 32'h28;
parameter A_SPI_DAC1_DATA_REG = BASE_REG + 32'h2C;
parameter A_SPI_DAC2_CS_REG   = BASE_REG + 32'h30;
parameter A_SPI_DAC2_DATA_REG = BASE_REG + 32'h34;

parameter A_RST_DEBUG_REG     = BASE_REG + 32'h40;

parameter PEAK_BASE_REG       = 32'h43C90000;
parameter INDICES_BASE_REG    = 32'h43CA0000;

parameter A_PM0_MEMA = 32'h43C20000;
parameter A_PM0_MEMB = 32'h43C30000;

parameter A_PM1_MEMA = 32'h43C40000;
parameter A_PM1_MEMB = 32'h43C50000;

parameter A_PM2_MEMA = 32'h43C60000;
parameter A_PM2_MEMB = 32'h43C70000;

parameter A_GALVO_H_MEM = 32'h43C00000;
parameter A_GALVO_V_MEM = 32'h43C10000;

parameter A_WINDOW_MEM =  32'h43C80000;

parameter A_INPUT_DEBUG_MEM =  32'h43CB0000;
parameter A_FFT_DEBUG_MEM =  32'h43CC0000;


parameter TBCLK_PERIOD = 10000;
parameter X2CLK_PERIOD = 1000;
//parameter X2CLK_PERIOD = 500;

reg [9:0] data_mem [0:2047*4];
reg [9:0] fclk_mem [0:2047];
reg [11:0] galvo_h_mem [0:1023];
reg [11:0] galvo_v_mem [0:1023];
reg [15:0] window_mem [0:2047];

integer i;
reg [3:0] cnt = 0;
reg [10:0] pointer = 0;
reg [12:0] dpointer = 0;

reg run = 0;
reg [31:0] address, data;
reg [31:0] galvo_data;
reg [31:0] window_data;

    reg tb_ACLK;
    reg tb_ARESETn;
    reg [9:0] current_byte, fclk_byte;
    reg fclkbit;
    wire databit;

    reg bit_clk;
    reg bitx2_clk;

    reg tb_clk_in;

    wire temp_clk;
    wire temp_rstn;

    reg [31:0] read_data;
    wire [3:0] leds;
    reg resp;

    // ADC
  wire adc_clk_n;
  wire adc_clk_p;

  wire [8:0] adc_n;
  wire [8:0] adc_p;

  // PM
  wire [9:0] data_out_to_pins_n_0;
  wire [9:0] data_out_to_pins_n_1;
  wire [9:0] data_out_to_pins_n_2;
  wire [9:0] data_out_to_pins_p_0;
  wire [9:0] data_out_to_pins_p_1;
  wire [9:0] data_out_to_pins_p_2;


  wire diff_clk_to_pins_0_clk_n;
  wire diff_clk_to_pins_0_clk_p;
  wire diff_clk_to_pins_1_clk_n;
  wire diff_clk_to_pins_1_clk_p;
  wire diff_clk_to_pins_2_clk_n;
  wire diff_clk_to_pins_2_clk_p;

  wire [87:0] ind1_0;
  wire [87:0] ind2_0;
  wire [87:0] ind3_0;
  wire [255:0] top1_0;
  wire [255:0] top2_0;
  wire [255:0] top3_0;
  wire event_data_in_channel_halt_0 ;
  wire event_data_out_channel_halt_0;
  wire event_fft_overflow_0         ;
  wire event_frame_started_0        ;
  wire event_status_channel_halt_0  ;
  wire event_tlast_missing_0        ;
  wire event_tlast_unexpected_0     ;

    initial
    begin
        tb_ACLK = 1'b0;
        tb_clk_in = 1'b0;
        bitx2_clk = 1'b0;
        bit_clk = 1'b0;
        run = 1'b0;
        $display("Loading data_mem from file");
        //$readmemh("datain.mem", data_mem);
//        $readmemh("sinenoise2tones.mem", data_mem);
        /* $readmemh("sine1_2_22_4.mem", data_mem); */
        $readmemh("20_1MHZ_128k.mem", data_mem);

        $readmemh("fclkin.mem", fclk_mem);
        $display("Finshed Loading data_mem");

        $display("Loading Galvo from file");
        $readmemh("galvo_h.mem", galvo_h_mem);
        $readmemh("galvo_v.mem", galvo_v_mem);

        $display("Loading Window from file");
        $readmemh("blackman2048.mem", window_mem);

//        $readmemh("fclkin.mem", fclk_mem);
        $display("Finished Loading Galvo mem file");

//        adc_n = 9'h000;
//        adc_p = 9'hFFF;
    end

    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------

//    always #10 tb_ACLK = !tb_ACLK;
//    always #3 bitx2_clk = !bitx2_clk;

always begin
    tb_ACLK = 1'b1;
    #(TBCLK_PERIOD/2) tb_ACLK = 1'b0;
    #(TBCLK_PERIOD/2);
end

always begin
    bitx2_clk = 1'b1;
    #(X2CLK_PERIOD/2) bitx2_clk = 1'b0;
    #(X2CLK_PERIOD/2);
end

always @ (posedge bitx2_clk)
    bit_clk = !bit_clk;


always @ (posedge bitx2_clk)
    if (cnt == 9 || !run) 
        cnt <= 0;
    else if (run)
        cnt <= cnt + 1;

always @ (posedge bitx2_clk)
    if (cnt == 9 && run == 1)
    begin
        dpointer <= dpointer + 1;
        pointer <= pointer + 1;
end

always @ (negedge bitx2_clk)
    if (cnt == 0)
        current_byte <= data_mem[dpointer];
    else
        current_byte <= current_byte >> 1;

always @ (negedge bitx2_clk)
    fclk_byte <= 10'h01F;
    /* fclk_byte <= fclk_mem[pointer]; */

 /* always @ (negedge bitx2_clk) */
 /*     databit <= current_byte[cnt]; */

 assign databit = current_byte[0];

 always @ (negedge bitx2_clk)
     fclkbit <= fclk_byte[cnt];


assign adc_n = {!fclkbit, 6'h00,databit,  !databit};
assign adc_p = {fclkbit, 6'hFF, !databit,  databit};

initial begin
    $display ("running the tb");
    tb_ARESETn = 1'b0;
    $display ("point A");

    repeat(20)@(posedge tb_ACLK);
    $display ("point B");

    tb_ARESETn = 1'b1;
    @(posedge tb_ACLK);
    $display ("point C");

    repeat(5) @(posedge tb_ACLK);

    //Reset the PL
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.fpga_soft_reset(32'h0);
    //This drives the LEDs on the GPIO output
    // tb.zynq_sys.design_2_i.processing_system7_0.inst.write_data(32'h41200000,4, 32'hFFFFFFFF, resp);
	#10000
/*
	$display ("==== Write 10 locations to PM0 1st Memory ====");
	address = A_PM0_MEMA;
	for (i = 0; i < 20 ; i = i + 1) begin
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, 32'b0, resp);
		address = address + 4;
	end
	for (i = 0; i < 10 ; i = i + 1) begin
	data = 1 << i;
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, data, resp);
		address = address + 4;
	end

	$display ("==== Finished Writing to PM0 Memory ====");
*/
/*
	$display ("==== Write 100 locations to PM0 2nd Memory ====");
	address = A_PM0_MEMB;
	for (i = 0; i < 10 ; i = i + 1) begin
	   data = 1 << i;
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, data, resp);
		address = address + 4;
	end
	for (i = 0; i < 20 ; i = i + 1) begin
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, 0, resp);
        //data = data << 1
		address = address + 4;
	end

	$display ("==== Finished Writing to PM0 2nd Memory ====");
*/

    $display ("Write to PM Control Register");
    // sync and max addresses
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_PM0_CTRL_REG,4, 32'h801E0010, resp);
    // remove sync
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_PM0_CTRL_REG,4, 32'h001E0010, resp);

	#1000

    /* write to DAC SPI config3 over SPI */
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_DAC0_DATA_REG,4, 32'h00031450, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_DAC0_CS_REG,4, 32'h00000002, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_DAC0_CS_REG,4, 32'h80000002, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_DAC0_CS_REG,4, 32'h00000002, resp);


	
	$display ("==== Write to Galvo Control Register ====");
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_GALVO_CTRL_REG,4, {5'h0, 11'd3, 5'h0, 11'd4}, resp);

/*
	$display ("==== Write 32 locations to Galvo H Memory ====");
	address = A_GALVO_H_MEM;
	for (i = 0; i < 32 ; i = i + 1) begin
	   galvo_data = {20'h0,  galvo_h_mem[i]};
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, galvo_data, resp);
		address = address + 4;
	end
	$display ("==== finished 32 locations to Galvo H Memory ====");
	$display ("==== Write 32 locations to Galvo V Memory ====");
	address = A_GALVO_V_MEM;
	for (i = 0; i < 32 ; i = i + 1) begin
	   galvo_data = {20'h0,  galvo_v_mem[i]};
        tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, galvo_data, resp);
		address = address + 4;
	end
	$display ("==== finished 32 locations to Galvo V Memory ====");
*/
/*
	$display ("==== Write to Window Coeff Memory ====");
	address = A_WINDOW_MEM;
	for (i = 0; i < 2048 ; i = i + 1) begin
	   window_data = {16'h0, window_mem[i]};
       $display("writing window data 32'h%x to address 32'h%x", window_data, address);
       tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(address,4, window_data, resp);
	   address = address + 4;
	end
*/
	$display ("RUN to MC for pixel processing");
	// write cycle time in units of 100ns
	
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_MC_REG,4, 32'h00008BB8, resp);

    $display ("Starting to input data from ADC");
    run = 1'b1;

//    #2000
//	#2000
//    $display ("%t, ============>>> Doing ADC SPI write",$time);
//    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_ADC_DATA_REG,4, 32'h12345678, resp);
//    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_ADC_CS_REG,4, 32'h80000003, resp);
//    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_SPI_ADC_CS_REG,4, 32'h00000003, resp);

    #1000000
    // Rst ADC and PM DACS
    $display ("%t, ============>>> Reset various peripherals",$time);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h0000007F, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);
    $display ("%t, ============>>> Reset Done",$time);

//    #542000
//    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000008, resp);
//    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);


    // RUN
    #500000
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_MC_REG,4, 32'h00000000, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_MC_REG,4, 32'h80000000, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_MC_REG,4, 32'h00000000, resp);


    // capture input data
    $display ("%t, ============>>> Debug Capture",$time);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00001100, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);

    // capture fft output
    #233520
    $display ("%t, ============>>> FFT Capture",$time);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000080, resp);
    tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_RST_DEBUG_REG,4, 32'h00000000, resp);

    // $display ("%t, ============>>> Doing manual Galvo SPI write",$time);
    // tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_GALVO_CTRL_REG,4, 32'h80000000, resp);
    // tb_full.zynq_sys.multiphase_i.processing_system7_0.inst.write_data(A_GALVO_MAN_REG,4, 32'h83450123, resp);

    /* if(read_data == 32'hDEADBEEF) begin */
    /*     $display ("AXI VIP Test PASSED"); */
    /* end */
    /* else begin */
    /*    $display ("AXI VIP Test FAILED"); */
    /* end */
    $display ("Simulation completed");
    $stop;
end

    assign temp_clk = tb_ACLK;
    assign temp_rstn = tb_ARESETn;

    /* assign adc_clk_n = bitx2_clk; */
    /* assign adc_clk_p = !bitx2_clk; */
    assign adc_clk_n = bit_clk;
    assign adc_clk_p = !bit_clk;

multiphase_wrapper zynq_sys
   (.DDR_addr(),
    .DDR_ba(),
    .DDR_cas_n(),
    .DDR_ck_n(),
    .DDR_ck_p(),
    .DDR_cke(),
    .DDR_cs_n(),
    .DDR_dm(),
    .DDR_dq(),
    .DDR_dqs_n(),
    .DDR_dqs_p(),
    .DDR_odt(),
    .DDR_ras_n(),
    .DDR_reset_n(),
    .DDR_we_n(),
    .FIXED_IO_ddr_vrn(),
    .FIXED_IO_ddr_vrp(),
    .FIXED_IO_mio(),
    .FIXED_IO_ps_clk(temp_clk),
    .FIXED_IO_ps_porb(temp_rstn ),
    .FIXED_IO_ps_srstb(temp_rstn),
   // .leds_4bits_tri_o(leds)
  .adc_n         ( adc_n),
  .adc_p         ( adc_p),
  .adc_clk_clk_n           ( adc_clk_n),
  .adc_clk_clk_p           ( adc_clk_p),

//   .event_data_in_channel_halt_0  ( event_data_in_channel_halt_0  ),
//   .event_data_out_channel_halt_0 ( event_data_out_channel_halt_0 ),
//   .event_fft_overflow_0          ( event_fft_overflow_0          ),
//   .event_frame_started_0         ( event_frame_started_0         ),
//   .event_status_channel_halt_0   ( event_status_channel_halt_0   ),
//   .event_tlast_missing_0         ( event_tlast_missing_0         ),
//   .event_tlast_unexpected_0      ( event_tlast_unexpected_0      ),
   
   .sclk_pm0 (),
   .mosi_pm0 (),
   .csn_pm0  (),
   
    .sclk_pm1 (),
   .mosi_pm1 (),
   .csn_pm1  (),
     
   .sclk_pm2 (),
   .mosi_pm2 (),
   .csn_pm2  (),
     
   .sclk_adc (),
   .mosi_adc (),
   .csn_adc  (),
   .adc_miso ()
   
   
//   .ind1_0                        ( ind1_0                        ),
//   .ind2_0                        ( ind2_0                        ),
//   .ind3_0                        ( ind3_0                        ),
//   .top1_0                        ( top1_0                        ),
//   .top2_0                        ( top2_0                        ),
//   .top3_0                        ( top3_0                        )
    );

endmodule
