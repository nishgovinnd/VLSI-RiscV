
module csr_data_mux_unit ( input      [11:0] csr_addr_in,
			   input      [63:0] mcycle_in,mtime_in,minstret_in,
			   input      [31:0] mscratch_in,mip_reg_in,mtval_in,mcause_in,mepc_in,mtvec_in,mstatus_in,misa_in,mie_reg_in,mcountinhibit_in,
			   output reg [31:0] csr_data_out
);

   
   
   
   parameter CYCLE     =         12'hC00;
   parameter TIME      =         12'hC01;
   parameter INSTRET   =         12'hC02;
   parameter CYCLEH    =         12'hC80;
   parameter TIMEH     =         12'hC81;
   parameter INSTRETH  =         12'hC82;
   

   parameter MSTATUS   =         12'h300;
   parameter MISA      =         12'h301;
   parameter MIE       =         12'h304;
   parameter MTVEC     =         12'h305;
   
  
   parameter MSCRATCH  =         12'h340;
   parameter MEPC      =         12'h341;
   parameter MCAUSE    =         12'h342;
   parameter MTVAL     =         12'h343;
   parameter MIP       =         12'h344;  
  
   parameter MCYCLE    =         12'hB00;
   parameter MINSTRET  =         12'hB02;
   parameter MCYCLEH   =         12'hB80;
   parameter MINSTRETH =         12'hB82;
   
   
   parameter MCOUNTINHIBIT =   12'h320;
   
   always @(*)
   begin
      case(csr_addr_in)
         CYCLE:         csr_data_out = mcycle_in[31:0];
         CYCLEH:        csr_data_out = mcycle_in[63:32];
         TIME:          csr_data_out = mtime_in[31:0];
         TIMEH:         csr_data_out = mtime_in[63:32];
         INSTRET:       csr_data_out = minstret_in[31:0];
         INSTRETH:      csr_data_out = minstret_in[63:32];
         MSTATUS:       csr_data_out = mstatus_in;
         MISA:          csr_data_out = misa_in;
         MIE:           csr_data_out = mie_reg_in;
         MTVEC:         csr_data_out = mtvec_in;
         MSCRATCH:      csr_data_out = mscratch_in;
         MEPC:          csr_data_out = mepc_in;
         MCAUSE:        csr_data_out = mcause_in;
         MTVAL:         csr_data_out = mtval_in;
         MIP:           csr_data_out = mip_reg_in;
         MCYCLE:        csr_data_out = mcycle_in[31:0];
         MCYCLEH:       csr_data_out = mcycle_in[63:32];
         MINSTRET:      csr_data_out = minstret_in[31:0];
         MINSTRETH:     csr_data_out = minstret_in[63:32];
         MCOUNTINHIBIT: csr_data_out = mcountinhibit_in;
         default:        csr_data_out = 32'b0;
      endcase
    end


endmodule

