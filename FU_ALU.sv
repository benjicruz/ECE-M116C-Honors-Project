`timescale 1 ns / 1 ns 

//implement ADD, SUB, AND, XOR, SRA

module FU_ALU #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter ROB_ROWS = 16
			)
			(
			input clk,
			input [ALUOP_BITS-1:0] ALUOp, //instruction IO
			input [$clog2(REG_NUM)-1:0] src_reg1,
			input [$clog2(REG_NUM)-1:0] src_reg2,
			input use_imm,
			input [SIZE-1:0] imm,
			input [$clog2(REG_NUM)-1:0] dest_reg1,
			input issue,
			output [0:0][$clog2(REG_NUM)-1:0] write_reg, //registers IO
			output [0:0][SIZE-1:0] write_data,
			output [1:0][$clog2(REG_NUM)-1:0] read_reg,
			input [1:0][SIZE-1:0] read_data,
			output reg RegWrite, //output current state
			output reg Comp,
			output ready,
			input [$clog2(ROB_ROWS)-1:0] in_robn, //ROB
			output reg [$clog2(ROB_ROWS)-1:0] out_robn,
			output is_sw
			);
			
			
	
	initial
	begin
		Comp = 0;
	end
	
	assign ready = 1;
	assign is_sw = 0;
	wire [SIZE-1:0] input2;
	
	ALU #(.SIZE(SIZE), .ALUOP_BITS(ALUOP_BITS)) ALU_1(.ALUOp(ALUOp), .in1(read_data[0]), .in2(input2), .out(write_data[0]));
	  
	assign input2 = use_imm ? imm : read_data[1];
	assign write_reg[0] = dest_reg1;
	assign read_reg[0] = src_reg1;
	assign read_reg[1] = src_reg2;
	
	assign RegWrite = issue;
	assign out_robn = in_robn;
			
	always @ (posedge clk) begin
		if(issue) begin
			Comp <= 1;
		end
		else begin
			Comp <= 0;
		end
   end
	
endmodule