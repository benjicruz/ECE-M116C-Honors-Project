`timescale 1 ns / 1 ns 

module find_index_inv #(
    parameter SIZE = 4
) (
    input [SIZE-1:0] in,
    output [$clog2(SIZE):0] first0,
	 output [$clog2(SIZE):0] second0
);

wire [$clog2(SIZE):0] temp [0:SIZE];
assign temp[0] = -1;

generate genvar i;
    for(i=0; i<SIZE; i=i+1) begin: gen_block1	
        assign temp[i+1] = in[i] ? i : temp[i]; 
	 end
endgenerate

assign first0 = temp[SIZE];
assign second0 = temp[first0];

endmodule