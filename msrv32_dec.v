



module msrv32_dec(
                  input [6:0] opcode_in,            
                  input funct7_5_in,               
                  input [2:0] funct3_in,            
                  input [1:0] iadder_1_to_0_in,     
                  input trap_taken_in,             
    
                  output [3:0] alu_opcode_out,      
                  output mem_wr_req_out,            
                  output [1:0] load_size_out,  
                  output load_unsigned_out,        
                  output alu_src_out,            
                  output iadder_src_out,     
                  output csr_wr_en_out,             
                  output rf_wr_en_out,              
                  output [2:0] wb_mux_sel_out,      
                  output [2:0] imm_type_out,        
                  output [2:0] csr_op_out,          
                  output illegal_instr_out,    
                  output misaligned_load_out,     
                  output misaligned_store_out       
                 );


   parameter  OPCODE_OP       =    5'b01100;
   parameter  OPCODE_OP_IMM   =    5'b00100;
   parameter  OPCODE_LOAD     =    5'b00000;
   parameter  OPCODE_STORE    =    5'b01000;
   parameter  OPCODE_BRANCH   =    5'b11000;
   parameter  OPCODE_JAL      =    5'b11011;
   parameter  OPCODE_JALR     =    5'b11001;
   parameter  OPCODE_LUI      =    5'b01101;
   parameter  OPCODE_AUIPC    =    5'b00101;
   parameter  OPCODE_MISC_MEM =    5'b00011;
   parameter  OPCODE_SYSTEM   =    5'b11100;


   parameter  FUNCT3_ADD      =    3'b000;
   parameter  FUNCT3_SUB      =    3'b000;
   parameter  FUNCT3_SLT      =    3'b010;
   parameter  FUNCT3_SLTU     =    3'b011;
   parameter  FUNCT3_AND      =    3'b111;
   parameter  FUNCT3_OR       =    3'b110;
   parameter  FUNCT3_XOR      =    3'b100;
   parameter  FUNCT3_SLL      =    3'b001;
   parameter  FUNCT3_SRL      =    3'b101;
   parameter  FUNCT3_SRA      =    3'b101;

   reg is_branch;
   reg is_jal;
   reg is_jalr;
   reg is_auipc;
   reg is_lui;
   reg is_load;
   reg is_store;
   reg is_system;
   wire is_csr;
   reg is_op;
   reg is_op_imm;
   reg is_misc_mem;
   reg is_addi;
   reg is_slti;
   reg is_sltiu;
   reg is_andi;
   reg is_ori;
   reg is_xori;
   wire is_implemented_instr;
   wire mal_word;
   wire mal_half;
   wire misaligned;
        

   always @*
   begin
      case(opcode_in [6:2])
         OPCODE_OP         : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b10000000000;
         OPCODE_OP_IMM     : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b01000000000;
         OPCODE_LOAD       : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00100000000;
         OPCODE_STORE      : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00010000000;
	 OPCODE_BRANCH     : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00001000000;
         OPCODE_JAL        : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000100000;
         OPCODE_JALR       : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000010000;
         OPCODE_LUI        : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000001000;
         OPCODE_AUIPC      : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000100;
         OPCODE_MISC_MEM   : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000010;
	 OPCODE_SYSTEM     : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000001;
	 default           : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000000;
      endcase
   end


   always @*
   begin
      case(funct3_in)
         FUNCT3_ADD       : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {is_op_imm, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
         FUNCT3_SLT       : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {1'b0, is_op_imm, 1'b0, 1'b0, 1'b0, 1'b0};    
         FUNCT3_SLTU      : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {1'b0, 1'b0, is_op_imm, 1'b0, 1'b0, 1'b0};
         FUNCT3_AND       : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {1'b0, 1'b0, 1'b0, is_op_imm, 1'b0, 1'b0};
         FUNCT3_OR        : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {1'b0, 1'b0, 1'b0, 1'b0, is_op_imm, 1'b0};                     
         FUNCT3_XOR       : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, is_op_imm};
	 default          : {is_addi,is_slti,is_sltiu,is_andi,is_ori,is_xori} = 6'b000000;
      endcase
   end


   assign load_size_out = funct3_in[1:0];
   assign load_unsigned_out = funct3_in[2];
    
   assign alu_src_out = opcode_in[5];
    
 
   assign is_csr = is_system & (funct3_in[2] | funct3_in[1] | funct3_in[0]); 
   assign csr_wr_en_out = is_csr;
   assign csr_op_out = funct3_in;
    
   assign iadder_src_out = is_load | is_store | is_jalr;
   assign rf_wr_en_out = is_lui | is_auipc | is_jalr | is_jal | is_op | is_load | is_csr | is_op_imm;//these operations require the register file
   assign alu_opcode_out[2:0] = funct3_in;
   assign alu_opcode_out[3] = funct7_5_in & ~(is_addi | is_slti | is_sltiu | is_andi | is_ori | is_xori);//select between identical funct3 operations
    

   assign wb_mux_sel_out[0] = is_load | is_auipc | is_jal | is_jalr;
   assign wb_mux_sel_out[1] = is_lui | is_auipc;
   assign wb_mux_sel_out[2] = is_csr | is_jal | is_jalr;


   assign imm_type_out[0] = is_op_imm | is_load | is_jalr | is_branch | is_jal;
   assign imm_type_out[1] = is_store | is_branch | is_csr;
   assign imm_type_out[2] = is_lui | is_auipc | is_jal | is_csr;

   assign is_implemented_instr = is_op | is_op_imm | is_branch | is_jal | is_jalr | is_auipc | is_lui | is_system | is_misc_mem | is_load | is_store;
    

   assign illegal_instr_out = ~opcode_in[1] | ~opcode_in[0] | ~is_implemented_instr;

 
   assign mal_word = funct3_in[1] & ~funct3_in[0] & (iadder_1_to_0_in[1] | iadder_1_to_0_in[0]);
   assign mal_half = ~funct3_in[1] & funct3_in[0] & iadder_1_to_0_in[0];
   assign misaligned = mal_word | mal_half;
   assign misaligned_store_out = is_store & misaligned;
   assign misaligned_load_out = is_load & misaligned;


   assign mem_wr_req_out = is_store & ~misaligned & ~trap_taken_in;
    
    
endmodule

