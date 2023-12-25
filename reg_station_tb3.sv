`timescale 1 ns / 1 ns 



module reg_station_tb3 #(
			parameter SIZE = 32,
			parameter REG_NUM = 8,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			MEM_ROWS = 64
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
			output reg [2:0] Comp
			);
			
	always #1 clk = ~clk;
			
	reg_station station1(.clk(clk),
			.new_ALUOp(ALUOp),
			.new_src_reg1(src_reg1),
			.new_src_reg2(src_reg2),
			.new_use_imm(use_imm),
			.new_imm(imm),
			.new_dest_reg1(dest_reg1),
			.new_valid(new_valid),
			.Comp(Comp));

	/* ALU assignment test */
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
	end

	
endmodule