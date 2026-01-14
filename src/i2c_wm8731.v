module i2c_wm8731 (
    input wire CLOCK,       // Clock 50MHz từ FPGA
    input wire RESET,       // Reset active low
    output reg I2C_SCLK,    // I2C Clock
    inout wire I2C_SDAT,    // I2C Data
    output reg END_TR       // Hoàn thành gửi dữ liệu
);

    // Địa chỉ I2C của WM8731 (7-bit) + bit ghi (0)
    localparam I2C_ADDR = 7'b0011010;
    reg [23:0] I2C_DATA [0:6];
    initial begin
        I2C_DATA[0] = {I2C_ADDR, 1'b0, 7'h0F, 9'h000}; // Reset
        I2C_DATA[1] = {I2C_ADDR, 1'b0, 7'h06, 9'h000}; // Power Management
        I2C_DATA[2] = {I2C_ADDR, 1'b0, 7'h04, 9'h015}; // Analog Audio Path Control
        I2C_DATA[3] = {I2C_ADDR, 1'b0, 7'h05, 9'h000}; // Digital Audio Path Control
        I2C_DATA[4] = {I2C_ADDR, 1'b0, 7'h07, 9'h009}; // I2S Format
        I2C_DATA[5] = {I2C_ADDR, 1'b0, 7'h08, 9'h002}; // Sampling Control (48kHz)
        I2C_DATA[6] = {I2C_ADDR, 1'b0, 7'h09, 9'h001}; // Activate Codec
    end

    reg [7:0] clk_div;      // Chia tần số cho I2C (~100kHz)
    localparam CLK_HALF_PERIOD = 125; // 50MHz / 100kHz / 2

    reg SDO;
    reg [23:0] SD;
    reg [5:0] SD_COUNTER;
    reg [2:0] cmd_index;    // Chỉ số lệnh trong I2C_DATA

    assign I2C_SDAT = SDO ? 1'bz : 0;

    reg ACK1, ACK2, ACK3;
    wire ACK = ACK1 | ACK2 | ACK3;

    // Chia tần số clock
    always @(posedge CLOCK or negedge RESET) begin
        if (!RESET) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // I2C Counter
    always @(negedge RESET or posedge CLOCK) begin
        if (!RESET) begin
            SD_COUNTER <= 6'b111111;
            cmd_index <= 0;
        end else if (clk_div == CLK_HALF_PERIOD) begin
            if (SD_COUNTER == 6'b111111 && cmd_index < 7)
                SD_COUNTER <= 0;
            else if (SD_COUNTER < 32)
                SD_COUNTER <= SD_COUNTER + 1;
            else if (cmd_index < 7)
                cmd_index <= cmd_index + 1;
        end
    end

    // I2C FSM
    always @(negedge RESET or posedge CLOCK) begin
        if (!RESET) begin
            I2C_SCLK <= 1;  // Thay SCLK thành I2C_SCLK
            SDO <= 1;
            ACK1 <= 0;
            ACK2 <= 0;
            ACK3 <= 0;
            END_TR <= 1;
        end else if (clk_div == CLK_HALF_PERIOD) begin
            case (SD_COUNTER)
                6'd0: begin
                    ACK1 <= 0; ACK2 <= 0; ACK3 <= 0;
                    END_TR <= 0;
                    SDO <= 1;
                    I2C_SCLK <= 1;
                end
                // Start
                6'd1: begin
                    SD <= I2C_DATA[cmd_index];
                    SDO <= 0;
                end
                6'd2: I2C_SCLK <= 0;
                // Slave Address
                6'd3: SDO <= SD[23];
                6'd4: SDO <= SD[22];
                6'd5: SDO <= SD[21];
                6'd6: SDO <= SD[20];
                6'd7: SDO <= SD[19];
                6'd8: SDO <= SD[18];
                6'd9: SDO <= SD[17];
                6'd10: SDO <= SD[16];
                6'd11: SDO <= 1'b1; // ACK
                // Sub Address
                6'd12: begin SDO <= SD[15]; ACK1 <= I2C_SDAT; end
                6'd13: SDO <= SD[14];
                6'd14: SDO <= SD[13];
                6'd15: SDO <= SD[12];
                6'd16: SDO <= SD[11];
                6'd17: SDO <= SD[10];
                6'd18: SDO <= SD[9];
                6'd19: SDO <= SD[8];
                6'd20: SDO <= 1'b1; // ACK
                // Data
                6'd21: begin SDO <= SD[7]; ACK2 <= I2C_SDAT; end
                6'd22: SDO <= SD[6];
                6'd23: SDO <= SD[5];
                6'd24: SDO <= SD[4];
                6'd25: SDO <= SD[3];
                6'd26: SDO <= SD[2];
                6'd27: SDO <= SD[1];
                6'd28: SDO <= SD[0];
                6'd29: SDO <= 1'b1; // ACK
                // Stop
                6'd30: begin SDO <= 0; I2C_SCLK <= 0; ACK3 <= I2C_SDAT; end
                6'd31: I2C_SCLK <= 1;
                6'd32: begin
                    SDO <= 1;
                    if (cmd_index == 6) END_TR <= 1;
                end
            endcase
        end
    end

endmodule