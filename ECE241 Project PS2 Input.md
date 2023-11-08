# ECE241 Project PS2 Input
Investigation into PS/2 inputs
## Make and Break Codes
[![PS/2 Controller](https://www.eecg.utoronto.ca/~jayar/ece241_08F/AudioVideoCores/ps2/img/keycodes.png)]
Above is the make codes for all the keys on the keyboard.

[![PS/2 Mouse/Keyboard Port Lecture L9.4. PS/2 Port. - ppt download](https://images.slideplayer.com/16/5036830/slides/slide_5.jpg)]
All make and break codes can be found on [altium site](https://techdocs.altium.com/display/FPGA/PS2+Keyboard+Scan+Codes)
## State Diagram
```mermaid
flowchart TB
Start(start)
WaitClockDataLow1(WtClkDatLow1)
WaitClockDataHig1(WtClkDatHig1)
WaitClockDataLow2(WtClkDatLow2)
WaitClockDataHig2(WtClkDatHig2)
WaitClockDataLow3(WtClkDatLow3)
WaitClockDataHig3(WtClkDatHig3)
GetKey1(getKey1)
BreakCodeCheck(BrkCodChk)
GetKey2(getKey2)
GetKey3(getKey3)

Start-->|data = 1|Start
Start-->|data = 0|WaitClockDataLow1
WaitClockDataLow1-->|clock = 0|WaitClockDataHig1
WaitClockDataHig1-->|"clock = 1 [increment counter by 1]"|WaitClockDataLow1
WaitClockDataHig1-->|"clock = 0 [shiftReg1(counter) <= data]"|WaitClockDataHig1
WaitClockDataHig1-->|counter < 11|WaitClockDataHig1
WaitClockDataLow1-->|counter == 11|GetKey1
GetKey1-->|"KeyVal1 <= shiftReg1(8:1)"|WaitClockDataLow2
WaitClockDataLow2-->|clock = 0|WaitClockDataHig2
WaitClockDataHig2-->|"clock = 1 [increment counter by 1]"|WaitClockDataLow2
WaitClockDataHig2-->|"clock = 0 [shiftReg2(counter) <= data]"|WaitClockDataHig2
WaitClockDataHig2-->|counter < 11|WaitClockDataHig2
WaitClockDataLow2-->|counter == 11|GetKey2
GetKey2-->|"KeyVal2 <= shiftReg2(8:1)"|BreakCodeCheck
BreakCodeCheck-->|"KeyVal1 == E0 [Arrow Keys and KeyVal2 will have key pressed]"|WaitClockDataLow1
BreakCodeCheck-->|"KeyVal2 != F0 [Loop to get a break code]"|WaitClockDataLow2
BreakCodeCheck-->|KeyVal2 == F0|WaitClockDataLow3
WaitClockDataLow3-->|clock = 0|WaitClockDataHig3
WaitClockDataHig3-->|"clock = 1 [increment counter by 1]"|WaitClockDataLow3
WaitClockDataHig3-->|"clock = 0 [shiftReg3(counter) <= data]"|WaitClockDataHig3
WaitClockDataHig3-->|counter < 11|WaitClockDataHig3
WaitClockDataLow3-->|counter == 11|GetKey3
GetKey3-->|"KeyVal3 <= shiftReg3(8:1)"|WaitClockDataLow1


```
