module top_tb;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;
    always #5 clk = ~clk;  // 100MHz system clock

    // SPI shared lines
    wire mosi;
    wire miso;
    wire cs;
    wire ext_clk;

    // Bidirectional CPU data buses
    wire [7:0] data_leader;
    wire [7:0] data_follower;

    reg [7:0] tb_data_leader, tb_data_follower;
    reg tb_data_en_leader = 0, tb_data_en_follower = 0;
    reg received = 0;

    assign data_leader   = tb_data_en_leader   ? tb_data_leader   : 8'bz;
    assign data_follower = tb_data_en_follower ? tb_data_follower : 8'bz;

    wire ready_leader, ready_follower;

    // Instantiate leader
    top dut_leader (
        .clk(clk),
        .rst(rst),
        .received(received),
        .in(miso),             // Follower's output
        .data(data_leader),
        .cs(cs),               // Shared CS line
        .ext_clk(ext_clk),     // Shared SPI clock
        .out(mosi),            // Leader's output
        .ready(ready_leader)
    );

    // Instantiate follower
    top dut_follower (
        .clk(clk),
        .rst(rst),
        .received(received),
        .in(mosi),             // Leader's output
        .data(data_follower),
        .cs(cs),               // Shared CS line
        .ext_clk(ext_clk),     // Shared SPI clock
        .out(miso),            // Follower's output
        .ready(ready_follower)
    );

    // Test sequence
    initial begin
        rst = 1;
        #50;
        rst = 0;
        #100;

        $display("\n--- Configuring Leader and Follower ---");
        send_config(
            1'b1, 1'b0, 1'b0, 1'b0, 3'b001,  // leader
            1'b0, 1'b0, 1'b0, 1'b0, 3'b000   // follower
        );
        wait(ready_leader && ready_follower);
        #100;

        $display("\n--- Sending data ---");
        // send_data(0, 8'h3C);
        // wait(ready_follower);
        // $display("follower ready");
        send_data(1, 8'hA5);
        send_data(0, 8'h3C);
        wait(ready_follower);
        wait(ready_leader);
        
        // follower shifting first leader not shifting until later?
        #100

        wait(ready_follower && ready_leader);

        $display("\n--- Verifying data ---");
        tb_data_en_follower = 0;
        tb_data_en_leader = 0;
        verify_data(1, 8'h3C);  // Leader should receive 0x3C from follower
        verify_data(0, 8'hA5);  // Follower should receive 0xA5 from leader
        received = 1;
        #100
        send_data(1, 8'h6A);
        send_data(0, 8'h0F);
        wait(ready_follower);
        wait(ready_leader);
        received = 0;
        #100
        wait(ready_follower && ready_leader);
        tb_data_en_follower = 0;
        tb_data_en_leader = 0;
        verify_data(1, 8'h0F);  // Leader should receive 0x3C from follower
        verify_data(0, 8'h6A);  // Follower should receive 0xA5 from leader



        $display("\nAll tests passed!");
        $finish;
    end

    // Helper task to send configuration
    task send_config;
        input mode1, len1, cpol1, cpha1;
        input [2:0] div1;
        input mode2, len2, cpol2, cpha2;
        input [2:0] div2;
        begin
            tb_data_leader   = {mode1, len1, cpol1, cpha1, div1, 1'b0};
            tb_data_follower = {mode2, len2, cpol2, cpha2, div2, 1'b0};
            tb_data_en_leader   = 1;
            tb_data_en_follower = 1;
            // #20;
            // tb_data_en_leader   = 0;
            // tb_data_en_follower = 0;
        end
    endtask

    // Helper task to send data
    task send_data;
        input mode;
        input [7:0] tx_leader;
        // input [7:0] tx_follower;
        begin
            if (mode) begin
                tb_data_leader = tx_leader;
                tb_data_en_leader = 1;
            end else begin
                tb_data_follower = tx_leader;
                tb_data_en_follower = 1;
            end
            // tb_data_leader   = tx_leader;
            // tb_data_follower = tx_follower;
            // tb_data_en_leader   = 1;
            // tb_data_en_follower = 1;
            // #20;
            // tb_data_en_leader   = 0;
            // tb_data_en_follower = 0;
        end
    endtask

    // Data verification
    task verify_data;
        input mode;  // 1 = leader, 0 = follower
        input [7:0] expected;
        begin
            #50;
            if (mode) begin
                if (data_leader !== expected) begin
                    $display("Leader received 0x%02X, expected 0x%02X", data_leader, expected);
                    $finish;
                end else begin
                    $display("Leader received correct data: 0x%02X", data_leader);
                end
            end else begin
                if (data_follower !== expected) begin
                    $display("Follower received 0x%02X, expected 0x%02X", data_follower, expected);
                    $finish;
                end else begin
                    $display("Follower received correct data: 0x%02X", data_follower);
                end
            end
        end
    endtask

    // always @ (posedge clk) begin
    //     // $display("ext clk: ", ext_clk);
    //     $display("cs: ", cs);
    // end

endmodule
