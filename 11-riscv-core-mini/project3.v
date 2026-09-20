`timescale 1ns / 1ps

module project3(
    input  wire        clk_125,      // 125 MHz system clock
    input  wire        rst_n,        // Reset button
    
    // DDR3 interface
    output wire [14:0] ddr_addr,
    output wire [2:0]  ddr_ba,
    output wire        ddr_cas_n,
    output wire        ddr_ck_n,
    output wire        ddr_ck_p,
    output wire        ddr_cke,
    output wire        ddr_cs_n,
    output wire [1:0]  ddr_dm,
    inout  wire [15:0] ddr_dq,
    inout  wire [1:0]  ddr_dqs_n,
    inout  wire [1:0]  ddr_dqs_p,
    output wire        ddr_odt,
    output wire        ddr_ras_n,
    output wire        ddr_reset_n,
    output wire        ddr_we_n,
    
    // VGA output
    output wire [4:0]  vga_r,
    output wire [5:0]  vga_g,
    output wire [4:0]  vga_b,
    output wire        vga_hsync,
    output wire        vga_vsync,
    
    // UART
    input  wire        uart_rx,
    output wire        uart_tx
);

    // Clock generation
    wire clk_100, clk_25, clk_mig;
    wire locked;
    
    clk_wiz_0 clk_gen(
        .clk_in1(clk_125),
        .clk_out1(clk_100),   // 100 MHz for MIG
        .clk_out2(clk_25),    // 25 MHz for VGA
        .reset(~rst_n),
        .locked(locked)
    );
    
    // Reset logic
    wire sys_rst = ~(rst_n & locked);
    wire mig_rst = sys_rst;
    
    // DDR3 MIG
    wire [31:0] mig_read_data;
    wire        mig_read_valid;
    wire [31:0] mig_write_data;
    wire [31:0] mig_addr;
    wire        mig_cmd_en;
    wire [2:0]  mig_cmd_instr;
    wire [6:0]  mig_cmd_bl;
    wire        mig_cmd_empty;
    wire        mig_cmd_full;
    wire        mig_rd_empty;
    wire        mig_rd_full;
    wire        mig_wr_empty;
    wire        mig_wr_full;
    wire        mig_init_done;
    
    mig_7series_0 ddr3_mig(
        .ddr_addr(ddr_addr),
        .ddr_ba(ddr_ba),
        .ddr_cas_n(ddr_cas_n),
        .ddr_ck_n(ddr_ck_n),
        .ddr_ck_p(ddr_ck_p),
        .ddr_cke(ddr_cke),
        .ddr_cs_n(ddr_cs_n),
        .ddr_dm(ddr_dm),
        .ddr_dq(ddr_dq),
        .ddr_dqs_n(ddr_dqs_n),
        .ddr_dqs_p(ddr_dqs_p),
        .ddr_odt(ddr_odt),
        .ddr_ras_n(ddr_ras_n),
        .ddr_reset_n(ddr_reset_n),
        .ddr_we_n(ddr_we_n),
        .app_addr(mig_addr),
        .app_cmd({mig_cmd_instr, mig_cmd_bl}),
        .app_en(mig_cmd_en),
        .app_wdf_data(mig_write_data),
        .app_wdf_end(1'b1),
        .app_wdf_mask(4'b0000),
        .app_wdf_wren(mig_wr_full & mig_wr_empty),
        .app_rd_data(mig_read_data),
        .app_rd_data_valid(mig_read_valid),
        .app_rd_data_end(),
        .app_wdf_rdy(),
        .app_rdy(),
        .app_sr_req(1'b0),
        .app_ref_req(1'b0),
        .app_zq_req(1'b0),
        .app_sr_active(),
        .app_ref_active(),
        .app_zq_active(),
        .ui_clk(clk_mig),
        .ui_clk_sync_rst(mig_rst),
        .init_calib_complete(mig_init_done),
        .sys_clk_i(clk_100),
        .clk_ref_i(clk_100),
        .sys_rst(mig_rst)
    );
    
    // RISC-V CPU Core
    wire [31:0] cpu_addr;
    wire [31:0] cpu_wdata;
    wire [31:0] cpu_rdata;
    wire [3:0]  cpu_we;
    wire        cpu_req;
    wire        cpu_ack;
    wire        cpu_irq;
    
    riscv_core cpu(
        .clk(clk_mig),
        .rst(sys_rst),
        .addr(cpu_addr),
        .wdata(cpu_wdata),
        .rdata(cpu_rdata),
        .we(cpu_we),
        .req(cpu_req),
        .ack(cpu_ack),
        .irq(cpu_irq)
    );
    
    // Memory Bus Arbiter
    wire [31:0] bus_addr;
    wire [31:0] bus_wdata;
    wire [31:0] bus_rdata;
    wire [3:0]  bus_we;
    wire        bus_req;
    wire        bus_ack;
    
    // BRAM interface (32KB)
    wire [31:0] bram_rdata;
    wire        bram_ack;
    
    // DDR interface
    wire [31:0] ddr_rdata;
    wire        ddr_ack;
    
    // Peripheral bus
    wire [31:0] periph_rdata;
    wire        periph_ack;
    
    bus_arbiter arbiter(
        .clk(clk_mig),
        .rst(sys_rst),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_rdata(cpu_rdata),
        .cpu_we(cpu_we),
        .cpu_req(cpu_req),
        .cpu_ack(cpu_ack),
        .bram_rdata(bram_rdata),
        .bram_ack(bram_ack),
        .ddr_rdata(ddr_rdata),
        .ddr_ack(ddr_ack),
        .periph_rdata(periph_rdata),
        .periph_ack(periph_ack),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_rdata(bus_rdata),
        .bus_we(bus_we),
        .bus_req(bus_req),
        .bus_ack(bus_ack)
    );
    
    // BRAM memory (32KB)
    bram_controller bram(
        .clk(clk_mig),
        .rst(sys_rst),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .rdata(bram_rdata),
        .we(bus_we),
        .req(bus_req & (bus_addr[31:16] == 16'h0000)),
        .ack(bram_ack)
    );
    
    // DDR controller wrapper
    ddr_controller ddr_wrapper(
        .clk(clk_mig),
        .rst(sys_rst),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .rdata(ddr_rdata),
        .we(bus_we),
        .req(bus_req & (bus_addr[31:24] == 8'h80)),
        .ack(ddr_ack),
        .mig_addr(mig_addr),
        .mig_wdata(mig_write_data),
        .mig_rdata(mig_read_data),
        .mig_rvalid(mig_read_valid),
        .mig_cmd_en(mig_cmd_en),
        .mig_cmd_instr(mig_cmd_instr),
        .mig_cmd_bl(mig_cmd_bl),
        .mig_cmd_empty(mig_cmd_empty),
        .mig_cmd_full(mig_cmd_full),
        .mig_rd_empty(mig_rd_empty),
        .mig_rd_full(mig_rd_full),
        .mig_wr_empty(mig_wr_empty),
        .mig_wr_full(mig_wr_full),
        .mig_init_done(mig_init_done)
    );
    
    // VGA controller
    vga_controller vga(
        .clk(clk_25),
        .rst(sys_rst),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync)
    );
    
    // UART controller
    uart_controller uart(
        .clk(clk_100),
        .rst(sys_rst),
        .rx(uart_rx),
        .tx(uart_tx),
        .addr(bus_addr[3:0]),
        .wdata(bus_wdata),
        .rdata(periph_rdata),
        .we(bus_we[0]),
        .req(bus_req & (bus_addr[31:24] == 8'hA0)),
        .ack(periph_ack)
    );
    
    // Interrupt controller
    interrupt_ctrl irq_ctrl(
        .clk(clk_mig),
        .rst(sys_rst),
        .uart_irq(uart_irq),
        .cpu_irq(cpu_irq)
    );

endmodule