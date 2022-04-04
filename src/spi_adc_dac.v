// Module    PM_SPI
// Function : Houses 4 separate independent SPI modules for PM pmS and ADC
//
`timescale 1ns/1ps
module spi_adc_pm
(
    // AXI to vector memories
    input [31:0] control_adc,        // input wire s_axi_aclk
    input [31:0] control_pm0,        // input wire s_axi_aclk
    input [31:0] control_pm1,        // input wire s_axi_aclk
    input [31:0] control_pm2,        // input wire s_axi_aclk

    input [31:0] data_adc,        // input wire s_axi_aclk
    input [31:0] data_pm0,        // input wire s_axi_aclk
    input [31:0] data_pm1,        // input wire s_axi_aclk
    input [31:0] data_pm2,        // input wire s_axi_aclk

    output [31:0] dataout_adc,        // input wire s_axi_aclk
    output [31:0] dataout_pm0,        // input wire s_axi_aclk
    output [31:0] dataout_pm1,        // input wire s_axi_aclk
    output [31:0] dataout_pm2,        // input wire s_axi_aclk

    output [31:0] status_adc,        // input wire s_axi_aclk
    output [31:0] status_pm0,        // input wire s_axi_aclk
    output [31:0] status_pm1,        // input wire s_axi_aclk
    output [31:0] status_pm2,        // input wire s_axi_aclk

   input clk,

    input reset,

   // ADC
   output sclk_adc   ,
   output csn_adc    ,
   output mosi_adc ,
   input adc_miso,

   // pm 0
   output sclk_pm0   ,
   output csn_pm0    ,
   output mosi_pm0 ,
   input pm0_miso,

   // pm 1
   output sclk_pm1   ,
   output csn_pm1    ,
   output mosi_pm1 ,
   input pm1_miso,

   // pm 2
   output sclk_pm2   ,
   output csn_pm2    ,
   output mosi_pm2 ,
   input pm2_miso
);

wire adc_status;
wire pm0_status;
wire pm1_status;
wire pm2_status;

spi_top #(
.CPOL (4'd3),
.CPHA (4'd3),
   .CLKFREQ  ( 28'd50000000),
   .SCLKFREQ ( 24'd1000000 )
) spi_adc (
   .clk     ( clk )     ,
   .reset   (reset )  ,
   .control (control_adc) ,
   .wrdata  (data_adc)  ,
   .rddata  (dataout_adc)  ,
   .status  (status_adc)  ,

   .sclk    (sclk_adc  )  ,
   .csn     (csn_adc   )  ,
   .mosi_o  (mosi_adc)  ,
   .miso_i  (adc_miso)
);

/* assign status_adc = {adc_status, 31'h0}; */

spi_top #(
.CPOL (4'd2),
.CPHA (4'd2), // 2 or 3
   .CLKFREQ  ( 28'd50000000),
   .SCLKFREQ ( 24'd1000000 )
) spi_pm0 (
   .clk     ( clk )     ,
   .reset   (reset )  ,
   .control (control_pm0) ,
   .wrdata  (data_pm0)  ,
   .rddata  (dataout_pm0)  ,
   .status  (status_pm0)  ,

   .sclk    (sclk_pm0  )  ,
   .csn     (csn_pm0   )  ,
   .mosi_o  (mosi_pm0)  ,
   .miso_i  (pm0_miso)
);

/* assign status_pm0 = {pm0_status, 31'h0}; */

spi_top #(
.CPOL (4'd2),
.CPHA (4'd2),
   .CLKFREQ  ( 28'd50000000),
   .SCLKFREQ ( 24'd1000000 )
) spi_pm1 (
   .clk     ( clk )     ,
   .reset   (reset )  ,
   .control (control_pm1) ,
   .wrdata  (data_pm1)  ,
   .rddata  (dataout_pm1)  ,
   .status  (status_pm1)  ,

   .sclk    (sclk_pm1  )  ,
   .csn     (csn_pm1   )  ,
   .mosi_o  (mosi_pm1)  ,
   .miso_i  (pm1_miso)
);

/* assign status_pm1 = {pm1_status, 31'h0}; */

spi_top #(
.CPOL (4'd2),
.CPHA (4'd2),
   .CLKFREQ  ( 28'd50000000),
   .SCLKFREQ ( 24'd1000000 )
) spi_pm2 (
   .clk     ( clk )     ,
   .reset   (reset )  ,
   .control (control_pm2) ,
   .wrdata  (data_pm2)  ,
   .rddata  (dataout_pm2)  ,
   .status  (status_pm2)  ,

   .sclk    (sclk_pm2  )  ,
   .csn     (csn_pm2   )  ,
   .mosi_o  (mosi_pm2)  ,
   .miso_i  (pm2_miso)
);

/* assign status_pm2 = {pm2_status, 31'h0}; */

    endmodule

