-- The SDF's in this file are Lua ports of the GLSL functions
-- available at https://iquilezles.org/articles/distfunctions2d/
--
-- MIT licence: please credit
-- -- Inigo Quilez https://iquilezles.org
-- -- robga https://github.com/pdstuff/PlaydateSDF
--
-- Although these have been designed for the Playdate handheld system, they should be useful in any
-- Lua environment (eg Love2D) without GPU.
--
-- The port is written for speed, not readability.

local sin = math.sin
local cos = math.cos
local atan = math.atan
local sqrt = math.sqrt
local pow = math.pow

-- Circle (https://www.shadertoy.com/view/3ltSW2)
function sdCircle(px, py, r)
	return sqrt(px*px+py*py) - r 
end

-- Segment (https://www.shadertoy.com/view/3tdSDj
function sdSegment(px, py, ax, ay, bx, by)
	local pax = px-ax
	local pay = py-ay
	local bax = bx-ax
	local bay = by-ay
	local h0 = (pax*bax+pay*bay) / (bax*bax+bay*bay)
	local h1 = ((1 < h0) and 1 or h0)
	local h = ((0 > h1) and 0 or h1)
	local gx = pax-(bax*h)
	local gy = pay-(bay*h)
	return sqrt(gx*gx+gy*gy)
end

-- Box (https://www.youtube.com/watch?v=62-pRVZuS5c)
function sdBox(px, py, bx, by)
	px = ((px >= 0) and px or -px) - bx
	py = ((py >= 0) and py or -py) - by
	local dx = ((px > 0) and px or 0)
	local dy = ((py > 0) and py or 0)
	local od = sqrt(dx*dx + dy*dy)
	local m = ((px > py) and px or py)
	local id = ((m < 0) and m or 0)
	return od + id
end

-- Oriented Box (https://www.shadertoy.com/view/stcfzn)
function sdOrientedBox(px, py, ax, ay, bx, by, th) -- a:startxy, b:endxy, th:thickness
	local bmax = bx-ax
	local bmay = by-ay
	local l = sqrt(bmax*bmax+bmay*bmay)
	local dx = bmax/l
	local dy = bmay/l
	local cx = px-(ax+bx)*0.5
	local cy = py-(ay+by)*0.5
	local m0 = dx*cx+dy*cy
	local m1 = -dy*cx+dx*cy
	local qx = ((m0 >= 0) and m0 or -m0)-l*0.5
	local qy = ((m1 >= 0) and m1 or -m1)-th
	local nx = ((qx > 0) and qx or 0)
	local ny = ((qy > 0) and qy or 0)
	local nxy = ((qx > qy) and qx or qy)
	return sqrt(nx*nx+ny*ny) + ((nxy < 0) and nxy or 0)
end

-- Rounded Box (https://www.shadertoy.com/view/4llXD7 
function sdRoundedBox(px, py, bx, by, rw, rx, ry, rz) -- b:w,h, r:{tr,br,tl,bl}
	if (px <= 0) then rw=ry; rx=rz; end
	if (py < 0) then rw=rx end	
	local qx = ((px >= 0) and px or -px)-bx+rw 
	local qy = ((py >= 0) and py or -py)-by+rw
	local nx = ((qx > 0) and qx or 0)
	local ny = ((qy > 0) and qy or 0)
	local nxy = ((qx > qy) and qx or qy)	
	local c = sqrt(nx*nx+ny*ny)
	return c + ((nxy < 0) and nxy or 0) - rw
end

function sdRoundSquare(px, py, s, r)
	local sr = s + r
	local qx = ((px >= 0) and px or -px) - sr
	local qy = ((py >= 0) and py or -py) - sr
	local mq = ((qx > qy) and qx or qy)
	local cqx = ((qx > 0) and qx or 0)
	local cqy = ((qy > 0) and qy or 0)
	local lcq = sqrt(cqx * cqx + cqy * cqy)
	return ((mq < 0) and mq or 0) + lcq - r
end

-- Rhombus (https://www.shadertoy.com/view/XdXcRB)
function sdRhombus(px, py, bx, by)
	px = (px >= 0) and px or -px
	py = (py >= 0) and py or -py	
	local f1x = bx-px*2
	local f1y = by-py*2
	local f = (f1x*bx-f1y*by) / (bx*bx+by*by)
	local h0 = ((f < 1) and f or 1)
	local h = ((-1 >= h0) and -1 or h0)
	local dvx = px-((bx*0.5)*(1-h))
	local dvy = py-((by*0.5)*(1+h))
	local r = px*by+py*bx-bx*by	
	return sqrt(dvx*dvx+dvy*dvy) * (r > 0 and 1 or r < 0 and -1 or 0)
end

-- Trapezoid (https://www.shadertoy.com/view/MlycD3)
function sdTrapezoid(px, py, r1, r2, he) -- r1:base width,  r2:cap width, he:height
	px = ((px >= 0) and px or -px)
	local k2x = r2-r1
	local k2y = 2*he
	local z = (py < 0) and r1 or r2
	local cax = px - ((px < z and px or z))
	local cay = ((py >= 0) and py or -py) - he
	local d0 = (k2x * (r2 - px) + k2y * (he - py)) / (k2x * k2x + k2y * k2y)
	local d1 = ((d0 < 1) and d0 or 1)
	local d = ((0 > d1) and 0 or d1)
	local cbx = px-r2+(k2x*d)
	local cby = py-he+(k2y*d)
	local s = (cbx < 0 and cay < 0) and -1 or 1
	local m0 = cax*cax+cay*cay
	local m1 = cbx*cbx+cby*cby
	return s*sqrt(((m0 < m1) and m0 or m1))
end

-- Parallelogram (https://www.shadertoy.com/view/7dlGRf)
function sdParallelogram(px, py, wi, he, sk ) -- width, height, skew
	local ex = sk
	local ey = he
	if py < 0.0 then
		px = -px
		py = -py
	end
	local wx = px - ex
	local wy = py - ey
	local m0 = ((wx < wi) and wx or wi)
	wx = wx - ((-wi > m0) and -wi or m0)
	local dx = wx * wx + wy * wy
	local dy = -wy
	local s = px * ey - py * ex
	if s < 0.0 then
		px = -px
		py = -py
	end
	local vx = px - wi
	local vy = py
	local ve = vx * ex + vy * ey
	local ee = ex * ex + ey * ey
	local veee = ve / ee
	local m1 = ((veee < 1) and veee or 1)
	local c = ((-1 > m1) and -1 or m1)
	vx = vx - ex * c
	vy = vy - ey * c
	local m2 = vx * vx + vy * vy
	dx = ((dx < m2) and dx or m2)
	local m3 =  wi * he - ((s >= 0) and s or -s)	
	dy = ((dy < m3) and dy or m3)
	return sqrt(dx) * (((-dy > 0) and 1 or 0) - ((-dy < 0) and 1 or 0))
end

-- Equilateral Triangle (https://www.shadertoy.com/view/Xl2yDW)
function sdEquilateralTriangle( px, py, r )	
	px = ((px >= 0) and px or -px) - r
	py = py + r / 1.73205
	if (px + 1.73205 * py) > 0 then
		local ppx = (px - 1.73205 * py) / 2.0
		local ppy = (-1.73205 * px - py) / 2.0
		px = ppx
		py = ppy
	end
	local m0 = ((px < 0) and px or 0)
	local m1 = -2 * r
	px = px - ((m1 > m0) and m1 or m0)
	return -sqrt(px * px + py * py) * ((py > 0) and 1 or -1)
end

-- Isosceles Triangle (https://www.shadertoy.com/view/MldcD7)
function sdTriangleIsosceles(px, py, qx, qy)
	px = ((px >= 0) and px or -px)
	local c0 = (px * qx + py * qy) / (qx * qx + qy * qy)
	local m0 = ((c0 < 1) and c0 or 1)
	local m1 = ((0 > m0) and 0 or m0)
	local ax = px - qx * m1
	local ay = py - qy * m1
	local c1 = px / qx
	local m2 = ((c1 < 0) and c1 or 0)
	local n = ((0 > m2) and 0 or m2)
	local bx = px - qx * n
	local by = py - qy
	local ss = (qy > 0 and 1 or (qy < 0 and -1 or 0))
	local c2 = ss * (px * qy - py * qx)
	local c3 = ss * (py - qy)
	local s = ((c2 > c3) and c2 or c3)
	local c4 = ax * ax + ay * ay
	local c5 = bx * bx + by * by
	return sqrt((c4 < c5) and c4 or c5) * ((s > 0 and 1) or (s < 0 and -1) or 0)
end

-- Triangle (https://www.shadertoy.com/view/XsXSz4)
function sdTriangle(px, py, p0x, p0y, p1x, p1y, p2x, p2y) -- vertices
	local e0x = p1x - p0x
	local e0y = p1y - p0y
	local e1x = p2x - p1x
	local e1y = p2y - p1y
	local e2x = p0x - p2x
	local e2y = p0y - p2y
	local v0x = px - p0x
	local v0y = py - p0y
	local v1x = px - p1x
	local v1y = py - p1y
	local v2x = px - p2x
	local v2y = py - p2y
	local dpv0 = (v0x * e0x + v0y * e0y) / (e0x * e0x + e0y * e0y)
	local dpv1 = (v1x * e1x + v1y * e1y) / (e1x * e1x + e1y * e1y)
	local dpv2 = (v2x * e2x + v2y * e2y) / (e2x * e2x + e2y * e2y)
	local n0 = ((dpv0 < 1) and dpv0 or 1)
	local n1 = ((dpv1 < 1) and dpv1 or 1)
	local n2 = ((dpv2 < 1) and dpv2 or 1)
	local m0 = ((0 > n0) and 0 or n0)
	local m1 = ((0 > n1) and 0 or n1)
	local m2 = ((0 > n2) and 0 or n2)
	local pq0x = v0x - e0x * m0
	local pq0y = v0y - e0y * m0
	local pq1x = v1x - e1x * m1
	local pq1y = v1y - e1y * m1
	local pq2x = v2x - e2x * m2
	local pq2y = v2y - e2y * m2
	local s = e0x * e2y - e0y * e2x
	s = (s > 0) and 1 or (s < 0) and -1 or 0
	local d0x = pq0x * pq0x + pq0y * pq0y
	local d0y = s * (v0x * e0y - v0y * e0x)
	local d1x = pq1x * pq1x + pq1y * pq1y
	local d1y = s * (v1x * e1y - v1y * e1x)
	local d2x = pq2x * pq2x + pq2y * pq2y
	local d2y = s * (v2x * e2y - v2y * e2x)
	local tx = ((d0x < d1x) and d0x or d1x)
	local dx = ((tx < d2x) and tx or d2x)
	local ty = ((d0y < d1y) and d0y or d1y)
	local dy = ((ty < d2y) and ty or d2y)
	return -sqrt(dx) * ((dy > 0) and 1 or (dy < 0) and -1 or 0)
end

-- Quad (https://www.shadertoy.com/view/7dSGWK)
function sdQuad(px, py, p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y)
	local e0x = p1x - p0x
	local e0y = p1y - p0y
	local e1x = p2x - p1x
	local e1y = p2y - p1y
	local e2x = p3x - p2x
	local e2y = p3y - p2y
	local e3x = p0x - p3x
	local e3y = p0y - p3y
	local v0x = px - p0x
	local v0y = py - p0y
	local v1x = px - p1x
	local v1y = py - p1y
	local v2x = px - p2x
	local v2y = py - p2y
	local v3x = px - p3x
	local v3y = py - p3y
	local c0 = (v0x * e0x + v0y * e0y) / (e0x * e0x + e0y * e0y)
	local c1 = (v1x * e1x + v1y * e1y) / (e1x * e1x + e1y * e1y)
	local c2 = (v2x * e2x + v2y * e2y) / (e2x * e2x + e2y * e2y)
	local c3 = (v3x * e3x + v3y * e3y) / (e3x * e3x + e3y * e3y)
	local g0 = ((c0 < 1) and c0 or 1)
	local g1 = ((c1 < 1) and c1 or 1)
	local g2 = ((c2 < 1) and c2 or 1)
	local g3 = ((c3 < 1) and c3 or 1)
	local m0 = ((0 > g0) and 0 or g0)
	local m1 = ((0 > g1) and 0 or g1)
	local m2 = ((0 > g2) and 0 or g2)
	local m3 = ((0 > g3) and 0 or g3)
	local pq0x = v0x - e0x * m0
	local pq0y = v0y - e0y * m0
	local pq1x = v1x - e1x * m1
	local pq1y = v1y - e1y * m1
	local pq2x = v2x - e2x * m2
	local pq2y = v2y - e2y * m2
	local pq3x = v3x - e3x * m3
	local pq3y = v3y - e3y * m3
	local d0x = pq0x * pq0x + pq0y * pq0y
	local d0y = v0x * e0y - v0y * e0x
	local d1x = pq1x * pq1x + pq1y * pq1y
	local d1y = v1x * e1y - v1y * e1x
	local d2x = pq2x * pq2x + pq2y * pq2y
	local d2y = v2x * e2y - v2y * e2x
	local d3x = pq3x * pq3x + pq3y * pq3y
	local d3y = v3x * e3y - v3y * e3x
	local dxa = ((d0x < d1x) and d0x or d1x)
	local dxb = ((d2x < d3x) and d2x or d3x)
	local dx = ((dxa < dxb) and dxa or dxb)
	
	if d0y>0 and d1y>0 and d2y>0 and d3y>0 then
		return -sqrt(dx)
	else
		return sqrt(dx)
	end
end

-- Uneven Capsule (https://www.shadertoy.com/view/4lcBWn)
function sdUnevenCapsule(px, py, r1, r2, h ) -- r1:radius1, r2:radius2, h:distance between r1,r2
	px = ((px >= 0) and px or -px)
	local b = (r1 - r2) / h
	local a = sqrt(1.0 - b * b)
	local k = (-b * px) + (a * py)
	local lp = sqrt(px * px + py * py)
	if k < 0.0 then
		return lp - r1
	end
	if k > a * h then
		local pyh = py - h
		return sqrt(px * px + pyh * pyh) - r2
	end
	return (a * px) + (b * py) - r1
end

-- Simple Egg (https://www.shadertoy.com/view/Wdjfz3)
function sdEgg(px, py, ra, rb)	
	px = ((px >= 0) and px or -px)
	local r = ra - rb
	local p2
	if py < 0.0 then
		return sqrt(px * px + py * py) - r - rb
	else
		p2 = px + r
		if 1.73205 * p2 < py then
			local p1 = py - 1.73205 * r
			return sqrt(px * px + p1 * p1) - rb
		else
			return sqrt(p2 * p2 + py * py) - 2.0 * r - rb
		end
	end
end

-- Pie (https://www.shadertoy.com/view/3l23RK)
function sdPie(px, py, cx, cy, r ) -- c:sin/cos of aperture, r:radius	
	px = ((px >= 0) and px or -px)
	local l = sqrt(px * px + py * py) - r
	local d = px * cx + py * cy
	local mdr = ((d < r) and d or r)
	local cd = ((0 > mdr) and 0 or mdr)
	local m0 = px - cx * cd
	local m1 = py - cy * cd
	local m = sqrt(m0 * m0 + m1 * m1)
	local cr = cy * px - cx * py
	local m2 = m * (cr > 0 and 1 or cr < 0 and -1 or 0)
	return ((l > m2) and l or m2)
end

-- Cut Disk (https://www.shadertoy.com/view/ftVXRc)
function sdCutDisk(px, py, r, h) -- r:radius, h:dist from centre (pos/neg)
	local w = sqrt(r * r - h * h)
	px = ((px >= 0) and px or -px)
	local pxx = px * px
	local pyy = py * py
	local s0 = (h - r) * pxx + w * w * (h + r - 2.0 * py)
	local s1 = h * px - w * py
	local s = ((s0 > s1) and s0 or s1)
	if s < 0.0 then
		return sqrt(pxx + pyy) - r
	elseif px < w then
		return h - py
	else
		local dx = px - w
		local dy = py - h
		return sqrt(dx * dx + dy * dy)
	end
end

-- Moon (https://www.shadertoy.com/view/WtdBRS)
function sdMoon(px, py, d, ra, rb) -- d:distance between circles, ra:radius1, rb:radius2
	py = ((py >= 0) and py or -py)
	local a = (ra * ra - rb * rb + d * d) / (2.0 * d)
	local m0 = ra * ra - a * a
	local b = sqrt(((m0 > 0) and m0 or 0))
	local m1 = b - py
	if d * (px * b - py * a) > d * d * ((m1 > 0) and m1 or 0) then
		local pxa = px - a
		local pyb = py - b
		return sqrt(pxa * pxa + pyb * pyb)
	end	
	local l1 = sqrt(px * px + py * py)
	local pdx = px - d
	local l2 = sqrt(pdx * pdx + py * py)
	local m2 = l1 - ra
	local m3 = -(l2 - rb)
	return ((m2 > m3) and m2 or m3)
end

-- Vesica (https://www.shadertoy.com/view/XtVfRW)
function sdVesica(px, py, r, d) -- d<r
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local b = sqrt(r*r - d*d)
	if (py - b) * d > px * b then
		local dy = py - b
		return sqrt(px * px + dy * dy) * (d > 0 and 1 or d < 0 and -1 or 0)
	else
		local dx = px + d
		return sqrt(dx * dx + py * py) - r
	end
end

-- Oriented Vesica (https://www.shadertoy.com/view/cs2yzG)
function sdOrientedVesica(px, py, ax, ay, bx, by, w)
	local dx = bx - ax
	local dy = by - ay
	local r = 0.5 * sqrt(dx * dx + dy * dy)
	local d = 0.5 * (r * r - w * w) / w
	local vx = dx / r
	local vy = dy / r
	local cx = 0.5 * (bx + ax)
	local cy = 0.5 * (by + ay)
	local qx = px - cx
	local qy = py - cy
	local m0 = vy * qx + vx * qy
	local m1 = -vx * qx + vy * qy
	local mqx = 0.5 * ((m0 >= 0) and m0 or -m0)
	local mqy = 0.5 * ((m1 >= 0) and m1 or -m1)
	local hx, hy, hz
	if r * mqx < d * (mqy - r) then
		hx = 0.0
		hy = r
		hz = 0.0
	else
		hx = -d
		hy = 0.0
		hz = d + w
	end
	local dx_h = mqx - hx
	local dy_h = mqy - hy
	return sqrt(dx_h * dx_h + dy_h * dy_h) - hz
end

-- Tunnel (https://www.shadertoy.com/view/flSSDy)
function sdTunnel(px, py, whx, why )
	px = ((px >= 0) and px or -px)
	py = -py
	local qx = px - whx
	local qy = py - why
	local m0 = ((qx > 0) and qx or 0)
	local d1 = m0 * m0 + qy * qy
	local l = sqrt(px * px + py * py)
	qx = (py > 0.0) and qx or (l - whx)
	local m1 = ((qy > 0) and qy or 0)
	local d2 = qx * qx + m1 * m1
	local d = sqrt(((d1 < d2) and d1 or d2))
	return (((qx > qy) and qx or qy) < 0.0) and -d or d
end

-- Arc (https://www.shadertoy.com/view/wl23RK)
function sdArc(px, py, scx, scy, ra, rb)
	px = ((px >= 0) and px or -px)
	if scy * px > scx * py then
		local dx = px - scx * ra
		local dy = py - scy * ra
		return sqrt(dx * dx + dy * dy) - rb
	else
		local l = sqrt(px * px + py * py)
		local lm = l - ra
		return ((lm >= 0) and lm or -lm) - rb
	end
end

-- Ring (https://www.shadertoy.com/view/DsccDH)
function sdRing(px, py, nx, ny, r, th) -- n:aperture e.g. math.cos(math.pi/2),math.sin(math.pi/2), r:radius, th:thickness
	px = ((px >= 0) and px or -px)
	local rx = nx * px + ny * py
	local ry = -ny * px + nx * py
	px = rx
	py = ry
	local l = sqrt(px * px + py * py)
	local lr = l - r
	local d1 = ((lr >= 0) and lr or -lr) - th * 0.5
	local rp = r - py
	local m0 = ((rp >= 0) and rp or -rp) - th * 0.5
	py = ((0 > m0) and 0 or m0)
	local d2 = sqrt(px * px + py * py) * (px > 0 and 1 or px < 0 and -1 or 0)	
	return ((d1 > d2) and d1 or d2)
end

-- Horseshoe (https://www.shadertoy.com/view/WlSGW1)
function sdHorseshoe(px, py, cx, cy, r, le, th ) -- c:aperture, r:radius, le:length, th:thickness
	px = ((px >= 0) and px or -px)
	local l = sqrt(px * px + py * py)
	local tx = -cx * px + cy * py
	py = cy * px + cx * py
	px = tx
	if not (py > 0.0 or px > 0.0) then
		px = l * ((-cx > 0.0) and 1.0 or -1.0)
	end
	if px <= 0.0 then
		py = l
	end
	px = px - le
	local pr = py - r
	py = ((pr >= 0) and pr or -pr) - th
	local mx = ((px > 0) and px or 0)
	local my = ((py > 0) and py or 0)
	local lr = sqrt(mx * mx + my * my)
	local m0 = ((px > py) and px or py)
	local mr = ((0 < m0) and 0 or m0)
	return lr + mr
end

-- Parabola (https://www.shadertoy.com/view/ws3GD7)
function sdParabola(px, py, k)
	px = ((px >= 0) and px or -px)
	local ik = 1.0 / k
	local p = ik * (py - 0.5 * ik) / 3.0
	local q = 0.25 * ik * ik * px
	local h = q * q - p * p * p
	local r = sqrt(((h >= 0) and h or -h))
	local x
	if h > 0 then
		local m = q - r
		x = pow(q + r, 1/3) + pow(((m >= 0) and m or -m), 1/3) * (p > 0 and 1 or p < 0 and -1 or 0)
	else
		x = 2.0 * cos(atan(r, q) / 3.0) * sqrt(p)
	end
	local dx = px - x
	local dy = py - (k * x * x)
	local d = sqrt(dx * dx + dy * dy)
	return (px < x) and -d or d
end

-- Cross (https://www.shadertoy.com/view/XtGfzw)
function sdCross(px, py, bx, by, r) 
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	if py > px then px,py = py,px end
	local qx = px - bx
	local qy = py - by
	local k = ((qx > qy) and qx or qy)
	local wx, wy
	if k > 0 then
		wx = qx
		wy = qy
	else
		wx = by - px
		wy = -k
	end
	local m1 = ((wx > 0) and wx or 0)
	local m2 = ((wy > 0) and wy or 0)
	local d = sqrt(m1 * m1 + m2 * m2)
	return (k > 0 and d or -d) + r
end

-- Rounded X (https://www.shadertoy.com/view/3dKSDc)
function sdRoundedX(px, py, w, r) -- w:arm length, r:radius/width of arm eg 12, 4
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local m0 = px + py
	local m = ((m0 < w) and m0 or w) * 0.5
	local dx = px - m
	local dy = py - m
	return sqrt(dx * dx + dy * dy) - r
end

-- Ellipse (https://www.shadertoy.com/view/tt3yz7)
function sdEllipse(px, py, ex, ey)
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local eiX = 1.0 / ex
	local eiY = 1.0 / ey
	local e2X = ex * ex
	local e2Y = ey * ey
	local veX = eiX * (e2X - e2Y)
	local veY = eiY * (e2Y - e2X)
	local tX = 0.70710678118654752
	local tY = 0.70710678118654752
	for i = 1, 3 do
		local vX = veX * tX * tX * tX
		local vY = veY * tY * tY * tY
		local tmx = px - vX
		local tmy = py - vY
		local n = sqrt(tmx * tmx + tmy * tmy)		
		local s0 = tX * ex - vX
		local s1 = tY * ey - vY
		local s = sqrt(s0 * s0 + s1 * s1)
		local uX = (tmx / n) * s
		local uY = (tmy / n) * s
		local wX = eiX * (vX + uX)
		local wY = eiY * (vY + uY)		
		local m0 = ((wX < 1) and wX or 1)
		local m1 = ((wY < 1) and wY or 1)
		local cx = ((0 > m0) and 0 or m0)
		local cy = ((0 > m1) and 0 or m1)
		n = sqrt(cx * cx + cy * cy)
		tX = cx / n
		tY = cy / n
	end	
	local nx = tX * ex
	local ny = tY * ey
	local dx = px - nx
	local dy = py - ny
	local d = sqrt(dx * dx + dy * dy)
	local dp = px * px + py * py
	local n = nx * nx + ny * ny
	return dp < n and -d or d
end

-- Star 5 (https://www.shadertoy.com/view/3tSGDy)
function sdStar5(px, py, r, rf)
	local kx = 0.809016994375
	local ky = -0.587785252292
	px = ((px >= 0) and px or -px)
	local m1 = kx * px + ky * py
	local f1 = ((m1 > 0) and m1 or 0) * 2.0
	px = px - kx * f1
	py = py - ky * f1
	local m2 = -kx * px + ky * py
	local f2 = ((m2 > 0) and m2 or 0) * 2.0
	px = px - (-kx * f2)
	px = ((px >= 0) and px or -px)
	py = py - (ky * f2) - r
	local bax = -ky * rf
	local bay = kx * rf - 1.0
	local m3 = (px * bax + py * bay) / (bax * bax + bay * bay)
	local m4 = ((m3 < r) and m3 or r)
	local h = ((0 > m4) and 0 or m4)
	local s = py * bax - px * bay
	local dx = px - bax * h
	local dy = py - bay * h
	return sqrt(dx * dx + dy * dy) * (s > 0 and 1 or s < 0 and -1 or 0)
end

-- Hexagram (https://www.shadertoy.com/view/tt23RR)
function sdHexagram(px, py, r)
	local kx = -0.5
	local ky = 0.8660254038
	local kz = 0.5773502692
	local kw = 1.7320508076
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local d1 = kx * px + ky * py
	local dd1 = 2.0 * ((d1 < 0) and d1 or 0)
	px -= dd1 * kx
	py -= dd1 * ky
	local d2 = ky * px + kx * py
	local dd2 = 2.0 * ((d2 < 0) and d2 or 0)
	px -= dd2 * ky
	py -= dd2 * kx	
	local m = r * kw
	local mm = ((px < m) and px or m)
	local n = r * kz
	px -= ((n > mm) and n or mm)
	py -= r
	return sqrt(px * px + py * py) * (py > 0 and 1 or py < 0 and -1 or 0)
end

-- Regular Pentagon (https://www.shadertoy.com/view/llVyWW)
function sdPentagon(px, py, r) -- r:apothem
	local kx = 0.809016994  -- cos pi/5
	local ky = 0.587785252  -- sin pi/5
	local kz = 0.726542528  -- tan pi/5
	px = ((px >= 0) and px or -px)
	local d1 = -kx * px + ky * py
	local ad = 2.0 * ((d1 < 0) and d1 or 0)
	local ax = ad * -kx
	local ay = ad * ky
	px = px - ax
	py = py - ay
	local d2 = kx * px + ky * py
	local bd = 2.0 * ((d2 < 0) and d2 or 0)
	local bx = bd * kx
	local by = bd * ky
	px = px - bx
	py = py - by
	local m = r * kz
	local n = ((px < m) and px or m)
	px = px - ((-m > n) and -m or n)
	py = py - r
	return sqrt(px * px + py * py) * ((py > 0) and 1 or (py < 0) and -1 or 0)
end

-- Regular Hexagon (https://www.shadertoy.com/view/fd3SRf)
function sdHexagon(px, py, s) -- s:apothem
	local kx = -0.866025404 -- cos(60 degrees)
	local ky = 0.5          -- sin(60 degrees)
	local kz = 0.577350269  -- 1/cos(60 degrees)
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local kxyp = (kx * px + ky * py)
	local pp = ((kxyp < 0) and kxyp or 0) * 2.0
	px = px - kx * pp
	py = py - ky * pp
	local kzs = kz * s
	local m = ((px < kzs) and px or kzs)
	px = px - ((-kzs > m) and -kzs or m)
	py = py - s
	return sqrt(px * px + py * py) * ((py > 0 and 1) or (py <= 0 and -1))
end

-- Regular Octagon (https://www.shadertoy.com/view/llGfDG)
function sdOctagon( px, py, r ) -- r:apothem
	local kx = -0.9238795325
	local ky = 0.3826834323
	local kz = 0.4142135623
	px = ((px >= 0) and px or -px)
	py = ((py >= 0) and py or -py)
	local d1 = kx * px + ky * py
	local m1 = 2.0 * ((d1 < 0) and d1 or 0)
	local ax = m1 * kx
	local ay = m1 * ky
	px = px - ax
	py = py - ay
	local d2 = -kx * px + ky * py  -- Use updated px, py from first adjustment
	local m2 = 2.0 * ((d2 < 0) and d2 or 0)
	local bx = m2 * (-kx)
	local by = m2 * ky
	px = px - bx
	py = py - by
	local kzr = kz * r
	local m = ((px < kzr) and px or kzr)
	px = px - ((-kzr > m) and -kzr or m)
	py = py - r
	return sqrt(px * px + py * py) * (py > 0 and 1 or py < 0 and -1 or 0)
end

-- Regular Polygon (https://www.shadertoy.com/view/7tSXzt)
function sdRegularPolygon(px, py, r, n )
	local an = 3.1415926535/n
	local acsx = cos(an) -- you can pre-calc this outside the function for speed
	local acsy = sin(an) -- you can pre-calc this outside the function for speed
	local bn = (atan(py, px) % (2.0 * an)) - an 
	local pmag = sqrt(px*px+py*py)
	px = cos(bn) * pmag
	local sbn = sin(bn)
	py = ((sbn >= 0) and sbn or -sbn) * pmag
	px -= acsx*r
	py -= acsy*r
	local ar = acsy * r
	local m = ((-py < ar) and -py or ar)
	py += ((0 > m) and 0 or m)
	return sqrt(px*px+py*py) * (px > 0 and 1 or px < 0 and -1 or 0)
end

-- Polygon (https://www.shadertoy.com/view/wdBXRW)
function sdPolygon(px, py, vx, vy, n)
	local d = (px - vx[1]) * (px - vx[1]) + (py - vy[1]) * (py - vy[1])
	local s = 1.0
	local j = n
	for i = 1, n do
		local ex = vx[j] - vx[i]
		local ey = vy[j] - vy[i]
		local wx = px - vx[i]
		local wy = py - vy[i]
		local pr = (wx * ex + wy * ey) / (ex * ex + ey * ey)
		local m = ((pr < 1) and pr or 1)
		pr = ((0 > m) and 0 or m)
		local bx = wx - ex * pr
		local by = wy - ey * pr
		local d0 = bx * bx + by * by
		d = ((d < d0) and d or d0)
		local c1 = (py >= vy[i])
		local c2 = (py < vy[j])
		local c3 = (ex * wy > ey * wx)
		if (c1 and c2 and c3) or (not c1 and not c2 and not c3) then
			s = -s
		end
		j = i
	end
	return s * sqrt(d)
end
