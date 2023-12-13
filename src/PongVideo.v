module PongVideo(input clock, input [10:0] x, y, input [9:0] ball_x, ball_y, leftPaddle_y, rightPaddle_y, input [3:0] LS, RS, output [7:0] R, G, B, output [31:0] spriteID, output updatePixel, output [15:0] pong_cRGB);
	wire overBall, overLeftPaddle, overRightPaddle, centreLine;
	assign overBall = (x >= ball_x && x <= ball_x + 4) && (y >= ball_y && y <= ball_y + 4);
	assign overLeftPaddle = (x >= 16 && x <= 16 + 8) && (y >= leftPaddle_y && y <= leftPaddle_y + 32);
	assign overRightPaddle = (x >= 800-16-8 && x <= 800-16-8 + 8) && (y >= rightPaddle_y && y <= rightPaddle_y + 32);
	assign centreLine = (x >= 398 && x <= 402);
	
	// original score display
	localparam scoreSize = 32;
	localparam scoreWidth = 8;
	wire [8:0] leftSeg; // 10 11 12 13 14 15
	overlap(leftSeg[0], (LS!=1 && LS!=4 && LS!=11 && LS!=14), 								x, y, 400-64, 						400-64+scoreSize, 				64, 						64+scoreWidth				);
	overlap(leftSeg[1], (LS!=5 && LS!=6 && LS!=15), 										x, y, 400-64+scoreSize-scoreWidth, 	400-64+scoreSize, 				64, 						64+scoreSize				);
	overlap(leftSeg[2], (LS!=2 && LS!=12), 													x, y, 400-64+scoreSize-scoreWidth, 	400-64+scoreSize, 				64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(leftSeg[3], (LS!=1 && LS!=4 && LS!=7 && LS!=11 && LS!=14), 						x, y, 400-64, 						400-64+scoreSize, 				64+scoreSize*2-scoreWidth*2,64+scoreSize*2-scoreWidth	);
	overlap(leftSeg[4], (LS==0 || LS==2 || LS==6 || LS==8 || LS==10 || LS==12), 			x, y, 400-64, 						400-64+scoreWidth, 				64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(leftSeg[5], (LS!=1 && LS!=2 && LS!=3 && LS!=7 && LS!=11 && LS!=12 && LS!=13), 	x, y, 400-64, 						400-64+scoreWidth, 				64, 						64+scoreSize				);
	overlap(leftSeg[6], (LS!=0 && LS!=1 && LS!=7 && LS!=10 && LS!=11), 						x, y, 400-64, 						400-64+scoreSize, 				64+scoreSize-scoreWidth, 	64+scoreSize				);
	overlap(leftSeg[7], (LS>=10), 															x, y, 400-64-scoreWidth*3,			400-64-scoreWidth*2, 			64, 						64+scoreSize				);
	overlap(leftSeg[8], (LS>=10), 															x, y, 400-64-scoreWidth*3,			400-64-scoreWidth*2, 			64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	wire [8:0] rightSeg; // offset when in the double digits
	overlap(rightSeg[0], (RS!=1 && RS!=4 && RS!=11 && RS!=14), 								x, y, 400+64-scoreSize 	+ ((RS>=10)? scoreWidth*2 : 0),	400+64						+ ((RS>=10)? scoreWidth*2 : 0),	64, 						64+scoreWidth				);
	overlap(rightSeg[1], (RS!=5 && RS!=6 && RS!=15), 										x, y, 400+64-scoreWidth + ((RS>=10)? scoreWidth*2 : 0),	400+64						+ ((RS>=10)? scoreWidth*2 : 0),	64, 						64+scoreSize				);
	overlap(rightSeg[2], (RS!=2 && RS!=12), 												x, y, 400+64-scoreWidth + ((RS>=10)? scoreWidth*2 : 0),	400+64						+ ((RS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(rightSeg[3], (RS!=1 && RS!=4 && RS!=7 && RS!=11 && RS!=14), 					x, y, 400+64-scoreSize 	+ ((RS>=10)? scoreWidth*2 : 0),	400+64						+ ((RS>=10)? scoreWidth*2 : 0),	64+scoreSize*2-scoreWidth*2,64+scoreSize*2-scoreWidth	);
	overlap(rightSeg[4], (RS==0 || RS==2 || RS==6 || RS==8 || RS==10 || RS==12), 			x, y, 400+64-scoreSize 	+ ((RS>=10)? scoreWidth*2 : 0),	400+64-scoreSize+scoreWidth	+ ((RS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(rightSeg[5], (RS!=1 && RS!=2 && RS!=3 && RS!=7 && RS!=11 && RS!=12 && RS!=13), 	x, y, 400+64-scoreSize 	+ ((RS>=10)? scoreWidth*2 : 0),	400+64-scoreSize+scoreWidth	+ ((RS>=10)? scoreWidth*2 : 0),	64, 						64+scoreSize				);
	overlap(rightSeg[6], (RS!=0 && RS!=1 && RS!=7 && RS!=10 && RS!=11), 					x, y, 400+64-scoreSize 	+ ((RS>=10)? scoreWidth*2 : 0),	400+64						+ ((RS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize				);
	overlap(rightSeg[7], (RS>=10), 															x, y, 400+64-scoreSize, 				400+64-scoreSize+scoreWidth,			64, 						64+scoreSize				);
	overlap(rightSeg[8], (RS>=10), 															x, y, 400+64-scoreSize, 				400+64-scoreSize+scoreWidth,			64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	
	// ball, left paddle, right paddle, centreLine, score
	assign R = (overBall) ? 8'd255 : ((overLeftPaddle) ? 8'd255 : ((overRightPaddle) ? 8'd255 : ((centreLine || leftSeg || rightSeg) ? 8'd127 : 0 )));
	assign G = (overBall) ? 8'd255 : ((overLeftPaddle) ? 8'd255 : ((overRightPaddle) ? 8'd255 : ((centreLine || leftSeg || rightSeg) ? 8'd127 : 0 )));
	assign B = (overBall) ? 8'd255 : ((overLeftPaddle) ? 8'd255 : ((overRightPaddle) ? 8'd255 : ((centreLine || leftSeg || rightSeg) ? 8'd127 : 0 )));
	
	assign spriteID = (overBall) ? 1 : ((overLeftPaddle) ? 1 : ((overRightPaddle) ? 1 : ((centreLine || leftSeg || rightSeg) ? 1 : 0 )));
	
	reg [3:0] prevLS, prevRS;
 	reg [9:0] prevBall_x, prevBall_y, prevLeftPaddle_y, prevRightPaddle_y;
	initial begin
		prevLS = 0;
		prevRS = 0;	
		prevBall_x = 0;
		prevBall_y = 0;
		prevLeftPaddle_y = 0;
		prevRightPaddle_y = 0;
	end
	always@ (posedge clock) begin
		prevLS = LS;
		prevRS = RS;
		prevBall_x = ball_x;
		prevBall_y = ball_y;
		prevLeftPaddle_y = leftPaddle_y;
		prevRightPaddle_y = rightPaddle_y;
	end
	
	wire prevOverBall, prevOverLeftPaddle, prevOverRightPaddle, prevCentreLine;
	assign prevOverBall = (x >= prevBall_x && x <= prevBall_x + 4) && (y >= prevBall_y && y <= prevBall_y + 4);
	assign prevOverLeftPaddle = (x >= 16 && x <= 16 + 8) && (y >= prevLeftPaddle_y && y <= prevLeftPaddle_y + 32);
	assign prevOverRightPaddle = (x >= 800-16-8 && x <= 800-16-8 + 8) && (y >= prevRightPaddle_y && y <= prevRightPaddle_y + 32);
	assign prevCentreLine = (x >= 398 && x <= 402);
	wire [8:0] prevLeftSeg;
	overlap(prevLeftSeg[0], (prevLS!=1 && prevLS!=4 && prevLS!=11 && prevLS!=14), 								x, y, 400-64, 						400-64+scoreSize, 				64, 						64+scoreWidth				);
	overlap(prevLeftSeg[1], (prevLS!=5 && prevLS!=6 && prevLS!=15), 										x, y, 400-64+scoreSize-scoreWidth, 	400-64+scoreSize, 				64, 						64+scoreSize				);
	overlap(prevLeftSeg[2], (prevLS!=2 && prevLS!=12), 													x, y, 400-64+scoreSize-scoreWidth, 	400-64+scoreSize, 				64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(prevLeftSeg[3], (prevLS!=1 && prevLS!=4 && prevLS!=7 && prevLS!=11 && prevLS!=14), 						x, y, 400-64, 						400-64+scoreSize, 				64+scoreSize*2-scoreWidth*2,64+scoreSize*2-scoreWidth	);
	overlap(prevLeftSeg[4], (prevLS==0 || prevLS==2 || prevLS==6 || prevLS==8 || prevLS==10 || prevLS==12), 			x, y, 400-64, 						400-64+scoreWidth, 				64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(prevLeftSeg[5], (prevLS!=1 && prevLS!=2 && prevLS!=3 && prevLS!=7 && prevLS!=11 && prevLS!=12 && prevLS!=13), 	x, y, 400-64, 						400-64+scoreWidth, 				64, 						64+scoreSize				);
	overlap(prevLeftSeg[6], (prevLS!=0 && prevLS!=1 && prevLS!=7 && prevLS!=10 && prevLS!=11), 						x, y, 400-64, 						400-64+scoreSize, 				64+scoreSize-scoreWidth, 	64+scoreSize				);
	overlap(prevLeftSeg[7], (prevLS>=10), 															x, y, 400-64-scoreWidth*3,			400-64-scoreWidth*2, 			64, 						64+scoreSize				);
	overlap(prevLeftSeg[8], (prevLS>=10), 															x, y, 400-64-scoreWidth*3,			400-64-scoreWidth*2, 			64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	wire [8:0] prevRightSeg;
	overlap(prevRightSeg[0], (prevRS!=1 && prevRS!=4 && prevRS!=11 && prevRS!=14), 								x, y, 400+64-scoreSize 	+ ((prevRS>=10)? scoreWidth*2 : 0),	400+64						+ ((prevRS>=10)? scoreWidth*2 : 0),	64, 						64+scoreWidth				);
	overlap(prevRightSeg[1], (prevRS!=5 && prevRS!=6 && prevRS!=15), 										x, y, 400+64-scoreWidth + ((prevRS>=10)? scoreWidth*2 : 0),	400+64						+ ((prevRS>=10)? scoreWidth*2 : 0),	64, 						64+scoreSize				);
	overlap(prevRightSeg[2], (prevRS!=2 && prevRS!=12), 												x, y, 400+64-scoreWidth + ((prevRS>=10)? scoreWidth*2 : 0),	400+64						+ ((prevRS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(prevRightSeg[3], (prevRS!=1 && prevRS!=4 && prevRS!=7 && prevRS!=11 && prevRS!=14), 					x, y, 400+64-scoreSize 	+ ((prevRS>=10)? scoreWidth*2 : 0),	400+64						+ ((prevRS>=10)? scoreWidth*2 : 0),	64+scoreSize*2-scoreWidth*2,64+scoreSize*2-scoreWidth	);
	overlap(prevRightSeg[4], (prevRS==0 || prevRS==2 || prevRS==6 || prevRS==8 || prevRS==10 || prevRS==12), 			x, y, 400+64-scoreSize 	+ ((prevRS>=10)? scoreWidth*2 : 0),	400+64-scoreSize+scoreWidth	+ ((prevRS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	overlap(prevRightSeg[5], (prevRS!=1 && prevRS!=2 && prevRS!=3 && prevRS!=7 && prevRS!=11 && prevRS!=12 && prevRS!=13), 	x, y, 400+64-scoreSize 	+ ((prevRS>=10)? scoreWidth*2 : 0),	400+64-scoreSize+scoreWidth	+ ((prevRS>=10)? scoreWidth*2 : 0),	64, 						64+scoreSize				);
	overlap(prevRightSeg[6], (prevRS!=0 && prevRS!=1 && prevRS!=7 && prevRS!=10 && prevRS!=11), 					x, y, 400+64-scoreSize 	+ ((prevRS>=10)? scoreWidth*2 : 0),	400+64						+ ((prevRS>=10)? scoreWidth*2 : 0),	64+scoreSize-scoreWidth, 	64+scoreSize				);
	overlap(prevRightSeg[7], (prevRS>=10), 															x, y, 400+64-scoreSize, 				400+64-scoreSize+scoreWidth,			64, 						64+scoreSize				);
	overlap(prevRightSeg[8], (prevRS>=10), 															x, y, 400+64-scoreSize, 				400+64-scoreSize+scoreWidth,			64+scoreSize-scoreWidth, 	64+scoreSize*2-scoreWidth	);
	
	//assign updatePixel = overBall || overLeftPaddle || overRightPaddle || centreLine || leftSeg || rightSeg || prevOverBall || prevOverLeftPaddle || prevOverRightPaddle || prevCentreLine || prevLeftSeg || prevRightSeg;
	assign updatePixel = 1;
	wire [4:0] r = R/8;
	wire [4:0] g = G/8;
	wire [4:0] b = B/8;
	//assign pong_cRGB = {(overBall || overLeftPaddle || overRightPaddle || centreLine || leftSeg || rightSeg), r, g, b};
	//assign pong_cRGB = 16'd65535; // force to high at all times
	assign pong_cRGB = 16'b1111111111111111; // force to high at all times
endmodule