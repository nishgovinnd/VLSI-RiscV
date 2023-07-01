module msrv32_bu(
                 input  [6:2] opcode_6_to_2_in,
                 input  [2:0] funct3_in,       
                 input  [31:0] rs1_in,rs2_in,         
                 output branch_taken_out      
                );    

   parameter  OPCODE_BRANCH   =    5'b11000;
   parameter  OPCODE_JAL      =    5'b11011;
   parameter  OPCODE_JALR     =    5'b11001;

    
   wire pc_mux_sel;
   wire pc_mux_sel_en; 
   reg is_branch;     
   reg is_jal;       
   reg is_jalr;        
   wire is_jump;       
   reg take;           

   assign is_jump = is_jal | is_jalr; 
   assign pc_mux_sel_en = is_branch | is_jal | is_jalr;
   assign pc_mux_sel = (is_jump == 1'b1) ? 1'b1 : take;
   assign branch_taken_out = pc_mux_sel_en & pc_mux_sel;
    
 
   always @(*)
   begin
      case (funct3_in)

         3'b000  : take = (rs1_in == rs2_in);
         3'b001  : take = !(rs1_in == rs2_in);
         3'b100  : take = rs1_in[31] ^ rs2_in[31] ? rs1_in[31] : (rs1_in < rs2_in);
         3'b101  : take = rs1_in[31] ^ rs2_in[31] ? ~rs1_in[31] : !(rs1_in < rs2_in);
         3'b110  : take = (rs1_in < rs2_in);
         3'b111  : take = !(rs1_in < rs2_in);
         default : take = 1'b0;

      endcase
   end
    

   always @(*)
   begin
      case (opcode_6_to_2_in [6:2])

         OPCODE_JAL    : is_jal =1'b1;
         OPCODE_JALR   : is_jalr =1'b1;
         OPCODE_BRANCH : is_branch = 1'b1;
         default       : {is_jal,is_jalr,is_branch} = 3'b000; 

      endcase
   end
    
endmodule

