`timescale 1 ns / 1 ns 


module reg_station #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter ALUOP_BITS = 3,
			parameter INPUT_ROWS = 2,
			parameter STORED_ROWS = 16,
			parameter ROB_ROWS = 16,
			MEM_ROWS = 64,
			ALU_NUM = 3
			)
			(
			input clk,
			input [INPUT_ROWS-1:0][ALUOP_BITS-1:0] new_ALUOp, //instruction IO
			input [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg1,
			input [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_src_reg2,
			input [INPUT_ROWS-1:0] new_use_imm,
			input [INPUT_ROWS-1:0][SIZE-1:0] new_imm,
			input [INPUT_ROWS-1:0][$clog2(REG_NUM)-1:0] new_dest_reg1,
			input [INPUT_ROWS-1:0] new_valid,
			input [INPUT_ROWS-1:0][$clog2(ROB_ROWS)-1:0] new_robn, /// ROB
			output reg [2:0] Comp,
			output reg [ALU_NUM-1:0][$clog2(REG_NUM)-1:0] write_reg, ////FUs - regs IO
			output reg [ALU_NUM-1:0][SIZE-1:0] write_data,
			output reg [2*ALU_NUM-1:0][$clog2(REG_NUM)-1:0] read_reg,
			input [2*ALU_NUM-1:0][SIZE-1:0] read_data,
			output [ALU_NUM-1:0] RegWrite,
			output [ALU_NUM-1:0][$clog2(ROB_ROWS)-1:0] out_robn, //ROB
			output [ALU_NUM-1:0] is_sw,
			
			output reg [0:0] EnWrite, // Memory IO
			output reg [0:0][$clog2(MEM_ROWS)-1:0] write_addr,
			output reg [0:0][SIZE-1:0] write_data_mem,
			output reg [0:0][$clog2(MEM_ROWS)-1:0] read_addr,
			input [0:0][SIZE-1:0] read_data_mem
			

			);
			
			localparam  ADD = 3'b000;
			localparam  SUB = 3'b001;
			localparam  AND = 3'b010;
			localparam  XOR = 3'b011;
			localparam  SRA = 3'b100;
			localparam  LW = 3'b101;
			localparam  SW = 3'b110;
			 
			 //trackers
			 reg [ALU_NUM-1:0] fu_ready;
			 
			 reg [ALU_NUM-1:0][ALUOP_BITS-1:0] ALUOp; //FUs IO
			 reg [ALU_NUM-1:0][$clog2(REG_NUM)-1:0] src_reg1;
			 reg [ALU_NUM-1:0][$clog2(REG_NUM)-1:0] src_reg2;
			 reg [ALU_NUM-1:0] use_imm;
			 reg [ALU_NUM-1:0][SIZE-1:0] imm;
			 reg [ALU_NUM-1:0][$clog2(REG_NUM)-1:0] dest_reg1;
			 reg [ALU_NUM-1:0] issue;
			 reg [ALU_NUM-1:0][$clog2(ROB_ROWS)-1:0] fu_robn;
			 
			 //instructions table
			 reg [STORED_ROWS-1:0] table_use;
			 reg [STORED_ROWS-1:0][ALUOP_BITS-1:0] table_OP;
			 reg [STORED_ROWS-1:0][$clog2(REG_NUM)-1:0] table_dest_reg1;
			 reg [STORED_ROWS-1:0][$clog2(REG_NUM)-1:0] table_src_reg1;
			 reg [STORED_ROWS-1:0] table_src_ready1;
			 reg [STORED_ROWS-1:0][$clog2(REG_NUM)-1:0] table_src_reg2;
			 reg [STORED_ROWS-1:0] table_src_ready2;
			 reg [STORED_ROWS-1:0] table_use_imm;
			 reg [STORED_ROWS-1:0][SIZE-1:0] table_imm;
			 reg [STORED_ROWS-1:0][1:0] table_fu;
			 reg [STORED_ROWS-1:0][$clog2(ROB_ROWS)-1:0] table_robn;
			 reg [ALU_NUM-1:0][STORED_ROWS-1:0] issue_cond_inv; //0 is ready for issue, 1 is not ready
			 
			 reg [REG_NUM-1:0] regs_ready;
			 
			 reg last_assigned_fu_alu; //this is for assigning either FU 0 or 1

			 
generate genvar i;
    for(i=0; i<STORED_ROWS; i=i+1) begin: gen_block1	
		  assign issue_cond_inv[0][i] = ~(table_use[i] && ((regs_ready[table_src_reg1[i]] && regs_ready[table_src_reg2[i]]) || (table_src_reg1[i] == table_dest_reg1[i])) && table_fu[i] == 0); 
        assign issue_cond_inv[1][i] = ~(table_use[i] && ((regs_ready[table_src_reg1[i]] && regs_ready[table_src_reg2[i]]) || (table_src_reg1[i] == table_dest_reg1[i])) && table_fu[i] == 1); 
		  assign issue_cond_inv[2][i] = ~(table_use[i] && ((regs_ready[table_src_reg1[i]] && regs_ready[table_src_reg2[i]]) || (table_src_reg1[i] == table_dest_reg1[i])) && table_fu[i] == 2); 
	 end
endgenerate	 	
			
	initial
	begin
	
		table_use = 0;
		fu_ready = 3'b111;
		table_src_ready1 = -1;
		table_src_ready2 = -1;
		table_fu = 0;
		
		regs_ready = -1;
		
		ALUOp = 0; 
		src_reg1 = 0;
		src_reg2 = 0;
		use_imm = 0;
		imm = 0;
		dest_reg1 = 0;
		issue = 0;
		
		last_assigned_fu_alu = 1;
	end
			
//Functional units
  FU_ALU FU_0(.clk(clk), .ALUOp(ALUOp[0]), .src_reg1(src_reg1[0]), .src_reg2(src_reg2[0]), 
  .use_imm(use_imm[0]), .imm(imm[0]), .dest_reg1(dest_reg1[0]), .issue(issue[0]), 
  .write_reg(write_reg[0]), .write_data(write_data[0]), .read_reg(read_reg[1:0]), 
  .read_data(read_data[1:0]), .RegWrite(RegWrite[0]), .Comp(Comp[0]), .in_robn(fu_robn[0]), .out_robn(out_robn[0]), .is_sw(is_sw[0]));
  
   FU_ALU FU_1(.clk(clk), .ALUOp(ALUOp[1]), .src_reg1(src_reg1[1]), .src_reg2(src_reg2[1]), 
  .use_imm(use_imm[1]), .imm(imm[1]), .dest_reg1(dest_reg1[1]), .issue(issue[1]), 
  .write_reg(write_reg[1]), .write_data(write_data[1]), .read_reg(read_reg[3:2]), 
  .read_data(read_data[3:2]), .RegWrite(RegWrite[1]), .Comp(Comp[1]), .in_robn(fu_robn[1]), .out_robn(out_robn[1]), .is_sw(is_sw[1]));
  
  FU_MEM FU_2(.clk(clk), .ALUOp(ALUOp[2]), .src_reg1(src_reg1[2]), .src_reg2(src_reg2[2]),
  .use_imm(use_imm[2]), .imm(imm[2]), .dest_reg1(dest_reg1[2]), .issue(issue[2]), 
  .write_reg(write_reg[2]), .write_data_reg(write_data[2]), .read_reg(read_reg[5:4]),
  .read_data_reg(read_data[5:4]), .RegWrite(RegWrite[2]), .Comp(Comp[2]), .in_robn(fu_robn[2]), .out_robn(out_robn[2]), .is_sw(is_sw[2]),
  .write_addr(write_addr), .write_data_mem(write_data_mem), 
  .read_addr(read_addr), .read_data_mem(read_data_mem), .EnWrite(EnWrite));
  
  
  //this modules finds first 2 available spots in table
  reg [1:0][$clog2(STORED_ROWS):0] free_spots;
  
  find_index #(.SIZE(STORED_ROWS)) find_index0(.in(table_use), .first0(free_spots[0]), .second0(free_spots[1]));
  
  //this modules find first slot ready for all FUs one by one
  reg [ALU_NUM-1:0][$clog2(STORED_ROWS):0] fu_ready_slot;
  
  reg [$clog2(REG_NUM)-1:0] delay_reg = 0;
		reg delay_mark = 0;
  
  generate genvar j;
    for(j=0; j<ALU_NUM; j=j+1) begin: gen_block2
			find_index #(.SIZE(STORED_ROWS)) find_index1(.in(issue_cond_inv[j]), .first0(fu_ready_slot[j]));
		end
	endgenerate
  
  //dispatch block
		always @ (posedge clk) begin
		for(integer g=0; g<2; g=g+1) begin
			if(new_valid[g] == 1'b1 && free_spots[g] != 31) begin 
				 //$display("added",free_spots[g]);
				 
				 table_use[free_spots[g]] <= 1;
				 
				 table_OP[free_spots[g]] <= new_ALUOp[g];
				 table_dest_reg1[free_spots[g]] <= new_dest_reg1[g];
				 table_src_reg1[free_spots[g]] <= new_src_reg1[g];
				 table_src_reg2[free_spots[g]] <= new_src_reg2[g];
				 table_use_imm[free_spots[g]] <= new_use_imm[g];
				 table_imm[free_spots[g]] <= new_imm[g];
				 table_robn[free_spots[g]] <= new_robn[g];
				 
				 regs_ready[new_dest_reg1[g]] <= 0;
				 regs_ready[0] <= 1;
				 
				
				//preassigning fu_alu
				 if(new_ALUOp[g] == ADD || new_ALUOp[g] == SUB || new_ALUOp[g] == AND || new_ALUOp[g] == XOR || new_ALUOp[g] == SRA) begin
					if(last_assigned_fu_alu) table_fu[free_spots[g]] <= 1;
					else table_fu[free_spots[g]] <= 0;
					last_assigned_fu_alu = ~last_assigned_fu_alu;
				 end
				 else table_fu[free_spots[g]] <= 2;
				 
			 end
					  
		end
		
		if(delay_mark) begin
		  regs_ready[delay_reg] <= 1;
			delay_mark <= 0;
		end
		
	
	//issue block
		for(integer c=0; c<ALU_NUM; c=c+1) begin
			
				  if(fu_ready_slot[c] != 31 && fu_ready[c]) begin // 31 is hardcoded
						//$display("issue ", c, " ",fu_ready_slot[c]);
						
						table_use[fu_ready_slot[c]] <= 0;
						
						ALUOp[c] <= table_OP[fu_ready_slot[c]]; 
						src_reg1[c] <= table_src_reg1[fu_ready_slot[c]];
						src_reg2[c] <= table_src_reg2[fu_ready_slot[c]];
						use_imm[c] <= table_use_imm[fu_ready_slot[c]];
						imm[c] <= table_imm[fu_ready_slot[c]];
						dest_reg1[c] <= table_dest_reg1[fu_ready_slot[c]];
						fu_robn[c] <=  table_robn[fu_ready_slot[c]];
						
						regs_ready[table_dest_reg1[fu_ready_slot[c]]] <= 1;
						 
						//delay for LW:
				      if((table_OP[fu_ready_slot[c]] == LW) || (table_OP[fu_ready_slot[c]] == SW))begin
							fu_ready[c] <= 0;
							delay_reg = table_dest_reg1[fu_ready_slot[c]];
							delay_mark <= 1;
						end
						else begin
							regs_ready[table_dest_reg1[fu_ready_slot[c]]] <= 1;
						end
						
						issue[c] <= 1;
						
				  end
				  else begin
						issue[c] <= 0;
						fu_ready[c] <= 1;
				  end

	   end
		end


endmodule