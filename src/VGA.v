module VGA(input clock, reset, output reg oH_sync, oY_sync, oBlank, output oSync, oClock, output wire [9:0] oX, output wire [9:0] oY, output reg eActivePixels, output reg eNewFrame);
	parameter X_SCREEN_PIXELS = 8'd800;
	parameter Y_SCREEN_PIXELS = 7'd600;
	//parameter X_SCREEN_PIXELS = 10'd800;
	//parameter Y_SCREEN_PIXELS = 10'd600;
	parameter PADDLE_HEIGHT = 7'd32;
	parameter PADDLE_DEPTH = 7'd4;

	localparam H_SYNC_START	= 40;				// Horizontal sync start, Front Porch
	localparam H_SYNC_END	= 40 + 128;			// Horizontal sync end, Front Porch + Sync Pulse
	localparam H_PIXL_START = 40 + 128 + 88;	// Horizontal pixel start, Front Porch + Sync Pulse + Back Porch
	localparam V_SYNC_START = 600 + 1;			// Vertical sync start, Horizontal pixels + Front Porch
	localparam V_SYNC_END	= 600 + 1 +4;		// Vertical sync end, Horizontal pixels + Front Porch + Sync Pulse
	localparam V_PIXL_END 	= 600;				// Vertical pixel end, Horizontal pixels
	localparam H_LENGTH		= 1056;				// 800 + 40 + 128 + 88
	localparam V_HEIGHT		= 628;				// 600 + 1 + 4 + 23
	
	reg [10:0] x;
	reg  [9:0] y;
	reg oH_sync_0, oY_sync_0, oBlank_0;
	
	always@(posedge clock) begin
		if (reset) begin
			x <= 0;
			y <= 0;
		end
		else if (x == H_LENGTH-1) begin
			x <= 0;
			y <= y + 1;
		end
		else
			x <= x+1;
		if (y == V_HEIGHT)
			y <= 0;
		oH_sync_0 <= (x < H_SYNC_START) || (x >= H_SYNC_END); // if between H_SYNC_START-1 and H_SYNC_END, low value
		oY_sync_0 <= (y < V_SYNC_START) || (y >= V_SYNC_END); // if between V_SYNC_START and V_SYNC_END, low value
		oBlank_0 <= (x >= H_PIXL_START) && (y < V_PIXL_END); // high when x and y are valid pixel positions
		oH_sync <= oH_sync_0; // delay signal by 1 clock cycle (based on original VGA Controller)						**** May need to flip the polarity because I'm using SVGA not VGA
		oY_sync <= oY_sync_0; // delay signal by 1 clock cycle (based on original VGA Controller)						**** May need to flip the polarity because I'm using SVGA not VGA
		oBlank <= oBlank_0; // delay signal by 1 clock cycle (based on original VGA Controller)
		
		eActivePixels <= oBlank_0; // high when x and y are valid pixel positions
		// eNewFrame <= x==H_LENGTH-1 && y==V_HEIGHT;
		eNewFrame <= !oY_sync_0;
		// eNewFrame <= 0;
		// if (oY_sync && !oY_sync_0)
		// 	eNewFrame <= 1;
		// eNewFrame <= eActivePixels && !oBlank_0; // if last cycle has active pixels and this cycle has no active pixels, trigger new frame, otherwise goes low
	end
	// assign eNewFrame = (x==H_LENGTH-1) && (y==V_HEIGHT);
	
	assign oX = (x < H_PIXL_START) ? 0 : x-H_PIXL_START; // start the x position when we finish the sync signals
	assign oY = (y < V_PIXL_END) ? y : V_PIXL_END - 1; // output y position only when we are not doing any sync signals
	//assign oH_sync = (x < H_SYNC_START) || (x >= H_SYNC_END); // if between H_SYNC_START-1 and H_SYNC_END, low value
	//assign oY_sync = (y < V_SYNC_START) || (y >= V_SYNC_END); // if between V_SYNC_START and V_SYNC_END, low value
	//assign oBlank = (x >= H_PIXL_START) && (y < V_PIXL_END); // high when x and y are valid pixel positions
	assign oSync = 1; // ??? should be high at all times?????? (based on original VGA Controller)
	assign oClock = clock;
endmodule