// Module    window_top
// Function : Performs a squared absolute value on incoming streams
//          : by squaring real and imaginary separately then adding results.
//          : input is stream of 32 bits, 16 & 16
//

`include "constants.vh"

`timescale 1ns/1ps
module mult_add_top_2  (
            /* input disable_power, */
            input select_average,

            input wire s_axis_data0_aclk,
            input wire [32 - 1 : 0] s_axis_data0_tdata,
            input wire s_axis_data0_tvalid,
            output wire s_axis_data0_tready,
            input wire s_axis_data0_tlast,

            input wire s_axis_data1_aclk,
            input wire [32 - 1 : 0] s_axis_data1_tdata,
            input wire s_axis_data1_tvalid,
            output wire s_axis_data1_tready,
            input wire s_axis_data1_tlast,

            input wire s_axis_data2_aclk,
            input wire [32 - 1 : 0] s_axis_data2_tdata,
            input wire s_axis_data2_tvalid,
            output wire s_axis_data2_tready,
            input wire s_axis_data2_tlast,

            input wire s_axis_data3_aclk,
            input wire [32 - 1 : 0] s_axis_data3_tdata,
            input wire s_axis_data3_tvalid,
            output wire s_axis_data3_tready,
            input wire s_axis_data3_tlast,

            input wire s_axis_data4_aclk,
            input wire [32 - 1 : 0] s_axis_data4_tdata,
            input wire s_axis_data4_tvalid,
            output wire s_axis_data4_tready,
            input wire s_axis_data4_tlast,

            input wire s_axis_data5_aclk,
            input wire [32 - 1 : 0] s_axis_data5_tdata,
            input wire s_axis_data5_tvalid,
            output wire s_axis_data5_tready,
            input wire s_axis_data5_tlast,

            input wire s_axis_data6_aclk,
            input wire [32 - 1 : 0] s_axis_data6_tdata,
            input wire s_axis_data6_tvalid,
            output wire s_axis_data6_tready,
            input wire s_axis_data6_tlast,

            input wire s_axis_data7_aclk,
            input wire [32 - 1 : 0] s_axis_data7_tdata,
            input wire s_axis_data7_tvalid,
            output wire s_axis_data7_tready,
            input wire s_axis_data7_tlast,

            input  [`CHANNELS*`INDEX_WIDTH-1:0] xk_in,
            output [`CHANNELS*`INDEX_WIDTH-1:0] xk_out,

            /* Master AXIS to Peak Detection */

            input wire m_axis_data0_aclk,
            output wire [32 - 1 : 0] m_axis_data0_tdata,
            output wire m_axis_data0_tvalid,
            input wire m_axis_data0_tready,
            output wire m_axis_data0_tlast,

            input wire m_axis_data1_aclk,
            output wire [32 - 1 : 0] m_axis_data1_tdata,
            output wire m_axis_data1_tvalid,
            input wire m_axis_data1_tready,
            output wire m_axis_data1_tlast,

            input wire m_axis_data2_aclk,
            output wire [32 - 1 : 0] m_axis_data2_tdata,
            output wire m_axis_data2_tvalid,
            input wire m_axis_data2_tready,
            output wire m_axis_data2_tlast,

            input wire m_axis_data3_aclk,
            output wire [32 - 1 : 0] m_axis_data3_tdata,
            output wire m_axis_data3_tvalid,
            input wire m_axis_data3_tready,
            output wire m_axis_data3_tlast,

            input wire m_axis_data4_aclk,
            output wire [32 - 1 : 0] m_axis_data4_tdata,
            output wire m_axis_data4_tvalid,
            input wire m_axis_data4_tready,
            output wire m_axis_data4_tlast,


            input wire m_axis_data5_aclk,
            output wire [32 - 1 : 0] m_axis_data5_tdata,
            output wire m_axis_data5_tvalid,
            input wire m_axis_data5_tready,
            output wire m_axis_data5_tlast,

            input wire m_axis_data6_aclk,
            output wire [32 - 1 : 0] m_axis_data6_tdata,
            output wire m_axis_data6_tvalid,
            input wire m_axis_data6_tready,
            output wire m_axis_data6_tlast,

            input wire m_axis_data7_aclk,
            output wire [32 - 1 : 0] m_axis_data7_tdata,
            output wire m_axis_data7_tvalid,
            input wire m_axis_data7_tready,
            output wire m_axis_data7_tlast
        );
localparam integer DELAY = 3;

wire [`CHANNELS-1:0] adder_tvalid;
wire [`CHANNELS-1:0] average_tvalid;
wire [`CHANNELS-1:0] adder_tlast;
wire [`CHANNELS-1:0] average_tlast;

wire [`CHANNELS-1:0] m_axis_data_tvalid;
wire [`CHANNELS-1:0] m_axis_data_tlast;

/* wire [`CHANNELS*32-1:0] m_axis_data_tdata; */
wire [`CHANNELS-1:0] s_axis_data_tvalid;
wire [`CHANNELS-1:0] s_axis_data_tlast;

wire [`CHANNELS*32-1:0] average_out;
wire [`CHANNELS*32-1:0] adder_out;
wire [`CHANNELS*32-1:0] final_out;

wire [`CHANNELS-1:0] select_average_s;

// split output data into separate channels
assign m_axis_data0_tdata = final_out[0 * 32 +: 32];
assign m_axis_data1_tdata = final_out[1 * 32 +: 32];
assign m_axis_data2_tdata = final_out[2 * 32 +: 32];
assign m_axis_data3_tdata = final_out[3 * 32 +: 32];
assign m_axis_data4_tdata = final_out[4 * 32 +: 32];
assign m_axis_data5_tdata = final_out[5 * 32 +: 32];
assign m_axis_data6_tdata = final_out[6 * 32 +: 32];
assign m_axis_data7_tdata = final_out[7 * 32 +: 32];

assign m_axis_data0_tvalid = m_axis_data_tvalid[0];
assign m_axis_data1_tvalid = m_axis_data_tvalid[1];
assign m_axis_data2_tvalid = m_axis_data_tvalid[2];
assign m_axis_data3_tvalid = m_axis_data_tvalid[3];
assign m_axis_data4_tvalid = m_axis_data_tvalid[4];
assign m_axis_data5_tvalid = m_axis_data_tvalid[5];
assign m_axis_data6_tvalid = m_axis_data_tvalid[6];
assign m_axis_data7_tvalid = m_axis_data_tvalid[7];

assign m_axis_data0_tlast = m_axis_data_tlast[0];
assign m_axis_data1_tlast = m_axis_data_tlast[1];
assign m_axis_data2_tlast = m_axis_data_tlast[2];
assign m_axis_data3_tlast = m_axis_data_tlast[3];
assign m_axis_data4_tlast = m_axis_data_tlast[4];
assign m_axis_data5_tlast = m_axis_data_tlast[5];
assign m_axis_data6_tlast = m_axis_data_tlast[6];
assign m_axis_data7_tlast = m_axis_data_tlast[7];

assign s_axis_data_tlast = {
    s_axis_data7_tlast,
    s_axis_data6_tlast,
    s_axis_data5_tlast,
    s_axis_data4_tlast,
    s_axis_data3_tlast,
    s_axis_data2_tlast,
    s_axis_data1_tlast,
    s_axis_data0_tlast};

assign s_axis_data_tvalid = {
    s_axis_data7_tvalid,
    s_axis_data6_tvalid,
    s_axis_data5_tvalid,
    s_axis_data4_tvalid,
    s_axis_data3_tvalid,
    s_axis_data2_tvalid,
    s_axis_data1_tvalid,
    s_axis_data0_tvalid};


wire [`CHANNELS-1:0] process_clks;
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


wire [`CHANNELS-1:0] disable_power_s;
reg [`CHANNELS*32 - 1 : 0] s_axis_data_tdata_d;

/* reg [(CHANNELS*DELAY*`INDEX_WIDTH)-1:0] sr_xk; */
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk0;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk1;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk2;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk3;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk4;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk5;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk6;
reg [((DELAY+1)*`INDEX_WIDTH)-1:0] sr_xk7;

assign s_axis_data0_tready = 1'b1;
assign s_axis_data1_tready = 1'b1;
assign s_axis_data2_tready = 1'b1;
assign s_axis_data3_tready = 1'b1;
assign s_axis_data4_tready = 1'b1;
assign s_axis_data5_tready = 1'b1;
assign s_axis_data6_tready = 1'b1;
assign s_axis_data7_tready = 1'b1;

wire [`CHANNELS*32-1:0] s_axis_data_tdata;
assign s_axis_data_tdata = {
    s_axis_data7_tdata,
    s_axis_data6_tdata,
    s_axis_data5_tdata,
    s_axis_data4_tdata,
    s_axis_data3_tdata,
    s_axis_data2_tdata,
    s_axis_data1_tdata,
    s_axis_data0_tdata};

/* ========== Add delays to valid, last, xk and data ============*/
/* Don't forget that MULT and ADDER have latencies */
 genvar d;
 generate
     for (d=0; d < `CHANNELS; d = d + 1) begin
         mydelay #( .DELAY (DELAY-1)) delay_valid (
             .rstn (1'b1),
             .clk  (process_clks[d]),
             .in   (s_axis_data_tvalid[d]),
             .out (adder_tvalid[d])
             /* .out (m_axis_data_tvalid[d]) */
         );
         mydelay #( .DELAY (DELAY-1)) delay_last (
             .rstn (1'b1),
             .clk  (process_clks[d]),
             .in   (s_axis_data_tlast[d]),
             .out (adder_tlast[d])
             /* .out (m_axis_data_tlast[d]) */
         );
     end
endgenerate

genvar j;
generate
    for (j=DELAY; j > 0; j = j - 1) begin
        always @(posedge process_clks[0])
            sr_xk0[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk0[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[1])
            sr_xk1[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk1[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[2])
            sr_xk2[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk2[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[3])
            sr_xk3[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk3[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[4])
            sr_xk4[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk4[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[5])
            sr_xk5[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk5[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[6])
            sr_xk6[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk6[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
        always @(posedge process_clks[7])
            sr_xk7[(j*`INDEX_WIDTH) +: `INDEX_WIDTH] <= sr_xk7[(j-1)*`INDEX_WIDTH +: `INDEX_WIDTH];
    end
endgenerate

always @(posedge process_clks[0])
    sr_xk0[`INDEX_WIDTH-1 : 0] <= xk_in[0*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[1])
    sr_xk1[`INDEX_WIDTH-1 : 0] <= xk_in[1*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[2])
    sr_xk2[`INDEX_WIDTH-1 : 0] <= xk_in[2*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[3])
    sr_xk3[`INDEX_WIDTH-1 : 0] <= xk_in[3*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[4])
    sr_xk4[`INDEX_WIDTH-1 : 0] <= xk_in[4*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[5])
    sr_xk5[`INDEX_WIDTH-1 : 0] <= xk_in[5*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[6])
    sr_xk6[`INDEX_WIDTH-1 : 0] <= xk_in[6*`INDEX_WIDTH +: `INDEX_WIDTH];
always @(posedge process_clks[7])
    sr_xk7[`INDEX_WIDTH-1 : 0] <= xk_in[7*`INDEX_WIDTH +: `INDEX_WIDTH];


assign xk_out[0*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[0]) ? sr_xk0[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk0[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[1*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[1]) ? sr_xk1[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk1[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[2*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[2]) ? sr_xk2[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk2[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[3*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[3]) ? sr_xk3[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk3[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[4*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[4]) ? sr_xk4[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk4[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[5*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[5]) ? sr_xk5[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk5[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[6*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[6]) ? sr_xk6[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk6[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;
assign xk_out[7*`INDEX_WIDTH +: `INDEX_WIDTH] = (~select_average_s[7]) ? sr_xk7[(DELAY-1)*`INDEX_WIDTH +: `INDEX_WIDTH] : sr_xk7[(DELAY)*`INDEX_WIDTH +: `INDEX_WIDTH] ;

// Now do the process for each channel
wire [32*`CHANNELS-1: 0] imag_squared;
wire [32*`CHANNELS-1: 0] real_squared;

genvar i;
generate
    for (i=0; i < `CHANNELS; i = i + 1) begin
        mult my_mult_real (
            .CLK (process_clks[i]   ),
            .A   (s_axis_data_tdata[(i*32)      +: 16]),
            .B   (s_axis_data_tdata[(i*32)      +: 16]),
            .P   (real_squared[i*32 +: 32]  )
        );

        mult my_mult_imag (
            .CLK (process_clks[i]   ),
            .A   (s_axis_data_tdata[(i*32) + 16 +: 16]),
            .B   (s_axis_data_tdata[(i*32) + 16 +: 16]),
            .P   (imag_squared[i*32 +: 32]  )
        );

        adder my_adder (
            .A(real_squared[i*32 +: 31]),  // input wire [30 : 0] A
            .B(imag_squared[i*32 +: 31]),  // input wire [30 : 0] B
            .CLK(process_clks[i]),  // input wire CLK
            .CE(1'b1),    // input wire CE
            /* .CE(disable_power_s[i]),    // input wire CE */
            .S(adder_out[i*32 +: 32]) // output wire [31 : 0] S
        );
end
endgenerate

/* sync_many # */
/* ( */
/*     .WIDTH(8) */
/* ) sync_disable_power */
/* ( */
/*     .clks (process_clks), */
/*     .ins   ({8{~disable_power}}), */
/*     .outs (disable_power_s) */
/* ); */

sync_many #
(
    .WIDTH(8)
) sync_select_average
(
    .clks (process_clks),
    .ins   ({8{select_average}}),
    .outs (select_average_s)
);
/* Now make a moving average output */
genvar k;
generate
    for (k=0; k < `CHANNELS; k = k + 1) begin
        moving_average moving_average_inst (
            .clk (process_clks[k]),

            .valid_i (adder_tvalid[k]),
            .valid_o (average_tvalid[k]),

            .last_i (adder_tlast[k]),
            .last_o (average_tlast[k]),

            .in  (adder_out[k*32 +: 32]),
            .out (average_out[k*32 +: 32])
            );
        end
    endgenerate

/* Select between the regular mult / add or the moving average output */
genvar m;
generate
    for (m=0; m < `CHANNELS; m = m + 1) begin
        wire [31:0] average1, adder1;
        wire [`VALUE_WIDTH-1:0] average2, adder2;

        assign average1 = average_out[m*32 +: 32] >> `AVERAGE_PEAK_SHIFT;
        assign average2 = average1[`VALUE_WIDTH-1:0];

        assign adder1 = adder_out[m*32 +: 32] >> `PEAK_SHIFT;
        assign adder2 = adder1[`VALUE_WIDTH-1:0];

        assign final_out[m*32 +: 32] = select_average_s[m] ? average2 : adder2;

        assign m_axis_data_tvalid[m] = select_average_s[m] ? average_tvalid[m] : adder_tvalid[m];
        assign m_axis_data_tlast[m]  = select_average_s[m] ? average_tlast[m]  : adder_tlast[m];
        end
 endgenerate
endmodule

