`timescale 1 ns / 1 ns 



module station_rob_tb #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			parameter ROB_ROWS = 16,
			parameter PC_WIDTH = 10,
			parameter ROWS_TO_ADD = 2,
			parameter READ_PORTS = 6,
			MEM_ROWS = 64,
			ALU_NUM = 3
			)
			(
			output reg clk,
			output reg [INPUT_ROWS-1:0][ALUOP_BITS-1:0] ALUOp, //instruction IO
			output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] src_reg1,
			output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] src_reg2,
			output reg [INPUT_ROWS-1:0] use_imm,
			output reg [INPUT_ROWS-1:0][SIZE-1:0] imm,
			output reg [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] dest_reg1,
			output reg [INPUT_ROWS-1:0] new_valid,
			output reg [INPUT_ROWS-1:0][$clog2(ROB_ROWS)-1:0] new_robn,
			output reg [2:0] Comp,
			output reg [ALU_NUM-1:0][$clog2(ROB_ROWS)-1:0] out_robn,
			output reg [ALU_NUM-1:0] is_sw,
			
			
			output reg [ROB_ROWS-1:0] rob_valid,
			output reg [ROB_ROWS-1:0][$clog2(REG_NUM)-1:0] rob_dest_reg,
			output reg [ROB_ROWS-1:0][$clog2(REG_NUM)-1:0] rob_old_dest_reg,
			output reg [ROB_ROWS-1:0] rob_dest_reg_val_valid,
			output reg [ROB_ROWS-1:0][SIZE-1:0] rob_dest_reg_val,
			output reg [ROB_ROWS-1:0] rob_is_sw,
			output reg [ROB_ROWS-1:0][$clog2(MEM_ROWS)-1:0] rob_store_addr,
			output reg [ROB_ROWS-1:0][SIZE-1:0] rob_store_data,
			output reg [ROB_ROWS-1:0][PC_WIDTH-1:0] rob_pc,
			output reg [READ_PORTS-1:0][ROB_ROWS-1:0] rob_forward_ready,
			
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
			
			
	reg_station station1(.clk(clk),
			.new_ALUOp(ALUOp),
			.new_src_reg1(src_reg1),
			.new_src_reg2(src_reg2),
			.new_use_imm(use_imm),
			.new_imm(imm),
			.new_dest_reg1(dest_reg1),
			.new_valid(new_valid),
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
			
   rob_module rob1(.clk(clk), 
  .RegWrite(RegWrite), 
  .write_reg(write_reg), 
  .write_data(write_data), 
  .read_reg(read_reg), 
  .read_data(read_data),
  .station_robn(out_robn),
  .station_is_sw(is_sw),
  
  .rob_valid(rob_valid),
  .rob_dest_reg(rob_dest_reg),
  .rob_old_dest_reg(rob_old_dest_reg),
  .rob_dest_reg_val_valid(rob_dest_reg_val_valid),
  .rob_dest_reg_val(rob_dest_reg_val),
  .rob_is_sw(rob_is_sw),
  .rob_store_addr(rob_store_addr),
  .rob_store_data(rob_store_data),
  .rob_pc(rob_pc),
  .rob_forward_ready(rob_forward_ready),
  
   .add_valid(new_valid), 
	.add_old_dest_reg(0),
	.add_pc(add_pc),
	.added_robn(new_robn)
  );

  
  
  always #1 clk = ~clk;
	
	
	/*exponenetial test*/
	
	initial
	begin
		clk = 0;
		
		ALUOp[0] = 3'b111; //instruction IO
		src_reg1[0] = 0;
		src_reg2[0] = 2;
		use_imm[0] = 1;
		imm[0] = 0;
		dest_reg1[0] = 0;
		
		ALUOp[1] = 3'b000; //instruction IO
		src_reg1[1] = 0;
		src_reg2[1] = 0;
		use_imm[1] = 1;
		imm[1] = 10;
		dest_reg1[1] = 0;
		
		new_valid = 0;
	end
	
	initial
	begin
	  
	  #11;
	  add_pc[0] = 0;
	  add_pc[1] = 1;
	  new_valid = 2'b11;
	  #2;
	  add_pc[0] = add_pc[0] + 2;
	  add_pc[1] = add_pc[1] + 2;
	  use_imm[1] <= 0;
	  #2;
	  add_pc[0] = add_pc[0] + 2;
	  add_pc[1] = add_pc[1] + 2;
	  #2
	  new_valid = 2'b01;
	  add_pc[0] = add_pc[0] + 2;
	  add_pc[1] = add_pc[1] + 2;
	  #2;
	  new_valid = 2'b00;
	  #10;
	  #2;
	  #10;
	end
	
	/*
initial
	begin
		clk = 0;
		
		ALUOp[0] = 3'b000; //instruction IO
		src_reg1[0] = 0;
		src_reg2[0] = 2;
		use_imm[0] = 1;
		imm[0] = 0;
		dest_reg1[0] = 0;
		
		ALUOp[1] = 3'b000; //instruction IO
		src_reg1[1] = 0;
		src_reg2[1] = 0;
		use_imm[1] = 1;
		imm[1] = 10;
		dest_reg1[1] = 0;
		
		new_valid = 0;
	end
	
	initial
	begin
	  
	  #11;
	  new_valid = 2'b11;
	  #2;
	  new_valid = 2'b11;
	  #20;
	  new_valid = 2'b00;
	  #10;
	  #2;
	  #10;
	end*/

	
endmodule