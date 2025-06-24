`include "spi_defines.vh"

module spi_leader #(
    parameter DATA_LEN  = `DATA_LEN,
    parameter CPOL      = `CPOL,
    parameter CPHA      = `CPHA,
    parameter DIV_WIDTH = `DIV_WIDTH
    )(
        input  wire                    clk,         // System clock
        input  wire                    rst,
        input  wire                    start,       // Start transfer
        input  wire [DATA_LEN-1:0]     data_in,     // Data to transmit
        input  wire [DIV_WIDTH-1:0]    divider,
        input  wire                    miso,        // Master In Slave Out

        output wire                    sclk,        // SPI clock output
        output wire                    mosi,        // Master Out Slave In
        output reg                     CS,          // Chip select (active low)
        output reg                     busy,        // Transfer in progress
        output reg [DATA_LEN-1:0]      data_out,    // Received data
        output wire                    data_ready   // Done flag (1-cycle pulse)
    );

    // Internal registers
    reg [DATA_LEN-1:0] tx_data;
    reg [DATA_LEN-1:0] rx_data;
    wire [DATA_LEN-1:0] tx_out, rx_out;

    reg load_tx, load_rx;
    reg TIP;
    reg [$clog2(DATA_LEN):0] bit_count;
    reg data_ready_reg;

    assign data_ready = data_ready_reg;

    // SPI clock generator
    wire clk_out, shift_sig, sample_sig;

    spi_clkgen #(
        .DIV_WIDTH(DIV_WIDTH)
    ) clkgen_inst (
        .sys_clk(clk),
        .rst(rst),
        .divider(divider),
        .TIP(TIP),
        .CS(CS),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .clk_out(clk_out),
        .shift(shift_sig),
        .sample(sample_sig)
    );

    // TX shift register (MOSI)
    shift_reg #(
        .DATA_LEN(DATA_LEN)
    ) tx_shift (
        .clk(clk_out),
        .rst(rst),
        .load_en(load_tx),
        .shift_en(shift_sig),
        .d_in(tx_data),
        .serial_in(1'b0),
        .serial_out(mosi),
        .d_out(tx_out)
    );

    // RX shift register (MISO)
    shift_reg #(
        .DATA_LEN(DATA_LEN)
    ) rx_shift (
        .clk(clk_out),
        .rst(rst),
        .load_en(load_rx),      // Can leave 0 or use to reset if needed
        .shift_en(sample_sig),
        .d_in({DATA_LEN{1'b0}}),
        .serial_in(miso),
        .serial_out(),          // Not needed
        .d_out(rx_out)
    );

    assign sclk = clk_out;

    // State machine
    reg [1:0] state;
    localparam IDLE     = 2'b00;
    localparam LOAD     = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DONE     = 2'b11;

    always @(posedge clk_out or posedge rst) begin
        if (rst) begin
            state           <= IDLE;
            CS              <= 1'b1;
            TIP             <= 1'b0;
            load_tx         <= 1'b0;
            load_rx         <= 1'b0;
            bit_count       <= 0;
            busy            <= 0;
            data_ready_reg  <= 0;
            data_out        <= 0;
        end else begin
            // One-cycle pulses
            load_tx <= 1'b0;
            load_rx <= 1'b0;
            data_ready_reg <= 1'b0;

            case (state)
                IDLE: begin
                    busy <= 0;
                    CS   <= 1;
                    TIP  <= 0;
                    bit_count <= 0;

                    if (start) begin
                        tx_data <= data_in;
                        state   <= LOAD;
                    end
                end

                LOAD: begin
                    load_tx <= 1;
                    load_rx <= 1;
                    CS      <= 0;
                    TIP     <= 1;
                    busy    <= 1;
                    state   <= TRANSFER;
                end

                TRANSFER: begin
                    if (sample_sig) begin
                        bit_count <= bit_count + 1;
                    end

                    if (bit_count == DATA_LEN) begin
                        state <= DONE;
                        TIP   <= 0;
                        rx_data   <= rx_out;
                    end
                end

                DONE: begin
                    CS              <= 1;
                    busy            <= 0;
                    data_ready_reg  <= 1;
                    data_out        <= rx_data;
                    state           <= IDLE;
                end
            endcase
        end
    end

endmodule
