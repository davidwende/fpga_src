`timescale 1ns/1ps

`include "constants.vh"

module peak_top_2
(
    input lresetn_stream,

    input s_axis_data0_aclk,
    input [32 - 1 : 0] s_axis_data0_tdata,
    input s_axis_data0_tvalid,
    output s_axis_data0_tready,
    input s_axis_data0_tlast,

    input s_axis_data1_aclk,
    input [32 - 1 : 0] s_axis_data1_tdata,
    input s_axis_data1_tvalid,
    output s_axis_data1_tready,
    input s_axis_data1_tlast,

    input s_axis_data2_aclk,
    input [32 - 1 : 0] s_axis_data2_tdata,
    input s_axis_data2_tvalid,
    output s_axis_data2_tready,
    input s_axis_data2_tlast,

    input s_axis_data3_aclk,
    input [32 - 1 : 0] s_axis_data3_tdata,
    input s_axis_data3_tvalid,
    output s_axis_data3_tready,
    input s_axis_data3_tlast,

    input s_axis_data4_aclk,
    input [32 - 1 : 0] s_axis_data4_tdata,
    input s_axis_data4_tvalid,
    output s_axis_data4_tready,
    input s_axis_data4_tlast,

    input s_axis_data5_aclk,
    input [32 - 1 : 0] s_axis_data5_tdata,
    input s_axis_data5_tvalid,
    output s_axis_data5_tready,
    input s_axis_data5_tlast,

    input s_axis_data6_aclk,
    input [32 - 1 : 0] s_axis_data6_tdata,
    input s_axis_data6_tvalid,
    output s_axis_data6_tready,
    input s_axis_data6_tlast,

    input s_axis_data7_aclk,
    input [32 - 1 : 0] s_axis_data7_tdata,
    input s_axis_data7_tvalid,
    output s_axis_data7_tready,
    input s_axis_data7_tlast,

    input  [`CHANNELS*`INDEX_WIDTH-1:0] xk,

    output peaks_ready,

  input s_axi_aclk     ,        // input wire s_axi_aclk
  input s_axi_aresetn  ,  // input wire s_axi_aresetn
  input [13:0] s_axi_awaddr   ,    // input wire [13 : 0] s_axi_awaddr
  input [2:0] s_axi_awprot   ,    // input wire [2 : 0] s_axi_awprot
  input s_axi_awvalid  ,  // input wire s_axi_awvalid
  output s_axi_awready  ,  // output wire s_axi_awready
  input [31:0] s_axi_wdata    ,      // input wire [31 : 0] s_axi_wdata
  input [3:0] s_axi_wstrb    ,      // input wire [3 : 0] s_axi_wstrb
  input s_axi_wvalid   ,    // input wire s_axi_wvalid
  output s_axi_wready   ,    // output wire s_axi_wready
  output [1:0] s_axi_bresp    ,      // output wire [1 : 0] s_axi_bresp
  output s_axi_bvalid   ,    // output wire s_axi_bvalid
  input s_axi_bready   ,    // input wire s_axi_bready
  input [13:0] s_axi_araddr   ,    // input wire [13 : 0] s_axi_araddr
  input [2:0] s_axi_arprot   ,    // input wire [2 : 0] s_axi_arprot
  input s_axi_arvalid  ,  // input wire s_axi_arvalid
  output s_axi_arready  ,  // output wire s_axi_arready
  output [31:0] s_axi_rdata    ,      // output wire [31 : 0] s_axi_rdata
  output [1:0] s_axi_rresp    ,      // output wire [1 : 0] s_axi_rresp
  output s_axi_rvalid   ,    // output wire s_axi_rvalid
  input s_axi_rready    // input wire s_axi_rready
        );


wire [32-`VALUE_WIDTH-1:0] values_zeros;
assign values_zeros = 0;
wire [`CHANNELS-1:0] resets_n;
wire [`CHANNELS-1:0] process_clks;
/* make vector of clocks */
assign process_clks = {
    s_axis_data7_aclk,
    s_axis_data6_aclk,
    s_axis_data5_aclk,
    s_axis_data4_aclk,
    s_axis_data3_aclk,
    s_axis_data2_aclk,
    s_axis_data1_aclk,
    s_axis_data0_aclk};

wire [`CHANNELS-1:0] s_axis_data_tvalid;
assign s_axis_data_tvalid = {
    s_axis_data7_tvalid,
    s_axis_data6_tvalid,
    s_axis_data5_tvalid,
    s_axis_data4_tvalid,
    s_axis_data3_tvalid,
    s_axis_data2_tvalid,
    s_axis_data1_tvalid,
    s_axis_data0_tvalid};

wire [`CHANNELS*32 - 1: 0] s_axis_data_tdata;
assign s_axis_data_tdata = {
    s_axis_data7_tdata,
    s_axis_data6_tdata,
    s_axis_data5_tdata,
    s_axis_data4_tdata,
    s_axis_data3_tdata,
    s_axis_data2_tdata,
    s_axis_data1_tdata,
    s_axis_data0_tdata};

wire [`CHANNELS - 1: 0] s_axis_data_tlast;
assign s_axis_data_tlast = {
    s_axis_data7_tlast,
    s_axis_data6_tlast,
    s_axis_data5_tlast,
    s_axis_data4_tlast,
    s_axis_data3_tlast,
    s_axis_data2_tlast,
    s_axis_data1_tlast,
    s_axis_data0_tlast};

// split output data into separate `channels
reg in_write;
wire [`CHANNELS-1:0] in_writes;
reg in_write_d;
reg [6:0] addr_wr;
reg [6:0] addr_wr_s;

assign s_axis_data0_tready = 1'b1;
assign s_axis_data1_tready = 1'b1;
assign s_axis_data2_tready = 1'b1;
assign s_axis_data3_tready = 1'b1;
assign s_axis_data4_tready = 1'b1;
assign s_axis_data5_tready = 1'b1;
assign s_axis_data6_tready = 1'b1;
assign s_axis_data7_tready = 1'b1;

wire [(`CHANNELS*`VALUE_WIDTH*`NUM_PEAKS) - 1 : 0] peaks;
wire [(`CHANNELS*`INDEX_WIDTH*`NUM_PEAKS) - 1 : 0] indices;

wire [`CHANNELS-1:0] last_out;
reg [`CHANNELS-1:0] r_last_out;
wire all_last_out;
reg all_last_out_d;
wire all_last_out_r;

reg [`CHANNELS*`INDEX_WIDTH-1:0] new_xk;
/* Create a local index counter instead of chained from FFT */
genvar x;
generate
    for (x=0; x < `CHANNELS; x = x + 1) begin
        always @(posedge process_clks[x])
            if (s_axis_data_tlast[x])
                new_xk[x*`INDEX_WIDTH +: `INDEX_WIDTH] <= 0;
            else if ( s_axis_data_tvalid[x] )
                new_xk[x*`INDEX_WIDTH +: `INDEX_WIDTH] <= new_xk[x*`INDEX_WIDTH +: `INDEX_WIDTH] + 1;
        end
    endgenerate

// Now replicate for each channel

genvar i;
generate
    for (i=0; i < `CHANNELS; i = i + 1) begin
        wire [32-1:0] intermediate_data1;
        wire [`VALUE_WIDTH-1:0] intermediate_data2;

        peak_detect_fast_shell peak_detect_fast_shell_inst
        (
            // inputs
            .clk      ( process_clks[i]                                 ) ,
                .aresetn  ( resets_n[i]                                     ) ,
                .valid    ( s_axis_data_tvalid[i]                           ) ,
                .last     ( s_axis_data_tlast[i]                            ) ,
                .last_out ( last_out[i]                                     ) ,
                .input_i  (s_axis_data_tdata[i*32 +: `VALUE_WIDTH]          ) ,
                .index_i  ( new_xk[i*`INDEX_WIDTH +: `INDEX_WIDTH]                ) ,
                // outputs
                .peaks     (peaks[i*`VALUE_WIDTH*`NUM_PEAKS +: `VALUE_WIDTH*`NUM_PEAKS] ),
                .indices   (indices[i*`INDEX_WIDTH*`NUM_PEAKS +: `INDEX_WIDTH*`NUM_PEAKS] )
                );
    end
endgenerate

/* now latch the last_outs */
genvar j;
generate
    for (j=0; j < `CHANNELS; j = j + 1) begin
        always @ (posedge process_clks[j])
            if (in_writes[j] || ~resets_n[j])
                r_last_out[j] <= 1'b0;
            else if (last_out[j])
                r_last_out[j] <= 1'b1;
        end
endgenerate

/* assign all_last_out = &r_last_out; */
/* and sync it */
sync_many #
	(
		.WIDTH(1)
	) sync_last_out
	(
        .clks (process_clks[0]),
        .ins   (&r_last_out),
        .outs (all_last_out)
	);

always @(posedge process_clks[0])
    all_last_out_d <= all_last_out;
assign all_last_out_r = (all_last_out && ~all_last_out_d);


sync_many #
	(
		.WIDTH   (`CHANNELS),
        .SYNC_FF (1)
	) sync_in_write
	(
        .clks (process_clks),
        .ins   ({`CHANNELS{in_write}}),
        .outs (in_writes)
	);

/* this needs some changes for timing issues */

/* have a big DPRAM for each of Peaks and Indices */
/* clock in one by one at active last */

wire        bram_clk_a;
wire        bram_en_a;
wire [3:0]  bram_we_a;
wire [13:0] bram_addr_a ;
wire [31:0] bram_wrdata_a;
wire [31:0] bram_rddata_a;
wire [31:0] bram_idx_rddata_a;
wire [31:0] bram_peak_rddata_a;


wire [`VALUE_WIDTH-1:0] peak_to_write;
reg  [`VALUE_WIDTH-1:0] peak_to_write_s;
wire [`INDEX_WIDTH-1:0] index_to_write;
reg  [`INDEX_WIDTH-1:0] index_to_write_s;

// controller for memory for peaks
bram_ctrl_2k bram_ctrl_peaks (
  .s_axi_aclk    ( s_axi_aclk    ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( bram_rddata_a )  // input wire [31 : 0] bram_rddata_a
);

dpram_128x32 dpram_peaks (
    /* from peak detect */
  .clka                 ( process_clks[0] ) ,    // input wire clka
  .ena                  ( 1'b1     ) ,      // input wire ena
  .wea                  ( in_write_d     ) ,      // input wire [0 : 0] wea
  .addra                ( addr_wr_s   ) ,  // input wire [9 : 0] addra
  .dina                 ( {values_zeros,peak_to_write_s}) ,    // input wire [9 : 0] dina
  .douta                (             ) ,  // output wire [9 : 0] douta

    /* to AXI */
  .clkb  ( bram_clk_a         ) ,    // input wire clkb
  .enb   ( !bram_addr_a[9]   ),
  .web   ( bram_we_a[0]       ) ,      // input wire [0 : 0] web
  .addrb ( bram_addr_a[8:2]  ) ,  // input wire [9 : 0] addrb
  .dinb  ( bram_wrdata_a ) ,    // input wire [9 : 0] dinb
  .doutb ( bram_peak_rddata_a ) // output wire [31 : 0] doutb
                              ) ;

dpram_128x32 dpram_indices (
    /* from peak detect */
  .clka                 ( process_clks[0] ),
  .ena                  ( 1'b1            ),
  .wea                  ( in_write_d        ),
  .addra                ( addr_wr_s         ),
  .dina                 ( {21'b0,index_to_write_s}  ),
  .douta                (                 ),

    /* to AXI */
  .clkb  ( bram_clk_a       ),
  .enb   ( bram_addr_a[9]   ),
  .web   ( bram_we_a[0]     ),
  .addrb ( bram_addr_a[8:2] ),
  .dinb  ( bram_wrdata_a    ),
  .doutb ( bram_idx_rddata_a    )
                                );
assign bram_rddata_a = bram_addr_a[9] ? bram_idx_rddata_a : bram_peak_rddata_a;

/* Mux and register (for timing) the peaks */
assign peak_to_write =  peaks[addr_wr * `VALUE_WIDTH +: `VALUE_WIDTH];
assign index_to_write = indices[addr_wr * `INDEX_WIDTH +: `INDEX_WIDTH];

always @ (posedge process_clks[0])
begin
    peak_to_write_s <= peak_to_write;
    index_to_write_s <= index_to_write;
end

    /* The in_write is write enable to dpram */
always @(posedge process_clks[0])
    if (~resets_n[0])
        in_write <= 1'b0;
    else if (all_last_out_r)
        in_write <= 1'b1;
    else if (addr_wr == (`NUM_PEAKS*`CHANNELS)-1)
        in_write <= 1'b0;

    /* generate the write address to dpram */
always @(posedge process_clks[0])
    if (~resets_n[0])
        addr_wr <= 0;
    else if (all_last_out_r)
        addr_wr <= 0;
    else if (addr_wr < `NUM_PEAKS*`CHANNELS-1)
    /* else if (in_write) */
        addr_wr <= addr_wr + 1;

always @(posedge process_clks[0])
begin
    in_write_d <= in_write;
    addr_wr_s <= addr_wr;
end

assign peaks_ready = (~in_write && in_write_d);

/* sync the resets */

sync_many #
	(
		.WIDTH(`CHANNELS)
	) sync_resets
	(
        .clks (process_clks),
        .ins   ({8{lresetn_stream}}),
        .outs (resets_n)
	);

    endmodule


