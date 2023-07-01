
 module msrv32_store_unit(input      [1:0 ] funct3_in,
		         input      [31:0] iadder_in,rs2_in,
                         input             mem_wr_req_in,ahb_ready_in,
			 output     [31:0] d_addr_out,
			 output reg [31:0] data_out,
			 output reg [3 :0] wr_mask_out,
                         output reg [1:0]  ahb_htrans_out,
		         output            wr_req_out
);
 

   reg [31:0] byte_dout,halfword_dout; 
   reg [3:0 ] byte_wr_mask,halfword_wr_mask;   
   reg [31:0] d_addr=0; 
  
   assign d_addr_out= {iadder_in[31:2],2'b00};

   assign wr_req_out=mem_wr_req_in;
 
   always@(*)
   begin
      case(iadder_in[1:0])
         2'b00   : byte_dout = {8'b0,8'b0,8'b0,rs2_in[7:0]};
         2'b01   : byte_dout = {8'b0,8'b0,rs2_in[7:0],8'b0};
         2'b10   : byte_dout = {8'b0,rs2_in[7:0],8'b0,8'b0};
         2'b11   : byte_dout = {rs2_in[7:0],8'b0,8'b0,8'b0};
         default : byte_dout = 32'b0;
      endcase
   end
 

   always@(*)
   begin
      case(iadder_in[1])
         1'b0    : halfword_dout = {16'b0,rs2_in[15:0]};
         1'b1    : halfword_dout = {rs2_in[15:0],16'b0};
         default : halfword_dout = 32'b0;
      endcase
   end

   always@(*)
   begin 
     if(ahb_ready_in)
      begin
         case(funct3_in)
            2'b00   : data_out = byte_dout;
            2'b01   : data_out = halfword_dout;
            default : data_out = rs2_in;
         endcase
         ahb_htrans_out = 2'b10;
      end
      else
         ahb_htrans_out = 2'b00;         
   end

 
   always@(*)
   begin
      case(funct3_in)
         2'b00   : wr_mask_out = byte_wr_mask;
         2'b01   : wr_mask_out = halfword_wr_mask;
         default : wr_mask_out = {4{mem_wr_req_in}};
      endcase 
   end
 

   always@(*)
   begin
      case(iadder_in[1:0])
         2'b00   : byte_wr_mask = {3'b0,mem_wr_req_in};
         2'b01   : byte_wr_mask = {2'b0,mem_wr_req_in,1'b0};
         2'b10   : byte_wr_mask = {1'b0,mem_wr_req_in,2'b0};
         2'b11   : byte_wr_mask = {mem_wr_req_in,3'b0};
	 default : byte_wr_mask = {4{mem_wr_req_in}};
      endcase 
   end

   always@(*)
   begin
      case(iadder_in[1])
         1'b0    : halfword_wr_mask = {2'b0,{2{mem_wr_req_in}}};
         1'b1    : halfword_wr_mask = {{2{mem_wr_req_in}},2'b0};
	 default : halfword_wr_mask = {4{mem_wr_req_in}};
      endcase 
   end 


endmodule

