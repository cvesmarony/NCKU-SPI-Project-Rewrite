module clkgen_tb;

    reg clk;
    reg rst;
    reg [7:0] divider;
    reg TIP;
    reg GO;
    reg CS;
    reg CPOL;

    wire clk_out;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, clkgen_tb);
    end


    // Instantiate the module
    spi_clkgen #(.DIV_WIDTH(8)) dut (
        .sys_clk(clk),
        .rst(rst),
        .divider(divider),
        .TIP(TIP),
        .GO(GO),
        .CS(CS),
        .CPOL(CPOL),
        .clk_out(clk_out)
    );

    // Generate system clock (100 MHz = 10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Init
        rst = 1;
        divider = 8;  // Clock toggle every 4 sys_clk cycles
        CPOL = 0;
        GO = 0;
        TIP = 0;
        CS = 1;

        #20;
        rst = 0;
        #20;

        // Start SPI transfer
        CS = 0;
        GO = 1;
        TIP = 1;
        #10 GO = 0;

        // Let SPI run
        #200;

        // End SPI transfer
        TIP = 0;
        CS = 1;

        #50;

        $finish;
    end

endmodule
