-- Demo of finding the intersection between a line segment and an ellipse or circle
-- MIT license. Credit @robga https://github.com/pdstuff/PlaydateSDF

import "CoreLibs/graphics"
import "Source/Lua/SDF2D.lua" -- Ensure you have put this file in the right location

local x1, y1, x2, y2 = 10, 50, 100, 140 -- line segment
local ex, ey, ew, eh = 160, 120, 120, 70 -- ellipse; x y at centre
local cx, cy, cr = 300, 120, 50 -- circle
local intr, ints = 6, 100 -- for drawing: intersection radius and reflected scale

-- Reflects one vector across another
function reflectVector(dx, dy, nx, ny)
	local dot_product = dx * nx + dy * ny
	local rx = dx - 2 * dot_product * nx
	local ry = dy - 2 * dot_product * ny
	return rx, ry
end

-- Reflects a line segment across a vector at scale
function reflectSegment(x1, y1, x2, y2, nx, ny, scale)
	local rx, ry = reflectVector(x2-x1, y2-y1, nx, ny)
	return x1 + scale * rx, y1 + scale * ry
end

-- Normal at x, y of an ellipse with dimensions w, h
function ellipseNormal(x, y, w, h)
	local w2, h2 = w * w, h * h
	local nx, ny = x / w2, y / h2
	local l = math.sqrt(nx * nx + ny * ny)
	return nx / l, ny / l
end

function drawEllipseIntersectionAndReflection(x1, y1, x2, y2, ex, ey, ew, eh, xi, yi)
	if xi == nil then return end
	playdate.graphics.fillCircleAtPoint(xi, yi, intr)
	local nx, ny = ellipseNormal(xi-ex, yi-ey, ew/2, eh/2)		
	if (x2-x1)*nx + (y2-y1)*ny < 0 then -- checks outside not inside
		local tx, ty = reflectSegment(x1, y1, x2, y2, nx, ny, ints)
		playdate.graphics.drawLine(xi, yi, tx, ty)
	end
end	

function drawCircleIntersectionAndReflection(x1, y1, x2, y2, cx, cy, cr, xi, yi)
	if xi == nil then return end
	playdate.graphics.fillCircleAtPoint(xi, yi, intr)
	local nx, ny, _ = grCircle(xi-cx, yi-cy, cr)
	if (x2-x1)*nx + (y2-y1)*ny < 0 then -- checks outside not inside
		local tx, ty = reflectSegment(x1, y1, x2, y2, nx, ny, ints)
		playdate.graphics.drawLine(xi, yi, tx, ty)
	end
end
	
function drawScene()
	playdate.graphics.drawEllipseInRect(ex-ew/2, ey-eh/2, ew, eh)	
	playdate.graphics.drawCircleAtPoint(cx,cy,cr)
	playdate.graphics.drawLine(x1, y1, x2, y2)
end

function drawIntersections()
	local int1x, int1y, int2x, int2y = iSegmentEllipse2D(x1, y1, x2, y2, ex, ey, ew, eh)
	drawEllipseIntersectionAndReflection(x1, y1, x2, y2, ex, ey, ew, eh, int1x, int1y)
	drawEllipseIntersectionAndReflection(x1, y1, x2, y2, ex, ey, ew, eh, int2x, int2y)
	local int1x, int1y, int2x, int2y = iSegmentCircle2D(x1, y1, x2, y2, cx, cy, cr)
	drawCircleIntersectionAndReflection(x1, y1, x2, y2, cx, cy, cr, int1x, int1y)
	drawCircleIntersectionAndReflection(x1, y1, x2, y2, cx, cy, cr, int2x, int2y)
end

function playdate.update()
	playdate.graphics.clear()
	drawScene()	
	drawIntersections()
	x1+=2; x2+=1;
end