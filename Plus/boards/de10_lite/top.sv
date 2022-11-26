`define INTEL_VERSION
`define CLK_FREQUENCY (50 * 1000 * 1000)

`include "yrv_mcu.v"

module top
(
  input         adc_clk_10,
  input         max10_clk1_50,
  input         max10_clk2_50,

  input  [ 1:0] key,
  input  [ 9:0] sw,
  output [ 9:0] led,

  output [ 7:0] hex0,
  output [ 7:0] hex1,
  output [ 7:0] hex2,
  output [ 7:0] hex3,
  output [ 7:0] hex4,
  output [ 7:0] hex5,

  output        vga_hs,
  output        vga_vs,
  output [ 3:0] vga_r,
  output [ 3:0] vga_g,
  output [ 3:0] vga_b,

  inout  [35:0] gpio
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

  always_ff @ (posedge clk or posedge reset)
    if (reset)
      clk_cnt <= '0;
    else
      clk_cnt <= clk_cnt + 1'd1;

  wire muxed_clk_raw
    = slow_clk_mode ? clk_cnt [22] : clk;

  wire muxed_clk;

  `ifdef SIMULATION
    assign muxed_clk = muxed_clk_raw;
  `else
    global i_global (.in (muxed_clk_raw), .out (muxed_clk));
  `endif

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
  wire         aux_uart_rx = gpio [34];
  assign gpio [35] = 1'b0;  // ground
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

  logic [5:0][7:0] hex_from_mcu;

  always_ff @ (posedge clk)
    for (int i = 0; i < 4; i ++)
      if (~ port1_reg [i])
        hex_from_mcu [i]
          <= { port0_reg[7], port0_reg[0], port0_reg[1], port0_reg[2],
               port0_reg[3], port0_reg[4], port0_reg[5], port0_reg[6] };

  assign hex_from_mcu [5:4] = '1;

  //--------------------------------------------------------------------------

  logic [23:0] display_number;

  always_comb
    casez (sw)
    default        : display_number = mem_addr         [23:0];
    10'b????????1? : display_number = mem_rdata        [23:0];
    10'b???????10? : display_number = mem_rdata        [31:8];
    10'b??????100? : display_number = mem_wdata        [23:0];
    10'b?????1000? : display_number = mem_wdata        [31:8];
    10'b????10000? : display_number = extra_debug_data [23:0];
    10'b???100000? : display_number = extra_debug_data [31:8];
    endcase

  //--------------------------------------------------------------------------

  wire [5:0][7:0] hex_from_show_mode;

  genvar gi;

  generate
    for (gi = 0; gi < 6; gi ++)
    begin : gen
      display_static_digit i_digit
      (
        display_number [gi * 4 +: 4],
        hex_from_show_mode [gi][6:0]
      );

      assign hex_from_show_mode [gi][7] = 1'b1;
    end
  endgenerate

  //--------------------------------------------------------------------------

  assign { hex5, hex4, hex3, hex2, hex1, hex0 }
    = slow_clk_mode ? hex_from_show_mode : hex_from_mcu;

  //--------------------------------------------------------------------------

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
