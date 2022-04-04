// Module    fft_top
// Function : Performs an FFT on
//          : multiple channels of incoming data S_AXIS
//          : presents AXIS master to downstream
//
// TODO Status bus is certainly incorrect
//
`include "constants.vh"

`timescale 1ns/1ps
//`include "c:\Users\David\Documents\boards\main\fpga\all_src\constants.vh"
module fft_top_2  (
    input reset, // synced to fft clk
    input disable_fft,
            //
            // AXI S slave - incoming data from window
            input  s_axis_data0_aclk,
            input  [32 - 1 : 0] s_axis_data0_tdata,
            input  s_axis_data0_tvalid,
            output  s_axis_data0_tready,
            input  s_axis_data0_tlast,

            input  s_axis_data1_aclk,
            input  [32 - 1 : 0] s_axis_data1_tdata,
            input  s_axis_data1_tvalid,
            output  s_axis_data1_tready,
            input  s_axis_data1_tlast,

            input  s_axis_data2_aclk,
            input  [32 - 1 : 0] s_axis_data2_tdata,
            input  s_axis_data2_tvalid,
            output  s_axis_data2_tready,
            input  s_axis_data2_tlast,

            input  s_axis_data3_aclk,
            input  [32 - 1 : 0] s_axis_data3_tdata,
            input  s_axis_data3_tvalid,
            output  s_axis_data3_tready,
            input  s_axis_data3_tlast,

            input  s_axis_data4_aclk,
            input  [32 - 1 : 0] s_axis_data4_tdata,
            input  s_axis_data4_tvalid,
            output  s_axis_data4_tready,
            input  s_axis_data4_tlast,

            input  s_axis_data5_aclk,
            input  [32 - 1 : 0] s_axis_data5_tdata,
            input  s_axis_data5_tvalid,
            output  s_axis_data5_tready,
            input  s_axis_data5_tlast,

            input  s_axis_data6_aclk,
            input  [32 - 1 : 0] s_axis_data6_tdata,
            input  s_axis_data6_tvalid,
            output  s_axis_data6_tready,
            input  s_axis_data6_tlast,

            input  s_axis_data7_aclk,
            input  [32 - 1 : 0] s_axis_data7_tdata,
            input  s_axis_data7_tvalid,
            output  s_axis_data7_tready,
            input  s_axis_data7_tlast,

            // config  port
            /* input wire s_axis_config_aclk, */
            /* input wire [15:0] s_axis_config_tdata , */
            /* input wire  s_axis_config_tvalid, */
            /* output wire s_axis_config_tready, */

            // output to downstream process
            input  m_axis_data0_aclk,
            output  [32 - 1 : 0] m_axis_data0_tdata,
            output  m_axis_data0_tvalid,
            input  m_axis_data0_tready,
            output  m_axis_data0_tlast,

            input  m_axis_data1_aclk,
            output  [32 - 1 : 0] m_axis_data1_tdata,
            output  m_axis_data1_tvalid,
            input  m_axis_data1_tready,
            output  m_axis_data1_tlast,

            input  m_axis_data2_aclk,
            output  [32 - 1 : 0] m_axis_data2_tdata,
            output  m_axis_data2_tvalid,
            input  m_axis_data2_tready,
            output  m_axis_data2_tlast,

            input  m_axis_data3_aclk,
            output  [32 - 1 : 0] m_axis_data3_tdata,
            output  m_axis_data3_tvalid,
            input  m_axis_data3_tready,
            output  m_axis_data3_tlast,

            input  m_axis_data4_aclk,
            output  [32 - 1 : 0] m_axis_data4_tdata,
            output  m_axis_data4_tvalid,
            input  m_axis_data4_tready,
            output  m_axis_data4_tlast,

            input  m_axis_data5_aclk,
            output  [32 - 1 : 0] m_axis_data5_tdata,
            output  m_axis_data5_tvalid,
            input  m_axis_data5_tready,
            output  m_axis_data5_tlast,

            input  m_axis_data6_aclk,
            output  [32 - 1 : 0] m_axis_data6_tdata,
            output  m_axis_data6_tvalid,
            input  m_axis_data6_tready,
            output  m_axis_data6_tlast,

            input  m_axis_data7_aclk,
            output  [32 - 1 : 0] m_axis_data7_tdata,
            output  m_axis_data7_tvalid,
            input  m_axis_data7_tready,
            output  m_axis_data7_tlast,

            input  m_axis_status_aclk,
            output  [7 : 0] m_axis_status_tdata,
            output  m_axis_status_tvalid,
            input  m_axis_status_tready,

            output reg  [`CHANNELS*`INDEX_WIDTH-1:0] xk,  // changes for different fft lengths

            // output flags
            output [6:0] fft_events
        );

wire [`CHANNELS-1:0] process_clks;
wire [`CHANNELS-1:0] resets;
wire [`CHANNELS -1 : 0] s_axis_data_tvalid;
wire [`CHANNELS*32 -1 : 0] s_axis_data_tdata;
wire [`CHANNELS*`TUSER_WIDTH -1 :0] m_axis_data_tuser;
wire [`CHANNELS-1 : 0] m_axis_data_tvalid_l         ;
wire [`CHANNELS-1 : 0] m_axis_data_tlast_l          ;
wire [`CHANNELS*8 - 1 : 0] m_axis_status_tdata_l        ;
wire [`CHANNELS-1 : 0] m_axis_status_tvalid_l       ;
wire [`CHANNELS-1 : 0] event_frame_started_l        ;
wire [`CHANNELS-1 : 0] event_tlast_unexpected_l     ;
wire [`CHANNELS-1 : 0] event_tlast_missing_l        ;
wire [`CHANNELS-1 : 0] event_fft_overflow_l         ;
wire [`CHANNELS-1 : 0] event_status_channel_halt_l  ;
wire [`CHANNELS-1 : 0] event_data_in_channel_halt_l ;
wire [`CHANNELS-1 : 0] event_data_out_channel_halt_l;
wire [`CHANNELS-1:0] m_axis_data_tready;
wire [`CHANNELS-1:0] s_axis_data_tlast;

wire event_frame_started        ;
wire event_tlast_unexpected     ;
wire event_tlast_missing        ;
wire event_fft_overflow         ;
wire event_status_channel_halt  ;
wire event_data_in_channel_halt ;
wire event_data_out_channel_halt;

wire [`CHANNELS-1 : 0] s_axis_config_tready;
wire [`CHANNELS-1 : 0] s_axis_data_tready;
wire [`CHANNELS*32 - 1 : 0] data_out;
reg  [`CHANNELS*32 - 1 : 0] r_data_out;

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


assign m_axis_data_tready = {
    m_axis_data7_tready,
    m_axis_data6_tready,
    m_axis_data5_tready,
    m_axis_data4_tready,
    m_axis_data3_tready,
    m_axis_data2_tready,
    m_axis_data1_tready,
    m_axis_data0_tready };

assign s_axis_data_tdata = {
    s_axis_data7_tdata,
    s_axis_data6_tdata,
    s_axis_data5_tdata,
    s_axis_data4_tdata,
    s_axis_data3_tdata,
    s_axis_data2_tdata,
    s_axis_data1_tdata,
    s_axis_data0_tdata};

assign s_axis_data_tvalid = {
    s_axis_data7_tvalid,
    s_axis_data6_tvalid,
    s_axis_data5_tvalid,
    s_axis_data4_tvalid,
    s_axis_data3_tvalid,
    s_axis_data2_tvalid,
    s_axis_data1_tvalid,
    s_axis_data0_tvalid};


/* split tready to separate buses */
assign s_axis_data0_tready = s_axis_data_tready[0];
assign s_axis_data1_tready = s_axis_data_tready[1];
assign s_axis_data2_tready = s_axis_data_tready[2];
assign s_axis_data3_tready = s_axis_data_tready[3];
assign s_axis_data4_tready = s_axis_data_tready[4];
assign s_axis_data5_tready = s_axis_data_tready[5];
assign s_axis_data6_tready = s_axis_data_tready[6];
assign s_axis_data7_tready = s_axis_data_tready[7];

assign s_axis_data_tlast = {
    s_axis_data7_tlast,
    s_axis_data6_tlast,
    s_axis_data5_tlast,
    s_axis_data4_tlast,
    s_axis_data3_tlast,
    s_axis_data2_tlast,
    s_axis_data2_tlast,
    s_axis_data0_tlast};

wire [`CHANNELS-1:0] disable_fft_s;


assign event_frame_started         = event_frame_started_l[0]        ;
assign event_tlast_unexpected      = event_tlast_unexpected_l[0]     ;
assign event_tlast_missing         = event_tlast_missing_l[0]        ;
assign event_fft_overflow          = event_fft_overflow_l[0]         ;
assign event_status_channel_halt   = event_status_channel_halt_l[0]  ;
assign event_data_in_channel_halt  = event_data_in_channel_halt_l[0] ;
assign event_data_out_channel_halt = event_data_out_channel_halt_l[0];

assign fft_events = {
    event_frame_started        ,
    event_tlast_unexpected     ,
    event_tlast_missing        ,
    event_fft_overflow         ,
    event_status_channel_halt  ,
    event_data_in_channel_halt ,
    event_data_out_channel_halt
    };

/* assign the XK from user data */
genvar m;
generate
    for (m=0; m < `CHANNELS; m = m + 1) begin
        always @ (posedge process_clks[m])
            xk[m*`INDEX_WIDTH +: `INDEX_WIDTH] <= m_axis_data_tuser[m*`TUSER_WIDTH +: `INDEX_WIDTH];
            /* xk[m*`INDEX_WIDTH +: `INDEX_WIDTH] <= m_axis_data_tuser[m*24 +: `INDEX_WIDTH]; */
    end
endgenerate

genvar i;
generate
    wire [31:0] fft_out_local;

    for (i=0; i < `CHANNELS; i = i + 1) begin
        //           xfft_pl_32_scaled_cr_1 my_fft (
        if (`PIXEL_SIZE == 2048)
            xfft_pl_2048_scaled_cr my_fft (
        .aclk                        ( process_clks[i]   ) ,                                                // input wire aclk
        .aresetn         ( ~resets[i]           ) ,

        .s_axis_config_tdata         ( 16'b0    ) ,  // input wire [15 : 0] s_axis_config_tdata
        .s_axis_config_tvalid        ( 0        ) ,  // input wire s_axis_config_tvalid
        .s_axis_config_tready        ( ) ,  // output wire s_axis_config_tready

        .s_axis_data_tdata           ( s_axis_data_tdata[i*32 +: 32]  ) ,  // input wire [31 : 0] s_axis_data_tdata
        .s_axis_data_tvalid          ( s_axis_data_tvalid[i] && ~disable_fft_s[i] ) ,  // input wire s_axis_data_tvalid
        .s_axis_data_tready          ( s_axis_data_tready       [i] ) ,  // output wire s_axis_data_tready
        .s_axis_data_tlast           ( s_axis_data_tlast[i]      ) ,  // input wire s_axis_data_tlast

        .m_axis_data_tdata           (  data_out[i*32 +: 32]          ) ,  // output wire [31 : 0] m_axis_data_tdata
        .m_axis_data_tuser           ( m_axis_data_tuser[i*24 +: 24]  ) ,  // output wire [7 : 0] m_axis_data_tuser
        .m_axis_data_tvalid          ( m_axis_data_tvalid_l[i] ) ,  // output wire m_axis_data_tvalid
        .m_axis_data_tready          ( m_axis_data_tready[i]  ) ,  // input wire m_axis_data_tready
        .m_axis_data_tlast           ( m_axis_data_tlast_l[i] ) ,  // output wire m_axis_data_tlast
        //
        .m_axis_status_tdata         ( m_axis_status_tdata_l[i*8 +: 8] ) ,  // output wire [7 : 0] m_axis_status_tdata
        .m_axis_status_tvalid        ( m_axis_status_tvalid_l[i] ) ,  // output wire m_axis_status_tvalid
        .m_axis_status_tready        ( m_axis_status_tready        ) ,  // input wire m_axis_status_tready

        .event_frame_started         ( event_frame_started_l[i]) , // output wire event_frame_started
        .event_tlast_unexpected      ( event_tlast_unexpected_l[i]) , // output wire event_tlast_unexpected
        .event_tlast_missing         ( event_tlast_missing_l[i]) , // output wire event_tlast_missing
        .event_fft_overflow          ( event_fft_overflow_l[i]) , // output wire event_fft_overflow
        .event_status_channel_halt   ( event_status_channel_halt_l[i]) , // output wire event_status_channel_halt
        .event_data_in_channel_halt  ( event_data_in_channel_halt_l[i]) , // output wire event_data_in_channel_halt
        .event_data_out_channel_halt ( event_data_out_channel_halt_l[i])   // output wire event_data_out_channel_halt
    );
    else
        xfft_pl_32_scaled_cr_1 my_fft (
    .aclk                        ( process_clks[i] ),
    .aresetn         ( ~resets[i]           ) ,

    .s_axis_config_tdata         ( 0         ) ,  // input wire [15 : 0] s_axis_config_tdata
    .s_axis_config_tvalid        ( 0        ) ,  // input wire s_axis_config_tvalid
    .s_axis_config_tready        (   ) ,  // output wire s_axis_config_tready

    .s_axis_data_tdata           ( s_axis_data_tdata[i*32 +: 32]  ) ,  // input wire [31 : 0] s_axis_data_tdata
    .s_axis_data_tvalid          ( s_axis_data_tvalid[i]          ) ,  // input wire s_axis_data_tvalid
    .s_axis_data_tready          ( s_axis_data_tready       [i] ) ,  // output wire s_axis_data_tready
    .s_axis_data_tlast           ( s_axis_data_tlast[i]           ) ,  // input wire s_axis_data_tlast

    .m_axis_data_tdata           (  data_out[i*32 +: 32]          ) ,  // output wire [31 : 0] m_axis_data_tdata
    .m_axis_data_tuser           ( m_axis_data_tuser[i*16 +: 16]  ) ,  // output wire [7 : 0] m_axis_data_tuser
    .m_axis_data_tvalid          ( m_axis_data_tvalid_l         [i] ) ,  // output wire m_axis_data_tvalid
    .m_axis_data_tready          ( m_axis_data_tready          ) ,  // input wire m_axis_data_tready
    .m_axis_data_tlast           ( m_axis_data_tlast_l          [i] ) ,  // output wire m_axis_data_tlast

    .m_axis_status_tdata         ( m_axis_status_tdata_l        [i*8 +: 8] ) ,  // output wire [7 : 0] m_axis_status_tdata
    .m_axis_status_tvalid        ( m_axis_status_tvalid_l       [i] ) ,  // output wire m_axis_status_tvalid
    .m_axis_status_tready        ( m_axis_status_tready        ) ,  // input wire m_axis_status_tready

    .event_frame_started         ( event_frame_started_l         [i]) , // output wire event_frame_started
    .event_tlast_unexpected      ( event_tlast_unexpected_l      [i]) , // output wire event_tlast_unexpected
    .event_tlast_missing         ( event_tlast_missing_l         [i]) , // output wire event_tlast_missing
    .event_fft_overflow          ( event_fft_overflow_l          [i]) , // output wire event_fft_overflow
    .event_status_channel_halt   ( event_status_channel_halt_l   [i]) , // output wire event_status_channel_halt
    .event_data_in_channel_halt  ( event_data_in_channel_halt_l  [i]) , // output wire event_data_in_channel_halt
    .event_data_out_channel_halt ( event_data_out_channel_halt_l [i])   // output wire event_data_out_channel_halt
);


// data out
//assign m_axis_data_tdata[i*32 +: 32] 	= fft_out_local;
/* assign s_axis_config_tready = s_axis_config_tready_l[0]; */
assign m_axis_status_tdata = m_axis_status_tdata_l[7:0];
     end

 endgenerate

 reg tlast[`CHANNELS-1:0];
 reg tvalid[`CHANNELS-1:0];

 genvar k;
 generate
     for (k=0; k < `CHANNELS; k = k + 1) begin
         always @ (posedge process_clks[k])
         begin
             r_data_out[k * 32 +: 32] <= data_out[k * 32 +: 32];
             tlast[k] <= m_axis_data_tlast_l[k];
             tvalid[k] <= m_axis_data_tvalid_l[k];
         end
     end
 endgenerate

// split data into separate channels
assign m_axis_data0_tdata = r_data_out[0 * 32 +: 32];
assign m_axis_data1_tdata = r_data_out[1 * 32 +: 32];
assign m_axis_data2_tdata = r_data_out[2 * 32 +: 32];
assign m_axis_data3_tdata = r_data_out[3 * 32 +: 32];
assign m_axis_data4_tdata = r_data_out[4 * 32 +: 32];
assign m_axis_data5_tdata = r_data_out[5 * 32 +: 32];
assign m_axis_data6_tdata = r_data_out[6 * 32 +: 32];
assign m_axis_data7_tdata = r_data_out[7 * 32 +: 32];

// split last into separate channels
assign m_axis_data0_tlast = tlast[0];
assign m_axis_data1_tlast = tlast[1];
assign m_axis_data2_tlast = tlast[2];
assign m_axis_data3_tlast = tlast[3];
assign m_axis_data4_tlast = tlast[4];
assign m_axis_data5_tlast = tlast[5];
assign m_axis_data6_tlast = tlast[6];
assign m_axis_data7_tlast = tlast[7];

// split valid into separate channels
assign m_axis_data0_tvalid = tvalid[0];
assign m_axis_data1_tvalid = tvalid[1];
assign m_axis_data2_tvalid = tvalid[2];
assign m_axis_data3_tvalid = tvalid[3];
assign m_axis_data4_tvalid = tvalid[4];
assign m_axis_data5_tvalid = tvalid[5];
assign m_axis_data6_tvalid = tvalid[6];
assign m_axis_data7_tvalid = tvalid[7];

 /* Sync for disable signal to FFT */
   /* xpm_cdc_array_single #( */
   /*    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10 */
   /*    .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values */
   /*    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages */
   /*    .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input */
   /*    .WIDTH(1)           // DECIMAL; range: 1-1024 */
   /* ) */
   /* sync_disable_fft ( */
   /*    .dest_out(disable_fft_s), // WIDTH-bit output: src_in synchronized to the destination clock domain. This */
   /*                         // output is registered. */

   /*    .dest_clk(s_axis_data_aclk), // 1-bit input: Clock signal for the destination clock domain. */
   /*   // .src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1 */
   /*    .src_in(disable_fft)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock */
   /*                         // domain. It is assumed that each bit of the array is unrelated to the others. This */
   /*                         // is reflected in the constraints applied to this macro. To transfer a binary value */
   /*                         // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead. */

   /* ); */
sync_many #
	(
		.WIDTH(8)
	) sync_disable
	(
        .clks (process_clks),
        .ins   ({8{disable_fft}}),
        .outs (disable_fft_s)
	);
sync_many #
	(
		.WIDTH(8)
	) sync_reset
	(
        .clks (process_clks),
        .ins   ({8{reset}}),
        .outs (resets)
	);

endmodule

