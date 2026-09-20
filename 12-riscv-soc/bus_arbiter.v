`timescale 1ns / 1ps

module bus_arbiter(
    input  wire        clk,
    input  wire        rst,

    // ============================================================
    // CPU SIDE
    // ============================================================

    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,
    output wire [31:0] cpu_rdata,

    input  wire [3:0]  cpu_we,
    input  wire        cpu_req,
    output wire        cpu_ack,

    // ============================================================
    // BRAM
    // ============================================================

    input  wire [31:0] bram_rdata,
    input  wire        bram_ack,

    // ============================================================
    // UART / PERIPHERALS
    // ============================================================

    input  wire [31:0] periph_rdata,
    input  wire        periph_ack,

    // ============================================================
    // COMMON BUS
    // ============================================================

    output wire [31:0] bus_addr,
    output wire [31:0] bus_wdata,
    output wire [3:0]  bus_we,
    output wire        bus_req
);

    // ============================================================
    // STATES
    // ============================================================

    localparam STATE_IDLE = 2'd0;
    localparam STATE_BRAM = 2'd1;
    localparam STATE_UART = 2'd2;
    localparam STATE_VGA  = 2'd3;

    reg [1:0] state;

    reg [31:0] read_data;
    reg        ack_out;

    // ============================================================
    // CPU RESPONSE
    // ============================================================

    assign cpu_rdata = read_data;
    assign cpu_ack   = ack_out;

    // ============================================================
    // COMMON BUS
    // ============================================================

    assign bus_addr  = cpu_addr;
    assign bus_wdata = cpu_wdata;
    assign bus_we    = cpu_we;

    // Keep request active while transaction is being serviced.
    assign bus_req = (state != STATE_IDLE);

    // ============================================================
    // MAIN STATE MACHINE
    // ============================================================

    always @(posedge clk) begin

        if (rst) begin

            state     <= STATE_IDLE;
            read_data <= 32'b0;
            ack_out   <= 1'b0;

        end

        else begin

            // ACK lasts for one clock.
            ack_out <= 1'b0;

            case (state)

                // =================================================
                // IDLE
                // =================================================

                STATE_IDLE: begin

                    if (cpu_req) begin

                        // -----------------------------------------
                        // BRAM
                        // 0x0000xxxx
                        // -----------------------------------------

                        if (cpu_addr[31:16] == 16'h0000) begin

                            state <= STATE_BRAM;

                        end

                        // -----------------------------------------
                        // UART
                        // 0xA0xxxxxx
                        // -----------------------------------------

                        else if (cpu_addr[31:24] == 8'hA0) begin

                            state <= STATE_UART;

                        end

                        // -----------------------------------------
                        // VGA
                        // 0xB0xxxxxx
                        // -----------------------------------------

                        else if (cpu_addr[31:24] == 8'hB0) begin

                            state <= STATE_VGA;

                        end

                        // -----------------------------------------
                        // Unknown address
                        // -----------------------------------------
                        //
                        // Return zero instead of hanging the CPU.
                        //

                        else begin

                            read_data <= 32'b0;
                            ack_out   <= 1'b1;
                            state     <= STATE_IDLE;

                        end

                    end

                end

                // =================================================
                // BRAM
                // =================================================

                STATE_BRAM: begin

                    if (bram_ack) begin

                        read_data <= bram_rdata;
                        ack_out   <= 1'b1;
                        state     <= STATE_IDLE;

                    end

                end

                // =================================================
                // UART
                // =================================================

                STATE_UART: begin

                    if (periph_ack) begin

                        read_data <= periph_rdata;
                        ack_out   <= 1'b1;
                        state     <= STATE_IDLE;

                    end

                end

                // =================================================
                // VGA
                // =================================================
                //
                // Current VGA controller does not expose an ACK.
                //
                // For now, treat VGA writes as completing after
                // one clock.
                //

                STATE_VGA: begin

                    read_data <= 32'b0;
                    ack_out   <= 1'b1;
                    state     <= STATE_IDLE;

                end

                // =================================================
                // SAFETY
                // =================================================

                default: begin

                    state <= STATE_IDLE;

                end

            endcase

        end

    end

endmodule
