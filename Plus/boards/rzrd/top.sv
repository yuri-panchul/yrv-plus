module top
(
    input        clk,
    input        reset_n,
    
    input  [3:0] key_sw,
    output [3:0] led,

    output [7:0] abcdefgh,
    output [3:0] digit,

    output       buzzer,

    output       hsync,
    output       vsync,
    output [2:0] rgb
);

  //--------------------------------------------------------------------------

  assign buzzer = 1'b0;
  assign hsync  = 1'b1;
  assign vsync  = 1'b1;
  assign rgb    = 3'b0;

  //--------------------------------------------------------------------------

  logic        ei_req;               // external int request
  logic        nmi_req   = 1'b0;     // non-maskable interrupt
  wire         resetb    = reset_n;  // master reset
  logic        ser_rxd   = 1'b0;     // receive data input
  logic [15:0] port4_in  = '0;
  logic [15:0] port5_in  = '0;

  //--------------------------------------------------------------------------

  wire         debug_mode;  // in debug mode
  wire         ser_clk;     // serial clk output (cks mode)
  wire         ser_txd;     // transmit data output
  wire         wfi_state;   // waiting for interrupt
  wire  [15:0] port0_reg;   // port 0
  wire  [15:0] port1_reg;   // port 1
  wire  [15:0] port2_reg;   // port 2
  wire  [15:0] port3_reg;   // port 3

  //--------------------------------------------------------------------------

  yrv_mcu i_yrv_mcu (.*);

  //--------------------------------------------------------------------------

  // The original board had port3_reg [13:8], debug_mode, wfi_state
  assign led = port3_reg [11:8];

  assign abcdefgh =
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

  assign digit =
  {
    port1_reg [0],
    port1_reg [1],
    port1_reg [2],
    port1_reg [3]
  };

  //--------------------------------------------------------------------------

  // 125Hz interrupt
  // 50,000,000 Hz / 125 Hz = 40,000 cycles

  logic [15:0] hz125_reg;
  logic        hz125_lat;

  assign ei_req    = hz125_lat;
  assign hz125_lim = hz125_reg == 16'd39999;

  always @ (posedge clk or negedge resetb)
    if (! resetb)
    begin
      hz125_reg <= 16'd0;
      hz125_lat <= 1'b0;
    end
    else
    begin
      hz125_reg <= hz125_lim ? 16'd0 : hz125_reg + 1'b1;
      hz125_lat <= ~ port3_reg [15] & (hz125_lim | hz125_lat);
    end

endmodule
