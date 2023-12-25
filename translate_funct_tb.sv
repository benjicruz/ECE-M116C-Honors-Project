`timescale 1 ns / 1 ns 

module translate_funct_tb #(
			parameter SIZE = 32,
			parameter REG_NUM = 8,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			parameter STORED_ROWS = 16,
			parameter ROB_ROWS = 16,
			MEM_ROWS = 64
			)
 (
	output reg [31:0] instr1,
	output reg [6:0] opcode1, 
	output reg [4:0] pd1,
	output reg [2:0] func3_1,
	output reg [4:0] ps1_1, 
	output reg [4:0] ps2_1, 
	output reg [7:0] func7_1,
	output reg [31:0] instr2,
	output reg [6:0] opcode2, 
	output reg [4:0] pd2,
	output reg [2:0] func3_2,
	output reg [4:0] ps1_2, 
	output reg [4:0] ps2_2, 
	output reg [7:0] func7_2,
	output reg [INPUT_ROWS-1:0][ALUOP_BITS-1:0] new_ALUOp, //instruction IO
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg1,
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg2,
	output reg [INPUT_ROWS-1:0] new_use_imm,
	output reg [INPUT_ROWS-1:0][SIZE-1:0] new_imm,
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_dest_reg1
);

assign opcode1 = instr1[6:0];
assign func3_1 = instr1[14:12];
assign func7_1 = instr1[31:25];

translate_funct t1(.instr1(instr1), .opcode1(opcode1), .func3_1(func3_1), .func7_1(func7_1), .new_ALUOp(new_ALUOp), .new_use_imm(new_use_imm), .new_imm(new_imm));

/*
# Instruction 1: 00000000000100011111001010010011
# Instruction 2: 00000010010000000000000010010011
# Instruction 1: 00000000001000101000001000110011
# Instruction 2: 01000000000000000000000000110011
# Instruction 1: 00000001011100010000010010010011
# Instruction 2: 00000000001100010100001100110011
# Instruction 1: 01000000011000001000000100110011
# Instruction 2: 01000000000000011101001110110011
# Instruction 1: 01000000010100011101000110110011
# Instruction 2: 00000001011100011111010010010011
*/

/*
        addi x2, x0, 6  
        addi x3, x0, 15 
        andi x5, x3, 1
        addi x1, x0, 36
        add x4, x5, x2
        sub x0, x0, x0
        addi x9, x2, 23
	     xor x6, x2, x3
        sub x2, x1, x6
        sra x7, x3, x0
        sra x3, x3, x5
        andi x9, x3, 23
*/

initial begin
instr1 = 31'b00000000000100011111001010010011;
#10;
instr1 = 31'b00000010010000000000000010010011;
#10;
instr1 = 31'b00000000001000101000001000110011;
#10;
instr1 = 31'b01000000000000000000000000110011;
#10;
instr1 = 31'b00000001011100010000010010010011;
#10;
instr1 = 31'b00000000001100010100001100110011;
#10;
instr1 = 31'b01000000011000001000000100110011;
#10;
instr1 = 31'b01000000000000011101001110110011;
#10;
instr1 = 31'b01000000010100011101000110110011;
#10;
instr1 = 31'b00000001011100011111010010010011;
end

endmodule