module VideoBuffer (input reset, input CLOCK_400, newFrame, output reg [9:0] buffX, buffY, input [7:0] iR, iG, iB, input CLOCK_40, input [9:0] scanX, scanY, output [7:0] oR, oG, oB);
	parameter X_SCREEN_PIXELS = 8'd800;
	parameter Y_SCREEN_PIXELS = 7'd600;
	
	reg scanBuffer;
	reg readyToScanBuffer;
	initial begin
		scanBuffer <= 0;
		readyToScanBuffer <= 1;
	end
	always@(posedge CLOCK_400) begin
		if (done) begin
			if (newFrame) begin
				buffX <= 0;
				buffY <= 0;
			end
			else if(buffX != X_SCREEN_PIXELS-1 && buffY != Y_SCREEN_PIXELS-1 && !scanBuffer) begin
				buffY <= (buffX == X_SCREEN_PIXELS-1) ? buffY+1 : buffY; // reached the end of the line, increment y
				buffX <= (buffX == X_SCREEN_PIXELS-1) ? 0 : buffX+1; // reach the end of the line, go back to 0
			end
			//else if(buffX != X_SCREEN_PIXELS-1 && buffY != Y_SCREEN_PIXELS-1)
			if (CLOCK_40) begin
				scanBuffer <= readyToScanBuffer; // high for 1 cycle
				readyToScanBuffer <= 0;
			end
			else
				readyToScanBuffer <= 1;
			go <= 1;
		end
		else
			go <= 0;
		/*if (CLOCK_40) begin
			scanBuffer <= readyToScanBuffer; // high for 1 cycle
			readyToScanBuffer <= 0;
		end
		else
			readyToScanBuffer <= 1;*/
	end
	
	wire [31:0] buffAddress;
	wire [31:0] scanAddress;
	assign buffAddress = (buffX + Y_SCREEN_PIXELS * buffY)*32;
	assign scanAddress = (scanX + Y_SCREEN_PIXELS * scanY)*32;
	
	wire [31:0] dataIn;
	wire [31:0] dataOut;
	assign dataIn = {iR + iG + iB};
	assign oR = dataOut[23:16];
	assign oG = dataOut[15: 8];
	assign oB = dataOut[ 7: 0];
	//assign oR, oG, oB = dataOut[23:0];
	
	reg go;
	wire done;
	initial go <= 0;
	
	custom_master (
		.clk(CLOCK_400),
		.reset(reset),
		
		// control inputs and outputs
		.control_fixed_location(0),
		.control_read_base(scanAddress),
		.control_read_length(32),
		.control_write_base(buffAddress),
		.control_write_length(32),
		.control_go(buffering),
		.control_done(done),
		//.control_early_done(),
	
		// user logic inputs and outputs
		.user_read_buffer(!scanBuffer),
		.user_write_buffer(scanBuffer),
		.user_buffer_input_data(dataIn),
		.user_buffer_output_data(dataOut),
		//.user_data_available(),
		//.user_buffer_full(),
	
		// master inputs and outputs
		//.master_address(),
		//.master_read(),
		//.master_write(),
		//.master_byteenable(),
		.master_readdata(dataIn),	// ?????????
		.master_readdatavalid(1),
		//.master_writedata(dataOut),	// ?????????
		//.master_burstcount(),
		.master_waitrequest(!go)
	);
endmodule

/*	parameter MASTER_DIRECTION = 0;							// 0 for read master, 1 for write master
	parameter DATA_WIDTH = 32;
	parameter MEMORY_BASED_FIFO = 1;						// 0 for LE/ALUT FIFOs, 1 for memory FIFOs (highly recommend 1)
	parameter FIFO_DEPTH = 32;
	parameter FIFO_DEPTH_LOG2 = 5;
	parameter ADDRESS_WIDTH = 32;
	parameter BURST_CAPABLE = 0;							// 1 to enable burst, 0 to disable it
	parameter MAXIMUM_BURST_COUNT = 2;
	parameter BURST_COUNT_WIDTH = 2;
		defparam a_burst_read_master.DATAWIDTH = DATA_WIDTH;
		defparam a_burst_read_master.MAXBURSTCOUNT = MAXIMUM_BURST_COUNT;
		defparam a_burst_read_master.BURSTCOUNTWIDTH = BURST_COUNT_WIDTH;
		defparam a_burst_read_master.BYTEENABLEWIDTH = DATA_WIDTH/8;
		defparam a_burst_read_master.ADDRESSWIDTH = ADDRESS_WIDTH;
		defparam a_burst_read_master.FIFODEPTH = FIFO_DEPTH;
		defparam a_burst_read_master.FIFODEPTH_LOG2 = FIFO_DEPTH_LOG2;
		defparam a_burst_read_master.FIFOUSEMEMORY = MEMORY_BASED_FIFO;*/



/*
module VideoBuffer(input scanClock, reset, newFrame, input [7:0] iR, iG, iB, input [10:0] scanX, scanY, input buffClock, output reg [10:0] buffX, buffY, output [7:0] oR, oG, oB);
	parameter X_SCREEN_PIXELS = 8'd800;
	parameter Y_SCREEN_PIXELS = 7'd600;
	
	reg runBufferScan;
	initial begin runBufferScan = 0; buffX = 0; buffY = 0; end
	always@ (posedge buffClock) begin
		if (newFrame)
			runBufferScan <= 1;
		if (buffX == X_SCREEN_PIXELS && runBufferScan)
			if (buffY == Y_SCREEN_PIXELS) begin
				buffX <= 0;
				buffY <= 0;
				runBufferScan <= 0;
			end else begin
				buffX <= 0;
				buffY <= buffY + 1;
			end
		else
			buffX = buffX + 1;
	end
	
	reg activeBuffer; // low is buff0, high is buff1
//	wire [7:0] buff0_R, buff0_G, buff0_B, buff1_R, buff1_G, buff1_B;
//	assign oR = (activeBuffer) ? buff1_R : buff0_R;
//	assign oG = (activeBuffer) ? buff1_G : buff0_G;
//	assign oB = (activeBuffer) ? buff1_B : buff0_B;
	
	initial activeBuffer = 0;
	always@ (posedge newFrame)
		activeBuffer <= !activeBuffer;
	
	wire [15:0] writeAddress, readAddress;
	wire  [7:0] writeOffset,  readOffset;
	PositionToAddress posToAddr0 (.x(scanX), .y(scanY), .address(readAddress), .offset(readOffset));
	PositionToAddress posToAddr1 (.x(buffX), .y(buffY), .address(writeAddress), .offset(writeOffset));
	wire [255:0] dataIn;
	assign dataIn = (writeOffset ==  0) ? {dataOut0[255:  8] + iR                    } : ( (writeOffset ==  1) ? {dataOut0[255: 16] + iR + dataOut0[  7:0]} : ( (writeOffset ==  2) ? {dataOut0[255: 24] + iR + dataOut0[ 16:0]} : ( (writeOffset ==  3) ? {dataOut0[255: 32] + iR + dataOut0[ 23:0]} : ( (writeOffset ==  4) ? {dataOut0[255: 40] + iR + dataOut0[ 31:0]} : ( (writeOffset ==  5) ? {dataOut0[255: 48] + iR + dataOut0[ 39:0]} : ( (writeOffset ==  6) ? {dataOut0[255: 56] + iR + dataOut0[ 47:0]} : ( (writeOffset ==  7) ? {dataOut0[255: 64] + iR + dataOut0[ 55:0]} : ( (writeOffset ==  8) ? {dataOut0[255: 72] + iR + dataOut0[ 63:0]} : ( (writeOffset ==  9) ? {dataOut0[255: 80] + iR + dataOut0[ 71:0]} : ( (writeOffset ==  10) ? {dataOut0[255: 88] + iR + dataOut0[ 79:0]} : ( (writeOffset ==  11) ? {dataOut0[255: 96] + iR + dataOut0[ 87:0]} : ( (writeOffset ==  12) ? {dataOut0[255:104] + iR + dataOut0[ 95:0]} : ( (writeOffset == 13) ? {dataOut0[255:112] + iR + dataOut0[103:0]} : ( (writeOffset == 14) ? {dataOut0[255:120] + iR + dataOut0[111:0]} : ( (writeOffset == 15) ? {dataOut0[255:128] + iR + dataOut0[119:0]} : ( (writeOffset == 16) ? {dataOut0[255:136] + iR + dataOut0[127:0]} : ( (writeOffset == 17) ? {dataOut0[255:144] + iR + dataOut0[135:0]} : ( (writeOffset == 18) ? {dataOut0[255:152] + iR + dataOut0[143:0]} : ( (writeOffset == 19) ? {dataOut0[255:160] + iR + dataOut0[151:0]} : ( (writeOffset == 20) ? {dataOut0[255:168] + iR + dataOut0[159:0]} : ( (writeOffset == 21) ? {dataOut0[255:176] + iR + dataOut0[167:0]} : ( (writeOffset == 22) ? {dataOut0[255:184] + iR + dataOut0[175:0]} : ( (writeOffset == 23) ? {dataOut0[255:192] + iR + dataOut0[183:0]} : ( (writeOffset == 24) ? {dataOut0[255:200] + iR + dataOut0[191:0]} : ( (writeOffset == 25) ? {dataOut0[255:208] + iR + dataOut0[199:0]} : ( (writeOffset == 26) ? {dataOut0[255:216] + iR + dataOut0[207:0]} : ( (writeOffset == 27) ? {dataOut0[255:224] + iR + dataOut0[215:0]} : ( (writeOffset == 28) ? {dataOut0[255:232] + iR + dataOut0[223:0]} : ( (writeOffset == 29) ? {dataOut0[255:240] + iR + dataOut0[231:0]} : ( (writeOffset == 30) ? {dataOut0[255:248] + iR + dataOut0[239:0]} : ( (writeOffset == 31) ? {                    iR + dataOut0[247:0]} : ( {dataOut0[255:144] + iR + dataOut0[135:0]} ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ;
	//assign dataIn = (activeBuffer) ? {dataOut1[255:writeOffset+8] + iR + (writeAddress != 0) ? dataOut1[writeOffset-1:0] : 0} : {dataOut0[255:writeOffset+8] + iR + (writeAddress != 0) ? dataOut0[writeOffset-1:0] : 0};
	wire [255:0] dataOut0, dataOut1;
	Buffer0 buff0 (.address(( activeBuffer) ? readAddress : writeAddress), .clock(( activeBuffer) ? scanClock : buffClock), .data(dataIn), .wren(!activeBuffer), .q(dataOut0));
	Buffer1 buff1 (.address((!activeBuffer) ? readAddress : writeAddress), .clock((!activeBuffer) ? scanClock : buffClock), .data(dataIn), .wren( activeBuffer), .q(dataOut1));
	assign oR = dataIn[readOffset +: 8];
	assign oG = dataIn[readOffset +: 8];
	assign oB = dataIn[readOffset +: 8];
//	buffer buff0 (.clock(clock), .reset(reset), .wren(!activeBuffer), .address((scanX+scanY*11'd800)), .data({oR + oG + oB}), .R(buff0_R), .G(buff0_G), .B(buff0_B));
//	buffer buff1 (.clock(clock), .reset(reset), .wren( activeBuffer), .address((scanX+scanY*11'd800)), .data({oR + oG + oB}), .R(buff1_R), .G(buff1_G), .B(buff1_B));
endmodule
*/

module PositionToAddress(input [10:0] x, y, output [15:0] address, output [5:0] offset);
	// based on 1920 x 1080 with 8 bit data for colour data
	wire [20:0] position;
	assign position = (y * 1080 + x);
	assign address = position / 32; // multiply by 8 as we can store 8 bits per position 256/8 = 32
	assign offset = (position % 256) / 8;
endmodule

//module buffer(input clock, reset, wren, input [19:0] address, input [23:0] data, output reg [7:0] R, G, B);
//	reg [11519999:0] vram; // size of 800*600*24 = 11,520,000
//	
//	always@(posedge clock) begin
//		if (reset)
//			vram <= 0;
//		else if (wren)
//			vram[address*5'd24 +: 24] <= data;
//		R <= vram[address*5'd24 +: 8];
//		G <= vram[address*5'd24+8 +: 8];
//		B <= vram[address*5'd24+16 +: 8];
//	end
	//assign R = vram[(address+1)*5'd24-1 : (address+1)*5'd24-8];
	//assign G = vram[(address+1)*5'd24-9 : (address+1)*5'd24-16];
	//assign B = vram[(address+1)*5'd24-17 : (address+1)*5'd24-24];
//endmodule