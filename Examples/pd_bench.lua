-- A benchmark of SDF functions on the playdate. Run it on device.
import "CoreLibs/object"
import "CoreLibs/graphics"
import "Source/SDF2D.lua"

local pd = playdate
local gfx	= pd.graphics
local geo	= pd.geometry
local v = playdate.geometry.vector2D.new
local vec2 = playdate.geometry.vector2D.new
playdate.display.setRefreshRate(10)
local gridSize, initialStep = 100, 10

local testObjects = {
	{sdCircle, 		"sdCircle", 		vec2(50,50), 	{50}},
	{sdBox,			"sdBox",			vec2(50,50), 	{vec2(40,40)}},
	{sdRoundedBox,	"sdRoundedBox", 	vec2(50,50),	{vec2(40,40), {0, 20, 0, 20}}},
	{sdOrientedBox, "sdOrientedBox", 	vec2(0,0), 		{vec2(20,20), vec2(80,80), 20}},
	{sdSegment,		"sdSegment",		vec2(0,0), 		{vec2(20,20), vec2(80,80)}},
	{sdRhombus,		"sdRhombus",		vec2(50,50), 	{vec2(50,40)}},
	{sdTrapezoid,	"sdTrapezoid",		vec2(50,50),	{50, 30, 40}},
	{sdParallelogram, "sdParallelogram", vec2(50,50), 	{40, 40, 10}},
	{sdTriangle, 	"sdTriangle", 		vec2(0,0), 		{vec2(10,10), vec2(90,90), vec2(10,80)}},
	{sdEquilateralTriangle, "sdEquilateralTriangle", 	vec2(50,50), {45}},
	{sdTriangleIsosceles, "sdTriangleIsosceles", vec2(50,50), {vec2(50,50)}},
	{sdPolygon, 	"sdPolygon 3", 		vec2(0,0),		{{vec2(10,10), vec2(90,90), vec2(10,80)}}},
	{sdUnevenCapsule, "sdUnevenCapsule", vec2(50,50), 	{20, 5, 40}},
	{sdPentagon, 	"sdPentagon", 		vec2(50,50), 	{40}},
	{sdRegularPolygon, "sdRegularPolygon 5", vec2(50,50), {40, 5}},
	{sdHexagon, 	"sdHexagon", 		vec2(50,50), 	{40}},
	{sdRegularPolygon, "sdRegularPolygon 6", vec2(50,50), {40, 6}},
	{sdOctagon, 	"sdOctagon", 		vec2(50,50), 	{40}},
	{sdRegularPolygon, "sdRegularPolygon 8", vec2(50,50), {40, 8}},
	{sdHexagram, 	"sdHexagram", 		vec2(50,50), 	{25}},
	{sdStar5, 		"sdStar5", 			vec2(50,50), 	{15, 3}},
	{sdPie, 		"sdPie", 			vec2(50,50), 	{vec2(math.sin(3.14/2/3),math.cos(3.14)), 40}},
	{sdCutDisk, 	"sdCutDisk", 		vec2(50,50), 	{50, -25}},
	{sdArc,			"sdArc", 			vec2(50,50), 	{vec2(math.sin(135 * math.pi / 180),math.cos(135 * math.pi / 180)), 40,5}},
	{sdRing, 		"sdRing", 			vec2(50,50), 	{vec2(math.cos(135 * math.pi / 180),math.sin(135 * math.pi / 180)),40,5}},
	{sdHorseshoe, 	"sdHorseshoe", 		vec2(50,50), 	{vec2(0,1), 40, 20, 5}},
	{sdVesica, 		"sdVesica", 		vec2(50,50),	{50,30}},
	{sdOrientedVesica, "sdOrientedVesica", vec2(0,0), 	{vec2(10,10), vec2(90,90), 30}},
	{sdMoon, 		"sdMoon", 			vec2(50,50), 	{15, 40, 30}},
	{sdCross, 		"sdCross", 			vec2(50,50),	{vec2(50,20),7}},
	{sdRoundedX, 	"sdRoundedX", 		vec2(50,50),	{60,10}},
	{sdQuad, 		"sdQuad", 			vec2(0,0), 		{vec2(10,10), vec2(10,80), vec2(90,90), vec2(70,15)}},
	{sdPolygon, 	"sdPolygon 4", 		vec2(0,0),		{{vec2(10,10), vec2(70,15), vec2(90,90), vec2(10,80)}}},
	{sdParabola,	"sdParabola",		vec2(50,50), 	{0.025}},
	{sdEllipse, 	"sdEllipse", 		vec2(50,50), 	{vec2(40,20)}},
	{sdEllipse2, 	"sdEllipse", 		vec2(50,50), 	{vec2(40,20)}},
	{sdTunnel, 		"sdTunnel", 		vec2(50,50),	{vec2(40,20)}},
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
		local cachedParams = {nil, nil, nil, nil, nil, nil}
		for i=1, #params do
			cachedParams[i] = params[i]
		end
		
		for x = 0, gridSize - 1 do
			playdate.resetElapsedTime()
			for y = 0, gridSize - 1 do
				local dist = f(v(x-offx, y-offy),cachedParams[1], cachedParams[2], cachedParams[3], cachedParams[4])
			end
			timeCount+=playdate.getElapsedTime()
			distCount+=gridSize
			coroutine.yield()
		end
		print(fname, distCount/timeCount/50)

	end
end