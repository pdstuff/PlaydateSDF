// The SDF's in this file are C ports of the GLSL functions
// available at https://iquilezles.org/articles/distfunctions2d/
//
// MIT licence: please credit
// -- @robga https://github.com/pdstuff/PlaydateSDF
// -- @iq https://iquilezles.org
//
// Although these have been designed for the Playdate handheld system, they should be useful in any
// C environment without GPU.
//
// The port is written for speed, not readability.

#include "sdf2d.h"
#include <math.h>

// Circle (https://www.shadertoy.com/view/3ltSW2)
float sdCircle(float x, float y, float r)
{
	return sqrtf(x*x+y*y)-r;
}

// Segment (https://www.shadertoy.com/view/3tdSDj
float sdSegment(float px, float py, float ax, float ay, float bx, float by) 
{	
	float pax = px-ax;
	float pay = py-ay;
	float bax = bx-ax;
	float bay = by-ay;		
	float h = fmaxf(0.0f, fminf(1.0f, (pax*bax+pay*bay) / (bax*bax+bay*bay)));
	float gx = pax-(bax*h);
	float gy = pay-(bay*h);
	return sqrtf(gx*gx+gy*gy);
}

// Box (https://www.youtube.com/watch?v=62-pRVZuS5c)
float sdBox(float px, float py, float bx, float by) {
	px = fabsf(px) - bx;
	py = fabsf(py) - by;
	float dx = fmaxf(px, 0.0f);
	float dy = fmaxf(py, 0.0f);
	float od = sqrtf(dx*dx + dy*dy);
	float id = fminf(fmaxf(px, py), 0.0f);
	return od + id;
}

// Oriented Box (https://www.shadertoy.com/view/stcfzn)
float sdOrientedBox(float px, float py, float ax, float ay, float bx, float by, float th) 
{
	float bmax = bx-ax;
	float bmay = by-ay;
	float l = sqrtf(bmax*bmax+bmay*bmay);
	float dx = bmax/l;
	float dy = bmay/l;
	float cx = px-(ax+bx)*0.5f;
	float cy = py-(ay+by)*0.5f;
	float qx = fabsf(dx*cx+dy*cy)-l*0.5f;
	float qy = fabsf(-dy*cx+dx*cy)-th;
	return sqrtf(fmaxf(qx,0.0f)*fmaxf(qx,0.0f)+fmaxf(qy,0.0f)*fmaxf(qy,0.0f)) + fminf(fmaxf(qx, qy), 0.0f);
}

// Rounded Box (https://www.shadertoy.com/view/4llXD7 
float sdRoundedBox(float px, float py, float bx, float by, float rw, float rx, float ry, float rz) // b:w,h, r:{tr,br,tl,bl}
{
	if (px <= 0) { rw=ry; rx=rz; }
	if (py < 0) { rw=rx; }	
	float qx = fabsf(px)-bx+rw; 
	float qy = fabsf(py)-by+rw;	
	float c = sqrtf(fmaxf(qx,0.0f)*fmaxf(qx,0.0f)+fmaxf(qy,0.0f)*fmaxf(qy,0.0f));
	return c + fminf(fmaxf(qx, qy), 0.0f) - rw;
}

float sdRoundSquare(float px, float py, float s, float r) {
	float qx = fabsf(px) - s + r;
	float qy = fabsf(py) - s + r;
	float mq = fmaxf(qx, qy);
	float cmq = fminf(mq, 0.0f);
	float cqx = fmaxf(qx, 0.0f);
	float cqy = fmaxf(qy, 0.0f);
	float lcq = sqrtf(cqx * cqx + cqy * cqy);
	return cmq + lcq - r;
}

// Rhombus (https://www.shadertoy.com/view/XdXcRB)
float sdRhombus(float px, float py, float bx, float by) 
{
	px = fabsf(px);
	py = fabsf(py);
	float f1x = bx-px*2.0f;
	float f1y = by-py*2.0f;
	float f = (f1x*bx-f1y*by) / (bx*bx+by*by);
	float h = fmaxf(-1.0f, fminf(f, 1.0f));
	float dvx = px-((bx*0.5f)*(1.0f-h));
	float dvy = py-((by*0.5f)*(1.0f+h));
	float r = px*by+py*bx-bx*by;	
	return sqrtf(dvx*dvx+dvy*dvy) * ((r>0)-(r<0));
}

// Trapezoid (https://www.shadertoy.com/view/MlycD3)
float sdTrapezoid(float px, float py, float r1, float r2, float he)  // r1:base width,  r2:cap width, he:height
{
	px = fabsf(px);
	float k2x = r2-r1;
	float k2y = 2.0f*he;
	float cax = px - fminf(px, (py < 0.0f) ? r1 : r2);
	float cay = fabsf(py)-he;
	float d = fmaxf(0.0f, fminf((k2x*(r2-px)+k2y*(he-py))/(k2x*k2x+k2y*k2y), 1.0f));
	float cbx = px-r2+(k2x*d);
	float cby = py-he+(k2y*d);
	float s = (cbx < 0.0f && cay < 0.0f) ? -1.0f : 1.0f;
	return s*sqrtf( fminf((cax*cax+cay*cay),(cbx*cbx+cby*cby) ));
}

// Parallelogram (https://www.shadertoy.com/view/7dlGRf)
float sdParallelogram(float px, float py, float wi, float he, float sk)
{
	float ex = sk, ey = he;
	if (py < 0.0f) { px = -px; py = -py; } 
	float wx = px - ex;
	float wy = py - ey;
	wx -= fmaxf(-wi, fminf(wx, wi));  
	float dx = wx * wx + wy * wy;
	float dy = -wy;
	float s = px * ey - py * ex;
	if (s < 0.0f) { px = -px; py = -py; } 
	float vx = px - wi;
	float vy = py;
	float dve = vx * ex + vy * ey;
	float dee = ex * ex + ey * ey;
	float c = fmaxf(-1.0f, fminf(dve / dee, 1.0f));
	vx -= ex * c;
	vy -= ey * c;
	dx = fminf(dx, vx * vx + vy * vy);
	dy = fminf(dy, wi * he - fabsf(s));
	return sqrtf(dx) * ((-dy > 0) - (-dy < 0));
}

// Equilateral Triangle (https://www.shadertoy.com/view/Xl2yDW)
float sdEquilateralTriangle(float px, float py, float r)
{
	float k = 1.73205f;
	px = fabsf(px) - r;
	py = py + r/k;	
	if ( (px+k*py) > 0.0f ) {
		float ppx = (px - k * py) / 2.0f;
		float ppy = (-k * px - py) / 2.0f;
		px = ppx;
		py = ppy;
	}
	px -= fmaxf(-2.0f*r, fminf(px, 0.0f));
	return -sqrtf(px*px+py*py)*((py>0)-(py<0));
}

// Isosceles Triangle (https://www.shadertoy.com/view/MldcD7)
float sdTriangleIsosceles(float px, float py, float qx, float qy)
{
	px = fabsf(px);
	float m1 = fmaxf(0.0f, fminf((px*qx+py*qy)/(qx*qx+qy*qy), 1.0f));
	float ax = px-qx*m1;
	float ay = py-qy*m1;
	float n = fmaxf(0.0f, fminf(px/qx, 1.0f));
	float bx = px-qx*n;
	float by = py-qy;
	float s = fmaxf(((qy>0)-(qy<0)) * (px*qy-py*qx), ((qy>0)-(qy<0))*(py-qy));
	return sqrtf(fminf(ax*ax+ay*ay,bx*bx+by*by))*((s>0)-(s<0));
}

// Triangle (https://www.shadertoy.com/view/XsXSz4)
float sdTriangle(float px, float py, float p0x, float p0y, float p1x, float p1y, float p2x, float p2y)
{
	float e0x = p1x-p0x;
	float e0y = p1y-p0y; 
	float e1x = p2x-p1x;
	float e1y = p2y-p1y; 
	float e2x = p0x-p2x;
	float e2y = p0y-p2y; 
	float v0x = px-p0x;
	float v0y = py-p0y; 
	float v1x = px-p1x;
	float v1y = py-p1y; 
	float v2x = px-p2x;
	float v2y = py-p2y; 
	float dp0 = (v0x*e0x+v0y*e0y) / (e0x*e0x+e0y*e0y);
	float dp1 = (v1x*e1x+v1y*e1y) / (e1x*e1x+e1y*e1y);
	float dp2 = (v2x*e2x+v2y*e2y) / (e2x*e2x+e2y*e2y);
	float m0 = fmaxf(0.0f, fminf(dp0, 1.0f));
	float m1 = fmaxf(0.0f, fminf(dp1, 1.0f));
	float m2 = fmaxf(0.0f, fminf(dp2, 1.0f));
	float pq0x = v0x-e0x*m0;
	float pq0y = v0y-e0y*m0;
	float pq1x = v1x-e1x*m1;
	float pq1y = v1y-e1y*m1;
	float pq2x = v2x-e2x*m2;
	float pq2y = v2y-e2y*m2;
	float s = e0x*e2y-e0y*e2x;
	s = ((s>0)-(s<0));
	float d0x = pq0x*pq0x+pq0y*pq0y;
	float d0y = s*(v0x*e0y-v0y*e0x);
	float d1x = pq1x*pq1x+pq1y*pq1y;
	float d1y = s*(v1x*e1y-v1y*e1x);
	float d2x = pq2x*pq2x+pq2y*pq2y;
	float d2y = s*(v2x*e2y-v2y*e2x);
	float dx = fminf(fminf(d0x,d1x), d2x);
	float dy = fminf(fminf(d0y,d1y), d2y);
	return -sqrtf(dx)*((dy>0)-(dy<0));	
}

// Quad (https://www.shadertoy.com/view/7dSGWK)
float sdQuad(float px, float py, float p0x, float p0y, float p1x, float p1y, float p2x, float p2y, float p3x, float p3y)
{	
	float e0x = p1x-p0x;
	float e0y = p1y-p0y; 
	float e1x = p2x-p1x;
	float e1y = p2y-p1y; 
	float e2x = p3x-p2x;
	float e2y = p3y-p2y; 
	float e3x = p0x-p3x;
	float e3y = p0y-p3y; 
	float v0x = px-p0x;
	float v0y = py-p0y; 
	float v1x = px-p1x;
	float v1y = py-p1y; 
	float v2x = px-p2x;
	float v2y = py-p2y; 
	float v3x = px-p3x;
	float v3y = py-p3y;
	float dp0 = (v0x*e0x+v0y*e0y) / (e0x*e0x+e0y*e0y);
	float dp1 = (v1x*e1x+v1y*e1y) / (e1x*e1x+e1y*e1y);
	float dp2 = (v2x*e2x+v2y*e2y) / (e2x*e2x+e2y*e2y);
	float dp3 = (v3x*e3x+v3y*e3y) / (e3x*e3x+e3y*e3y);
	float m0 = fmaxf(0.0f, fminf(dp0, 1.0f));
	float m1 = fmaxf(0.0f, fminf(dp1, 1.0f));
	float m2 = fmaxf(0.0f, fminf(dp2, 1.0f));
	float m3 = fmaxf(0.0f, fminf(dp3, 1.0f));
	float pq0x = v0x-e0x*m0;
	float pq0y = v0y-e0y*m0;
	float pq1x = v1x-e1x*m1;
	float pq1y = v1y-e1y*m1;
	float pq2x = v2x-e2x*m2;
	float pq2y = v2y-e2y*m2;
	float pq3x = v3x-e3x*m3;
	float pq3y = v3y-e3y*m3;
	float d0x = pq0x*pq0x+pq0y*pq0y;
	float d0y = v0x*e0y-v0y*e0x;
	float d1x = pq1x*pq1x+pq1y*pq1y;
	float d1y = v1x*e1y-v1y*e1x;
	float d2x = pq2x*pq2x+pq2y*pq2y;
	float d2y = v2x*e2y-v2y*e2x;
	float d3x = pq3x*pq3x+pq3y*pq3y;
	float d3y = v3x*e3y-v3y*e3x;
	float dx = fminf(fminf(fminf(d0x,d1x), d2x), d3x);
	float dy = fminf(fminf(fminf(d0y,d1y), d2y), d3y);
	return -sqrtf(dx)*((dy>0)-(dy<0));
}

// Uneven Capsule (https://www.shadertoy.com/view/4lcBWn)
float sdUnevenCapsule(float px, float py, float r1, float r2, float h) { // -- r1:radius1, r2:radius2, h:distance between r1,r2
	px = fabsf(px);
	float b = (r1 - r2) / h;
	float a = sqrtf(1.0f - b * b);	
	float k = (-b * px) + (a * py);
	float lp = sqrtf(px * px + py * py);
	if (k < 0.0f) return lp - r1;
	if (k > a * h) {
		return sqrtf(px * px + (py - h) * (py - h)) - r2;
	}
	return (a * px) + (b * py) - r1;
}

// Simple Egg (https://www.shadertoy.com/view/Wdjfz3)
float sdEgg(float px, float py, float ra, float rb) {
	const float k = 1.73205f;	
	px = fabsf(px);
	float r = ra - rb;
	float l1 = sqrtf(px * px + py * py) - r;
	if (py < 0.0f) {
		return l1 - rb;
	} else {
		float m0 = py - k * r;
		float l2 = sqrtf(px * px + m0 * m0);	
		if (k * (px + r) < py) {
			return l2 - rb;
		} else {
			float m1 = px + r;
			float l3 = sqrtf(m1 * m1 + py * py) - 2.0f * r;
			return l3 - rb;
		}
	}
}

// Pie (https://www.shadertoy.com/view/3l23RK)
float sdPie(float px, float py, float cx, float cy, float r) { // c:sin/cos of aperture, r:radius
	px = fabsf(px);
	float l = sqrtf(px*px + py*py) - r;
	float dpc = px*cx + py*cy;
	float cd = fmaxf(0.0f, fminf(dpc, r));
	float nx = cx*cd;
	float ny = cy*cd;
	float m = sqrtf((px - nx) * (px - nx) + (py - ny) * (py - ny));
	float cr = cy * px - cx * py;
	float s = (cr > 0.0f) ? 1.0f : -1.0f;
	return fmaxf(l, m * s);
}

// Cut Disk (https://www.shadertoy.com/view/ftVXRc)
float sdCutDisk(float px, float py, float r, float h) { // r:radius, h:dist from centre (pos/neg)
	float w = sqrtf(r*r - h*h);
	px = fabsf(px);
	float pxx = px * px;
	float pyy = py * py;
	float s = fmaxf((h - r) * pxx + w * w * (h + r - 2.0f * py), h * px - w * py);
	if (s < 0.0f) {
		return sqrtf(pxx + pyy) - r;
	} else if (px < w) {
		return h - py;
	} else {
		float dx = px - w;
		float dy = py - h;
		return sqrtf(dx * dx + dy * dy);
	}
}

// Moon (https://www.shadertoy.com/view/WtdBRS)
float sdMoon(float px, float py, float d, float ra, float rb)
{
	py = fabsf(py);
	float a = (ra * ra - rb * rb + d * d) / (2.0f * d);
	float b = sqrtf(fmaxf(ra * ra - a * a, 0.0f));	
	if (d * (px * b - py * a) > d * d * fmaxf(b - py, 0.0f))
	{
		float pxa = px - a;
		float pyb = py - b;
		return sqrtf(pxa * pxa + pyb * pyb);
	}
	float l1 = sqrtf(px * px + py * py); 
	float pdx = px - d;
	float l2 = sqrtf(pdx * pdx + py * py); 	
	return fmaxf(l1 - ra, -(l2 - rb));
}

// Vesica (https://www.shadertoy.com/view/XtVfRW)
float sdVesica(float px, float py, float r, float d) {
	px = fabsf(px);  
	py = fabsf(py);  
	float b = sqrtf(r*r-d*d);  
	if ((py - b) * d > px * b) {
		float dy = py - b;  
		return sqrtf(px * px + dy * dy) * ((d > 0) - (d < 0));
	} else {
		float dx = px + d; 
		return sqrtf(dx * dx + py * py) - r;  
	}
}

// Oriented Vesica (https://www.shadertoy.com/view/cs2yzG)
float sdOrientedVesica(float px, float py, float ax, float ay, float bx, float by, float w) {
	float dx = bx - ax;
	float dy = by - ay;
	float r = 0.5f * sqrtf(dx * dx + dy * dy);
	float d = 0.5f * (r * r - w * w) / w;
	float vx = dx / r;
	float vy = dy / r;
	float cx = 0.5f * (bx + ax);
	float cy = 0.5f * (by + ay);
	float qx = px - cx;
	float qy = py - cy;
	float mqx = 0.5f * fabsf(vy * qx + vx * qy);
	float mqy = 0.5f * fabsf(-vx * qx + vy * qy);
	float hx, hy, hz;
	if (r * mqx < d * (mqy - r)) {
		hx = 0.0f;
		hy = r;
		hz = 0.0f;
	} else {
		hx = -d;
		hy = 0.0f;
		hz = d + w;
	}
	float dx_h = mqx - hx;
	float dy_h = mqy - hy;
	return sqrtf(dx_h * dx_h + dy_h * dy_h) - hz;
}

// Tunnel (https://www.shadertoy.com/view/flSSDy)
float sdTunnel(float px, float py, float whx, float why) {
	px = fabsf(px);
	py = -py;
	float qx = px - whx;
	float qy = py - why;

	float m0 = fmaxf(qx, 0.0f);
	float d1 = m0 * m0 + qy * qy;
	float l = sqrtf(px * px + py * py);
	qx = (py > 0.0f) ? qx : l - whx;
	float m1 = fmaxf(qy, 0.0f);
	float d2 = qx * qx + m1 * m1;
	float d = sqrtf(fminf(d1, d2));
	return (fmaxf(qx, qy) < 0.0f) ? -d : d;
}

// Arc (https://www.shadertoy.com/view/wl23RK)
float sdArc(float px, float py, float scx, float scy, float ra, float rb) {
	px = fabsf(px);
	if (scy * px > scx * py) {
		float dx = px - scx * ra; 
		float dy = py - scy * ra; 
		return sqrtf(dx * dx + dy * dy) - rb;  
	} else {
		float l = sqrtf(px * px + py * py); 
		return fabsf(l - ra) - rb;  
	}
}

// Ring (https://www.shadertoy.com/view/DsccDH)
float sdRing(float px, float py, float nx, float ny, float r, float th) {
	px = fabsf(px);
	float rx = nx * px + ny * py;  
	py = -ny * px + nx * py; 
	px = rx;
	float l = sqrtf(px * px + py * py); 
	float d1 = fabsf(l - r) - th * 0.5f;
	py = fmaxf(0.0f, fabsf(r - py) - th * 0.5f);
	float d2 = sqrtf(px * px + py * py) * ((px > 0) - (px < 0));
	return fmaxf(d1, d2);
}

// Horseshoe (https://www.shadertoy.com/view/WlSGW1)
float sdHorseshoe(float px, float py, float cx, float cy, float r, float le, float th) {
	px = fabsf(px);
	float l = sqrtf(px * px + py * py);
	float tx = -cx * px + cy * py;
	py = cy * px + cx * py;
	px = tx;
	px = (py > 0.0f || px > 0.0f) ? px : l * ((-cx > 0.0f) ? 1.0f : -1.0f);
	py = (px > 0.0f) ? py : l;
	px = px - le;
	py = fabsf(py - r) - th;
	float mx = fmaxf(px, 0.0f);
	float my = fmaxf(py, 0.0f);
	float lr = sqrtf(mx * mx + my * my);
	float mr = fminf(0.0f, fmaxf(px, py));
	return lr + mr;
}

// Parabola (https://www.shadertoy.com/view/ws3GD7)
float sdParabola(float px, float py, float k) {
	px = fabsf(px);
	float ik = 1.0f / k;
	float p = ik * (py - 0.5f * ik) / 3.0f;
	float q = 0.25f * ik * ik * px;
	float h = q * q - p * p * p;
	float r = sqrtf(fabsf(h));
	float x;
	if (h > 0.0f) {
		x = cbrtf(q + r) + cbrtf(fabsf(q - r)) * ((p > 0) - (p < 0));
	} else {
		x = 2.0f * cosf(atan2f(r, q) / 3.0f) * sqrtf(p);
	}
	float dx = px - x;
	float dy = py - (k * x * x);
	float d = sqrtf(dx * dx + dy * dy); 
	return (px < x) ? -d : d;
}

// Cross (https://www.shadertoy.com/view/XtGfzw)
float sdCross(float px, float py, float bx, float by, float r) {
	px = fabsf(px);
	py = fabsf(py);
	if (py > px) {
		float temp = px;
		px = py;
		py = temp;
	}
	float qx = px - bx;
	float qy = py - by;
	float k = fmaxf(qx, qy);
	float wx, wy;
	if (k > 0.0f) {
		wx = qx;
		wy = qy;
	} else {
		wx = by - px;
		wy = -k;
	}
	float m1 = fmaxf(wx, 0.0f);
	float m2 = fmaxf(wy, 0.0f);
	float d = sqrtf(m1 * m1 + m2 * m2);
	return (k > 0.0f ? d : -d) + r;
}

// Rounded X (https://www.shadertoy.com/view/3dKSDc)
float sdRoundedX(float px, float py, float w, float r) {
	px = fabsf(px);  
	py = fabsf(py);  
	float m = fminf(px + py, w) * 0.5f; 
	float dx = px - m; 
	float dy = py - m; 
	return sqrtf(dx * dx + dy * dy) - r; 
}

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

// Star 5 (https://www.shadertoy.com/view/3tSGDy)
float sdStar5(float px, float py, float r, float rf)
{	
	float kx = 0.809016994375f;
	float ky = -0.587785252292f;
	px = fabsf(px);
	float f1 = fmaxf((kx*px+ky*py),0.0f)*2.0f;
	px = px-kx*f1;
	py = py-ky*f1;
	float f2 = fmaxf((-kx*px+ky*py),0.0f)*2.0f;
	px = px-(-kx*f2);
	px = fabsf(px);
	py = py-(ky*f2)-r;
	float bax = -ky*rf;
	float bay = kx*rf-1.0f;
	float h = fmaxf(0.0f, fminf(((px*bax+py*bay)/(bax*bax+bay*bay)), r));
	float s = py*bax-px*bay;
	float dx = px-bax*h;
	float dy = py-bay*h;
	return sqrtf(dx*dx+dy*dy) * ((s>0)-(s<0));
}

// Hexagram (https://www.shadertoy.com/view/tt23RR)
float sdHexagram(float px, float py, float r)
{
	float kx = -0.5f;
	float ky = 0.8660254038f;
	float kz = 0.5773502692f; 
	float kw = 1.7320508076f; 
	px = fabsf(px);
	py = fabsf(py);
	float d1 = kx * px + ky * py;
	px -= 2.0f * fminf(d1, 0.0f) * kx;
	py -= 2.0f * fminf(d1, 0.0f) * ky;
	float d2 = ky * px + kx * py;
	px -= 2.0f * fminf(d2, 0.0f) * ky;
	py -= 2.0f * fminf(d2, 0.0f) * kx;
	px -= fmaxf(r * kz, fminf(px, r * kw));
	py -= r;
	return sqrtf(px * px + py * py) * ((py > 0) - (py < 0));
}

// Regular Pentagon (https://www.shadertoy.com/view/llVyWW)
float sdPentagon(float px, float py, float r) // r:apothem
{
	float kx = 0.809016994f; // cos pi/5
	float ky = 0.587785252f; // sin pi/5
	float kz = 0.726542528f; // tan pi/5
	px = fabsf(px);
	float d1 = -kx * px + ky * py;
	float ax = 2.0f * fminf(d1, 0.0f) * -kx;
	float ay = 2.0f * fminf(d1, 0.0f) * ky;
	px -= ax;
	py -= ay;
	float d2 = kx * px + ky * py;
	float bx = 2.0f * fminf(d2, 0.0f) * kx;
	float by = 2.0f * fminf(d2, 0.0f) * ky;
	px -= bx;
	py -= by;
	px -= fmaxf(-r * kz, fminf(px, r * kz));
	py -= r;
	return sqrtf(px * px + py * py) * ((py > 0) - (py < 0));
}

// Regular Hexagon (https://www.shadertoy.com/view/fd3SRf)
float sdHexagon(float px, float py, float s) // s:apothem
{
	float kx = -0.866025404f;
	float ky = 0.5f;
	float kz = 0.577350269f;
	px = fabsf(px);
	py = fabsf(py);
	float kxyp = (kx*px+ky*py);
	px -= kx * fminf(kxyp,0.0f) * 2.0f;
	py -= ky * fminf(kxyp,0.0f) * 2.0f;
	px -= fmaxf(-kz*s, fminf(px, kz*s));
	py -= s;
	return sqrtf(px*px+py*py) * ((py>0)-(py<0));		
}

// Regular Octagon (https://www.shadertoy.com/view/llGfDG)
float sdOctagon(float px, float py, float r) // r:apothem
{
	float kx = -0.9238795325f;
	float ky = 0.3826834323f;
	float kz = 0.4142135623f;
	px = fabsf(px);
	py = fabsf(py);
	float d1 = kx * px + ky * py;
	float ax = 2.0f * fminf(d1, 0.0f) * kx;
	float ay = 2.0f * fminf(d1, 0.0f) * ky;
	px -= ax;
	py -= ay;
	float d2 = -kx * px + ky * py; // Use updated px, py from first adjustment
	float bx = 2.0f * fminf(d2, 0.0f) * (-kx);
	float by = 2.0f * fminf(d2, 0.0f) * ky;
	px -= bx;
	py -= by;
	px -= fmaxf(-kz*r, fminf(px, kz*r));
	py -= r;
	return sqrtf(px*px + py*py) * ((py > 0) - (py < 0));
}

// Regular Polygon (https://www.shadertoy.com/view/7tSXzt)
float sdRegularPolygon(float px, float py, float r, int n) {

	float an = 3.141593f / n;
	float acs_x = cosf(an); // you can pre-calc this outside the function for speed
	float acs_y = sinf(an); // you can pre-calc this outside the function for speed
	float fm = fmodf(atan2f(py, px), (2.0f * an));
	if (fm < 0) { fm += 2.0f * an; }
	float bn = fm - an;
	float p_mag = sqrtf(px * px + py * py);
	px = cosf(bn) * p_mag;
	py = fabsf(sinf(bn)) * p_mag;
	px -= acs_x*r;
	py -= acs_y*r;
	py += fmaxf(0.0f, fminf(-py, acs_y * r));
	return sqrtf(px * px + py * py) * ((px>0.0f)-(px<0.0f));
}

// Polygon (https://www.shadertoy.com/view/wdBXRW)
float sdPolygon(float px, float py, float vx[], float vy[], int n)
{
	float d = (px - vx[0]) * (px - vx[0]) + (py - vy[0]) * (py - vy[0]);
	float s = 1.0f;
	int j = n - 1;
	for (int i = 0; i < n; j = i++)
	{
		float ex = vx[j] - vx[i];
		float ey = vy[j] - vy[i];
		float wx = px - vx[i];
		float wy = py - vy[i];
		float pr = (wx * ex + wy * ey) / (ex * ex + ey * ey);
		pr = fmaxf(0.0f, fminf(pr, 1.0f));  
		float bx = wx - ex * pr;
		float by = wy - ey * pr;
		d = fminf(d, bx * bx + by * by);
		int c1 = (py >= vy[i]);
		int c2 = (py < vy[j]);
		int c3 = (ex * wy > ey * wx);
		if ((c1 && c2 && c3) || (!c1 && !c2 && !c3))
			s = -s;			
	}
	return s * sqrtf(d);
}
