
module mstatus_reg( input             clk_in,rst_in,wr_en_in,data_wr_3_in,data_wr_7_in,mie_clear_in,mie_set_in,
                    input      [11:0] csr_addr_in,
                    output     [31:0] mstatus_out,
                    output reg        mie_out
);

   parameter  MSTATUS = 12'h300;
   reg mpie_out;
   assign mstatus_out = {19'b0, 2'b11, 3'b0, mpie_out, 3'b0 , mie_out, 3'b0};
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mie_out <= 1'b0;
         mpie_out <= 1'b1;
      end
      else if(csr_addr_in == MSTATUS && wr_en_in)
      begin
         mie_out <= data_wr_3_in;
         mpie_out <= data_wr_7_in;
      end
      else if(mie_clear_in == 1'b1)
      begin
         mpie_out <= mie_out;
         mie_out <= 1'b0;
      end
      else if(mie_set_in == 1'b1)
      begin
         mie_out <= mpie_out;
         mpie_out <= 1'b1;
      end
   end
endmodule

