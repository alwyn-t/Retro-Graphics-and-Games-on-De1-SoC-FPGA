# ECE241 Project VGA Output
Deep dive into VGA protocol
## Overview
- VGA refers to 'Video Graphics Array' and was created by IBM. The associated connector is the DE15 socket and is used to transmit video signals to monitors.
- Using a red, green and blue channel data lines with vertical and horizontal sync signals, pixels are sequentially sent to the monitor to be displayed.
- Various resolutions and refresh rates exist which depend on the timings of the vertical and horizontal sync signals. 
## Data
Unlike a lot of digital circuit communications, VGA utilizes voltage variation to allow for a wider range in colours without additional hardware. Specifically, the colour analogue data voltage ranges from 0 - 0.7V. Due to the data of each pixel being sent is sequentially, we can separate the logic for the sync signals (used to coordinate the displays) and the logic for the colours.
Pixel data is sent line by line, each separated by a horizontal sync signal until the entire screen data has been sent, in which the vertical sync signal is sent to indicate a full frame has been transmitted. This structure is repeated for each frame is displayed. Additionally, before and after each sync signal, there is a front porch and back porch respectively which is required to be analog black because it is used as a reference for the RGB values.
Below is 2 lines being sent with horizontal sync signals separating them
[![Horizontal Sync Signals](https://web.mit.edu/6.111/www/labkit/images/vga_line.png)]
Below is a vertical sync signal separating two different frames
[![Vertical Sync Signal](https://web.mit.edu/6.111/www/labkit/images/vga_frame.png)]
There are a few things to notice in these examples.
1. Within the front porch and back porch, all colour analogue data lines are set to a normal black. While the colour values go to a lower voltage when a sync pulse is sent.
2. When traversing the vertical sync pulse, colour values are inverted.
Additional information can be found on [MIT Labkit VGA Video Output](https://web.mit.edu/6.111/www/labkit/vga.shtml).
Another way to visualize the front porch, back porch, horizontal sync and vertical sync signals can be seen below in the various rectangular blocks.
[![Project F Image of Data](https://projectf.io/img/posts/fpga-graphics/display-timings.png)]
Additional information can be found on [Project F Beginning FPGA Graphics](https://projectf.io/posts/fpga-graphics/).
To assist with mapping digital to analogue signals (bits to voltage), FPGAs are often equipped with a VGA DAC (digital to analogue converter). Some can take up to 10 bits of colour data for each RGB value. Please refer to your FPGA board for VGA DAC specifications. For example, for the DE1-SoC FPGA board, the user manual which includes the specific VGA DAC can be found on [terasIC DE1-SoC Board Resources](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=836&PartNo=4#contents). On the DE1-SoC FPGA board, the appropriate sync and blank colour analogues are also taken into account, so I do not have to manually set the digital colour values to normal black.
## Resolution and Refresh Rates
Below are common resolutions, the associated refresh rates, and minimum pixel clocks from [Project F Video Timings](https://projectf.io/posts/video-timings-vga-720p-1080p/). Additional information on the front porch, back porch, horizontal sync and vertical sync signals specifications can be found on Project F and on [TinyVGA VGA Signal Timing](http://tinyvga.com/vga-timing).

Standard | Resolution | Refresh Rate|Minimum Pixel Clock
--|--|--|--
VGA|640x480|60Hz|25.175MHz±0.5%
SVGA|800x600|60Hz|40.000MHz
HD|1280x720|60Hz|74.250MHz
HD|1920x1080|60Hz|148.5MHz
HD|1920x1080|30Hz|74.250MHz

To achieve the correct pixel clock, there are multiple ways. If the internal clock is a whole number multiple of the target clock, a simple counter clock will suffice, giving accurate timings. This works by having a counter to track the number of clock ticks that have passed on the internal clock to be able to trigger the target clock at the appropriate time. On the other hand, if the internal clock and target clock do not line up, you will have to use a PLL (Phase-locked loop) clock which can provide the appropriate clock cycles but with the down side of including noise. There is also a DLL (Delay-locked loop) clock, but it does not have much application in VGA output.
For the DE1-SoC FPGA board, [DE1-SoC My First FPGA](http://www.ee.ic.ac.uk/pcheung/teaching/E2_experiment/My_First_Fpga.pdf) outlines how a PLL clock can be added to our project.

## Similar Projects
Listed below are similar projects which may prove to be useful for referencing.
- [Medium Designing a 24-bit VGA Adapter](https://medium.com/@jeremysee_2/designing-a-24-bit-vga-adapter-acbcccd3258e) - goes into detail about creating a VGA adapter with a VGA DAC
- [Van Hunter Adams VGA Driver in Verilog](https://vanhunteradams.com/DE1/VGA_Driver/Driver.html) - details the VGA standard and provides an implementation of the VGA output drive in Verilog
- [UG EECG VGA Adapter](http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/dev_vga.html) - details using the Nios II processor to connect via a VGA adapter to a DE1-SoC DAC chip
- [UG EECG Interfaces on the DE1-SoC board](http://www-ug.eecg.toronto.edu/msl/manuals/tutorial_DE1-SoC-v5.4.pdf) - details the VGA interface on the DE1-SoC FPGA board (including the VGA DAC and associated pin assignments). Files mentioned in the PDF can be found here on [UG EECG DE1-SoC Tutorials](http://www-ug.eecg.toronto.edu/desl/MSO_de1_tutorials.html)