`timescale 1 ns / 1 ns 



module Memory_tb(input in1, 
			output out,
				output reg [0:0][5:0] read_addr,
  output reg [0:0][31:0] read_data,
  output reg [0:0][5:0] write_addr,
  output reg [0:0][31:0] write_data,
  output reg clk
			);

  
  Memory mem(.EnWrite(1), .clk(clk), .write_addr(write_addr), .write_data(write_data), .read_addr(read_addr), .read_data(read_data));
  
  
  initial begin
  clk = 1;
  write_addr[0] = 0;
  write_data[0] = 'h11110011;
  read_addr[0] = 0;
  #1
  $display("read_data =  %h", read_data[0]);
	#2
	$display("read_data =  %h", read_data[0]);
	#2
	$display("read_data =  %h", read_data[0]);
	write_data[0] = 'h11111100;
	#2
	$display("read_data =  %h", read_data[0]);
			
			
			

	end
	
	
	always #1 clk = ~clk;
	
endmodule