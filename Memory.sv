`timescale 1 ns / 1 ns 

module Memory #(
			parameter IO_SIZE = 32,
			parameter INNER_SIZE = 8,
			parameter ROWS = 64,
			parameter READ_PORTS = 1,
			parameter WRITE_PORTS = 1
			)
			(
			input clk,
			input [WRITE_PORTS-1:0] EnWrite,
			input [WRITE_PORTS-1:0][$clog2(ROWS)-1:0] write_addr,
			input [WRITE_PORTS-1:0][IO_SIZE-1:0] write_data,
			input [READ_PORTS-1:0][$clog2(ROWS)-1:0] read_addr,
			output reg [READ_PORTS-1:0][IO_SIZE-1:0] read_data
			);
	
	reg [ROWS-1:0][IO_SIZE-1:0] mem;
	
	initial
	begin
		mem = 0;
	end
	
	genvar c;
	generate
		for (c = 0; c < WRITE_PORTS; c = c + 1) begin : gen_block1	
			always @ (negedge clk) begin
				if(EnWrite[c])
					mem[write_addr[c]] = write_data[c];
			end
		end
	endgenerate
	
	genvar i;
	generate
		for (i = 0; i < READ_PORTS; i = i + 1) begin : gen_block2	
				always @ (posedge clk) begin //posedge and negedge may be swapped
					read_data[i] = mem[read_addr[i]];//{mem[read_addr[i]],mem[read_addr[i]+1],mem[read_addr[i]+2],mem[read_addr[i]+3]};
				end
		end
	endgenerate
	
endmodule