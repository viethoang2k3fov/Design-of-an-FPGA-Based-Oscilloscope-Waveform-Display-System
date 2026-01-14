// wm8731_top.v
// Top module phát dạng sóng sin ra Line Out thông qua WM8731 bằng I2S

module wm8731_top (
    input clk_50,            // Clock 50MHz
    input reset_n,           // Active low reset
    input wire [2:0] wave_sel,
    input wire noise_en,
    input wire btn_inc_amp,
    input wire btn_dec_amp,
    input wire btn_inc_freq,
    input wire btn_dec_freq,

    output wire AUD_XCK,     // Master clock for WM8731
    output wire AUD_BCLK,    // I2S bit clock
    output wire AUD_DACDAT,  // I2S serial data
    output wire AUD_DACLRCK, // I2S LR clock
    output wire I2C_SCL,     // I2C clock
    inout wire I2C_SDA       // I2C data
);

    wire [11:0] wave_data;
    wire clk_12_288MHz;
    wire clk_48kHz;

    // PLL hoặc clock divider tạo clock 12.288MHz và 48kHz
    clock_gen clkgen (
        .clk_in(clk_50),
        .clk_12_288MHz(clk_12_288MHz),
        .clk_48kHz(clk_48kHz)
    );

    assign AUD_XCK = clk_12_288MHz; // Master clock cung cấp cho WM8731

    // Bộ tạo dạng sóng nâng cao
    waveform_gen_adv waveform_gen_inst (
        .clk(clk_50),
        .rst_n(reset_n),
        .wave_sel(wave_sel),
        .noise_en(noise_en),
        .btn_inc_amp(btn_inc_amp),
        .btn_dec_amp(btn_dec_amp),
        .btn_inc_freq(btn_inc_freq),
        .btn_dec_freq(btn_dec_freq),
        .clk_test(),
        .sine_test(),
        .sawtooth_test(),
        .ecg_test(),
        .square_test(),
        .phase_test(),
        .noise_test(),
        .triangle_test(),
        .wave_mux_test(),
        .wave_out(wave_data),
        .pre_fir_test()
    );

    // Giao tiếp I2S
    i2s_transmitter i2s_tx (
        .clk(clk_12_288MHz),
        .reset(reset_n),
        .sample_data(wave_data),
        .bclk(AUD_BCLK),
        .lrck(AUD_DACLRCK),
        .sdata(AUD_DACDAT)
    );

    // Giao tiếp I2C để cấu hình WM8731
    wm8731_config i2c_cfg (
        .clk(clk_50),
        .reset(reset_n),
        .i2c_scl(I2C_SCL),
        .i2c_sda(I2C_SDA)
    );

endmodule