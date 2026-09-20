`timescale 1ns / 1ps

module alu_4bit(
    input  [3:0] a,
    input  [3:0] b,
    input  [1:0] op,          // Operation select
    output [3:0] result,
    output       carry_out,
    output       overflow,
    output       zero
);

    // Internal signals
    reg  [4:0] temp_result;   // 5-bit to handle carry
    wire [3:0] b_comp;        // 2's complement of b for subtraction

    // 2's complement of b
    assign b_comp = ~b + 1;

    always @(*) begin
        case (op)
            2'b00: temp_result = a + b;           // Addition
            2'b01: temp_result = a - b;           // Subtraction
            2'b10: temp_result = a & b;           // AND
            2'b11: temp_result = a ^ b;           // XOR
            default: temp_result = a + b;
        endcase
    end

    // Output assignments
    assign result = temp_result[3:0];
    assign carry_out = temp_result[4];
    
    // Overflow detection for signed operations
    // For addition: overflow when signs of a and b are same but result sign is different
    // For subtraction: overflow when signs of a and b are different but result sign is same as a
    assign overflow = ((op == 2'b00) && (a[3] == b[3]) && (result[3] != a[3])) ||
                      ((op == 2'b01) && (a[3] != b[3]) && (result[3] != a[3]));
    
    // Zero flag
    assign zero = (result == 4'b0000);

endmodule