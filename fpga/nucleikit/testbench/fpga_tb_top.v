`timescale 1ns/10ps

module fpga_tb_top();
   reg CLK100MHZ;
   wire CLK32768KHZ;
   reg fpga_rst;
   reg mcu_rst;
   wire qspi_cs;
   wire qspi_sck;
   wire [3:0]qspi_dq;

   initial begin
      CLK100MHZ <= 0;
      fpga_rst <= 0;
      mcu_rst <= 0;
      #15000 fpga_rst <= 1;
      mcu_rst <= 1;
   end

   always
     begin
        #5 CLK100MHZ <= ~CLK100MHZ;
     end

   // always
   //   begin
   //      // #15259 CLK32768KHZ <= ~CLK32768KHZ;
   //      #20 CLK32768KHZ <= ~CLK32768KHZ;
   //   end

   wire clk_8388;
   wire mmcm_locked;
   wire resetn = fpga_rst & mcu_rst;

   mmcm u_mmcm
     (
      .resetn(resetn),
      .clk_in1(CLK100MHZ),
      .clk_out1(clk_8388),
      .locked(mmcm_locked)
      );


   clkdivider u_clkdivider
     (
      .clk(clk_8388),
      .reset(~resetn),
      .clk_out(CLK32768KHZ)
      );

   system u_system
     (
      .CLK100MHZ(CLK100MHZ),
      .CLK32768KHZ(CLK32768KHZ),

      .fpga_rst(fpga_rst),
      .mcu_rst(mcu_rst),

      .qspi_cs(qspi_cs),
      .qspi_sck(qspi_sck),
      .qspi_dq(qspi_dq),

      .gpio(),

      .mcu_TDO(),
      .mcu_TCK(),
      .mcu_TDI(),
      .mcu_TMS(),

      .pmu_paden(),
      .pmu_padrst(),
      .mcu_wakeup()
      );

   W25Q32JVxxIM u_w25q32jvm(
                            .CSn(qspi_cs),
                            .CLK(qspi_sck),
                            .DIO(qspi_dq[0]),
                            .DO(qspi_dq[1]),
                            .WPn(qspi_dq[2]),
                            .HOLDn(qspi_dq[3]),
                            .RESETn(resetn));

endmodule
