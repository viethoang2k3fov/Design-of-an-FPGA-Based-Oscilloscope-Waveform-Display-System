module square_wave_gen (
    input wire clk,
    input wire rst_n,
    input wire [7:0] phase,  // Dùng toàn bộ phase để tạo sóng vuông
    output reg signed [11:0] square_wave   // Tín hiệu sóng vuông đầu ra (12-bit signed)
);
    parameter signed [11:0] AMPLITUDE = 12'sd1000;  // Biên độ có thể điều chỉnh

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            square_wave <= 12'sd0;
        else
            square_wave <= phase[7] ? AMPLITUDE : -AMPLITUDE;
    end

endmodule
