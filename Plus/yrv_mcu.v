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
/** YRV simple mcu system                                             Rev 0.0  03/29/2021 **/
/**                                                                                       **/
/*******************************************************************************************/
`define INSTANCE_MEM

`define IO_BASE   16'hffff                                 /* msword of i/o address        */
`define IO_PORT10 14'h0000                                 /* lsword of port 1/0 address   */
`define IO_PORT32 14'h0001                                 /* lsword of port 3/2 address   */
`define IO_PORT54 14'h0002                                 /* lsword of port 5/4 address   */
`define IO_PORT76 14'h0003                                 /* lsword of port 7/6 address   */
`define MEM_BASE  16'h0000                                 /* msword of mem address        */

`include "yrv_top.v"                                       /* processor                    */
`include "serial_rx.v"                                     /* serial receive               */
`include "serial_tx.v"                                     /* serial transmit              */
`include "serial_top.v"                                    /* serial port                  */

`ifdef INSTANCE_MEM
`include "inst_mem.v"                                      /* instantiated memory          */
`endif

module yrv_mcu  (debug_mode, port0_reg, port1_reg, port2_reg, port3_reg, ser_clk, ser_txd,
                 wfi_state, clk, ei_req, nmi_req, port4_in, port5_in, resetb, ser_rxd);

  input         clk;                                       /* cpu clock                    */
  input         ei_req;                                    /* external int request         */
  input         nmi_req;                                   /* non-maskable interrupt       */
  input         resetb;                                    /* master reset                 */
  input         ser_rxd;                                   /* receive data input           */
  input  [15:0] port4_in;                                  /* port 4                       */
  input  [15:0] port5_in;                                  /* port 5                       */

  output        debug_mode;                                /* in debug mode                */
  output        ser_clk;                                   /* serial clk output (cks mode) */
  output        ser_txd;                                   /* transmit data output         */
  output        wfi_state;                                 /* waiting for interrupt        */
  output [15:0] port0_reg;                                 /* port 0                       */
  output [15:0] port1_reg;                                 /* port 1                       */
  output [15:0] port2_reg;                                 /* port 2                       */
  output [15:0] port3_reg;                                 /* port 3                       */

  /*****************************************************************************************/
  /* signal declarations                                                                   */
  /*****************************************************************************************/
  wire          bufr_done;                                 /* serial tx done sending       */
  wire          bufr_empty;                                /* serial tx buffer empty       */
  wire          bufr_full;                                 /* serial rx buffer full        */
  wire          bufr_ovr;                                  /* serial rx buffer overrun     */
  wire          bus_32;                                    /* 32-bit bus select            */
  wire          debug_mode;                                /* in debug mode                */
  wire          ld_wdata;                                  /* serial port write            */
  wire          mem_ready;                                 /* memory ready                 */
  wire          mem_write;                                 /* memory write enable          */
  wire          port10_dec, port32_dec;                    /* i/o port decodes             */
  wire          port54_dec, port76_dec;
  wire          rd_rdata;                                  /* serial port read             */
  wire          ser_clk;                                   /* serial clk output (cks mode) */
  wire          ser_txd;                                   /* transmit data output         */
  wire          wfi_state;                                 /* waiting for interrupt        */
  wire    [1:0] mem_trans;                                 /* memory transfer type         */
  wire    [3:0] mem_ble;                                   /* memory byte lane enables     */
  wire    [7:0] rx_rdata;                                  /* receive data buffer          */
  wire   [15:0] li_req;                                    /* local int requests           */
  wire   [15:0] port7_dat;                                 /* i/o port                     */
  wire   [31:0] mcu_rdata;                                 /* system memory read data      */
  wire   [31:0] mem_addr;                                  /* memory address               */
  wire   [31:0] mem_wdata;                                 /* memory write data            */

  reg           io_rd_reg;                                 /* i/o read                     */
  reg           io_wr_reg;                                 /* i/o write                    */
  reg           mem_rd_reg;                                /* mem read                     */
  reg           mem_wr_reg;                                /* mem write                    */
  reg     [3:0] mem_ble_reg;                               /* reg'd memory byte lane en    */
  reg    [15:0] port0_reg,  port1_reg;                     /* i/o ports                    */
  reg    [15:0] port2_reg,  port3_reg;
  reg    [15:0] port4_reg,  port5_reg;
  reg    [15:0] port6_reg;
  reg    [15:0] mem_addr_reg;                              /* reg'd memory address         */

`ifdef INSTANCE_MEM
  wire   [31:0] mem_rdata;                                 /* raw read data                */
`else
  wire    [3:0] mem_wr_byte;                               /* system ram byte enables      */
  reg     {7:0] mcu_mem [0:4095];                          /* system ram                   */
  reg    [31:0] mem_rdata;                                 /* raw read data                */
`endif

  /*****************************************************************************************/
  /* 32-bit bus, no wait states, internal local interrupts                                 */
  /*****************************************************************************************/
  assign bus_32    = 1'b1;
  assign mem_ready = 1'b1;
  assign li_req    = {12'h0, bufr_empty, bufr_done, bufr_full, bufr_ovr};

  /*****************************************************************************************/
  /* processor                                                                             */
  /*****************************************************************************************/
  yrv_top YRV     ( .csr_achk(), .csr_addr(), .csr_read(), .csr_wdata(), .csr_write(),
                    .debug_mode(debug_mode), .ebrk_inst(), .mem_addr(mem_addr),
                    .mem_ble(mem_ble), .mem_lock(), .mem_trans(mem_trans),
                    .mem_wdata(mem_wdata), .mem_write(mem_write), .timer_en(),
                    .wfi_state(wfi_state), .brk_req(1'b0), .bus_32(bus_32), .clk(clk),
                    .csr_ok_ext(1'b0), .csr_rdata(32'h0), .dbg_req(1'b0),
                    .dresetb(resetb), .ei_req(ei_req), .halt_reg(1'b0), .hw_id(10'h0),
                    .li_req(li_req), .mem_rdata(mcu_rdata), .mem_ready(mem_ready),
                    .nmi_req(nmi_req), .resetb(resetb), .sw_req(1'b0), .timer_match(1'b0),
                    .timer_rdata(64'h0) );

  /*****************************************************************************************/
  /* 32-bit memory (currently 1k x 32)                                                     */
  /*****************************************************************************************/
`ifdef INSTANCE_MEM
  inst_mem MEM    ( .mem_rdata(mem_rdata), .clk(clk), .mem_addr(mem_addr[15:0]),
                    .mem_addr_reg(mem_addr_reg),.mem_ble_reg(mem_ble_reg),
                    .mem_ready(mem_ready), .mem_trans(mem_trans), .mem_wdata(mem_wdata),
                    .mem_wr_reg(mem_wr_reg) );
`else
  assign mem_wr_byte = {4{mem_wr_reg}} & mem_ble_reg & {4{mem_ready}};

  always @ (posedge clk) begin
    if (mem_trans[0]) begin
      mem_rdata[31:24] <= mcu_mem[{mem_addr[11:2], 2'b11}];
      mem_rdata[23:16] <= mcu_mem[{mem_addr[11:2], 2'b10}];
      mem_rdata[15:8]  <= mcu_mem[{mem_addr[11:2], 2'b01}];
      mem_rdata[7:0]   <= mcu_mem[{mem_addr[11:2], 2'b00}];
      end
    if (mem_wr_byte[3]) mcu_mem[{mem_addr_reg[11:2], 2'b11}] <= mem_wdata[31:24];
    if (mem_wr_byte[2]) mcu_mem[{mem_addr_reg[11:2], 2'b10}] <= mem_wdata[23:16];
    if (mem_wr_byte[1]) mcu_mem[{mem_addr_reg[11:2], 2'b01}] <= mem_wdata[15:8];
    if (mem_wr_byte[0]) mcu_mem[{mem_addr_reg[11:2], 2'b00}] <= mem_wdata[7:0];
    end

initial $readmemh("code_demo.mem", mcu_mem);

`endif

  /*****************************************************************************************/
  /* bus interface                                                                         */
  /*****************************************************************************************/
  always @ (posedge clk or negedge resetb) begin
    if (!resetb) begin
      mem_addr_reg <= 16'h0;
      mem_ble_reg  <=  4'h0;
      io_rd_reg    <=  1'b0;
      io_wr_reg    <=  1'b0;
      mem_rd_reg   <=  1'b0;
      mem_wr_reg   <=  1'b0;
      end
    else if (mem_ready) begin
      mem_addr_reg <= mem_addr[15:0];
      mem_ble_reg  <= mem_ble;
      io_rd_reg    <= !mem_write &&  mem_trans[0] && (mem_addr[31:16] == `IO_BASE);
      io_wr_reg    <=  mem_write && &mem_trans    && (mem_addr[31:16] == `IO_BASE);
      mem_rd_reg   <= !mem_write &&  mem_trans[0] && (mem_addr[31:16] == `MEM_BASE);
      mem_wr_reg   <=  mem_write && &mem_trans    && (mem_addr[31:16] == `MEM_BASE);
      end
    end

  assign port10_dec = (mem_addr_reg[15:2] == `IO_PORT10);
  assign port32_dec = (mem_addr_reg[15:2] == `IO_PORT32);
  assign port54_dec = (mem_addr_reg[15:2] == `IO_PORT54);
  assign port76_dec = (mem_addr_reg[15:2] == `IO_PORT76);

  assign mcu_rdata  = (mem_rd_reg) ? mem_rdata              :
                      (port10_dec) ? {port1_reg, port0_reg} :
                      (port32_dec) ? {port3_reg, port2_reg} :
                      (port54_dec) ? {port5_reg, port4_reg} :
                      (port76_dec) ? {port7_dat, port6_reg} : 32'h0;

  /*****************************************************************************************/
  /* parallel ports                                                                        */
  /*****************************************************************************************/
  always @ (posedge clk or negedge resetb) begin
    if (!resetb) begin
      port0_reg <= 16'h0;
      port1_reg <= 16'h0;
      port2_reg <= 16'h0;
      port3_reg <= 16'h0;
      port4_reg <= 16'h0;
      port5_reg <= 16'h0;
      port6_reg <= 16'h0;
      end
    else begin
      if (io_wr_reg && port10_dec && mem_ready) begin
        if (mem_ble_reg[3]) port1_reg[15:8] <= mem_wdata[31:24];
        if (mem_ble_reg[2]) port1_reg[7:0]  <= mem_wdata[23:16];
        if (mem_ble_reg[1]) port0_reg[15:8] <= mem_wdata[15:8];
        if (mem_ble_reg[0]) port0_reg[7:0]  <= mem_wdata[7:0];
        end
      if (io_wr_reg && port32_dec && mem_ready) begin
        if (mem_ble_reg[3]) port3_reg[15:8] <= mem_wdata[31:24];
        if (mem_ble_reg[2]) port3_reg[7:0]  <= mem_wdata[23:16];
        if (mem_ble_reg[1]) port2_reg[15:8] <= mem_wdata[15:8];
        if (mem_ble_reg[0]) port2_reg[7:0]  <= mem_wdata[7:0];
        end
      port4_reg <= port4_in;
      port5_reg <= port5_in;
      if (io_wr_reg && port76_dec && mem_ready) begin
        if (mem_ble_reg[1]) port6_reg[15:8] <= mem_wdata[15:8];
        if (mem_ble_reg[0]) port6_reg[7:0]  <= mem_wdata[7:0];
        end
      end
    end

  /*****************************************************************************************/
  /* serial port                                                                           */
  /*****************************************************************************************/
  serial_top SERIAL ( .bufr_done(bufr_done), .bufr_empty(bufr_empty), .bufr_full(bufr_full),
                      .bufr_ovr(bufr_ovr), .rx_rdata(rx_rdata), .ser_clk(ser_clk),
                      .ser_txd(ser_txd), .cks_mode(port6_reg[0]), .clkp(clk),
                      .div_rate(port6_reg[15:4]), .ld_wdata(ld_wdata), .rd_rdata(rd_rdata),
                      .s_reset(port6_reg[3]), .ser_rxd(ser_rxd), .tx_wdata(mem_wdata[7:0]) );

  assign ld_wdata  = io_wr_reg && port76_dec && mem_ble_reg[2] && mem_ready;
  assign rd_rdata  = io_rd_reg && port76_dec && mem_ble_reg[2] && mem_ready;
  assign port7_dat = {4'h0, bufr_empty, bufr_done, bufr_full, bufr_ovr, rx_rdata};

  endmodule





