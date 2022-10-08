/*******************************************************************************************/
/**                                                                                       **/
/** Copyright 2021 Monte J. Dalrymple                                                     **/
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
/** YRV Alchrity system                                               Rev 0.0  03/30/2020 **/
/**                                                                                       **/
/*******************************************************************************************/
`include "yrv_mcu.v"                                       /* microcontroller              */

module yrv_alchrity (AN_io, C6_brd, C8_brd, C9_brd, C42_brd, C43_brd, C45_brd, C46_brd,
                     DO_brd, L_io, LED_brd, RA_io, RB_io, RC_io, RD_io, RE_io, RF_io, RG_io,
                     RDP_io, SCK_brd, DI_brd, DIP_io, MHZ_100, NMI_brd, RESET_brd, S_io);

  input         C6_brd;                                    /* FPGA board Bank C, pin 6     */
  input         C8_brd;                                    /* FPGA board Bank C, pin 8     */
  input         C9_brd;                                    /* FPGA board Bank C, pin 9     */
  input         DI_brd;                                    /* FPGA board serial input      */
  input         MHZ_100;                                   /* FPGA board clock             */
  input         NMI_brd;                                   /* FPGA board NMI (active-Low)  */
  input         RESET_brd;                                 /* FPGA board reset switch      */
  input   [5:1] S_io;                                      /* IO board switches            */
  input  [24:1] DIP_io;                                    /* IO board DIP switches        */

  output        C42_brd;                                   /* FPGA board Bank C, pin 42    */
  output        C43_brd;                                   /* FPGA board Bank C, pin 43    */
  output        C45_brd;                                   /* FPGA board Bank C, pin 45    */
  output        C46_brd;                                   /* FPGA board Bank C, pin 46    */
  output        DO_brd;                                    /* FPGA board serial output     */
  output        RA_io;                                     /* IO board display seg A       */
  output        RB_io;                                     /* IO board display seg B       */
  output        RC_io;                                     /* IO board display seg C       */
  output        RD_io;                                     /* IO board display seg D       */
  output        RE_io;                                     /* IO board display seg E       */
  output        RF_io;                                     /* IO board display seg F       */
  output        RG_io;                                     /* IO board display seg G       */
  output        RDP_io;                                    /* IO board display DP          */
  output        SCK_brd;                                   /* FPGA board serial clock      */
  output  [4:1] AN_io;                                     /* IO board display enables     */
  output  [7:0] LED_brd;                                   /* FPGA board LEDs              */
  output [24:1] L_io;                                      /* IO board LEDs                */

  /*****************************************************************************************/
  /* signal declarations                                                                   */
  /*****************************************************************************************/
  wire          RA_io,   RB_io,   RC_io,   RD_io;          /* IO board display segments    */
  wire          RE_io,   RF_io,   RG_io,   RDP_io;
  wire          DO_brd,  SCK_brd;                          /* FPGA board serial outputs    */
  wire          C42_brd, C43_brd, C45_brd, C46_brd;        /* FPGA board Bank C outputs    */
  wire    [4:1] AN_io;                                     /* IO board display enables     */
  wire    [7:0] LED_brd;                                   /* FPGA board LEDs              */
  wire   [24:1] L_io;                                      /* IO board LEDs                */

  wire          clk;                                       /* cpu clock                    */
  wire          debug_mode;                                /* in debug mode                */
  wire          ei_req;                                    /* external int request         */
  wire          hz125_lim;                                 /* 20MHZ / 160000 = 125Hz       */
  wire          nmi_req;                                   /* non-maskable interrupt       */
  wire          ser_clk, ser_rxd, ser_txd;                 /* serial port                  */
  wire          resetb;                                    /* master reset                 */
  wire          wfi_state;                                 /* waiting for interrupt        */
  wire   [15:0] port0_reg,  port1_reg;                     /* i/o ports                    */
  wire   [15:0] port2_reg,  port3_reg;
  wire   [15:0] port4_in,   port5_in;

  reg           hz125_lat;                                 /* latched 125Hz pulse          */
  reg     [2:0] mhz20_reg;                                 /* 20MHz divider                */
  reg    [17:0] hz125_reg;                                 /* 125Hz divider                */

  /*****************************************************************************************/
  /* processor                                                                             */
  /*****************************************************************************************/
  yrv_mcu MCU   ( .debug_mode(debug_mode), .port0_reg(port0_reg), .port1_reg(port1_reg),
                  .port2_reg(port2_reg), .port3_reg(port3_reg), .ser_clk(ser_clk),
                  .ser_txd(ser_txd), .wfi_state(wfi_state), .clk(clk), .ei_req(ei_req),
                  .nmi_req(nmi_req), .port4_in(port4_in), .port5_in(port5_in),
                  .resetb(resetb), .ser_rxd(ser_rxd) );

  /*****************************************************************************************/
  /* pin mapping                                                                           */
  /*****************************************************************************************/
  assign AN_io     = {port1_reg[0], port1_reg[1], port1_reg[2], port1_reg[3]};
  assign C46_brd   = port1_reg[11];
  assign C45_brd   = port1_reg[10];
  assign C43_brd   = port1_reg[9];
  assign C42_brd   = port1_reg[8];
  assign DO_brd    = ser_txd;
  assign L_io      = {port3_reg[7:0], port2_reg};
  assign LED_brd   = {port3_reg[13:8], debug_mode, wfi_state};
  assign RDP_io    = port0_reg[7];
  assign RA_io     = port0_reg[6];
  assign RB_io     = port0_reg[5];
  assign RC_io     = port0_reg[4];
  assign RD_io     = port0_reg[3];
  assign RE_io     = port0_reg[2];
  assign RF_io     = port0_reg[1];
  assign RG_io     = port0_reg[0];
  assign SCK_brd   = ser_clk;
  assign port5_in  = {C9_brd, C8_brd, C6_brd, S_io,
                      DIP_io[17], DIP_io[18], DIP_io[19], DIP_io[20],
                      DIP_io[21], DIP_io[22], DIP_io[23], DIP_io[24]};
  assign port4_in  = {DIP_io[9],  DIP_io[10], DIP_io[11], DIP_io[12],
                      DIP_io[13], DIP_io[14], DIP_io[15], DIP_io[16],
                      DIP_io[1],  DIP_io[2],  DIP_io[3],  DIP_io[4],
                      DIP_io[5],  DIP_io[6],  DIP_io[7],  DIP_io[8]};

  /*****************************************************************************************/
  /* special connections                                                                   */
  /*****************************************************************************************/
`ifdef ICE40_VERSION
  SB_GB  CLKBUF  ( .USER_SIGNAL_TO_GLOBAL_BUFFER(mhz20_reg[0]),
                   .GLOBAL_BUFFER_OUTPUT(clk) );
`else
  assign clk       = mhz20_reg[0];
`endif

  assign resetb    = RESET_brd;

  assign nmi_req   = !NMI_brd;
  assign ser_rxd   = DI_brd;

  /*****************************************************************************************/
  /* 100MHz divider                                                                        */
  /*****************************************************************************************/
  always @ (posedge MHZ_100 or negedge resetb) begin
    if (!resetb) mhz20_reg <= 3'h0;
    else         mhz20_reg <= {!mhz20_reg[0], mhz20_reg[2], &mhz20_reg[2:1]};
    end

  /*****************************************************************************************/
  /* 125Hz interrupt                                                                       */
  /*****************************************************************************************/
  assign ei_req    =  hz125_lat;
  assign hz125_lim = (hz125_reg == 18'h270ff);

  always @ (posedge clk or negedge resetb) begin
    if (!resetb) begin
      hz125_reg <= 18'h0;
      hz125_lat <= 1'b0;
      end
    else begin
      hz125_reg <= hz125_lim ? 18'h0 : hz125_reg + 1'b1;
      hz125_lat <= !port3_reg[15] && (hz125_lim || hz125_lat);
      end
    end

  endmodule





