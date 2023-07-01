
module msrv32_machine_control( input  clk_in, reset_in,
                              
                               input  illegal_instr_in,misaligned_load_in,misaligned_store_in,
                              
                               input  misaligned_instr_in,
                             
                               input  [6:2] opcode_6_to_2_in,
                               input  [2:0] funct3_in,
                               input  [6:0] funct7_in,
                               input  [4:0] rs1_addr_in,
                               input  [4:0] rs2_addr_in,
                               input  [4:0] rd_addr_in,
                              
                               input  e_irq_in,t_irq_in, s_irq_in,
			      
			       input  mie_in, meie_in,mtie_in, msie_in, meip_in,mtip_in,msip_in,         
                            
                               output reg i_or_e_out, set_epc_out, set_cause_out,
                               output reg [3:0] cause_out,
                               output reg instret_inc_out, mie_clear_out, mie_set_out,
			                  misaligned_exception_out,
                               
                               output reg [1:0] pc_src_out,
                              
                               output reg flush_out,
                               
                               output trap_taken_out );
    
    
    reg [3:0] curr_state;
    reg [3:0] next_state;
    
    
    parameter STATE_RESET         = 4'b0001; 
    parameter STATE_OPERATING     = 4'b0010;
    parameter STATE_TRAP_TAKEN    = 4'b0100;    
    parameter STATE_TRAP_RETURN   = 4'b1000;
    
    parameter PC_BOOT =2'b00,
              PC_EPC=  2'b01,
              PC_TRAP= 2'b10,
              PC_NEXT= 2'b11;
    
    wire exception;
    wire ip;
    wire eip;
    wire tip;
    wire sip;
    wire is_system;
    wire rs1_addr_zero;
    wire rs2_addr_zero;
    wire rd_zero;
    wire rs2_addr_mret;
    wire rs2_addr_ebreak;
    wire FUNCT3_zero;
    wire FUNCT7_zero;
    wire FUNCT7_mret;
    wire csr;
    wire mret;
    wire ecall;
    wire ebreak;
    reg pre_instret_inc;
    

    
    assign is_system   =  opcode_6_to_2_in[6] & opcode_6_to_2_in[5] & opcode_6_to_2_in[4] 
                          & ~opcode_6_to_2_in[3] & ~opcode_6_to_2_in[2];
    assign FUNCT3_zero =  ~(funct3_in[2] | funct3_in[1] | funct3_in[0]);
    assign FUNCT7_zero =  ~(funct7_in[6] | funct7_in[5] | funct7_in[4] | funct7_in[3] 
                          | funct7_in[2] | funct7_in[1] | funct7_in[0]);
    assign FUNCT7_wfi  =  ~funct7_in[6] & ~funct7_in[5] & ~funct7_in[4] & funct7_in[3] & 
                          ~funct7_in[2] & ~funct7_in[1] & ~funct7_in[0];
    assign FUNCT7_mret  = ~funct7_in[6] & ~funct7_in[5] & funct7_in[4] & 
                          funct7_in[3] & ~funct7_in[2] & ~funct7_in[1] & ~funct7_in[0];
    assign rs1_addr_zero =~(rs1_addr_in[4] | rs1_addr_in[3] | rs1_addr_in[2] | rs1_addr_in[1] | 
                          rs1_addr_in[0]);
    assign rs2_addr_zero =~(rs2_addr_in[4] | rs2_addr_in[3] | rs2_addr_in[2] | rs2_addr_in[1] | 
                          rs2_addr_in[0]);
    assign rd_zero =      ~(rd_addr_in[4] | rd_addr_in[3] | rd_addr_in[2] | rd_addr_in[1] | rd_addr_in[0]);
    assign rs2_addr_wfi = ~rs2_addr_in[4] & ~rs2_addr_in[3] & rs2_addr_in[2] & 
                          ~rs2_addr_in[1] & rs2_addr_in[0];
    assign rs2_addr_mret = ~rs2_addr_in[4] & ~rs2_addr_in[3] & ~rs2_addr_in[2] & 
                           rs2_addr_in[1] & ~rs2_addr_in[0];
    assign rs2_addr_ebreak = ~rs2_addr_in[4] & ~rs2_addr_in[3] & ~rs2_addr_in[2] & 
                             ~rs2_addr_in[1] & rs2_addr_in[0];
    assign mret =            is_system & FUNCT7_mret & rs2_addr_mret & rs1_addr_zero & FUNCT3_zero & rd_zero;
    assign ecall = is_system & FUNCT7_zero & rs2_addr_zero & rs1_addr_zero & FUNCT3_zero & rd_zero;
    assign ebreak = is_system & FUNCT7_zero & rs2_addr_ebreak & rs1_addr_zero & FUNCT3_zero & rd_zero;
    
    assign eip = meie_in & (e_irq_in | meip_in);
    assign tip = mtie_in & (t_irq_in | mtip_in);
    assign sip = msie_in & (s_irq_in | msip_in);
    assign ip = eip | tip | sip;
    assign exception = illegal_instr_in | misaligned_instr_in | misaligned_load_in | misaligned_store_in;
    assign trap_taken_out = (mie_in & ip) | exception | ecall | ebreak;
    
    always @*
    begin
       case(curr_state)
          STATE_RESET:
             next_state = STATE_OPERATING;
          STATE_OPERATING: 
             if(trap_taken_out) 
                next_state = STATE_TRAP_TAKEN;
             else if(mret) 
                next_state = STATE_TRAP_RETURN;
             else 
                next_state = STATE_OPERATING;
          STATE_TRAP_TAKEN:
             next_state = STATE_OPERATING;
          STATE_TRAP_RETURN:
             next_state = STATE_OPERATING;
          default:
             next_state = STATE_OPERATING;
        endcase
    end
    
    
    always @*
    begin
       case(curr_state)
          STATE_RESET:
          begin
             pc_src_out = PC_BOOT;
             flush_out = 1'b1;
             instret_inc_out = 1'b0;
             set_epc_out = 1'b0;
             set_cause_out = 1'b0;
             mie_clear_out = 1'b0;
             mie_set_out = 1'b0;
           end
           STATE_OPERATING:
              begin
              pc_src_out = PC_NEXT;
              flush_out = 1'b0;
              instret_inc_out = 1'b1;
              set_epc_out = 1'b0;
              set_cause_out = 1'b0;
              mie_clear_out = 1'b0;
              mie_set_out = 1'b0;
           end
           STATE_TRAP_TAKEN:
           begin
              pc_src_out = PC_TRAP;
              flush_out = 1'b1;
              instret_inc_out = 1'b0;
              set_epc_out = 1'b1;
              set_cause_out = 1'b1;
              mie_clear_out = 1'b1;
              mie_set_out = 1'b0;
           end
           STATE_TRAP_RETURN:
           begin
              pc_src_out = PC_EPC;
              flush_out = 1'b1;
              instret_inc_out = 1'b0;
              set_epc_out = 1'b0;
              set_cause_out = 1'b0;
              mie_clear_out = 1'b0;
              mie_set_out = 1'b1;
           end
           default:
           begin
              pc_src_out = PC_NEXT;
              flush_out = 1'b0;
              instret_inc_out = 1'b1;
              set_epc_out = 1'b0;
              set_cause_out = 1'b0;
              mie_clear_out = 1'b0;
              mie_set_out = 1'b0;
           end
        endcase
        
    end
    
  
    
    always @(posedge clk_in)
    begin
       if(reset_in) 
          curr_state <= STATE_RESET;
       else
          curr_state <= next_state;
    end    
    
    always @(posedge clk_in)
    begin
       if(reset_in) 
          misaligned_exception_out <= 1'b0;
       else 
          misaligned_exception_out <= misaligned_instr_in | misaligned_load_in | misaligned_store_in;
    end
    
    always @(posedge clk_in)
    begin
       if(reset_in)
       begin
          cause_out <= 4'b0;
          i_or_e_out <= 1'b0;
       end
       else if(curr_state == STATE_OPERATING)
       begin 
          if(mie_in & eip)
          begin
             cause_out <= 4'b1011; // M-mode external interrupt
             i_or_e_out <= 1'b1;
          end
       end	 
       else if(mie_in & sip)
       begin
          cause_out <= 4'b0011; // M-mode software interrupt
          i_or_e_out <= 1'b1;
       end
       else if(mie_in & tip)
       begin
          cause_out <= 4'b0111; // M-mode timer interrupt
          i_or_e_out <= 1'b1;
       end
       else if(illegal_instr_in)
       begin
          cause_out <= 4'b0010; // Illegal instruction
          i_or_e_out <= 1'b0;
       end
       else if(misaligned_instr_in)
       begin
          cause_out <= 4'b0000; // Instruction address misaligned
          i_or_e_out <= 1'b0;
       end
       else if(ecall)
       begin
          cause_out <= 4'b1011; // Environment call from M-mode
          i_or_e_out <= 1'b0;
       end
       else if(ebreak)
       begin
          cause_out <= 4'b0011; // Breakpoint
          i_or_e_out <= 1'b0;
       end
       else if(misaligned_store_in)
       begin
          cause_out <= 4'b0110; // Store address misaligned
          i_or_e_out <= 1'b0;
       end
       else if(misaligned_load_in)
       begin
          cause_out <= 4'b0100; // Load address misaligned
          i_or_e_out <= 1'b0;
       end
      
    end		  
       
endmodule

