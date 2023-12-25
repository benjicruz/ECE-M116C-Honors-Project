`timescale 1 ns / 1 ns 

module find_index_tb #(
			parameter SIZE = 32
			)
			(
			input [SIZE-1:0] in1,
			input [SIZE-1:0] in2
			);
			
reg [3:0] in;
reg [2:0] out;
reg [2:0] out2;
			
find_index find_index1(.in(in), .first0(out), .second0(out2));

initial begin
   in = 4'b0000;
	#2
	$display("");
	$display(out);
	$display(out2);
	#2
	in = 4'b1000;
	#2
	$display("");
	$display(out);
	$display(out2);
	#2
	in = 4'b1100;
	#2
	$display("");
	$display(out);
	$display(out2);
	#2
	in = 4'b1110;
	#2
	$display("");
	$display(out);
	$display(out2);
	#2
	in = 4'b1111;
	#2
	$display("");
	$display(out);
	$display(out2);
end
	
endmodule