module DinoGame(input clock_60Hz, clock_40MHz, reset, enable, escape, jump, start, input [10:0] scanX, scanY, output [7:0] oR, oG, oB, output [31:0] spriteID, output updatePixel, output [15:0] dino_cRGB, output [31:0] score);
	wire [10:0] player_y;
	// wire [31:0] score;
	wire [2*4-1:0] cactus_h;
	wire [10*4-1:0] cactus_x;
	wire [10*4-1:0] bird_x, bird_y;
	wire [1:0] animation_cycle;
	
	DinoController dinoController(.clock(clock_60Hz), .reset(reset), .enable(enable), .escape(escape), .start(start), .jump(jump), .y_pos(player_y), .score(score), .cactus_h(cactus_h), .cactus_x(cactus_x), .bird_x(bird_x), .bird_y(bird_y), .animation_cycle(animation_cycle));
	DinoVideo dinoVideo(.clock(clock_60Hz), .scanClk(clock_40MHz), .animation_cycle(animation_cycle), .x(scanX), .y(scanY), .player_y(player_y), .score(score), .cactus_h(cactus_h), .cactus_x(cactus_x), .bird_x(bird_x), .bird_y(bird_y), .R(oR), .G(oG), .B(oB), .spriteID(spriteID), .updatePixel(updatePixel), .dino_cRGB(dino_cRGB));
endmodule