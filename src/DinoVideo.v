module DinoVideo(input clock, scanClk, input [1:0] animation_cycle, input [10:0] x, y, input [10:0] player_y, input [31:0] score, input [2*4-1:0] cactus_h, input [10*4-1:0] cactus_x, input [10*4-1:0] bird_x, bird_y, output [7:0] R, G, B, output [31:0] spriteID, output updatePixel, output [15:0] dino_cRGB);
	wire overPlayer;
	wire [3:0] overCactus, overBird;
	localparam ground = 480;
	localparam x_pos = 64;
	localparam player_width = 32;
	localparam player_height = 32;
	localparam cactus_width = 32;
	localparam n_cactus_y = {10'd32,10'd24,10'd16,10'd8};
	localparam bird_width = 32;
	localparam bird_height = 32;
	
	assign overPlayer = (x >= x_pos && x < x_pos + player_width) && (y >= player_y - player_height && y < player_y);
	assign overCactus[0] = ((((cactus_x[0*10 +: 10] < cactus_width) && x >= 0 || x >= cactus_x[0*10 +: 10] - cactus_width) && x < cactus_x[0*10 +: 10]) && (y >= ground - n_cactus_y[(cactus_h[0*2 +: 2])*10 +: 10] && y < ground));
	assign overCactus[1] = ((((cactus_x[1*10 +: 10] < cactus_width) && x >= 0 || x >= cactus_x[1*10 +: 10] - cactus_width) && x < cactus_x[1*10 +: 10]) && (y >= ground - n_cactus_y[(cactus_h[1*2 +: 2])*10 +: 10] && y < ground));
	assign overCactus[2] = ((((cactus_x[2*10 +: 10] < cactus_width) && x >= 0 || x >= cactus_x[2*10 +: 10] - cactus_width) && x < cactus_x[2*10 +: 10]) && (y >= ground - n_cactus_y[(cactus_h[2*2 +: 2])*10 +: 10] && y < ground));
	assign overCactus[3] = ((((cactus_x[3*10 +: 10] < cactus_width) && x >= 0 || x >= cactus_x[3*10 +: 10] - cactus_width) && x < cactus_x[3*10 +: 10]) && (y >= ground - n_cactus_y[(cactus_h[3*2 +: 2])*10 +: 10] && y < ground));
	assign overBird[0] = (((bird_x[0*10 +: 10] < bird_width) && x >= 0 || x >= bird_x[0*10 +: 10] - bird_width) && x < bird_x[0*10 +: 10]) && (y >= bird_y[0*10 +: 10] - bird_height && y < bird_y[0*10 +: 10]);
	assign overBird[1] = (((bird_x[1*10 +: 10] < bird_width) && x >= 0 || x >= bird_x[1*10 +: 10] - bird_width) && x < bird_x[1*10 +: 10]) && (y >= bird_y[1*10 +: 10] - bird_height && y < bird_y[1*10 +: 10]);
	assign overBird[2] = (((bird_x[2*10 +: 10] < bird_width) && x >= 0 || x >= bird_x[2*10 +: 10] - bird_width) && x < bird_x[2*10 +: 10]) && (y >= bird_y[2*10 +: 10] - bird_height && y < bird_y[2*10 +: 10]);
	assign overBird[3] = (((bird_x[3*10 +: 10] < bird_width) && x >= 0 || x >= bird_x[3*10 +: 10] - bird_width) && x < bird_x[3*10 +: 10]) && (y >= bird_y[3*10 +: 10] - bird_height && y < bird_y[3*10 +: 10]);
	
	// player, bird, cactus
	//assign R = (overPlayer) ? 8'd255 : ((overBird) ? 8'd235 : ((overCactus) ? 8'd007 : 0));
	//assign G = (overPlayer) ? 8'd255 : ((overBird) ? 8'd168 : ((overCactus) ? 8'd117 : 0));
	//assign B = (overPlayer) ? 8'd255 : ((overBird) ? 8'd052 : ((overCactus) ? 8'd022 : 0));
	
	reg [7:0] prevPlayerY;
	reg [31:0] prevScore;
	reg [2*4-1:0] prevCactus_h;
	reg [10*4-1:0] prevCactus_x;
	reg [10*4-1:0] prevBird_x, prevBird_y;
	initial begin
		prevPlayerY = 0;
		prevScore = 0;
		prevCactus_h = 0;
		prevCactus_x = 0;
		prevBird_x = 0;
		prevBird_y = 0;
	end
	
	always@ (posedge clock) begin
		prevPlayerY = player_y;
		prevScore = score;
		prevCactus_h = cactus_h;
		prevCactus_x = cactus_x;
		prevBird_x = bird_x;
		prevBird_y = bird_y;
	end
	
	wire prevOverPlayer;
	wire [3:0] prevOverCactus, prevOverBird;
	
	assign prevOverPlayer = (x >= x_pos && x < x_pos + player_width) && (y >= prevPlayerY && y < prevPlayerY + player_height);
	assign prevOverCactus[0] = ((((prevCactus_x[0*10 +: 10] < cactus_width) && x >= 0 || x >= prevCactus_x[0*10 +: 10] - cactus_width) && x < cactus_x[0*10 +: 10]) && (y >= ground - n_cactus_y[(prevCactus_h[0*2 +: 2])*10 +: 10] && y < ground));
	assign prevOverCactus[1] = ((((prevCactus_x[1*10 +: 10] < cactus_width) && x >= 0 || x >= prevCactus_x[1*10 +: 10] - cactus_width) && x < cactus_x[1*10 +: 10]) && (y >= ground - n_cactus_y[(prevCactus_h[1*2 +: 2])*10 +: 10] && y < ground));
	assign prevOverCactus[2] = ((((prevCactus_x[2*10 +: 10] < cactus_width) && x >= 0 || x >= prevCactus_x[2*10 +: 10] - cactus_width) && x < cactus_x[2*10 +: 10]) && (y >= ground - n_cactus_y[(prevCactus_h[2*2 +: 2])*10 +: 10] && y < ground));
	assign prevOverCactus[3] = ((((prevCactus_x[3*10 +: 10] < cactus_width) && x >= 0 || x >= prevCactus_x[3*10 +: 10] - cactus_width) && x < cactus_x[3*10 +: 10]) && (y >= ground - n_cactus_y[(prevCactus_h[3*2 +: 2])*10 +: 10] && y < ground));
	assign prevOverBird[0] = (((prevBird_x[0*10 +: 10] < bird_width) && x >= 0 || x >= prevBird_x[0*10 +: 10] - bird_width) && x < bird_x[0*10 +: 10]) && (y >= prevBird_y[0*10 +: 10] - bird_height && y < prevBird_y[0*10 +: 10]);
	assign prevOverBird[1] = (((prevBird_x[1*10 +: 10] < bird_width) && x >= 0 || x >= prevBird_x[1*10 +: 10] - bird_width) && x < bird_x[1*10 +: 10]) && (y >= prevBird_y[1*10 +: 10] - bird_height && y < prevBird_y[1*10 +: 10]);
	assign prevOverBird[2] = (((prevBird_x[2*10 +: 10] < bird_width) && x >= 0 || x >= prevBird_x[2*10 +: 10] - bird_width) && x < bird_x[2*10 +: 10]) && (y >= prevBird_y[2*10 +: 10] - bird_height && y < prevBird_y[2*10 +: 10]);
	assign prevOverBird[3] = (((prevBird_x[3*10 +: 10] < bird_width) && x >= 0 || x >= prevBird_x[3*10 +: 10] - bird_width) && x < bird_x[3*10 +: 10]) && (y >= prevBird_y[3*10 +: 10] - bird_height && y < prevBird_y[3*10 +: 10]);
	
	assign updatePixel = overPlayer || overCactus || overBird || prevOverPlayer || prevOverCactus || prevOverBird;
	wire [4:0] r = R/8;
	wire [4:0] g = G/8;
	wire [4:0] b = B/8;
	//assign dino_cRGB = {(overPlayer || overCactus || overBird || prevOverPlayer || prevOverCactus || prevOverBird), r, g, b};
	//assign dino_cRGB = 16'd65535; // force to high at all times
	assign dino_cRGB = 16'b1111111111111111; // force to high at all times

	wire [13:0] dinoSpriteAddr = animation_cycle*32 + x-x_pos + (y-player_y+player_height)*512;
	wire [13:0] cactusSpriteAddr0 = 128 + cactus_h[0*2 +: 2]*32 + x-cactus_x[0*10 +: 10]+cactus_width + (y+32-ground)*512;
	wire [13:0] cactusSpriteAddr1 = 128 + cactus_h[1*2 +: 2]*32 + x-cactus_x[1*10 +: 10]+cactus_width + (y+32-ground)*512;
	wire [13:0] cactusSpriteAddr2 = 128 + cactus_h[2*2 +: 2]*32 + x-cactus_x[2*10 +: 10]+cactus_width + (y+32-ground)*512;
	wire [13:0] cactusSpriteAddr3 = 128 + cactus_h[3*2 +: 2]*32 + x-cactus_x[3*10 +: 10]+cactus_width + (y+32-ground)*512;
	wire [13:0] cactusSpriteAddr = overCactus[0] ? cactusSpriteAddr0 : (overCactus[1] ? cactusSpriteAddr1 : (overCactus[2] ? cactusSpriteAddr2 : (overCactus[3] ? cactusSpriteAddr3 : 0)));
	wire [13:0] birdSpriteAddr0 = 256 + (animation_cycle+0 > 3 ? animation_cycle+0-4 : animation_cycle+0)*32 + x-bird_x[0*10 +: 10]+bird_width + (y-bird_y[0*10 +: 10]+bird_height)*512;
	wire [13:0] birdSpriteAddr1 = 256 + (animation_cycle+1 > 3 ? animation_cycle+1-4 : animation_cycle+1)*32 + x-bird_x[1*10 +: 10]+bird_width + (y-bird_y[1*10 +: 10]+bird_height)*512;
	wire [13:0] birdSpriteAddr2 = 256 + (animation_cycle+2 > 3 ? animation_cycle+2-4 : animation_cycle+2)*32 + x-bird_x[2*10 +: 10]+bird_width + (y-bird_y[2*10 +: 10]+bird_height)*512;
	wire [13:0] birdSpriteAddr3 = 256 + (animation_cycle+3 > 3 ? animation_cycle+3-4 : animation_cycle+3)*32 + x-bird_x[3*10 +: 10]+bird_width + (y-bird_y[3*10 +: 10]+bird_height)*512;
	wire [13:0] birdSpriteAddr = overBird[0] ? birdSpriteAddr0 : (overBird[1] ? birdSpriteAddr1 : (overBird[2] ? birdSpriteAddr2 : (overBird[3] ? birdSpriteAddr3 : 0)));
	wire [15:0] q_a, q_b;
	wire [13:0] address_a = (overPlayer) ? dinoSpriteAddr : (overCactus ? cactusSpriteAddr : (overBird ? birdSpriteAddr : 0));
	wire [13:0] address_b = (overPlayer && overCactus) ? cactusSpriteAddr : (overBird ? birdSpriteAddr : 0);
	DinoRom2Port dinoRom(.address_a(address_a), .address_b(address_b), .clock(scanClk), .q_a(q_a), .q_b(q_b));
	wire drawA = q_a[15];
	wire drawB = q_b[15];
	wire [3:0] digit0 = score % 10;
	wire [3:0] digit1 = (score / 10) % 10;
	wire [3:0] digit2 = (score / 100) % 10;
	wire [3:0] digit3 = (score / 1000) % 10;
	wire [3:0] digit4 = (score / 10000) % 10;
	wire [3:0] digit5 = (score / 100000) % 10;
	wire [3:0] digit6 = (score / 1000000) % 10;
	wire [3:0] digit7 = (score / 10000000) % 10;
	wire [3:0] digit8 = (score / 100000000) % 10;
	wire [3:0] digit9 = (score / 1000000000) % 10;
	wire overDigit0 = x >= 800-32-((0+1)*24) && x < 800-32-(0*24) && y >= 32 && y < 32+32;
	wire overDigit1 = x >= 800-32-((1+1)*24) && x < 800-32-(1*24) && y >= 32 && y < 32+32;
	wire overDigit2 = x >= 800-32-((2+1)*24) && x < 800-32-(2*24) && y >= 32 && y < 32+32;
	wire overDigit3 = x >= 800-32-((3+1)*24) && x < 800-32-(3*24) && y >= 32 && y < 32+32;
	wire overDigit4 = x >= 800-32-((4+1)*24) && x < 800-32-(4*24) && y >= 32 && y < 32+32;
	wire overDigit5 = x >= 800-32-((5+1)*24) && x < 800-32-(5*24) && y >= 32 && y < 32+32;
	wire overDigit6 = x >= 800-32-((6+1)*24) && x < 800-32-(6*24) && y >= 32 && y < 32+32;
	wire overDigit7 = x >= 800-32-((7+1)*24) && x < 800-32-(7*24) && y >= 32 && y < 32+32;
	wire overDigit8 = x >= 800-32-((8+1)*24) && x < 800-32-(8*24) && y >= 32 && y < 32+32;
	wire overDigit9 = x >= 800-32-((9+1)*24) && x < 800-32-(9*24) && y >= 32 && y < 32+32;
	wire [13:0] digit0Addr = digit0*32 + (x - 800+32+((0+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit1Addr = digit1*32 + (x - 800+32+((1+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit2Addr = digit2*32 + (x - 800+32+((2+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit3Addr = digit3*32 + (x - 800+32+((3+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit4Addr = digit4*32 + (x - 800+32+((4+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit5Addr = digit5*32 + (x - 800+32+((5+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit6Addr = digit6*32 + (x - 800+32+((6+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit7Addr = digit7*32 + (x - 800+32+((7+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit8Addr = digit8*32 + (x - 800+32+((8+1)*24) + 4) + (y - 32)*512;
	wire [13:0] digit9Addr = digit9*32 + (x - 800+32+((9+1)*24) + 4) + (y - 32)*512;
	wire [13:0] numberAddr = overDigit9 ? digit9Addr : (overDigit8 ? digit8Addr : (overDigit7 ? digit7Addr : (overDigit6 ? digit6Addr : (overDigit5 ? digit5Addr : (overDigit4 ? digit4Addr : (overDigit3 ? digit3Addr : (overDigit2 ? digit2Addr : (overDigit1 ? digit1Addr : (overDigit0 ? digit0Addr : (0))))))))));
	wire [15:0] numberQ;
	wire drawQ = numberQ[15];
	DinoNumberROM2Port dinoNumberROM2Port(.address_a(numberAddr), .address_b(), .clock(scanClk), .q_a(numberQ), .q_b());
	assign R = drawA ? q_a[14:10] << 3 : (drawB ? q_b[14:10] << 3 : ((y >= ground) ? 8'd217 : (drawQ ? numberQ[14:10] << 3 : 8'd255)));
	assign G = drawA ? q_a[ 9: 5] << 3 : (drawB ? q_b[ 9: 5] << 3 : ((y >= ground) ? 8'd160 : (drawQ ? numberQ[ 9: 5] << 3 : 8'd255)));
	assign B = drawA ? q_a[ 4: 0] << 3 : (drawB ? q_b[ 4: 0] << 3 : ((y >= ground) ? 8'd102 : (drawQ ? numberQ[ 4: 0] << 3 : 8'd255)));
endmodule