// wm8731_config.v
// Gửi lệnh cấu hình WM8731 qua I2C

module wm8731_config (
    input wire clk,          // Clock (50MHz)
    input wire reset,        // Active high reset
    input wire [11:0] wave_data, // Dữ liệu dạng sóng đầu vào
    output wire i2c_scl,     // I2C clock
    inout wire i2c_sda       // I2C data
);

    // Danh sách các thanh ghi cấu hình WM8731
    reg [15:0] config_data [0:8];
    initial begin
        // Các thanh ghi cấu hình của WM8731 (vẫn như trước)
        config_data[0] = 16'b0000000001111001; // Reg 0: Left Line In (mute, 0dB)
        config_data[1] = 16'b0001000001111001; // Reg 1: Right Line In (mute, 0dB)
        config_data[2] = 16'b0010000000001010; // Reg 2: Left Headphone Out (0dB)
        config_data[3] = 16'b0011000000001010; // Reg 3: Right Headphone Out (0dB)
        config_data[4] = 16'b0100000000001010; // Reg 4: Analog Audio Path (DAC selected)
        config_data[5] = 16'b0101000000000000; // Reg 5: Digital Audio Path (disable mute)
        config_data[6] = 16'b0110000000000000; // Reg 6: Power Down (all on)
        config_data[7] = 16'b0111000000100010; // Reg 7: Digital Format (I2S, 16-bit)
        config_data[8] = 16'b1000000000000000; // Reg 8: Sample Rate (48kHz)
    end

    // FSM control
    reg [3:0] state = 0;
    reg [3:0] index = 0;
    reg start = 0;
    wire done;

    // Giao tiếp I2C
    i2c_master i2c_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .wave_data(config_data[index]),  // Dữ liệu cấu hình WM8731
        .done(done),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            index <= 0;
            start <= 0;
        end else begin
            case (state)
                0: begin
                    start <= 1;
                    state <= 1;
                end
                1: begin
                    start <= 0;
                    if (done) state <= 2;
                end
                2: begin
                    if (index < 8) begin
                        index <= index + 1;
                        state <= 0;
                    end
                end
            endcase
        end
    end

    // Phần này là dữ liệu wave_data sẽ được sử dụng trong khối i2s_transmitter
    // Dữ liệu wave_data có thể ảnh hưởng đến quá trình điều khiển và lựa chọn tín hiệu
    // cần thiết cho WM8731 (VD: điều chỉnh biên độ, tần số hoặc chế độ phát sóng).
    // Các tín hiệu này sẽ được kết hợp với các thanh ghi cấu hình WM8731 để
    // xác định các tham số hoạt động của WM8731.

endmodule
