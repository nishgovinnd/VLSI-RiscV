
module mepc_and_mscratch_reg( input        clk_in,rst_in,wr_en_in,set_epc_in,
                              input      [31:0] pc_in,data_wr_in,
                              input      [11:0] csr_addr_in,
                              output reg [31:0] mscratch_out,mepc_out,
                              output     [31:0] epc_out
);

   parameter MSCRATCH_RESET =     32'h00000000;
   parameter MSCRATCH       =     12'h340;
   parameter MEPC_RESET     =     32'h00000000;
   parameter MEPC           =     12'h341;



   always @(posedge clk_in)
   begin
      if(rst_in)
         mscratch_out <= MSCRATCH_RESET;
      else if(csr_addr_in == MSCRATCH && wr_en_in)
         mscratch_out <= data_wr_in;
   end


   assign epc_out = mepc_out;
   always @(posedge clk_in)
   begin
      if(rst_in)
         mepc_out <=MEPC_RESET;
      else if(set_epc_in)
         mepc_out <= pc_in;
      else if(csr_addr_in == MEPC && wr_en_in)
         mepc_out <= {data_wr_in[31:2], 2'b00};
   end
endmodule

