// Module    pm_top
// Function : reads values from DPRAM in a cyclic fashion and outputs
//          : to pins
//          : Two independent instances - common clock
//          : presents AXI slave for loading DPRAMS
//
`timescale 1ns/1ps
module pm_top
(
    input fast_c, // divided down by 1 and 2 

    input clk_control,
    input rst_control_n,

    input clk_adc,
    input rst_adc_n,
    output [19:0] data_out_from_device   , // output [9:0] data_out_to_pins_p
    input [31:0] control_in,

    output [31:0] status,

    input sync_awg, // from clk_adc domain
    output dbg_sync_s,

    /* debug signals */
    /* output [9:0] addra_debug, */
    /* output [9:0] addrb_debug, */

    input         s_axi_pmb_aclk ,  // input wire s_axi_aresetn
    input         s_axi_pmb_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_pmb_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_pmb_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_pmb_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_pmb_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_pmb_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_pmb_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_pmb_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_pmb_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_pmb_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_pmb_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_pmb_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_pmb_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_pmb_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_pmb_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_pmb_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_pmb_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_pmb_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_pmb_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_pmb_rready  ,      // input wire s_axi_rready

    input         s_axi_pma_aclk ,  // input wire s_axi_aresetn
    input         s_axi_pma_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_pma_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_pma_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_pma_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_pma_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_pma_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_pma_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_pma_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_pma_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_pma_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_pma_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_pma_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_pma_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_pma_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_pma_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_pma_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_pma_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_pma_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_pma_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_pma_rready      // input wire s_axi_rready
);


reg [19:0] data_out_from_device_d;
// PM values from memory
reg [10:0] addra;
reg [10:0] addrb;
wire bram_clk_a;
wire bram_clk_b;
wire bram_en_a;          // output wire bram_en_a
wire bram_en_b;          // output wire bram_en_a
wire [3:0] bram_we_a;          // output wire [3 : 0] bram_we_a
wire [3:0] bram_we_b;          // output wire [3 : 0] bram_we_a
wire [12:0] bram_addr_a;
wire [12:0] bram_addr_b;
wire [31:0] bram_wrdata_a;
wire [31:0] bram_wrdata_b;
wire [11:0] bram_rddata_a;
wire [11:0] bram_rddata_b;
/* wire [19:0] data_out_from_device; */
 wire [9:0] pm_data_a;
 wire [9:0] pm_data_b;
 wire [9:0] pm_data_rev_a;
 wire [9:0] pm_data_rev_b;
 /* reg [9:0] pm_data_a_d; */
 /* reg [9:0] pm_data_b_d; */

 reg [10:0] addra_max;
 wire synca_en;
 wire synca_en_s;
 wire addra_en;

 reg [10:0] addrb_max;
 wire syncb_en;
 wire syncb_en_s;
 wire addrb_en;

 wire clk_div2;

 wire clk_en;
 assign clk_en = 1'b1;

/* assign   addra_max = control_in[10:0]; */
assign   synca_en  = control_in[14];
assign   addra_en  = control_in[15];

/* assign   addrb_max = control_in[26:16]; */
assign   syncb_en  = control_in[30];
assign   addrb_en  = control_in[31];

always @ (posedge clk_control)
    if (addra_en)
        addra_max <= control_in[10:0];

always @ (posedge clk_control)
    if (addrb_en)
        addrb_max <= control_in[26:16];

wire sync_s;
wire [10:0] addra_max_s, addrb_max_s;
wire reset_s;

wire [31:0] status_pre_s;
assign status_pre_s = {
    addrb_en,
    syncb_en,
    3'h0,
    addrb_max,
    addra_en,
    synca_en,
    3'h0,
    addra_max
    };

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(1),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(1),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_sync (
      .dest_pulse(sync_s),
      .dest_clk(fast_c),     // 1-bit input: Destination clock.
      .dest_rst(reset_s),
      //
      .src_clk(clk_adc),       // 1-bit input: Source clock.
      .src_pulse(sync_awg),
      .src_rst(!rst_adc_n)
   );

   assign dbg_sync_s = sync_s;


/* change clock domains */
my_sync sync_status (
    .clk (clk_control),
    .in  (status_pre_s),
    .out (status)
);
my_sync sync_synca (
    .clk (fast_c),
    .in  (synca_en),
    .out (synca_en_s)
);
my_sync sync_syncb (
    .clk (fast_c),
    .in  (syncb_en),
    .out (syncb_en_s)
);

my_sync sync_reset (
    .clk (fast_c),
    .in  (!s_axi_pma_aresetn),
    .out (reset_s)
);

my_sync #(.WIDTH(11)) sync_addra_max
(
    .clk (fast_c),
    .in  (addra_max),
    .out (addra_max_s)
);

my_sync #(.WIDTH(11)) sync_addrb_max
(
    .clk (fast_c),
    .in  (addrb_max),
    .out (addrb_max_s)
);

bram_ctrl_2k bram_ctrl_2k_instb (
  .s_axi_aclk    ( s_axi_pmb_aclk ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_pmb_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_pmb_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_pmb_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_pmb_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_pmb_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_pmb_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_pmb_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_pmb_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_pmb_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_pmb_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_pmb_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_pmb_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_pmb_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_pmb_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_pmb_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_pmb_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_pmb_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_pmb_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_pmb_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_pmb_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram_clk_a    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram_en_a     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram_we_a     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram_addr_a   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram_wrdata_a ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {22'h0, bram_rddata_a[9:0] })  // input wire [31 : 0] bram_rddata_a
);

bram_ctrl_2k bram_ctrl_2k_insta (
  .s_axi_aclk    ( s_axi_pma_aclk   ) ,        // input wire s_axi_aclk
  .s_axi_aresetn ( s_axi_pma_aresetn ) ,  // input wire s_axi_aresetn
  .s_axi_awaddr  ( s_axi_pma_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
  .s_axi_awprot  ( s_axi_pma_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid ( s_axi_pma_awvalid ) ,  // input wire s_axi_awvalid
  .s_axi_awready ( s_axi_pma_awready ) ,  // output wire s_axi_awready
  .s_axi_wdata   ( s_axi_pma_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb   ( s_axi_pma_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid  ( s_axi_pma_wvalid  ) ,    // input wire s_axi_wvalid
  .s_axi_wready  ( s_axi_pma_wready  ) ,    // output wire s_axi_wready
  .s_axi_bresp   ( s_axi_pma_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid  ( s_axi_pma_bvalid  ) ,    // output wire s_axi_bvalid
  .s_axi_bready  ( s_axi_pma_bready  ) ,    // input wire s_axi_bready
  .s_axi_araddr  ( s_axi_pma_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
  .s_axi_arprot  ( s_axi_pma_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid ( s_axi_pma_arvalid ) ,  // input wire s_axi_arvalid
  .s_axi_arready ( s_axi_pma_arready ) ,  // output wire s_axi_arready
  .s_axi_rdata   ( s_axi_pma_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp   ( s_axi_pma_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid  ( s_axi_pma_rvalid  ) ,    // output wire s_axi_rvalid
  .s_axi_rready  ( s_axi_pma_rready  ) ,    // input wire s_axi_rready

  .bram_rst_a    ( ) ,        // output wire bram_rst_a
  .bram_clk_a    ( bram_clk_b    ) ,        // output wire bram_clk_a
  .bram_en_a     ( bram_en_b     ) ,          // output wire bram_en_a
  .bram_we_a     ( bram_we_b     ) ,          // output wire [3 : 0] bram_we_a
  .bram_addr_a   ( bram_addr_b   ) ,      // output wire [13 : 0] bram_addr_a
  .bram_wrdata_a ( bram_wrdata_b ) ,  // output wire [31 : 0] bram_wrdata_a
  .bram_rddata_a ( {22'h0, bram_rddata_b[9:0] } ) // input wire [31 : 0] bram_rddata_a
);

    // ======== DPRAM ==========
    //

    // port A is for outgoing coeff
    // port B is for AXI-4 to PS

dpram_2kx12 pm_dpram1 (
  .clka               ( bram_clk_a          ) ,    // input wire clka
  .ena                ( bram_en_a           ) ,      // input wire ena
  .wea                ( bram_we_a[0]        ) ,      // input wire [0 : 0] wea
  .addra              ( bram_addr_a[12:2]   ) ,  // input wire [9 : 0] addra
  .dina               ( {2'b00, bram_wrdata_a[9:0]} ) ,    // input wire [9 : 0] dina
  .douta              ( bram_rddata_a       ) ,  // output wire [9 : 0] douta

  .clkb  (fast_c    ) ,    // input wire clkb
  .enb   (clk_en    ) ,      // input wire enb
  .web   (1'b0      ) ,      // input wire [0 : 0] web
  .addrb (addra     ) ,  // input wire [9 : 0] addrb
  .dinb  (          ) ,    // input wire [9 : 0] dinb
  .doutb (pm_data_a ) // output wire [15 : 0] doutb
                              ) ;

dpram_2kx12 pm_dpram2 (
  .clka               ( bram_clk_b         ),
  .ena                ( bram_en_b          ),
  .wea                ( bram_we_b[0]       ),
  .addra              ( bram_addr_b[12:2]  ),
  .dina               ( {2'b00, bram_wrdata_b[9:0]} ),
  .douta              ( bram_rddata_b      ),

  .clkb  ( fast_c    ) ,
  .enb   ( clk_en    ) ,
  .web   ( 1'b0      ) ,
  .addrb ( addrb     ) ,
  .dinb  (           ) ,
  .doutb ( pm_data_b )
                              ) ;

// reverse bit order before assignment to big vector
genvar i;
generate
    for (i = 0; i < 10 ; i = i + 1) begin
        /* assign pm_data_rev_a[9-i] = pm_data_a[i]; */
        /* assign pm_data_rev_b[9-i] = pm_data_b[i]; */
        assign pm_data_rev_a[i] = pm_data_a[i];
        assign pm_data_rev_b[i] = pm_data_b[i];
    end
endgenerate

// add a register at output for timing reasons
always @ (posedge fast_c)
    if (clk_en)
        data_out_from_device_d <= {pm_data_rev_a, pm_data_rev_b};

assign data_out_from_device = data_out_from_device_d;

always @(posedge fast_c)
    if (addra == addra_max_s || (sync_s && synca_en_s) || reset_s)
        addra <= 0;
    else
        addra <= addra + 1;

always @(posedge fast_c)
    if (addrb == addrb_max_s || (sync_s && syncb_en_s) || reset_s)
        addrb <= 0;
    else
        addrb <= addrb + 1;

    endmodule

