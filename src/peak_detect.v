// Module    peak_detect
// Function : Detects the 3 highest values and records them and indexes
//
`timescale 1ns/1ps
module peak_detect #(
parameter integer VALUE_WIDTH = 32,
parameter integer INDEX_WIDTH = 11
)
(
    input clk,
    input tlast,
    input valid,
    input [INDEX_WIDTH-1:0] index,
    input [VALUE_WIDTH-1:0] value,

    output reg [VALUE_WIDTH-1:0] top1,
    output reg [VALUE_WIDTH-1:0] top2,
    output reg [VALUE_WIDTH-1:0] top3,

    output reg [INDEX_WIDTH-1:0] index1,
    output reg [INDEX_WIDTH-1:0] index2,
    output reg [INDEX_WIDTH-1:0] index3
        );

        reg tlast_d;

always @(posedge clk)
    tlast_d <= tlast;

always @(posedge clk) begin
        if (tlast) begin // TODO maybe need to delay tlast by 1
            top1 <= 0;
            index1 <= 0;
            top2 <= 0;
            index2 <= 0;
            top3 <= 0;
            index3 <= 0;
        end
        // only capture second half of points since symmetric
        else if ( valid && value > top1 && index[INDEX_WIDTH-1]) begin
            top1 <= value;
            top2 <= top1;
            top3 <= top2;
            index1 <= index;
            index2 <= index1;
            index3 <= index2;
        end
        else if (valid && value > top2 && index[INDEX_WIDTH-1]) begin
            top2 <= value;
            top3 <= top2;
            index2 <= index;
            index3 <= index2;
        end
        else if (valid && value > top1 && index[INDEX_WIDTH-1]) begin
            top3 <= value;
            index3 <= index;
        end
    end

endmodule

