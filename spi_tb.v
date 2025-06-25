`include "spi_defines.vh"

module spi_tb;

    // Parameters
    parameter DATA_LEN = 8;
    parameter DIV_WIDTH = 8;

    // Clock and reset
    reg sys_clk = 0;
    reg rst = 1;
    always #5 sys_clk = ~sys_clk; // 100 MHz clock (10ns period)

    // Leader control
    reg go;
    wire cs, sclk, mosi, miso;
    wire [DATA_LEN-1:0] leader_rx, follower_rx;
    wire done_leader, done_follower;

    // Test data registers
    reg [DATA_LEN-1:0] tx_leader;
    reg [DATA_LEN-1:0] tx_follower;

    // Signal monitoring
    reg [3:0] sclk_pulse_count = 0;
    reg prev_cs = 1;
    reg prev_sclk = 0;
    reg [DATA_LEN-1:0] mosi_history, miso_history;

    // Instantiate modules (using your original definitions without CPOL/CPHA ports)
    spi_leader #(
        .DATA_LEN(DATA_LEN),
        .DIV_WIDTH(DIV_WIDTH)
    ) leader_inst (
        .sys_clk(sys_clk),
        .rst(rst),
        .go(go),
        .clk_divider(8'd4),
        .tx_data(tx_leader),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .cs(cs),
        .rx_data(leader_rx),
        .busy(),
        .done(done_leader)
    );

    spi_follower #(
        .DATA_LEN(DATA_LEN)
    ) follower_inst (
        .clk(sys_clk),
        .rst(rst),
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .tx_data(tx_follower),
        .miso(miso),
        .rx_data(follower_rx),
        .done(done_follower)
    );

    // Test sequence
    initial begin
        $display("Starting SPI Testbench");
        $dumpfile("spi_tb.vcd");
        $dumpvars(0, spi_tb);

        // Initialize
        #20;
        rst = 0;
        #50;

        // Basic test cases
        $display("\n===== Basic Functionality Tests =====");
        
        // Test Case 1: Basic transfer
        test_transfer(
            8'b10101010, // Leader data
            8'b01010101, // Follower data
            "Basic transfer"
        );
        
        // Test Case 2: All zeros
        test_transfer(
            8'b00000000,
            8'b00000000,
            "All zeros"
        );
        
        // Test Case 3: All ones
        test_transfer(
            8'b11111111,
            8'b11111111,
            "All ones"
        );
        
        // Test Case 4: Single bit set
        test_transfer(
            8'b00000001,
            8'b10000000,
            "Single bit set"
        );
        
        // Test Case 5: Random pattern
        test_transfer(
            8'b11001100,
            8'b00110011,
            "Random pattern"
        );

        // Edge case testing
        $display("\n===== Edge Case Tests =====");
        
        // Back-to-back transfers
        $display("\nBack-to-back transfer test");
        repeat (3) begin
            test_transfer(
                $random,
                $random,
                "Back-to-back random"
            );
        end

        $display("\nAll tests completed successfully");
        $finish;
    end

    // SCLK pulse counter and data capture
    always @(posedge sys_clk) begin
        prev_cs <= cs;
        prev_sclk <= sclk;
        
        if (prev_cs && !cs) begin
            sclk_pulse_count <= 0;
            mosi_history <= 0;
            miso_history <= 0;
        end
        
        if (!prev_sclk && sclk && !cs) begin  // Rising edge detection
            sclk_pulse_count <= sclk_pulse_count + 1;
            mosi_history <= {mosi_history[DATA_LEN-2:0], mosi};
            miso_history <= {miso_history[DATA_LEN-2:0], miso};
            $display("Edge %0d: MOSI=%b, MISO=%b", 
                    sclk_pulse_count + 1, mosi, miso);
        end
    end

    task test_transfer;
        input [DATA_LEN-1:0] leader_data;
        input [DATA_LEN-1:0] follower_data;
        input [80:0] test_name;
        begin
            $display("\nTest: %s", test_name);
            tx_leader = leader_data;
            tx_follower = follower_data;
            run_transfer();
            verify_transfer(DATA_LEN);
        end
    endtask

    task run_transfer;
        begin
            $display("Leader sending: %b", tx_leader);
            $display("Follower sending: %b", tx_follower);
            
            go = 1;
            #10;
            go = 0;
            
            wait (done_leader);
            #50; // Inter-transfer delay
            
            $display("Transfer completed");
        end
    endtask

    task verify_transfer;
        input integer expected_pulses;
        begin
            // Verify clock pulses
            $display("SCLK pulses: %0d (expected %0d)", 
                    sclk_pulse_count, expected_pulses);
            
            if (sclk_pulse_count != expected_pulses) begin
                $display("ERROR: Incorrect number of clock pulses");
            end
            
            // Verify data exchange
            $display("Leader received: %b (expected %b)", 
                    leader_rx, tx_follower);
            $display("Follower received: %b (expected %b)", 
                    follower_rx, tx_leader);
            
            if (leader_rx === tx_follower && follower_rx === tx_leader) begin
                $display("RESULT: PASS");
            end else begin
                $display("RESULT: FAIL");
            end
            
            // Verify no X or Z states
            if (^leader_rx === 1'bx || ^follower_rx === 1'bx) begin
                $display("WARNING: Received data contains X/Z states");
            end
        end
    endtask

endmodule