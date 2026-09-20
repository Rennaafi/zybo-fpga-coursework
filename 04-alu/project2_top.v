module project2(
    input  [7:0] sw,
    input  [3:0] btn,
    output [3:0] led,
    output       led5_r,
    output       led5_g,
    output       led5_b
);

    wire [3:0] a, b;
    wire [3:0] result;
    wire       carry_out, overflow, zero;
    reg  [1:0] op_select;  // Use a reg to combine buttons properly

    assign a = sw[3:0];
    assign b = sw[7:4];

    // 📋 Decide which operation based on buttons
    always @(*) begin
        if (btn[0]) op_select = 2'b00;  // BTN0 = Addition
        else if (btn[1]) op_select = 2'b01;  // BTN1 = Subtraction
        else if (btn[2]) op_select = 2'b10;  // BTN2 = AND
        else if (btn[3]) op_select = 2'b11;  // BTN3 = XOR
        else op_select = 2'b00;  // Default to addition
    end

    alu_4bit u_alu (
        .a(a),
        .b(b),
        .op(op_select),
        .result(result),
        .carry_out(carry_out),
        .overflow(overflow),
        .zero(zero)
    );

    assign led = result;
    assign led5_r = overflow;
    assign led5_g = zero;
    assign led5_b = carry_out;

endmodule