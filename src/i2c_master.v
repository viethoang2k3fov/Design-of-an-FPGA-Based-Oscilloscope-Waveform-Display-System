// i2c_master.v
// Module I2C master để gửi 12-bit cấu hình đến WM8731

module i2c_master (
    input wire clk,            // Clock (50MHz)
    input wire reset,          // Active high reset
    input wire start,          // Bắt đầu truyền
    input wire [11:0] wave_data, // Dữ liệu dạng sóng (12-bit)
    output reg done,           // Hoàn thành truyền
    output reg i2c_scl,        // I2C clock
    inout wire i2c_sda         // I2C data
);

    // Địa chỉ I2C của WM8731: 0x1A (7-bit) + write bit (0)
    localparam DEVICE_ADDR = 8'h34;  // 0x1A << 1 | 0 = 0x34

    reg [5:0] bit_cnt = 0;
    reg [23:0] shift_reg;
    reg sda_out = 1;
    reg sda_oe = 0; // 1 = output, 0 = high-Z
    reg [7:0] clk_div = 0;

    assign i2c_sda = sda_oe ? sda_out : 1'bz;

    localparam SCL_DIV = 125; // 50MHz / (2 * 125) = 200kHz I2C

    reg [2:0] state = 0;
    localparam IDLE  = 3'd0,
               START = 3'd1,
               SEND  = 3'd2,
               ACK   = 3'd3,
               STOP  = 3'd4,
               DONE  = 3'd5;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_cnt <= 0;
            i2c_scl <= 1;
            sda_out <= 1;
            sda_oe <= 0;
            done <= 0;
            clk_div <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Format: DEVICE_ADDR + wave_data (12-bit)
                        // Cộng thêm địa chỉ WM8731 vào dữ liệu wave_data
                        shift_reg <= {DEVICE_ADDR, wave_data, 1'b0}; // 12-bit wave_data + 1 bit data
                        bit_cnt <= 23;  // Đưa vào thanh ghi 24-bit để truyền
                        clk_div <= 0;
                        i2c_scl <= 1;
                        sda_out <= 1;
                        sda_oe <= 1;
                        state <= START;
                    end
                end

                START: begin
                    if (clk_div == SCL_DIV) begin
                        sda_out <= 0;  // SDA low while SCL high = START
                        state <= SEND;
                        clk_div <= 0;
                    end else clk_div <= clk_div + 1;
                end

                SEND: begin
                    if (clk_div == SCL_DIV) begin
                        i2c_scl <= 0;
                        clk_div <= 0;
                        sda_out <= shift_reg[bit_cnt];
                        sda_oe <= 1;
                        state <= ACK;
                    end else clk_div <= clk_div + 1;
                end

                ACK: begin
                    if (clk_div == SCL_DIV) begin
                        i2c_scl <= 1;
                        clk_div <= 0;
                        if (bit_cnt == 0) state <= STOP;
                        else begin
                            bit_cnt <= bit_cnt - 1;
                            state <= SEND;
                        end
                    end else clk_div <= clk_div + 1;
                end

                STOP: begin
                    if (clk_div == SCL_DIV) begin
                        i2c_scl <= 0;
                        sda_out <= 0;
                        clk_div <= 0;
                        state <= DONE;
                    end else clk_div <= clk_div + 1;
                end

                DONE: begin
                    if (clk_div == SCL_DIV) begin
                        i2c_scl <= 1;
                        sda_out <= 1;
                        sda_oe <= 0;
                        done <= 1;
                        state <= IDLE;
                        clk_div <= 0;
                    end else clk_div <= clk_div + 1;
                end
            endcase
        end
    end

endmodule
