module shift_reg (
    parameter CHAR_LENGTH = 8
    )(
        input                       clk,
        input                       rst,
        input                       load,       // Load signal: load d_in into register
        input                       shift,      // Shift signal: shift data
        input [CHAR_LENGTH-1:0]     d_in,       // Input data (parallel)
        output                      TOP,        // MSB of the shift register
        output [CHAR_LENGTH-1:0]    d_out       // Current register state
    );

    integer i;
    reg [CHAR_LENGTH-1:0] shift_reg;

    assign d_out = shift_reg;
    assign TOP = shift_reg[CHAR_LENGTH-1];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 0;
        end else if (load) begin
            shift_reg <= d_in;
        end else if (shift) begin
            shift_reg <= shift_reg << 1;
        end
    end


endmodule