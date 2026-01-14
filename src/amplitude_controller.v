module amplitude_controller (
    input wire signed [11:0] wave_in,
    input wire [3:0] amplitude_factor,
    output reg signed [11:0] wave_out
);

    wire signed [15:0] amp_signed;
    wire signed [23:0] scaled_wave;
    wire signed [11:0] scaled_shifted;

    assign amp_signed = amplitude_factor * 16; // hệ số từ 0 -> 240
    assign scaled_wave = wave_in * amp_signed;
    assign scaled_shifted = scaled_wave[18:7]; // shift toán học tương đương scaled_wave >>> 7

    always @(*) begin
        // Saturation logic: clip biên
        if (scaled_shifted > 12'sd2047)
            wave_out = 12'sd2047;
        else if (scaled_shifted < -12'sd2048)
            wave_out = -12'sd2048;
        else
            wave_out = scaled_shifted;
    end
endmodule
