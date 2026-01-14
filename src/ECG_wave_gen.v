module ECG_wave_gen (
    input wire clk,          // Clock đã chia
    input wire rst_n,        // Reset
    input wire [7:0] phase,  // Pha đầu vào (dùng 0-63)
    output reg signed [11:0] ecg_waveform
);

    // LUT chứa mẫu sóng ECG (64 mẫu, 12-bit signed, biên độ ±1024)
    wire signed [11:0] ecg_lut [0:63];
// LUT từ Python, chuẩn hóa cho QRS ~±1536
    assign ecg_lut[0]  = 12'sd0;    assign ecg_lut[1]  = 12'sd3;    assign ecg_lut[2]  = 12'sd7;    assign ecg_lut[3]  = 12'sd12;
    assign ecg_lut[4]  = 12'sd18;   assign ecg_lut[5]  = 12'sd25;   assign ecg_lut[6]  = 12'sd32;   assign ecg_lut[7]  = 12'sd40;
    assign ecg_lut[8]  = 12'sd48;   assign ecg_lut[9]  = 12'sd55;   assign ecg_lut[10] = 12'sd62;   assign ecg_lut[11] = 12'sd68;
    assign ecg_lut[12] = 12'sd73;   assign ecg_lut[13] = 12'sd77;   assign ecg_lut[14] = 12'sd81;   assign ecg_lut[15] = 12'sd84;
    assign ecg_lut[16] = 12'sd87;   assign ecg_lut[17] = 12'sd90;   assign ecg_lut[18] = 12'sd94;   assign ecg_lut[19] = 12'sd99;
    assign ecg_lut[20] = 12'sd107;  assign ecg_lut[21] = 12'sd120;  assign ecg_lut[22] = 12'sd141;  assign ecg_lut[23] = 12'sd174;
    assign ecg_lut[24] = 12'sd232;  assign ecg_lut[25] = 12'sd341;  assign ecg_lut[26] = 12'sd550;  assign ecg_lut[27] = 12'sd912;
    assign ecg_lut[28] = 12'sd1377; assign ecg_lut[29] = 12'sd1536; assign ecg_lut[30] = 12'sd1219; assign ecg_lut[31] = 12'sd766;
    assign ecg_lut[32] = 12'sd374;  assign ecg_lut[33] = 12'sd162;  assign ecg_lut[34] = 12'sd62;   assign ecg_lut[35] = 12'sd17;
    assign ecg_lut[36] = 12'sd2;    assign ecg_lut[37] = 12'sd0;    assign ecg_lut[38] = 12'sd8;    assign ecg_lut[39] = 12'sd24;
    assign ecg_lut[40] = 12'sd46;   assign ecg_lut[41] = 12'sd70;   assign ecg_lut[42] = 12'sd95;   assign ecg_lut[43] = 12'sd119;
    assign ecg_lut[44] = 12'sd141;  assign ecg_lut[45] = 12'sd160;  assign ecg_lut[46] = 12'sd175;  assign ecg_lut[47] = 12'sd187;
    assign ecg_lut[48] = 12'sd194;  assign ecg_lut[49] = 12'sd197;  assign ecg_lut[50] = 12'sd196;  assign ecg_lut[51] = 12'sd191;
    assign ecg_lut[52] = 12'sd183;  assign ecg_lut[53] = 12'sd172;  assign ecg_lut[54] = 12'sd158;  assign ecg_lut[55] = 12'sd141;
    assign ecg_lut[56] = 12'sd122;  assign ecg_lut[57] = 12'sd100;  assign ecg_lut[58] = 12'sd76;   assign ecg_lut[59] = 12'sd50;
    assign ecg_lut[60] = 12'sd23;   assign ecg_lut[61] = 12'sd0;    assign ecg_lut[62] = -12'sd22;  assign ecg_lut[63] = -12'sd38;
    // Đầu ra trực tiếp từ LUT
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ecg_waveform <= 12'sd0;
        else
            ecg_waveform <= ecg_lut[phase[5:0]]; // Chỉ dùng 6 bit thấp của phase (0-63)
    end

endmodule