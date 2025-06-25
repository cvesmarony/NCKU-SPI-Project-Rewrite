`include "spi_defines.vh"

module spi_clkgen #(
    parameter DIV_WIDTH = `DIV_WIDTH
)(
    input wire                     sys_clk,
    input wire                     rst,
    input wire [DIV_WIDTH-1:0]     divider,
    input wire                     TIP,
    input wire                     CS,
    input wire                     CPOL,
    input wire                     CPHA,
    output reg                     shift,
    output reg                     sample,
    output reg                     clk_out
);

    reg [DIV_WIDTH-1:0] count;
    reg clk_out_prev;

    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            clk_out <= CPOL;
            clk_out_prev <= CPOL;
            count   <= 0;
            shift   <= 0;
            sample  <= 0;
        end else begin
            shift  <= 0;
            sample <= 0;
            clk_out_prev <= clk_out;

            if (TIP && ~CS) begin
                if (count == (divider >> 1) - 1) begin
                    clk_out <= ~clk_out;
                    count <= 0;

                    // Use new value of clk_out (after flip)
                    if ((~clk_out == ~CPOL && CPHA == 1'b0) || 
                        (~clk_out == CPOL  && CPHA == 1'b1)) begin
                        sample <= 1;
                    end else begin
                        shift <= 1;
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

    always @(posedge sys_clk) begin
        $display("CLKGEN: TIP=%b, CS=%b, count=%d, clk_out=%b", 
                TIP, CS, count, clk_out);
    end
endmodule