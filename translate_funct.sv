`timescale 1 ns / 1 ns 

module translate_funct #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			parameter STORED_ROWS = 16,
			parameter ROB_ROWS = 16,
			MEM_ROWS = 64
			)
 (
	input [31:0] instr1,
	input [6:0] opcode1, 
	input [5:0] pd1,
	input [2:0] func3_1,
	input [5:0] ps1_1, 
	input [5:0] ps2_1, 
	input [7:0] func7_1,
	input [31:0] instr2,
	input [6:0] opcode2, 
	input [5:0] pd2,
	input [2:0] func3_2,
	input [5:0] ps1_2, 
	input [5:0] ps2_2, 
	input [7:0] func7_2,
	output [INPUT_ROWS-1:0][ALUOP_BITS-1:0] new_ALUOp, //instruction IO
	output [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg1,
	output [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg2,
	output [INPUT_ROWS-1:0] new_use_imm,
	output [INPUT_ROWS-1:0][SIZE-1:0] new_imm,
	output [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_dest_reg1
);

//ADD, SUB, ADDI, XOR, ANDI, SRA
//LW, SW

localparam  ADD = 3'b000;
localparam  SUB = 3'b001;
localparam  AND = 3'b010;
localparam  XOR = 3'b011;
localparam  SRA = 3'b100;
localparam  LW = 3'b101;
localparam  SW = 3'b110;
localparam  TEST = 3'b111;

assign new_ALUOp[0] = (opcode1 == 7'b0000011) ? LW : ((opcode1 == 7'b0100011) ? SW : ((func3_1 == 3'b101) ? SRA : ((func3_1 == 3'b100) ? XOR : ((func3_1 == 3'b111) ? AND : (((opcode1 == 7'b0110011) && (func7_1 == 7'b0100000)) ? SUB : ADD)))));
assign new_use_imm[0] = (opcode1 == 7'b0010011) ? 1 : 0;
assign new_imm[0] = (opcode1 == 7'b0100011) ? {instr1[31:25],instr1[11:7]} : instr1[31:20];
assign new_src_reg1[0] = ps1_1;
assign new_src_reg2[0] = ps2_1;
assign new_dest_reg1[0] = pd1;

assign new_ALUOp[1] = (opcode2 == 7'b0000011) ? LW : ((opcode2 == 7'b0100011) ? SW : ((func3_2 == 3'b101) ? SRA : ((func3_2 == 3'b100) ? XOR : ((func3_2 == 3'b111) ? AND : (((opcode2 == 7'b0110011) && (func7_2 == 7'b0100000)) ? SUB : ADD)))));
assign new_use_imm[1] = (opcode2 == 7'b0010011) ? 1 : 0;
assign new_imm[1] = (opcode2 == 7'b0100011) ? {instr2[31:25],instr2[11:7]} : instr2[31:20];
assign new_src_reg1[1] = ps1_2;
assign new_src_reg2[1] = ps2_2;
assign new_dest_reg1[1] = pd2;



endmodule