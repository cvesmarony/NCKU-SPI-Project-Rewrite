module spi_clkgen (
    input wire sys_clk,
    input wire rst,
    input wire [2:0] divider,   // clock divider (like your `div`)
    input wire TIP,             // transfer in progress (start/stop control)
    input wire CS,
    input wire CPOL,
    input wire CPHA,
    output reg clk_out,
    output reg shift,
    output reg sample
);
    reg [15:0] clk_div_cnt;
    reg spi_clk_int;

    // Generate base spi clock with divider when TIP active
    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            clk_div_cnt <= 0;
            spi_clk_int <= CPOL;
        end else if (TIP && !CS) begin
            if (clk_div_cnt == (1 << divider)) begin
                clk_div_cnt <= 0;
                spi_clk_int <= ~spi_clk_int;
            end else begin
                clk_div_cnt <= clk_div_cnt + 1;
            end
        end else begin
            clk_div_cnt <= 0;
            spi_clk_int <= CPOL;
        end
    end

    // SPI clock output adjusted for CPOL
    always @(posedge sys_clk) begin
        clk_out <= spi_clk_int;
    end

    // Generate shift/sample strobes based on CPOL/CPHA and spi_clk_int edges
    // We'll use a simple edge detector on spi_clk_int with sys_clk synchronizer

    reg [2:0] clk_sync;
    always @(posedge sys_clk) clk_sync <= {clk_sync[1:0], spi_clk_int};

    wire pos_edge = (~clk_sync[2] & clk_sync[1]);
    wire neg_edge = (clk_sync[2] & ~clk_sync[1]);

    // According to CPOL/CPHA
    // sample_edge = (cpha == cpol) ? pos_edge : neg_edge;
    // shift_edge = (cpha == cpol) ? neg_edge : pos_edge;

    always @(posedge sys_clk) begin
        sample <= (CPHA == CPOL) ? pos_edge : neg_edge;
        shift  <= (CPHA == CPOL) ? neg_edge : pos_edge;
    end
endmodule