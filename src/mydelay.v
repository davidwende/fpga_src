`timescale 1ns/1ps
module mydelay   #(
    parameter integer DELAY	= 3
)
(
    input rstn,
    input clk,
    input in,
    output out
        );

reg [DELAY:0] sr;

 always @(posedge clk)
    if (!rstn)
     sr <= 0;
 else
     sr <= {sr[DELAY-1 : 0] , in};

assign out	= sr[DELAY];

    endmodule

