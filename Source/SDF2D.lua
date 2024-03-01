-- The SDF's in this library are ports of the GLSL functions
-- available at https://iquilezles.org/articles/distfunctions2d/

import "CoreLibs/object"
import "utils.lua"

pd = playdate
geo	= pd.geometry
vec2 = geo.vector2D.new

-- Circle (https://www.shadertoy.com/view/3ltSW2)
function sdCircle(p, r)
	return p:magnitude() - r
end

-- Rounded Box (https://www.shadertoy.com/view/4llXD7 
function sdRoundedBox(p, b, r) -- b:vec2(w,h), r:{tr,br,tl,bl}
	if p.x <= 0 then r[1], r[2] = r[3], r[4] end
	if p.y <= 0 then r[1] = r[2] end
	local q = vec2(math.abs(p.x)-b.x+r[1],math.abs(p.y)-b.y+r[1])
	return vec2(math.max(q.x,0),math.max(q.y,0)):magnitude() + math.min(math.max(q.x,q.y),0.0) - r[1]
end

-- Box (https://www.youtube.com/watch?v=62-pRVZuS5c)
function sdBox(p, b)
	local d = vecAbs2D(p) - b
	local od = vec2(math.max(d.x, 0), math.max(d.y, 0)):magnitude()
	local id = math.min(math.max(d.x, d.y), 0)
	return od + id
end
	
-- Oriented Box (https://www.shadertoy.com/view/stcfzn)
function sdOrientedBox(p, a, b, th) -- a:vec(startxy), b:vec(endxy), th:thickness
	
	local l = (b-a):magnitude()
	local d = (b-a) / l
	local q = p - (a + b) * 0.5
	q = vec2mat2mul({d.x,-d.y,d.y,d.x},q)
	q = vecAbs2D(q) - vec2(l*0.5, th)
	local maxQ = vec2(math.max(q.x, 0), math.max(q.y, 0))	
	return maxQ:magnitude() + math.min(math.max(q.x, q.y), 0.0)
end

-- Segment (https://www.shadertoy.com/view/3tdSDj
function sdSegment(p, a, b)

	local pa = p - a
	local ba = b - a
	local h = math.max(0, math.min(1, pa:dotProduct(ba) / ba:dotProduct(ba)))
	return (pa - ba * h):magnitude()

end

-- Rhombus - exact   (https://www.shadertoy.com/view/XdXcRB)
function sdRhombus(p, b)

	p = vecAbs2D(p)
	local h = clamp(vecNDot2D(b - p*2, b) / (b:dotProduct(b)), -1.0, 1.0)
	local d_vec = p - vecHadamard2D((b * 0.5),vec2(1.0 - h, 1.0 + h))

	return d_vec:magnitude() * sign(p.x * b.y + p.y * b.x - b.x * b.y)

end

-- Isosceles Trapezoid (https://www.shadertoy.com/view/MlycD3)
function sdTrapezoid(p, r1, r2, he) -- r1:base width,  r2:cap width, he:height
	local k1 = vec2(r2,he)
	local k2 = vec2(r2-r1,2.0*he)
	p.x = math.abs(p.x)
	local ca = vec2(p.x - math.min(p.x, (p.y < 0.0) and r1 or r2), math.abs(p.y) - he)
	local cb = p - k1 + k2*clamp( (k2*(k1-p))/(k2*k2), 0.0, 1.0 )
	local s = (cb.x < 0.0 and ca.y < 0.0) and -1.0 or 1.0
	return s*math.sqrt( math.min(ca*ca,cb*cb) )
end

-- Parallelogram (https://www.shadertoy.com/view/7dlGRf)
function sdParallelogram(p, wi, he, sk ) -- width, height, skew
	local e = vec2(sk,he)
	if p.y <0 then
		p = -p
	end
	local w = p - e 
	w.x -= clamp(w.x,-wi,wi)
	local d = vec2(w*w, -w.y)
	local s = p.x*e.y - p.y*e.x
	if s < 0 then
		p = -p
	end
	local v = p - vec2(wi,0) 
	v -= e*clamp((v*e)/(e*e),-1.0,1.0)
	d = vecMin2D(d, vec2(v*v, wi*he-math.abs(s)))
	return math.sqrt(d.x)*sign(-d.y)
end

-- Equilateral Triangle (https://www.shadertoy.com/view/Xl2yDW)
function sdEquilateralTriangle( p, r )
	local k = 1.73205
	p.x = math.abs(p.x) - r
	p.y = p.y + r/k
	if( p.x+k*p.y>0.0 ) then
		p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0
	end
	p.x -= clamp( p.x, -2.0*r, 0.0 )
	return p:magnitude()*sign(p.y)*-1
end

-- Isosceles Triangle (https://www.shadertoy.com/view/MldcD7)
function sdTriangleIsosceles(p, q)
	
	p.x = math.abs(p.x)
	local a = p - q * clamp((p*q)/(q*q), 0.0, 1.0)	
	local b1 =  vec2(clamp(p.x/q.x, 0.0, 1.0), 1.0)
	local b = p - vecHadamard2D(q,b1)
	local k = sign(q.y)
	local d = math.min(a*a,b*b)
	local s = math.max( k*(vecCrossProduct2D(p,q)),k*(p.y-q.y)  )
	
	return math.sqrt(d)*sign(s)
	
end

-- Triangle (https://www.shadertoy.com/view/XsXSz4)
function sdTriangle(p, p0, p1, p2) -- vertices

	local e0, e1, e2 = p1 - p0, p2 - p1, p0 - p2
	local v0, v1, v2 = p - p0, p - p1, p - p2

	local pq0 = v0 - e0 * clamp((v0 * e0) / (e0 * e0), 0.0, 1.0)
	local pq1 = v1 - e1 * clamp((v1 * e1) / (e1 * e1), 0.0, 1.0)
	local pq2 = v2 - e2 * clamp((v2 * e2) / (e2 * e2), 0.0, 1.0)

	local s = sign(vecCrossProduct2D(e0,e2))

	local d0 = vec2( pq0 * pq0, s*vecCrossProduct2D(v0,e0))
	local d1 = vec2( pq1 * pq1, s*vecCrossProduct2D(v1,e1))
	local d2 = vec2( pq2 * pq2, s*vecCrossProduct2D(v2,e2))

	local d = vecMin2D( vecMin2D( d0, d1), d2)

	return -math.sqrt(d.x)*sign(d.y)

end

-- Uneven Capsule (https://www.shadertoy.com/view/4lcBWn)
function sdUnevenCapsule(p, r1, r2, h ) -- r1:radius1, r2:radius2, h:distance between r1,r2
	p.x = math.abs(p.x)
	local b = (r1-r2)/h
	local a = math.sqrt(1.0-b*b)
	local k = p * vec2(-b,a)
	if k < 0 then
		return p:magnitude() - r1
	end
	if k > a*h then
		return (p-vec2(0.0,h)):magnitude() - r2
	end
	return p * vec2(a,b) - r1
end

-- Regular Pentagon (https://www.shadertoy.com/view/llVyWW)
function sdPentagon(p, r) -- r:apothem

	local k = {x = 0.809016994, y = 0.587785252, z = 0.726542528} -- pi/5: cos, sin, tan
	
	p.y = -p.y
	p.x = math.abs(p.x)
	
	local k1 = vec2(-k.x, k.y)
	p -= k1 * math.min(k1*p, 0.0) * 2.0
	local k2 = vec2(k.x, k.y)
	p -= k2 * math.min(k2*p, 0.0) * 2.0
	p -= vec2(clamp(p.x, -r * k.z, r * k.z), r)

	return p:magnitude() * sign(p.y)

end

-- Regular Hexagon
function sdHexagon(p, s) -- r:apothem
	
	local kxy = vec2(-0.866025404, 0.5)
	local kz = 0.577350269
	p = vecAbs2D(p)
	p -= kxy * math.min(kxy * p, 0.0) * 2.0
	p -= vec2(clamp(p.x, -kz*s, kz*s), s)

	return p:magnitude()*sign(p.y)

end

-- Regular Octagon (https://www.shadertoy.com/view/llGfDG)
function sdOctagon( p, r ) -- r:apothem
	local kx, ky, kz = -0.9238795325, 0.3826834323, 0.4142135623
	p = vecAbs2D(p)
	p -= vec2( kx,ky) * 2.0*math.min(vec2( kx,ky) * p,0.0)
	p -= vec2(-kx,ky) * 2.0*math.min(vec2(-kx,ky) * p,0.0)
	p -= vec2(clamp(p.x, -kz*r, kz*r), r)
	return p:magnitude()*sign(p.y)
end

-- Hexagram (https://www.shadertoy.com/view/tt23RR)
function sdHexagram(p, r)
	local kx, ky, kz, kw = -0.5, 0.8660254038, 0.5773502692, 1.7320508076
	p = vecAbs2D(p)
	p -= vec2(kx, ky)*2.0*math.min(vec2(kx,ky)*p,0.0)
	p -= vec2(ky, kx)*2.0*math.min(vec2(ky,kx)*p,0.0)
	p -= vec2(clamp(p.x,r*kz,r*kw),r)
	return p:magnitude()*sign(p.y)
end

-- Star 5 (https://www.shadertoy.com/view/3tSGDy)
function sdStar5(p, r, rf)
	local k1 = vec2(0.809016994375, -0.587785252292)
	local k2 = vec2(-k1.x,k1.y)
	p.x = math.abs(p.x)
	p -= k1*2.0*math.max(k1*p,0.0)
	p -= k2*2.0*math.max(k2*p,0.0)
	p.x = math.abs(p.x)
	p.y -= r
	local ba = vec2(-k1.y,k1.x)*rf - vec2(0,1)
	local h = clamp( (p*ba)/(ba*ba), 0.0, r )
	return (p-ba*h):magnitude() * sign(p.y*ba.x-p.x*ba.y)
end

-- Regular Star (https://www.shadertoy.com/view/3tSGDy)

-- Pie (https://www.shadertoy.com/view/3l23RK)
function sdPie(p, c, r ) -- c:sin/cos of aperture, r:radius
	p.x = math.abs(p.x)
	local l = p:magnitude() - r
	local m = (p-c*clamp(p*c,0.0,r)):magnitude()
	return math.max(l,m*sign(c.y*p.x-c.x*p.y))
end

-- Cut Disk (https://www.shadertoy.com/view/ftVXRc)
function sdCutDisk(p, r, h) -- r:radius, h:dist from centre (pos/neg)
	local w = math.sqrt(r*r-h*h) -- constant for any given shape
	p.x = math.abs(p.x)
	local s = math.max( (h-r)*p.x*p.x+w*w*(h+r-2.0*p.y), h*p.x-w*p.y )
	
	if s < 0 then
		return p:magnitude()-r
	elseif (p.x<w) then
		return h - p.y
	else
		return (p-vec2(w,h)):magnitude()
	end
end

-- Arc (https://www.shadertoy.com/view/wl23RK)
function sdArc(p, sc, ra, rb) -- ra:radius, rb:width, sc:vec2(math.sin(rad),math.cos(rad))
	p.x = math.abs(p.x)
	return (sc.y * p.x > sc.x * p.y) and (p - sc * ra):magnitude() or math.abs(p:magnitude() - ra) - rb
end

-- Ring (https://www.shadertoy.com/view/DsccDH)
function sdRing(p, n, r, th) -- n:aperture e.g. math.cos(math.pi/2),math.sin(math.pi/2), r:radius, th:thickness

	p.x = math.abs(p.x)   
	p = vec2mat2mul({n.x,n.y,-n.y,n.x},p)
	return math.max( math.abs(p:magnitude()-r)-th*0.5,
				vec2(p.x,math.max(0.0,math.abs(r-p.y)-th*0.5)):magnitude()*sign(p.x))

end

-- Horseshoe (https://www.shadertoy.com/view/WlSGW1)
function sdHorseshoe(p, c, r, le, th ) -- c:aperture, r:radius, le:length, th:thickness

	p.x = math.abs(p.x)
	p.y = -p.y
	local l = p:magnitude()
	p = vec2mat2mul({-c.x, c.y, c.y, c.x}, p)
	p = vec2(((p.y > 0.0 or p.x > 0.0) and p.x or l * sign(-c.x)),(p.x > 0.0 and p.y or l))	
	p = vec2(p.x - le, math.abs(p.y - r) - th)
	local maxp = vec2(math.max(p.x,0),math.max(p.y,0))
	return maxp:magnitude() + math.min(0.0,math.max(p.x,p.y))

end

-- Vesica (https://www.shadertoy.com/view/XtVfRW)
function sdVesica(p, r, d) -- d<r
	p = vecAbs2D(p)
	local b = math.sqrt(r*r-d*d)
	if (p.y-b)*d > p.x*b then
		return (p-vec2(0.0,b)):magnitude()
	else
		return (p-vec2(-d,0.0)):magnitude()-r
	end
end

-- Oriented Vesica (https://www.shadertoy.com/view/cs2yzG)
function sdOrientedVesica(p, a, b, w)

	local r = 0.5*(b-a):magnitude()
	local d = 0.5*(r*r-w*w)/w
	local v = (b-a)/r
	local c = (b+a)*0.5
	local q = vecAbs2D(vec2mat2mul({v.y,v.x,-v.x,v.y}, p-c))*0.5
	local h = {}
	if (r*q.x<d*(q.y-r)) then
		h = {0.0,r,0.0}
	else
		h = {-d,0.0,d+w}
	end
	return (q-vec2(h[1], h[2])):magnitude() - h[3]

end


-- Moon (https://www.shadertoy.com/view/WtdBRS)
function sdMoon(p, d, ra, rb) -- d:distance between circles, ra:radius1, rb:radius2
		   
	p.y = math.abs(p.y)
	
	local a = (ra*ra - rb*rb + d*d) / (2.0*d)
	local b = math.sqrt(math.max(ra*ra - a*a, 0.0))

	if d * (p.x * b - p.y * a) > d*d * math.max(b - p.y, 0.0) then
		return (p - vec2(a, b)):magnitude()
	end

	local distToOuterCircle = (p:magnitude() - ra)
	local distToInnerCircle = -((p - vec2(d, 0)):magnitude() - rb)
	return math.max(distToOuterCircle, distToInnerCircle)

end

-- Simple Egg (https://www.shadertoy.com/view/XtVfRW)
-- Heart (https://www.shadertoy.com/view/3tyBzV)

-- Cross (https://www.shadertoy.com/view/XtGfzw)
function sdCross(p, b, r) 
	p = vecAbs2D(p)
	if p.y>p.x then
		p = vec2(p.y, p.x)
	end
	local q = p - b
	local k = math.max(q.y,q.x)
	local w
	if k>0 then
		w = q
	else
		w = vec2(b.y-p.x,-k)
	end	
	return sign(k)*vec2(math.max(w.x,0),math.max(w.y,0)):magnitude() + r
end

-- Rounded X (https://www.shadertoy.com/view/3dKSDc)
function sdRoundedX(p, w, r) -- w:arm length, r:radius/width of arm eg 12, 4
	p = vecAbs2D(p)
	local m = math.min(p.x+p.y,w)*0.5
	return vec2(p.x-m,p.y-m):magnitude() - r
end

-- Polygon (https://www.shadertoy.com/view/wdBXRW)
function sdPolygon(v, p)

	local N = #v
	local d = (p - v[1]):magnitudeSquared()
	local s = 1.0

	for i = 1, N do
		local j = (i % N) + 1
		local e = v[j] - v[i]
		local w = p - v[i]
		local b = w - (e * clamp((w * e) / e:magnitudeSquared(), 0.0, 1.0))
		d = math.min(d, b:magnitudeSquared())

		local c1 = p.y >= v[i].y
		local c2 = p.y < v[j].y
		local c3 = (e.x * w.y - e.y * w.x) > 0
		if (c1 and c2 and c3) or (not c1 and not c2 and not c3) then
			s = s * -1.0
		end
	end

	return s * math.sqrt(d)
	
end

-- Ellipse (https://www.shadertoy.com/view/tt3yz7)
function sdEllipse(p, e)

	local pAbs = vecAbs2D(p)
	local ei = vec2(1/e.x, 1/e.y)
	local e2 = vecHadamard2D(e, e) -- Component-wise multiplication
	local ve = vecHadamard2D(ei, vec2(e2.x - e2.y, e2.y - e2.x))
	local t = vec2(0.70710678118654752, 0.70710678118654752)

	for i = 1, 3 do
		local v = vecHadamard2D(ve, vecHadamard2D(t, vecHadamard2D(t, t)))
		local u = (pAbs - v):normalized() * ((vecHadamard2D(t, e) - v):magnitude())
		local w = vecHadamard2D(ei, (v + u))
		t = vec2(clamp(w.x, 0.0, 1.0), clamp(w.y, 0.0, 1.0)):normalized() --clamp??
	end
	
	local nearestAbs = vecHadamard2D(t, e)
	local dist = (pAbs - nearestAbs):magnitude()
	local inside = pAbs:dotProduct(pAbs) < nearestAbs:dotProduct(nearestAbs)
	
	return inside and -dist or dist

end

-- Parabola (https://www.shadertoy.com/view/ws3GD7)
function sdParabola(pos, k)
	
	pos.x = math.abs(pos.x)
	
	local ik = 1.0/k
	local p = ik*(pos.y - 0.5*ik)/3.0
	local q = 0.25*ik*ik*pos.x
	
	local h = q*q - p*p*p
	local r = math.sqrt(math.abs(h))

	local x
	if (h>0.0) then
		x = (q+r) ^ (1/3) + (math.abs(q-r) ^ (1/3)) * sign(p)
	else
		x = 2.0*math.cos(math.atan(r,q)/3.0)*math.sqrt(p)
	end
		
	local d = (pos-vec2(x,k*x*x)):magnitude()
	
	return (pos.x < x) and -d or d
	
end

-- Parabola Segment (https://www.shadertoy.com/view/3lSczz)
-- Quadratic Bezier (https://www.shadertoy.com/view/MlKcDD)
-- Bobbly Cross (https://www.shadertoy.com/view/NssXWM)

-- Tunnel (https://www.shadertoy.com/view/flSSDy)
function sdTunnel(p, wh )
	
	local q = vecAbs2D(p)
	q.x -= wh.x
	
	if p.y>=0.0 then
		q.x = math.max(q.x,0.0)
		q.y += wh.y
		return -math.min( wh.x-p:magnitude(), q:magnitude() )
	else
		q.y -= wh.y
		local f = math.max(q.x,q.y)
		if f < 0.0 then
			return f
		else
			return vec2(math.max(q.x,0),math.max(q.y,0)):magnitude()
		end
	end
	
end

-- Stairs (https://www.shadertoy.com/view/7tKSWt)
-- Quadratic Circle (https://www.shadertoy.com/view/Nd3cW8)
-- Hyperbola (https://www.shadertoy.com/view/DtjXDG)
-- Cool S (https://www.shadertoy.com/view/clVXWc)
-- Circle Wave (https://www.shadertoy.com/view/stGyzt)

-- Regular Polygon (https://www.shadertoy.com/view/7tSXzt)
function sdRegularPolygon(p, r, n )

	local an = math.pi/n
	local acs = vec2(math.cos(an),math.sin(an))
	local bn = (math.atan(p.y, p.x) % (2.0 * an)) - an 
	p = vec2(math.cos(bn),math.abs(math.sin(bn))) * p:magnitude()
	p -= acs*r
	p.y += clamp( -p.y, 0.0, acs.y*r)
	return p:magnitude() * sign(p.x)

end

-- Quad (https://www.shadertoy.com/view/7dSGWK)
function sdQuad(p, p0, p1, p2, p3)

	local e0, e1, e2, e3 = p1 - p0, p2 - p1, p3 - p2, p0 - p3
	local v0, v1, v2, v3 = p - p0, p - p1, p - p2, p - p3
	
	local pq0 = v0 - e0*clamp( (v0*e0)/(e0*e0), 0.0, 1.0 )
	local pq1 = v1 - e1*clamp( (v1*e1)/(e1*e1), 0.0, 1.0 )
	local pq2 = v2 - e2*clamp( (v2*e2)/(e2*e2), 0.0, 1.0 )
	local pq3 = v3 - e3*clamp( (v3*e3)/(e3*e3), 0.0, 1.0 )
	
	local ds = vecMin2D( vecMin2D( vec2( ( pq0*pq0 ), vecCrossProduct2D(v0,e0) ),
						vec2( ( pq1*pq1 ), vecCrossProduct2D(v1,e1) )),
						vecMin2D( vec2( ( pq2*pq2 ), vecCrossProduct2D(v2,e2) ),
						vec2( ( pq3*pq3 ), vecCrossProduct2D(v3,e3) ) ));

	local d = math.sqrt(ds.x)
	if ds.y > 0.0 then
		return -d
	else
		return d
	end
end
