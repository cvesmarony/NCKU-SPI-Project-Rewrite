`include "spi_defines.vh"

module spi_follower #(
    parameter DATA_LEN = 8
)(
    input wire                    clk,
    input wire                    rst,
    input wire                    sclk,
    input wire                    cs,
    input wire                    mosi,
    input wire [DATA_LEN-1:0]     tx_data,
    output wire                   miso,
    output wire [DATA_LEN-1:0]    rx_data,
    output reg                    done
);

    reg prev_sclk;
    reg prev_cs;
    reg [DATA_LEN-1:0] rx_shift, tx_shift;
    reg [3:0] bit_cnt;

    assign miso = tx_shift[0];
    assign rx_data = rx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_sclk <= 0;
            prev_cs <= 1;
            bit_cnt <= 0;
            rx_shift <= 0;
            tx_shift <= 0;
            done <= 0;
        end else begin
            prev_sclk <= sclk;
            prev_cs <= cs;
            done <= 0;

            // Load TX data when CS goes low (start of transfer)
            if (prev_cs && !cs) begin
                tx_shift <= tx_data; // preload shift reg
                bit_cnt <= 0;
                rx_shift <= 0;
            end

            if (!cs) begin
                // Sample MOSI on SCLK rising edge
                if (!prev_sclk && sclk) begin
                    rx_shift <= {mosi, rx_shift[DATA_LEN-1:1]};
                    if (bit_cnt == DATA_LEN-1) begin
                        done <= 1;
                    end
                end

                // Shift MISO on SCLK falling edge
                if (prev_sclk && !sclk) begin
                    tx_shift <= {1'b0, tx_shift[DATA_LEN-1:1]};
                    if (!done) begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end
            end
        end
    end
endmodule