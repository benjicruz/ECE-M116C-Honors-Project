`timescale 1 ns / 1 ns 



module ALU_tb(input in1, 
			output out
			);

  reg [31:0] a = 2;
  reg [31:0] b = 1;
  reg clk = 0;
  reg [31:0] c = 0;
  reg [2:0] ALUOp = 0;
  
  ALU ALU_1(.ALUOp(ALUOp), .in1(a), .in2(b), .out(c));
  
  initial begin
			#10
			ALUOp = 1;
			#1
			$display("a =  %d", a);
			$display("b =  %d", b);
			$display("c =  %d", c);
			
			#10
			$display("a =  %d", a);
			$display("b =  %d", b);
			$display("c =  %d", c);
			ALUOp = 2;
			#10
			$display("a =  %d", a);
			$display("b =  %d", b);
			$display("c =  %d", c);
			ALUOp = 3;
			#10
			$display("a =  %d", a);
			$display("b =  %d", b);
			$display("c =  %d", c);
			ALUOp = 4;
			#10
			$display("a =  %d", a);
			$display("b =  %d", b);
			$display("c =  %d", c);

	end
	
	always #1 clk = ~clk;
	
endmodule