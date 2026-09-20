`timescale 1ns / 1ps

module riscv_core(
    input  wire        clk,
    input  wire        rst,

    // CPU memory/bus interface
    output wire [31:0] addr,
    output wire [31:0] wdata,
    input  wire [31:0] rdata,
    output wire [3:0]  we,
    output wire        req,
    input  wire        ack,

    // Interrupt input
    input  wire        irq
);

    // ============================================================
    // CPU states
    // ============================================================
    localparam STATE_FETCH = 2'd0;
    localparam STATE_EXEC  = 2'd1;
    localparam STATE_LOAD  = 2'd2;
    localparam STATE_STORE = 2'd3;

    reg [1:0] state;

    // ============================================================
    // Program counter / instruction
    // ============================================================
    reg [31:0] pc;
    reg [31:0] instruction;

    // ============================================================
    // Decode
    // ============================================================
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];

    // ============================================================
    // Register file
    // ============================================================
    reg [31:0] reg_file [0:31];

    wire [31:0] rs1_data =
        (rs1 == 5'd0) ? 32'b0 : reg_file[rs1];

    wire [31:0] rs2_data =
        (rs2 == 5'd0) ? 32'b0 : reg_file[rs2];

    // ============================================================
    // Immediate generation
    // ============================================================

    // I-type immediate
    wire [31:0] imm_i =
        {{20{instruction[31]}}, instruction[31:20]};

    // S-type immediate
    wire [31:0] imm_s =
        {{20{instruction[31]}},
         instruction[31:25],
         instruction[11:7]};

    // B-type immediate
    wire [31:0] imm_b =
        {{19{instruction[31]}},
         instruction[31],
         instruction[7],
         instruction[30:25],
         instruction[11:8],
         1'b0};

    // U-type immediate
    wire [31:0] imm_u =
        {instruction[31:12], 12'b0};

    // J-type immediate
    wire [31:0] imm_j =
        {{11{instruction[31]}},
         instruction[31],
         instruction[19:12],
         instruction[20],
         instruction[30:21],
         1'b0};

    // ============================================================
    // ALU input selection
    // ============================================================

    wire [31:0] alu_b;

    assign alu_b =
        (opcode == 7'b0110011) ? rs2_data :   // R-type
        (opcode == 7'b0010011) ? imm_i    :   // I-type ALU
        (opcode == 7'b0000011) ? imm_i    :   // Load
        (opcode == 7'b0100011) ? imm_s    :   // Store
        32'b0;

    // ============================================================
    // ALU
    // ============================================================

    wire [31:0] alu_result;
    wire        alu_zero;

    alu_unit alu (
        .a      (rs1_data),
        .b      (alu_b),
        .sel    ({funct7[5], funct3}),
        .result (alu_result),
        .zero   (alu_zero)
    );

    // ============================================================
    // Write-back registers
    // ============================================================

    reg [31:0] wb_data;
    reg [4:0]  wb_rd;
    reg        wb_en;

    // ============================================================
    // Bus outputs
    //
    // These are wires because they are generated combinationally.
    // This avoids the original "procedural assignment to a
    // non-register" errors.
    // ============================================================

    assign req =
        (state == STATE_FETCH) ||
        (state == STATE_LOAD)  ||
        (state == STATE_STORE);

    assign addr =
        (state == STATE_FETCH) ? pc :
        (state == STATE_LOAD)  ? alu_result :
        (state == STATE_STORE) ? alu_result :
        32'b0;

    assign wdata =
        (state == STATE_STORE) ? rs2_data :
        32'b0;

    assign we =
        (state == STATE_STORE) ? 4'b1111 :
        4'b0000;

    // ============================================================
    // Main CPU
    // ============================================================

    integer i;

    always @(posedge clk) begin

        if (rst) begin

            pc          <= 32'h00000000;
            instruction <= 32'b0;
            state       <= STATE_FETCH;

            wb_data     <= 32'b0;
            wb_rd       <= 5'd0;
            wb_en       <= 1'b0;

            // Initialize register file
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'b0;

        end else begin

            // ----------------------------------------------------
            // x0 is ALWAYS zero in RISC-V
            // ----------------------------------------------------
            reg_file[0] <= 32'b0;

            // ----------------------------------------------------
            // Write-back
            // ----------------------------------------------------
            if (wb_en) begin
                if (wb_rd != 5'd0)
                    reg_file[wb_rd] <= wb_data;

                wb_en <= 1'b0;
            end

            // ----------------------------------------------------
            // State machine
            // ----------------------------------------------------
            case (state)

                // =================================================
                // FETCH
                // =================================================
                STATE_FETCH: begin

                    // req and addr are generated above.
                    // Wait for memory to acknowledge the fetch.
                    if (ack) begin
                        instruction <= rdata;
                        state       <= STATE_EXEC;
                    end

                end


                // =================================================
                // EXECUTE
                // =================================================
                STATE_EXEC: begin

                    case (opcode)

                        // -----------------------------------------
                        // R-type
                        // -----------------------------------------
                        7'b0110011: begin

                            wb_data <= alu_result;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= pc + 32'd4;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // I-type ALU
                        // -----------------------------------------
                        7'b0010011: begin

                            wb_data <= alu_result;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= pc + 32'd4;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // LOAD
                        // -----------------------------------------
                        7'b0000011: begin

                            // Address is generated from:
                            // rs1 + immediate
                            //
                            // Wait in STATE_LOAD until ack.
                            state <= STATE_LOAD;

                        end


                        // -----------------------------------------
                        // STORE
                        // -----------------------------------------
                        7'b0100011: begin

                            // Address = rs1 + immediate
                            // wdata  = rs2_data
                            // we     = 1111
                            //
                            // Wait for memory acknowledge.
                            state <= STATE_STORE;

                        end


                        // -----------------------------------------
                        // BRANCH
                        // -----------------------------------------
                        7'b1100011: begin

                            case (funct3)

                                // BEQ
                                3'b000: begin
                                    if (rs1_data == rs2_data)
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                // BNE
                                3'b001: begin
                                    if (rs1_data != rs2_data)
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                // BLT
                                3'b100: begin
                                    if ($signed(rs1_data) < $signed(rs2_data))
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                // BGE
                                3'b101: begin
                                    if ($signed(rs1_data) >= $signed(rs2_data))
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                // BLTU
                                3'b110: begin
                                    if ($unsigned(rs1_data) < $unsigned(rs2_data))
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                // BGEU
                                3'b111: begin
                                    if ($unsigned(rs1_data) >= $unsigned(rs2_data))
                                        pc <= pc + imm_b;
                                    else
                                        pc <= pc + 32'd4;
                                end

                                default: begin
                                    pc <= pc + 32'd4;
                                end

                            endcase

                            state <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // JAL
                        // -----------------------------------------
                        7'b1101111: begin

                            wb_data <= pc + 32'd4;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= pc + imm_j;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // JALR
                        // -----------------------------------------
                        7'b1100111: begin

                            wb_data <= pc + 32'd4;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= (rs1_data + imm_i) & 32'hFFFFFFFE;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // LUI
                        // -----------------------------------------
                        7'b0110111: begin

                            wb_data <= imm_u;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= pc + 32'd4;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // AUIPC
                        // -----------------------------------------
                        7'b0010111: begin

                            wb_data <= pc + imm_u;
                            wb_rd   <= rd;
                            wb_en   <= 1'b1;

                            pc      <= pc + 32'd4;
                            state   <= STATE_FETCH;

                        end


                        // -----------------------------------------
                        // Unknown / unsupported instruction
                        // -----------------------------------------
                        default: begin

                            pc    <= pc + 32'd4;
                            state <= STATE_FETCH;

                        end

                    endcase

                end


                // =================================================
                // LOAD WAIT
                // =================================================
                STATE_LOAD: begin

                    // req = 1
                    // addr = alu_result
                    // we = 0000
                    //
                    // Wait for memory to return data.
                    if (ack) begin

                        wb_data <= rdata;
                        wb_rd   <= rd;
                        wb_en   <= 1'b1;

                        pc      <= pc + 32'd4;
                        state   <= STATE_FETCH;

                    end

                end


                // =================================================
                // STORE WAIT
                // =================================================
                STATE_STORE: begin

                    // req   = 1
                    // addr  = alu_result
                    // wdata = rs2_data
                    // we    = 1111
                    //
                    // Wait for memory to acknowledge the store.
                    if (ack) begin

                        pc    <= pc + 32'd4;
                        state <= STATE_FETCH;

                    end

                end


                // =================================================
                // Safety default
                // =================================================
                default: begin

                    state <= STATE_FETCH;

                end

            endcase

        end

    end

endmodule
