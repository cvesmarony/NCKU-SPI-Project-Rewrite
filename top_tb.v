module top_tb;

    reg clk = 0;
    reg rst = 1;

    // Bidirectional nets need to be declared as wires
    wire [7:0] data;
    wire cs;
    wire ext_clk;

    reg [7:0] data_drive;
    reg data_drive_en;
    assign data = data_drive_en ? data_drive : 8'bz;

    // MOSI/MISO
    wire mosi;
    reg miso = 1'b1;  // tied low for now

    reg cs_en;
    reg cs_in;
    assign cs = cs_en ? cs_in : 8'bz;

    reg ext_en;
    reg sclk = 0;
    assign ext_clk = ext_en ? sclk : 1'bz;

    // Instantiate DUT (leader mode)
    top uut (
        .clk(clk),
        .rst(rst),
        .in(miso),
        .data(data),
        .cs(cs),
        .ext_clk(ext_clk),
        .out(mosi)
    );
    
    // top dut2 (
    //     .clk(clk),
    //     .rst(rst),
    //     .in(miso),
    //     .data(data),
    //     .cs(cs),
    //     .ext_clk(ext_clk),
    //     .out(mosi)
    // );

    // Clock generation
    always #5 clk = ~clk;
    always #10 sclk = ~sclk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        $display("=== Begin TOP Module Test ===");

        // Initial reset
        #10;
        rst = 1;
        ext_en = 0;
        cs_en = 0;
        #100
        rst = 0;

        // Drive config byte: mode=1 (leader), len=0 (8-bit), cpol=0, cpha=0, div=3'b001
        #10;
        data_drive = 8'b1_0_0_0_0010;
        data_drive_en = 1;
        wait (uut.config_set == 1);
        data_drive_en = 0;

        // Wait for config to be accepted
        $display("Config accepted by DUT");

        // Wait until cs is pulled low (transfer started)
        // leader
        wait (cs == 0);

        // follower
        // ext_en = 1;
        // cs_in = 0;
        // cs_en = 1;
        $display("CS pulled low, transfer starting...");

        // Observe SPI clock and MOSI
        #10;

        // Wait for SPI to complete (data_en goes high again)
        wait (uut.data_en == 0);
        $display("Received data: %02X", data);

        #20;
        $display("=== End of TOP Module Test ===");
        $finish;
    end
endmodule
