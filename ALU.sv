`timescale 1 ns / 1 ns 

//implement ADD, SUB, AND, XOR, SRA

module ALU #(
			parameter SIZE = 32,
			parameter ALUOP_BITS = 3
			)
			(
			input [SIZE-1:0] in1,
			input [SIZE-1:0] in2,
			input [ALUOP_BITS-1:0] ALUOp,
			output [SIZE-1:0] out
			);
			
	localparam  ADD = 3'b000;
   localparam  SUB = 3'b001;
	localparam  AND = 3'b010;
   localparam  XOR = 3'b011;
	localparam  SRA = 3'b100;
			
	assign out = (ALUOp == ADD) ? (in1 + in2) : ((ALUOp == SUB) ? ((in1 > in2) ? (in1 - in2) : (in2 - in1)) : ((ALUOp == AND) ? (in1 & in2) : ((ALUOp == XOR) ? (in1 ^ in2) : ((ALUOp == SRA) ? (in1 >>> in2) : (in1)))));
	/*
	always @ * begin
		case (ALUOp)
			ADD: out = in1 + in2;
			SUB: out = in1 - in2;
			AND: out = in1 & in2;
			XOR: out = in1 ^ in2;
			SRA: out = in1 >>> in2;
			default: out = in1;
		endcase
   end
	*/
	
endmodule