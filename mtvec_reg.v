
module mtvec_reg( input        clk_in,rst_in,wr_en_in,int_or_exc_in,
                  input  [31:0] data_wr_in,
                  input  [11:0] csr_addr_in,
                  input  [3:0 ] cause_in,
                  output [31:0] mtvec_out,trap_address_out
);

   parameter  MTVEC_BASE_RESET  =    30'b00000000_00000000_00000000_000000;
   parameter  MTVEC_MODE_RESET  =    2'b00;
   parameter  MTVEC             =    12'h305;

   reg  [1:0 ] mtvec_mode; // machine trap mode
   reg  [29:0] mtvec_base; // machine trap base address

   assign mtvec_out = {mtvec_base, mtvec_mode};
   wire [31:0] trap_mux_out;
   wire [31:0] vec_mux_out;
   wire [31:0] base_offset;
   assign base_offset = cause_in << 2;
   assign trap_mux_out = int_or_exc_in ? vec_mux_out : {mtvec_base, 2'b00};
   assign vec_mux_out = mtvec_out[0] ? {mtvec_base, 2'b00} + base_offset : {mtvec_base, 2'b00};
   assign trap_address_out = trap_mux_out;
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mtvec_mode <= MTVEC_MODE_RESET;
         mtvec_base <= MTVEC_BASE_RESET;
      end
      else if(csr_addr_in == MTVEC && wr_en_in)
      begin
         mtvec_mode <= data_wr_in[1:0];
         mtvec_base <= data_wr_in[31:2];
      end
   end
endmodule

