## =========================================================
## Zybo Z7-10
## 125 MHz system clock
## =========================================================

set_property -dict {
    PACKAGE_PIN K17
    IOSTANDARD LVCMOS33
} [get_ports clk]

create_clock -period 8.000 \
    -name sys_clk_pin \
    [get_ports clk]


## =========================================================
## UART TX
## Pmod JE1 pin 1 = V12
## FPGA TX -> CP2102 RXD
## =========================================================

set_property -dict {
    PACKAGE_PIN V12
    IOSTANDARD LVCMOS33
} [get_ports uart_tx]
