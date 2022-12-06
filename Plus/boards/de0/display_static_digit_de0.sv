
module display_static_digit_de0
(
    input        [3:0] dig,
    output logic [7:0] hex
);

    always_comb
        case (dig)
        'h0: hex = 'b11000000;  // d0-d6
        'h1: hex = 'b11111001;
        'h2: hex = 'b10100100;  //   --d0--
        'h3: hex = 'b10110000;  //  |     |
        'h4: hex = 'b10011001;  //  d5    d1
        'h5: hex = 'b10010010;  //  |     |
        'h6: hex = 'b10000010;  //   --d6--
        'h7: hex = 'b11111000;  //  |     |
        'h8: hex = 'b10000000;  //  d4    d2
        'h9: hex = 'b10010000;  //  |     |
        'ha: hex = 'b10001000;  //   --d3--  dp 
        'hb: hex = 'b10000011;
        'hc: hex = 'b11000110;
        'hd: hex = 'b10100001;
        'he: hex = 'b10000110;
        'hf: hex = 'b10001110;
        endcase

endmodule
