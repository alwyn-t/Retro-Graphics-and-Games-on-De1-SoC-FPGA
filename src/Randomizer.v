module Randomizer(input clock, output reg [7:0] value);
	reg [2:0] counter5;
	reg [2:0] counter7;
	reg [3:0] counter11;
	reg [3:0] counter13;
	
	always@(clock) begin
		counter5 <= (counter5!=5) ? counter5 + 1:0;
		counter7 <= (counter7!=7) ? counter7 + 1:0;
		counter11 <= (counter11!=11) ? counter11 + 1:0;
		counter13 <= (counter13!=13) ? counter13 + 1:0;
		value <= {counter5, counter11[3:1], counter7, counter13[3:1]};
	end
	//assign value = ( (counter5 * counter7)^counter11 ) - counter13;
	// assign value = {counter5, counter11[3:1], counter7, counter13[3:1]};
endmodule