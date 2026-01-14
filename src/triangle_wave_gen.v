module triangle_wave_gen (
    input wire clk,                            // Clock đầu vào
    input wire rst_n,                          // Reset active-low
    input wire [7:0] phase,                    // Phase 8-bit
    output reg signed [11:0] triangle_wave     // Sóng tam giác 12-bit signed
);

    // Các tham số để kiểm soát biên độ
    localparam MAX_AMPLITUDE = 12'sd2047;      // Biên độ tối đa cho 12-bit signed
    localparam MIN_AMPLITUDE = -12'sd2047;     // Biên độ tối thiểu

    // Tính toán khoảng cách từ đỉnh
    wire [7:0] distance_from_peak;
    wire signed [11:0] raw_triangle;

    // Tính giá trị tuyệt đối của (phase - 128)
    assign distance_from_peak = (phase[7]) ? (8'd255 - phase) : phase;

    // Tính sóng tam giác: nhân với hệ số để đảm bảo biên độ hợp lý
    // Chia tỷ lệ để tránh tràn số: (distance_from_peak * 16) - 2048
    assign raw_triangle = ($signed({1'b0, distance_from_peak}) <<< 4) - 12'sd2048;

    // Đồng bộ hóa đầu ra
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            triangle_wave <= 12'sd0;           // Reset đầu ra về 0
        end else begin
            // Giới hạn biên độ để tránh clipping
            if (raw_triangle > MAX_AMPLITUDE)
                triangle_wave <= MAX_AMPLITUDE;
            else if (raw_triangle < MIN_AMPLITUDE)
                triangle_wave <= MIN_AMPLITUDE;
            else
                triangle_wave <= raw_triangle;
        end
    end

endmodule