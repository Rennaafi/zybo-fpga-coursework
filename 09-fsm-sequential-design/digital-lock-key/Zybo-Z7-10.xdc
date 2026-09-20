## ============================================================
## Zybo-Z7-10.xdc
## Constraints for digital_lock_top.v on the Digilent Zybo Z7-10.
## Pin locations taken from Digilent's official Zybo-Z7-Master.xdc
## (https://github.com/Digilent/digilent-xdc).
##
## Pin mapping used here:
##   clk        <- sysclk         (125 MHz onboard oscillator)
##   rst        <- btn[1]         (BTN1, dedicated global/power-up reset)
##   sw[3:0]    <- sw[3:0]        (SW0..SW3, password digit switches)
##   btn0_raw   <- btn[0]         (BTN0, "confirm digit" per the FSM diagram)
##   btn3_raw   <- btn[3]         (BTN3, "cancel/reset FSM" per the FSM diagram)
##   led0..3    <- led[0..3]      (individual LEDs, digit-entry progress)
##   led_green  <- led6_g         (RGB LED6, green channel = UNLOCK)
##   led_red    <- led6_r         (RGB LED6, red channel   = WRONG)
##
## BTN2 (K19) is left unused/reserved.
##
## NOTE: when instantiating digital_lock_top for this board, set
##   .CLK_FREQ_HZ(125_000_000)
## to match the 8ns clock period declared below.
## ============================================================

## Clock signal (125 MHz)
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## Global reset (BTN1)
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L24N_T3_34 Sch=btn[1]

## Switches (password digit input)
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L19N_T3_VREF_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L24P_T3_34 Sch=sw[1]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L4N_T0_34 Sch=sw[2]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L9P_T1_DQS_34 Sch=sw[3]

## Buttons
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { btn0_raw }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { btn3_raw }]; #IO_L7P_T1_34 Sch=btn[3]
# BTN2 (K19, Sch=btn[2]) intentionally left unassigned/reserved.

## Individual LEDs (digit-entry progress indicators)
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led0 }]; #IO_L23P_T3_35 Sch=led[0]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led1 }]; #IO_L23N_T3_35 Sch=led[1]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led2 }]; #IO_0_35 Sch=led[2]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { led3 }]; #IO_L3N_T0_DQS_AD1N_35 Sch=led[3]

## RGB LED6 -- used single-channel here (green = UNLOCK, red = WRONG;
## these are mutually exclusive states so sharing one RGB LED works fine)
set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { led_green }]; #IO_L6N_T0_VREF_35 Sch=led6_g
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { led_red }]; #IO_L18P_T2_34 Sch=led6_r
