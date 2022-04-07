// Module    peak_detect
// Function : Detects the 3 highest values and records them and indexes
//
`include "constants.vh"

`timescale 1ns/1ps
module peak_detect_fast
(
    input clk,
    input reset,

    input  valid_in,
    output reg valid_out,

    input  last_in,
    output reg last_out,

    input  slip_in,
    output reg slip_out,

    input  sample_previous_in,
    output reg sample_previous_out,


    /* the held index and peak from previous stage */
    input  [`VALUE_WIDTH-1:0] held_peak_in,
    input  [`INDEX_WIDTH-1:0] held_index_in,

    /* held peak and index from this stage */
    output reg [`VALUE_WIDTH-1:0] held_peak_out,
    output reg [`VALUE_WIDTH-1:0] held_peak_final,

    output reg [`INDEX_WIDTH-1:0] held_index_out,
    output reg [`INDEX_WIDTH-1:0] held_index_final,

    /* delayed versions of incoming streams */
    input  [`VALUE_WIDTH-1:0] sample_in,
    output reg [`VALUE_WIDTH-1:0] sample_out,

    input  [`INDEX_WIDTH-1:0] index_in,
    output reg [`INDEX_WIDTH-1:0] index_out
        );

wire sample_here;
reg [`VALUE_WIDTH-1:0] held_peak_out_l;
reg [`INDEX_WIDTH-1:0] held_index_out_l;

always @(posedge clk) begin
    held_peak_out <= held_peak_out_l;
    held_index_out <= held_index_out_l;
end

/* Delay conrols from upstream before passing them on */
always @(posedge clk) begin
    if (reset) begin
        index_out <= 0;
        last_out <= 0;
        valid_out <= 0;
    end
    else begin
        index_out <= index_in;
        last_out <= last_in;
        sample_out <= sample_in;
        valid_out <= valid_in;
    end
end

/* sample here if valid and large input */
assign sample_here = (valid_in && (sample_in > held_peak_out_l) && !sample_previous_in && index_in[`INDEX_WIDTH-1]) ? 1'b1 : 1'b0;

always @(posedge clk)
    sample_previous_out <= sample_here;

/* control the slip downstream */
always @(posedge clk)
    if (slip_in || sample_here)
        slip_out <= 1'b1;
    else
        slip_out <= 1'b0;

/* Now do the actual updating */
always @(posedge clk) begin
    if (reset || last_in) begin
        held_peak_out_l <= 0;
        held_index_out_l <= 0;
    end else if (slip_in) begin
        /* update with held values from previous stage */
        held_peak_out_l <= held_peak_in;
        held_index_out_l <= held_index_in;
    end else if (sample_here) begin
        /* update with incoming stream values */
        held_peak_out_l <= sample_in;
        held_index_out_l <= index_in;
    end
end

/* now register the final values for read back */
always @(posedge clk)
    if (last_in) begin
        held_peak_final <= held_peak_out;
        held_index_final <= held_index_out;
    end

endmodule
