module multiplexer (
    input wire signed [11:0] sine_in,
    input wire signed [11:0] square_in,
    input wire signed [11:0] triangle_in,
    input wire signed [11:0] sawtooth_in,
    input wire signed [11:0] noise,
    input wire signed [11:0] ecg_in,
    input wire [2:0] wave_sel,     // Chọn dạng sóng
    input wire noise_en,           // Bật/tắt nhiễu
    output reg signed [11:0] wave_mux
);

    localparam MAX_AMPLITUDE = 12'sd2047;
    localparam MIN_AMPLITUDE = -12'sd2048;

    reg signed [11:0] selected_wave;
    wire signed [12:0] sum; // 13-bit để phát hiện tràn

    // Chọn sóng
    always @(*) begin
        case (wave_sel)
            3'b000: selected_wave = sine_in;
            3'b001: selected_wave = square_in;
            3'b010: selected_wave = triangle_in;
            3'b011: selected_wave = sawtooth_in;
            3'b100: selected_wave = ecg_in;
            default: selected_wave = 12'sd0;
        endcase
    end

    // Cộng nhiễu (nếu bật)
    assign sum = selected_wave + (noise_en ? noise : 12'sd0);

    // Giới hạn clipping
    always @(*) begin
        if (sum > MAX_AMPLITUDE)
            wave_mux = MAX_AMPLITUDE;
        else if (sum < MIN_AMPLITUDE)
            wave_mux = MIN_AMPLITUDE;
        else
            wave_mux = sum[11:0];
    end

endmodule