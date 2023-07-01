
module mcause_reg( input             clk_in,rst_in,set_cause_in,i_or_e_in,wr_en_in,
                   input      [3:0 ] cause_in,
                   input      [31:0] data_wr_in,
                   input      [11:0] csr_addr_in,
                   output     [31:0] mcause_out,
                   output reg [3:0 ] cause_out,
                   output reg        int_or_exc_out
);

   parameter MCAUSE =  12'h342;

   reg  [26:0] cause_rem;   //remaining bits of mcause register

   assign mcause_out = {int_or_exc_out, cause_rem, cause_out};
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         cause_out <= 4'b0000;
         cause_rem <= 27'b0;
         int_or_exc_out <= 1'b0;
      end
      else if(set_cause_in)
      begin
         cause_out <= cause_in;
         cause_rem <= 27'b0;
         int_or_exc_out <= i_or_e_in;
      end
      else if(csr_addr_in == MCAUSE && wr_en_in)
      begin
         cause_out <= data_wr_in[3:0];
         cause_rem <= data_wr_in[30:4];
         int_or_exc_out <= data_wr_in[31];

      end
   end
endmodule
