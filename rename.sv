module rename(	rat, start,
					PC1, PC2, PC1_o, PC2_o, old_pd1, old_pd2, retire1f, retire2f, retire1reg, retire2reg, 
					instr1, opcode1, rd_1, func3_1, rs1_1, rs2_1, func7_1, 
					instr1_o, opcode1_o, pd_1, func3_1_o, ps1_1, ps2_1, func7_1_o,
					instr2, opcode2, rd_2, func3_2, rs1_2, rs2_2, func7_2,
					instr2_o, opcode2_o, pd_2, func3_2_o, ps1_2, ps2_2, func7_2_o
);

	output reg [5:0] rat [31:0];
	
	
	reg freepool[63:0];
	integer found;
	input start;
	
	input retire1f;
	input retire2f;
	input [5:0] retire1reg;
	input [5:0] retire2reg;
	
	input [7:0] PC1;
	input [7:0] PC2;
	
	output reg [7:0] PC1_o;
	output reg [7:0] PC2_o;
	
	input [31:0] instr1;
	input [6:0] opcode1; 
	input [4:0] rd_1; 
	input [2:0] func3_1;
	input [4:0] rs1_1; 
	input [4:0] rs2_1; 
	input [7:0] func7_1;
	
	output reg [31:0] instr1_o;
	output reg [6:0] opcode1_o; 
	output reg [5:0] pd_1; 
	output reg [2:0] func3_1_o;
	output reg [5:0] ps1_1; 
	output reg [5:0] ps2_1; 
	output reg [7:0] func7_1_o;
	
	input [31:0] instr2;
	input [6:0] opcode2; 
	input [4:0] rd_2; 
	input [2:0] func3_2;
	input [4:0] rs1_2; 
	input [4:0] rs2_2; 
	input [7:0] func7_2;
	
	output reg [31:0] instr2_o;
	output reg [6:0] opcode2_o; 
	output reg [5:0] pd_2; 
	output reg [2:0] func3_2_o;
	output reg [5:0] ps1_2; 
	output reg [5:0] ps2_2; 
	output reg [7:0] func7_2_o;
	
	
	output reg [5:0] old_pd1;
	output reg [5:0] old_pd2;
	
	
	initial begin
		for (integer n = 0; n < 32; n = n + 1) begin
				freepool[n] = 1;
		end
		for (integer n = 32; n < 64; n = n + 1) begin
				freepool[n] = 0;
		end
		for(integer n = 0; n < 32; n = n + 1) begin
			rat[n] = n;
		end 
	end
	
	always @ (*) begin

	
		if(start) begin 
			// add in retire signals after retire stage is complete
	if(retire1f == 1) begin 
			freepool[retire1reg] = 1;
		end else if (retire2f == 1) begin
			freepool[retire2reg] = 1;
		end
		
	ps1_1 = rat[rs1_1];
	// for each dest reg find a free from free pool and assign it
	found = 0;
		for (integer n = 0; n < 64; n = n + 1) begin
				if(freepool[n] ==0 && found == 0) begin
					found = 1;
					if(rd_1 != 0) begin
						old_pd1 = rat[rd_1];
						rat[rd_1] = n;
						freepool[n] = 1;
						pd_1 = n;
					end else begin
						old_pd1 = 0;
						pd_1 = 0;
					end
					//$display("renaming dest reg%d to p%d", rd_1, pd_1);
				end 
		end
	// for each source, access find and find preg 
	ps2_1 = rat[rs2_1];
	//$display("renaming source reg1 %d to p%d", rs1_1, ps1_1);
	//$display("renaming source reg2 %d to p%d", rs2_1, ps2_1);

		opcode1_o = opcode1;
		func3_1_o = func3_1;
		func7_1_o = func7_1;
		instr1_o = instr1;
		//second
		found = 0;
		for (integer n = 0; n < 64; n = n + 1) begin
				if(freepool[n] ==0 && found == 0) begin
					found = 1;
					if(rd_2 != 0) begin
						old_pd2 = rat[rd_2];
						rat[rd_2] = n;
						freepool[n] = 1;
						pd_2 = n;
					end else begin
						old_pd2 = 0;
						pd_2 = 0;
					end
					//$display("renaming dest reg %d to p%d", rd_2, pd_2);
				end
		end
		
		// for second iunstruction
		
				// for each source, access find and find preg 
		ps1_2 = rat[rs1_2];
		ps2_2 = rat[rs2_2];
		//$display("renaming source reg1 %d to p%d", rs1_2, ps1_2);
		//$display("renaming source reg2 %d to p%d", rs2_2, ps2_2);
	
		opcode2_o = opcode2;
		func3_2_o = func3_2;
		func7_2_o = func7_2;
		instr2_o = instr2;
		
		PC1_o <= PC1;
		PC2_o <= PC2;
							
		end
	
	end
	

endmodule
