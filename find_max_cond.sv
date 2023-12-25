`timescale 1 ns / 1 ns 

// this module serves a similar purpose to argmax function
module find_max_cond #(
    parameter SIZE = 4,
	 parameter VAL_WIDTH = 2
) (
    input [SIZE-1:0] in_cond,
	 input [SIZE-1:0][VAL_WIDTH-1:0] in_max,
    output [$clog2(SIZE):0] first_index1,
	 output [$clog2(SIZE):0] second_index1
);

wire [$clog2(SIZE):0] temp [0:SIZE];
wire [VAL_WIDTH-1:0] temp_max [0:SIZE];
assign temp[0] = -1;
assign temp_max[0] = in_max[0];

generate genvar i;
    for(i=0; i<SIZE; i=i+1) begin: gen_block1	
        assign temp[i+1] = (in_cond[i] && (in_max[i] >= temp_max[i])) ? i : temp[i];
		  assign temp_max[i+1] = (in_cond[i] && (in_max[i] >= temp_max[i])) ? in_max[i] : temp_max[i];
	 end
endgenerate

assign first_index1 = temp[SIZE];//-1
assign second_index1 = temp[first_index1];

endmodule