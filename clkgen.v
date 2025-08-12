module clkgen (
        input wire          clk,
        input wire          rst,
        input wire [2:0]    divider,
        input wire          cpol,
        input wire          cs,

        output reg          sclk
    );

    reg [16:0]      count;
    reg [16:0]      div;
    always @ (*) begin
        case (divider)
            3'b000:      div <= 1;
            3'b001:      div <= 1024;
            3'b010:      div <= 2048;
            3'b011:      div <= 4096;
            3'b100:      div <= 8192;
            3'b101:      div <= 16384;
            3'b110:      div <= 32768;
            3'b111:      div <= 65536;
            default:    div <= 1024;
        endcase
    end

    always @ (posedge clk or posedge rst) begin
        // $display("cpol:", cpol);
        if (rst) begin
//            if (cpol) begin
//                sclk <= 1;
//            end else begin
//                sclk <= 0;
//            end
            sclk <= 0;      // needed to be 0 instead of cpol
            count <= 0;
        end else if (~cs) begin
            if (count >= div) begin
                count <= 0;
                sclk <= ~sclk;
            end else begin
                count <= count + 1;
            end
        end else begin
            if (cpol) begin
                sclk <= 1;
            end else begin
                sclk <= 0;
            end
            count <= 0;
        end
    end

endmodule