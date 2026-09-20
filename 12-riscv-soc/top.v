`timescale 1ns / 1ps

module top(
    input  wire        clk_125,
    input  wire        rst_n,

    // ============================================================
    // VGA
    // ============================================================
    output wire [4:0]  vga_r,
    output wire [5:0]  vga_g,
    output wire [4:0]  vga_b,
    output wire        vga_hsync,
    output wire        vga_vsync,

    // ============================================================
    // UART
    // ============================================================
    input  wire        uart_rx,
    output wire        uart_tx
);

    // ============================================================
    // CLOCK GENERATION
    //
    // clk_125 -> Clock Wizard
    //
    // clk_out1 = 100 MHz
    // clk_out2 = 25 MHz
    // ============================================================

    wire clk_100;
    wire clk_25;
    wire locked;

    clk_wiz_0 clk_gen (
        .clk_in1  (clk_125),
        .clk_out1 (clk_100),
        .clk_out2 (clk_25),
        .reset    (~rst_n),
        .locked   (locked)
    );

    // ============================================================
    // SYSTEM RESET
    //
    // Wait until the Clock Wizard locks, then hold reset for
    // several clock cycles.
    // ============================================================

    reg [3:0] rst_cnt;

    always @(posedge clk_100 or negedge rst_n) begin

        if (!rst_n) begin
            rst_cnt <= 4'b0000;
        end

        else if (!locked) begin
            rst_cnt <= 4'b0000;
        end

        else if (rst_cnt != 4'b1111) begin
            rst_cnt <= rst_cnt + 1'b1;
        end

    end

    wire sys_rst;

    assign sys_rst = !locked || (rst_cnt != 4'b1111);

    // ============================================================
    // CPU BUS
    // ============================================================

    wire [31:0] cpu_addr;
    wire [31:0] cpu_wdata;
    wire [31:0] cpu_rdata;

    wire [3:0]  cpu_we;
    wire        cpu_req;
    wire        cpu_ack;

    wire        cpu_irq;

    // ============================================================
    // RISC-V CPU
    // ============================================================

    riscv_core cpu (
        .clk   (clk_100),
        .rst   (sys_rst),

        .addr  (cpu_addr),
        .wdata (cpu_wdata),
        .rdata (cpu_rdata),

        .we    (cpu_we),
        .req   (cpu_req),
        .ack   (cpu_ack),

        .irq   (cpu_irq)
    );

    // ============================================================
    // COMMON BUS
    // ============================================================

    wire [31:0] bus_addr;
    wire [31:0] bus_wdata;
    wire [3:0]  bus_we;
    wire        bus_req;

    // ============================================================
    // BRAM
    // ============================================================

    wire [31:0] bram_rdata;
    wire        bram_ack;

    // ============================================================
    // UART / PERIPHERALS
    // ============================================================

    wire [31:0] periph_rdata;
    wire        periph_ack;

    // ============================================================
    // BUS ARBITER
    // ============================================================

    bus_arbiter arbiter (
        .clk         (clk_100),
        .rst         (sys_rst),

        // CPU side
        .cpu_addr    (cpu_addr),
        .cpu_wdata   (cpu_wdata),
        .cpu_rdata   (cpu_rdata),
        .cpu_we      (cpu_we),
        .cpu_req     (cpu_req),
        .cpu_ack     (cpu_ack),

        // BRAM
        .bram_rdata  (bram_rdata),
        .bram_ack    (bram_ack),

        // UART
        .periph_rdata(periph_rdata),
        .periph_ack  (periph_ack),

        // Common bus
        .bus_addr    (bus_addr),
        .bus_wdata   (bus_wdata),
        .bus_we      (bus_we),
        .bus_req     (bus_req)
    );

    // ============================================================
    // BRAM
    //
    // Address range:
    //
    //     0x00000000 - 0x0000FFFF
    //
    // Your BRAM controller can further limit this to its actual
    // implemented size.
    // ============================================================

    bram_controller bram (
        .clk   (clk_100),
        .rst   (sys_rst),

        .addr  (bus_addr),
        .wdata (bus_wdata),
        .rdata (bram_rdata),

        .we    (bus_we),

        .req   (
            bus_req &&
            (bus_addr[31:16] == 16'h0000)
        ),

        .ack   (bram_ack)
    );

    // ============================================================
    // UART
    //
    // Address range:
    //
    //     0xA0000000
    //
    // Only the low address bits are sent to the UART.
    // ============================================================

    wire uart_irq;

    uart_controller uart (
        .clk   (clk_100),
        .rst   (sys_rst),

        .rx    (uart_rx),
        .tx    (uart_tx),

        .addr  (bus_addr[3:0]),
        .wdata (bus_wdata),
        .rdata (periph_rdata),

        .we    (bus_we[0]),

        .req   (
            bus_req &&
            (bus_addr[31:24] == 8'hA0)
        ),

        .ack   (periph_ack),

        .irq   (uart_irq)
    );

    // ============================================================
    // VGA
    //
    // Address range:
    //
    //     0xB0000000
    //
    // IMPORTANT:
    // Your original VGA controller had its rdata/ack ports left
    // unconnected. Therefore the arbiter treats VGA accesses as
    // fire-and-forget writes for now.
    //
    // We keep the VGA interface exactly as it appeared in your
    // original top.v.
    // ============================================================

vga_controller vga (
    .clk       (clk_25),
    .rst       (sys_rst),

    .vga_r     (vga_r),
    .vga_g     (vga_g),
    .vga_b     (vga_b),

    .vga_hsync (vga_hsync),
    .vga_vsync (vga_vsync)
);

    // ============================================================
    // INTERRUPT CONTROLLER
    // ============================================================

    interrupt_ctrl irq_ctrl (
        .clk      (clk_100),
        .rst      (sys_rst),

        .uart_irq (uart_irq),
        .cpu_irq  (cpu_irq)
    );

endmodule
