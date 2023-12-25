`timescale 1 ns / 1 ns 



module registers_tb(input in1, 
			output out,
				output reg [1:0][2:0] read_reg,
  output reg [1:0][31:0] read_data,
  output reg [0:0][2:0] write_reg,
  output reg [0:0][31:0] write_data,
  output reg clk
			);

  
  registers_wp1 regs1(.RegWrite(1), .clk(clk), .write_reg(write_reg), .write_data(write_data), .read_reg(read_reg), .read_data(read_data));
  
  initial begin
  clk = 1;
  write_reg = 0;
  write_data = 100;
  read_reg[0] = 0;
  read_reg[1] = 1;
  $display("readreg =  %d", read_reg[0]);
			#10
			read_reg[0] = 0;
			$display("readreg =  %d", read_reg[0]);
			$display("readreg1 =  %d", read_reg[1]);
			write_reg[0] = 0;
			write_data[0] = 111;
			$display("write0 =  %d", write_data[0]);
			$display("read0 =  %d", read_data[0]);
			$display("read1 =  %d", read_data[1]);
			#2
			write_reg[0] = 1;
			write_data[0] = 222;
			$display("write0 =  %d", write_data[0]);
			$display("read0 =  %d", read_data[0]);
			$display("read1 =  %d", read_data[1]);
			#2
			write_reg[0] = 0;
			write_data[0] = 888;
			$display("write0 =  %d", write_data[0]);
			$display("read0 =  %d", read_data[0]);
			$display("read1 =  %d", read_data[1]);
			#10
			$display("write0 =  %d", write_data[0]);
			$display("read0 =  %d", read_data[0]);
			$display("read1 =  %d", read_data[1]);
			read_reg[0] = 0;
			#2
			
			read_reg[0] = 0;
			
			
			

	end
	
	always #1 clk = ~clk;
	
endmodule