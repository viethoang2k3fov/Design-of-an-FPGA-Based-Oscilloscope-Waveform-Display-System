// i2s_transmitter.v
// Giao tiếp I2S để truyền dữ liệu âm thanh tới WM8731

module i2s_transmitter (
    input wire clk,              // Clock 12.288 MHz
    input wire reset,            // Active low reset
    input wire [11:0] sample_data, // Dữ liệu âm thanh 12-bit
    output reg bclk,             // I2S Bit Clock
    output reg lrck,             // I2S Left/Right Clock
    output reg sdata             // I2S Serial Data
);

    // Chia clock bit (BCLK) với tần số 12.288 MHz cho I2S
    reg [3:0] bclk_cnt = 0; // Counter chia tần số BCLK
    reg [11:0] shift_reg = 0; // Register lưu dữ liệu (12-bit)
    reg [4:0] lrck_cnt = 0;   // Counter cho tần số LRCK (48 kHz)

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            bclk <= 0;
            lrck <= 0;
            shift_reg <= 0;
            bclk_cnt <= 0;
            lrck_cnt <= 0;
        end else begin
            // Tạo xung BCLK từ tín hiệu clk (12.288 MHz)
            if (bclk_cnt == 7) begin
                bclk <= ~bclk;
                bclk_cnt <= 0;
            end else begin
                bclk_cnt <= bclk_cnt + 1;
            end

            // Tạo xung LRCK cho tín hiệu trái/phải
            if (lrck_cnt == 23) begin
                lrck <= ~lrck;
                lrck_cnt <= 0;
            end else begin
                lrck_cnt <= lrck_cnt + 1;
            end

            // Dịch dữ liệu âm thanh (sample_data) vào sdata
            if (bclk_cnt == 7) begin
                shift_reg <= {shift_reg[10:0], sample_data[11]};  // Dịch bit từ sample_data
                sdata <= shift_reg[11];  // Truyền dữ liệu bit ra sdata
            end
        end
    end

endmodule
