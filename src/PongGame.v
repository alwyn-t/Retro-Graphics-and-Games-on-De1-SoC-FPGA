module PongGame(input clock_60Hz, reset, enable, escape, leftUp, leftDown, rightUp, rightDown, start, input [10:0] scanX, scanY, output [7:0] oR, oG, oB, output [31:0] spriteID, output updatePixel, output [15:0] pong_cRGB, output [3:0] leftScore, rightScore);
	wire [9:0] ball_x, ball_y;
	wire [9:0] leftPaddle_y, rightPaddle_y;
	// wire [3:0] leftScore, rightScore;
	
	PongController controller(.clock(clock_60Hz), .reset(reset), .enable(enable), .escape(escape), .leftPaddleUp(leftUp), .leftPaddleDown(leftDown), .rightPaddleUp(rightUp), .rightPaddleDown(rightDown), .start(start), .ball_x(ball_x), .ball_y(ball_y), .leftPaddle_y(leftPaddle_y), .rightPaddle_y(rightPaddle_y), .oLeft_Score(leftScore), .oRight_Score(rightScore));
	PongVideo video(.clock(clock_60Hz), .x(scanX), .y(scanY), .ball_x(ball_x), .ball_y(ball_y), .leftPaddle_y(leftPaddle_y), .rightPaddle_y(rightPaddle_y), .LS(leftScore), .RS(rightScore), .R(oR), .G(oG), .B(oB), .spriteID(spriteID), .updatePixel(updatePixel), .pong_cRGB(pong_cRGB));
endmodule