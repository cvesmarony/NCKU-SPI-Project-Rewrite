`include "spi_defines.vh"

module spi_leader #(
    parameter DATA_LEN = `DATA_LEN,
    parameter DIV_WIDTH = `DIV_WIDTH
    )(
        input wire                      sys_clk,
        input wire                      rst,
        input wire                      go,
        input wire [DIV_WIDTH-1:0]      clk_divider,
        input wire [DATA_LEN-1:0]       tx_data,
        input wire                      miso,
        output wire                     mosi,
        output wire                     sclk,
        output reg                      cs,
        output wire [DATA_LEN-1:0]      rx_data,
        output reg                      busy,
        output reg                      done
    );

    reg [3:0] bit_cnt;
    reg tip;
    reg [DATA_LEN-1:0] rx_reg;

    wire shift_en, sample_en;
    wire clk_out;
    assign sclk = clk_out;

    spi_clkgen clkgen (
        .sys_clk(sys_clk),
        .rst(rst),
        .divider(clk_divider),
        .TIP(tip),
        .CS(cs),
        .CPOL(`CPOL),
        .CPHA(`CPHA),
        .shift(shift_en),
        .sample(sample_en),
        .clk_out(clk_out)
    );

    // Transmit shift register
    reg [DATA_LEN-1:0] tx_shift;
    assign mosi = tx_shift[0];

    // Receive shift register
    always @(posedge sys_clk) begin
        if (sample_en && !cs) begin
            rx_reg <= {miso, rx_reg[DATA_LEN-1:1]};
        end
    end
    assign rx_data = rx_reg;

    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            cs <= 1;
            tip <= 0;
            busy <= 0;
            done <= 0;
            bit_cnt <= 0;
            tx_shift <= 0;
            rx_reg <= 0;
        end else begin
            done <= 0;
            
            if (go && !busy) begin
                cs <= 0;
                tip <= 1;
                busy <= 1;
                bit_cnt <= 0;
                tx_shift <= tx_data;
            end else if (tip) begin
                if (shift_en && !cs) begin
                    tx_shift <= {1'b0, tx_shift[DATA_LEN-1:1]};
                end
                
                if (sample_en && !cs) begin
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == DATA_LEN-1) begin
                        tip <= 0;
                        cs <= 1;
                        busy <= 0;
                        done <= 1;
                    end
                end
            end
        end
    end
endmodule