

module fpga_tb_top();
   reg CLK100MHZ;
    reg fpga_rst;
   reg mcu_rst;

   initial begin
      CLK100MHZ   <=0;
      fpga_rst <=0;
      mcu_rst <=0;
      #15000 fpga_rst <=1;
      mcu_rst <=1;
   end

   always
     begin
        #10 CLK100MHZ <= ~CLK100MHZ;
     end

   system u_system
     (
      .CLK100MHZ(CLK100MHZ),
      .CLK32768KHZ(),

      .fpga_rst(fpga_rst),
      .mcu_rst(mcu_rst),

      .qspi_cs(),
      .qspi_sck(),
      .qspi_dq(),

      .gpio(),

      .mcu_TDO(),
      .mcu_TCK(),
      .mcu_TDI(),
      .mcu_TMS(),

      .pmu_paden(),
      .pmu_padrst(),
      .mcu_wakeup()
      );

endmodule
