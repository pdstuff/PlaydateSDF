#ifndef SDF2D_H
#define SDF2D_H

float sdCircle(float x, float y, float r);
float sdBox(float px, float py, float bx, float by);
float sdBoxLinf(float px, float py, float bx, float by);
float sdRoundedBox(float px, float py, float bx, float by, float rw, float rx, float ry, float rz);
float sdOrientedBox(float px, float py, float ax, float ay, float bx, float by, float th);
float sdSegment(float px, float py, float ax, float ay, float bx, float by); 
float sdSegmentLinf(float px, float py, float ax, float ay, float bx, float by); 
float sdRhombus(float px, float py, float bx, float by);
float sdRhombusLinf(float px, float py, float bx, float by);
float sdTrapezoid(float px, float py, float r1, float r2, float he);
float sdParallelogram(float px, float py, float wi, float he, float sk);
float sdTriangle(float px, float py, float p0x, float p0y, float p1x, float p1y, float p2x, float p2y);
float sdTriangleIsosceles(float px, float py, float qx, float qy);
float sdEquilateralTriangle(float px, float py, float r);
float sdQuad(float px, float py, float p0x, float p0y, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y);
float sdStar5(float px, float py, float r, float rf);
float sdPentagon(float px, float py, float r);
float sdHexagon(float px, float py, float s);
float sdOctagon(float px, float py, float r);
float sdHexagram(float px, float py, float r);
float sdPie(float px, float py, float cx, float cy, float r);
float sdCutDisk(float px, float py, float r, float h);
float sdArc(float px, float py, float scx, float scy, float ra, float rb);
float sdRing(float px, float py, float nx, float ny, float r, float th);
float sdHorseshoe(float px, float py, float cx, float cy, float r, float le, float th);
float sdVesica(float px, float py, float r, float d);
float sdOrientedVesica(float px, float py, float ax, float ay, float bx, float by, float w);
float sdMoon(float px, float py, float d, float ra, float rb);
float sdCross(float px, float py, float bx, float by, float r);
float sdRoundedX(float px, float py, float w, float r);
float sdParabola(float px, float py, float k);
float sdTunnel(float px, float py, float whx, float why);
float sdEllipse(float px, float py, float ex, float ey);
float sdEllipseLinf(float px, float py, float ex, float ey);
float sdRegularPolygon(float px, float py, float r, int n);
float sdPolygon(float px, float py, float vx[], float vy[], int num);
float sdRoundSquare(float px, float py, float s, float r);
float sdEgg(float px, float py, float ra, float rb);
float sdUnevenCapsule(float px, float py, float r1, float r2, float h);

#endif 