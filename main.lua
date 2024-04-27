-- A benchmark of SDF functions on the playdate. Run it on device.
import "CoreLibs/object"
import "CoreLibs/graphics"
import "Source/Lua/SDF2D.lua" -- Ensure you have put this file in the right location

local pd = playdate
local gfx	= pd.graphics
local vec2 = playdate.geometry.vector2D.new
local fps = 10
playdate.display.setRefreshRate(fps)
local gridSize = 100

local testObjects = {
{sdCircle, 			"sdCircle", 		vec2(50,50), 	{50}},
{sdSegment,			"sdSegment",		vec2(0,0), 		{20,20,80,80}},
{sdSegmentLinf,		"sdSegmentLinf",		vec2(0,0), 		{20,20,80,80}},
{sdBox,				"sdBox",			vec2(50,50), 	{40,40}},
{sdBoxLinf,			"sdBoxLinf",			vec2(50,50), 	{40,40}},
{sdRoundedBox,		"sdRoundedBox", 	vec2(50,50),	{40,40, 0, 20, 0, 20}},
{sdOrientedBox, 	"sdOrientedBox", 	vec2(0,0), 		{20,20, 80,80, 20}},
{sdRoundSquare, 	"sdRoundSquare",	vec2(50,50),	{40, 20}},	
{sdRhombus,			"sdRhombus",		vec2(50,50), 	{50,40}},
{sdRhombusLinf,		"sdRhombusLinf",		vec2(50,50), 	{50,40}},
{sdTrapezoid,		"sdTrapezoid",		vec2(50,50),	{50, 30, 40}},
{sdParallelogram, 	"sdParallelogram", 	vec2(50,50), 	{40, 40, 10}},
{sdEquilateralTriangle, "sdEquilateralTriangle", 	vec2(50,50), {45}},
{sdTriangleIsosceles, "sdTriangleIsosceles", vec2(50,50), {50,50}},
{sdTriangle, 	"sdTriangle", 		vec2(0,0), 		{10,10, 90,90, 10,80}},
{sdQuad, 		"sdQuad", 			vec2(0,0), 		{10,10, 10,80, 90,90, 70,15}},
{sdUnevenCapsule, "sdUnevenCapsule", vec2(50,50), 	{20, 5, 40}},
{sdEgg, 		"sdEgg", vec2(50,50), {30, 10}},
{sdPie, 		"sdPie", 			vec2(50,50), 	{math.sin(3.14/2/3),math.cos(3.14), 40}},
{sdCutDisk, 	"sdCutDisk", 		vec2(50,50), 	{50, -25}},
{sdVesica, 		"sdVesica", 		vec2(50,50),	{50,30}},
{sdOrientedVesica, "sdOrientedVesica", vec2(0,0), 	{10,10, 90,90, 30}},
{sdMoon, 		"sdMoon", 			vec2(50,50), 	{15, 40, 30}},
{sdTunnel, 		"sdTunnel", 		vec2(50,50),	{40,20}},
{sdArc,			"sdArc", 			vec2(50,50), 	{math.sin(135 * math.pi / 180),math.cos(135 * math.pi / 180),40,5}},
{sdRing, 		"sdRing", 			vec2(50,50), 	{math.cos(135 * math.pi / 180),math.sin(135 * math.pi / 180),40,5}},
{sdHorseshoe, 	"sdHorseshoe", 		vec2(50,50), 	{0,1, 40, 20, 5}},
{sdParabola,	"sdParabola",		vec2(50,50), 	{0.025}},
{sdCross, 		"sdCross", 			vec2(50,50),	{50,20,7}},
{sdRoundedX, 	"sdRoundedX", 		vec2(50,50),	{60,10}},
{sdEllipse, 	"sdEllipse", 		vec2(50,50), 	{40,20}},
{sdEllipseLinf, 	"sdEllipseLinf", 		vec2(50,50), 	{40,20}},
{sdStar5, 		"sdStar5", 			vec2(50,50), 	{15, 3}},
{sdHexagram, 	"sdHexagram", 		vec2(50,50), 	{25}},
{sdPentagon, 	"sdPentagon", 		vec2(50,50), 	{40}},
{sdRegularPolygon, "sdRegularPolygon 5", vec2(50,50), {40, 5}},
{sdHexagon, 	"sdHexagon", 		vec2(50,50), 	{40}},
{sdRegularPolygon, "sdRegularPolygon 6", vec2(50,50), {40, 6}},
{sdOctagon, 	"sdOctagon", 		vec2(50,50), 	{40}},
{sdRegularPolygon, "sdRegularPolygon 8", vec2(50,50), {40, 8}},
{sdPolygon, 	"sdPolygon 4", 		vec2(0,0), {{10,70,90,10},{10,15,90,80},4}},
}

local testObjects = {
{sdSegmentLinf,		"sdSegmentLinf",		vec2(0,0), 		{20,20,80,80}},
{sdBoxLinf,			"sdBoxLinf",			vec2(50,50), 	{40,40}},
{sdRhombusLinf,		"sdRhombusLinf",		vec2(50,50), 	{50,40}},
{sdEllipseLinf, 	"sdEllipseLinf", 		vec2(50,50), 	{40,20}},
}
function playdate.update()
	
	for i=1,#testObjects do
		obj = testObjects[i]
		local grid = {}
		local f = obj[1]
		local fname = obj[2]
		local offset = obj[3]
		local offx, offy = offset.x, offset.y
		local params = obj[4]
		local timeCount = 0
		local distCount = 0
		local cachedParams = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
		for i=1, #params do
			cachedParams[i] = params[i]
		end

		-- We do two loops. 1st with drawing for visualisation, 2nd without for benchmarking.
		for i = 1,2 do
			for x = 0, gridSize - 1 do
				playdate.resetElapsedTime()
				for y = 0, gridSize - 1 do
					local dist = f(x-offx, y-offy, cachedParams[1], cachedParams[2], cachedParams[3], cachedParams[4], cachedParams[5],  cachedParams[6],  cachedParams[7],  cachedParams[8])
					if i == 1 then
						if dist <= 1 then
							grid[string.format("%d,%d", x, y)] = 1
						else
							grid[string.format("%d,%d", x, y)] = 0
						end
					end
				end
				local thistimecount = playdate.getElapsedTime()
				if i==2 then -- benchmark the second run only
					timeCount+=thistimecount
					distCount+=gridSize
				end
				if thistimecount*2 > 1/fps then 
					coroutine.yield() -- yield if we don't have time this frame for another column
				end
			end
			if i == 2 then 
				print(fname, math.floor(distCount/timeCount/50))
			end
			coroutine.yield()
		end
		
		local backgroundImage = gfx.image.new(400,240)
		gfx.pushContext(backgroundImage)
		for x = 0, gridSize - 1 do
			for y = 0, gridSize - 1 do
				local key = string.format("%d,%d", x, y)
				if grid[key] == 1 then
					gfx.drawPixel(x+150,y+70)
				end
			end
		end
		gfx.popContext(backgroundImage)
		playdate.graphics.clear()
		backgroundImage:draw(0, 0)
		playdate.graphics.drawText(fname, 140, 180)
		playdate.graphics.drawText("Per 1/50 sec: " .. math.floor(distCount/timeCount/50), 140, 200)
	end
end