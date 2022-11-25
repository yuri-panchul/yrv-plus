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

    assign led  = sw;

    wire clk   = max10_clk1_50;
    wire reset = sw [9];

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

endmodule
