`timescale 1 ns / 1 ns 

//implement LW, SW

module FU_MEM #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter MEM_ROWS = 64,
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
			output [0:0][SIZE-1:0] write_data_reg,
			output [1:0][$clog2(REG_NUM)-1:0] read_reg,
			input [1:0][SIZE-1:0] read_data_reg,
			output reg RegWrite,
			output reg [0:0] EnWrite, // Memory IO
			output [0:0][$clog2(MEM_ROWS)-1:0] write_addr,
			output [0:0][SIZE-1:0] write_data_mem,
			output [0:0][$clog2(MEM_ROWS)-1:0] read_addr,
			input [0:0][SIZE-1:0] read_data_mem,
			output reg Comp,
			output reg ready,
			input [$clog2(ROB_ROWS)-1:0] in_robn, //ROB
			output reg [$clog2(ROB_ROWS)-1:0] out_robn,
			output reg is_sw
			);
			
	localparam  LW = 3'b101;
	localparam  SW = 3'b110;
			
	reg issue_d;
	
	initial
	begin
		is_sw = 0;
		RegWrite = 0;
		EnWrite = 0;
		issue_d = 0;
		Comp = 0;
		ready = 1;
	end
	
	wire [SIZE-1:0] mem_addr;
	assign out_robn = in_robn;
	//assign RegWrite = issue;
	
	assign mem_addr = read_data_reg[0] + imm;
	assign write_addr[0] = mem_addr;
	assign read_addr[0] = mem_addr;
	
	assign write_data_mem[0] = read_data_reg[1];
	assign write_data_reg[0] = read_data_mem[0];
	assign read_reg[0] = src_reg1;
	assign read_reg[1] = src_reg2;
	assign write_reg = dest_reg1;
			
	always @ (posedge clk) begin
		issue_d <= issue;
		case (ALUOp)
			LW: begin
				is_sw <= 0;
				
				if(issue) begin
					ready = 0;
					RegWrite <= 1;
				end
				else begin
				   RegWrite <= 0;
					ready = 1;
				end
				
				if(issue_d) begin
					EnWrite <= 0;
					Comp <= 1;
				end
				else begin
					EnWrite <= 0;
					Comp <= 0;
				end
			end
			SW: begin
				is_sw <= 1;
				if(issue) begin
					RegWrite <= 0;
					EnWrite <= 1;
					Comp <= 1;
					ready <= 1;
				end
				else begin
					RegWrite <= 0;
					EnWrite <= 0;
					Comp <= 0;
					ready <= 1;
				end
			end
			default: begin
				is_sw <= 1;
				if(issue) begin
					//$display("FU_MEM_test_read reg: ", src_reg1, " value: ", read_data_reg[0]);
					//RegWrite <= 0;
					EnWrite <= 0;
					Comp <= 1;
					ready <= 1;
				end
				else begin
					//RegWrite <= 0;
					EnWrite <= 0;
					Comp <= 0;
					ready <= 1;
				end
			end
		endcase
   end
	
endmodule