module console #(parameter CLOCK_FREQUENCY = 50000000) (input CLOCK_50, PS2_CLK, PS2_DAT, output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, output [9:0] LEDR, input [3:0] KEY, input [9:0] SW,
	// VGA
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, 
	output [7:0] VGA_R, VGA_G, VGA_B

	// sdram
	/*output [12:0] DRAM_ADDR, 
	output [1:0] DRAM_BA, 
	output DRAM_CAS_N, DRAM_CKE, 
	output DRAM_CS_N,
	inout [15:0] DRAM_DQ, 
	output DRAM_LDQM, DRAM_UDQM,
	output DRAM_RAS_N,
	output DRAM_WE_N, DRAM_CLK*/
	);
	
	//assign LEDR[0] = VGA_BLANK_N;
	wire w_flag, a_flag, s_flag, d_flag, up_flag, left_flag, down_flag, right_flag, space_flag, enter_flag, escape_flag;
	PS2 keyboard(.Clock_50(Clock_50), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .HEX5(/*HEX5*/), .HEX4(/*HEX4*/), .HEX3(/*HEX3*/), .HEX2(/*HEX2*/), .HEX1(/*HEX1*/), .HEX0(/*HEX0*/), .LEDR(/*LEDR[9:2]*/), .w_flag(w_flag), .a_flag(a_flag), .s_flag(s_flag), .d_flag(d_flag), .up_flag(up_flag), .left_flag(left_flag), .down_flag(down_flag), .right_flag(right_flag), .space_flag(space_flag), .enter_flag(enter_flag), .escape_flag(escape_flag));
	
	wire clock_60Hz;
	// clock_60Hz clk60 (.clock_in(CLOCK_50), .clock_60Hz(clock_60Hz));
	assign clock_60Hz = newFrame;
	
	//wire [7:0] pongR, pongG, pongB;
	wire [10:0] buffX, buffY;
	wire updatePixel;
	wire [15:0] pong_cRGB;
	//PongGame pongGame(.clock_60Hz(clock_60Hz), .reset(!KEY[0]), .enable(1), .leftUp(w_flag), .leftDown(s_flag), .rightUp(up_flag), .rightDown(down_flag), .start(space_flag), .scanX(buffX), .scanY(buffY), .updatePixel(updatePixel), .pong_cRGB(pong_cRGB));
	//DinoGame dinoGame(.clock_60Hz(clock_60Hz), .reset(!KEY[0]), .enable(1), .jump(space_flag), .start(up_flag), .scanX(scanX), scanY(scanY), .oR(VGA_R), .oG(VGA_G), .oB(VGA_B), .updatePixel(), .dino_cRGB());
	
	wire CLOCK_40;
	wire CLOCK_40_shifted;
	wire CLOCK_200;
	wire CLOCK_200_shifted;
	PLL pll(.refclk(CLOCK_50), .rst(!KEY[0]), .outclk_0(CLOCK_40), .outclk_1(CLOCK_40_shifted), .outclk_2(CLOCK_200), .outclk_3(CLOCK_200_shifted));
	wire [9:0] scanX, scanY;
	wire activePixels, newFrame;
	assign VGA_CLK = CLOCK_40_shifted;
	VGA display(.clock(CLOCK_40), .reset(!KEY[0]), .oH_sync(VGA_HS), .oY_sync(VGA_VS), .oBlank(VGA_BLANK_N), .oSync(VGA_SYNC_N), .oClock(/*VGA_CLK*/), .oX(scanX), .oY(scanY), .eActivePixels(activePixels), .eNewFrame(newFrame));

	wire [7:0] randNum;
	Randomizer randomizer (.clock(clock_60Hz), .value(randNum));

	wire load;
	wire gameSelectEnable, pongEnable, dinoEnable;
	wire [2:0] game;
	wire doneLoading = 1;
	wire [19:0] gameSelectTime;
	GameSelect gameSelect(.clock_60Hz(clock_60Hz), .reset(!KEY[0]), .doneLoading(doneLoading), .escape(escape_flag), .up(up_flag), .down(down_flag), .left(left_flag), .right(right_flag), .enter(enter_flag), .space(space_flag), .load(load), .gameSelectEnable(gameSelectEnable), .pongEnable(pongEnable), .dinoEnable(dinoEnable), .game(game), .gameSelectTime(gameSelectTime));
	wire [7:0] selectR, selectG, selectB;
	GameSelectVideo gameSelectVideo(.clk(CLOCK_40), .enable(gameSelectEnable), .game(game), .scanX(scanX), .scanY(scanY), .oR(selectR), .oG(selectG), .oB(selectB), .SW(SW));
	
	wire [7:0] pongR, pongG, pongB;
	wire [3:0] pongLeftScore, pongRightScore;
	PongGame pongGame(.clock_60Hz(clock_60Hz), .reset(!KEY[0] || !KEY[1] || !KEY[3]), .enable(pongEnable), .escape(escape_flag), .leftUp(w_flag), .leftDown(s_flag), .rightUp(up_flag), .rightDown(down_flag), .start(space_flag), .scanX(scanX), .scanY(scanY), .oR(pongR), .oG(pongG), .oB(pongB), .leftScore(pongLeftScore), .rightScore(pongRightScore));
	wire [7:0] dinoR, dinoG, dinoB;
	wire [31:0] dinoScore;
	DinoGame dinoGame(.clock_60Hz(clock_60Hz), .clock_40MHz(CLOCK_40), .reset(!KEY[0] || !KEY[1] || !KEY[2]), .enable(dinoEnable), .escape(escape_flag), .jump(space_flag), .start(space_flag), .scanX(scanX), .scanY(scanY), .oR(dinoR), .oG(dinoG), .oB(dinoB), .updatePixel(), .dino_cRGB(), .score(dinoScore));
	assign VGA_R = gameSelectEnable ? selectR : (pongEnable ? pongR : (dinoEnable ? dinoR : 0));
	assign VGA_G = gameSelectEnable ? selectG : (pongEnable ? pongG : (dinoEnable ? dinoG : 0));
	assign VGA_B = gameSelectEnable ? selectB : (pongEnable ? pongB : (dinoEnable ? dinoB : 0));
	wire [3:0] digit0 = (gameSelectEnable ? gameSelectTime : (pongEnable ? pongRightScore : (dinoEnable ? dinoScore : 0)))%10;
	wire [3:0] digit1 = (gameSelectEnable ? gameSelectTime : (pongEnable ? pongRightScore : (dinoEnable ? dinoScore : 0)))/10%10;
	wire [3:0] digit2 = (gameSelectEnable ? gameSelectTime : (pongEnable ? 0 : (dinoEnable ? dinoScore : 0)))/100%10;
	wire [3:0] digit3 = (gameSelectEnable ? gameSelectTime : (pongEnable ? 0 : (dinoEnable ? dinoScore : 0)))/1000%10;
	wire [3:0] digit4 = (gameSelectEnable ? gameSelectTime : (pongEnable ? pongLeftScore*10000 : (dinoEnable ? dinoScore : 0)))/10000%10;
	wire [3:0] digit5 = (gameSelectEnable ? gameSelectTime : (pongEnable ? pongLeftScore*10000 : (dinoEnable ? dinoScore : 0)))/100000%10;
	hex_decoder h0 (.in(digit0), .hex(HEX0));
	hex_decoder h1 (.in(digit1), .hex(HEX1));
	hex_decoder h2 (.in(digit2), .hex(HEX2));
	hex_decoder h3 (.in(digit3), .hex(HEX3));
	hex_decoder h4 (.in(digit4), .hex(HEX4));
	hex_decoder h5 (.in(digit5), .hex(HEX5));
	//assign LEDR[0] = space_flag;
	//assign LEDR[1] = up_flag;
	assign LEDR[0] = gameSelectEnable;
	assign LEDR[9:1] = selectR;

	// FIFO
	wire busy;
	wire [23:0] address; // 2 bank 13 row 9 col
	wire write;
	wire [15:0] dataIn;
	wire read;
	wire [15:0] dataOut;
	// assign LEDR[4] = write;
	// assign LEDR[3] = activePixels;
	// assign LEDR[2] = read; 		////// detect read calls
	// assign LEDR[1] = newFrame; ///
	// assign LEDR[0] = busy;     //////////
	wire [15:0] cRGBout;
	//wire [15:0] cRGBin = {1'b1, pongR>>3, pongG>>3, pongB>>3};
	wire loadTempBuffer;
	wire readReady; // CLOCK_200 -> CLOCK_200_shifted
	FIFO fifo(.buffClk(CLOCK_200_shifted), .newFrame(newFrame), .buffX(buffX), .buffY(buffY), .updatePixel(updatePixel), .cRGBin(pong_cRGB), .scanClk(CLOCK_40_shifted), .activePixels(activePixels), .cRGBout(cRGBout), .busy(busy), .address(address), .write(write), .dataOut(dataIn), .read(read), .dataIn(dataOut), .readReady(readReady), .loadTempBuffer(loadTempBuffer));
	//defparam fifo.X_SCREEN_PIXELS = 800;
	//defparam fifo.Y_SCREEN_PIXELS = 600;
	//assign VGA_R = (cRGBout[15]) ? cRGBout[14:10] << 3 : 0;
	//assign VGA_G = (cRGBout[15]) ? cRGBout[ 9: 5] << 3 : 0;
	//assign VGA_B = (cRGBout[15]) ? cRGBout[ 4: 0] << 3 : 0;
	
	// reg [3:0] counter;
	// initial counter = 0;
	// always@(posedge CLOCK_40) begin
	// 	if (activePixels)
	// 		counter <= counter + 1;
	// end
	
	// reg [3:0] readCounter;
	// initial readCounter = 0;
	// always@(posedge read)
	// 	readCounter <= readCounter + 1;
	
	// reg [6:0] writeCounter;
	// initial writeCounter = 0;
	// always@(posedge write)
	// 	writeCounter <= writeCounter + 1;
	
	// reg loadTempBufferTrigger;
	// initial loadTempBufferTrigger = 0;
	// reg [6:0] loadTempBufferCounter;
	// initial loadTempBufferCounter = 0;
	// always@(posedge loadTempBuffer) begin
	// 	loadTempBufferCounter <= loadTempBufferCounter + 1;
	// 	loadTempBufferTrigger <= 1;
	// end
	

	// counter is triggering so active pixels are working
	// readCounter is not triggering so read is never being set high
	// pong_cRGB is valid
	// loadTempBufferTrigger never goes high
	
	//hex_decoder h0 (.in(pong_cRGB[ 3: 0]), .hex(HEX2));
	//hex_decoder h1 (.in(pong_cRGB[ 7: 4]), .hex(HEX3));
	// hex_decoder h2 (.in(pong_cRGB[11: 8]), .hex(HEX4));
	// hex_decoder h3 (.in(pong_cRGB[15:12]), .hex(HEX5));
	// hex_decoder h0 (.in(cRGBout[ 3: 0]), .hex(HEX2));
	// hex_decoder h1 (.in(cRGBout[ 7: 4]), .hex(HEX3));
	//hex_decoder h2 (.in(cRGBout[11: 8]), .hex(HEX4));
	//hex_decoder h3 (.in(cRGBout[15:12]), .hex(HEX5));
	//hex_decoder h0 (.in(buffX[ 5: 2]), .hex(HEX2));
	//hex_decoder h1 (.in(buffX[ 9: 6]), .hex(HEX3));
	//hex_decoder h2 (.in(buffY[ 5: 2]), .hex(HEX4));
	//hex_decoder h3 (.in(buffY[ 9: 6]), .hex(HEX5));
	// hex_decoder h4 (.in(readCounter[ 3: 0]), .hex(HEX1));
	// hex_decoder h5 (.in(writeCounter[ 5: 2]), .hex(HEX0));
	//hex_decoder h5 (.in(loadTempBufferCounter[ 6: 3]), .hex(HEX0));
	// assign LEDR[9] = loadTempBufferTrigger;
	// assign LEDR[8] = !write;
	// assign LEDR[7] = buffX[8];
	// assign LEDR[6] = buffY[8];
	// assign LEDR[5] = updatePixel;
	
	
	
	// sdramController
	
	assign DRAM_CLK = CLOCK_200_shifted;
	reg sdramStartUpReset;
	initial sdramStartUpReset = 0;
	always@ (CLOCK_200)
		sdramStartUpReset = 1;
	sdram_controller sdramController(
		// HOST INTERFACE
		.wr_addr(address),
		.wr_data(dataIn),
		.wr_enable(write),

		.rd_addr(address),
		.rd_data(dataOut),
		.rd_ready(readReady),
		.rd_enable(read),

		.busy(busy), .rst_n(sdramStartUpReset), .clk(CLOCK_200),

		// SDRAM SIDE
		.addr(DRAM_ADDR), .bank_addr(DRAM_BA), .data(DRAM_DQ), .clock_enable(DRAM_CKE), .cs_n(DRAM_CS_N), .ras_n(DRAM_RAS_N), .cas_n(DRAM_CAS_N), .we_n(DRAM_WE_N),
		.data_mask_low(DRAM_LDQM), .data_mask_high(DRAM_UDQM)
	);
	defparam sdramController.CLK_FREQUENCY = 200;
	
endmodule