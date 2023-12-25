`timescale 1ns/1ns

module decode (
	PC1, PC2, PC1_o, PC2_o, start, 
	instr1, opcode1, rd_1, func3_1, rs1_1, rs2_1, func7_1, 
	instr2, opcode2, rd_2, func3_2, rs1_2, rs2_2, func7_2
);

	input start;
	input [7:0] PC1;
	input [7:0] PC2;
	
	output reg [7:0] PC1_o;
	output reg [7:0] PC2_o;


	input [31:0] instr1;
	output reg [6:0] opcode1; 
	output reg [4:0] rd_1; 
	output reg [2:0] func3_1;
	output reg [4:0] rs1_1; 
	output reg [4:0] rs2_1; 
	output reg [7:0] func7_1;
	
	input [31:0] instr2;
	output reg [6:0] opcode2; 
	output reg [4:0] rd_2; 
	output reg [2:0] func3_2;
	output reg [4:0] rs1_2; 
	output reg [4:0] rs2_2; 
	output reg [7:0] func7_2;
	
	always @ (*) begin
	
		if(start) begin
		opcode1 = instr1[6:0];
		rd_1 = instr1[11:7];
		func3_1 = instr1[14:12];
		rs1_1 = instr1[19:15];
		rs2_1 = instr1[24:20];
		func7_1 = instr1[31:25];
		
		opcode2 = instr2[6:0];
		rd_2 = instr2[11:7];
		func3_2 = instr2[14:12];
		rs1_2 = instr2[19:15];
		rs2_2 = instr2[24:20];
		func7_2 = instr2[31:25];
	
		PC1_o = PC1;
		PC2_o = PC2;

		end
	end

endmodule