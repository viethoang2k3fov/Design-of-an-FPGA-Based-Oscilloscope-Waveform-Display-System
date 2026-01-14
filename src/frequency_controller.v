module frequency_controller (
    input wire clk,
    input wire rst_n,
    input wire [3:0] frequency_factor,   // Hệ số điều chỉnh tần số (0-15)
    output reg [7:0] phase               // Pha đầu ra
);

    reg [7:0] phase_increment;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase <= 8'd0;
        else
            phase <= phase + phase_increment;
    end

    always @(*) begin
        // Tránh giá trị quá thấp (0) làm phase đứng yên
        if (frequency_factor == 4'd0)
            phase_increment = 8'd1;
        else
            phase_increment = {4'd0, frequency_factor};  // Mở rộng 4-bit thành 8-bit
    end

endmodule
