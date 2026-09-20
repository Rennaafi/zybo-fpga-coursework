`timescale 1ns / 1ps

module riscv_core(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] addr,
    output wire [31:0] wdata,
    input  wire [31:0] rdata,
    output wire [3:0]  we,
    output wire        req,
    input  wire        ack,
    input  wire        irq
);

    // PC and instruction fetch
    reg [31:0] pc;
    reg [31:0] next_pc;
    reg [31:0] instruction;
    reg        inst_valid;
    
    // Decode stage
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    
    // Register file
    reg [31:0] reg_file [31:0];
    wire [31:0] rs1_data = reg_file[rs1];
    wire [31:0] rs2_data = reg_file[rs2];
    
    // Immediate generation
    wire [31:0] imm_i = {{20{instruction[31]}}, instruction[31:20]};
    wire [31:0] imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    wire [31:0] imm_b = {{20{instruction[31]}}, instruction[7], instruction[30:25], 
                          instruction[11:8], 1'b0};
    wire [31:0] imm_u = {instruction[31:12], 12'b0};
    wire [31:0] imm_j = {{12{instruction[31]}}, instruction[19:12], 
                          instruction[20], instruction[30:21], 1'b0};
    
    // ALU
    wire [31:0] alu_result;
    wire        alu_zero;
    
    alu_unit alu(
        .a(rs1_data),
        .b(opcode == 7'b0110011 ? rs2_data : 
           (opcode == 7'b0010011 ? imm_i : 
            (opcode == 7'b0000011 ? imm_i :
             (opcode == 7'b0100011 ? imm_s :
              (opcode == 7'b1100011 ? imm_b : 32'b0))))),
        .sel({funct7[5], funct3}),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // Write-back
    reg [31:0] wb_data;
    reg        wb_en;
    reg [4:0]  wb_rd;
    
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h00000000;
            inst_valid <= 0;
            wb_en <= 0;
        end else begin
            // Instruction fetch
            req <= 1'b1;
            addr <= pc;
            if (ack) begin
                instruction <= rdata;
                inst_valid <= 1'b1;
            end
            
            // Execute
            if (inst_valid) begin
                case (opcode)
                    7'b0110011: begin // R-type
                        we <= 4'b1111;
                        wdata <= alu_result;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                    end
                    7'b0010011: begin // I-type
                        we <= 4'b1111;
                        wdata <= alu_result;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                    end
                    7'b0000011: begin // Load
                        req <= 1'b1;
                        addr <= alu_result;
                        if (ack) begin
                            we <= 4'b1111;
                            wdata <= rdata;
                            wb_rd <= rd;
                            wb_en <= 1'b1;
                        end
                    end
                    7'b0100011: begin // Store
                        req <= 1'b1;
                        addr <= alu_result;
                        wdata <= rs2_data;
                        we <= 4'b1111;
                        if (ack) begin
                            we <= 4'b0000;
                        end
                    end
                    7'b1100011: begin // Branch
                        if ((funct3 == 3'b000 && alu_zero) ||
                            (funct3 == 3'b001 && !alu_zero) ||
                            (funct3 == 3'b100 && $signed(rs1_data) < $signed(rs2_data)) ||
                            (funct3 == 3'b101 && $signed(rs1_data) >= $signed(rs2_data)) ||
                            (funct3 == 3'b110 && $unsigned(rs1_data) < $unsigned(rs2_data)) ||
                            (funct3 == 3'b111 && $unsigned(rs1_data) >= $unsigned(rs2_data))) begin
                            pc <= pc + imm_b;
                        end else begin
                            pc <= pc + 4;
                        end
                    end
                    7'b1101111: begin // JAL
                        we <= 4'b1111;
                        wdata <= pc + 4;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                        pc <= pc + imm_j;
                    end
                    7'b1100111: begin // JALR
                        we <= 4'b1111;
                        wdata <= pc + 4;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                        pc <= (rs1_data + imm_i) & ~1;
                    end
                    7'b0110111: begin // LUI
                        we <= 4'b1111;
                        wdata <= imm_u;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                    end
                    7'b0010111: begin // AUIPC
                        we <= 4'b1111;
                        wdata <= pc + imm_u;
                        wb_rd <= rd;
                        wb_en <= 1'b1;
                    end
                endcase
            end
            
            // Write-back
            if (wb_en) begin
                reg_file[wb_rd] <= wb_data;
                wb_en <= 0;
            end
        end
    end

endmodule