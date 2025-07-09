module clkgen_tb;

    reg clk = 0;
    reg rst = 1;
    reg [7:0] data;
    reg in = 0;
    wire ext_clk;
    wire out;
    wire cs;

    // Instantiate top module
    top uut (
        .clk(clk),
        .rst(rst),
        .data(data),
        .in(in),
        .ext_clk(ext_clk),
        .out(out),
        .cs(cs)
    );

    // Generate system clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("Starting SPI Clock Generator Test...");
        $dumpfile("clkgen_tb.vcd");
        $dumpvars(0, clkgen_tb);

        // Initial reset
        #10 rst = 0;

        // Send config: leader=1, len=00, CPOL=0, CPHA=0, div=3
        // 1_00_0_0_011 = 8'b10000011 = 0x83
        data = 8'h83;

        // Wait for clock edges to appear
        #1000;

        $display("Finished clock test");
        $finish;
    end

    // Optional monitor
    reg [7:0] ext_clk_prev;
    always @(posedge clk) begin
        if (ext_clk !== ext_clk_prev) begin
            $display("T=%0t | ext_clk changed to %b", $time, ext_clk);
            ext_clk_prev <= ext_clk;
        end
    end

endmodule
