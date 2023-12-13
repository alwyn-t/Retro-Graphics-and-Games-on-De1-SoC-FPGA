module overlap (output overlap, input enable, input [9:0] x, y, left, right, top, bottom);
	assign overlap = enable && (x >= left && x <= right && y >= top && y <= bottom);
endmodule