local vec2 = playdate.geometry.vector2D.new

local sin = math.sin
local cos = math.cos
local abs = math.abs
local max = math.max
local min = math.min
local sqrt = math.sqrt

function sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end

--function clamp(value, min, max) return math.max(math.min(value, max), min) end

function clamp(value, minval, maxval)
	if value < minval then return minval
	elseif value > maxval then return maxval
	else return value end
end

function apply1(a,f) return vec2(f(a.x),f(a.y)) end

function apply2(a,b,f) return vec2(f(a.x,b.x),f(a.y,b.y))end

--function vecMin2D(a,b) return apply2(a,b,min) end
function vecMin2D(a,b) return vec2(min(a.x,b.x),min(a.y,b.y)) end

--function vecMax2D(a,b) return apply2(a,b,max) end
function vecMax2D(a,b) return vec2(max(a.x,b.x),max(a.y,b.y)) end

--function vecAbs2D(a) return apply1(a,abs) end
function vecAbs2D(a) return vec2(abs(a.x),abs(a.y)) end

--function vecHadamard2D(a,b) return apply2(a,b,function(x,y) return x*y end) end
function vecHadamard2D(a,b) return vec2(a.x*b.x,a.y*b.y) end

--function vecHadamardDiv2D(a,b) return apply2(a,b,function(x,y) return x/y end) end
function vecHadamardDiv2D(a,b) return vec2(a.x/b.x,a.y/b.y) end

function vecCrossProduct2D(v1, v2) return v1.x * v2.y - v1.y * v2.x end

function vecNDot2D(a, b) return a.x * b.x - a.y * b.y end

function vec2mat2mul(m, q) return vec2(m[1]*q.x + m[3]*q.y, m[2]*q.x + m[4]*q.y) end

function opOnion(p, f, params, r) return abs(f(p, table.unpack(params))) - r end

function opRound(p, f, params, r ) return f(p, table.unpack(params)) - r end

--[[
Calculate a normalized gradient from nearby points to find the direction of the
shortest path to the surface. We compute the gradient vector, and then normalize
the magnitude to remove local variations of the slope. This approach provides a 
directionally accurate vector for collision responses or for guiding movements.
]]
function calcNormalizedGradient(p, f, o, params) -- p:point, o:offset, f:sdf, params:params to sdf
	local eps = 1e-4
	local ds = {f(vec2(p.x + eps, p.y)-o, table.unpack(params)),
				f(vec2(p.x - eps, p.y)-o, table.unpack(params)),
				f(vec2(p.x, p.y + eps)-o, table.unpack(params)),
				f(vec2(p.x, p.y - eps)-o, table.unpack(params))}
	return vec2((ds[1]-ds[2])/(2*eps), (ds[3]-ds[4])/(2*eps)):normalized()
end
