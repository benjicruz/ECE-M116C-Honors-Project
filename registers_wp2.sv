`timescale 1 ns / 1 ns 

module registers_wp2 #(
			parameter SIZE = 32,
			parameter REG_NUM = 8,
			parameter READ_PORTS = 2,
			parameter WRITE_PORTS = 2
			)
			(
			input clk,
			input [WRITE_PORTS-1:0] RegWrite,
			input [WRITE_PORTS-1:0][$clog2(REG_NUM)-1:0] write_reg,
			input [WRITE_PORTS-1:0][SIZE-1:0] write_data,
			input [READ_PORTS-1:0][$clog2(REG_NUM)-1:0] read_reg,
			output reg [READ_PORTS-1:0][SIZE-1:0] read_data
			);
	
	reg [REG_NUM-1:0][SIZE-1:0] regs;
	
	initial
	begin
		regs = 0;
		read_data = 0;
	end
	
	//genvar c;
	//generate
	//	for (c = 0; c < WRITE_PORTS; c = c + 1) begin : gen_block1	
	//		always @ (negedge clk) begin
	//			if(RegWrite[c]) regs[write_reg[c]] = write_data[c];
	//		end
	//	end
	//endgenerate
	
	always @ (negedge clk) begin
				if(RegWrite[0]) regs[write_reg[0]] = write_data[0];
				if(RegWrite[1]) regs[write_reg[1]] = write_data[1];
	end
	
	genvar i;
	generate
		for (i = 0; i < READ_PORTS; i = i + 1) begin : gen_block2	
				always @ (posedge clk) begin //posedge and negedge may be swapped
					read_data[i] = regs[read_reg[i]];
				end
		end
	endgenerate
	
endmodule