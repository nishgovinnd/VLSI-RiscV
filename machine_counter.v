
module machine_counter( input             clk_in,rst_in,wr_en_in,mcountinhibit_cy_in,mcountinhibit_ir_in,instret_inc_in,
			input      [11:0] csr_addr_in,
			input  	   [31:0] data_wr_in, 
  			input 	   [63:0] real_time_in, 
			output reg [63:0] mcycle_out,minstret_out,mtime_out
);

   parameter MCYCLE_RESET   =     32'h00000000;
   parameter TIME_RESET     =     32'h00000000;
   parameter MINSTRET_RESET =     32'h00000000;
   parameter MCYCLEH_RESET  =     32'h00000000;
   parameter TIMEH_RESET    =     32'h00000000;
   parameter MINSTRETH_RESET=     32'h00000000;
   parameter MCYCLE         =     12'hB00;
   parameter MCYCLEH        =     12'hB80;
   parameter MINSTRET       =     12'hB02;
   parameter MINSTRETH      =     12'hB82;

   always @(posedge clk_in)
   begin
      if(rst_in)
      begin
         mcycle_out <= {MCYCLEH_RESET, MCYCLE_RESET};
         minstret_out <= {MINSTRETH_RESET, MINSTRET_RESET};
         mtime_out <= {TIMEH_RESET, TIME_RESET};
      end
      else
      begin
         mtime_out <= real_time_in;

         if(csr_addr_in == MCYCLE && wr_en_in)
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= {mcycle_out[63:32], data_wr_in} + 1;
            else
	       mcycle_out <= {mcycle_out[63:32], data_wr_in};
         end
         else if(csr_addr_in == MCYCLEH && wr_en_in)
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= {data_wr_in, mcycle_out[31:0]} + 1;
            else 
	       mcycle_out <= {data_wr_in, mcycle_out[31:0]};
         end
         else
         begin
            if(mcountinhibit_cy_in == 1'b0) 
	       mcycle_out <= mcycle_out + 1;
            else 
	       mcycle_out <= mcycle_out;
         end
         if(csr_addr_in == MINSTRET && wr_en_in)
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= {minstret_out[63:32], data_wr_in} + instret_inc_in;
            else 
	       minstret_out <= {minstret_out[63:32], data_wr_in};
         end
         else if(csr_addr_in == MINSTRETH && wr_en_in)
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= {data_wr_in, minstret_out[31:0]} + instret_inc_in;
            else 
	       minstret_out <= {data_wr_in, minstret_out[31:0]};
         end
         else
         begin
            if(mcountinhibit_ir_in == 1'b0) 
	       minstret_out <= minstret_out + instret_inc_in;
            else 
	       minstret_out <= minstret_out;
         end

      end
   end
endmodule

