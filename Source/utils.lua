function sign(x) return x > 0 and 1 or x < 0 and -1 or 0 end

function clamp(value, min, max) return math.max(math.min(value, max), min) end

function apply1(a,f) return geo.vector2D.new(f(a.x),f(a.y)) end

function apply2(a,b,f) return geo.vector2D.new(f(a.x,b.x),f(a.y,b.y))end

function vecMin2D(a,b) return apply2(a,b,math.min) end

function vecMax2D(a,b) return apply2(a,b,math.max) end

function vecAbs2D(a) return apply1(a,math.abs) end

function vecHadamard2D(a,b) return apply2(a,b,function(x,y) return x*y end) end

function vecCrossProduct2D(v1, v2) return v1.x * v2.y - v1.y * v2.x end

function vecNDot2D(a, b) return a.x * b.x - a.y * b.y end

function vec2mat2mul(m, q) return vec2(m[1]*q.x + m[3]*q.y, m[2]*q.x + m[4]*q.y) end

function opOnion(p, f, params, r) return math.abs(f(p, table.unpack(params))) - r end

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
