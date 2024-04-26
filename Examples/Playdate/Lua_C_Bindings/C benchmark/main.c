#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

#include "sdf2d.h" // be sure to add sdf2d.h and sdf2d.c to your project!

static PlaydateAPI* pd = NULL;

int benchmark(lua_State* L);

int
eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInitLua )
	{
		pd = playdate;
		const char* err;
		if ( !pd->lua->addFunction(benchmark, "benchmark", &err) )
					pd->system->logToConsole("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
	}
	return 0;
}

int benchmark(lua_State* L)
{
	LCDBitmap* img = pd->graphics->newBitmap(400, 240, 1);

	int sdtype = pd->lua->getArgInt(1);
	int benchtest = pd->lua->getArgInt(2);
	
	int w, h, rowbytes;
	uint8_t *data;
	uint8_t *mask;	
	pd->graphics->getBitmapData(img, &w, &h, &rowbytes, &mask, &data);
	
	int qx = 200; 
	int qy = 120;
	
	// To set the pixel at (10, 20) to black
	int x;
	int y;
	float totald;
	
	float vx[] = {10.0f, 370.0f, 190.0f, 30.0f};
	float vy[] = {10.0f, 115.0f, 190.0f, 80.0f};
	
	pd->system->resetElapsedTime();
	for(y=0;y<240;y++) {
		for(x=0;x<400;x++) {
			
			float d;		
			switch (sdtype) {
			case 1:	d = sdCircle(qx-x, qy-y, 110); break;  
			case 2: d = sdSegment(x, y, 50, 220, 350, 20); break;
			case 3: d = sdBox(qx-x, qy-y, 160, 70); break;
			case 4: d = sdOrientedBox(x, y, 50, 20, 350, 220, 20); break;
			case 5: d = sdRoundedBox(qx-x, qy-y, 70, 40, 10, 20, 0, 20); break;
			case 6: d = sdRoundSquare(x-qx,y-qy, 100, 20); break;
			case 7: d = sdRhombus(qx-x, qy-y, 100, 30); break;
			case 8:	d = sdTrapezoid(qx-x, qy-y, 100, 30, 40); break; 
			case 9:	d = sdParallelogram(qx-x, qy-y, 150, 50, 30); break;
			case 10: d = sdEquilateralTriangle(qx-x, qy-y, 100); break;
			case 11: d = sdTriangleIsosceles(qx-x, qy-y, 160, 50); break;
			case 12: d = sdTriangle(x, y, 40, 10, 50, 200, 350, 80); break;
			case 13: d = sdQuad(x, y, 40, 10, 50, 200, 320, 180, 350, 80); break;
			case 14: d = sdUnevenCapsule(x-qx,y-qy, 40, 30, 80); break;
			case 15: d = sdEgg(x-qx,y-qy, 50, 10); break;
			case 16: d = sdPie(qx-x,qy-y,0.866f, -0.5f, 100); break;
			case 17: d = sdCutDisk(qx-x,qy-y,100,-75); break;
			case 18: d = sdMoon(qx-x,qy-y,45,110,90); break;
			case 19: d = sdVesica(qx-x,qy-y,110,60); break;
			case 20: d = sdOrientedVesica(x,y,110,10,290,190,30); break;
			case 21: d = sdTunnel(qx-x,qy-y,80,40); break;
			case 22: d = sdArc(qx-x,qy-y,0.7071f,-0.7071f,80,10); break;
			case 23: d = sdRing(qx-x,qy-y,-0.7071f,0.7071f,100,10); break;
			case 24: d = sdHorseshoe(qx-x,qy-y,0,1,80,100,5); break;
			case 25: d = sdParabola(qx-x,qy-y,0.002); break;
			case 26: d = sdCross(qx-x,qy-y,100,40,14); break;
			case 27: d = sdRoundedX(qx-x,qy-y,180,20); break;
			case 28: d = sdEllipse(x-qx,y-qy,160,80); break;
			case 29: d = sdStar5(qx-x,qy-y,35,3); break;
			case 30: d = sdHexagram(qx-x,qy-y,45); break;
			case 31: d = sdPentagon(qx-x,qy-y,90); break;
			case 32: d = sdRegularPolygon(qx-x,qy-y,90,5); break;
			case 33: d = sdHexagon(qx-x,qy-y,90); break;
			case 34: d = sdRegularPolygon(qx-x,qy-y,90,6); break;
			case 35: d = sdOctagon(qx-x,qy-y,90); break;
			case 36: d = sdRegularPolygon(qx-x,qy-y,90,8); break;
			case 37: d = sdPolygon(x, y, vx, vy, 4); break;
			}	
						
			totald+=d; // use the value to ensure compiler doesn't strip it
			if (benchtest==0) {
				float remainder = fmodf(fabsf(d), 10.0f);
				remainder = remainder <= 0.9f || (10.0f - remainder) <= 0.9f;
				if ((remainder == 1) == (d > 0.0f))
				{ 
					data[(y)*rowbytes+(x)/8] &= ~(1 << (uint8_t)(7 - ((x) % 8)));
				};
			}
		}
	}
	float ts = pd->system->getElapsedTime();
	pd->lua->pushBitmap(img);
	pd->lua->pushFloat((w*h)/ts/50.0f);
	pd->lua->pushFloat(totald);
	return 3;
}
