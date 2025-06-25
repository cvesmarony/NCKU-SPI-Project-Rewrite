`include "spi_defines.vh"

module shift_reg_tx_tb;
    parameter DATA_LEN = `DATA_LEN;

    reg clk, rst, load_en, shift_en;
    reg [DATA_LEN-1:0] d_in;
    wire serial_out;
    wire [DATA_LEN-1:0] d_out;
    reg serial_in = 0; // not used in MOSI test

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

    initial begin
        $dumpfile("shift_reg_tx.vcd");
        $dumpvars(0, shift_reg_tx_tb);
        $display("=== MOSI Shift Register Test ===");

        rst = 1; load_en = 0; shift_en = 0; d_in = 0;
        #10 rst = 0;

        // Load value
        d_in = 8'b10110011;
        load_en = 1; #10; load_en = 0;

        // Shift out bits
        repeat (DATA_LEN) begin
            shift_en = 1;
            #10;
            $display("Shifted out bit: %b | d_out: %b", serial_out, d_out);
        end

        shift_en = 0;
        $finish;
    end
endmodule