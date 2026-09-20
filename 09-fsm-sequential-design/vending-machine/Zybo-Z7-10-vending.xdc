## Zybo Z7-10 constraints for the vending_challenge project (top.v)
## Pin locations verified against Digilent's Zybo-Z7-Master.xdc

## Clock signal (125 MHz)
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## Buttons
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports { btn_coin }];    ## btn[0]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { btn_menu }];    ## btn[1]
set_property -dict { PACKAGE_PIN K19 IOSTANDARD LVCMOS33 } [get_ports { btn_proceed }]; ## btn[2]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports { rst }];         ## btn[3] used as reset

## LEDs (menu indicator, ld0=100won .. ld3=400won)
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { ld[0] }];
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { ld[1] }];
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { ld[2] }];
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports { ld[3] }];

## RGB LED 6 -- the only RGB LED populated on Zybo Z7-10
## (LED5 in the master XDC is Zybo Z7-20 only; not used here)
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { rgb_r }];
set_property -dict { PACKAGE_PIN F17 IOSTANDARD LVCMOS33 } [get_ports { rgb_g }];
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { rgb_b }];