module clk_divider (
    input  wire clk,      // Clock từ FPGA (50MHz)
    input  wire rst_n,    // Reset
    output reg clk_out    // Clock sau chia (được định nghĩa là reg)
);

    parameter DIV_COUNT = 2; // Chia 50MHz xuống 1kHz
    reg [15:0] counter; // Cần đủ bit để đếm tới DIV_COUNT

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;  // Reset clk_out về 0
        end else begin
            if (counter == (DIV_COUNT - 1)) begin
                counter <= 0;
                clk_out <= ~clk_out; // Đảo trạng thái của clock
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule