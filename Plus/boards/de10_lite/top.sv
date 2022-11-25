`define INTEL_VERSION
`define CLK_FREQUENCY (50 * 1000 * 1000)

`include "yrv_mcu.v"

module top
(
  input           adc_clk_10,
  input           max10_clk1_50,
  input           max10_clk2_50,

  input   [ 1:0]  key,
  input   [ 9:0]  sw,
  output  [ 9:0]  led,

  output  [ 7:0]  hex0,
  output  [ 7:0]  hex1,
  output  [ 7:0]  hex2,
  output  [ 7:0]  hex3,
  output  [ 7:0]  hex4,
  output  [ 7:0]  hex5,

  output          vga_hs,
  output          vga_vs,
  output  [ 3:0]  vga_r,
  output  [ 3:0]  vga_g,
  output  [ 3:0]  vga_b,

  inout   [35:0]  gpio
);

  //--------------------------------------------------------------------------
  // Unused pins

  assign vga_hs = '0;
  assign vga_vs = '0;
  assign vga_r  = '0;
  assign vga_g  = '0;
  assign vga_b  = '0;

  //--------------------------------------------------------------------------
  // Clock and reset

  wire clk   = max10_clk1_50;
  wire reset = sw [9];

  //--------------------------------------------------------------------------
  // MCU clock

  wire slow_clk_mode = sw [0];

  logic [22:0] clk_cnt;

  always @ (posedge clk or posedge reset)
    if (~ reset_n)
      clk_cnt <= '0;
    else
      clk_cnt <= clk_cnt + 1'd1;

  wire muxed_clk_raw
    = slow_clk_mode ? clk_cnt [22] : clk;

  wire muxed_clk;
  global i_global (.in (muxed_clk_raw), .out (muxed_clk));

  //--------------------------------------------------------------------------
  // MCU inputs

  wire         ei_req;               // external int request
  wire         nmi_req   = 1'b0;     // non-maskable interrupt
  wire         resetb    = ~ reset;  // master reset
  wire         ser_rxd   = 1'b0;     // receive data input
  wire  [15:0] port4_in  = '0;
  wire  [15:0] port5_in  = '0;

  //--------------------------------------------------------------------------
  // MCU outputs

  wire         debug_mode;  // in debug mode
  wire         ser_clk;     // serial clk output (cks mode)
  wire         ser_txd;     // transmit data output
  wire         wfi_state;   // waiting for interrupt
  wire  [15:0] port0_reg;   // port 0
  wire  [15:0] port1_reg;   // port 1
  wire  [15:0] port2_reg;   // port 2
  wire  [15:0] port3_reg;   // port 3

  // Auxiliary UART receive pin

  `ifdef BOOT_FROM_AUX_UART
  wire         aux_uart_rx = gpio [31];
  `endif

  // Exposed memory bus for debug purposes

  wire         mem_ready;   // memory ready
  wire  [31:0] mem_rdata;   // memory read data
  wire         mem_lock;    // memory lock (rmw)
  wire         mem_write;   // memory write enable
  wire   [1:0] mem_trans;   // memory transfer type
  wire   [3:0] mem_ble;     // memory byte lane enables
  wire  [31:0] mem_addr;    // memory address
  wire  [31:0] mem_wdata;   // memory write data

  wire  [31:0] extra_debug_data;

  //--------------------------------------------------------------------------
  // MCU instantiation

  yrv_mcu i_yrv_mcu (.clk (muxed_clk), .*);

  //--------------------------------------------------------------------------
  // Pin assignments

  // The original board had port3_reg [13:8], debug_mode, wfi_state
  assign led = { port3_reg [15:8], debug_mode, wfi_state };

  //--------------------------------------------------------------------------

  wire [7:0] abcdefgh_from_mcu
    = { port0_reg[0], port0_reg[1], port0_reg[2], port0_reg[3],
        port0_reg[4], port0_reg[5], port0_reg[6], port0_reg[7] };

  assign hex0 = { 8 { port1_reg [0] } } & abcdefgh_from_mcu;
  assign hex1 = { 8 { port1_reg [1] } } & abcdefgh_from_mcu;
  assign hex2 = { 8 { port1_reg [2] } } & abcdefgh_from_mcu;
  assign hex3 = { 8 { port1_reg [3] } } & abcdefgh_from_mcu;

  //--------------------------------------------------------------------------

    display_static_digit i_digit_0 ( number_to_display [ 3: 0], hex0 [6:0]);
    display_static_digit i_digit_1 ( number_to_display [ 7: 4], hex1 [6:0]);
    display_static_digit i_digit_2 ( number_to_display [11: 8], hex2 [6:0]);
    display_static_digit i_digit_3 ( number_to_display [15:12], hex3 [6:0]);
    display_static_digit i_digit_4 ( number_to_display [19:16], hex4 [6:0]);
    display_static_digit i_digit_5 ( number_to_display [23:20], hex5 [6:0]);

    assign { hex5 [7], hex4 [7], hex3 [7], hex2 [7], hex1 [7], hex0 [7] }
        = ~ sw [5:0];


  wire [7:0] abcdefgh_from_mcu =
  {
    port0_reg[6],
    port0_reg[5],
    port0_reg[4],
    port0_reg[3],
    port0_reg[2],
    port0_reg[1],
    port0_reg[0],
    port0_reg[7] 
  };

  wire [3:0] digit_from_mcu =
  {
    port1_reg [3],
    port1_reg [2],
    port1_reg [1],
    port1_reg [0]
  };

















    wire [23:0] number_to_display
        = ~ { key, key, sw, sw };

    display_static_digit i_digit_0 ( number_to_display [ 3: 0], hex0 [6:0]);
    display_static_digit i_digit_1 ( number_to_display [ 7: 4], hex1 [6:0]);
    display_static_digit i_digit_2 ( number_to_display [11: 8], hex2 [6:0]);
    display_static_digit i_digit_3 ( number_to_display [15:12], hex3 [6:0]);
    display_static_digit i_digit_4 ( number_to_display [19:16], hex4 [6:0]);
    display_static_digit i_digit_5 ( number_to_display [23:20], hex5 [6:0]);

    assign { hex5 [7], hex4 [7], hex3 [7], hex2 [7], hex1 [7], hex0 [7] }
        = ~ sw [5:0];

  `ifdef OLD_INTERRUPT_CODE

  //--------------------------------------------------------------------------
  // 125Hz interrupt
  // 50,000,000 Hz / 125 Hz = 40,000 cycles

  logic [15:0] hz125_reg;
  logic        hz125_lat;

  assign ei_req    = hz125_lat;
  wire   hz125_lim = hz125_reg == 16'd39999;

  always_ff @ (posedge clk or negedge resetb)
    if (~ resetb)
    begin
      hz125_reg <= 16'd0;
      hz125_lat <= 1'b0;
    end
    else
    begin
      hz125_reg <= hz125_lim ? 16'd0 : hz125_reg + 1'b1;
      hz125_lat <= ~ port3_reg [15] & (hz125_lim | hz125_lat);
    end

  `endif

  //--------------------------------------------------------------------------
  // 8 KHz interrupt
  // 50,000,000 Hz / 8 KHz = 6250 cycles

  logic [12:0] khz8_reg;
  logic        khz8_lat;

  assign ei_req    = khz8_lat;
  wire   khz8_lim = khz8_reg == 13'd6249;

  always_ff @ (posedge clk or negedge resetb)
    if (~ resetb)
    begin
      khz8_reg <= 13'd0;
      khz8_lat <= 1'b0;
    end
    else
    begin
      khz8_reg <= khz8_lim ? 13'd0 : khz8_reg + 1'b1;
      khz8_lat <= ~ port3_reg [15] & (khz8_lim | khz8_lat);
    end

endmodule
