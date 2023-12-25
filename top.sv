`timescale 1ns/1ns

module stage1(clk, instr1_ren_in, instr2_ren_in, old_pd1, old_pd2, valid1, valid2, rt1valid, rt2valid, rt1reg, rt2reg,
			opcode1_ren_out, func3_1_ren_out, func7_1_ren_out, opcode2_ren_out, func3_2_ren_out, func7_2_ren_out,
			  PC1_ren_out, PC2_ren_out, pd_1_ren_out, ps2_1_ren_out, ps1_1_ren_out, pd_2_ren_out, ps1_2_ren_out, ps2_2_ren_out
);


	
	input clk;
	////////////////////////// registers initialization ////////////////////////////
	
	reg [31:0] instr1;
	reg [31:0] instr2;
	
	output reg valid1 = 0;
	output reg valid2 = 0;
	
	input rt1valid;
    input rt2valid;
    input [5:0] rt1reg;
    input [5:0] rt2reg;
	
	
	reg[7:0] PC1_dec_in;
	reg[7:0] PC2_dec_in;
	reg[7:0] PC1_dec_out;
	reg[7:0] PC2_dec_out;
	
	reg [6:0] opcode1_dec_out; 
	reg [4:0] rd_1_dec_out; 
	reg [2:0] func3_1_dec_out;
	reg [4:0] rs1_1_dec_out; 
	reg [4:0] rs2_1_dec_out; 
	reg [7:0] func7_1_dec_out;
	
	reg [6:0] opcode2_dec_out; 
	reg [4:0] rd_2_dec_out; 
	reg [2:0] func3_2_dec_out;
	reg [4:0] rs1_2_dec_out; 
	reg [4:0] rs2_2_dec_out; 
	reg [7:0] func7_2_dec_out;
	
	//rename registers
	
	reg[7:0] PC1_ren_in;
	reg[7:0] PC2_ren_in;
	output reg[7:0] PC1_ren_out;
	output reg[7:0] PC2_ren_out;
	
	reg [6:0] opcode1_ren_in; 
	reg [4:0] rd_1_ren_in; 
	reg [2:0] func3_1_ren_in;
	reg [4:0] rs1_1_ren_in; 
	reg [4:0] rs2_1_ren_in; 
	reg [7:0] func7_1_ren_in;
	
	output reg [6:0] opcode1_ren_out; 
	output reg [5:0] pd_1_ren_out; 
	output reg [2:0] func3_1_ren_out;
	output reg [5:0] ps1_1_ren_out; 
	output reg [5:0] ps2_1_ren_out; 
	output reg [7:0] func7_1_ren_out;
	
	reg [6:0] opcode2_ren_in; 
	reg [4:0] rd_2_ren_in; 
	reg [2:0] func3_2_ren_in;
	reg [4:0] rs1_2_ren_in; 
	reg [4:0] rs2_2_ren_in; 
	reg [7:0] func7_2_ren_in;
	
	output reg [6:0] opcode2_ren_out; 
	output reg [5:0] pd_2_ren_out; 
	output reg [2:0] func3_2_ren_out;
	output reg [5:0] ps1_2_ren_out; 
	output reg [5:0] ps2_2_ren_out; 
	output reg [7:0] func7_2_ren_out;
	
	output reg [31:0] instr1_ren_in;
	output reg [31:0] instr2_ren_in;
	reg [31:0] instr1_ren_out;
	reg [31:0] instr2_ren_out;
	
	output reg [5:0] old_pd1;
	output reg [5:0] old_pd2;
	
	reg [7:0] instruction_mem[127:0];
	reg [5:0] rat [31:0];
	

	
	integer PC = 0;
	integer start = 0;
	reg [15:0] total_count;
	
		// module initialization

	decode dec(
	PC1_dec_in, PC2_dec_in, PC1_dec_out, PC2_dec_out, start,
	instr1, opcode1_dec_out, rd_1_dec_out, func3_1_dec_out, rs1_1_dec_out, rs2_1_dec_out, func7_1_dec_out, 
	instr2, opcode2_dec_out, rd_2_dec_out, func3_2_dec_out, rs1_2_dec_out, rs2_2_dec_out, func7_2_dec_out
	);
	
rename ren( rat, start,
                PC1_ren_in, PC2_ren_in, PC1_ren_out, PC2_ren_out, old_pd1, old_pd2, rt1valid, rt2valid, rt1reg, rt2reg,
					instr1_ren_in, opcode1_ren_in, rd_1_ren_in, func3_1_ren_in, rs1_1_ren_in, rs2_1_ren_in, func7_1_ren_in, 
					instr1_ren_out, opcode1_ren_out, pd_1_ren_out, func3_1_ren_out, ps1_1_ren_out, ps2_1_ren_out, func7_1_ren_out,
					instr2_ren_in, opcode2_ren_in, rd_2_ren_in, func3_2_ren_in, rs1_2_ren_in, rs2_2_ren_in, func7_2_ren_in, 
					instr2_ren_out, opcode2_ren_out, pd_2_ren_out, func3_2_ren_out, ps1_2_ren_out, ps2_2_ren_out, func7_2_ren_out
	);
	
	
	//fetch stage
	initial begin
		for(integer n = 0; n < 128; n = n + 1) begin
				instruction_mem[n] = 0;
		end
		$readmemh("C:/Users/Benji/Desktop/evaluation-hex.txt", instruction_mem);
		//r-test-hex
		//evaluation-hex
		total_count = 0;
		start = 1;
	end

	
	always @ (posedge clk) begin
		if(start) begin 
		
			instr1 <= {instruction_mem[PC], instruction_mem[PC+1], instruction_mem[PC+2], instruction_mem[PC +3]};
			instr2 <= {instruction_mem[PC+4], instruction_mem[PC+5], instruction_mem[PC+6], instruction_mem[PC +7]};
				if(instr1 != 0) begin 
					total_count = total_count + 1;
				end
				if(instr2 != 0) begin
					total_count = total_count + 1;
				end
			
			PC1_dec_in <= PC;
			PC2_dec_in <= PC + 4;
			
			PC = PC + 8;
			
			
			 if(instr1 != 0) begin 
				valid1 <= 1;
			end else begin
				valid1 <= 0;
			end
			
			if(instr2 != 0) begin 
				valid2 <= 1;
			end else begin
				valid2 <= 0;
			end
			
			$display("Instruction 1: %h", instr1);
			$display("Instruction 2: %h", instr2);
			if(valid1)
				$display("instruction1 valid");
			if(valid2)
				$display("instruction2 valid");
			
			//$display("Instruction Count: %d", total_count);
		
		end
	end
	
	// rename & decode pipeline buffer
	always @ (posedge clk) begin
		PC1_ren_in <= PC1_dec_out;
		PC2_ren_in <= PC2_dec_out;
		
		opcode1_ren_in <= opcode1_dec_out;
		rd_1_ren_in <= rd_1_dec_out;
		func3_1_ren_in <= func3_1_dec_out;
		rs1_1_ren_in <= rs1_1_dec_out;
		rs2_1_ren_in <= rs2_1_dec_out;
		func7_1_ren_in <= func7_1_dec_out;
		
		opcode2_ren_in <= opcode2_dec_out;
		rd_2_ren_in <= rd_2_dec_out;
		func3_2_ren_in <= func3_2_dec_out;
		rs1_2_ren_in <= rs1_2_dec_out;
		rs2_2_ren_in <= rs2_2_dec_out;
		func7_2_ren_in <= func7_2_dec_out;
		
		instr1_ren_in <= instr1;
		instr2_ren_in <= instr2;	
	end

endmodule