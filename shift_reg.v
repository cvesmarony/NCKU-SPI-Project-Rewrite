module shift_reg #(
    parameter DATA_LEN = 8
)(
    input                       clk,
    input                       rst,
    input wire [DATA_LEN-1:0]   data_in,       // Parallel input from CPU
    input                       sample_en,     // Load parallel input to shift register
    input                       shift_en,      // Enable shifting
    input                       serial_in,     // Serial input (MISO or MOSI)
    output wire                 serial_out,    // Serial output (MOSI or MISO)
    output reg [DATA_LEN-1:0]   data_out,      // Parallel output to CPU
    input                       load
);

    assign serial_out = data_out[0];  // LSB-first output

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 8'b0;
        end else begin
            if (sample_en) begin
                data_out <= data_in;
            end else if (shift_en) begin
                data_out <= {serial_in, data_out[DATA_LEN-1:1]};  // Shift right, LSB first
            end
            if (load) begin
                data_out <= data_in;
            end
        end
    end

endmodule
