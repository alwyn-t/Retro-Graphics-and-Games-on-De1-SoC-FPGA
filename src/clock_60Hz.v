module clock_60Hz #(parameter CLOCK_FREQUENCY = 50000000) (input clock_in, output reg clock_60Hz);
	reg [$clog2(CLOCK_FREQUENCY)-1:0] counter;
	localparam flag0 = 0 * 833333;   // 0 * 833333.3
	localparam flag1 = 1 * 833333;   // 1 * 833333.3
	localparam flag2 = 2 * 833333;   // 2 * 833333.3
	localparam flag3 = 3 * 833333+1; // 3 * 833333.3
	localparam flag4 = 4 * 833333+1; // 4 * 833333.3
	localparam flag5 = 5 * 833333+1; // 5 * 833333.3
	localparam flag6 = 6 * 833333+2; // 6 * 833333.3
	localparam flag7 = 7 * 833333+2; // 7 * 833333.3
	localparam flag8 = 8 * 833333+2; // 8 * 833333.3
	localparam flag9 = 9 * 833333+3; // 9 * 833333.3
	localparam flag10= 10* 833333+3; // 10* 833333.3
	localparam flag11= 11* 833333+3; // 11* 833333.3
	localparam flag12= 12* 833333+4; // 12* 833333.3
	localparam flag13= 13* 833333+4; // 13* 833333.3
	localparam flag14= 14* 833333+4; // 14* 833333.3
	localparam flag15= 15* 833333+5; // 15* 833333.3
	localparam flag16= 16* 833333+5; // 16* 833333.3
	localparam flag17= 17* 833333+5; // 17* 833333.3
	localparam flag18= 18* 833333+6; // 18* 833333.3
	localparam flag19= 19* 833333+6; // 19* 833333.3
	localparam flag20= 20* 833333+6; // 20* 833333.3
	localparam flag21= 21* 833333+7; // 21* 833333.3
	localparam flag22= 22* 833333+7; // 22* 833333.3
	localparam flag23= 23* 833333+7; // 23* 833333.3
	localparam flag24= 24* 833333+8; // 24* 833333.3
	localparam flag25= 25* 833333+8; // 25* 833333.3
	localparam flag26= 26* 833333+8; // 26* 833333.3
	localparam flag27= 27* 833333+9; // 27* 833333.3
	localparam flag28= 28* 833333+9; // 28* 833333.3
	localparam flag29= 29* 833333+9; // 29* 833333.3
	localparam flag30= 30* 833333+10; // 30* 833333.3
	localparam flag31= 31* 833333+10; // 31* 833333.3
	localparam flag32= 32* 833333+10; // 32* 833333.3
	localparam flag33= 33* 833333+11; // 33* 833333.3
	localparam flag34= 34* 833333+11; // 34* 833333.3
	localparam flag35= 35* 833333+11; // 35* 833333.3
	localparam flag36= 36* 833333+12; // 36* 833333.3
	localparam flag37= 37* 833333+12; // 37* 833333.3
	localparam flag38= 38* 833333+12; // 38* 833333.3
	localparam flag39= 39* 833333+13; // 39* 833333.3
	localparam flag40= 40* 833333+13; // 40* 833333.3
	localparam flag41= 41* 833333+13; // 41* 833333.3
	localparam flag42= 42* 833333+14; // 42* 833333.3
	localparam flag43= 43* 833333+14; // 43* 833333.3
	localparam flag44= 44* 833333+14; // 44* 833333.3
	localparam flag45= 45* 833333+15; // 45* 833333.3
	localparam flag46= 46* 833333+15; // 46* 833333.3
	localparam flag47= 47* 833333+15; // 47* 833333.3
	localparam flag48= 48* 833333+16; // 48* 833333.3
	localparam flag49= 49* 833333+16; // 49* 833333.3
	localparam flag50= 50* 833333+16; // 20* 833333.3
	localparam flag51= 51* 833333+17; // 51* 833333.3
	localparam flag52= 52* 833333+17; // 52* 833333.3
	localparam flag53= 53* 833333+17; // 53* 833333.3
	localparam flag54= 54* 833333+18; // 54* 833333.3
	localparam flag55= 55* 833333+18; // 55* 833333.3
	localparam flag56= 56* 833333+18; // 56* 833333.3
	localparam flag57= 57* 833333+19; // 57* 833333.3
	localparam flag58= 58* 833333+19; // 58* 833333.3
	localparam flag59= 59* 833333+19; // 59* 833333.3 
	initial begin
		counter <= 0;
		clock_60Hz <= 0;
	end
	always@(posedge clock_in) begin
		counter <= counter + 1;
		clock_60Hz <= 0;
		// if (counter == flag0  ||
		// 	counter == flag1  ||
		// 	counter == flag2  ||
		// 	counter == flag3  ||
		// 	counter == flag4  ||
		// 	counter == flag5  ||
		// 	counter == flag6  ||
		// 	counter == flag7  ||
		// 	counter == flag8  ||
		// 	counter == flag9  ||
		// 	counter == flag10 ||
		// 	counter == flag11 ||
		// 	counter == flag12 ||
		// 	counter == flag13 ||
		// 	counter == flag14 ||
		// 	counter == flag15 ||
		// 	counter == flag16 ||
		// 	counter == flag17 ||
		// 	counter == flag18 ||
		// 	counter == flag19 ||
		// 	counter == flag20 ||
		// 	counter == flag21 ||
		// 	counter == flag22 ||
		// 	counter == flag23 ||
		// 	counter == flag24 ||
		// 	counter == flag25 ||
		// 	counter == flag26 ||
		// 	counter == flag27 ||
		// 	counter == flag28 ||
		// 	counter == flag29 ||
		// 	counter == flag30 ||
		// 	counter == flag31 ||
		// 	counter == flag32 ||
		// 	counter == flag33 ||
		// 	counter == flag34 ||
		// 	counter == flag35 ||
		// 	counter == flag36 ||
		// 	counter == flag37 ||
		// 	counter == flag38 ||
		// 	counter == flag39 ||
		// 	counter == flag40 ||
		// 	counter == flag41 ||
		// 	counter == flag42 ||
		// 	counter == flag43 ||
		// 	counter == flag44 ||
		// 	counter == flag45 ||
		// 	counter == flag46 ||
		// 	counter == flag47 ||
		// 	counter == flag48 ||
		// 	counter == flag49 ||
		// 	counter == flag50 ||
		// 	counter == flag51 ||
		// 	counter == flag52 ||
		// 	counter == flag53 ||
		// 	counter == flag54 ||
		// 	counter == flag55 ||
		// 	counter == flag56 ||
		// 	counter == flag57 ||
		// 	counter == flag58 ||
		// 	counter == flag59
		// )
		// 	clock_60Hz <= 1;
		// if (counter == CLOCK_FREQUENCY - 1)
		// 	counter <= 0;
		// if (counter == CLOCK_FREQUENCY/60) begin // divide by 60 to get 60 hz updates
		// 	counter <= 0;
		// 	clock_60Hz <= 1;
		// end
		if (counter == CLOCK_FREQUENCY/60) begin // divide by 60 to get 60 hz updates
			counter <= 0;
			clock_60Hz <= 1;
		end
	end
endmodule