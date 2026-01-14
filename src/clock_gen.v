// clock_gen.v
// Module tạo các tín hiệu clock cho hệ thống (12.288 MHz, 48 kHz) và sử dụng wave_data [11:0]

module clock_gen (
    input wire clk_in,          // Clock đầu vào (50MHz)
    input wire reset,           // Reset hệ thống
    output wire clk_12_288MHz,  // Clock 12.288 MHz cho WM8731
    output wire clk_48kHz       // Clock 48 kHz cho giao tiếp I2S
);

    // Các thanh ghi giữ giá trị tần số
    reg [11:0] wave_data_reg;

    // Clock divider cho các tín hiệu clock cần thiết
    reg [7:0] div_12_288MHz = 0;
    reg [15:0] div_48kHz = 0;
    reg clk_12_288MHz_reg = 0;
    reg clk_48kHz_reg = 0;

    // Đưa dữ liệu wave_data vào
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            wave_data_reg <= 12'd0;
        end else begin
            wave_data_reg <= wave_data_reg; // Cập nhật dữ liệu theo yêu cầu
        end
    end

    // Tạo clock 12.288 MHz từ clock 50 MHz
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            div_12_288MHz <= 8'd0;
            clk_12_288MHz_reg <= 0;
        end else begin
            if (div_12_288MHz == 8'd4) begin  // 50MHz / 4 = 12.288MHz
                clk_12_288MHz_reg <= ~clk_12_288MHz_reg;
                div_12_288MHz <= 8'd0;
            end else begin
                div_12_288MHz <= div_12_288MHz + 1;
            end
        end
    end

    // Tạo clock 48 kHz từ clock 50 MHz
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            div_48kHz <= 16'd0;
            clk_48kHz_reg <= 0;
        end else begin
            if (div_48kHz == 16'd1041) begin  // 50MHz / 1041 = 48kHz
                clk_48kHz_reg <= ~clk_48kHz_reg;
                div_48kHz <= 16'd0;
            end else begin
                div_48kHz <= div_48kHz + 1;
            end
        end
    end

    // Gán giá trị cho các output
    assign clk_12_288MHz = clk_12_288MHz_reg;
    assign clk_48kHz = clk_48kHz_reg;

endmodule
