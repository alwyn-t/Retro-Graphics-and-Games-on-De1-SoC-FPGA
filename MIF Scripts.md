# MIF Scripts
To ease the creation process of the sprite maps and ASCII characters maps, I programmed two different scripts in C++ to convert a CSS file to MIF file. A CSS file is quite unconventional but it was one of the easiest plain text export file types from `ASEPRITE`. The first script converts the CSS file to compressed RGB values (`A-RRRRR-GGGGG-BBBBB`) while the second script converts the CSS file to binary data. To get more specifics, please visit [Intel's MIF file documentation]().
**Note**: Unfortunately, I did not spend much time polishing these scripts so I recommend reading through so you can create your own. If you wish to use the scripts, you will need to update the `WIDTH` and `DEPTH` parameters in the header to appropriate values for your project. The script will loop over all values until it reaches the end of the file but the `WIDTH` and `Height` parameters need to be updated to to match your sprite map or be larger. Additionally, the address variables will need to be updated to be based on the new size of the sprite map.

```
//
// Created by Alwyn Tong on 2023-12-02.
//
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <sstream>

using namespace std;

char* fileName;

int main(int argc, char* argv[]){
	FILE *outputFile = fopen("output.mif","w");
	if (outputFile == 0) {
		cout << "could not create file" << endl;
		return 1;
	}
	
	// header
	fprintf(outputFile, "WIDTH = 8;\nDEPTH = 1024;\n\n\nADDRESS_RADIX = UNS;\nDATA_RADIX = BIN;\n--- unsigned decimal\n");
	
	// start body
	fprintf(outputFile, "CONTENT BEGIN\n");
	int address;
	int previousAddress;
	int y, x;
	string byte = "00000000";
	
	string line;
	for (int i=0; i<9; i++) { // skip over the first 8 lines
		getline(cin, line);
	}
	
	// load first value in
	stringstream lineStream(line);
	lineStream >> x;
	lineStream.ignore(3);
	lineStream >> y;
	previousAddress = address = (x>>3) + y*64;
	getline(cin, line);
	byte[7-x%8] = '1';
	
	while (!cin.eof()) {
		stringstream lineStream(line);
		lineStream >> x;
		lineStream.ignore(3);
		lineStream >> y;
		getline(cin, line);
		address = (x>>3) + y*64;
		if (address != previousAddress) {
			// add previous value to file
			fprintf(outputFile, " %i : %s;\n", previousAddress, byte.c_str());
			previousAddress = address;
			byte = "00000000";
			byte[7-x%8] = '1';
		} else {
			byte[7-x%8] = '1';
		}
		if (line == "}") {break;}
	}
	
	// end and close file
	fprintf(outputFile, "END;\n");
	fclose(outputFile);
	
	return 0;
}
```

```
//
// Created by Alwyn Tong on 2023-12-02.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <sstream>

using namespace std;

char* fileName;

int main(int argc, char* argv[]){
	FILE *outputFile = fopen("output.mif","w");
	if (outputFile == 0) {
		cout << "could not create file" << endl;
		return 1;
	}
	
	// header
	fprintf(outputFile, "WIDTH = 16;\nDEPTH = 16384;\n\n\nADDRESS_RADIX = UNS;\nDATA_RADIX = UNS;\n--- unsigned decimal\n");
	fprintf(outputFile, "--- cRGB (compressed RGB)\n--- 1 bit for alpha (on/off), 5 bits for red, 5 bits for green, 5 bits for blue\n--- all RGB values should be bit shifted 3 times (or multiplied by 8 to get mapped 24-bit RGB values)\n\n");
	
	// start body
	fprintf(outputFile, "CONTENT BEGIN\n");
	int address;
	int previousAddress;
	int lastAddress;
	string colour;
	string previousColour;
	int y, x;
	
	string line;
	for (int i=0; i<9; i++) { // skip over the first 8 lines
		getline(cin, line);
	}
	
	// load first value in
	stringstream lineStream(line);
	lineStream >> x;
	lineStream.ignore(3);
	lineStream >> y;
	lineStream.ignore(4);
	lineStream >> colour;
	previousColour = colour;
	lastAddress = previousAddress = address = x + y*512;
	getline(cin, line);
	
	// hex to cRGB
	while (!cin.eof()) {
		stringstream lineStream(line);
		lineStream >> x;
		lineStream.ignore(3);
		lineStream >> y;
		lineStream.ignore(4);
		lineStream >> colour;
		getline(cin, line);
		address = x + y*512;
		// check if values are different or if addresses are adjacent
		if (colour != previousColour || address != previousAddress+1) {
			// add previous value to file
			if (lastAddress == previousAddress) {
				fprintf(outputFile, " %i : ", previousAddress);
			} else {
				fprintf(outputFile, " [%i..%i] : ", lastAddress, previousAddress);
			}
		
			int hex1 = (previousColour[1] >= 48 && previousColour[0] <=57) ? previousColour[0] - 48 : previousColour[0] - 55;
			int hex2 = (previousColour[2] >= 48 && previousColour[1] <=57) ? previousColour[1] - 48 : previousColour[1] - 55;
			int hex3 = (previousColour[3] >= 48 && previousColour[2] <=57) ? previousColour[2] - 48 : previousColour[2] - 55;
			int hex4 = (previousColour[4] >= 48 && previousColour[3] <=57) ? previousColour[3] - 48 : previousColour[3] - 55;
			int hex5 = (previousColour[5] >= 48 && previousColour[4] <=57) ? previousColour[4] - 48 : previousColour[4] - 55;
			int hex6 = (previousColour[6] >= 48 && previousColour[5] <=57) ? previousColour[5] - 48 : previousColour[5] - 55;
			
			int byte1 = hex1*16 + hex2;
			int byte2 = hex3*16 + hex4;
			int byte3 = hex5*16 + hex6;
			
			byte1 /= 8;
			byte2 /= 8;
			byte3 /= 8;
			
			int colourValue = 32768 + byte1*32*32 + byte2*32 + byte3;
			fprintf(outputFile, "%i;\n", colourValue);
			
			lastAddress = previousAddress = address;
			previousColour = colour;
		} else {
			// if the colour and address are the same
			previousAddress = address;
		}
		if (line == "}") {break;}
	}
	
	// end and close file
	fprintf(outputFile, "END;\n");
	fclose(outputFile);
	
	return 0;
}
```