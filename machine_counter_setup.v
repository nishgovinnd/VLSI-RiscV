


module machine_counter_setup( input             clk_in,rst_in,wr_en_in,data_wr_2_in,data_wr_0_in,
                              input      [11:0] csr_addr_in,
                              output reg        mcountinhibit_cy_out,mcountinhibit_ir_out,
                              output     [31:0] mcountinhibit_out
);

   parameter MCOUNTINHIBIT_CY_RESET = 1'b0;
   parameter MCOUNTINHIBIT_IR_RESET = 1'b0;
   parameter MCOUNTINHIBIT          = 12'h320;

   wire [31:0] mcountinhibit;
   assign mcountinhibit = {29'b0, mcountinhibit_ir_out, 1'b0, mcountinhibit_cy_out};
   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mcountinhibit_cy_out <= MCOUNTINHIBIT_CY_RESET;
         mcountinhibit_ir_out <= MCOUNTINHIBIT_IR_RESET;
      end
      else if(csr_addr_in == MCOUNTINHIBIT && wr_en_in)
      begin
         mcountinhibit_cy_out <= data_wr_2_in;
         mcountinhibit_ir_out <= data_wr_0_in;
      end
   end

endmodule

