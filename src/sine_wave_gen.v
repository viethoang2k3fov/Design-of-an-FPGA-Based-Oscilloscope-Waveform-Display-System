module sine_wave_gen (
    input wire clk,
    input wire rst_n,
    input wire [7:0] phase,                // Pha đầu vào
    output reg signed [11:0] sine_wave     // Sóng sin đầu ra (12-bit signed)
);

    // LUT 1/4 chu kỳ, đã scale trước: giá trị 12-bit unsigned từ 0 đến 2047
    wire [11:0] lut[0:63];

    assign lut[0]  = 12'd0;    assign lut[1]  = 12'd32;   assign lut[2]  = 12'd63;   assign lut[3]  = 12'd95;
    assign lut[4]  = 12'd126;  assign lut[5]  = 12'd158;  assign lut[6]  = 12'd189;  assign lut[7]  = 12'd220;
    assign lut[8]  = 12'd251;  assign lut[9]  = 12'd282;  assign lut[10] = 12'd313;  assign lut[11] = 12'd343;
    assign lut[12] = 12'd374;  assign lut[13] = 12'd404;  assign lut[14] = 12'd433;  assign lut[15] = 12'd463;
    assign lut[16] = 12'd492;  assign lut[17] = 12'd521;  assign lut[18] = 12'd549;  assign lut[19] = 12'd577;
    assign lut[20] = 12'd605;  assign lut[21] = 12'd632;  assign lut[22] = 12'd659;  assign lut[23] = 12'd685;
    assign lut[24] = 12'd711;  assign lut[25] = 12'd736;  assign lut[26] = 12'd761;  assign lut[27] = 12'd785;
    assign lut[28] = 12'd809;  assign lut[29] = 12'd832;  assign lut[30] = 12'd855;  assign lut[31] = 12'd877;
    assign lut[32] = 12'd899;  assign lut[33] = 12'd920;  assign lut[34] = 12'd940;  assign lut[35] = 12'd960;
    assign lut[36] = 12'd979;  assign lut[37] = 12'd998;  assign lut[38] = 12'd1016; assign lut[39] = 12'd1033;
    assign lut[40] = 12'd1050; assign lut[41] = 12'd1066; assign lut[42] = 12'd1082; assign lut[43] = 12'd1097;
    assign lut[44] = 12'd1111; assign lut[45] = 12'd1125; assign lut[46] = 12'd1138; assign lut[47] = 12'd1150;
    assign lut[48] = 12'd1162; assign lut[49] = 12'd1173; assign lut[50] = 12'd1183; assign lut[51] = 12'd1193;
    assign lut[52] = 12'd1202; assign lut[53] = 12'd1210; assign lut[54] = 12'd1218; assign lut[55] = 12'd1225;
    assign lut[56] = 12'd1231; assign lut[57] = 12'd1237; assign lut[58] = 12'd1242; assign lut[59] = 12'd1246;
    assign lut[60] = 12'd1250; assign lut[61] = 12'd1253; assign lut[62] = 12'd1255; assign lut[63] = 12'd1257;

    reg signed [11:0] value;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sine_wave <= 12'sd0;
        end else begin
            case (phase[7:6])
                2'b00: value <= lut[phase[5:0]];          // 0°–90°
                2'b01: value <= lut[~phase[5:0]];         // 90°–180°
                2'b10: value <= -lut[phase[5:0]];         // 180°–270°
                2'b11: value <= -lut[~phase[5:0]];        // 270°–360°
            endcase
            sine_wave <= value;
        end
    end

endmodule
