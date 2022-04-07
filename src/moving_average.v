// Module    moving_average
// Function : Performs a moving average on window of 3 values

`include "constants.vh"

`timescale 1ns/1ps
module moving_average  (
    input clk,
    input valid_i,
    output valid_o,
    input last_i,
    output reg last_o,
    input [31:0] in,
    output [31:0] out
);

localparam integer DELAY = 3;

reg [31:0] ff1,ff2,ff3;
reg [1:0] sr_valid;
reg [1:0] sr_last;

always @ (posedge clk)
    sr_valid <= {sr_valid[0], valid_i};

assign valid_o = sr_valid[0];

always @ (posedge clk)
    if (valid_i)
        last_o <= last_i;
    else if (last_o)
        last_o <= 0;

always @ (posedge clk)
    if (valid_i)
    begin
        ff1 <= in;
        ff2 <= ff1;
        ff3 <= ff2;
    end
/* always @ (posedge clk) */
/*     if (sr_valid[0]) */
/*         ff2 <= ff1; */
/* always @ (posedge clk) */
/*     if (sr_valid[1]) */
/*         ff3 <= ff2; */

assign out = ff3 + ff2 + ff1;

/* mydelay #( .DELAY (DELAY)) delay_valid ( */
/*     .rstn (1'b1), */
/*     .clk  (clk), */
/*     .in   (valid_i), */
/*     .out (valid_o) */
/* ); */

/* mydelay #( .DELAY (DELAY)) delay_last ( */
/*     .rstn (1'b1), */
/*     .clk  (clk), */
/*     .in   (last_i), */
/*     .out (last_o) */
/* ); */
    endmodule



