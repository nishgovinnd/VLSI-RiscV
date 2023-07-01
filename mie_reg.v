


module mie_reg( input         clk_in,rst_in,wr_en_in,data_wr_11_in,data_wr_7_in,data_wr_3_in,
                input  [11:0] csr_addr_in,
                output        meie_out,mtie_out,msie_out,
                output [31:0] mie_reg_out
);

   parameter MIE = 12'h304;


   reg meie,mtie,msie;

   assign mie_reg_out = {20'b0, meie, 3'b0, mtie, 3'b0, msie, 3'b0};
   assign meie_out = meie;
   assign mtie_out = mtie;
   assign msie_out = msie;
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         meie <= 1'b0;
         mtie <= 1'b0;
         msie <= 1'b0;
      end
      else if(csr_addr_in == MIE && wr_en_in)
      begin
         meie <= data_wr_11_in;
         mtie <= data_wr_7_in;
         msie <= data_wr_3_in;
      end
   end

endmodule

