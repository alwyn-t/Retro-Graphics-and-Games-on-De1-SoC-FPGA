# ECE241 Project Resources
## Useful Links
[DE1-SoC Interfaces and Peripherals](https://class.ece.uw.edu/271/hauck2/de1/index.html)
[PS/2 Controller](http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/ARM/dev_ps2.html) [Alt link](http://www-ug.eecg.toronto.edu/msl/nios_devices/dev_ps2.html)

## NES Controller
[Pinout Guide](https://pinoutguide.com/Game/snescontroller_pinout.shtml)
Whenever you send a high to the shift register latch (OUT 0), the controller will send 7 clock pulses (CUP) and Data gamepad (D1) will output the associated high or low if the button is pressed
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