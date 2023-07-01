module msrv32_top_wrapper(msrv32_ahb_instr_if instr_if, msrv32_ahb_data_if data_if, msrv32_rst_if rst_if,msrv32_irq_if irq_if);

   msrv32_top  DUT 
   (
	// Replace the below mentioned comments with the respective signal names from your top module of RTL.
 
     .ms_riscv32_mp_clk_in (instr_if.ms_riscv32_mp_clk_in),
     .ms_riscv32_mp_rst_in(rst_if.ms_riscv32_mp_rst_in),
     .ms_riscv32_mp_rc_in(rst_if.ms_riscv32_mp_rc_in),

     .ms_riscv32_mp_imaddr_out(instr_if.ms_riscv32_mp_imaddr_out),
     .ms_riscv32_mp_instr_in(instr_if.ms_riscv32_mp_instr_in),
     .ms_riscv32_mp_instr_hready_in(instr_if.ms_riscv32_mp_instr_hready_in),           

     .ms_riscv32_mp_dmaddr_out(data_if.ms_riscv32_mp_dmaddr_out),
     .ms_riscv32_mp_dmdata_out(data_if.ms_riscv32_mp_dmdata_out),
     .ms_riscv32_mp_dmwr_req_out(data_if.ms_riscv32_mp_dmwr_req_out),
     .ms_riscv32_mp_dmwr_mask_out(data_if.ms_riscv32_mp_dmwr_mask_out),
     .ms_riscv32_mp_data_in(data_if.ms_riscv32_mp_data_in),
     .ms_riscv32_mp_data_hready_in(data_if.ms_riscv32_mp_data_hready_in),            
     .ms_riscv32_mp_hresp_in(data_if.ms_riscv32_mp_hresp_in),                  
     .ms_riscv32_mp_data_htrans_out(data_if.ms_riscv32_mp_data_htrans_out),      
     
     .ms_riscv32_mp_eirq_in(irq_if.ms_riscv32_mp_eirq_in),
     .ms_riscv32_mp_tirq_in(irq_if.ms_riscv32_mp_tirq_in),
     .ms_riscv32_mp_sirq_in(irq_if.ms_riscv32_mp_sirq_in)
    );
endmodule


