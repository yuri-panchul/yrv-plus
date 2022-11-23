//--------------------------------------------------------------------------------------
//
// Copyright 2021 Monte J. Dalrymple
// Copyright 2021 Systemyde International Corporation
// Copyright 2022 Yuri Panchul
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may not use
// this file except in compliance with the License, or, at your option, the Apache
// License version 2.0. You may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//
// YRV processor test bench                                          Rev 0.0  02/08/2021
// YRV simple mcu system                                             Rev 0.0  03/29/2021
// YRV board-agnostic tb with cycle-accurate simulation, no #delays  Rev 0.0  10/08/2022
//
//--------------------------------------------------------------------------------------

`timescale 1 ns / 100 ps

`define CLK_FREQUENCY (50 * 1000 * 1000)

`include "yrv_mcu.v"

module tb_yrv_mcu;

  logic        clk;          // cpu clock
  logic        ei_req;       // external int request
  logic        nmi_req;      // non-maskable interrupt
  logic        resetb;       // master reset
  logic        ser_rxd;      // receive data input
  logic [15:0] port4_in;     // port 4
  logic [15:0] port5_in;     // port 5

  wire         debug_mode;   // in debug mode
  wire         ser_clk;      // serial clk output (cks mode)
  wire         ser_txd;      // transmit data output
  wire         wfi_state;    // waiting for interrupt
  wire  [15:0] port0_reg;    // port 0
  wire  [15:0] port1_reg;    // port 1
  wire  [15:0] port2_reg;    // port 2
  wire  [15:0] port3_reg;    // port 3

  wire         mem_ready;    // memory ready
  wire  [31:0] mem_rdata;    // memory read data
  wire         mem_lock;     // memory lock (rmw)
  wire         mem_write;    // memory write enable
  wire   [1:0] mem_trans;    // memory transfer type
  wire   [3:0] mem_ble;      // memory byte lane enables
  wire  [31:0] mem_addr;     // memory address
  wire  [31:0] mem_wdata;    // memory write data

  wire  [31:0] extra_debug_data;

  `ifdef BOOT_FROM_AUX_UART
  logic        aux_uart_rx;  // auxiliary uart receive pin
  `endif

  yrv_mcu i_yrv_mcu (.*);

  //------------------------------------------------------------------------------------

  // The design is supposed to run with the frequency 50 MHz,
  // i.e. the period is 20 ns

  initial
  begin
    clk = '0;
    forever # 10 clk = ~ clk;
  end

  //------------------------------------------------------------------------------------

  task init;

    ei_req      <= '0;  // external int request
    nmi_req     <= '0;  // non-maskable interrupt
    ser_rxd     <= '0;  // receive data input
    port4_in    <= '0;  // port 4
    port5_in    <= '0;  // port 5

    `ifdef BOOT_FROM_AUX_UART
    aux_uart_rx <= '0;  // auxiliary uart receive pin
    `endif

  endtask

  //------------------------------------------------------------------------------------

  task reset;

    resetb <= 'x;
    repeat (10) @ (posedge clk);
    resetb <= '0;
    repeat (10) @ (posedge clk);
    resetb <= '1;

  endtask

  //------------------------------------------------------------------------------------

  initial
  begin
    `ifdef __ICARUS__
      $dumpvars;
    `endif

    init;
    reset;

    for (int i = 0; i < 1000; i ++)
    begin
      ei_req   <= ((i + 1) % 100 == 0);  // external int request
      nmi_req  <= ((i + 1) % 333 == 0);  // non-maskable interrupt

      if (0)
      begin
      ser_rxd  <= $urandom ();     // receive data input
      port4_in <= $urandom ();     // port 4
      port5_in <= $urandom ();     // port 5
      end

      @ (posedge clk);
    end

    `ifdef MODEL_TECH  // Mentor ModelSim and Questa
      $stop;
    `else
      $finish;
    `endif
  end

endmodule

`ifdef OLD
/*******************************************************************************************/
/**                                                                                       **/
/** Copyright 2021 Systemyde International Corporation                                    **/
/**                                                                                       **/
/** SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1                                      **/
/**                                                                                       **/
/** Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use  **/
/** this file except in compliance with the License, or, at your option, the Apache       **/
/** License version 2.0. You may obtain a copy of the License at                          **/
/**                                                                                       **/
/** https://solderpad.org/licenses/SHL-2.1/                                               **/
/**                                                                                       **/
/** Unless required by applicable law or agreed to in writing, any work distributed under **/
/** the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF   **/
/** ANY KIND, either express or implied. See the License for the specific language        **/
/** governing permissions and limitations under the License.                              **/
/**                                                                                       **/
/** YRV processor test bench                                          Rev 0.0  02/08/2021 **/
/**                                                                                       **/
/*******************************************************************************************/
/* set time scale                                                                          */
`timescale 1ns / 10ps

/* top level                                                                               */
`include "yrv_alchrity.v"

module testbench;

  wire          C42_brd;                                   /* FPGA board Bank C, pin 42    */
  wire          C43_brd;                                   /* FPGA board Bank C, pin 43    */
  wire          C45_brd;                                   /* FPGA board Bank C, pin 45    */
  wire          C46_brd;                                   /* FPGA board Bank C, pin 46    */
  wire          DO_brd;                                    /* FPGA board serial wire     */
  wire          RA_io;                                     /* IO board display seg A       */
  wire          RB_io;                                     /* IO board display seg B       */
  wire          RC_io;                                     /* IO board display seg C       */
  wire          RD_io;                                     /* IO board display seg D       */
  wire          RE_io;                                     /* IO board display seg E       */
  wire          RF_io;                                     /* IO board display seg F       */
  wire          RG_io;                                     /* IO board display seg G       */
  wire          RDP_io;                                    /* IO board display DP          */
  wire          SCK_brd;                                   /* FPGA board serial clock      */
  wire    [4:1] AN_io;                                     /* IO board display enables     */
  wire    [7:0] LED_brd;                                   /* FPGA board LEDs              */
  wire   [24:1] L_io;                                      /* IO board LEDs                */

  reg           C6_brd;                                    /* FPGA board Bank C, pin 6     */
  reg           C8_brd;                                    /* FPGA board Bank C, pin 8     */
  reg           C9_brd;                                    /* FPGA board Bank C, pin 9     */
  reg           DI_brd;                                    /* FPGA board serial reg        */
  reg           MHZ_100;                                   /* FPGA board clock             */
  reg           NMI_brd;                                   /* FPGA board NMI (active-Low)  */
  reg           RESET_brd;                                 /* FPGA board reset switch      */
  reg     [5:1] S_io;                                      /* IO board switches            */
  reg    [24:1] DIP_io;                                    /* IO board DIP switches        */

  /*****************************************************************************************/
  /* testbench housekeeping                                                                */
  /*****************************************************************************************/
  reg           TREF0, TREF1, TREF2, TREF3, TREF4;         /* timing generator             */
  reg           TREF5, TREF6, TREF7, TREF8, TREF9;

  /*****************************************************************************************/
  /* initialize inputs                                                                     */
  /*****************************************************************************************/
  initial begin
    C6_brd      <= 1'b0;                                   /* FPGA board Bank C, pin 6     */
    C8_brd      <= 1'b0;                                   /* FPGA board Bank C, pin 8     */
    C9_brd      <= 1'b0;                                   /* FPGA board Bank C, pin 9     */
    DI_brd      <= 1'b0;                                   /* FPGA board serial reg        */
    MHZ_100     <= 1'b0;                                   /* FPGA board clock             */
    NMI_brd     <= 1'b0;                                   /* FPGA board NMI (active-Low)  */
    RESET_brd   <= 1'b1;                                   /* FPGA board reset switch      */
    S_io        <= 5'h0;                                   /* IO board switches            */
    DIP_io      <= 24'h0;                                  /* IO board DIP switches        */
    end

  /*****************************************************************************************/
  /* timing generator                                                                      */
  /*****************************************************************************************/
  initial begin
    TREF0 <= 1'b1;
    TREF1 <= 1'b0;
    TREF2 <= 1'b0;
    TREF3 <= 1'b0;
    TREF4 <= 1'b0;
    TREF5 <= 1'b0;
    TREF6 <= 1'b0;
    TREF7 <= 1'b0;
    TREF8 <= 1'b0;
    TREF9 <= 1'b0;
    end

  always begin
    #1 TREF0 <= 1'b0;
       TREF1 <= 1'b1;
    #1 TREF1 <= 1'b0;
       TREF2 <= 1'b1;
    #1 TREF2 <= 1'b0;
       TREF3 <= 1'b1;
    #1 TREF3 <= 1'b0;
       TREF4 <= 1'b1;
    #1 TREF4 <= 1'b0;
       TREF5 <= 1'b1;
    #1 TREF5 <= 1'b0;
       TREF6 <= 1'b1;
    #1 TREF6 <= 1'b0;
       TREF7 <= 1'b1;
    #1 TREF7 <= 1'b0;
       TREF8 <= 1'b1;
    #1 TREF8 <= 1'b0;
       TREF9 <= 1'b1;
    #1 TREF9 <= 1'b0;
       TREF0 <= 1'b1;
    end

  always @ (posedge TREF3) MHZ_100 = 0;
  always @ (posedge TREF8) MHZ_100 = 1;

  /*****************************************************************************************/
  /* instantiate the design                                                                */
  /*****************************************************************************************/
  yrv_alchrity YRV ( .AN_io(AN_io), .C6_brd(C6_brd), .C8_brd(C8_brd), .C9_brd(C9_brd),
                     .C42_brd(C42_brd), .C43_brd(C43_brd), .C45_brd(C45_brd),
                     .C46_brd(C46_brd), .DO_brd(DO_brd), .L_io(L_io), .LED_brd(LED_brd),
                     .RA_io(RA_io), .RB_io(RB_io), .RC_io(RC_io), .RD_io(RD_io),
                     .RE_io(RE_io), .RF_io(RF_io), .RG_io(RG_io), .RDP_io(RDP_io),
                     .SCK_brd(SCK_brd), .DI_brd(DI_brd), .DIP_io(DIP_io), .MHZ_100(MHZ_100),
                     .NMI_brd(NMI_brd), .RESET_brd(RESET_brd), .S_io(S_io) );

  /*****************************************************************************************/
  /* test tasks                                                                            */
  /*****************************************************************************************/
  task resettask;
    begin
      wait(TREF6);
      RESET_brd = 0;
      wait(TREF0);
      wait(TREF6);
      wait(TREF0);
      wait(TREF6);
      RESET_brd = 1;
      wait(TREF0);
      end
    endtask

  /*****************************************************************************************/
  /* run the test patterns                                                                 */
  /*****************************************************************************************/
  initial begin
    `ifdef __ICARUS__
      $dumpvars;
    `endif

    resettask;
    // $readmemh("clock_rom.vm", YRV.MCU.mcu_mem);

    fork
      begin
        wait (C46_brd);
      end
      begin
        repeat (1000) @ (posedge MHZ_100);
        $display ("!!! TIMEOUT !!!");
        disable fork;
      end
    join_any

    `ifdef MODEL_TECH  // Mentor ModelSim and Questa
      $stop;
    `else
      $finish;
    `endif
    end

  endmodule
`endif
