// Module    VGA
// Function : VGA gain, power control, Sync etc.
//
`timescale 1ns/1ps
module vga
(
    input [31:0] vga_in,
    output [31:0] vga_out,
    input clk_1M,

    input [7:0] dbgA,
    /* input dbgA0, */
    /* input dbgA1, */
    /* input dbgA2, */
    /* input dbgA3, */
    /* input dbgA4, */
    /* input dbgA5, */
    /* input dbgA6, */
    /* input dbgA7, */

    input [7:0] dbgB,
    /* input dbgB0, */
    /* input dbgB1, */
    /* input dbgB2, */
    /* input dbgB3, */
    /* input dbgB4, */
    /* input dbgB5, */
    /* input dbgB6, */
    /* input dbgB7, */

    output [7:0] up,
    output [7:0] down,
    output [1:0] step,
    output [1:0] debug

);

reg [17:0] cnt = 0;

/* assign step  = vga_in[17:16]; */
assign debug = vga_in[19:18];

assign up = dbgA;
/* assign up = { */
/*     dbgA7, */
/*     dbgA6, */
/*     dbgA5, */
/*     dbgA4, */
/*     dbgA3, */
/*     dbgA2, */
/*     dbgA1, */
/*     dbgA0}; */

assign down = dbgB;
/* assign down = { */
/*     dbgB7, */
/*     dbgB6, */
/*     dbgB5, */
/*     dbgB4, */
/*     dbgB3, */
/*     dbgB2, */
/*     dbgB1, */
/*     dbgB0}; */

assign vga_out = 32'b0;

always @ (posedge clk_1M)
    cnt <= cnt + 1;

assign step  = cnt[1:0];

    endmodule

