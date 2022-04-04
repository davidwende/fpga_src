
`timescale 1 ns / 1 ps

	module all_rstn_sync
	(
        input clk_adc,
        input clk_stream,
        input clk_control,

        input asyncrst_n,

        // resets in clock domains
        output reg rst_adc_n,
        output reg rst_stream_n,
        output reg rst_control_n,

        // resets to input selectio
        output reg sel_clk_rst,
        output reg sel_io_rst,

        // long reset in clk_stream domain
        output reg lresetn_stream

    );

reg ff_adc;
reg ff_stream;
reg ff_control;

reg [7:0] rst_cnt;
reg [3:0] sel_rst_sr;
reg long_reset;
reg sel_io_rst_l;

// =============== sync to clk_adc ====================
always @ (posedge clk_adc or negedge asyncrst_n)
    if (!asyncrst_n) {rst_adc_n, ff_adc} <= 2'b0;
    else  {rst_adc_n, ff_adc} <= {ff_adc, 1'b1};

// =============== sync to clk_stream ====================
always @ (posedge clk_stream or negedge asyncrst_n)
    if (!asyncrst_n) {rst_stream_n, ff_stream} <= 2'b0;
    else  {rst_stream_n, ff_stream} <= {ff_stream, 1'b1};

// =============== sync to clk_control ====================
always @ (posedge clk_control or negedge asyncrst_n)
    if (!asyncrst_n) {rst_control_n, ff_control} <= 2'b0;
    else  {rst_control_n, ff_control} <= {ff_control, 1'b1};

// ================ Make a LONG reset ======================
always @ (posedge clk_stream or negedge rst_stream_n)
    if (!rst_stream_n)
        rst_cnt <= ~0;
    else if (rst_cnt != 0)
        rst_cnt <= rst_cnt - 1;

always @ (posedge clk_stream or negedge lresetn_stream)
    if (!lresetn_stream)
        sel_rst_sr <= ~0;
    else
        sel_rst_sr <= {sel_rst_sr[2:0], 1'b0};

always @ (posedge clk_stream or negedge rst_stream_n)
    if (!rst_stream_n)
        lresetn_stream <= 1'b0;
    else if (rst_cnt != 0)
        lresetn_stream <= 1'b0;
    else
        lresetn_stream <= 1'b1;

always @ (posedge clk_stream)
    sel_clk_rst <= ~lresetn_stream;

always @ (posedge clk_stream)
    sel_io_rst <= |sel_rst_sr;
    /* sel_io_rst_l <= |sel_rst_sr; */

// now sync to clk_adc

/* my_sync sync_io_adc ( */
/*     .clk (clk_adc), */
/*     .in (sel_io_rst_l), */
/*     .out (sel_io_rst) */
/* ); */

endmodule
