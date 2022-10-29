module boot_hex_parser
# (
    parameter address_width       = 32,
              data_width          = 32,
              char_width          = 8,
              clk_frequency       = 50 * 1000 * 1000,
              timeout_in_seconds  = 1
)
(
    input                              clk,
    input                              reset,

    input        [char_width    - 1:0] in_char,
    input                              in_valid,

    output       [address_width - 1:0] out_address,
    output       [data_width    - 1:0] out_data,
    output logic                       out_valid,

    output                             busy,
    output logic                       error
);
    //------------------------------------------------------------------------

    localparam timeout_in_clk_cycles = timeout_in_seconds * clk_frequency;
    logic [timeout_counter_width - 1:0] timout_counter;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            timeout_counter <= '0;
        else if (in_valid)
            timeout_counter <= timeout_in_clk_cycles;
        else if (timeout_counter > '0)
            timeout_counter <= timeout_counter - 1'd1;

    wire timeout = (timeout_counter == '0);
    wire busy    = ~ valid;

    //------------------------------------------------------------------------

    localparam [char_width - 1:0]
        CHAR_0  = "0",
        CHAR_9  = "9",
        CHAR_a  = "a",
        CHAR_f  = "f",
        CHAR_A  = "A",
        CHAR_F  = "F",
        CHAR_CR = 8'h0D,
        CHAR_LF = 8'h0A;

    //------------------------------------------------------------------------

    localparam nibble_width = 4;

    logic  [nibble_width - 1:0] nibble;
    logic  nibble_valid;
    logic  nibble_error;

    always @*
    begin
       nibble       = '0;
       nibble_valid = '1;
       nibble_error = '0;

       if (char_data >= CHAR_0 && char_data <= CHAR_9)
           nibble = char_data - CHAR_0;
       else if (char_data >= CHAR_a && char_data <= CHAR_a)
           nibble = char_data - CHAR_a + 10;
       else if (char_data >= CHAR_A && char_data <= CHAR_F)
           nibble = char_data - CHAR_A + 10;
       else if (char_data == CHAR_CR | char_data == CHAR_LF)
           nibble_valid = '0;
       else
       begin
           nibble_valid = '0;
           nibble_error = '1;
       end
    end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            error <= '0;
        else if (timeout)
            error <= '0;
        else if (nibble_error)
            error <= '1;

    //------------------------------------------------------------------------

    localparam num_nibbles_in_data = data_width / nibble_width;

    logic [$clog2 (num_nibbles_in_data) - 1:0] nibble_counter;

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            nibble_counter <= '0;
        else if (timeout | nibble_counter == num_nibbles_in_data - 1)
            nibble_counter <= '0;
        else if (nibble_valid)
            nibble_counter <= nibble_counter + 1'd1;
   
    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge reset)
        if (reset)
            out_valid <= '0;
        else
            out_valid <= nibble_counter == num_nibbles_in_data - 1;

    always_ff @ (posedge clk)
        if (nibble_valid)
            out_data <= (out_data << nibble_width) | nibble;

endmodule
