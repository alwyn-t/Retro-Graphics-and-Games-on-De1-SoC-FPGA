module PongController(input clock, reset, enable, escape, leftPaddleUp, leftPaddleDown, rightPaddleUp, rightPaddleDown, start, output reg [9:0] ball_x, ball_y, leftPaddle_y, rightPaddle_y, output reg [3:0] oLeft_Score, oRight_Score);
	parameter X_SCREEN_PIXELS = 10'd800;
	parameter Y_SCREEN_PIXELS = 10'd600;
	parameter PADDLE_HEIGHT = 7'd32;
	parameter PADDLE_DEPTH = 7'd8;
	parameter BALL_RADIUS = 4;
	parameter LEFT_PADDLE_X = 7'd16;
	parameter RIGHT_PADDLE_X = X_SCREEN_PIXELS - LEFT_PADDLE_X - PADDLE_DEPTH;
	wire [9:0] nBall_x, nBall_y;
	wire [9:0] nLeftPaddle_y, nRightPaddle_y;
	reg vx_pos, vy_pos;
	parameter vx = 10;
	parameter vy = 10;
	parameter leftPaddle_vy = 5;
	parameter rightPaddle_vy = 5;
	
	reg endGame;
	
	wire [3:0] vpaddle;
	
	initial begin
		vx_pos <= 1;
		vy_pos <= 1;
		oLeft_Score <= 0;
		oRight_Score <= 0;
		ball_x <= 398;// (X_SCREEN_PIXELS - BALL_RADIUS)/2
		ball_y <= 298;// (Y_SCREEN_PIXELS - BALL_RADIUS)/2
		leftPaddle_y <= 284;// (Y_SCREEN_PIXELS - PADDLE_HEIGHT)/2
		rightPaddle_y <= 284;// (Y_SCREEN_PIXELS - PADDLE_HEIGHT)/2
		endGame <= 0;
	end
	
	assign nBall_x = (vx_pos) ? ball_x + vx :  ball_x - vx;
	assign nBall_y = (vy_pos) ? ball_y + vy :  ball_y - vy;
	assign nLeftPaddle_y = (leftPaddleUp ^ leftPaddleDown) ? ((leftPaddleUp) ? leftPaddle_y - leftPaddle_vy : leftPaddle_y + leftPaddle_vy) : leftPaddle_y;
	assign nRightPaddle_y = (rightPaddleUp ^ rightPaddleDown) ? ((rightPaddleUp) ? rightPaddle_y - rightPaddle_vy : rightPaddle_y + rightPaddle_vy) : rightPaddle_y;
	
	reg [1:0] currentState, nextState;
	localparam 	START_MENU 	= 2'd0,
				GAME		= 2'd1,
				PAUSE_MENU	= 2'd2,
				END_MENU	= 2'd3;
	initial begin
		currentState	<= START_MENU;
		nextState		<= START_MENU;
	end
	
	always@ (posedge clock) begin // main game loop
		if (reset) begin
			currentState	<= START_MENU;
			nextState		<= START_MENU;
		end
		case (currentState)
			START_MENU: nextState <= (start) ? GAME : START_MENU;
			GAME: nextState <= (escape) ? PAUSE_MENU : GAME;
			PAUSE_MENU: nextState <= (start) ? GAME : PAUSE_MENU;
			END_MENU: nextState <= (start) ? START_MENU : END_MENU;
		endcase
		currentState <= nextState;
		if (reset || currentState == START_MENU) begin
			vx_pos <= 1;
			vy_pos <= 1;
			oLeft_Score <= 0;
			oRight_Score <= 0;
			ball_x <= 398;// (X_SCREEN_PIXELS - BALL_RADIUS)/2
			ball_y <= 298;// (Y_SCREEN_PIXELS - BALL_RADIUS)/2
			leftPaddle_y <= 284;// (Y_SCREEN_PIXELS - PADDLE_HEIGHT)/2
			rightPaddle_y <= 284;// (Y_SCREEN_PIXELS - PADDLE_HEIGHT)/2
			endGame <= 0;
		end
		if (!reset && enable && currentState == GAME) begin
			// out of bounds check
			if (nBall_x > X_SCREEN_PIXELS - BALL_RADIUS && nBall_x < X_SCREEN_PIXELS + 112 - BALL_RADIUS/2) begin
				ball_x <= 398;// (X_SCREEN_PIXELS - BALL_RADIUS)/2
				ball_y <= 298;// (Y_SCREEN_PIXELS - BALL_RADIUS)/2
				vx_pos <= 0;
				vy_pos <= 1;
				if (oLeft_Score == 4'd15) begin
					currentState <= END_MENU;
					nextState <= END_MENU;
				end
				else
					oLeft_Score <= oLeft_Score + 1;
			end
			else if (nBall_x >= X_SCREEN_PIXELS + 112 - BALL_RADIUS/2 && nBall_x <= 1024) begin
				ball_x <= 398;// (X_SCREEN_PIXELS - BALL_RADIUS)/2
				ball_y <= 298;// (Y_SCREEN_PIXELS - BALL_RADIUS)/2
				vx_pos <= 1;
				vy_pos <= 1;
				if (oRight_Score == 4'd15) begin
					currentState <= END_MENU;
					nextState <= END_MENU;
				end
				else
					oRight_Score <= oRight_Score + 1;
			end
			else if (nBall_y > Y_SCREEN_PIXELS - BALL_RADIUS) begin
				ball_y <= (vy_pos) ? 2 * Y_SCREEN_PIXELS - nBall_y - 2 * BALL_RADIUS : (1024 - nBall_y);// Y_SCREEN_PIXELS - ((nBall_y + BALL_RADIUS) - Y_SCREEN_PIXELS) - BALL_RADIUS : 1024 = 2^10
				vy_pos <= !vy_pos;
			end
			else begin
				ball_x <= nBall_x;
				ball_y <= nBall_y;
			end
			// paddle interactions
			if (nBall_x + BALL_RADIUS >= LEFT_PADDLE_X && nBall_x <= LEFT_PADDLE_X + PADDLE_DEPTH && nBall_y + BALL_RADIUS >= leftPaddle_y && nBall_y <= leftPaddle_y + PADDLE_HEIGHT) begin
				vx_pos <= 1;
				// score update
			end
			if (nBall_x + BALL_RADIUS >= RIGHT_PADDLE_X && nBall_x <= RIGHT_PADDLE_X + PADDLE_DEPTH && nBall_y + BALL_RADIUS >= rightPaddle_y && nBall_y <= rightPaddle_y + PADDLE_HEIGHT) begin
				vx_pos <= 0;
				// score update
			end
			if (nLeftPaddle_y > Y_SCREEN_PIXELS - PADDLE_HEIGHT && nLeftPaddle_y < Y_SCREEN_PIXELS - PADDLE_HEIGHT/2 + 212)
				leftPaddle_y <= Y_SCREEN_PIXELS - PADDLE_HEIGHT;
			else if (nLeftPaddle_y >= Y_SCREEN_PIXELS - PADDLE_HEIGHT/2 + 212 && nLeftPaddle_y <= 1024)
				leftPaddle_y <= 0;
			else
				leftPaddle_y <= nLeftPaddle_y;
			if (nRightPaddle_y > Y_SCREEN_PIXELS - PADDLE_HEIGHT && nRightPaddle_y < Y_SCREEN_PIXELS - PADDLE_HEIGHT/2 + 212)
				rightPaddle_y <= Y_SCREEN_PIXELS - PADDLE_HEIGHT;
			else if (nRightPaddle_y >= Y_SCREEN_PIXELS - PADDLE_HEIGHT/2 + 212 && nRightPaddle_y <= 1024)
				rightPaddle_y <= 0;
			else
				rightPaddle_y <= nRightPaddle_y;
		end
	end
endmodule