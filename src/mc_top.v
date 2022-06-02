// Module
// Function : Master Controller for timing Galvo and pixels flow
//
`include "constants.vh"
`timescale 1ns/1ps
module mc_top
(
    // From ADC
    input clk_stream, // 250 MHz
    input clk_control, // 100 MHz
    input clk_adc, // ADC sample clock
    input clk10, // 10MHz
    input lresetn_stream,

    input rst_stream_n,
    input rst_adc_n,
    input rst_control_n,
    input rst_clk10,

    input [6:0] fft_events,

    input peaks_ready,

    output rstn_adc,
    output rstn_pm,
    output fft_rst,
    output fifo_rst,

    output reg select_average,

    output reg force_nowindow,

    /* output disable_fifowr, */
    /* output [7:0] disable_fiford, */
    /* output disable_galvo, */
    /* output disable_window, */
    /* output disable_fft, */
    /* output disable_power, */
    /* output disable_peak, */

    input [10:0] galvoh,
    input [10:0] galvov,

    input galvo_spi_done, // in clk_adc domain
    input [8:0] bitslips, // in clk_adc domain
    /* control and status */
    input [31:0] control, // in control domain
    output [31:0] status, // control domain
    /* debug */
    input [31:0] debug, // in control domain
    output [31:0] debug_status, // control domain
        //
    /* capture an input channel from adc */
    output input_debug_go, // to input_top, make it start capturing debug buffer
    output reg [2:0] dbg_mux,

    output fft_capture, // to fft, make it start capturing debug buffer

    output reg sampling,

    output dbg_running,
    output dbg_running_s,
    output [7:0] dbg_count,

    output reg last,
    output sync_awg,
    output reg galvo_go
    );

assign dbg_running = running;
assign dbg_running_s = running_s;

// reset adc and pm
wire adc_rst, pm_rst;
reg adc_rst_d, pm_rst_d;
reg adc_rst_reg, pm_rst_reg;
wire adc_rst_r, pm_rst_r;
reg [2:0] adc_rstcnt;
reg [2:0] pm_rstcnt;

// bitslip
reg [7:0] bitslipcnt;
wire [7:0] bitslipcnt_s;
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
wire [6:0] fftevents_s;
wire [6:0] fft_event_reg_s;

/* reg [5:0]   cnt; // make larger in real life */
reg  [1:0] state, state_next;
reg  [1:0] rstate, rstate_next;

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

reg  [11:0] count;
reg last_toggle;

wire [10:0] galvov_s;
wire [10:0] galvoh_s;
// need some of bits in clk_adc domain
// all bits in control register are rising edge sensitive
wire [3:0] run_type;
wire [3:0] run_type_s;
reg running;
reg tc;
wire running_s;
wire run;
wire halt;
wire [15:0] version;

assign version = {`MAJ_VERSION, `MIN_VERSION};
/* breakout control register */
assign run                = control[31];
assign halt               = control[30];
assign rst_peak_ready     = control[29];

always @ (posedge clk_control)
    if (!rst_control_n)
        running <= 0;
    else if (run)
        running <= 1;
    else if (halt)
        running <= 0;

/* collect for status read */
assign status = {
    peaks_ready_s,
    peak_ready_hold,
    13'h0,
    galvov_s[10:0],
    5'h0,
    galvoh_s[10:0]
    };

/* collect for debug read */
assign debug_status = {
    version,
    bitslipcnt_s,
    1'b0,
    fftevents_s
    };

/* breakout debug and resets register */

wire fft_capture_l;
reg fft_capture_d;
wire [2:0] dbg_mux_i;

assign force_nowindow_clr = debug[17];
assign force_nowindow_set = debug[16];
assign dbg_mux_i          = debug[14:12];
assign input_debug_go     = debug[8];
assign fft_capture_l      = debug[7];

assign fifo_rst           = debug[6];
assign fft_rst            = debug[5];
assign adc_rst            = debug[3];
assign pm_rst             = debug[2];
assign bitslip_rst        = debug[1];
assign fft_event_rst      = debug[0];

/* latch dbg_mux */
always @ (posedge clk_control)
    if (input_debug_go)
        dbg_mux <= dbg_mux_i;

always @ (posedge clk_control)
    fft_capture_d <= fft_capture_l;
assign fft_capture = (fft_capture_l && !fft_capture_d);

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

/* Count the 10MHz clocks and issue a GO at specific count */
always @(posedge clk_adc)
    if (!rst_adc_n)
        count <= 0;
    else
        if (count == `PIXEL_SIZE-1 )
            count <= 0;
    else
        count <= count + 1;

always @(posedge clk_adc)
    if (count == `PIXEL_SIZE-1 )
        tc <= 1'b1;
    else
        tc <= 1'b0;

always @(posedge clk_adc)
    if (!rst_adc_n)
        sampling <= 1'b0;
    else if (tc && running_s)
        sampling <= 1'b1;
    else if (tc && !running_s)
        sampling <= 1'b0;

always @(posedge clk_adc)
    last <= (count == `PIXEL_SIZE -1 );

/* the galvo_go signal triggers horizontal increment in galvo */
always @(posedge clk_adc)
    galvo_go = (count == `PIXEL_SIZE-1 || count == (`PIXEL_SIZE/2)-1);

/* sync the AWG on every two pixels */
always @(posedge clk_adc)
    if (!rst_adc_n)
        last_toggle <= 0;
    else if (last)
        last_toggle <= !last_toggle;

edge_detect #(
    .TYPE ( 1 )
)
last_rising (
    .o (sync_awg),
    .clk (clk_adc),
    .i (last_toggle)
);

/* assign sync_awg = last; */

assign dbg_count = count[7:0];

sync_many #
	(
		.WIDTH(1)
	) sync_running
	(
        .clks (clk_adc),
        .ins  (running),
        .outs (running_s)
	);

    /* Sync the galvo current position to control domain */
sync_many #
	(
		.WIDTH(11)
	) sync_galvoh
	(
        .clks ({11{clk_control}}),
        .ins  (galvoh),
        .outs (galvoh_s)
	);

sync_many #
	(
		.WIDTH(11)
	) sync_galvov
	(
        .clks ({11{clk_control}}),
        .ins  (galvov),
        .outs (galvov_s)
	);

/* capture FFT events and also allow to reset them */
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

/* sync the bitslip reset */
my_sync2 sync_bitslip_cnt_reset
                 (
    .reset_n_in  ( rst_control_n    ) ,
    .reset_n_out ( rst_adc_n        ) ,
    .clkin       ( clk_control      ) ,
    .clkout      ( clk_adc          ) ,
    .in          ( bitslip_rst      ) ,
    .out         ( bitslip_rst_s    )
                                    ) ;
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

    // sync bitslip back to clk_control
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(8)           // DECIMAL; range: 1-1024
   )
   sync_bs (
      .dest_out(bitslipcnt_s), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
      .dest_clk(clk_control), // 1-bit input: Clock signal for the destination clock domain.
      .src_in(bitslipcnt)
   );

    // sync fft_events back to clk_control
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(7)           // DECIMAL; range: 1-1024
   )
   sync_fftevent (
      .dest_out(fftevents_s),
      .dest_clk(clk_control),
      .src_in(fft_event_reg)
   );


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


       endmodule

