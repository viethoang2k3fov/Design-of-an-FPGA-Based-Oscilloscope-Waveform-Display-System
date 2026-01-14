module waveform_gen_adv (
    input wire clk,                // Clock 50MHz từ FPGA
    input wire rst_n,              // Tín hiệu reset
    input wire [2:0] wave_sel,     // Chọn dạng sóng (sine, square, triangle, sawtooth)
    input wire noise_en,           // Bật/tắt nhiễu
    input wire btn_inc_amp,        // Nút bấm tăng biên độ
    input wire btn_dec_amp,        // Nút bấm giảm biên độ
    input wire btn_inc_freq,       // Nút bấm tăng tần số
    input wire btn_dec_freq,       // Nút bấm giảm tần số
    input wire btn_inc_noise,      // Nút bấm tăng nhiễu
    input wire btn_dec_noise,      // Nút bấm giảm nhiễu
    output wire clk_test,
    output wire signed [11:0] sine_test,
    output wire [11:0] sawtooth_test,
    output wire [11:0] ecg_test, 
    output wire signed [11:0] square_test,
    output wire [7:0] phase_test,
    output wire signed [11:0] noise_test,
    output wire [11:0] triangle_test,
    output wire signed [11:0] wave_mux_test,
    output wire signed [11:0] wave_out, // Sóng đầu ra
    output wire signed [11:0] pre_fir_test
);

    // ======= Clock Division =======
    wire clk_out; // Clock sau chia tần số
    clk_divider clk_div (
        .clk(clk),
        .rst_n(rst_n),
        .clk_out(clk_out)
    );
    assign clk_test = clk_out;

    // ======= Amplitude and Frequency Control =======
    wire [3:0] amp_factor;
    wire [3:0] freq_factor;
    wire [4:0] noise_amp_factor;

    control_unit ctrl_unit (
        .clk(clk_out),
        .rst_n(rst_n),
        .btn_inc_amp(btn_inc_amp),
        .btn_dec_amp(btn_dec_amp),
        .btn_inc_freq(btn_inc_freq),
        .btn_dec_freq(btn_dec_freq),
        .btn_inc_noise(btn_inc_noise),
        .btn_dec_noise(btn_dec_noise),
        .amp_factor(amp_factor),
        .freq_factor(freq_factor),
        .noise_amp_factor(noise_amp_factor)
    );

    // ======= Frequency Controller =======
    wire [7:0] phase;
    frequency_controller freq_ctrl (
        .clk(clk_out),
        .rst_n(rst_n),
        .frequency_factor(freq_factor),
        .phase(phase)
    );
    assign phase_test = phase;

    // ======= Waveform Generators =======
    wire signed [11:0] sine_wave;
    wire [11:0] triangle_wave, sawtooth_wave;
    wire signed [11:0] square_wave, noise;
    wire [11:0] ecg_waveform;

    sine_wave_gen sine_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        .phase(phase),
        .sine_wave(sine_wave)
    );
    assign sine_test = sine_wave;

    square_wave_gen square_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        .phase(phase), 
        .square_wave(square_wave)
    );
    assign square_test = square_wave;

    triangle_wave_gen triangle_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        .phase(phase),
        .triangle_wave(triangle_wave)
    );
    assign triangle_test = triangle_wave;

    sawtooth_wave_gen sawtooth_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        .phase(phase),
        .sawtooth_wave(sawtooth_wave)
    );
    assign sawtooth_test = sawtooth_wave;

    noise_generator noise_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        //.phase(phase),
        .noise_out(noise),
        .noise_amp_factor(noise_amp_factor)
    );
    assign noise_test = noise;

    ECG_wave_gen ecg_gen (
        .clk(clk_out),
        .rst_n(rst_n),
        .phase(phase),
        .ecg_waveform(ecg_waveform)
    );
    assign ecg_test = ecg_waveform;

    // ======= Multiplexer =======
    wire signed [11:0] selected_wave;
    assign wave_mux_test = selected_wave;
    multiplexer wave_mux (
        .sine_in(sine_wave),
        .square_in(square_wave),
        .triangle_in(triangle_wave),
        .sawtooth_in(sawtooth_wave),
        .noise(noise),
        .wave_sel(wave_sel),
        .ecg_in(ecg_waveform),  
        .noise_en(noise_en),
        .wave_mux(selected_wave)
    );

    // ======= Amplitude Controller =======
    wire signed [11:0] amplified_wave;
    amplitude_controller amp_ctrl (
        .wave_in(selected_wave),
        .amplitude_factor(amp_factor),
        .wave_out(amplified_wave)
    );

    // ======= FIR Filter =======
    wire signed [23:0] filtered_signal;

    symmetricFIR fir_inst (
        .clk(clk_out),
        .rst_n(rst_n),
        .noisy_signal(amplified_wave),
        .filtered_signal(filtered_signal)
    );

    // ======= Output Assignments =======
    assign pre_fir_test = amplified_wave;           // Debug trước lọc
    assign wave_out = filtered_signal[22:11];       // Rút gọn từ 24-bit -> 12-bit signed

endmodule
