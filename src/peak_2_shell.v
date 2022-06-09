/* This module handles a single channel */
/* accepts incoming stream along with index and valid signals */


`include "constants.vh"

`timescale 1ns/1ps

module peak_2_shell
(
    // AXI S slave - incoming data to be processed
    input clk,
    input aresetn,
    input valid,
    input last,
    output last_out,

    input [`VALUE_WIDTH-1:0] input_i,
    input [`INDEX_WIDTH-1:0] index_i,

    output  [`VALUE_WIDTH- 1 : 0] peak1_final,
    output  [`VALUE_WIDTH- 1 : 0] peak2_final,
    output  [`INDEX_WIDTH- 1 : 0] index1_final,
    output  [`INDEX_WIDTH- 1 : 0] index2_final
        );

wire reset;
assign reset = !aresetn;
wire catch1;
reg [`VALUE_WIDTH-1 : 0] peak1, peak2;
reg [`INDEX_WIDTH-1 : 0] index1, index2;
reg side1, side2;
wire [`VALUE_WIDTH-1 : 0] input_mid, input_end, input_begin;

// Now do the process for each channel
reg [`VALUE_WIDTH*2*`NUM_BINS - 1 : 0] sr_input;

genvar i;
generate
    for (i=1; i < 2*`NUM_BINS; i = i + 1) begin
        always @(posedge clk)
            if (valid)
                sr_input[i*`VALUE_WIDTH +: `VALUE_WIDTH] <= sr_input[(i-1)*`VALUE_WIDTH +: `VALUE_WIDTH];
    end
endgenerate

always @(posedge clk)
    if (valid)
        sr_input[0 +: `VALUE_WIDTH] <= input_i;

assign input_mid = sr_input[3*`VALUE_WIDTH +: `VALUE_WIDTH];

/* indicate that we need to update peak1 and index1 */
assign catch1 = ( (input_mid > peak1) && valid);

/* now catch largest peak */
always @(posedge clk)
    if (reset)
        peak1 <= 0;
    else if (catch1)
    begin
        peak1 <= input_mid;
        index1 <= index_i - 4;
    end

/* now capture peak2 */
    assign catch2 = (catch1 && (index_i - index2) > `PEAK_HOLDOFF);

always @(posedge clk)
    if (reset)
    begin
        peak2 <= 0;
        index2 <= 0;
    end
    else if (catch2)
    begin
        peak2 <= peak1;
        side2 <= side1;
        index2 <= index1;
    end


assign peak1_final = peak1;
assign peak2_final = peak2;
assign index1_final = index1;
assign index2_final = index2;

/* now capture the left / right for each peak */
/* for peak1 */

assign input_end = sr_input[`VALUE_WIDTH*(2*`NUM_BINS -1) +: `VALUE_WIDTH];
/* assign input_begin = sr_input[0 +: `VALUE_WIDTH]; */
always @(posedge clk)
    if (catch1)
    begin
        if (input_end > input_i)
            side1 <= 1'b0;
        else
            side1 <= 1'b1;
    end


endmodule

