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

localparam integer FAR = 0;
localparam integer NEAR = 1;

wire reset;
assign reset = !aresetn;

/* how to handle incoming values */
wire catch1;
wire catch2;
wire save_input;
wire save_p1;
wire slip;
wire restore;
wire dist1;
wire dist_saved;

reg [`VALUE_WIDTH-1 : 0] peak1, peak2, peak_saved;
reg [`INDEX_WIDTH-1 : 0] index1, index2, index_saved;
wire [`INDEX_WIDTH-1 : 0] index_mid;
reg side1, side2, side_saved;
wire [`VALUE_WIDTH-1 : 0] input_mid, input_end;

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
assign index_mid = (index_i - 5);

/* indicate that we need to update peak1 and index1 */
/* catch1 : input is larger than peak1, so replaces peak1 */
assign catch1 =  (input_mid > peak1) ;
assign dist1 = ((index_mid - index1) < `PEAK_HOLDOFF) ? NEAR : FAR;
assign dist_saved = ((index_mid - index_saved) < `PEAK_HOLDOFF) ? NEAR : FAR;

/* catch2 : input is larger than peak2 but smaller than peak1
* and distance from current peak is far, so input replaces peak2 */
assign catch2 = (~catch1 && (input_mid > peak2) && (dist1 == FAR));

/* slip : peak1 was replaced by input and distance large so peak1 replaces peak2 */
assign slip = (catch1 && dist1 == FAR);

/* save2 : peak1 was replaced by input but previous peak1 was near, therefore
* it cannot become peak2. We save it incase it becomes "far" and can
* therefore be used */
assign save_p1 = (catch1 && (dist1 == NEAR));
/* assign save_input = (~catch1 && (input_mid > peak_saved) && (dist1 == NEAR)); */
assign save_input = (~catch1 && (input_mid > peak2) && (dist1 == NEAR));

/* restore: A new peak1 registered that makes the saved 2 now "far" */
assign restore = (catch1 && (peak_saved > peak2) && (dist_saved == FAR));

/* now catch largest peak */
always @(posedge clk)
    if (reset)
    begin
        peak1      <= 0;
        index1     <= 0;
    end
    else if (catch1 && valid)
    begin
        peak1      <= input_mid;
        index1     <= index_mid;
    end


/* save potential peaks to temp storage */
always @(posedge clk)
    if (reset)
    begin
        peak_saved  <= 0;
        index_saved <= 0;
    end
    else if (save_p1 && valid)
    begin
        peak_saved <= peak1;
        index_saved <= index1;
        side_saved <= side1;
    end
    else if (save_input && valid)
    begin
        peak_saved <= input_mid;
        index_saved <= index_mid;
        if (input_end > input_i)
            side_saved <= 1'b0;
        else
            side_saved <= 1'b1;
    end

/* Store values into peak2 from either:
* 1. temp storage or
* 2. slip from p1 or
* 3. capture from input */
always @(posedge clk)
    if (reset)
    begin
        peak2  <= 0;
        index2 <= 0;
    end
    else if (slip && valid)
    begin
        peak2 <= peak1;
        index2 <= index1;
        side2  <= side1;
    end
    else if (catch2 && valid)
    begin
        peak2 <= input_mid;
        index2 <= index_mid;
        if (input_end > input_i)
            side2 <= 1'b0;
        else
            side2 <= 1'b1;
    end
    else if (restore && valid)
    begin
        peak2 <= peak_saved;
        index2 <= index_saved;
        side2  <= side_saved;
    end


assign peak1_final = peak1;
assign peak2_final = peak2;
assign index1_final = index1;
assign index2_final = index2;

/* now capture the left / right for each peak */
/* for peak1 */

assign input_end = sr_input[`VALUE_WIDTH*(2*`NUM_BINS -1) +: `VALUE_WIDTH];
always @(posedge clk)
    if (catch1)
    begin
        if (input_end > input_i)
            side1 <= 1'b0;
        else
            side1 <= 1'b1;
    end


endmodule

