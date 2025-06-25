`include "spi_defines.vh"

module shift_reg_rx_tb;
    parameter DATA_LEN = `DATA_LEN;

    reg clk, rst, load_en, shift_en;
    reg [DATA_LEN-1:0] d_in = 0; // unused in MISO test
    reg serial_in;
    wire serial_out;
    wire [DATA_LEN-1:0] d_out;

    shift_reg #(.DATA_LEN(DATA_LEN)) dut (
        .clk(clk),
        .rst(rst),
        .d_in(d_in),
        .load_en(load_en),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .d_out(d_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test serial input bits
    reg [DATA_LEN-1:0] serial_input = 8'b11001101;
    integer i;

    initial begin
        $dumpfile("shift_reg_rx.vcd");
        $dumpvars(0, shift_reg_rx_tb);
        $display("=== MISO Shift Register Test ===");

        rst = 1; load_en = 0; shift_en = 0;
        #10 rst = 0;

        // Shift in bits
        for (i = 0; i < DATA_LEN; i = i + 1) begin
            serial_in = serial_input[DATA_LEN - 1 - i];
            shift_en = 1;
            #10;
            $display("Shifted in bit: %b | d_out: %b", serial_in, d_out);
        end

        shift_en = 0;
        $finish;
    end
endmodule