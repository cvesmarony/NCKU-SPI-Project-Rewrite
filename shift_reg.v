module shift_reg #(
    parameter DATA_LEN = `DATA_LEN
    )(
        input                       clk,
        input                       rst,
        input                       load,           // Load signal: load d_in into register
        input                       shift,          // Shift signal: shift data
        input  [DATA_LEN-1:0]       d_in,           // Input data (parallel)
        input                       serial_in,      // for MISO
        output                      TOP,            // MSB of the shift register
        output [DATA_LEN-1:0]       d_out           // Current register state
    );

    reg [DATA_LEN-1:0] shift_reg;

    assign d_out = shift_reg;
    assign TOP = shift_reg[DATA_LEN-1];

    always @(posedge clk or posedge rst) begin
        if (rst)
            shift_reg <= 0;
        else if (load)
            shift_reg <= d_in;
        else if (shift)
            shift_reg <= {shift_reg[DATA_LEN-2:0], serial_in};  // shift left, LSB from serial_in
    end

endmodule