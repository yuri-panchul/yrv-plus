`define INTEL_VERSION
`define CLK_FREQUENCY (50 * 1000 * 1000)

`include "yrv_mcu.v"

module top
(
  input         clk1_50,
// input    reset_in,
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
  output        lpt_STROBE,
  output  [7:0] lpt_data,
  output        lpt_AUTOFEED,
  input         lpt_ACK,
  input         lpt_BUSY,
  input         lpt_POUT,
  input         lpt_SEL,
  output        lpt_reset

  `ifdef BOOT_FROM_AUX_UART
  ,
  input              rx
  `endif

);

  //--------------------------------------------------------------------------
  // Unused pins

  // assign vga_hs = '0;
  // assign vga_vs = '0;
  // assign vga_r  = '0;
  // assign vga_g  = '0;
  // assign vga_b  = '0;


  //Memory bus interface
  reg    [15:0] mem_addr_reg;                              /* reg'd memory address         */
  reg     [3:0] mem_ble_reg;                               /* reg'd memory byte lane en    */


  wire    [3:0] vga_wr_byte_0;                                 /* vga ram byte enables      */
  reg           vga_wr_reg_0;                                  /* mem write                    */

  wire    [3:0] vga_wr_byte_1;                                 /* vga ram byte enables      */
  reg           vga_wr_reg_1;                                  /* mem write                    */

  reg     [7:0] vga_mem0_0 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem1_0 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem2_0 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem3_0 [0:16383];                          /* vga ram                   */

  reg     [7:0] vga_mem0_1 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem1_1 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem2_1 [0:16383];                          /* vga ram                   */
  reg     [7:0] vga_mem3_1 [0:16383];                          /* vga ram                   */



  assign vga_wr_byte_0 = {4{vga_wr_reg_0}} & mem_ble_reg & {4{mem_ready}};
  assign vga_wr_byte_1 = {4{vga_wr_reg_1}} & mem_ble_reg & {4{mem_ready}};

  //--------------------------------------------------------------------------
  // Clock and reset

   wire clk   = clk1_50;
   wire reset = ~ key[0];

  //--------------------------------------------------------------------------
  // MCU clock

  wire slow_clk_mode = ~ key[1];

  logic [23:0] clk_cnt;
    //Timer 3Hz
  logic [15:0] timer;

  always_ff @ (posedge clk or posedge reset)
    if (reset)
      clk_cnt <= '0;
    else
      begin
        clk_cnt <= clk_cnt + 1'd1;

      end
 
 logic timer_flag;

 wire time_clk = clk_cnt[23];

always_ff @ (posedge time_clk or posedge reset)
   if (reset)
      timer <= '0;
    else
      timer <= timer+1'd1;

 
 // always @ (posedge clk or posedge reset)
 //    if (reset)
 //      begin
 //        timer <= '0;
 //        timer_flag <='0;
 //      end
 //    else
 //      if(clk_cnt[23] && ~timer_flag )
 //        begin
 //          timer <= timer+1'd1;
 //          timer_flag <=1'b1;
 //        end
 //      else if (clk_cnt[22])
 //          timer_flag <=0;

  wire muxed_clk_raw
    = slow_clk_mode ? clk_cnt [20] : clk;

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
  wire  [15:0] port4_in;
  wire  [15:0] port5_in;

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
  wire         aux_uart_rx = rx;
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

  //-------------------
  // LPT Ports
  assign lpt_STROBE = port3_reg[0];
  assign lpt_reset = port3_reg[1];
  assign lpt_data =   port2_reg[7:0];
  assign port4_in[0] = lpt_ACK;
  assign port4_in[1] = lpt_BUSY;
  assign port4_in[2] = lpt_POUT;
  assign port4_in[3] = lpt_SEL;

  assign port4_in[15:4] = 1'b0;
  assign port5_in = timer;


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
    10'b???1 : display_number = mem_rdata        [23:0];
    10'b??10 : display_number = mem_rdata        [31:8];
    10'b?100 : display_number = mem_wdata        [23:0];
    10'b1000 : display_number = mem_wdata        [31:8];
//    10'b????10000? : display_number = extra_debug_data [23:0];
//    10'b???100000? : display_number = extra_debug_data [31:8];
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
/*
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
*/


    wire display_on;

    wire [X_WIDTH - 1:0] x;
    wire [Y_WIDTH - 1:0] y;


    localparam X_WIDTH = 10,
               Y_WIDTH = 10,
               CLK_MHZ = 50;

    vga
    # (
        .HPOS_WIDTH ( X_WIDTH      ),
        .VPOS_WIDTH ( Y_WIDTH      ),
        .CLK_MHZ    ( CLK_MHZ      )
    )
    i_vga
    (
        .clk        (   muxed_clk  ), 
        .reset      (   ~resetb    ),
        .hsync      (   vga_hs     ),
        .vsync      (   vga_vs     ),
        .display_on (   display_on ),
        .hpos       (   x          ),
        .vpos       (   y          )
    );


  always @ (posedge clk or negedge resetb) begin
    if (!resetb) begin
      mem_addr_reg <= 16'h0;
      mem_ble_reg  <=  4'h0;
      vga_wr_reg_0   <=  1'b0;
      end
    else if (mem_ready) begin
      mem_addr_reg <= mem_addr[15:0];
      mem_ble_reg  <= mem_ble;
      vga_wr_reg_0   <= mem_write && &mem_trans    && (mem_addr[31:16] == `VGA_BASE_0);
      vga_wr_reg_1   <= mem_write && &mem_trans    && (mem_addr[31:16] == `VGA_BASE_1);
      end
    end

  reg   [31:0]  color_line_reg_0;
  reg   [31:0]  color_line_reg_1;

  always @ (posedge clk) begin
          if (vga_wr_byte_0[3]) vga_mem3_0[mem_addr_reg[15:2]] <= mem_wdata[31:24];
          if (vga_wr_byte_0[2]) vga_mem2_0[mem_addr_reg[15:2]] <= mem_wdata[23:16];
          if (vga_wr_byte_0[1]) vga_mem1_0[mem_addr_reg[15:2]] <= mem_wdata[15:8];
          if (vga_wr_byte_0[0]) vga_mem0_0[mem_addr_reg[15:2]] <= mem_wdata[7:0];
          
          if (vga_wr_byte_1[3]) vga_mem3_1[mem_addr_reg[15:2]] <= mem_wdata[31:24];
          if (vga_wr_byte_1[2]) vga_mem2_1[mem_addr_reg[15:2]] <= mem_wdata[23:16];
          if (vga_wr_byte_1[1]) vga_mem1_1[mem_addr_reg[15:2]] <= mem_wdata[15:8];
          if (vga_wr_byte_1[0]) vga_mem0_1[mem_addr_reg[15:2]] <= mem_wdata[7:0];
          

            color_line_reg_0 <= {vga_mem3_0[pixel_addr[15:2]], vga_mem2_0 [pixel_addr[15:2]], vga_mem1_0 [pixel_addr[15:2]],vga_mem0_0 [pixel_addr[15:2]]};
            color_line_reg_1 <= {vga_mem3_1[pixel_addr[15:2]], vga_mem2_1 [pixel_addr[15:2]], vga_mem1_1 [pixel_addr[15:2]],vga_mem0_1 [pixel_addr[15:2]]};
            


            pixel_bank <=pixel_addr[16];
    end

  logic [16:0] pixel_addr;
  logic pixel_bank;
  
  logic [1:0]  chip;
  reg   [7:0]  color_reg;// = 8'b00000011;



  // ((y>>1)<<8) + ((y>>1)<<6) + x>>1
  // assign pixel_addr = (((y>>1)*320)+(x>>1));
  assign pixel_addr = (((y>>1)<<8) + ((y>>1)<<6) + (x>>1));
  assign chip = pixel_addr[1:0];
  

  always@ (posedge clk) begin
    // if(display_on)
        case(chip)
          2'b00: color_reg <= pixel_bank ? color_line_reg_1[7:0]: color_line_reg_0[7:0];
          2'b01: color_reg <= pixel_bank ? color_line_reg_1[15:8]: color_line_reg_0[15:8];
          2'b10: color_reg <= pixel_bank ? color_line_reg_1[23:16]: color_line_reg_0[23:16];
          2'b11: color_reg <= pixel_bank ? color_line_reg_1[31:24]: color_line_reg_0[31:24];
        endcase
  end


  always_comb
    begin
      // Circle

      if (~ display_on)
        begin          
          vga_r = 4'b0000;
          vga_g = 4'b0000;
          vga_b = 4'b0000;
        end
      else 
        begin
          vga_r = {color_reg[7:5], color_reg[7] ||color_reg[6] || color_reg[5]};
          vga_g = {color_reg[4:2], color_reg[4] ||color_reg[3] || color_reg[2]};
          vga_b = {color_reg[1:0], color_reg[1] ||color_reg[0], color_reg[1]};       
        end
    end


    // always_comb
    // begin
    //   // Circle

    //   if (~ display_on)
    //     begin          
    //       vga_r = 4'b0000;
    //       vga_g = 4'b0000;
    //       vga_b = 4'b0000;
    //     end
    //   else if (x ** 2 + y ** 2 < 100 ** 2)
    //     begin
    //       vga_r = 4'b1111;
    //       vga_g = 4'b0000;
    //       vga_b = 4'b0000;          
    //     end
    //   else if (x > 200 & y > 200 & x < 300 & y < 400) 
    //     begin
    //       vga_r = 4'b1111;
    //       vga_g = 4'b0011;
    //       vga_b = 4'b0000;    
    //     end
    //   else if ((x - 600) ** 2 + (y - 200) ** 2 < 70 ** 2)
    //     begin
    //       vga_r = 4'b1111;
    //       vga_g = 4'b1111;
    //       vga_b = 4'b1111;          
    //     end
    //   else
    //     begin
    //       vga_r = 4'b0000;
    //       vga_g = 4'b0011;
    //       vga_b = 4'b1111;            
    //     end
    // end

endmodule