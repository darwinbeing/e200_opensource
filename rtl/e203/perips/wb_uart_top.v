module wb_uart_top(
  input        clk,
  input        rst_n,

  // Internal wishbone connections
  input        i_wb_cyc,
  input        i_wb_stb,
  input        i_wb_we,
  input [2:0]  i_wb_addr,
  input [7:0]  i_wb_data,

  // Wishbone return values
  output       o_wb_ack,
  output [7:0] o_wb_data,
  output       o_uart_int,

  output       o_uart_txd,
  input        i_uart_rxd
);

   wire           rclk;
   wire           baudoutn;

   assign rclk = baudoutn;

   uart_16750 u_uart (.CLK(clk),
                      .RST(~rst_n),
                      .BAUDCE(1'b1),
                      .WB_CYC(i_wb_cyc),
                      .WB_STB(i_wb_stb),
                      .WB_WE(i_wb_we),
                      .WB_ADR(i_wb_addr),
                      .WB_DIN(i_wb_data),
                      .WB_DOUT(o_wb_data),
                      .WB_ACK(o_wb_ack),
                      .INT(o_uart_int),
                      .OUT1N(),
                      .OUT2N(),
                      .RCLK(rclk),
                      .BAUDOUTN(baudoutn),
                      .RTSN(),
                      .DTRN(),
                      .CTSN(),
                      .DSRN(),
                      .DCDN(),
                      .RIN(),
                      .SIN(i_uart_rxd),
                      .SOUT(o_uart_txd));

endmodule
