// constants.vh

`ifndef __david__
`define __david__ 1

`define CHANNELS 8

// fft 2048 / 24 / 11
// fft 32 / 16 / 6

`define INDEX_WIDTH 11
`define TUSER_WIDTH 24
`define PIXEL_SIZE 2048
`define MULTI_OUT_WIDTH 25

// peaks
`define NUM_PEAKS 4

// remove lower 3 nibbles
`define PEAK_SHIFT 8
// and also when using average
`define AVERAGE_PEAK_SHIFT 10

// take 16 bits, i.e. ignore highest nibble
`define VALUE_WIDTH 16

`endif
