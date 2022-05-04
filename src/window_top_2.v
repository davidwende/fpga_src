// Module    window_top
// Function : Performs a window operation (multiply sample by sample) on
//          : incoming data
//          : presents AXIS master to downstream 
//

`include "constants.vh"

//
`timescale 1ns/1ps
module window_top_2  (
    input force_nowindow,
    /* input disable_window, */

    // AXI slave for coeff memory
    input         s_axi_coef_aclk    ,        // input wire s_axi_aclk
    input         s_axi_coef_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_coef_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_coef_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_coef_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_coef_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_coef_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_coef_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_coef_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_coef_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_coef_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_coef_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_coef_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_coef_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_coef_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_coef_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_coef_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_coef_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_coef_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_coef_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_coef_rready  ,      // input wire s_axi_rready

    /* AXI S slave - incoming data to be windowed */
    input        S_AXIS_ACLK,
    input        S_AXIS_ARESETN,
    input        S_AXIS_TVALID,
    input [`CHANNELS*16-1 :0] S_AXIS_TDATA,
    input [3:0]  S_AXIS_TSTRB,
    input        S_AXIS_TLAST,
    output       S_AXIS_TREADY,

    /* AXIS Master to downstream processing */
    input         M_AXIS_ACLK,
    input         M_AXIS_ARESETN,
    output        M_AXIS_TVALID, // out1
    output [`CHANNELS*16-1:0] M_AXIS_TDATA,
    output        M_AXIS_TLAST,
    input         M_AXIS_TREADY // not used, we assume downstream IS_0 always ready
);

/* wire  disable_window_s; */

wire [15:0] coef_data;
wire [15:0] mult_data;

reg pending_last;
wire out2;

wire force_nowindow_s;

// BRAM signals
 wire bram_clk_a;
 wire bram_en_a;
 wire [3:0] bram_we_a;
 wire [12:0] bram_addr_a;
 wire [31:0] bram_wrdata_a;
 wire [9:0] bram_rddata_a;

/* pipeline the valid and last for downstream use */

localparam integer DELAY = 3;

wire [`CHANNELS*25 - 1 : 0] multi_out;

  assign  S_AXIS_TREADY = 1'b1;

    genvar i;
    generate
        for (i=0; i < `CHANNELS; i = i + 1) begin
            wire signed [`MULTI_OUT_WIDTH-1:0] local_multi_out;
        MULT_MACRO #        (
            .DEVICE        ( "7SERIES"   ) , // Target Device: "7SERIES"
            .LATENCY       ( 3           ) ,        // Desired clock cycle latency, 0-4
            .WIDTH_A       ( 10          ) ,       // From ADC
            .WIDTH_B       ( 16          ) // From BRAM - coefficients
        ) MULT_MACRO_inst (
            // TODO length is incorrect for P
            .P             (local_multi_out) ,        // result
            /* .P             (M_AXIS_TDATA[i*32 +: 25]) ,        // result */
            .A             ( S_AXIS_TDATA[i*16 +: 10]),     // Multiplier input A bus, width determined by WIDTH_A parameter
            .B             ( mult_data   ) ,                // Multiplier input B bus, width determined by WIDTH_B parameter
            .CE            ( 1'b1) ,        // 1-bit active high input clock enable
            .CLK           ( S_AXIS_ACLK ),
            .RST           ( 1'b0      )
        ) ;
     assign M_AXIS_TDATA[i*16 +: 16] = local_multi_out >>> 9;
     end
 endgenerate


        // Co-efficients
reg [10:0] addra;
wire [15:0] bram_rddata_l;

    // controller for DPRAM
bram_ctrl_2k bram_ctrl_2k_instb (
  .s_axi_aclk    ( s_axi_coef_aclk    ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_coef_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_coef_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_coef_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_coef_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_coef_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_coef_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_coef_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_coef_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_coef_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_coef_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_coef_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_coef_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_coef_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_coef_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_coef_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_coef_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_coef_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_coef_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_coef_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_coef_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {22'h0, bram_rddata_a })  // input wire [31 : 0] bram_rddata_a
);
    // ======== DPRAM ==========
    //

    // port A is for outgoing coeff
    // port B is for AXI-4 to PS

dpram_2kx16 coef_dpram
         (
  .clka  ( S_AXIS_ACLK ) ,    // input wire clka
  .ena   ( 1'b1        ) ,      // input wire ena
  .wea   ( 1'b0        ) ,      // input wire [0 : 0] wea
  .addra ( addra       ) ,  // input wire [10 : 0] addra
  .dina  (             ) ,    // input wire [15 : 0] dina
  .douta ( coef_data   ) ,  // output wire [15 : 0] douta

  .clkb  ( bram_clk_a          ) ,    // input wire clkb
  .enb   ( bram_en_a           ) ,      // input wire enb
  .web   ( bram_we_a[0]        ) ,      // input wire [0 : 0] web
  .addrb ( bram_addr_a[12:2]   ) ,  // input wire [10 : 0] addrb
  .dinb  ( bram_wrdata_a[15:0] ) ,    // input wire [15 : 0] dinb
  .doutb ( bram_rddata_l       ) // output wire [15 : 0] doutb
                               ) ;
assign bram_rddata_a = {16'b0, bram_rddata_l};
assign mult_data = (force_nowindow_s) ? 16'h7FFF : coef_data;


// generate read address into dpram to get coefficient
always @(posedge S_AXIS_ACLK)
    if (!S_AXIS_ARESETN || (pending_last && M_AXIS_TVALID))
        addra <= 0;
    else if (S_AXIS_TVALID)
        addra <= addra + 1;

always @(posedge S_AXIS_ACLK)
    if (!S_AXIS_ARESETN)
        pending_last <= 1'b0;
    else if (S_AXIS_TLAST)
        pending_last <= 1'b1;
    else if (M_AXIS_TLAST && M_AXIS_TREADY)
        pending_last <= 1'b0;

 mydelay #( .DELAY (DELAY)) delay_last (
     .rstn (S_AXIS_ARESETN),
     .clk  (S_AXIS_ACLK),
     .in   (S_AXIS_TLAST),
     .out (M_AXIS_TLAST)
 );

 mydelay #( .DELAY (DELAY)) delay_valid (
     .rstn (S_AXIS_ARESETN),
     .clk  (S_AXIS_ACLK),
     .in   (S_AXIS_TVALID),
     .out  (M_AXIS_TVALID)
 );

/* sync the disable window to AXIS domain */
 sync_many #( .WIDTH(1)) sync_disable_window (
    .clks ( S_AXIS_ACLK     ) ,
    .ins  (  force_nowindow  ) ,
    .outs (  force_nowindow_s)) ;

    endmodule

