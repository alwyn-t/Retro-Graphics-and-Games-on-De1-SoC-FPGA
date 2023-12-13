module PS2(Clock_50, PS2_CLK, PS2_DAT, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, w_flag, a_flag, s_flag, d_flag, up_flag, left_flag, down_flag, right_flag, space_flag, enter_flag, escape_flag);
	input Clock_50, PS2_CLK, PS2_DAT;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [9:2] LEDR;
	wire [7:0] KEY_VAL1, KEY_VAL2, KEY_VAL3;
	wire newKey;
	output reg w_flag, a_flag, s_flag, d_flag;
	output reg up_flag, left_flag, down_flag, right_flag;
	output reg space_flag, enter_flag, escape_flag;
	
	initial begin
		w_flag <= 0;
		a_flag <= 0;
		s_flag <= 0;
		d_flag <= 0;
		up_flag <= 0;
		left_flag <= 0;
		down_flag <= 0;
		right_flag <= 0;
		space_flag <= 0;
		enter_flag <= 0;
		escape_flag <= 0;
	end

	always@(posedge newKey) begin
		if (KEY_VAL1 == 8'h1D)
			w_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h1C)
			a_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h1B)
			s_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h23)
			d_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h29)
			space_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h5A)
			enter_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h76)
			escape_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h75 && (KEY_VAL3 == 8'hE0 || KEY_VAL2 == 8'hE0))
			up_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h6B && (KEY_VAL3 == 8'hE0 || KEY_VAL2 == 8'hE0))
			left_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h72 && (KEY_VAL3 == 8'hE0 || KEY_VAL2 == 8'hE0))
			down_flag <= KEY_VAL2 != 8'hF0;
		else if (KEY_VAL1 == 8'h74 && (KEY_VAL3 == 8'hE0 || KEY_VAL2 == 8'hE0))
			right_flag <= KEY_VAL2 != 8'hF0;
	end
	
	assign LEDR[9] = w_flag;
	assign LEDR[8] = a_flag;
	assign LEDR[7] = s_flag;
	assign LEDR[6] = d_flag;
	assign LEDR[5] = up_flag;
	assign LEDR[4] = left_flag;
	assign LEDR[3] = down_flag;
	assign LEDR[2] = right_flag;
	
	hex_decoder m1 (.in(KEY_VAL1[3:0]), .hex(HEX0));
	hex_decoder m2 (.in(KEY_VAL1[7:4]), .hex(HEX1));
	hex_decoder m3 (.in(KEY_VAL2[3:0]), .hex(HEX2));
	hex_decoder m4 (.in(KEY_VAL2[7:4]), .hex(HEX3));
	hex_decoder m5 (.in(KEY_VAL3[3:0]), .hex(HEX4));
	hex_decoder m6 (.in(KEY_VAL3[7:4]), .hex(HEX5));
	
	PS2_Input ps2in (.PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .KEY_VAL1(KEY_VAL1), .KEY_VAL2(KEY_VAL2), .KEY_VAL3(KEY_VAL3), .newKey(newKey));
endmodule

module PS2_Input(PS2_CLK, PS2_DAT, KEY_VAL1, KEY_VAL2, KEY_VAL3, newKey); // added newKey flag
	input PS2_CLK, PS2_DAT;
	output reg [7:0] KEY_VAL1, KEY_VAL2, KEY_VAL3;
	output reg newKey;
	reg [7:0] counter;
	reg [7:0] shiftReg;
	reg parityFlag;
	
	initial begin
		counter <= 8'd10;
		shiftReg <= 8'd0;
		parityFlag <= 0;
		KEY_VAL1 <= 8'd0;
		KEY_VAL2 <= 8'd0;
		KEY_VAL3 <= 8'd0;
		newKey <= 0;
	end
	
	always@(negedge PS2_CLK) begin // counter is from 0->10, 11 indices (1 starting bit, 8 data bits, 1 parity, 1 end bit)
		newKey <= 0;
		if (counter < 10) begin // skips over start bit with counter at 11 and trigger found below
			if (counter < 8) begin // store 1 byte of data representing the key press
				shiftReg[counter] <= PS2_DAT;
			end
			if (counter == 8) begin
				if (shiftReg%2 == PS2_DAT)
					parityFlag <= 1;
				else begin
					parityFlag <= 0;
				end
				KEY_VAL1 <= shiftReg;// flipped order to hopefully cause the movement of values to be in the correct order
				KEY_VAL2 <= KEY_VAL1;
				KEY_VAL3 <= KEY_VAL2;
			end
			if (counter == 9 && PS2_DAT) begin // check if stop code is high // added parity flag
				shiftReg <= 0;
				newKey <= 1;
			end
			counter <= counter + 1;
		end
		else if (!PS2_DAT) counter <= 0;
	end
endmodule