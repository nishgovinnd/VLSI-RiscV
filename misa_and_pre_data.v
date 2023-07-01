


module misa_and_pre_data( input         csr_op_2_in,
                          input  [4:0 ] csr_uimm_in,
                          input  [31:0] csr_data_in,
                          output [31:0] misa_out,pre_data_out
);

   wire [1:0 ] mxl; // machine XLEN
   wire [25:0] mextensions; // ISA extensions


   assign pre_data_out = csr_op_2_in == 1'b1 ? {27'b0, csr_uimm_in} : csr_data_in;

   assign mxl = 2'b01;
   assign mextensions = 26'b00000000000000000100000000;
   assign misa_out = {mxl, 4'b0, mextensions};

endmodule

