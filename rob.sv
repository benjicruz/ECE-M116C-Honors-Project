`timescale 1 ns / 1 ns 

module rob_module #(
			parameter SIZE = 32,
			parameter REG_NUM = 64,
			parameter READ_PORTS = 6,
			parameter WRITE_PORTS = 3,
			parameter ROB_ROWS = 16,
			parameter MEM_ROWS = 64,
			parameter PC_WIDTH = 10,
			parameter ROWS_TO_ADD = 2,
			ALU_NUM = 3,
			parameter ROWS_TO_RETIRE = 2
			
			)
			(
			input clk,
			input [WRITE_PORTS-1:0] RegWrite, //Registers IO
			input [WRITE_PORTS-1:0][$clog2(REG_NUM)-1:0] write_reg,
			input [WRITE_PORTS-1:0][SIZE-1:0] write_data,
			input [READ_PORTS-1:0][$clog2(REG_NUM)-1:0] read_reg,
			output [READ_PORTS-1:0][SIZE-1:0] read_data,
			
			input [ALU_NUM-1:0][$clog2(ROB_ROWS)-1:0] station_robn,
			input [ALU_NUM-1:0] station_is_sw,
			
			input [ROWS_TO_ADD-1:0] add_valid, //adding rows
			input [ROWS_TO_ADD-1:0][$clog2(REG_NUM)-1:0] add_old_dest_reg,
			input [ROWS_TO_ADD-1:0][PC_WIDTH-1:0] add_pc,
			output [ROWS_TO_ADD-1:0][$clog2(ROB_ROWS)-1:0] added_robn,
			
			output reg [ROWS_TO_RETIRE-1:0][$clog2(REG_NUM)-1:0] reg_to_retire, //retiring
			output reg [ROWS_TO_RETIRE-1:0] retire_signals,
			
			input [0:0] EnWrite, // Memory IO
			input [0:0][$clog2(MEM_ROWS)-1:0] write_addr,
			input [0:0][SIZE-1:0] write_data_mem,
			input [0:0][$clog2(MEM_ROWS)-1:0] read_addr,
			output [0:0][SIZE-1:0] read_data_mem
			
			);
			
			reg [ROB_ROWS-1:0] rob_valid;
			reg [ROB_ROWS-1:0] rob_complete;
			reg [ROB_ROWS-1:0][$clog2(REG_NUM)-1:0] rob_dest_reg;
			reg [ROB_ROWS-1:0][$clog2(REG_NUM)-1:0] rob_old_dest_reg;
			reg [ROB_ROWS-1:0] rob_dest_reg_val_valid;
			reg [ROB_ROWS-1:0][SIZE-1:0] rob_dest_reg_val;
			reg [ROB_ROWS-1:0] rob_is_sw;
			reg [ROB_ROWS-1:0][$clog2(MEM_ROWS)-1:0] rob_store_addr;
			reg [ROB_ROWS-1:0][SIZE-1:0] rob_store_data;
			reg [ROB_ROWS-1:0][PC_WIDTH-1:0] rob_pc;
			reg [READ_PORTS-1:0][ROB_ROWS-1:0] rob_forward_ready;
			reg [ROB_ROWS-1:0] rob_retire_ready;
			reg [ROB_ROWS-1:0] rob_complete_d;
			
				reg [WRITE_PORTS-1:0] RegWrite_reg;
				reg [READ_PORTS-1:0][SIZE-1:0] read_data_reg;
				reg [WRITE_PORTS-1:0][SIZE-1:0] write_data_reg;
				reg [WRITE_PORTS-1:0][$clog2(REG_NUM)-1:0] write_reg_reg;
				
				initial  begin
					RegWrite_reg = 0;
					write_data_reg = 0;
					write_reg_reg = 0;
				end
	
	//mark ready for forwarding (rob_valid[i] && rob_dest_reg_val_valid[i] && )
	generate genvar i;
	for(i=0; i<ROB_ROWS; i=i+1) begin: gen_block3
		//for(integer i=0; i<ROB_ROWS; i=i+1) begin: gen_block4
			assign rob_forward_ready[0][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[0]);
			assign rob_forward_ready[1][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[1]);
			assign rob_forward_ready[2][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[2]);
			assign rob_forward_ready[3][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[3]);
			assign rob_forward_ready[4][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[4]);
			assign rob_forward_ready[5][i] = rob_valid[i] && rob_dest_reg_val_valid[i] && (rob_dest_reg[i] == read_reg[5]);
		//end
	end
	endgenerate
	
	reg [READ_PORTS-1:0][$clog2(ROB_ROWS):0] rob_forward_row;
	
	//forwarding selector
	generate genvar j;
      for(j=0; j<READ_PORTS; j=j+1) begin: gen_block2
			find_max_cond #(.SIZE(ROB_ROWS), .VAL_WIDTH(PC_WIDTH)) arg_max1(.in_cond(rob_forward_ready[j]), .in_max(rob_pc), .first_index1(rob_forward_row[j]));
		end
	endgenerate
	
	//this modules finds first 2 available spots in table
  
  find_index #(.SIZE(ROB_ROWS)) find_index0(.in(rob_valid), .first0(added_robn[0]), .second0(added_robn[1]));
  
    //mark ready for retiring

	
	generate genvar ii;
	for(ii=0; ii<ROB_ROWS; ii=ii+1) begin: gen_block6
			assign rob_retire_ready[ii] = rob_valid[ii] && rob_complete[ii];
	end
	endgenerate
	
  //this modules finds first 2 rows to delete from ROB
  reg [ROWS_TO_RETIRE-1:0][$clog2(ROB_ROWS):0] rob_retire_row;
  
  find_index #(.SIZE(ROB_ROWS)) find_index2(.in(rob_retire_ready), .first0(rob_retire_row[0]), .second0(rob_retire_row[1]));
	
  
  always @ (posedge clk) begin
		rob_complete <= rob_complete_d;
  		//retiring rows from ROB
		for(integer c=0; c<1; c=c+1) begin
			if(rob_retire_row[c] != 31) begin
				rob_valid[rob_retire_row[c]] <= 0;
				rob_complete[rob_retire_row[c]] <= 0;
				
				if(rob_dest_reg_val_valid[rob_retire_row[c]] == 1) begin
					RegWrite_reg[c] <= 1;
					write_data_reg[c] <= rob_dest_reg[rob_retire_row[c]];
					write_reg_reg[c] <= rob_dest_reg_val[rob_retire_row[c]];
				end
				//rob_dest_reg_val_valid[rob_retire_row[c]] <= 0;
				
			end
			else begin
				RegWrite_reg[c] <= 0;
			end
		end
  
    //adding rows to ROB
		for(integer g=0; g<2; g=g+1) begin
			if(add_valid[g] == 1'b1 && added_robn[g] != 31) begin 
				rob_valid[added_robn[g]] <= 1;
				rob_old_dest_reg[added_robn[g]] <= add_old_dest_reg[g];
				rob_pc[added_robn[g]] <= add_pc[g];
			end
		end
	
  end
		
  initial
  begin
		rob_is_sw = 0;
	  rob_valid = 0;
	  rob_dest_reg_val = 0;
	  rob_dest_reg_val_valid = 0;
	  rob_dest_reg = 0;
	  rob_pc = 0;
	  RegWrite_reg = 0;
	  rob_complete = 0;
	  rob_complete_d = 0;
	  
  end
  
  //updating rows of ROB
  always @ (posedge clk) begin
  
		//$display("%b ",rob_forward_row[0]);
		//$display("%b",rob_forward_test);
		for(integer c=0; c<ALU_NUM; c=c+1) begin
			if(RegWrite[c]) begin
			   //$display("update_val_rob ", station_robn[c], " ,reg: ",write_reg[c], " ,val: ", write_data[c]);
				rob_dest_reg_val_valid[station_robn[c]] <= ~station_is_sw[c];
				rob_dest_reg[station_robn[c]] <= write_reg[c];
				rob_dest_reg_val[station_robn[c]] <= write_data[c];
				rob_is_sw[station_robn[c]] <= station_is_sw[c];
				rob_complete_d[station_robn[c]] <= 1;
				end
			
		end
		
  end
  
  //forwarding unit
  /*generate genvar g;
	for(g=0; g<READ_PORTS; g=g+1) begin: gen_block5 //hardcoded as (ROB_ROWS bits) + 1
		assign read_data[g] = (rob_forward_row[g] == 31) ? read_data_reg[g] : rob_dest_reg_val[rob_forward_row[g]];
	end
  endgenerate*/
  
  
  //Registers
  registers_wp3 #(.READ_PORTS(6)) regs_rob(.clk(clk), 
  .RegWrite(RegWrite), 
  .write_reg(write_reg), 
  .write_data(write_data), 
  .read_reg(read_reg), 
  .read_data(read_data));
 
  
  //Memory
  Memory mem(.EnWrite(EnWrite), .clk(clk), .write_addr(write_addr), .write_data(write_data_mem),
  .read_addr(read_addr), .read_data(read_data_mem));

	
endmodule