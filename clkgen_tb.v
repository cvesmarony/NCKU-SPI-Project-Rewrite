`include "spi_defines.vh"

module clkgen_tb;
    parameter DIV_WIDTH = `DIV_WIDTH;

    reg sys_clk;
    reg rst;
    reg [DIV_WIDTH-1:0] divider;
    reg TIP;
    reg CS;
    reg CPOL;
    reg CPHA;

    // Outputs
    wire shift;
    wire sample;
    wire clk_out;

    // DUT
    spi_clkgen #(.DIV_WIDTH(DIV_WIDTH)) dut (
        .sys_clk(sys_clk),
        .rst(rst),
        .divider(divider),
        .TIP(TIP),
        .CS(CS),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .shift(shift),
        .sample(sample),
        .clk_out(clk_out)
    );

    // Clock generation: 10ns period
    initial sys_clk = 0;
    always #5 sys_clk = ~sys_clk;

    task run_mode;
    input mode_cpol;
    input mode_cpha;
    input [DIV_WIDTH-1:0] div_val;
        begin
            CPOL = mode_cpol;
            CPHA = mode_cpha;
            divider = div_val;

            $display("\n--- Testing SPI Mode %0d (CPOL=%0b, CPHA=%0b) ---", (mode_cpol << 1) | mode_cpha, CPOL, CPHA);

            // Reset and initialize
            rst = 1; #20;
            rst = 0;
            CS = 0;        // Chip selected
            TIP = 1;       // Transfer in progress

            // Run for multiple cycles
            repeat (40) begin
                @(posedge sys_clk);
                $display("Time %4t | clk_out=%b | shift=%b | sample=%b | count=%0d", 
                         $time, clk_out, shift, sample, dut.count);
            end

            TIP = 0;
            CS = 1;       // Deselect
        end
    endtask

    initial begin
        $dumpfile("clkgen.vcd");
        $dumpvars(0, clkgen_tb);
        // Initial values
        rst = 0;
        TIP = 0;
        CS = 1;
        CPOL = 0;
        CPHA = 0;
        divider = 4;  // Divide sys_clk to slow down SPI clock

        #20;

        run_mode(1'b0, 1'b0, 4); // Mode 0
        run_mode(1'b0, 1'b1, 4); // Mode 1
        run_mode(1'b1, 1'b0, 4); // Mode 2
        run_mode(1'b1, 1'b1, 4); // Mode 3

        $finish;
    end
endmodule
