
module msrv32_integer_file( input clk_in, reset_in,
                            
                            input  [4:0]  rs_1_addr_in,rs_2_addr_in, 
                            output [31:0] rs_1_out,rs_2_out,
                           
                            input  [4:0]  rd_addr_in,
                            input         wr_en_in,
                            input  [31:0] rd_in
			   );

    
   
    reg [31:0] reg_file [31:0];

 
    wire fwd_op1_enable, fwd_op2_enable;
    integer i;
    
   
    assign fwd_op1_enable = (rs_1_addr_in == rd_addr_in && wr_en_in == 1'b1) ? 1'b1 : 1'b0;
    assign fwd_op2_enable = (rs_2_addr_in == rd_addr_in && wr_en_in == 1'b1) ? 1'b1 : 1'b0;
        
    
  
   always@(posedge clk_in or posedge reset_in)
   begin
      if(reset_in)
      begin
      for(i = 0; i < 32; i = i+1) 
         reg_file[i]  = 32'b0;
      end  

      else if(wr_en_in && rd_addr_in) 
      begin
         reg_file[rd_addr_in] <= rd_in;
      end 
   end	
 
   assign rs_1_out = fwd_op1_enable == 1'b1 ? rd_in : reg_file[rs_1_addr_in]; 
   assign rs_2_out = fwd_op2_enable == 1'b1 ? rd_in : reg_file[rs_2_addr_in];
    
endmodule

