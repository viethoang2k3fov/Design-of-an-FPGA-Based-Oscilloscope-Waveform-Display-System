module phase_generator (
    input  wire clk,
    input  wire rst_n,
    output reg [7:0] phase
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase <= 8'd0;
        else
            phase <= phase + 8'd1;  // Tăng dần để tạo sóng liên tục
    end

endmodule