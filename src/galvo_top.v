// Module    Galvo_top
// Function : Responsible for:
//              keeping track of current X and Y positions
//              updating X and Y from preset vectors
//          : by squaring real and imaginary separately then adding results.
//          : input is stream of 32 bits, 16 & 16
//
`timescale 1ns/1ps
module galvo_top   #(
    parameter integer CHANNELS	= 8
)
(

    // AXI to vector memories
    input         s_axi_h_aclk ,  // input wire s_axi_aresetn
    input         s_axi_h_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_h_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_h_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_h_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_h_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_h_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_h_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_h_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_h_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_h_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_h_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_h_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_h_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_h_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_h_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_h_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_h_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_h_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_h_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_h_rready  ,     // input wire s_axi_rready

    input         s_axi_v_aclk ,  // input wire s_axi_aresetn
    input         s_axi_v_aresetn ,  // input wire s_axi_aresetn
    input [12:0]  s_axi_v_awaddr  ,    // input wire [13 : 0] s_axi_awaddr
    input [2:0]   s_axi_v_awprot  ,    // input wire [2 : 0] s_axi_awprot
    input         s_axi_v_awvalid ,  // input wire s_axi_awvalid
    output        s_axi_v_awready ,  // output wire s_axi_awready
    input [31:0]  s_axi_v_wdata   ,      // input wire [31 : 0] s_axi_wdata
    input [3:0]   s_axi_v_wstrb   ,      // input wire [3 : 0] s_axi_wstrb
    input         s_axi_v_wvalid  ,    // input wire s_axi_wvalid
    output        s_axi_v_wready  ,    // output wire s_axi_wready
    output [1:0]  s_axi_v_bresp   ,      // output wire [1 : 0] s_axi_bresp
    output        s_axi_v_bvalid  ,    // output wire s_axi_bvalid
    input         s_axi_v_bready  ,    // input wire s_axi_bready
    input [12:0]  s_axi_v_araddr  ,    // input wire [13 : 0] s_axi_araddr
    input [2:0]   s_axi_v_arprot  ,    // input wire [2 : 0] s_axi_arprot
    input         s_axi_v_arvalid ,  // input wire s_axi_arvalid
    output        s_axi_v_arready ,  // output wire s_axi_arready
    output [31:0] s_axi_v_rdata   ,      // output wire [31 : 0] s_axi_rdata
    output [1:0]  s_axi_v_rresp   ,      // output wire [1 : 0] s_axi_rresp
    output        s_axi_v_rvalid  ,    // output wire s_axi_rvalid
    input         s_axi_v_rready  ,     // input wire s_axi_rready

    input         clk_adc  ,     // for sync the pixel_done
    input rst_adc_n  ,
    input rst_control_n  ,

    input disable_galvo,

    output sclk   ,
    output csn    ,
    output mosi_o ,

    input pixel_done,
    input [31:0] control,
    input [31:0] manual,
    output galvo_spi_done
);

wire bram_clk_h;
wire bram_clk_v;
wire bram_en_h;
wire bram_en_v;
wire [3:0] bram_we_h;
wire [3:0] bram_we_v;
wire [12:0] bram_addr_h;
wire [12:0] bram_addr_v;
wire [31:0] bram_wrdata_h;
wire [31:0] bram_wrdata_v;
wire [31:0] bram_rddata_h;
wire [31:0] bram_rddata_v;
wire [11:0] h_do;
wire [11:0] v_do;

reg [10:0] h_addr, v_addr;
wire [10:0] H_MAX, V_MAX;
wire [31:0] spi_control;
wire [31:0] spi_status;
wire [31:0] spi_wrdata;
wire [11:0] bram_rdh;
wire [11:0] bram_rdv;
wire [15:0] v_data, h_data;
wire [15:0] v_data_swapped, h_data_swapped;
reg r_galvo_spi_done;

wire manual_mode;
wire manual_go;
reg manual_go_d;
wire manual_go_r;
wire [11:0] h_manual;
wire [11:0] v_manual;

wire disable_galvo_s;

assign manual_go = manual[31];
assign h_manual = manual[11:0];
assign v_manual = manual[27:16];

assign manual_mode = control[31];
assign H_MAX = control[10:0];
assign V_MAX = control[26:16];


reg go_spi, go_spi_d, go_spi_dd;
wire spi_done;
reg [2:0] state, state_next;
parameter IDLE = 0, DO_H = 1, DO_H2 = 2, DONE_H = 3, WAIT = 4, DO_V = 5, DO_V2 = 6, DONE_V = 7;
reg [7:0] cnt;
wire cnt_tc;
reg v_pending;

reg pixel_done_d; // TODO must sync to this clock domain
wire pixel_done_s;
wire pixel_done_r;
// Code Starts
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(1)           // DECIMAL; range: 1-1024
   )
   sync_disable_galvo (
      .dest_out(disable_galvo_s),
      .dest_clk(s_axi_h_aclk), // same as clk_control
      .src_in(disable_galvo)
   );

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(1),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(1),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_pixel_done (
      .dest_pulse           ( pixel_done_r   ) ,
      .dest_clk             ( s_axi_h_aclk   ) ,
      .dest_rst             ( !rst_control_n ) ,
      .src_clk              ( clk_adc        ) ,
      .src_pulse            ( pixel_done     ) ,
      .src_rst              ( !rst_adc_n     )
                                             ) ;

always @(posedge s_axi_h_aclk) begin
    if (!rst_control_n) begin
        h_addr <= 0;
    end else begin
        if (pixel_done_r ) begin
            if (h_addr < H_MAX) begin
                h_addr <= h_addr + 1;
            end else begin
                h_addr <= 0;
            end
        end
    end
end

/* Address pointer for vertical */
always @(posedge s_axi_h_aclk)
    if (!rst_control_n)
        v_addr <= 0;
    else
        if (pixel_done_r && h_addr == H_MAX )
            if (v_addr < V_MAX)
                v_addr <= v_addr + 1;
            else
                v_addr <= 0;


/* Address pointer for Horizontal */
always @(posedge s_axi_h_aclk  or negedge rst_control_n)
    if (!rst_control_n)
        v_pending <= 0;
   else
        if (pixel_done_r && h_addr == H_MAX)
            v_pending <= 1;
        else if (state == DO_V2 && spi_done)
            v_pending <= 0;

/* AXI to BRAM controller for Horizontal */
bram_ctrl_2k bram_ctrl_2k_insth (
    .s_axi_aclk    ( s_axi_h_aclk ) ,        // input wire s_axi_aclk
    .s_axi_aresetn ( s_axi_h_aresetn ) ,  // input wire s_axi_aresetn
    .s_axi_awaddr  ( s_axi_h_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
    .s_axi_awprot  ( s_axi_h_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
    .s_axi_awvalid ( s_axi_h_awvalid ) ,  // input wire s_axi_awvalid
    .s_axi_awready ( s_axi_h_awready ) ,  // output wire s_axi_awready
    .s_axi_wdata   ( s_axi_h_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb   ( s_axi_h_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
    .s_axi_wvalid  ( s_axi_h_wvalid  ) ,    // input wire s_axi_wvalid
    .s_axi_wready  ( s_axi_h_wready  ) ,    // output wire s_axi_wready
    .s_axi_bresp   ( s_axi_h_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid  ( s_axi_h_bvalid  ) ,    // output wire s_axi_bvalid
    .s_axi_bready  ( s_axi_h_bready  ) ,    // input wire s_axi_bready
    .s_axi_araddr  ( s_axi_h_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
    .s_axi_arprot  ( s_axi_h_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
    .s_axi_arvalid ( s_axi_h_arvalid ) ,  // input wire s_axi_arvalid
    .s_axi_arready ( s_axi_h_arready ) ,  // output wire s_axi_arready
    .s_axi_rdata   ( s_axi_h_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp   ( s_axi_h_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid  ( s_axi_h_rvalid  ) ,    // output wire s_axi_rvalid
    .s_axi_rready  ( s_axi_h_rready  ) ,    // input wire s_axi_rready

    .bram_rst_a    ( ) ,        // output wire bram_rst_a
    .bram_clk_a    ( bram_clk_h    ) ,        // output wire bram_clk_a
    .bram_en_a     ( bram_en_h     ) ,          // output wire bram_en_a
    .bram_we_a     ( bram_we_h     ) ,          // output wire [3 : 0] bram_we_a
    .bram_addr_a   ( bram_addr_h   ) ,      // output wire [13 : 0] bram_addr_a
    .bram_wrdata_a ( bram_wrdata_h ) ,  // output wire [31 : 0] bram_wrdata_a
    .bram_rddata_a ( bram_rddata_h )   // input wire [31 : 0] bram_rddata_a
);

/* AXI to BRAM controller for Vertical */
bram_ctrl_2k bram_ctrl_2k_instv (
    .s_axi_aclk    ( s_axi_v_aclk ) ,        // input wire s_axi_aclk
    .s_axi_aresetn ( s_axi_v_aresetn ) ,  // input wire s_axi_aresetn
    .s_axi_awaddr  ( s_axi_v_awaddr  ) ,    // input wire [13 : 0] s_axi_awaddr
    .s_axi_awprot  ( s_axi_v_awprot  ) ,    // input wire [2 : 0] s_axi_awprot
    .s_axi_awvalid ( s_axi_v_awvalid ) ,  // input wire s_axi_awvalid
    .s_axi_awready ( s_axi_v_awready ) ,  // output wire s_axi_awready
    .s_axi_wdata   ( s_axi_v_wdata   ) ,      // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb   ( s_axi_v_wstrb   ) ,      // input wire [3 : 0] s_axi_wstrb
    .s_axi_wvalid  ( s_axi_v_wvalid  ) ,    // input wire s_axi_wvalid
    .s_axi_wready  ( s_axi_v_wready  ) ,    // output wire s_axi_wready
    .s_axi_bresp   ( s_axi_v_bresp   ) ,      // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid  ( s_axi_v_bvalid  ) ,    // output wire s_axi_bvalid
    .s_axi_bready  ( s_axi_v_bready  ) ,    // input wire s_axi_bready
    .s_axi_araddr  ( s_axi_v_araddr  ) ,    // input wire [13 : 0] s_axi_araddr
    .s_axi_arprot  ( s_axi_v_arprot  ) ,    // input wire [2 : 0] s_axi_arprot
    .s_axi_arvalid ( s_axi_v_arvalid ) ,  // input wire s_axi_arvalid
    .s_axi_arready ( s_axi_v_arready ) ,  // output wire s_axi_arready
    .s_axi_rdata   ( s_axi_v_rdata   ) ,      // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp   ( s_axi_v_rresp   ) ,      // output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid  ( s_axi_v_rvalid  ) ,    // output wire s_axi_rvalid
    .s_axi_rready  ( s_axi_v_rready  ) ,    // input wire s_axi_rready

    .bram_rst_a    ( ) ,        // output wire bram_rst_a
    .bram_clk_a    ( bram_clk_v    ) ,        // output wire bram_clk_a
    .bram_en_a     ( bram_en_v     ) ,          // output wire bram_en_a
    .bram_we_a     ( bram_we_v     ) ,          // output wire [3 : 0] bram_we_a
    .bram_addr_a   ( bram_addr_v   ) ,      // output wire [13 : 0] bram_addr_a
    .bram_wrdata_a ( bram_wrdata_v ) ,  // output wire [31 : 0] bram_wrdata_a
    .bram_rddata_a ( bram_rddata_v )   // input wire [31 : 0] bram_rddata_a
);
// a - internal, b - AXI
// pm_dpram1 for Horizontal
dpram_2kx12 dpram_h (
    .clka(s_axi_h_aclk ),    // input wire clka
    .ena(1'b1),      // input wire ena
    .wea(1'b0),      // input wire [0 : 0] wea
    .addra(h_addr),  // input wire [9 : 0] addra
    .dina(),    // input wire [9 : 0] dina
    .douta(h_do),  // output wire [9 : 0] douta

    .clkb(bram_clk_h),    // input wire clkb
  .enb(bram_en_h),      // input wire enb
  .web(bram_we_h[0]),      // input wire [0 : 0] web
  .addrb(bram_addr_h[12:2]),  // input wire [9 : 0] addrb
  .dinb(bram_wrdata_h[11:0]),    // input wire [9 : 0] dinb
  .doutb(bram_rdh)  // output wire [15 : 0] doutb
);

// pm_dpram2 for Vertical
dpram_2kx12 dpram_v (
  .clka(s_axi_v_aclk ),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(v_addr),  // input wire [10 : 0] addra
  .dina(),    // input wire [15 : 0] dina
  .douta(v_do),  // output wire [15 : 0] douta

  .clkb(bram_clk_v),    // input wire clkb
  .enb(bram_en_v),      // input wire enb
  .web(bram_we_v[0]),      // input wire [0 : 0] web
  .addrb(bram_addr_v[12:2]),  // input wire [10 : 0] addrb
  .dinb(bram_wrdata_v[11:0]),    // input wire [15 : 0] dinb
  .doutb(bram_rdv)  // is extension performed auto???
);

/* Data is only 12 bits */
assign bram_rddata_h = {20'b0, bram_rdh};
assign bram_rddata_v = {20'b0, bram_rdv};

wire pre_sclk, pre_csn, pre_mosi_o;

/* the SPI master */
spi_top #(
.CPOL (4'd2),
.CPHA (4'd3)
) spi_galvo (
   .clk     ( s_axi_h_aclk )     ,
   .reset   (~rst_control_n )  ,
   .control (spi_control) ,
   .wrdata  (spi_wrdata)  ,
   .rddata  ()  ,
   .status  (spi_status)  ,

   .sclk    (pre_sclk  )  ,
   .csn     (pre_csn   )  ,
   .mosi_o  (pre_mosi_o)  ,
   .miso_i  (1'b0)
);

assign sclk   = (~disable_galvo_s) ? pre_sclk : 1'b0;
assign csn    = (~disable_galvo_s) ? pre_csn : 1'b1;
assign mosi_o = (~disable_galvo_s) ? pre_mosi_o : 1'b1;

assign spi_control = {go_spi_dd, 29'b0 , 2'b01};
assign spi_done = spi_status[0]; // clk_control domain

always @ (posedge s_axi_h_aclk or negedge rst_control_n ) begin
    if (!rst_control_n)
        state <= IDLE;
    else
        state <= state_next;
end

always @ (state, pixel_done_r, spi_done, cnt, v_pending, manual_mode) begin
    state_next <= state;
    go_spi <= 1'b0;
    case (state)
        IDLE: begin // 0
            if (pixel_done_r) begin
                state_next <= DO_H;
                go_spi <= 1'b1;
            end
        end

        DO_H: begin // 1
            go_spi <= 1'b0;
            if (!spi_done) begin
                state_next <= DO_H2;
            end
        end

       DO_H2: begin // 2
            go_spi <= 1'b0;
            if (spi_done) begin
                state_next <= DONE_H;
            end
        end

       DONE_H: begin //3
            go_spi <= 1'b0;
            if (cnt == 0) begin
                if (v_pending || manual_mode)
                    state_next <= WAIT;
                else
                     state_next <= IDLE;
            end
        end

        WAIT: begin // 4
                state_next <= DO_V;
                go_spi <= 1'b1;
        end

        DO_V: begin // 5
               go_spi <= 1'b0;
               if (!spi_done) begin
                   state_next <= DO_V2;
               end
        end

       DO_V2: begin // 6
            go_spi <= 1'b0;
            if (spi_done) begin
                state_next <= DONE_V;
            end
        end

        DONE_V: begin // 7
            go_spi <= 1'b0;
            if (cnt == 0) begin
               state_next <= IDLE;
            end
        end

    endcase
end

/* Must add the channel code and select between auto & manual */
assign h_data = (manual_mode == 0) ? {4'b0001 , h_do } : {4'b0001, h_manual} ; // load and update channel A
assign v_data = (manual_mode == 0) ? {4'b0100 , v_do } : {4'b0001, v_manual} ; // load and update channel B
assign h_data_swapped = {h_data[7:0], h_data[15:8]};
assign v_data_swapped = {v_data[7:0], v_data[15:8]};
assign spi_wrdata = (state == DO_V || state == DO_V2) ? {16'h0, v_data} :  {16'h0, h_data};

always @(posedge s_axi_h_aclk )
    if ((!v_pending && state == DONE_H && cnt == 0 ) || (state == DONE_V && cnt == 0 ))
        r_galvo_spi_done <= 1'b1;
    else
        r_galvo_spi_done <= 1'b0;

assign galvo_spi_done = r_galvo_spi_done;

/* This is a wait - should convert to programmable value */
always @(posedge s_axi_h_aclk or negedge rst_control_n )
    if (!rst_control_n)
        cnt <= 15;
    else if (state == DO_H2 || state == DO_V2)
        cnt <= 15;
    else if (cnt != 0)
        cnt <= cnt - 1;

always @(posedge s_axi_h_aclk)
begin
    go_spi_d <= go_spi;
    go_spi_dd <= go_spi_d;
 end

always @(posedge s_axi_h_aclk )
    manual_go_d <= manual_go;

assign manual_go_r = manual_go && !manual_go_d;

    endmodule

