module msrv32_immediate_adder(input  [31:0] pc_in,rs1_in,imm_in,
                              input         iadder_src_in,
                              output [31:0] iadder_out
                             );

   assign iadder_out = iadder_src_in ? (rs1_in+imm_in) : (pc_in + imm_in);
endmodule

