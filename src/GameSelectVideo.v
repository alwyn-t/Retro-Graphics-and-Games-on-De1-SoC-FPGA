module GameSelectVideo(input clk, enable, input [2:0] game, input [10:0] scanX, scanY, output [7:0] oR, oG, oB, input [9:0] SW);
    //800 x 600 resolution, 8 x 16 acsii characters, 100 x 37.5
    reg [8*3800-1:0] textBuffer = {
        {100{8'd63}}, 
        // Created by Alwyn T 2 43 30 26 45 30 29 : 27 50 : 0 37 48 50 39 : 19
        {41{8'd63}}, 8'd19, 8'd63, 8'd39, 8'd50, 8'd48, 8'd37, 8'd0, 8'd63, 8'd50, 8'd27, 8'd63, 8'd29, 8'd30, 8'd45, 8'd26, 8'd30, 8'd43, 8'd 2, {41{8'd63}},
        {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
         {46{8'd63}}, 8'd60, 8'd59, 8'd58, 8'd63, 8'd63, 8'd61, 8'd56, 8'd61, {46{8'd63}}, // [/] ^=^
         {48{8'd63}}, 8'd40, 8'd39, 8'd34, 8'd3, {48{8'd63}}, // Dino
         {48{8'd63}}, 8'd32, 8'd39, 8'd40, 8'd15, {48{8'd63}}, // Pong
         {44{8'd63}}, 8'd4, 8'd12, 8'd0, 8'd6, 8'd63, 8'd0, 8'd63, 8'd17, 8'd4, 8'd19, 8'd13, 8'd4, {44{8'd63}}, //ENTER A GAME 54 13 19 4 17 : 0 : 6 0 12 4
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}, {100{8'd63}}, {100{8'd63}}, {100{8'd63}},
        {100{8'd63}}
    };

    always@ (posedge clk) begin
        textBuffer[(18*100+46)*8 +: 8] = (game == 0) ? 8'd57 : 6'd63;
        textBuffer[(19*100+46)*8 +: 8] = (game == 1) ? 8'd57 : 6'd63;
    end
    // reg [8*3750-1:0] textBuffer = {3750{8'd1}}; // lots of B's

    // wire [9:0] address = 10'd614;
    // wire [9:0] address = textBuffer[((scanX/8) + (scanY/16)*100) +: 8] + (scanY%16)*64; // 0 : 1024-1
    wire [9:0] address = textBuffer[((scanX[10:3]) + (scanY[10:4])*100)*8 +: 8] + (scanY%16)*64; // 0 : 1024-1
	wire [7:0] q;
    ASCIIRom asciiRom(.address(address), .clock(clk), .q(q));

//    assign oR = q[(scanX[2:0])] ? 8'd0 : 8'd255;
//    assign oG = q[(scanX[2:0])] ? 8'd0 : 8'd255;
//    assign oB = q[(scanX[2:0])] ? 8'd0 : 8'd255;
    reg [8:0] backgroundRGB = 8'd0;
    reg [8:0] foregroundRGB = 8'd255;
    always@ (*) begin
        if (SW[9])
            foregroundRGB <= SW[8:0];
        else
            backgroundRGB <= SW[8:0];
    end
    assign oR = q[(scanX%8)] ? foregroundRGB[8:6]*32 : backgroundRGB[8:6]*32;
    assign oG = q[(scanX%8)] ? foregroundRGB[5:3]*32 : backgroundRGB[5:3]*32;
    assign oB = q[(scanX%8)] ? foregroundRGB[2:0]*32 : backgroundRGB[2:0]*32;
    // assign oR = q[(scanX%8)] ? 8'd255 : 8'd0;
    // assign oG = q[(scanX%8)] ? 8'd255 : 8'd0;
    // assign oB = q[(scanX%8)] ? 8'd255 : 8'd0;
endmodule