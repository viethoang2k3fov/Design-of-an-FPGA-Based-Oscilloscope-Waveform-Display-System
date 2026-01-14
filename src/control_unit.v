module control_unit (
    input wire clk,
    input wire rst_n,
    input wire btn_inc_amp,
    input wire btn_dec_amp,
    input wire btn_inc_freq,
    input wire btn_dec_freq,
    input wire btn_inc_noise,         // Nút tăng nhiễu
    input wire btn_dec_noise,         // Nút giảm nhiễu
    output reg [3:0] amp_factor,
    output reg [3:0] freq_factor,
    output reg [4:0] noise_amp_factor // Biên độ nhiễu, dải 0–31
);

    reg [17:0] counter;  // 18-bit để debounce ~2.6ms tại 50MHz
    reg btn_inc_amp_prev, btn_dec_amp_prev;
    reg btn_inc_freq_prev, btn_dec_freq_prev;
    reg btn_inc_noise_prev, btn_dec_noise_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            amp_factor <= 4'd8;
            freq_factor <= 4'd8;
            noise_amp_factor <= 5'd16;  // Giá trị mặc định trung bình
            counter <= 0;

            btn_inc_amp_prev <= 0;
            btn_dec_amp_prev <= 0;
            btn_inc_freq_prev <= 0;
            btn_dec_freq_prev <= 0;
            btn_inc_noise_prev <= 0;
            btn_dec_noise_prev <= 0;
        end else begin
            if (counter == 18'd200000) begin
                counter <= 0;

                // Amplitude
                if (btn_inc_amp && !btn_inc_amp_prev && amp_factor < 4'd15)
                    amp_factor <= amp_factor + 1;
                else if (btn_dec_amp && !btn_dec_amp_prev && amp_factor > 4'd0)
                    amp_factor <= amp_factor - 1;

                // Frequency
                if (btn_inc_freq && !btn_inc_freq_prev && freq_factor < 4'd15)
                    freq_factor <= freq_factor + 1;
                else if (btn_dec_freq && !btn_dec_freq_prev && freq_factor > 4'd0)
                    freq_factor <= freq_factor - 1;

                // Noise amplitude
                if (btn_inc_noise && !btn_inc_noise_prev && noise_amp_factor < 5'd31)
                    noise_amp_factor <= noise_amp_factor + 1;
                else if (btn_dec_noise && !btn_dec_noise_prev && noise_amp_factor > 5'd0)
                    noise_amp_factor <= noise_amp_factor - 1;

                // Cập nhật trạng thái trước đó
                btn_inc_amp_prev <= btn_inc_amp;
                btn_dec_amp_prev <= btn_dec_amp;
                btn_inc_freq_prev <= btn_inc_freq;
                btn_dec_freq_prev <= btn_dec_freq;
                btn_inc_noise_prev <= btn_inc_noise;
                btn_dec_noise_prev <= btn_dec_noise;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
