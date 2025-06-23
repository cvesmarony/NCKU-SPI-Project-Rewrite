`include "spi_defines.vh"

module spi_clkgen #(
    parameter DIV_WIDTH = `DIV_WIDTH  // Bit width of the divider
    )(
        input wire                     sys_clk,    // System clock
        input wire                     rst,        // Reset
        input wire [DIV_WIDTH-1:0]     divider,    // Clock divider
        input wire                     TIP,        // Transfer in progress (external control)
        input wire                     CS,         // Chip select (active low)
        input wire                     CPOL,       // Clock polarity (input, configurable)
        input wire                     CPHA,       // Clock phase
        output reg                     shift,      // Shift signal
        output reg                     sample,     // Sample signal
        output reg                     clk_out     // Generated SPI clock
    );

    reg [DIV_WIDTH-1:0] count;

    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            clk_out <= CPOL;
            count   <= 0;
            shift   <= 0;
            sample  <= 0;
        end else begin
            shift  <= 0;
            sample <= 0;

            if (TIP && ~CS) begin
                // Counts until divider number then flips clock
                if (count == (divider >> 1) - 1) begin
                    clk_out <= ~clk_out;
                    count <= 0;

                    if ((clk_out == ~CPOL && CPHA == 1'b0) || (clk_out == CPOL && CPHA == 1'b1)) begin
                        sample <= 1;
                        shift  <= 0;
                    end else begin
                        shift  <= 1;
                        sample <= 0;
                    end
                end else begin
                    count <= count + 1;
                end
            end else begin
                clk_out <= CPOL;
                count   <= 0;
            end
        end
    end
endmodule