
import tb_pkg::*;

`include "tb.svh"
`include "e203_defines.v"

module tb;

  // leave this
  timeunit 1ps;
  timeprecision 1ps;

///////////////////////////////////////////////////////////////////////////////
// MUT signal declarations
///////////////////////////////////////////////////////////////////////////////
  logic           clk;
  logic           rst_n;

  logic [`E203_ADDR_SIZE-1:0] uart0_apb_paddr;
  logic uart0_apb_pwrite;
  logic uart0_apb_pselx;
  logic uart0_apb_penable;
  logic [`E203_XLEN-1:0] uart0_apb_pwdata;
  logic [`E203_XLEN-1:0] uart0_apb_prdata;

  logic uart0_txd;
  logic uart0_rxd;
  logic uart0_irq;

///////////////////////////////////////////////////////////////////////////////
// TB signal declarations
///////////////////////////////////////////////////////////////////////////////

  logic stim_start, stim_end, end_of_sim, acq_done;
  logic [63:0] num_vectors;
  // string test_name;

  logic mem_rand_en;
  logic inv_rand_en;
  logic io_rand_en;
  logic tlb_rand_en;
  logic exception_en;

  logic [63:0] stim_vaddr;
  logic [63:0] exp_data;
  logic [63:0] exp_vaddr;
  logic stim_push, stim_flush, stim_full;
  logic exp_empty, exp_pop;

  logic dut_out_vld, dut_in_rdy;

  logic                     icb_cmd_valid;
  logic                     icb_cmd_ready;
  logic [32-1:0]            icb_cmd_addr;
  logic                     icb_cmd_read;
  logic [32-1:0]            icb_cmd_wdata;
  logic [4 -1:0]            icb_cmd_wmask;

  logic                     icb_rsp_valid;
  logic                     icb_rsp_ready;
  logic [32-1:0]            icb_rsp_rdata;
  logic                     icb_rsp_err;


  // logic                     icb_cmd_valid;
  // logic                     icb_cmd_ready;
  // logic [32-1:0]            icb_cmd_addr;
  // logic                     icb_cmd_read;
  // logic [32-1:0]            icb_cmd_wdata;
  // logic [4 -1:0]            icb_cmd_wmask;

  // logic                     icb_rsp_valid;
  // logic                     icb_rsp_ready;
  // logic [32-1:0]            icb_rsp_rdata;
  // logic                     icb_rsp_err;

  logic                    success;

///////////////////////////////////////////////////////////////////////////////
// Clock Process
///////////////////////////////////////////////////////////////////////////////

  always @*
    begin
    do begin
      clk = 1;#(CLK_HI);
      clk = 0;#(CLK_LO);
    end while (end_of_sim == 1'b0);
      repeat (100) begin
        // generate a few extra cycle to allow response acquisition to complete
        clk = 1;#(CLK_HI);
        clk = 0;#(CLK_LO);
      end
  end

///////////////////////////////////////////////////////////////////////////////
// Helper tasks
///////////////////////////////////////////////////////////////////////////////

  // prepare tasks...


   task automatic ICB_DW_WR;
      input logic [`E203_ADDR_SIZE - 1:0] addr;
      input logic [3:0]                   cmd;
      input logic [`E203_ADDR_SIZE - 1:0] data;
      output logic                        okay;

      `APPL_WAIT_CYC(clk,1);
      icb_cmd_valid = 0;
      icb_cmd_addr = 0;
      icb_cmd_read = 0;
      icb_cmd_wdata = 0;
      icb_cmd_wmask = 0;

      icb_rsp_ready = 0;
      `APPL_WAIT_CYC(clk,1);
      icb_cmd_valid = 1;
      icb_cmd_addr = addr;

      `APPL_WAIT_CYC(clk,1);
      icb_cmd_read = 1;

      while(~icb_cmd_ready) begin
         `APPL_WAIT_CYC(clk,1)
         // $display("TB> cmd ready  %d", icb_cmd_ready);
      end

      while(icb_cmd_ready) begin
         `APPL_WAIT_CYC(clk,1)
         // $display("TB> cmd ready  %d", icb_cmd_ready);
      end

      `APPL_WAIT_CYC(clk,1);
      icb_cmd_valid = 0;
      icb_cmd_read = 0;

      while(~icb_rsp_valid) begin
         `APPL_WAIT_CYC(clk,1)
         $display("TB> rsp rdata  %X", icb_rsp_rdata);
      end

      // $display("TB> rsp valid  %d", icb_rsp_valid);
      $display("TB> %X %X", addr,icb_rsp_rdata);

    endtask

  // task automatic genRandReq();
  //   automatic bit ok;
  //   automatic logic [63:0] val;
  //   dreq_i.req     = 0;
  //   dreq_i.kill_s1 = 0;
  //   dreq_i.kill_s2 = 0;
  //   num_vectors    = 100000;
  //   stim_end       = 0;

  //   stim_start     = 1;
  //   `APPL_WAIT_CYC(clk_i,10)
  //   stim_start     = 0;

  //   // start with clean cache
  //   flush_i        = 1;
  //   `APPL_WAIT_CYC(clk_i,1)
  //   flush_i        = 0;

  //    while(~acq_done) begin
  //     // randomize request
  //     dreq_i.req = 0;
  //     ok = randomize(val) with {val > 0; val <= 100;};
  //     if (val < SeqRate) begin
  //       dreq_i.req = 1;
  //       // generate random address
  //       ok = randomize(val) with {val >= 0; val < (MemBytes-TlbOffset)>>2;};
  //       dreq_i.vaddr = val<<2;// align to 4Byte
  //       // generate random control events
  //       ok = randomize(val) with {val > 0; val <= 100;};
  //       dreq_i.kill_s1 = (val < S1KillRate);
  //       ok = randomize(val) with {val > 0; val <= 100;};
  //       dreq_i.kill_s2 = (val < S2KillRate);
  //       ok = randomize(val) with {val > 0; val <= 100;};
  //       flush_i = (val < FlushRate);
  //       `APPL_WAIT_SIG(clk_i, dut_in_rdy)
  //     end else begin
  //       `APPL_WAIT_CYC(clk_i,1)
  //     end
  //   end
  //   stim_end       = 1;
  // endtask : genRandReq


  // task automatic genSeqRead();
  //   automatic bit ok;
  //   automatic logic [63:0] val;
  //   automatic logic [63:0] addr;
  //   dreq_i.req     = 0;
  //   dreq_i.kill_s1 = 0;
  //   dreq_i.kill_s2 = 0;
  //   num_vectors    = 32*4*1024;
  //   addr           = 0;
  //   stim_end       = 0;

  //   stim_start     = 1;
  //   `APPL_WAIT_CYC(clk_i,10)
  //   stim_start     = 0;

  //   // start with clean cache
  //   flush_i        = 1;
  //   `APPL_WAIT_CYC(clk_i,1)
  //   flush_i        = 0;

  //   while(~acq_done) begin
  //     dreq_i.req = 1;
  //     dreq_i.vaddr = addr;
  //     // generate linear read
  //     addr = (addr + 4) % (MemBytes - TlbOffset);
  //     `APPL_WAIT_SIG(clk_i, dut_in_rdy)
  //   end
  //   stim_end       = 1;
  // endtask : genSeqRead


///////////////////////////////////////////////////////////////////////////////
// MUT
///////////////////////////////////////////////////////////////////////////////


sirv_gnrl_icb2apb # (
  .AW   (32),
  .DW   (`E203_XLEN)
) u_uart0_apb_icb2apb(
    .i_icb_cmd_valid (icb_cmd_valid),
    .i_icb_cmd_ready (icb_cmd_ready),
    .i_icb_cmd_addr  (icb_cmd_addr ),
    .i_icb_cmd_read  (icb_cmd_read ),
    .i_icb_cmd_wdata (icb_cmd_wdata),
    .i_icb_cmd_wmask (icb_cmd_wmask),
    .i_icb_cmd_size  (),

    .i_icb_rsp_valid (icb_rsp_valid),
    .i_icb_rsp_ready (icb_rsp_ready),
    .i_icb_rsp_rdata (icb_rsp_rdata),
    .i_icb_rsp_err   (icb_rsp_err),

    .apb_paddr     (uart0_apb_paddr  ),
    .apb_pwrite    (uart0_apb_pwrite ),
    .apb_pselx     (uart0_apb_pselx  ),
    .apb_penable   (uart0_apb_penable),
    .apb_pwdata    (uart0_apb_pwdata ),
    .apb_prdata    (uart0_apb_prdata ),

    .clk           (clk  ),
    .rst_n         (rst_n)
  );

   apb_uart u_apb_uart0_top (
                        .CLK     ( clk ),
                        .RSTN    ( rst_n ),
                        .PSEL    ( uart0_apb_pselx ),
                        .PENABLE ( uart0_apb_penable ),
                        .PWRITE  ( uart0_apb_pwrite ),
                        .PADDR   ( uart0_apb_paddr[2:0] ),
                        .PWDATA  ( uart0_apb_pwdata ),
                        .PRDATA  ( uart0_apb_prdata ),
                        .PREADY  (),
                        .PSLVERR (),
                        .INT     ( uart0_irq ),
                        .OUT1N   (), // keep open
                        .OUT2N   (), // keep open
                        .RTSN    (), // no flow control
                        .DTRN    (), // no flow control
                        .CTSN    ( 1'b0 ),
                        .DSRN    ( 1'b0 ),
                        .DCDN    ( 1'b0 ),
                        .RIN     ( 1'b0 ),
                        .SIN     ( uart0_rxd ),
                        .SOUT    ( uart0_txd )
                        );


  initial   // process runs just once
  begin : p_stim
    end_of_sim       = 0;
    num_vectors      = 0;
    stim_start       = 0;
    stim_end         = 0;

    clk             = 0;
    rst_n           = 0;

    icb_cmd_valid = 0;
    icb_cmd_addr = 0;
    icb_cmd_read = 0;
    icb_cmd_wdata = 0;
    icb_cmd_wmask = 0;

    icb_rsp_ready = 0;


    // print some info
    $display("TB> current configuration:");
    // $display("TB> MemWords       %d",   MemWords);
    // $display("TB> CachedAddrBeg  %16X", CachedAddrBeg);
    // $display("TB> TlbRandHitRate %d",   TlbRandHitRate);
    // $display("TB> MemRandHitRate %d",   MemRandHitRate);
    // $display("TB> MemRandInvRate %d",   MemRandInvRate);
    // $display("TB> S1KillRate     %d",   S1KillRate);
    // $display("TB> S2KillRate     %d",   S2KillRate);
    // $display("TB> FlushRate      %d",   FlushRate);

    // `APPL_WAIT_CYC(clk,100);
    // $display("TB> choose TLB offset  %16X", TlbOffset);

    // reset cycles
    `APPL_WAIT_CYC(clk,100);
    rst_n        = 1'b1;
    `APPL_WAIT_CYC(clk,100);

    $display("TB> stimuli application started");
    // apply each test until NUM_ACCESSES memory
    // requests have successfully completed
    ///////////////////////////////////////////////
    // TEST 0
    ICB_DW_WR(32'h10013005, 4'h7, 32'h00000000, success);

    `APPL_WAIT_CYC(clk,40);
    ///////////////////////////////////////////////
    // TEST 1
    // test_name = "TEST1, enabled cache";
    // en_i = 1;
    // genRandReq();
    // `APPL_WAIT_CYC(clk,40);
    // ///////////////////////////////////////////////
    // // TEST 2
    // test_name = "TEST2, enabled cache, sequential reads";
    // en_i        = 1;
    // genSeqRead();
    // `APPL_WAIT_CYC(clk,40);
    // ///////////////////////////////////////////////
    // // TEST 3
    // test_name = "TEST3, enabled cache, random stalls in mem and TLB side";
    // en_i        = 1;
    // mem_rand_en = 1;
    // tlb_rand_en = 1;
    // genRandReq();
    // `APPL_WAIT_CYC(clk,40);
    // ///////////////////////////////////////////////
    // // TEST 4
    // test_name = "TEST4, +random invalidations";
    // en_i        = 1;
    // mem_rand_en = 1;
    // tlb_rand_en = 1;
    // inv_rand_en = 1;
    // genRandReq();
    // `APPL_WAIT_CYC(clk_i,40);
    ///////////////////////////////////////////////
    end_of_sim = 1;
    $display("TB> stimuli application ended");
  end

///////////////////////////////////////////////////////////////////////////////
// stimuli acquisition process
///////////////////////////////////////////////////////////////////////////////

  // assign dut_out_vld = dreq_o.valid;

  // initial   // process runs just once
  // begin : p_acq

  //   bit ok;
  //   progress status;
  //   string failingTests, tmpstr;
  //   int    n;

  //   status       = new();
  //   failingTests = "";
  //   acq_done     = 0;

  //   ///////////////////////////////////////////////
  //   // loop over tests
  //   n=0;
  //   while (~end_of_sim) begin
  //     // wait for stimuli application
  //     `ACQ_WAIT_SIG(clk_i, stim_start);
  //     $display("TB: ----------------------------------------------------------------------\n");
  //     $display("TB> %s", test_name);

  //     status.reset(num_vectors);
  //     acq_done = 0;
  //     for (int k=0;k<num_vectors;k++) begin

  //       // wait for response
  //       `ACQ_WAIT_SIG(clk_i, dut_out_vld);

  //       ok=(dreq_o.data == exp_data[FETCH_WIDTH-1:0]) && (dreq_o.vaddr == exp_vaddr);

  //       if(!ok) begin
  //         tmpstr =
  //         $psprintf("vector: %02d - %06d -- exp_vaddr: %16X -- act_vaddr : %16X -- exp_data: %08X -- act_data: %08X",
  //           n, k, exp_vaddr, dreq_o.vaddr, exp_data[FETCH_WIDTH-1:0], dreq_o.data);
  //         failingTests = $psprintf("%sTB: %s\n", failingTests, tmpstr);
  //         $display("TB> %s", tmpstr);
  //       end
  //       status.addRes(!ok);
  //       status.print();
  //     end
  //     acq_done = 1;
  //     n++;
  //     // wait for stimuli application end
  //     `ACQ_WAIT_SIG(clk_i, stim_end);
  //     `ACQ_WAIT_CYC(clk_i,100);
  //   end
  //   ///////////////////////////////////////////////

  //   status.printToFile("summary.rep", 1);

  //   if(status.totErrCnt == 0) begin
  //     $display("TB: ----------------------------------------------------------------------\n");
  //     $display("TB: PASSED %0d VECTORS", status.totAcqCnt);
  //     $display("TB: ----------------------------------------------------------------------\n");
  //   end else begin
  //     $display("TB: ----------------------------------------------------------------------\n");
  //     $display("TB: FAILED %0d OF %0d VECTORS\n", status.totErrCnt, status.totAcqCnt);
  //     $display("TB: failing tests:");
  //     $display("%s", failingTests);
  //     $display("TB: ----------------------------------------------------------------------\n");
  //   end
  // end

endmodule
