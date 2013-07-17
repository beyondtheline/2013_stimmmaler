/* Playstation Move on the PC, main source file
   by Carl Kenner 4 October 2010 - 5 October 2010 */

#include <stdio.h>
#include <stdlib.h>
#include "moveonpc.h"

int main() {
    printf("Opening Moves\n");
	if (!OpenMoves()) {
        printf("error!\n");
	}
	printf("Found %d Moves\n", GetMoveCount());
	SetColour(0, 0,0,255);
	SetColour(1, 255,0,0);
	SetColour(2, 0,255,0);
	SetColour(3, 255,255,0);

	int r = 0;
	int g = 0;
	int b = 0;

	TMove m;
	if (GetMoveCount()>0) {
		do {
			ReadMove(0, &m);

			//SetRumble(0, m.TAnalog);

			//if (m.Buttons & B_SQUARE)   SetColour(0, 0xFF, 0x6F, 0x80);
			//if (m.Buttons & B_CROSS)    SetColour(0, 0x4C, 0x6F, 0xFF);
			//if (m.Buttons & B_TRIANGLE) SetColour(0, 0x00, 0xFF, 0x23);
			//if (m.Buttons & B_CIRCLE)   SetColour(0, 0xFF, 0x6F, 0x0D);

			if (m.Buttons & B_SQUARE)
			{
				r = m.TAnalog;
				SetColour(0, r, g, b);
			}
			if (m.Buttons & B_TRIANGLE)
			{
				g = m.TAnalog;
				SetColour(0, r, g, b);
			}
			if (m.Buttons & B_CROSS)
			{
				b = m.TAnalog;
				SetColour(0, r, g, b);
			}

			if (m.Buttons & B_CIRCLE)
			{
				SetRumble(0, m.TAnalog);
			}
			else SetRumble(0, 0);

			if (m.Buttons & B_MOVE)
			{
				r = b = 0xAF;
				g = 0xFF;
				SetColour(0, r, g, b);
				//SetColour(0, 0xAF, 0xFF, 0xAF);  // white on my Move
			}
			if (m.Buttons & B_SELECT)
			{
				r = g = b = 255;
				SetColour(0, r, g, b);
				//SetColour(0, 0xFF, 0xFF, 0xFF); // setting all to maximum looks purple on my Move
			}
			if (m.Buttons & B_START)
			{
				r = g = b = 0;
				SetColour(0, r, g, b);
				//SetColour(0, 0xFF, 0xFF, 0xFF); // setting all to maximum looks purple on my Move
			} 
			printf("B:(%x,%x) Acc:(%d,%d,%d) Mag:(%d,%d,%d) Gyr:(%d,%d,%d) Temp:(%d) Bat:(%x)\n", m.Buttons, m.TAnalog, m.RawForceX, m.RawForceY, m.RawForceZ,
				m.RawMagnetX, m.RawMagnetY, m.RawMagnetZ, m.RawGyroYaw,m.RawGyroPitch,m.RawGyroRoll, m.RawTemperature, m.RawBattery);
		} while ((m.Buttons & B_PS) == 0);
	}
	SetColour(0, 0, 0, 0);
    printf("Closing Moves\n");
	CloseMoves();
	return 0;
}