module noise_generator #(
    parameter integer NOISE_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,
    input wire [4:0] noise_amp_factor,  // Hệ số điều chỉnh runtime
    output reg signed [NOISE_WIDTH-1:0] noise_out
);

    reg [15:0] lfsr;
    wire feedback_bit;

    assign feedback_bit = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    wire [3:0] rand_sum = lfsr[0] + lfsr[1] + lfsr[2] + lfsr[3] + lfsr[4];
    wire signed [7:0] centered = {1'b0, rand_sum} - 4'd2;

    wire signed [15:0] scaled_noise = centered * noise_amp_factor;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 16'hACE1;
            noise_out <= 0;
        end else begin
            lfsr <= {lfsr[14:0], feedback_bit};
            noise_out <= scaled_noise[15:4];  // Có thể điều chỉnh bit shift tại đây nếu muốn mạnh hơn
        end
    end
endmodule
