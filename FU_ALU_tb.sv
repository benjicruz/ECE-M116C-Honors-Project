`timescale 1 ns / 1 ns 



module FU_ALU_tb #(
			parameter SIZE = 32,
			parameter REG_NUM = 8,
			parameter ALUOP_BITS = 3
			)
			(input in1, 
			output out
			);
			
	reg clk = 0;
	reg [ALUOP_BITS-1:0] ALUOp = 0; //instruction IO
	reg [$clog2(REG_NUM)-1:0] src_reg1 = 0;
	reg [$clog2(REG_NUM)-1:0] src_reg2 = 0;
	reg use_imm = 1;
	reg [SIZE-1:0] imm = 10;
	reg [$clog2(REG_NUM)-1:0] dest_reg1 = 0;
	reg issue = 0;
	wire [0:0][$clog2(REG_NUM)-1:0] write_reg; //registers IO
	wire [0:0][SIZE-1:0] write_data;
	wire [1:0][$clog2(REG_NUM)-1:0] read_reg;
	wire [1:0][SIZE-1:0] read_data;
	reg RegWrite;
	reg Comp;
			

  
  FU_ALU FU_ALU_1(.clk(clk), .ALUOp(ALUOp), .src_reg1(src_reg1), .src_reg2(src_reg2), .use_imm(use_imm), .imm(imm), .dest_reg1(dest_reg1), .issue(issue), 
  .write_reg(write_reg), .write_data(write_data), .read_reg(read_reg), 
  .read_data(read_data), .RegWrite(RegWrite), .Comp(Comp));
  registers_wp1 regs1(.clk(clk), .RegWrite(RegWrite), .write_reg(write_reg), .write_data(write_data), .read_reg(read_reg), .read_data(read_data));
  
  initial begin
			$display(read_data[0]);
			#2
			$display(read_data[0]);
			issue = 1;
			#2
			issue = 0;
			$display(read_data[0]);
			#2
			$display(read_data[0]);
			#10
			#10
			issue = 1;
			#2
			dest_reg1 <= 1;
			#2
			issue = 0;
			#10
			#10
			#10
			$display(read_data[0]);
			src_reg1 = 1;
			#10
			$display(read_data[0]);
			src_reg1 = 0;
			#10
			$display(read_data[0]);
	end
	
	always #1 clk = ~clk;
	
endmodule