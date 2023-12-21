# Additional Resources
Listed on this page is additional project resources which proved useful when developing my FPGA program. I recommend having a brief scroll through each of these sites prior to starting full development.
[DE1-SoC Manual](http://ee.ic.ac.uk/pcheung/teaching/ee2_digital/de1-soc_user_manual.pdf) - Details the pinout layout of the DE1-SoC board and additional operational information for the soft processor interfaces.
[DE1-SoC Interfaces and Peripherals](https://class.ece.uw.edu/271/hauck2/de1/index.html) - Listing and description of all soft processor interfaces and peripherals.
[UofT DE1-SoC Peripheral Controllers] - Wide range of controller modules which can be used as examples or references.
[PS/2 Controller](http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/ARM/dev_ps2.html) [Alt link](http://www-ug.eecg.toronto.edu/msl/nios_devices/dev_ps2.html) - Details on the PS/2 protocol and PS/2 make / break codes.
[DESL documents](http://www-ug.eecg.toronto.edu/desl/) - DESL lab (UofT's ECE and Eng Sci FPGA lab) provided documents and controller modules.

## NES Controller
This following section is about the NES Controller protocol, although I did not use this protocol in this project, it can provide some understanding on how serial connections can operate and how you can design your own protocol if you will to have connections between different devices.
[Pinout Guide](https://pinoutguide.com/Game/snescontroller_pinout.shtml)
Whenever you send a high to the shift register latch (OUT 0), the controller will send 7 clock pulses (CUP) and Data gamepad (D1) will output the associated high or low if the button is pressed.
## Clock pulse order
1. B
2. Y
3. Select
4. Start
5. North
6. South
7. West
8. East
9. A
10. X
11. L
12. R