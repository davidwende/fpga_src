/* This module handles a single channel */
/* Instantiates peak_detect_fast once for each peak to be detected */

`include "constants.vh"

`timescale 1ns/1ps

module peak_detect_fast_shell
(
    // AXI S slave - incoming data to be processed
    input clk,
    input aresetn,
    input valid,
    input last,
    output last_out,

    input [`VALUE_WIDTH-1:0] input_i,
    input [`INDEX_WIDTH-1:0] index_i,

    output  [(`NUM_PEAKS * `VALUE_WIDTH) - 1 : 0] peaks,
    output  [(`NUM_PEAKS * `INDEX_WIDTH) - 1 : 0] indices

        );

// Now do the process for each channel

wire [`NUM_PEAKS:0] last_io;
wire [`NUM_PEAKS:0] slip_io;
wire [`NUM_PEAKS:0] valid_io;
wire [`NUM_PEAKS:0] sample_previous_io;

wire reset;
assign reset = !aresetn;

wire [((1+`NUM_PEAKS)*`INDEX_WIDTH)-1 :0] index_io;
wire [((1+`NUM_PEAKS)*`VALUE_WIDTH)-1 :0] sample_io;
wire [((1+`NUM_PEAKS)*`VALUE_WIDTH)-1 :0] held_peak_io;
wire [((1+`NUM_PEAKS)*`INDEX_WIDTH)-1 :0] held_index_io;
wire [((1+`NUM_PEAKS)*`VALUE_WIDTH)-1 :0] held_peak_final;
wire [((1+`NUM_PEAKS)*`INDEX_WIDTH)-1 :0] held_index_final;

/* initialize first link in chain */
assign last_io[0] = last;
assign last_out = last_io[`NUM_PEAKS];
assign slip_io[0] = 1'b0;
assign valid_io[0] = valid;
assign sample_previous_io[0] = 1'b0;
assign held_peak_io[`VALUE_WIDTH-1:0] = 0;
assign held_index_io[`INDEX_WIDTH-1:0] = 0;

assign sample_io[`VALUE_WIDTH-1:0] = input_i;
assign index_io[`INDEX_WIDTH-1:0] = index_i;

genvar i;
generate
    for (i=0; i < `NUM_PEAKS; i = i + 1) begin
        peak_detect_fast my_peak_detect_fast
                          (
            .clk          ( clk      ) ,
            .reset        ( reset  ) ,

            .valid_in      ( valid_io[i]  ) ,
            .valid_out      ( valid_io[i+1]  ) ,

            .sample_previous_in       ( sample_previous_io[i]  ) ,
            .sample_previous_out      ( sample_previous_io[i+1]  ) ,

            .last_in       ( last_io[i]   ) ,
            .last_out       ( last_io[i+1]   ) ,

            .slip_in      ( slip_io[i] ) ,
            .slip_out      ( slip_io[i+1]  ) ,

            /* detected peak and index from previous stage */
            .held_peak_in ( held_peak_io[i*`VALUE_WIDTH +: `VALUE_WIDTH]  ) ,
            .held_index_in (held_index_io[i*`INDEX_WIDTH +: `INDEX_WIDTH]),

            /* detected peak and index from this stage */
            .held_peak_out  (held_peak_io[(i+1)*`VALUE_WIDTH +: `VALUE_WIDTH] ) ,
            .held_index_out (held_index_io[(i+1)*`INDEX_WIDTH +: `INDEX_WIDTH]),

            .held_peak_final  (peaks[i*`VALUE_WIDTH +: `VALUE_WIDTH] ) ,
            .held_index_final (indices[i*`INDEX_WIDTH +: `INDEX_WIDTH]),

            /* incoming samples are delayed */
            .sample_in     ( sample_io[i*`VALUE_WIDTH +: `VALUE_WIDTH]) ,
            .sample_out     ( sample_io[(i+1)*`VALUE_WIDTH +: `VALUE_WIDTH]) ,

            /* previous index may be used here */
            .index_in      ( index_io[i*`INDEX_WIDTH +: `INDEX_WIDTH]  ) ,
            .index_out      ( index_io[(i+1)*`INDEX_WIDTH +: `INDEX_WIDTH]  ) 
            );


    end
endgenerate


    endmodule


