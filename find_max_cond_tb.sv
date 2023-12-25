`timescale 1 ns / 1 ns 

module find_max_cond_tb #(
			parameter SIZE = 32
			)
			(
			input [SIZE-1:0] in1,
			input [SIZE-1:0] in2
			);
			
reg [3:0] in;
reg [3:0][1:0] vals;
reg [2:0] out;
reg [2:0] out2;
			
find_max_cond find_index1(.in_cond(in), .in_max(vals), .first_index1(out));

initial begin
	vals[0] = 2'b01;
	vals[1] = 2'b10;
	vals[2] = 2'b11;
	vals[3] = 2'b00;
	
   in = 4'b0000;
	#2
	$display("");
	$display(out);
	#2
	in = 4'b0001;
	#2
	$display("");
	$display(out);
	#2
	in = 4'b0011;
	#2
	$display("");
	$display(out);
	#2
	in = 4'b0111;
	#2
	$display("");
	$display(out);
	#2
	in = 4'b1111;
	#2
	$display("");
	$display(out);
end
	
endmodule