module hex_decoder(in, hex);
	input [3:0] in;
	output reg [6:0] hex;
	
	always@(*) begin
		hex[0] <= !(in!=1 && in!=4 && in!=11 && in!=13);
		hex[1] <= !(in!=5 && in!=6 && in!=11 && in!=12 && in!=14 && in!=15);
		hex[2] <= !(in!=2 && in!=12 && in!=14 && in!=15);
		hex[3] <= !(in!=1 && in!=4 && in!=7 && in!=10 && in!=15);
		hex[4] <= !(in!=1 && in!=3 && in!=4 && in!=5 && in!=7 && in!=9);
		hex[5] <= !(in!=1 && in!=2 && in!=3 && in!=7 && in!=13);
		hex[6] <= !(in!=0 && in!=1 && in!=7 && in!=12);
	end
endmodule