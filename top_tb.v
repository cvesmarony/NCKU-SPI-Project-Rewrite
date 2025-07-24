module top_tb;

    // Clock and reset
    reg clk = 0;
    reg sclk = 0;
    reg rst = 1;
    always #5 clk = ~clk;  // 100MHz system clock
    always #10 sclk = ~sclk;

    // Testbench control
    reg [7:0] tb_data;
    reg tb_data_en;
    integer test_num = 0;
    
    // SPI signals
    wire [7:0] data;
    wire cs;
    wire ext_clk;
    wire mosi;
    wire ready;
    reg miso = 1;

    reg cs_en;
    reg cs_in;
    assign cs = cs_en ? cs_in : 8'bz;

    reg ext_en;
    assign ext_clk = ext_en ? sclk : 1'bz;
    
    // Bidirectional bus control
    assign data = tb_data_en ? tb_data : 8'bz;
    // Simulate SPI Master sending 0x55 = 8'b01010101 (LSB-first)
    reg [7:0] master_data = 8'h55;


    integer i;
    
    // Instantiate DUT (test as both leader and follower)
    top dut_leader (
        .clk(clk),
        .rst(rst),
        .in(miso),
        .data(data),
        .cs(cs),
        .ext_clk(ext_clk),
        .out(mosi),
        .ready(ready)
    );

    // top dut_follower (
    //     .clk(clk),
    //     .rst(rst),
    //     .in(miso2),
    //     .data(data2),
    //     .cs(cs),
    //     .ext_clk(ext_clk),
    //     .out(mosi),
    //     .ready(ready)
    // );
    
    // Test sequences
    initial begin
        // Initialize
        rst = 1;
        #100;
        miso = 1;
        tb_data_en = 0;
        cs_en = 0;
        ext_en = 0;
        #100;
        rst = 0;
        #100
        
        // Test 1: 8-bit transfer
        // test_num = 1;
        // $display("\nTest %0d: 8-bit, CPOL=0, CPHA=0", test_num);
        
        // // Configure as leader
        // send_config(1'b1, 1'b0, 1'b0, 1'b0, 3'b001);
        // wait(ready);  // Wait for configuration complete
        // #100;
        
        // // Send data
        // send_data(8'hA5);
        
        // // Simulate follower response
        // repeat(8) begin
        //     #100;
        //     miso = ~miso;  // Alternate bits (10101010)
        // end

        // wait(ready);
        // tb_data_en = 0;
        
        // // Verify received data (should be 0x55)
        // verify_data(8'hAA);
        
        
        // =============================================
        // Test 2: Follower mode
        // =============================================
        test_num = 2;
        $display("\nTest %0d: Follower mode", test_num);
        
        // Reconfigure as follower
        send_config(1'b0, 1'b0, 1'b0, 1'b0, 3'b000);
        wait(ready);
        #100
        
        // Simulate external master
        ext_en = 1;
        cs_in = 0;
        cs_en = 1;
        $display("CS low");

        repeat(8) begin
            wait(dut_leader.sample_edge);
            wait(dut_leader.shift_edge);
            miso = ~miso;  // Alternate bits (10101010)
            $display("miso: ", miso);
        end
        
        // Wait for completion
        // wait_for_transfer_complete();
        wait(ready);
        // #100
        tb_data_en = 0;
        // #100
        verify_data(8'hAA);  // Should have received 0x55
        
        $display("\nAll tests completed successfully!");
        $finish;
    end
    
    // Helper tasks
     task send_config;
        input mode;
        input len;
        input cpol;
        input cpha;
        input [2:0] div;
        begin
            $display("Sending config...");
            tb_data = {mode, len, cpol, cpha, div, 1'b0};
            tb_data_en = 1;
        end
    endtask

    task send_data;
        input [7:0] tx_data;
        begin
            $display("Sending data: 0x%02X", tx_data);
            tb_data = tx_data;;
            tb_data_en = 1;
        end
    endtask

    task verify_data;
        input [7:0] expected;
        begin
            #50;  // Wait for bus to stabilize
            if (data !== expected) begin
                $display("ERROR: Received 0x%02X (expected 0x%02X) at time %t",
                        data, expected, $time);
                $display("DUT internal state: rxo=0x%02X, rxi=0x%02X",
                        dut_leader.rxo, dut_leader.rxi);
                $finish;
            end
            $display("Data verified: 0x%02X", data);
        end
    endtask
    
    // Monitor SPI bus
    always @(posedge dut_leader.ext_clk) begin
        if (dut_leader.mode && !dut_leader.cs) begin
            $display("SPI CLK posedge - MOSI: %b", mosi);
        end
    end
    
    always @(negedge dut_leader.ext_clk) begin
        if (dut_leader.mode && !dut_leader.cs) begin
            $display("SPI CLK negedge - MISO: %b", miso);
        end
    end 
    
endmodule