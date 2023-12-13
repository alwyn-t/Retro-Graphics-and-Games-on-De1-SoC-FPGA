module FIFO(input buffClk, newFrame, output reg [10:0] buffX, buffY, input updatePixel , input [15:0] cRGBin, input scanClk, activePixels, output reg [15:0] cRGBout, input busy, output reg [23:0] address, output reg write, output reg [15:0] dataOut, output reg read, input [15:0] dataIn, input readReady, output reg loadTempBuffer);
	parameter X_SCREEN_PIXELS = 11'd800;
	parameter Y_SCREEN_PIXELS = 11'd600;
	reg [(400*16)-1:0] tempBuffer;
	reg [8:0] readCursor;   // 9 bit
	reg [8:0] outputCursor; // 9 bit
	reg loadNewFrame;
	//reg loadTempBuffer;
	
	initial begin
		buffX <= 0;
		buffY <= 0;
		//tempBuffer = 0;
		tempBuffer = 1024'd999999999999999999999999999999999999;
		readCursor = 0;
		outputCursor = 0;
		loadNewFrame = 0;
		loadTempBuffer = 0;
	end
	
	reg activeBuffer;
	initial activeBuffer = 1;
	
	wire [23:0] writeAddress;
	positionToAddress posToAddr0 (.firstBuffer(activeBuffer), .x(buffX), .y(buffY), .address(writeAddress));
	defparam posToAddr0.X_SCREEN_PIXELS = X_SCREEN_PIXELS;
	defparam posToAddr0.Y_SCREEN_PIXELS = Y_SCREEN_PIXELS;
	reg [10:0] readX, readY;
	initial readX = 0;
	initial readY = 0;
	wire [23:0] readAddress;
	positionToAddress posToAddr1 (.firstBuffer(activeBuffer), .x(readX), .y(readY), .address(readAddress));
	defparam posToAddr1.X_SCREEN_PIXELS = X_SCREEN_PIXELS;
	defparam posToAddr1.Y_SCREEN_PIXELS = Y_SCREEN_PIXELS;
	
	reg newFrameTrigger;
	initial newFrameTrigger = 0;
	
	reg [6:0] test;
	initial test = 0;
	
	reg yAxisPixelToggle;
	initial yAxisPixelToggle = 1;
	reg finishedLine;
	initial finishedLine = 0;
	always@ (posedge buffClk) begin
		write <= 0;
		read <= 0;
		if (!loadNewFrame && ((readCursor != outputCursor) || loadTempBuffer)) begin // when data can be loaded into the temporary buffer, cases include when loadTempBuffer trigger is set to high, or when the readX and readY are not at the start and the readCursor is at outputCursor
			if (!busy) begin
				if (yAxisPixelToggle && !finishedLine) begin
					if (readX == 2)
						loadTempBuffer <= 0; // turn off trigger to start loading temporary buffer
					if (readReady)
						tempBuffer[(readCursor*16) +: 16] <= dataIn; // static noise
					readCursor <= (readCursor != 399) ? readCursor + 1 : 0;
					address <= readAddress;
					read <= 1;
					if (readY == Y_SCREEN_PIXELS - 2 && readX == X_SCREEN_PIXELS - 2) begin
						readX <= 0;
						readY <= 0;
					end else begin
						readY <= (readX == X_SCREEN_PIXELS - 2) ? readY + 2 : readY;
						readX <= (readX == X_SCREEN_PIXELS - 2) ? 0 : readX + 2;
					end
					finishedLine <= (readCursor == 399) ? 1 : 0;
				end else if (!yAxisPixelToggle)
					finishedLine <= 0;
			end
		end else if (loadNewFrame) begin // loading data into buffer
			if (!busy) begin
				if (updatePixel) begin
					dataOut <= cRGBin;
					address <= writeAddress;
					write <= 1;
				end
				if (buffY >= Y_SCREEN_PIXELS - 2 && buffX >= X_SCREEN_PIXELS - 2) begin
					loadNewFrame <= 0; // end putting data into the buffer
					loadTempBuffer <= 1; // can start loading into the temporary buffer
					readX <= 0;
					readY <= 0;
					buffX <= 0;
					buffY <= 0;
				end else begin
					buffY <= (buffX == X_SCREEN_PIXELS - 2) ? buffY + 2 : buffY;
					buffX <= (buffX == X_SCREEN_PIXELS - 2) ? 0 : buffX + 2;
				end
			end
		end
		if (newFrame && !newFrameTrigger) begin
			activeBuffer <= !activeBuffer;
			loadNewFrame <= 1;
			newFrameTrigger <= 1;
			//loadTempBuffer <= 1; //////// uncomment to force the data to be loaded into temporary buffer first
			buffX <= 0;
			buffY <= 0;
			readX <= 0;
			readY <= 0;
		end else if (!newFrame)
			newFrameTrigger <= 0;
	end
	
	reg xAxisPixelToggle;
	initial xAxisPixelToggle = 0;
	always@ (scanClk) begin
		if (activePixels) begin
			cRGBout <= tempBuffer[(outputCursor*16) +: 16];
			outputCursor <= (xAxisPixelToggle) ? ((outputCursor != 399) ? outputCursor + 1 : 0) : outputCursor;
			xAxisPixelToggle = !xAxisPixelToggle;
			yAxisPixelToggle = (outputCursor != 399) ? yAxisPixelToggle: !yAxisPixelToggle;
		end
	end
endmodule

module positionToAddress(input firstBuffer, input [10:0] x, y, output [23:0] address); // 2 bank, 13 row, 9 col
	parameter X_SCREEN_PIXELS = 11'd1920;
	parameter Y_SCREEN_PIXELS = 11'd1080;
	assign address = (x + y * X_SCREEN_PIXELS) * 2 + (firstBuffer ? 0 : X_SCREEN_PIXELS * Y_SCREEN_PIXELS * 2);
endmodule
