module i2s_master (
    input wire clk,         // Clock 50MHz từ FPGA
    input wire rst_n,       // Reset active low
    input wire [7:0] wave_data, // Dữ liệu sóng 8-bit từ module tạo sóng
    input wire data_valid,  // Tín hiệu báo dữ liệu sóng sẵn sàng
    output reg bclk,        // Bit Clock cho I2S
    output reg daclrck,     // Left/Right Clock cho I2S
    output reg dacdat       // Dữ liệu sóng số gửi đến WM8731
);

    // Chia tần số clock
    reg [11:0] clk_div;
    localparam BCLK_DIV = 16; // BCLK ~ 1.5625MHz (50MHz / 32), cho 48kHz sample rate

    // Điều khiển I2S
    reg [4:0] bit_count;    // Đếm 16 bit cho mỗi kênh
    reg [15:0] shift_reg;   // Thanh ghi dịch chứa dữ liệu 16-bit

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
            bclk <= 0;
            daclrck <= 0;
            dacdat <= 0;
            bit_count <= 0;
            shift_reg <= 0;
        end else begin
            clk_div <= clk_div + 1;
            if (clk_div == BCLK_DIV - 1) begin
                clk_div <= 0;
                bclk <= ~bclk;

                if (bclk) begin // Cạnh xuống của BCLK
                    if (data_valid && bit_count == 0) begin
                        shift_reg <= {wave_data, 8'b0}; // Mở rộng 8-bit thành 16-bit bằng padding 0
                        bit_count <= 15;               // Gửi 16 bit
                        daclrck <= 0;                  // Chỉ gửi 1 kênh (trái)
                    end
                    if (bit_count > 0) begin
                        dacdat <= shift_reg[bit_count];
                        bit_count <= bit_count - 1;
                    end else begin
                        dacdat <= 0; // Giữ đầu ra thấp khi không gửi
                    end
                end
            end
        end
    end

endmodule