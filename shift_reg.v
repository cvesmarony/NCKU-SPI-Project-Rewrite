`include "spi_defines.vh"

module shift_reg #(
    parameter DATA_LEN = `DATA_LEN
    )(
        input                       clk,
        input                       rst,
        input [DATA_LEN-1:0]        d_in,
        input                       load_en,
        input                       shift_en,
        input                       serial_in,
        output wire                 serial_out,
        output reg [DATA_LEN-1:0]   d_out
    );

    reg [DATA_LEN-1:0] shift_reg;

    assign serial_out = shift_reg[0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= {DATA_LEN{1'b0}};
            d_out <= {DATA_LEN{1'b0}};
        end else begin
            if (load_en) begin
                shift_reg <= d_in;
                d_out <= d_in;
            end else if (shift_en) begin
                shift_reg <= {serial_in, shift_reg[DATA_LEN-1:1]};
                d_out <= {serial_in, shift_reg[DATA_LEN-1:1]};
            end
        end
    end
endmodule
