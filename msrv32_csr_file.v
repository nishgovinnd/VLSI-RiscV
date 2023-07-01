


module msrv32_csr_file(input        clk_in,rst_in,wr_en_in,
		       input [11:0] csr_addr_in,
		       input [2:0 ] csr_op_in,
		       input [4:0 ] csr_uimm_in,
		       input [31:0] csr_data_in,
		       input [31:0] pc_in,iadder_in,
		       input	    e_irq_in,s_irq_in,t_irq_in,i_or_e_in,set_cause_in,set_epc_in,instret_inc_in,mie_clear_in,mie_set_in,
		       input [3:0 ] cause_in,
		       input [63:0] real_time_in,
		       input misaligned_exception_in,
		       output [31:0] csr_data_out,
		       output  mie_out,
		       output [31:0] epc_out,trap_address_out,
		       output meie_out,mtie_out,msie_out,meip_out,mtip_out,msip_out

		
);
  
   wire [31:0] mstatus; // machine status register
   wire [31:0] misa; // machine ISA register
   wire [31:0] mie_reg; // machine interrupt enable register
   wire [31:0] mtvec;
   wire [1:0 ] mxl; // machine XLEN
   wire [25:0] mextensions; // ISA extensions
   wire  [1:0 ] mtvec_mode; // machine trap mode
   wire  [29:0] mtvec_base; // machine trap base address
   wire        mpie; // mach. prior interrupt enable

  
   wire  [31:0] mscratch; // machine scratch register
   wire [31:0] mepc; // machine exception program counter
   wire [31:0] mtval; // machine trap value register
   wire [31:0] mcause; // machine trap cause register
   wire [31:0] mip_reg; // machine interrupt pending register
   wire        int_or_exc; // interrupt or exception signal
   wire [3:0 ] cause; // interrupt cause
   wire  [26:0] cause_rem; // remaining bits of mcause register 

  
   wire [63:0] mcycle;
   wire [63:0] mtime;
   wire [63:0] minstret;


   wire [31:0] mcountinhibit;
   wire  mcountinhibit_cy;
   wire  mcountinhibit_ir;

  
   
  

   wire [31:0] data_wr;
   wire [31:0] pre_data;


   data_wr_mux_unit DRMU (.csr_op_1_0_in(csr_op_in[1:0]),
			  .csr_data_out_in(csr_data_out),
			  .pre_data_in(pre_data),
			  .data_wr_out(data_wr)
			 );


   csr_data_mux_unit CDMU (.csr_addr_in(csr_addr_in),
			   .mcycle_in(mcycle),
			   .mtime_in(mtime),
			   .minstret_in(minstret),
			   .mscratch_in(mscratch),
			   .mip_reg_in(mip_reg),
			   .mtval_in(mtval),
			   .mcause_in(mcause),
			   .mepc_in(mepc),
			   .mtvec_in(mtvec),
			   .mstatus_in(mstatus),
			   .misa_in(misa),
			   .mie_reg_in(mie_reg),
			   .mcountinhibit_in(mcountinhibit),
			   .csr_data_out(csr_data_out)
			);



   mstatus_reg MS (.clk_in(clk_in),
		   .rst_in(rst_in),
		   .wr_en_in(wr_en_in),
		   .data_wr_3_in(data_wr[3]),
		   .data_wr_7_in(data_wr[7]),
		   .mie_clear_in(mie_clear_in),
		   .mie_set_in(mie_set_in),
		   .csr_addr_in(csr_addr_in),
		   .mstatus_out(mstatus),
		   .mie_out(mie_out)
		  );

   misa_and_pre_data MPD (.csr_op_2_in(csr_op_in[2]),
			  .csr_uimm_in(csr_uimm_in),
			  .csr_data_in(csr_data_in),
			  .misa_out(misa),
			  .pre_data_out(pre_data)
			 );


   mie_reg MIE_REG (.clk_in(clk_in),
		    .rst_in(rst_in),
		    .wr_en_in(wr_en_in),
		    .data_wr_3_in(data_wr[3]),
		    .data_wr_7_in(data_wr[7]),
		    .data_wr_11_in(data_wr[11]),
		    .csr_addr_in(csr_addr_in),
		    .meie_out(meie_out),
		    .mtie_out(mtie_out),
		    .msie_out(msie_out),
		    .mie_reg_out(mie_reg)
		   );




   mtvec_reg MTVEC_REG (.clk_in(clk_in),
			.rst_in(rst_in),
			.wr_en_in(wr_en_in),
			.int_or_exc_in(int_or_exc),
			.data_wr_in(data_wr),
			.csr_addr_in(csr_addr_in),
			.cause_in(cause),
			.mtvec_out(mtvec),
			.trap_address_out(trap_address_out)
			);



   mepc_and_mscratch_reg MM_REG (.clk_in(clk_in),
				 .rst_in(rst_in),
				 .wr_en_in(wr_en_in),
				 .set_epc_in(set_epc_in),
				 .pc_in(pc_in),
				 .data_wr_in(data_wr),
				 .csr_addr_in(csr_addr_in),
				 .mscratch_out(mscratch),
				 .mepc_out(mepc),
				 .epc_out(epc_out)
				);



   mcause_reg MCAUSE_REG (.clk_in(clk_in),
			  .rst_in(rst_in),
			  .wr_en_in(wr_en_in),
			  .set_cause_in(set_cause_in),
			  .i_or_e_in(i_or_e_in),
			  .cause_in(cause_in),
			  .data_wr_in(data_wr),
			  .csr_addr_in(csr_addr_in),
			  .mcause_out(mcause),
			  .cause_out(cause),
			  .int_or_exc_out(int_or_exc)
			);



   mip_reg MIP_REG (.clk_in(clk_in),
		   .rst_in(rst_in),
		   .e_irq_in(e_irq),
		   .t_irq_in(t_irq),
		   .s_irq_in(s_irq),
		   .meip_out(meip_out),
		   .mtip_out(mtip_out),
		   .msip_out(msip_out),
		   .mip_reg_out(mip_reg)
		  ); 



   mtval_reg MTVAL_REG (.clk_in(clk_in),
			.rst_in(rst_in),
			.wr_en_in(wr_en_in),
			.set_cause_in(set_cause_in),
			.misaligned_exception_in(misaligned_exception_in),
			.iadder_in(iadder_in),
			.data_wr_in(data_wr),
			.csr_addr_in(csr_addr_in),
			.mtval_out(mtval)
			);




  
   machine_counter_setup MCS (.clk_in(clk_in),
			      .rst_in(rst_in),
			      .wr_en_in(wr_en_in),
			      .data_wr_2_in(data_wr[2]),
			      .data_wr_0_in(data_wr[0]),
			      .csr_addr_in(csr_addr_in),
			      .mcountinhibit_cy_out(mcountinhibit_cy),
			      .mcountinhibit_ir_out(mcountinhibit_ir),
			      .mcountinhibit_out(mcountinhibit)
			     );


   machine_counter MC (.clk_in(clk_in),
		       .rst_in(rst_in),
		       .wr_en_in(wr_en_in),
		       .mcountinhibit_cy_in(mcountinhibit_cy),
		       .mcountinhibit_ir_in(mcountinhibit_ir),
		       .instret_inc_in(instret_inc_in),
		       .csr_addr_in(csr_addr_in),
		       .data_wr_in(data_wr),
		       .real_time_in(real_time_in),
		       .mcycle_out(mcycle),
		       .minstret_out(minstret),
		       .mtime_out(mtime)
		      );

      
endmodule




