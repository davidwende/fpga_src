// Module
// Function : Master Controller for timing Galvo and pixels flow
//
`timescale 1ns/1ps
module mc_top
(
    // From ADC
    input clk_stream, // 250 MHz
    input clk_control, // 100 MHz
    input clk_adc, // ADC sample clock
    input lresetn_stream,

    input rst_stream_n,
    input rst_adc_n,
    input rst_control_n,

    input [6:0] fft_events,

    input peaks_ready,

    output rstn_adc,
    output rstn_pm,
    output fft_rst,
    output fifo_rst,

    output reg select_average,

    output reg force_nowindow,

    output dbg_state_idle,
    output dbg_running,
    output dbg_run_type0,

    output disable_fifowr,
    output [7:0] disable_fiford,
    output disable_galvo,
    output disable_window,
    output disable_fft,
    output disable_power,
    output disable_peak,

    input pixel_done, // from input_top, signals that it finished sampling a pixel
    input galvo_spi_done, // in clk_adc domain
    input [8:0] bitslips, // in clk_adc domain
    input [31:0] control, // in control domain
    input [31:0] disables, // in control domain
    output [31:0] status, // control domain
    output debug_go, // to input_top, make it start capturing debug buffer
    output reg [1:0] dbg_mux,
    output reg go // to input_top, make it start sampling a pixel
    );

// reset adc and pm
wire adc_rst, pm_rst, debug_go_i;
reg adc_rst_d, pm_rst_d, debug_go_d;
reg adc_rst_reg, pm_rst_reg;
wire adc_rst_r, pm_rst_r;
reg [2:0] adc_rstcnt;
reg [2:0] pm_rstcnt;

// bitslip
reg [7:0] bitslipcnt;
wire [7:0] bitslipcnt_clk;
reg bitslip_d;
wire bitslip_r;
wire bitslip_rst;
reg bitslip_rst_d;
wire bitslip_rst_r;
wire bitslip_rst_rs;
wire [14:0] status_l;

/* Peaks ready */
wire peaks_ready_s;
reg peak_ready_hold;
wire rst_peak_ready;

// fft events
wire fft_event_rst;
reg fft_event_rst_d;
wire fft_event_rst_r;
reg [6:0] fft_event_reg;
wire [6:0] fft_event_reg_s;

wire pixel_done_s;
/* reg [5:0]   cnt; // make larger in real life */
reg  [1:0] state, state_next;
reg  [1:0] rstate, rstate_next;
parameter IDLE = 0, DO_GALVO_SPI = 1, DO_PIXEL = 2, DO_PIXEL_WAIT = 3;
parameter rIDLE = 0, rCOUNT_DOWN = 1, rDONE = 2;

reg have_clk_div;
wire reset_clk_div;

wire run_always;
wire run_always_s;
wire run_halt_s;

wire galvo_spi_done_s;

wire force_nowindow_clr;
wire force_nowindow_set;

wire select_average_clr;
wire select_average_set;

/* debug mux */
wire [3:0] dbg_mux_set;
wire [3:0] dbg_mux_i;
reg [3:0] dbg_mux_l;

// need some of bits in clk_adc domain
// all bits in control register are rising edge sensitive
wire [3:0] run_type;
wire [3:0] run_type_s;
reg running;
assign run_type     = control[31:28];
assign dbg_run_type0 = control[31];

// resets
assign rst_peak_ready = control[8];

assign dbg_mux_i = control[15:12];

/* To stop Galvo SPI or stop write to FIFO */
assign disable_fifowr  = disables[ 0 ];
assign disable_peak    = disables[ 1 ];
assign disable_galvo   = disables[ 2 ];
assign disable_window  = disables[ 3 ];
assign disable_fft     = disables[ 4 ];
assign disable_power   = disables[ 5 ];


assign disable_fiford  = disables[15:8];
/* ======================================== */

assign force_nowindow_clr = control[17];
assign force_nowindow_set = control[16];

/* Various resets */

assign select_average_clr = control[8];
assign select_average_set = control[7];
assign fifo_rst           = control[6];
assign fft_rst            = control[5];
assign debug_go_i         = control[4];
assign adc_rst            = control[3];
assign pm_rst             = control[2];
assign bitslip_rst        = control[1];
assign fft_event_rst      = control[0];

always @ (posedge clk_control)
    fft_event_rst_d <= fft_event_rst;
assign fft_event_rst_r = (fft_event_rst && !fft_event_rst_d);

always @ (posedge clk_control)
    bitslip_rst_d <= bitslip_rst;
assign bitslip_rst_r = (bitslip_rst && !bitslip_rst_d);

/* Just use rectangular window and not from coefficients */

always @ (posedge clk_control or negedge rst_control_n)
    if (~rst_control_n)
        force_nowindow <= 0;
    else if (force_nowindow_set)
        force_nowindow <= 1;
    else if (force_nowindow_clr)
        force_nowindow <= 0;

always @ (posedge clk_control or negedge rst_control_n)
    if (~rst_control_n)
        select_average <= 0;
    else if (select_average_set)
        select_average <= 1;
    else if (select_average_set)
        select_average <= 0;

/* ======================================== */

// must sync bitslip_rst_r pulse to clk_adc
   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),
      .INIT_SYNC_FF(1),
      .REG_OUTPUT(0),
      .RST_USED(1),
      .SIM_ASSERT_CHK(0)
   )
   xpm_cdc_pulse_inst (
      .dest_pulse(bitslip_rst_rs),
      .dest_clk(clk_adc),
      .dest_rst(!rst_adc_n),
      .src_clk(clk_control),
      .src_pulse(bitslip_rst_r),
      .src_rst(!rst_adc_n)
   );

// TODO add field to control for wait after galvo done before new pixel

my_sync2 sync_done (
    .reset_n_in     ( rst_adc_n        ) ,
    .reset_n_out    ( rst_stream_n        ) ,
    .clkin         ( clk_adc      ) ,
    .clkout        ( clk_stream          ) ,
    .in            ( pixel_done   ) ,
    .out           ( pixel_done_s )
                                  ) ;

/* always @ (posedge clk_stream or negedge lresetn_stream) */
/*     if (!lresetn_stream) */
/*         cnt <= ~0; // TODO wrong count !!!! */
/*     else if ((state == DO_PIXEL && pixel_done_s)) */
/*         cnt <= ~0; // TODO wrong count !!!! */
/*     else */
/*         cnt <= cnt - 1; */

always @ (posedge clk_stream or negedge lresetn_stream) begin
    if (!lresetn_stream)
        state <= IDLE;
    else begin
        if (~running)
            state <= IDLE;
        else
            state <= state_next;
    end
end

my_sync my_sync_galvo_done (
    .clk (clk_stream),
    .in (galvo_spi_done),
    .out (galvo_spi_done_s)
);

always @ (state,  pixel_done_s, galvo_spi_done_s, running) begin
    state_next <= state;
    case (state)
        IDLE: begin // 0
                state_next <= DO_PIXEL ;
            end

        DO_GALVO_SPI: begin // 1
        if (galvo_spi_done_s)
            state_next <= DO_PIXEL;
        end

        DO_PIXEL: begin // 2
                state_next <= DO_PIXEL_WAIT;
        end

       DO_PIXEL_WAIT: begin // 3
            if (pixel_done_s)
                state_next <= DO_GALVO_SPI;
        end

        default: begin
                state_next <= IDLE;
            end

    endcase
end

assign dbg_state_idle = (state == IDLE) ? 1'b1 : 1'b0;

always @ (posedge clk_stream)
    if (state == DO_PIXEL)
        go <= 1'b1;
    else
        go <= 1'b0;

/* assign go = (state == DO_PIXEL) ? 1'b1 : 1'b0; */

my_sync2 sync_bitslip_cnt_reset
                 (
    .reset_n_in  ( rst_control_n    ) ,
    .reset_n_out ( rst_adc_n        ) ,
    .clkin       ( clk_control      ) ,
    .clkout      ( clk_adc          ) ,
    .in          ( bitslip_rst      ) ,
    .out         ( bitslip_rst_s    )
                                    ) ;

genvar i;
generate
    for (i=0; i < 7; i = i + 1) begin
        always @ (posedge clk_stream or negedge rst_stream_n)
            if (!rst_stream_n)
                fft_event_reg[i] <= 0;
            else if (fft_events[i])
                fft_event_reg[i] <= 1'b1;
            else if (fft_event_rst_r)
                fft_event_reg[i] <= 0;
        end
    endgenerate


// now capture and reset bitslip counter
always @ (posedge clk_adc)
    bitslip_d <= bitslips[0];

assign bitslip_r = (bitslips[0] && !bitslip_d);

always @ (posedge clk_adc or negedge rst_adc_n)
    if (!rst_adc_n)
        bitslipcnt <= 0;
    else if (bitslip_rst_rs)
        bitslipcnt <= 0;
    else if ((bitslip_r) && (~&bitslipcnt))
        bitslipcnt <= bitslipcnt + 1;

    // sync  bitslip and fft_events back to clk_control
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(15)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_inst (
      .dest_out(status_l), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.

      .dest_clk(clk_control), // 1-bit input: Clock signal for the destination clock domain.
     // .src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in({bitslipcnt, fft_event_reg})      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                           // domain. It is assumed that each bit of the array is unrelated to the others. This
                           // is reflected in the constraints applied to this macro. To transfer a binary value
                           // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

   );
// now drive back to AXI
assign status = {
    peaks_ready_s,
    peak_ready_hold,
    14'h0,
    status_l[14:7],  // 8
    1'b0,
    status_l[6:0]   // 7
    };

always @ (posedge clk_control)
    dbg_mux_l <= dbg_mux_i;

genvar j;
generate
    for (j=0; j < 4; j = j + 1) begin
        edge_detect #( .TYPE (1)  // 0 falling , 1 rising
        ) edge_pixel_done_r (
            .clk ( s_axi_h_aclk),
            .o   ( dbg_mux_set[j]),
            .i   ( dbg_mux_i[j])
        );
        end
endgenerate

always @(posedge clk_control)
    if ( dbg_mux_set[0] )
        dbg_mux <= 2'b00;
    else
    if ( dbg_mux_set[1] )
        dbg_mux <= 2'b01;
    else
    if ( dbg_mux_set[2] )
        dbg_mux <= 2'b10;
    else
    if ( dbg_mux_set[3] )
        dbg_mux <= 2'b11;


edge_detect #( .TYPE (1)  // 0 falling , 1 rising
) edge_adc_rst (
    .clk ( clk_control),
    .o   ( adc_rst_r),
    .i   ( adc_rst)
);

edge_detect #( .TYPE (1)  // 0 falling , 1 rising
) edge_pm_rst (
    .clk ( clk_control),
    .o   ( pm_rst_r),
    .i   ( pm_rst)
);

edge_detect #( .TYPE (1)  // 0 falling , 1 rising
) edge_debug_go (
    .clk ( clk_control),
    .o   ( debug_go),
    .i   ( debug_go_i)
);

// resets need counters for 50nS minimum
always @ (posedge clk_control or negedge rst_control_n)
    if (!rst_control_n)
        adc_rstcnt <= ~0;
    else if (adc_rst_r)
        adc_rstcnt <= ~0;
    else if (adc_rstcnt != 0)
        adc_rstcnt <= adc_rstcnt - 1;

always @ (posedge clk_control or negedge rst_control_n)
    if (!rst_control_n)
        pm_rstcnt <= ~0;
    else if (pm_rst_r)
        pm_rstcnt <= ~0;
    else if (pm_rstcnt != 0)
        pm_rstcnt <= pm_rstcnt - 1;

always @ (posedge clk_control or negedge rst_control_n)
    if (!rst_control_n)
        pm_rst_reg <= 1'b1;
    else if (pm_rstcnt != 0)
        pm_rst_reg <= 1'b1;
    else
        pm_rst_reg <= 1'b0;

assign rstn_pm = ~pm_rst_reg;

always @ (posedge clk_control or negedge rst_control_n)
    if (!rst_control_n)
        adc_rst_reg <= 1'b1;
    else if (adc_rstcnt != 0)
        adc_rst_reg <= 1'b1;
    else
        adc_rst_reg <= 1'b0;

assign rstn_adc = ~adc_rst_reg;
//

/* handle peaks ready */
   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(1),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_peaks (
      .dest_pulse(peaks_ready_s), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                               // transfer is correctly initiated on src_pulse input. This output is
                               // combinatorial unless REG_OUTPUT is set to 1.

      .dest_clk(clk_control),     // 1-bit input: Destination clock.
      .dest_rst(!rst_control_n),     // 1-bit input: optional; required when RST_USED = 1
      .src_clk(clk_stream),       // 1-bit input: Source clock.
      .src_pulse(peaks_ready),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                               // destination clock domain. The minimum gap between each pulse transfer must be
                               // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                               // between the falling edge of a src_pulse to the rising edge of the next
                               // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                               // will generate a pulse the size of one dest_clk period in the destination
                               // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                               // src_rst and/or dest_rst are asserted.

      .src_rst(!rst_stream_n)        // 1-bit input: optional; required when RST_USED = 1
   );

   always @ (posedge clk_control or negedge rst_control_n)
       if (~rst_control_n)
           peak_ready_hold <= 1'b0;
       else if (peaks_ready_s)
           peak_ready_hold <= 1'b1;
       else if (rst_peak_ready)
           peak_ready_hold <= 1'b0;

       /* sync the run type to clk_stream */
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(4)           // DECIMAL; range: 1-1024
   )
   xpm_sync_run_type (
      .dest_out(run_type_s), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.

      .dest_clk(clk_stream), // 1-bit input: Clock signal for the destination clock domain.
     // .src_clk(src_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(run_type)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                           // domain. It is assumed that each bit of the array is unrelated to the others. This
                           // is reflected in the constraints applied to this macro. To transfer a binary value
                           // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
   );

   /* set or clear running flag based on synced command */
   always @(posedge clk_stream)
       if (~rst_stream_n || run_type_s[0])
           running <= 1'b0;
       else if (run_type_s[3])
           running <= 1'b1;

assign dbg_running = running;

       endmodule

