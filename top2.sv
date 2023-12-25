`timescale 1ns/1ns

//"C:/Users/egorb/Documents/M116/git1/ECE-M116C-Honors/traces/r-test-hex.txt"
module top2#(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			parameter ROB_ROWS = 16,
			parameter PC_WIDTH = 10,
			parameter READ_PORTS = 6,
			parameter ROWS_TO_ADD = 2,
			MEM_ROWS = 64,
			ALU_NUM = 3
			)(
	output reg [31:0] instr1_ren_in, //rename+decode stage
	output reg [31:0] instr2_ren_in,

   output reg[7:0] PC1_ren_out,
	output reg[7:0] PC2_ren_out,
	
	output reg [6:0] opcode1_ren_out,
	output reg [5:0] pd_1_ren_out,
	output reg [2:0] func3_1_ren_out,
	output reg [5:0] ps1_1_ren_out, 
	output reg [5:0] ps2_1_ren_out, 
	output reg [7:0] func7_1_ren_out,

	
	output reg [6:0] opcode2_ren_out, 
	output reg [5:0] pd_2_ren_out, 
	output reg [2:0] func3_2_ren_out,
	output reg [5:0] ps1_2_ren_out, 
	output reg [5:0] ps2_2_ren_out,
	output reg [7:0] func7_2_ren_out,

	
	output reg [5:0] old_pd1,
	output reg [5:0] old_pd2,
	output reg valid1,
	output reg valid2,
	
	output reg [INPUT_ROWS-1:0][ALUOP_BITS-1:0] new_ALUOp, //translation stage
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg1,
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg2,
	output reg [INPUT_ROWS-1:0] new_use_imm,
	output reg [INPUT_ROWS-1:0][SIZE-1:0] new_imm,
	output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_dest_reg1,
	
	output reg [INPUT_ROWS-1:0][$clog2(ROB_ROWS)-1:0] new_robn,//res station + ROB stage
	output reg [2:0] Comp,
	output reg [ALU_NUM-1:0][$clog2(ROB_ROWS)-1:0] out_robn,
	output reg [ALU_NUM-1:0] is_sw,
	
	output reg [ALU_NUM-1:0][$clog2(REG_NUM)-1:0] write_reg, ////FUs - regs IO
	output reg [ALU_NUM-1:0][SIZE-1:0] write_data,
	output reg [2*ALU_NUM-1:0][$clog2(REG_NUM)-1:0] read_reg,
	output reg [2*ALU_NUM-1:0][SIZE-1:0] read_data,
	output reg [ALU_NUM-1:0] RegWrite,
	
	output reg [ROWS_TO_ADD-1:0][PC_WIDTH-1:0] add_pc,
	
	output reg [0:0] EnWrite, // Memory IO
	output reg [0:0][$clog2(MEM_ROWS)-1:0] write_addr,
	output reg [0:0][SIZE-1:0] write_data_mem,
	output reg [0:0][$clog2(MEM_ROWS)-1:0] read_addr,
	output reg [0:0][SIZE-1:0] read_data_mem
);

reg clk = 0;
		
initial begin
	clk = 0;
end
	always #1 clk = ~clk;
	
reg rt1valid;
reg rt2valid;
reg [5:0] rt1reg;
reg [5:0] rt2reg;
	
	//rename + decode stages
stage1 stage1_ins(clk, instr1_ren_in, instr2_ren_in, old_pd1, old_pd2,  valid1, valid2, rt1valid, rt2valid, rt1reg, rt2reg,
			opcode1_ren_out, func3_1_ren_out, func7_1_ren_out, opcode2_ren_out, func3_2_ren_out, func7_2_ren_out,
			  PC1_ren_out, PC2_ren_out, pd_1_ren_out, ps2_1_ren_out, ps1_1_ren_out, pd_2_ren_out, ps1_2_ren_out, ps2_2_ren_out
);

//translation of ALUOp and immidiates
translate_funct translation1(
	.instr1(instr1_ren_in),
	.opcode1(opcode1_ren_out), 
	.pd1(pd_1_ren_out),
	.func3_1(func3_1_ren_out),
	.ps1_1(ps1_1_ren_out), 
	.ps2_1(ps2_1_ren_out), 
	.func7_1(func7_1_ren_out),
	.instr2(instr2_ren_in),
	.opcode2(opcode2_ren_out), 
	.pd2(pd_2_ren_out),
	.func3_2(func3_2_ren_out),
	.ps1_2(ps1_2_ren_out), 
	.ps2_2(ps2_2_ren_out), 
	.func7_2(func7_2_ren_out),
	.new_ALUOp(new_ALUOp), //instruction IO
	.new_src_reg1(new_src_reg1),
	.new_src_reg2(new_src_reg2),
	.new_use_imm(new_use_imm),
	.new_imm(new_imm),
	.new_dest_reg1(new_dest_reg1)
);
			
//reservation station
reg_station station1(.clk(clk),
	.new_ALUOp(new_ALUOp),
	.new_src_reg1(new_src_reg1),
	.new_src_reg2(new_src_reg2),
	.new_use_imm(new_use_imm),
	.new_imm(new_imm),
	.new_dest_reg1(new_dest_reg1),
	.new_valid({valid1,valid2}),
	.new_robn(new_robn),
	.Comp(Comp),
	.RegWrite(RegWrite), 
	.write_reg(write_reg), 
	.write_data(write_data), 
	.read_reg(read_reg), 
	.read_data(read_data),
	.out_robn(out_robn),
	.is_sw(is_sw),
	.EnWrite(EnWrite),
	.write_addr(write_addr),
	.write_data_mem(write_data_mem),
	.read_addr(read_addr),
	.read_data_mem(read_data_mem)
	);
	
//ROB	
 rob_module rob1(.clk(clk), 
  .RegWrite(RegWrite), 
  .write_reg(write_reg), 
  .write_data(write_data), 
  .read_reg(read_reg), 
  .read_data(read_data),
  .station_robn(out_robn),
  .station_is_sw(is_sw),
  .add_valid({valid1,valid2}), 
  .add_old_dest_reg({old_pd1, old_pd2}),
  .add_pc(add_pc),
  .added_robn(new_robn),
  .retire_signals({rt1valid,rt2valid}),
  .reg_to_retire({rt1reg,rt2reg}),
  .EnWrite(EnWrite),
  .write_addr(write_addr),
  .write_data_mem(write_data_mem),
  .read_addr(read_addr),
  .read_data_mem(read_data_mem)
  );
  
	initial
	begin
	  add_pc[0] = 0;
	  add_pc[1] = 1;
	end
	
	always @ (posedge clk) begin
		add_pc[0] = add_pc[0]+2;
		add_pc[1] = add_pc[1]+2;
	end


endmodule
