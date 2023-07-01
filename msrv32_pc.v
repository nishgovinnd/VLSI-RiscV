module msrv32_pc (input              branch_taken_in,rst_in,
                  input              ahb_ready_in,
                  input       [1:0 ] pc_src_in,
                  input       [31:0] epc_in,trap_address_in,pc_in,
                  input       [31:1] iaddr_in,
                  output      [31:0] pc_plus_4_out,i_addr_out,
		  output             misaligned_instr_out,
                  output  reg [31:0] pc_mux_out
		 );
   reg [31:0] i_addr;
   parameter BOOT_ADDRESS = 0;

  
   wire [31:0] next_pc;   
  
   assign misaligned_instr_out=next_pc[1] & branch_taken_in;   
   assign pc_plus_4_out = pc_in + 32'h00000004;   

  
   assign next_pc=branch_taken_in ? {iaddr_in,1'b0} : pc_plus_4_out; 


   assign i_addr_out = i_addr;


   always@(*)
   begin
      case(pc_src_in)
         2'b00  : pc_mux_out = BOOT_ADDRESS;
         2'b01  : pc_mux_out = epc_in;
	 2'b10  : pc_mux_out = trap_address_in;
         2'b11  : pc_mux_out = next_pc;
	 default: pc_mux_out = next_pc;
      endcase
    end

   always @(*)
   begin
      if(rst_in)
      i_addr = BOOT_ADDRESS;
      else if(ahb_ready_in)
      i_addr =  pc_mux_out;
   end

endmodule

