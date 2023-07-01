module msrv32_alu(input [31:0] op_1_in,        
                  input [31:0] op_2_in,        
                  input [3:0] opcode_in,      
                  output reg [31:0] result_out 
                 );


   parameter  FUNCT3_ADD      =    3'b000;
   parameter  FUNCT3_SLT      =    3'b010;
   parameter  FUNCT3_SLTU     =    3'b011;
   parameter  FUNCT3_AND      =    3'b111;
   parameter  FUNCT3_OR       =    3'b110;
   parameter  FUNCT3_XOR      =    3'b100;
   parameter  FUNCT3_SLL      =    3'b001;
   parameter  FUNCT3_SRL      =    3'b101;
     
    
   wire signed [31:0] signed_op1;  
   wire signed [31:0] adder_op2;   
   wire [31:0] minus_op2;          
   wire [31:0] sra_result;        
   wire [31:0] srl_result;         
   wire [31:0] shr_result;         
   wire slt_result;               
   wire sltu_result;               
    
   reg [31:0] pre_result;    
    
   assign signed_op1 = op_1_in;
   assign minus_op2 = -op_2_in;
   assign adder_op2 = opcode_in[3] == 1'b1 ? minus_op2 : op_2_in;
   assign sra_result = signed_op1 >>> op_2_in[4:0];
   assign srl_result = op_1_in >> op_2_in[4:0];
   assign shr_result = opcode_in[3] == 1'b1 ? sra_result : srl_result;
   assign sltu_result = op_1_in < op_2_in;
   assign slt_result = op_1_in[31] ^ op_2_in[31] ? op_1_in[31] : sltu_result;


   always @*
   begin
    
      case(opcode_in[2:0])
        
         FUNCT3_ADD  : result_out = op_1_in + adder_op2;
         FUNCT3_SRL  : result_out = shr_result;
         FUNCT3_OR   : result_out = op_1_in | op_2_in;
         FUNCT3_AND  : result_out = op_1_in & op_2_in;            
         FUNCT3_XOR  : result_out = op_1_in ^ op_2_in;
         FUNCT3_SLT  : result_out = {31'b0, slt_result};
         FUNCT3_SLTU : result_out = {31'b0, sltu_result};
         FUNCT3_SLL  : result_out = op_1_in << op_2_in[4:0];
         default     : result_out = 32'b0;

      endcase
    
   end
    
endmodule

