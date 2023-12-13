module GameSelect(input clock_60Hz, reset, doneLoading, escape, up, down, left, right, enter, space, output load, output gameSelectEnable, pongEnable, dinoEnable, output [2:0] game, output reg [19:0] gameSelectTime);
	/*
	States
	HOVER_PONG -> LOAD_PONG -> INGAME_DINO
		|
	HOVER_DINO -> LOAD_PONG -> INGAME_DINO
	*/
	localparam  HOVER_PONG = 3'd0;
	localparam   LOAD_PONG = 3'd1;
	localparam INGAME_PONG = 3'd2;
	localparam  HOVER_DINO = 3'd3;
	localparam   LOAD_DINO = 3'd4;
	localparam INGAME_DINO = 3'd5;
	
	reg [3:0] currentState, nextState;
	
	initial currentState = INGAME_DINO;
	initial    nextState = INGAME_DINO;
	always@(posedge clock_60Hz) begin
		currentState <= nextState;
	end
	always@(*) begin
		case (currentState)
			 HOVER_PONG : nextState <= (space || enter) ? LOAD_PONG : ((down) ? HOVER_DINO : HOVER_PONG);
			  LOAD_PONG : nextState <= (doneLoading) ? INGAME_PONG : LOAD_PONG;
			INGAME_PONG : nextState <= (escape) ? HOVER_PONG : INGAME_PONG;
			 HOVER_DINO : nextState <= (space || enter) ? LOAD_DINO : ((up) ? HOVER_PONG : HOVER_DINO);
			  LOAD_DINO : nextState <= (doneLoading) ? INGAME_DINO : LOAD_DINO;
			INGAME_DINO : nextState <= (escape) ? HOVER_DINO : INGAME_DINO;
		endcase
	end
	
	assign load = currentState == LOAD_PONG || currentState == LOAD_DINO;
	assign game = currentState == HOVER_PONG ? 0 : (currentState == HOVER_DINO ? 1 : 2);
	assign gameSelectEnable = !(pongEnable || dinoEnable);
	assign pongEnable = (currentState == INGAME_PONG);
	assign dinoEnable = (currentState == INGAME_DINO);

	initial gameSelectTime = 0;
	reg [5:0] counter = 0;
	always@ (posedge clock_60Hz) begin
		counter <= (counter < 60) ? counter + 1 : 0;
		gameSelectTime <= (!counter) ? (gameSelectTime < 999999 ? gameSelectTime + 1 : 0) : gameSelectTime;
	end
endmodule