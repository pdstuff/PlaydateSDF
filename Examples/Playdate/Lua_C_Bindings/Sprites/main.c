#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

static PlaydateAPI* pd = NULL;

// Ellipse https://www.shadertoy.com/view/tt3yz7
float sdEllipse(float px, float py, float ex, float ey) {
	px = fabsf(px);
	py = fabsf(py);
	float eiX = 1.0f / ex;
	float eiY = 1.0f / ey;
	float e2X = ex * ex;
	float e2Y = ey * ey;
	float veX = eiX * (e2X - e2Y);
	float veY = eiY * (e2Y - e2X);
	float tX = 0.70710678118654752f; // sqrt(2)/2
	float tY = 0.70710678118654752f;
	for (int i = 0; i < 3; i++) {
		float vX = veX * tX * tX * tX;
		float vY = veY * tY * tY * tY;
		float tmx = px - vX;
		float tmy = py - vY;
		float n = sqrtf(tmx * tmx + tmy * tmy);
		float uX = (tmx / n) * sqrtf((tX * ex - vX) * (tX * ex - vX) + (tY * ey - vY) * (tY * ey - vY));
		float uY = (tmy / n) * sqrtf((tX * ex - vX) * (tX * ex - vX) + (tY * ey - vY) * (tY * ey - vY));
		float wX = eiX * (vX + uX);
		float wY = eiY * (vY + uY);
		float cx = fmaxf(0.0f, fminf(wX, 1.0f));
		float cy = fmaxf(0.0f, fminf(wY, 1.0f));
		n = sqrtf(cx * cx + cy * cy);
		tX = cx / n;
		tY = cy / n;
	}
	float nx = tX * ex;
	float ny = tY * ey;
	float d = sqrtf((px - nx) * (px - nx) + (py - ny) * (py - ny));
	float dp = px * px + py * py;
	float dn = nx * nx + ny * ny;
	return dp < dn ? -d : d;
}

//int sdEllipseBIND(lua_State* L);

int sdEllipseBIND(lua_State* L)
{
	float px = pd->lua->getArgFloat(1);
	float py = pd->lua->getArgFloat(2);
	float ex = pd->lua->getArgFloat(3);
	float ey = pd->lua->getArgFloat(4);

	float ret = sdEllipse(px, py, ex, ey);
	pd->lua->pushFloat(ret);
	return 1;
}


typedef struct {
	int (*func)(lua_State*);
	const char* name;
} LuaFunction;

LuaFunction functions[] = {
	//{sdfRhombus, "sdfRhombus"},
	//{sdfTrapezoid, "sdfTrapezoid"},
	{sdEllipseBIND, "sdEllipse"}
};

const int numFunctions = sizeof(functions) / sizeof(functions[0]);


int
eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInitLua )
	{
		pd = playdate;
		
		const char* err;

		for (int i = 0; i < numFunctions; i++) {
			if (!pd->lua->addFunction(functions[i].func, functions[i].name, &err)) {
				pd->system->logToConsole("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
			}
		}
	}
	return 0;
}

