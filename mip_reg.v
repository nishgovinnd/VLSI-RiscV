
module mip_reg(input         clk_in,rst_in,e_irq_in,t_irq_in,s_irq_in,
               output        meip_out,mtip_out,msip_out,
               output [31:0] mip_reg_out);

   reg meip,mtip,msip;   //Internal wires

   always@(posedge clk_in)
   begin
      if(rst_in)
      begin
         meip = 1'b0;
         mtip = 1'b0;
         msip = 1'b0;
      end
      else
      begin
         meip = e_irq_in;
         mtip = t_irq_in;
         msip = s_irq_in;
      end
   end
   assign meip_out = meip;
   assign mtip_out = mtip;
   assign msip_out = msip;

   assign mip_reg_out = {20'b0, meip, 3'b0, mtip, 3'b0, msip, 3'b0};
endmodule

