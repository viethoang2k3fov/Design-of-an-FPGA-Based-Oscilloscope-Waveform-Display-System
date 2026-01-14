module fir_filter (
    input wire clk,                         // Clock hệ thống
    input wire rst_n,                       // Active-low reset
    input wire signed [7:0] data_in,        // Dữ liệu đầu vào (8-bit)
    output wire signed [7:0] data_out,      // Dữ liệu đầu ra (8-bit)
    output wire signed [7:0] debug_tap      // Tap cuối để debug nếu cần
);

parameter N = 65;

reg signed [7:0] delayholder [N-1:0];             // Lưu trữ các mẫu tín hiệu
wire signed [31:0] summation [N-1:0];              // Kết quả nhân hệ số x mẫu
reg signed [23:0] finsummations_register [N-1:0];  // Dữ liệu sau shift
reg signed [23:0] finsummation_register;           // Tổng cuối cùng trước khi rút gọn
reg signed [7:0] output_register;                  // Dữ liệu đầu ra (8-bit)

reg signed [23:0] coeffs [0:1000];                 // Bộ hệ số

integer x, z;

// ===== Khởi tạo hệ số đối xứng =====
initial begin
    coeffs[0]  = 20;
    coeffs[1]  = 21;
    coeffs[2]  = -30;
    coeffs[3]  = -28;
    coeffs[4]  = 25;
    coeffs[5]  = 59;
    coeffs[6]  = -19;
    coeffs[7]  = -91;
    coeffs[8]  = -9;
    coeffs[9]  = 126;
    coeffs[10] = 57;
    coeffs[11] = -150;
    coeffs[12] = -132;
    coeffs[13] = 154;
    coeffs[14] = 231;
    coeffs[15] = -120;
    coeffs[16] = -347;
    coeffs[17] = 33;
    coeffs[18] = 464;
    coeffs[19] = 123;
    coeffs[20] = -560;
    coeffs[21] = -361;
    coeffs[22] = 604;
    coeffs[23] = -695;
    coeffs[24] = -555;
    coeffs[25] = -1147;
    coeffs[26] = 345;
    coeffs[27] = 1779;
    coeffs[28] = 174;
    coeffs[29] = -2828;
    coeffs[30] = -1576;
    coeffs[31] = 5930;
    coeffs[32] = 13540;

    for (x = 0; x <= 32; x = x + 1)
        coeffs[33 + x] = coeffs[32 - x];
end

// ===== Sinh khối nhân song song =====
genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : mult_gen
        multiplier_pre mult_inst (
            .dataa(coeffs[i]),
            .datab(delayholder[i]),
            .result(summation[i])
        );
    end
endgenerate

assign data_out = output_register;
assign debug_tap = delayholder[N-1];

// ===== Mạch lọc FIR chính =====
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        output_register <= 0;
        for (z = 0; z < N; z = z + 1)
            delayholder[z] <= 0;
    end else begin
        // Shift tín hiệu
        for (z = N-1; z > 0; z = z - 1)
            delayholder[z] <= delayholder[z-1];
        delayholder[0] <= data_in;

        // Shift phải và cộng dồn
        for (z = 0; z < N; z = z + 1)
            finsummations_register[z] <= summation[z][31] ? 
                (summation[z][31:15] + 1) : (summation[z][29:15] + 5);

        finsummation_register = 0;
        for (z = 0; z < N; z = z + 1)
            finsummation_register = finsummation_register + finsummations_register[z];

        // Cắt giảm từ 24-bit -> 8-bit output (kết quả lọc)
        output_register <= finsummation_register[23:16];
    end
end

endmodule
