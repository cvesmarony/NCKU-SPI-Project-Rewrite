module top (
        input  wire        clk,             // CPU/System clock
        input  wire        rst,             // Global reset
        input  wire        in,              // Data received

        inout  wire [7:0]  data,            // CPU data bus (bidirectional)
        inout  wire        cs,              // Chip select (driven in leader mode)
        inout  wire        ext_clk,         // SPI clock (driven in leader mode)

        output wire        out              // Data sent
    );

    // Configuration Settings
    reg [7:0]   config_reg;
    reg         config_set;
    reg         set;

    // Parse configuration fields
    // wire        mode  = config_reg[7];          // 1 = leader, 0 = follower
    // wire        len   = config_reg[6];          // 1 = 16 bits, 0 = 8 bits; data length
    // wire        cpol  = config_reg[5];          // clock polarity
    // wire        cpha  = config_reg[4];          // clock phase
    // wire [2:0]  div   = config_reg[3:1];        // divider (configured in clkgen)
    reg mode, len, cpol, cpha;
    reg [2:0] div;
    reg [4:0] count;                            // bit count for bits sent/received
    // integer count;
    wire sclk, sclk_pe, sclk_ne;

    // Data length configuration
    reg [4:0]  data_len;                       // up to 16
    always @ (*) begin
        case (len)
            1'b0:       data_len <= 8;
            1'b1:       data_len <= 16;
            default:    data_len <= 8;
        endcase
    end


    // wire [len-1:0] txi;                     // input to transmitted shift reg
    // wire [len-1:0] txo;                     // output to transmitted shift reg
    // wire [len-1:0] rxi;                     // input to received shift reg
    // wire [len-1:0] rxo;                     // output to received shift reg

    // reg [15:0] txi, rxi;    // tx input/output buffer regs
    // wire [15:0] txo, rxo;   // outputs from shift reg modules
    reg [7:0] txi, rxi;    // tx input/output buffer regs
    wire [7:0] txo, rxo;   // outputs from shift reg modules


    // CPU interface data handling
    reg data_en;
    // reg [7:0] data_out;
    wire [7:0] data_in = data;
    // assign data = data_en ? rxo : 8'bz;
    assign data = data_en ? rxo : 8'bz;

    reg shift_tx = 0;
    reg shift_rx = 0;
    reg sample_tx = 0; 
    reg sample_rx = 0;

    // CS tristate control
    reg cs_en;
    reg cs_out;
    wire cs_in = cs;
    assign cs = cs_en ? cs_out : 1'bz;

    // ext_clk tristate control
    reg ext_clk_en;
    // reg ext_clk_out;
    wire ext_clk_in = ext_clk;
    assign ext_clk = ext_clk_en ? sclk : 1'bz;

    reg shift_edge, sample_edge;
    reg first_edge;
    reg cpol_reg;

    clkgen clock (
        .clk(clk),
        .rst(rst),
        .divider(div),
        .cpol(cpol),
        .cs(cs),
        .sclk(sclk)
    );

    // Edge detectors on SCLK
    pos_edge_detect ped(.sig(sclk), .clk(clk), .pe(sclk_pe));
    neg_edge_detect ned(.sig(sclk), .clk(clk), .ne(sclk_ne));

    // Leader shift register
    shift_reg transmit (
        .clk(clk),
        .rst(rst),
        .data_in(txi),
        .sample_en(sample_tx),
        .shift_en(shift_tx),
        .serial_in(1'b1),               // Doesn't matter for transmitting; data from CPU (txi)
        .serial_out(out),               // To other device
        .data_out(txo)
    );

    // Follower shift register
    shift_reg receive (
        .clk(clk),
        .rst(rst),
        .data_in(rxi),                  // From other device
        .sample_en(sample_rx),
        .shift_en(shift_rx),
        .serial_in(in),
        .serial_out(),              // Doesn't  matter for transmitting; data not being sent
        .data_out(rxo)
    );

    // Logic for configuring and for reset
    always @(posedge clk or posedge rst) begin
        // Reset values
        if (rst) begin
            config_set <= 0;
            config_reg <= 8'b0;
            data_en <= 0;
            mode <= 0;
            len <= 0;
            cpol <= 0;
            cpha <= 0;
            div <= 3'b0;
            count <= 0;
            first_edge <= 0;
            txi <= 0;
            rxi <= 0;
            set <= 0;
            shift_tx <= 0;
            shift_rx <= 0;
            sample_tx <= 0;
            sample_rx <= 0;
            // sclk_ne <= 0;
            // sclk_pe <= 0;
            shift_edge <= 0;
            sample_edge <= 0;
            // ext_clk_out <= 0;
            
        // Configure if not yet configured
        end else begin
            if (~config_set) begin
            // $display("DATA_EN:", data_en);
            config_reg <= data_in;                             // Config from CPU
            // $display("DATA_IN:", data_in);
            // $display("DATA:", data);
            {mode, len, cpol, cpha, div} <= data[7:1];      // Config reg
            // $display("MODE:", mode);
            // $display("CONFIG:", config_reg);
            // data_en <= 1;                                   // Enable data to send back to CPU
            // config_set <= 1;                                // Config set is true
            // rxi <= 8'hFF;
            set <= 1;
            // $display("RXI:", rxi);
            // data_en <= 1;                                   // Enable data to send back to CPU
            
        // Disable data_en after sending so that CPU knows when to send more data
        // end
            end 
            if (set) begin
                data_en <= 1;
                config_set <= 1;
                // $display(data_en);
                // $display("CONFIG REG:", config_reg);
                // $display("MODE:", mode);
                // $display("DATA:", data);
                // $display("DATA IN:", data_in);
                // $display("RXO:", rxo);
            end
        end
    end

    // Logic for driving CS and ext_clk
    always @ (*) begin
        // Leader drives cs and ext_clk
        if (mode) begin
            $display("Leader mode");
            cs_en = 1;
            cs_out = 0;                 // Enable low
            // $display("CS:", cs);
            // $display("CONFIG:", config_set);
            // $display("count:", count);
            // $display("cpol:", cpol);
            // $display("cpha:", cpha);
            // $display("len:", len);
            // $display("length:", data_len);

            // $display("sample edge:", sample_edge);
            // $display("shift edge:", shift_edge);
            // $display("sclk ne:", sclk_ne);
            // $display("sclk pe:", sclk_pe);

            ext_clk_en = 1;
            // ext_clk_out = sclk;

        // Follower does NOT drive cs or ext_clk
        end else begin
            $display("Follower mode");
            cs_en = 0;
            cs_out = 1'bz;

            ext_clk_en = 0;
            // ext_clk_out = 1'bz;
        end
    end

    // Logic for shifting data
    always @ (posedge clk) begin
        txi <= txo;
        rxi <= rxo;
        // has not sent/received all bits yet and if cs is on and after config
        if ((count < data_len) && ~cs && config_set) begin          // check logic for cs as it is inout
        // while (count < data_len) begin
            // $display("COUNTING") ;
            // Detecing shift and sample edges
            shift_edge  = (cpol == cpha) ? sclk_ne : sclk_pe;
            sample_edge = (cpol == cpha) ? sclk_pe : sclk_ne;
            // $display("sample edge:", sample_edge);
            // $display("shift edge:", shift_edge);
            // $display("sclk ne:", sclk_ne);
            // $display("sclk pe:", sclk_pe);
            // $display("sclk:", sclk);
            // $display("div:", div);
            // $display("cs:", cs);

            // Determining when to shift and sample
            if (cpha == 0) begin
                // $display("YAY");
                shift_tx <= shift_edge;
                shift_rx <= shift_edge;
                sample_tx <= sample_edge;
                sample_rx <= sample_edge;
            end else begin
                if (first_edge) begin
                    shift_tx    <= shift_edge;
                    shift_rx  <= shift_edge;
                    sample_tx   <= sample_edge;
                    sample_rx <= sample_edge;
                end else if (shift_edge || sample_edge)
                    first_edge <= 1;  // Mark the first clock edge seen
            end

            // if (shift_rx) count = count + 1;        // add after shifting
        end
        // end
            // Reset count and shift values
            // count <= 0;
            // shift_tx <= 0;
            // shift_rx <= 0;
            // sample_tx <= 0;
            // sample_rx <= 0;
            // cs_out <= 1;
        // end
    end

    // Logic for counter
    always @(posedge clk) begin
        if (shift_tx) begin
            count <= count + 1;
            $display("shifted");
        end
    end

    // Logic for sending data
    always @(posedge clk) begin
        if (count < data_len && config_set) begin      // check logic
            data_en <= 1;
        end else if (data_en && (count == data_len)) begin
            data_en <= 0; // One cycle pulse
        end
    end

endmodule