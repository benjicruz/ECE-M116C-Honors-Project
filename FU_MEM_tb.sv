`timescale 1 ns / 1 ns 



module FU_MEM_tb #(
			parameter SIZE = 32,
			parameter REG_NUM = 8,
			parameter ALUOP_BITS = 3,
			MEM_ROWS = 64
			)
			(input in1, 
			output out,
			output reg clk,
			output reg [ALUOP_BITS-1:0] ALUOp, //instruction IO
			output reg [$clog2(REG_NUM)-1:0] src_reg1,
			output reg [$clog2(REG_NUM)-1:0] src_reg2,
			output reg use_imm,
			output reg [SIZE-1:0] imm,
			output reg [$clog2(REG_NUM)-1:0] dest_reg1,
			output reg issue,
			output reg [0:0][$clog2(REG_NUM)-1:0] write_reg, //registers IO
			output reg [0:0][SIZE-1:0] write_data,
			output reg [1:0][$clog2(REG_NUM)-1:0] read_reg,
			output reg [1:0][SIZE-1:0] read_data,
			output reg RegWrite,
			output reg [0:0] EnWrite, // Memory IO
			output reg [0:0][$clog2(MEM_ROWS)-1:0] write_addr,
			output reg [0:0][SIZE-1:0] write_data_mem,
			output reg [0:0][$clog2(MEM_ROWS)-1:0] read_addr,
			output reg [0:0][SIZE-1:0] read_data_mem,
			
			output reg [$clog2(REG_NUM)-1:0] read_reg_test,
			output reg [SIZE-1:0] read_data_test,
			output reg RegWrite_test,
			output reg [$clog2(REG_NUM)-1:0] write_reg_test,
			output reg [SIZE-1:0] write_data_test,
			output reg Comp
			);
			

	initial
	begin
		clk = 0;
		ALUOp = 3'b111; //instruction IO
		src_reg1 = 0;
		src_reg2 = 2;
		use_imm = 1;
		imm = 0;
		dest_reg1 = 0;
		issue = 0;
		
		write_data_test = 0;
		write_reg_test = 2;
		RegWrite_test = 0;
		read_reg_test = 2;
	end
			

  
  FU_MEM FU_MEM_1(.clk(clk), .ALUOp(ALUOp), .src_reg1(src_reg1), .src_reg2(src_reg2), .use_imm(use_imm), .imm(imm), .dest_reg1(dest_reg1), .issue(issue), .write_reg(write_reg), 
  .write_data_reg(write_data), .read_reg(read_reg), .read_data_reg(read_data), 
  .RegWrite(RegWrite), .write_addr(write_addr), .write_data_mem(write_data_mem), 
  .read_addr(read_addr), .read_data_mem(read_data_mem), .EnWrite(EnWrite), .Comp(Comp));
  registers_wp2 #(.READ_PORTS(3)) regs1(.clk(clk), .RegWrite({RegWrite,RegWrite_test}), .write_reg({write_reg,write_reg_test}), .write_data({write_data,write_data_test}), .read_reg({read_reg,read_reg_test}), .read_data({read_data,read_data_test}));
  Memory mem(.EnWrite(EnWrite), .clk(clk), .write_addr(write_addr), .write_data(write_data_mem), .read_addr(read_addr), .read_data(read_data_mem));
  
  initial begin
			//$display(read_data_test);
			//write_data_test = 111;
			//RegWrite_test = 1;
			//#2
			//RegWrite_test = 0;
			//$display(read_data_test);
			#10
			//issue = 1;
			#2
			//issue = 0;
			#10
			ALUOp = 3'b111;
			#10
			issue = 1;
			#4
			issue = 0;
			#10
			//read_reg_test = 0;
			#10
			//$display(read_data_test);
			#10
			#10
			//ALUOp = 3'b111;
			#10
			//issue = 1;
			#2
			//issue = 0;
			#10
			$display("");

			
	end
	
	always #1 clk = ~clk;
	
endmodule