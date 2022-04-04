
module spi_top #(
   parameter CPOL =  4'd3 , // {U,X,0,1,Z,W,L,H,-}
   parameter CPHA =  4'd3 ,
   parameter CLKFREQ =  28'd50000000,
   parameter SCLKFREQ =24'd5000000
)
(
input clk,
	input reset,
	input [31:0] control,
	input [31:0] wrdata,
	output [31:0] rddata,
	output [31:0] status,

	output sclk,
	output csn,
	output mosi_o,
	input miso_i
);

reg en;
//reg csn;

wire byte_tc;
wire go, go_r;
reg go_d;
reg [2:0] byte_cnt;
reg [1:0] byte_pnt;
reg [1:0] state, state_next;
reg increment_byte;
wire data_ready;
wire [1:0] num_bytes;
wire [7:0] mosi_data, miso_data;
reg [31:0] rddata_l;
parameter IDLE = 0, DO_BYTE = 1, INC_BYTE = 2;

//lw_spi_master #(
spi_master #(
    .c_clkfreq  ( 50000000 ),
    .c_sclkfreq ( 5000000 ),
    .c_cpol     ( CPOL ), // {U,X,0,1,Z,W,L,H,-}
    .c_cpha     ( CPHA )
) lw_spi_master_inst (
    .clk_i       	( clk ), // input
    .en_i        	( en ), // input
    .mosi_data_i 	( mosi_data), // input
    .miso_data_o 	( miso_data ), // output
    .data_ready_o	( data_ready ), //  output
    .cs_o        	( csn ), //  output
    .sclk_o      	( sclk ), //  output
    .mosi_o      	( mosi_o ), //  output
    .miso_i      	( miso_i ) //  input
);

assign go = control[31];
assign num_bytes = control[1:0];
assign status[0] = (state == IDLE) ? 1'b1 : 1'b0;
assign status[31:1] = 31'b0;


always @ (posedge clk)
    go_d <= go;

assign go_r = (go && !go_d) ? 1'b1 : 1'b0;


always @ (posedge clk) begin
    if (reset)
        state <= IDLE;
    else
        state <= state_next;
end


always @ (state, go_r, data_ready) begin
    state_next <= state;
    increment_byte <= 1'b0;
    en <= 1'b0;
    case (state)
        IDLE: begin
            if (go_r) begin
                state_next <= DO_BYTE;
                en <= 1'b1;
            end
        end

        DO_BYTE: begin
        en <= 1'b1;
            if (data_ready) begin
                state_next <= INC_BYTE;
                increment_byte <= 1'b1;
            end
        end

        INC_BYTE: begin
            if (byte_tc) begin
                state_next <= IDLE;
                en <= 1'b0;
            end
            else
            begin
                en <= 1'b1;
                state_next <= DO_BYTE;
            end
        end
    endcase
end

always @ (posedge clk)
    if (reset || state == IDLE)
        byte_pnt <= num_bytes;
    else if (increment_byte)
        byte_pnt <= byte_pnt - 1;

always @ (posedge clk)
    if (reset || state == IDLE)
        byte_cnt <= num_bytes + 1;
    else if (increment_byte)
        byte_cnt <= byte_cnt - 1;

assign byte_tc = (byte_cnt == 0) ? 1'b1 : 1'b0;
assign mosi_data = wrdata[8*byte_pnt +: 8];

always @ (posedge clk)
    if (reset)
        rddata_l <= 32'b0;
    else if (data_ready)
        rddata_l <= {rddata_l[23:0], miso_data};

assign rddata = rddata_l;

    endmodule
