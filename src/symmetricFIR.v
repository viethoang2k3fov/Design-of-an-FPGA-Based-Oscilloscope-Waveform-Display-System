module symmetricFIR #(
    parameter COEFF_NUM     = 34,
    parameter COEFF_WIDTH   = 8,
    parameter DATA_WIDTH    = 12,
    parameter STAGE1_WIDTH  = DATA_WIDTH + 1,
    parameter STAGE2_WIDTH  = STAGE1_WIDTH + COEFF_WIDTH + 1,
    parameter STAGE3_WIDTH  = STAGE2_WIDTH + 1,
    parameter OUTPUT_WIDTH  = STAGE3_WIDTH + 2
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire signed [DATA_WIDTH-1:0] noisy_signal,
    output reg  signed [OUTPUT_WIDTH-1:0] filtered_signal
);

    // ========== Coefficients ==========
    wire signed [COEFF_WIDTH-1:0] coeff [0:COEFF_NUM-1];
           assign coeff[0] = 0;
assign coeff[1] = 0;
assign coeff[2] = 0;
assign coeff[3] = 0;
assign coeff[4] = 0;
assign coeff[5] = 1;
assign coeff[6] = 0;
assign coeff[7] = -2;
assign coeff[8] = 2;
assign coeff[9] = 2;
assign coeff[10] = -4;
assign coeff[11] = -1;
assign coeff[12] = 8;
assign coeff[13] = -1;
assign coeff[14] = -15;
assign coeff[15] = 13;
assign coeff[16] = 63;
assign coeff[17] = 63;
assign coeff[18] = 13;
assign coeff[19] = -15;
assign coeff[20] = -1;
assign coeff[21] = 8;
assign coeff[22] = -1;
assign coeff[23] = -4;
assign coeff[24] = 2;
assign coeff[25] = 2;
assign coeff[26] = -2;
assign coeff[27] = 0;
assign coeff[28] = 1;
assign coeff[29] = 0;
assign coeff[30] = 0;
assign coeff[31] = 0;
assign coeff[32] = 0;
assign coeff[33] = 0;

    // ========== Shift Register ==========
    reg signed [DATA_WIDTH-1:0] shift_reg [0:2*COEFF_NUM-1];

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 2*COEFF_NUM; i = i + 1)
                shift_reg[i] <= 0;
        end else begin
            shift_reg[0] <= noisy_signal;
            for (i = 1; i < 2*COEFF_NUM; i = i + 1)
                shift_reg[i] <= shift_reg[i-1];
        end
    end

    // ========== Filter Core ==========
    reg signed [STAGE1_WIDTH-1:0] add_stage  [0:COEFF_NUM-1];
    reg signed [STAGE2_WIDTH-1:0] mult_stage [0:COEFF_NUM-1];
    reg signed [STAGE3_WIDTH-1:0] sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            filtered_signal <= 0;
        end else begin
            // Stage 1: symmetric add
            for (i = 0; i < COEFF_NUM; i = i + 1)
                add_stage[i] <= shift_reg[i] + shift_reg[2*COEFF_NUM - 1 - i];

            // Stage 2: multiply
            for (i = 0; i < COEFF_NUM; i = i + 1)
                mult_stage[i] <= add_stage[i] * coeff[i];

            // Stage 3: accumulate
            sum = 0;
            for (i = 0; i < COEFF_NUM; i = i + 1)
                sum = sum + mult_stage[i];

            filtered_signal <= sum;
        end
    end

endmodule
