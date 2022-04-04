// Module
// Function : The input from ADC to output parallel bus
//

`include "constants.vh"

`timescale 1ns/1ps
module input_top_2  (
    /* AXI S slave - incoming data from window */
    input        S_AXIS_ACLK,
    input        S_AXIS_ARESETN,
    input        S_AXIS_TVALID,
    input [`CHANNELS*16-1 :0] S_AXIS_TDATA,
    input        S_AXIS_TLAST,
    output       S_AXIS_TREADY,

    /* AXIS Master to downstream window */
    input         M_AXIS_ACLK,
    input         M_AXIS_ARESETN,
    output        M_AXIS_TVALID,
    output [`CHANNELS*16-1:0] M_AXIS_TDATA,
    output        M_AXIS_TLAST,
    input         M_AXIS_TREADY,

output dbg_last,
output dbg_rd_en,
output dbg_full,
output dbg_rst_fifo,
output dbg_disable_fiford_s ,
output dbg_empty,
output dbg_in_capture,
output dbg_debug_go,
output dbg_in_pixel,
    // from & to mc
    input clk_control,
    input clk_stream,
    input go,
    input reset_fifo,
    output dbg_go_s,
    output dbg_go_r,
    output pixel_done,
     input rst_stream_n,
     input rst_control_n,
     input rst_adc_n,
     input disable_fifowr,
     input [`CHANNELS-1:0] disable_fiford,

     output reg [9:0] debug_data,
    // From ADC
    input [89:0]  data_in_to_device,
        input        clk_adc           ,
        output [8:0] bitslips,

        output debug_capture,

    // control
    input lreset_n,

    input debug_go,
    input [1:0] dbg_mux,

        // AXI to debug adc capture memory
    input         s_axi_adc0_aclk    ,        // input wire s_axi_aclk
    input         s_axi_adc0_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_adc0_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_adc0_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_adc0_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_adc0_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_adc0_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_adc0_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_adc0_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_adc0_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_adc0_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_adc0_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_adc0_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_adc0_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_adc0_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_adc0_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_adc0_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_adc0_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_adc0_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_adc0_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_adc0_rready  ,      // input wire s_axi_rready

    input         s_axi_adc1_aclk    ,        // input wire s_axi_aclk
    input         s_axi_adc1_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_adc1_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_adc1_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_adc1_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_adc1_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_adc1_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_adc1_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_adc1_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_adc1_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_adc1_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_adc1_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_adc1_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_adc1_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_adc1_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_adc1_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_adc1_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_adc1_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_adc1_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_adc1_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_adc1_rready  ,      // input wire s_axi_rready

    input         s_axi_adc2_aclk    ,        // input wire s_axi_aclk
    input         s_axi_adc2_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_adc2_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_adc2_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_adc2_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_adc2_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_adc2_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_adc2_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_adc2_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_adc2_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_adc2_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_adc2_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_adc2_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_adc2_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_adc2_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_adc2_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_adc2_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_adc2_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_adc2_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_adc2_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_adc2_rready  ,      // input wire s_axi_rready

    // masters to downstream process
    input wire m_axis_data0_aclk,
    output wire [31:0] m_axis_data0_tdata,
    output wire m_axis_data0_tvalid,
    input wire m_axis_data0_tready,
    output wire m_axis_data0_tlast,

    input wire m_axis_data1_aclk,
    output wire [31:0] m_axis_data1_tdata,
    output wire m_axis_data1_tvalid,
    input wire m_axis_data1_tready,
    output wire m_axis_data1_tlast,

    input wire m_axis_data2_aclk,
    output wire [31:0] m_axis_data2_tdata,
    output wire m_axis_data2_tvalid,
    input wire m_axis_data2_tready,
    output wire m_axis_data2_tlast,

    input wire m_axis_data3_aclk,
    output wire [31:0] m_axis_data3_tdata,
    output wire m_axis_data3_tvalid,
    input wire m_axis_data3_tready,
    output wire m_axis_data3_tlast,

    input wire m_axis_data4_aclk,
    output wire [31:0] m_axis_data4_tdata,
    output wire m_axis_data4_tvalid,
    input wire m_axis_data4_tready,
    output wire m_axis_data4_tlast,

    input wire m_axis_data5_aclk,
    output wire [31:0] m_axis_data5_tdata,
    output wire m_axis_data5_tvalid,
    input wire m_axis_data5_tready,
    output wire m_axis_data5_tlast,

    input wire m_axis_data6_aclk,
    output wire [31:0] m_axis_data6_tdata,
    output wire m_axis_data6_tvalid,
    input wire m_axis_data6_tready,
    output wire m_axis_data6_tlast,

    input wire m_axis_data7_aclk,
    output wire [31:0] m_axis_data7_tdata,
    output wire m_axis_data7_tvalid,
    input wire m_axis_data7_tready,
    output wire m_axis_data7_tlast

    );

wire [`CHANNELS*16 - 1 : 0] fifo_data_out;
wire [`CHANNELS-1:0] process_clks;
wire [`CHANNELS-1:0] reset_fifos;
wire [`CHANNELS-1:0] empty;
wire [`CHANNELS-1:0] full; // for debug
wire [`CHANNELS-1:0] rd_en;
reg  [`CHANNELS-1:0] m_axis_data_tvalid_l;

/* wire [79:0] dout; */
wire        bitslip            ;
reg [10:0] cnt = 0;
wire [89:0] re_order;
wire go_s;
wire go_r;
reg go_d;
reg in_pixel;
wire last;
wire [`CHANNELS-1:0] tlast;
/* reg in_pixel_d; */
wire lresetn_adc;
reg [10:0] debug_addr;
reg in_capture;
wire debug_go_s;

/* pipeline registers for debug capture */
wire [1:0] dbg_mux_l;
reg [9:0] reg0, reg1, reg2;

wire        bram0_clk_a;
wire        bram0_en_a;
wire [3:0]  bram0_we_a;
wire [31:0] bram0_wrdata_a;
wire [11:0] bram0_rddata_a;
wire [12:0] bram0_addr_a;

wire        bram1_clk_a;
wire        bram1_en_a;
wire [3:0]  bram1_we_a;
wire [31:0] bram1_wrdata_a;
wire [11:0] bram1_rddata_a;
wire [12:0] bram1_addr_a;

wire        bram2_clk_a;
wire        bram2_en_a;
wire [3:0]  bram2_we_a;
wire [31:0] bram2_wrdata_a;
wire [11:0] bram2_rddata_a;
wire [12:0] bram2_addr_a;

wire lreset_n_adc;

wire [`CHANNELS-1:0] disable_fiford_s;

/* make vector of clocks */
assign process_clks = {
    m_axis_data7_aclk,
    m_axis_data6_aclk,
    m_axis_data5_aclk,
    m_axis_data4_aclk,
    m_axis_data3_aclk,
    m_axis_data2_aclk,
    m_axis_data1_aclk,
    m_axis_data0_aclk};

   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(2),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(0)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_rst_inst (
      .dest_arst(lreset_n_adc), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                             // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                             // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                             // (DEST_SYNC_FF*dest_clk) period.

      .dest_clk(clk_adc),   // 1-bit input: Destination clock.
      .src_arst(lreset_n)    // 1-bit input: Source asynchronous reset signal.
   );


/* First must separate input bus into 9 bytes of 10 bits each */

// data coming from selectio wizard is not ordered correctly
// so here we re-order it
genvar j,k;
generate
    for (j = 0; j < 10; j = j + 1) begin
        for (k = 0; k < 9; k = k + 1) begin
            assign re_order[k*10 + j] = data_in_to_device[j*9 + k];
        end
    end
endgenerate

// debug data
always @ (posedge clk_adc)
    debug_data <= re_order[9:0];

// generate correct frame sync from the frame data stream
slip_detect slip_detect_inst
            (
    .clk    ( clk_adc       ) , // input clk_in_p
    .resetn ( lreset_n_adc  ) ,
    .slip   ( bitslip       ) , // input bitslip
    .data   ( re_order[89:80] )
                            ) ;

assign bitslips = {9{bitslip}};

/* The main FIFO from clk_adc domain to process_clks domains */
genvar h;
generate
    for (h=0; h < `CHANNELS; h = h + 1) begin
        adc_fifo adc_fifo_inst
                    (
            .rst    ( reset_fifo   ) ,
            .wr_clk ( clk_adc                         ) ,
            .rd_clk ( process_clks[h]                 ) ,
            .din    ( {S_AXIS_TLAST, S_AXIS_TDATA[h*16 +: 16]}    ) ,
            .wr_en  ( S_AXIS_TVALID  ) ,
            /* .wr_en  ( in_pixel  ) , */
            /* .wr_en  (( in_pixel && ~disable_fifowr_s) ) , */
            .rd_en  ( rd_en[h]                        ) ,
            /* .dout   ( {tlast[h], dout[h*10 +: 10]}    ) , */
            .dout   ( {tlast[h], fifo_data_out[h*16 +: 16]} ) ,
            .full   ( full[h]                         ) ,
            .empty  ( empty[h]                        )
                                                      ) ;
    end
endgenerate

/* split data from fifo to separate buses */
assign m_axis_data0_tdata = {16'b0, fifo_data_out[(0 * 16) +: 16]};
assign m_axis_data1_tdata = {16'b0, fifo_data_out[(1 * 16) +: 16]};
assign m_axis_data2_tdata = {16'b0, fifo_data_out[(2 * 16) +: 16]};
assign m_axis_data3_tdata = {16'b0, fifo_data_out[(3 * 16) +: 16]};
assign m_axis_data4_tdata = {16'b0, fifo_data_out[(4 * 16) +: 16]};
assign m_axis_data5_tdata = {16'b0, fifo_data_out[(5 * 16) +: 16]};
assign m_axis_data6_tdata = {16'b0, fifo_data_out[(6 * 16) +: 16]};
assign m_axis_data7_tdata = {16'b0, fifo_data_out[(7 * 16) +: 16]};

assign m_axis_data0_tlast = tlast[0];
assign m_axis_data1_tlast = tlast[1];
assign m_axis_data2_tlast = tlast[2];
assign m_axis_data3_tlast = tlast[3];
assign m_axis_data4_tlast = tlast[4];
assign m_axis_data5_tlast = tlast[5];
assign m_axis_data6_tlast = tlast[6];
assign m_axis_data7_tlast = tlast[7];


// always read from FIFO when it is NOT empty
genvar r;
generate
    for (r = 0; r < `CHANNELS; r = r + 1) begin
        assign  rd_en[r] = (!empty[r] & !disable_fiford_s[r]);
    end
endgenerate

assign dbg_rd_en = rd_en[0];
assign dbg_empty = empty[0];
assign dbg_full = full[0];
assign dbg_rst_fifo = reset_fifo;

wire [`CHANNELS-1:0] lreset_n_s;
sync_many #
	(
		.WIDTH(8)
	) sync_lresetn
	(
        .clks (process_clks),
        .ins   ({8{lreset_n}}),
        .outs (lreset_n_s)
	);
/* sync_many # */
/* 	( */
/* 		.WIDTH(8) */
/* 	) sync_reset_fifos */
/* 	( */
/*         .clks (process_clks), */
/*         .ins   ({8{reset_fifo}}), */
/*         .outs (reset_fifos) */
/* 	); */

// downstream AXIS valid only when reading from FIFO
genvar m;
generate
    for (m = 0; m < `CHANNELS; m = m + 1) begin
        always @ (posedge process_clks[m] or negedge lreset_n_s[m])
            if (!lreset_n_s[m])
                m_axis_data_tvalid_l[m] <= 1'b0;
            else
                m_axis_data_tvalid_l[m] <= rd_en[m];
        end
endgenerate

assign m_axis_data0_tvalid = m_axis_data_tvalid_l[0];
assign m_axis_data1_tvalid = m_axis_data_tvalid_l[1];
assign m_axis_data2_tvalid = m_axis_data_tvalid_l[2];
assign m_axis_data3_tvalid = m_axis_data_tvalid_l[3];
assign m_axis_data4_tvalid = m_axis_data_tvalid_l[4];
assign m_axis_data5_tvalid = m_axis_data_tvalid_l[5];
assign m_axis_data6_tvalid = m_axis_data_tvalid_l[6];
assign m_axis_data7_tvalid = m_axis_data_tvalid_l[7];


my_sync
sync_reset (
    .clk   ( clk_adc     ) ,
    .in    ( lreset_n    ) ,
    .out   ( lresetn_adc )
                         ) ;

// do the "go" for N samples (2048)
always @(posedge clk_adc or negedge lresetn_adc)
    if (!lresetn_adc)
        cnt <= `PIXEL_SIZE-1;
    else if (go_r)
        cnt <= `PIXEL_SIZE-1;
    else if (in_pixel)
        cnt <= cnt - 1;

assign last = (cnt == 0) ? 1'b1 : 1'b0;
assign dbg_last = last;
assign M_AXIS_TLAST = last;

/* We assume that the FIFO is NEVER full */
// probably true since processing at more than 100MHz
always @(posedge clk_adc or negedge lresetn_adc)
    if (!lresetn_adc)
        in_pixel <= 1'b0;
    else if ( go_r)
        in_pixel <= 1'b1;
    else if (cnt == 0)
        in_pixel <= 1'b0;

assign M_AXIS_TVALID = in_pixel;

/* always @(posedge clk_adc) */
assign dbg_in_pixel = in_pixel;
assign dbg_go_r = go_r;

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(1),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_go (
      .dest_pulse(go_s),
      .dest_clk(clk_adc),
      .dest_rst(!rst_adc_n),
      .src_clk(clk_stream),
      .src_pulse(go),
      .src_rst(!rst_stream_n));

assign dbg_go_s = go_s;

always @(posedge clk_adc)
    go_d <= go_s;

assign go_r = (go_s && !go_d) ? 1'b1 : 1'b0;


edge_detect #(
    .TYPE (0)  // 0 falling , 1 rising
) edge_pixel_done_f (
    .clk ( clk_adc),
    .o   ( pixel_done),
    .i   ( in_pixel)
);

// controller for memory for capture
bram_ctrl_2k bram_ctrl_capture0 (
  .s_axi_aclk    ( s_axi_adc0_aclk    ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_adc0_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_adc0_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_adc0_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_adc0_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_adc0_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_adc0_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_adc0_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_adc0_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_adc0_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_adc0_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_adc0_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_adc0_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_adc0_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_adc0_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_adc0_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_adc0_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_adc0_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_adc0_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_adc0_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_adc0_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram0_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram0_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram0_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram0_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram0_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {20'h0, bram0_rddata_a })  // input wire [31 : 0] bram_rddata_a
);
bram_ctrl_2k bram_ctrl_capture1 (
  .s_axi_aclk    ( s_axi_adc1_aclk    ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_adc1_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_adc1_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_adc1_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_adc1_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_adc1_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_adc1_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_adc1_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_adc1_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_adc1_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_adc1_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_adc1_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_adc1_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_adc1_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_adc1_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_adc1_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_adc1_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_adc1_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_adc1_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_adc1_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_adc1_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram1_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram1_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram1_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram1_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram1_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {20'h0, bram1_rddata_a })  // input wire [31 : 0] bram_rddata_a
);
bram_ctrl_2k bram_ctrl_capture2 (
  .s_axi_aclk    ( s_axi_adc2_aclk    ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_adc2_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_adc2_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_adc2_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_adc2_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_adc2_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_adc2_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_adc2_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_adc2_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_adc2_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_adc2_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_adc2_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_adc2_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_adc2_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_adc2_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_adc2_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_adc2_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_adc2_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_adc2_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_adc2_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_adc2_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram2_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram2_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram2_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram2_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram2_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {20'h0, bram2_rddata_a })  // input wire [31 : 0] bram_rddata_a
);

dpram_2kx12 debug_dpram_ch0 (
  .clka                 ( clk_adc ) ,    // input wire clka
  .ena                  ( 1'b1     ) ,      // input wire ena
  .wea                  ( in_capture     ) ,      // input wire [0 : 0] wea
  .addra                ( debug_addr   ) ,  // input wire [9 : 0] addra
  .dina                 ( {2'b0,reg0}  ) ,    // input wire [9 : 0] dina
  /* .dina                 ( {2'b0,re_order[19:10]}  ) ,    // input wire [9 : 0] dina */
  .douta                (             ) ,  // output wire [9 : 0] douta

  .clkb  ( bram0_clk_a         ) ,    // input wire clkb
  .enb   ( bram0_en_a          ) ,      // input wire enb
  .web   ( bram0_we_a[0]       ) ,      // input wire [0 : 0] web
  .addrb ( bram0_addr_a[12:2]  ) ,  // input wire [9 : 0] addrb
  .dinb  ( bram0_wrdata_a[11:0] ) ,    // input wire [9 : 0] dinb
  .doutb ( bram0_rddata_a      ) // output wire [15 : 0] doutb
                              ) ;

dpram_2kx12 debug_dpram_ch1 (
  .clka                 ( clk_adc ) ,    // input wire clka
  .ena                  ( 1'b1     ) ,      // input wire ena
  .wea                  ( in_capture     ) ,      // input wire [0 : 0] wea
  .addra                ( debug_addr   ) ,  // input wire [9 : 0] addra
  .dina                 ( {2'b0,reg1}  ) ,    // input wire [9 : 0] dina
  .douta                (             ) ,  // output wire [9 : 0] douta

  .clkb  ( bram1_clk_a         ) ,    // input wire clkb
  .enb   ( bram1_en_a          ) ,      // input wire enb
  .web   ( bram1_we_a[0]       ) ,      // input wire [0 : 0] web
  .addrb ( bram1_addr_a[12:2]  ) ,  // input wire [9 : 0] addrb
  .dinb  ( bram1_wrdata_a[11:0] ) ,    // input wire [9 : 0] dinb
  .doutb ( bram1_rddata_a      ) // output wire [15 : 0] doutb
                              ) ;
dpram_2kx12 debug_dpram_ch2 (
  .clka                 ( clk_adc ) ,    // input wire clka
  .ena                  ( 1'b1     ) ,      // input wire ena
  .wea                  ( in_capture     ) ,      // input wire [0 : 0] wea
  .addra                ( debug_addr   ) ,  // input wire [9 : 0] addra
  .dina                 ( {2'b0,reg2}  ) ,    // input wire [9 : 0] dina
  .douta                (             ) ,  // output wire [9 : 0] douta

  .clkb  ( bram2_clk_a         ) ,    // input wire clkb
  .enb   ( bram2_en_a          ) ,      // input wire enb
  .web   ( bram2_we_a[0]       ) ,      // input wire [0 : 0] web
  .addrb ( bram2_addr_a[12:2]  ) ,  // input wire [9 : 0] addrb
  .dinb  ( bram2_wrdata_a[11:0] ) ,    // input wire [9 : 0] dinb
  .doutb ( bram2_rddata_a      ) // output wire [15 : 0] doutb
                              ) ;

// control the debug capture process
// first sync debug_go to adc domain

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(1),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_debug_go (
      .dest_pulse(debug_go_s), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                               // transfer is correctly initiated on src_pulse input. This output is
                               // combinatorial unless REG_OUTPUT is set to 1.

      .dest_clk(clk_adc),     // 1-bit input: Destination clock.
      .dest_rst(!rst_adc_n),     // 1-bit input: optional; required when RST_USED = 1
      .src_clk(clk_control),       // 1-bit input: Source clock.
      .src_pulse(debug_go),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                               // destination clock domain. The minimum gap between each pulse transfer must be
                               // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                               // between the falling edge of a src_pulse to the rising edge of the next
                               // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                               // will generate a pulse the size of one dest_clk period in the destination
                               // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                               // src_rst and/or dest_rst are asserted.

      .src_rst(!rst_control_n)        // 1-bit input: optional; required when RST_USED = 1
   );

always @ (posedge clk_adc or negedge rst_adc_n)
    /* if (lreset_n) */
    if (!rst_adc_n)
        in_capture <= 1'b0;
    else if (debug_go_s)
        in_capture <= 1'b1;
    else if (&debug_addr)
        in_capture <= 1'b0;

assign dbg_in_capture = in_capture;
assign dbg_debug_go = debug_go_s;

always @ (posedge clk_adc or negedge rst_adc_n)
    if (!rst_adc_n)
        debug_addr <= 0;
    else if (debug_go_s)
        debug_addr <= 0;
    else if (in_capture && ~&debug_addr)
        debug_addr <= debug_addr + 1;

assign debug_capture = debug_go_s;

// sync dbg_mux to clk_adc
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(2)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_inst (
      .dest_out(dbg_mux_l), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.

      .dest_clk(clk_adc), // 1-bit input: Clock signal for the destination clock domain.
     // .src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(dbg_mux)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                           // domain. It is assumed that each bit of the array is unrelated to the others. This
                           // is reflected in the constraints applied to this macro. To transfer a binary value
                           // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

   );

 sync_many #( .WIDTH(8)) sync_disable_fiford (
    .clks ( process_clks     ) ,
    .ins  ( disable_fiford   ) ,
    .outs ( disable_fiford_s )) ;

assign dbg_disable_fiford_s = disable_fiford_s[0];

 sync_many #( .WIDTH(1)) sync_disable_fifowr (
    .clks ( clk_adc     ) ,
    .ins  ( disable_fifowr   ) ,
    .outs ( disable_fifowr_s )) ;

/* now mux the debug signals into regs */
always @(posedge clk_adc)
begin
    if (dbg_mux_l == 2'b00)
    begin
        reg0 <= re_order[9:0];
        reg1 <= re_order[19:10];
        reg2 <= re_order[29:20];
    end
    else if (dbg_mux_l == 2'b01)
    begin
        reg0 <= re_order[29:20];
        reg1 <= re_order[39:30];
        reg2 <= re_order[49:40];
    end
    else if (dbg_mux_l == 2'b10)
    begin
        reg0 <= re_order[49:40];
        reg1 <= re_order[59:50];
        reg2 <= re_order[69:60];
    end else
    begin
        reg0 <= re_order[59:50];
        reg1 <= re_order[69:60];
        reg2 <= re_order[79:70];
    end
end

/* Collect 8 `channels of data for passing through Window function */
genvar n;
    generate
        for (n=0; n < `CHANNELS; n = n + 1) begin

            assign M_AXIS_TDATA[n*16 +: 10]      = re_order[n*10 +: 10];
            assign M_AXIS_TDATA[n*16 + 10 +: 6] = 0;

        end
    endgenerate
assign S_AXIS_TREADY = 1'b1;

endmodule

