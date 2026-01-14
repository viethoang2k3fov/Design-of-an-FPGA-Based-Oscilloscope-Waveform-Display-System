module sawtooth_wave_gen (
    input wire clk,       // Clock sau chia
    input wire rst_n,     // Reset
    input wire [7:0] phase, // Phase để đồng bộ
    output reg signed [11:0] sawtooth_wave
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sawtooth_wave <= 12'sd0;
        else begin
            // Scale phase (0-255) to -2048 to +2047
            // Công thức: (phase * 16) - 2048
            sawtooth_wave <= ($signed({1'b0, phase}) <<< 4) - 12'sd2048;
        end
    end

endmodule
