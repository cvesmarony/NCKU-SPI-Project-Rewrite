module shift_tb;

    parameter DATA_LEN = 8;
    reg clk, rst;
    reg sample_en, shift_en;
    reg serial_in;
    wire serial_out;
    reg [DATA_LEN-1:0] data_in;
    wire [DATA_LEN-1:0] data_out;

    // DUT
    shift_reg #(.DATA_LEN(DATA_LEN)) dut (
        .clk(clk),
        .rst(rst),
        .sample_en(sample_en),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock
    always #5 clk = ~clk;

    task load_data(input [7:0] val);
        begin
            data_in = val;
            #1;              // <== give time for assignment to take effect
            sample_en = 1;
            shift_en = 0;
            @(posedge clk);
            sample_en = 0;
        end
    endtask

    task shift_in_byte(input [7:0] val);
        integer i;
        begin
            shift_en = 1;
            for (i = 0; i < 8; i = i + 1) begin
                serial_in = val[i];  // LSB first
                @(posedge clk);
            end
            shift_en = 0;
        end
    endtask

    initial begin
        $display("=== Shift Register Edge Case Tests ===");
        clk = 0;
        rst = 1;
        sample_en = 0;
        shift_en = 0;
        serial_in = 0;
        data_in = 8'h00;

        #10 rst = 0;

        // 1. Load all 0s
        $display("\n[Case 1] Load all 0s");
        load_data(8'h00);
        #1 $display("  Output = %h (Expected 00)", data_out);

        // 2. Load all 1s
        $display("\n[Case 2] Load all 1s");
        load_data(8'hFF);
        #1 $display("  Output = %h (Expected FF)", data_out);

        // 3. Shift in all 0s
        $display("\n[Case 3] Clear then shift in 0s");
        load_data(8'h00);
        shift_in_byte(8'h00);
        #1 $display("  Output = %h (Expected 00)", data_out);

        // 4. Shift in all 1s
        $display("\n[Case 4] Clear then shift in 1s");
        load_data(8'h00);
        shift_in_byte(8'hFF);
        #1 $display("  Output = %h (Expected FF)", data_out);

        // 5. Shift in alternating bits (10101010)
        $display("\n[Case 5] Shift in 0xAA (10101010)");
        load_data(8'h00);
        shift_in_byte(8'hAA);
        #1 $display("  Output = %h (Expected AA)", data_out);

        // 6. Shift without load (should start from 0)
        $display("\n[Case 6] Shift without loading (in 0xF0)");
        load_data(8'h00);
        shift_in_byte(8'hF0);
        #1 $display("  Output = %h (Expected F0)", data_out);

        // 7. Mid-shift reset
        $display("\n[Case 7] Mid-shift reset");
        load_data(8'h55);
        shift_en = 1;
        serial_in = 1;
        @(posedge clk);  // 1 shift
        rst = 1;
        @(posedge clk);
        rst = 0;
        shift_en = 0;
        #1 $display("  Output = %h (Expected 00 after reset)", data_out);

        $display("\nAll edge cases completed.");
        $finish;
    end

    // Debug Monitor
    always @(posedge clk)
        $display("[%0t] sample=%b shift=%b sin=%b dout=%h sout=%b",
                 $time, sample_en, shift_en, serial_in, data_out, serial_out);

endmodule
