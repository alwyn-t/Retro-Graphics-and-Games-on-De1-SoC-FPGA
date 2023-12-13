//module DinoController(input clock, jump, output [7:0] y_pos, output [3:0] score, output [1:0] cactus0_h, cactus1_h, cactus2_h, cactus3_h, output [9:0] cactus0_x, cactus1_x, cactus2_x, cactus3_x, output [9:0] bird0_x, bird0_y, bird1_x, bird1_y, bird2_x, bird2_y, bird3_x, bird3_y); // y_pos represents the bottom of the character // for cactus and bird, the positions are based on bottom right points to have offscreen display
module DinoController(input clock, reset, enable, escape, start, jump, output reg [10:0] y_pos, output reg [31:0] score, output reg [2*4-1:0] cactus_h, output reg [10*4-1:0] cactus_x, output reg [10*4-1:0] bird_x, bird_y, output reg [1:0] animation_cycle); // y_pos represents the bottom of the character // for cactus and bird, the positions are based on bottom right points to have offscreen display
	//localparam gravity = 5;
	localparam gravity = 8'd3;
	//localparam max_velocity = 8'd148; // 10 + 128
	localparam max_velocity = 8'd168; // 10 + 128
	reg [7:0] jump_velocity; // speed range: [127 : -128]
	localparam initial_jump_velocity = 8'd88; // -20 + 128
	wire [7:0] normal_fall_velocity = (jump_velocity + 4 < max_velocity) ? jump_velocity + 4 : max_velocity;
	wire [7:0] slow_fall_velocity = (jump_velocity + 1 < max_velocity) ? jump_velocity + 1 : max_velocity;
	localparam stop_velocity = 8'd128; // 0 + 128
	localparam ground = 480;
	
	wire [10:0] n_y_pos;
	// assign n_y_pos = (y_pos + (jump_velocity/2 - 64) <= ground) ? (y_pos + (jump_velocity/2 - 64)) : ground;
	assign n_y_pos = (y_pos + (jump_velocity/4 - 32) <= ground) ? (y_pos + (jump_velocity/4 - 32)) : ground;
	wire onGround;
	assign onGround = (n_y_pos == ground);
	wire nearGround;
	assign nearGround = (n_y_pos >= (ground - 1));
	reg [7:0] jump_counter;
	reg [7:0] player_vx;
	initial player_vx <= 0;
	localparam x_pos = 64;
	localparam player_width = 32;
	localparam player_height = 32;
	
	localparam cactus_width = 32;
	localparam n_cactus_y = {10'd32,10'd24,10'd16,10'd8};
	localparam bird_width = 32;
	localparam bird_height = 32;
	localparam cactus_vx = 1;
	localparam bird_vx = 2;
	wire [10*4-1:0] n_cactus_x;
	wire [10*4-1:0] n_bird_x;
	integer i;
	assign n_cactus_x[10*0 +: 10] = (cactus_x[10*0 +: 10] - cactus_vx - player_vx > cactus_x[10*0 +: 10]) ? 10'd1023 : cactus_x[10*0 +: 10] - cactus_vx - player_vx;
	assign n_cactus_x[10*1 +: 10] = (cactus_x[10*1 +: 10] - cactus_vx - player_vx > cactus_x[10*1 +: 10]) ? 10'd1023 : cactus_x[10*1 +: 10] - cactus_vx - player_vx;
	assign n_cactus_x[10*2 +: 10] = (cactus_x[10*2 +: 10] - cactus_vx - player_vx > cactus_x[10*2 +: 10]) ? 10'd1023 : cactus_x[10*2 +: 10] - cactus_vx - player_vx;
	assign n_cactus_x[10*3 +: 10] = (cactus_x[10*3 +: 10] - cactus_vx - player_vx > cactus_x[10*3 +: 10]) ? 10'd1023 : cactus_x[10*3 +: 10] - cactus_vx - player_vx;
	assign n_bird_x[10*0 +: 10] = (bird_x[10*0 +: 10] - bird_vx - player_vx > cactus_x[10*0 +: 10]) ? 10'd1023 : bird_x[10*0 +: 10] - bird_vx - player_vx;
	assign n_bird_x[10*1 +: 10] = (bird_x[10*1 +: 10] - bird_vx - player_vx > cactus_x[10*1 +: 10]) ? 10'd1023 : bird_x[10*1 +: 10] - bird_vx - player_vx;
	assign n_bird_x[10*2 +: 10] = (bird_x[10*2 +: 10] - bird_vx - player_vx > cactus_x[10*2 +: 10]) ? 10'd1023 : bird_x[10*2 +: 10] - bird_vx - player_vx;
	assign n_bird_x[10*3 +: 10] = (bird_x[10*3 +: 10] - bird_vx - player_vx > cactus_x[10*3 +: 10]) ? 10'd1023 : bird_x[10*3 +: 10] - bird_vx - player_vx;
	// assign n_cactus_x = cactus_x - {cactus_vx, cactus_vx, cactus_vx, cactus_vx} - {player_vx, player_vx, player_vx, player_vx};
	// assign n_bird_x = bird_x - {bird_vx, bird_vx, bird_vx, bird_vx} - {player_vx, player_vx, player_vx, player_vx};
	
	// max speed
	localparam maxSpeed = 10;
	
	// player speed increase timer
	reg [6:0] playerSpeedTimer;
	
	// bird and cactus cooldown
	reg [15:0] cactus_cooldown;
	reg [15:0] bird_cooldown;
	
	// randomizer (127-0)
	wire [6:0] randomVal;
	Randomizer randomizer (.clock(clock), .value(randomVal));
	
	// cycle index
	reg [3:0] cycleIndex;
	initial cycleIndex = 0;

	// jump register
	reg [15:0] jump_register;
	initial jump_register = 0;
	wire player_jump = jump || jump_register!=0;

	// animation cooldown
	reg [5:0] animationCooldown = 0; 
	
	reg [2:0] currentState, nextState;
	localparam 	START_MENU 	= 3'd0,
				GAME		= 3'd1,
				END_CHECK	= 3'd2,
				PAUSE_MENU	= 3'd3,
				END_MENU	= 3'd4;
	initial begin
		currentState	<= START_MENU;
		nextState		<= START_MENU;
	end

	always@(posedge clock) begin
		if (reset) begin
			currentState	<= START_MENU;
			nextState		<= START_MENU;
		end
		case (currentState)
			START_MENU: nextState <= (start) ? GAME : START_MENU;
			GAME: nextState <= (escape) ? PAUSE_MENU : GAME;
			END_CHECK: nextState <= (!start) ? END_MENU : END_CHECK;
			PAUSE_MENU: nextState <= (start) ? GAME : PAUSE_MENU;
			END_MENU: nextState <= (start) ? START_MENU : END_MENU;
		endcase
		currentState <= nextState;
		if (reset || currentState == START_MENU) begin
			player_vx <= 1;
			y_pos <= ground;
			jump_velocity <= stop_velocity;
			score <= 0;
			cactus_h <= 0;
			cactus_x <= {4{10'd1023}};
			bird_x <= {4{10'd1023}};
			bird_y <= {4{10'd200}};
			cactus_cooldown <= 8;
			bird_cooldown <= 0;
			playerSpeedTimer <= 0;
			cycleIndex <= 0;
			jump_register <= 0;
			animation_cycle <= 0;
		end
		else if (!reset && enable && currentState == GAME) begin
			// velocity calculations
			jump_velocity <= (onGround) ? (player_jump ? initial_jump_velocity : (onGround ? stop_velocity : slow_fall_velocity)) : (jump_counter ? slow_fall_velocity : normal_fall_velocity);
			// jump counter
			jump_counter <= (onGround && player_jump) ? 10 : ((jump_counter && player_jump) ? jump_counter-1 : 0);
			// y_pos
			y_pos <= n_y_pos;
			//jump register
			jump_register <= jump_register << jump;
			
			// hit detection
			for (i = 0; i<4; i=i+1) begin
			// no need to check lower bound as the cactus is always on the ground
				if (x_pos <=  n_cactus_x[i*10 +: 10]-12 && x_pos + player_width > n_cactus_x[i*10 +: 10] - cactus_width+12 && n_y_pos > ground - n_cactus_y[(cactus_h[i*2 +: 2])*10 +: 10]) begin
					currentState <= END_CHECK;
					nextState <= END_CHECK;
				end
				if (x_pos <=  n_bird_x[i*10 +: 10] && x_pos + player_width > n_bird_x[i*10 +: 10] - bird_width && n_y_pos - player_height <= bird_y[i*10 +: 10]-12 && n_y_pos > bird_y[i*10 +: 10] - bird_height+12) begin // hit bird
					currentState <= END_CHECK;
					nextState <= END_CHECK;
				end
			end
			score <= score + player_vx;
			
			// update entities
			for (i = 0; i<4; i=i+1) begin
				cactus_x[i*10 +: 10] <= (cactus_x[i*10 +: 10] != 1023) ? n_cactus_x[i*10 +: 10] : cactus_x[i*10 +: 10];
				bird_x[i*10 +: 10] <= (bird_x[i*10 +: 10] != 1023) ? n_bird_x[i*10 +: 10] : bird_x[i*10 +: 10];
			end
			
			// cycling obstacles
			cactus_cooldown <= ( cactus_cooldown - player_vx < cactus_cooldown ) ? cactus_cooldown - player_vx : 0;
			bird_cooldown <= ( bird_cooldown - player_vx < bird_cooldown ) ? bird_cooldown - player_vx : 0;
			if (cycleIndex[0]) begin
				if (cactus_x[(cycleIndex[2:1])*10 +: 10] == 1023 && !cactus_cooldown) begin
					cactus_cooldown <= 320 + randomVal/4;
					cactus_x[(cycleIndex[2:1])*10 +: 10] <= 800 + cactus_width + randomVal;
					cactus_h[(cycleIndex[2:1])*2 +: 2] <= randomVal[5:4];
				end
			end
			else if (bird_x[cycleIndex[2:1]*10 +: 10] == 1023 && !bird_cooldown) begin
				bird_cooldown <= 640 + randomVal/2;
				bird_x[cycleIndex[2:1]*10 +: 10] <= 800 + bird_width + randomVal;
				bird_y[cycleIndex[2:1]*10 +: 10] <= ground - 48 - (randomVal[6:4]*32);
				// bird_y[cycleIndex[2:1]*10 +: 10] <= randomVal[6] ? (ground - 48 + randomVal) : (ground - 48 -randomVal);
			end
			cycleIndex <= cycleIndex + 1;
			
			playerSpeedTimer <= (playerSpeedTimer) ? playerSpeedTimer - 1 : 120;
			player_vx <= (player_vx < maxSpeed) ? (!playerSpeedTimer ? player_vx + 1 : player_vx) : maxSpeed;
			
			animationCooldown <= (animationCooldown != 10) ? animationCooldown + 1 : 0;
			animation_cycle <= (!animationCooldown) ? animation_cycle + 1 : animation_cycle;
		end
	end
endmodule