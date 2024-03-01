-- An example of visualising an SDF to an image
-- This is far too slow for on-device implementation but could 
-- be used to build sprite images and is useful for testing SDFs.
import "CoreLibs/object"
import "CoreLibs/graphics"
import "PlaydateSDF/SDF2D.lua"

pd = playdate
gfx	= pd.graphics
geo	= pd.geometry
v = geo.vector2D.new
print('render start',playdate.getCurrentTimeMilliseconds())

local gridSize, initialStep = 100, 10
local p = geo.vector2D.new(50, 50)

-- Rather than sample all x by y points we'll speed it up
-- by using the returned distance from any point check
local function checkAndUpdateWithCircle(x, y, grid, sdf)
--	local dist = sdMoon(p - v(x, y), 14, 32, 24)
--	local dist = sdHexagram(p - v(x, y),15)
--	local dist = sdStar5(p - v(x, y),15,3) -- use for demo
--	local dist = sdTrapezoid(p - v(x, y), 30,20,12)
--	local dist = sdUnevenCapsule(p - v(x, y), 10,1,22)
--	local dist = sdPie(p - v(x, y),vec2(math.sin(3.14/3),math.cos(3.14/3)), 30)
--	local dist = sdCutDisk(p - v(x, y),15,-10)
--	local dist = sdVesica(p - v(x, y),20,7)
--	local dist = sdOrientedVesica(p - v(x, y), vec2(10,10), vec2(30,30), 4)
--	local dist = sdCross(p - v(x, y),vec2(40,20),7)
	local dist = sdRoundedX(p - v(x, y), 30,5)
--	local dist = sdOrientedBox(p - v(x, y), vec2(10,10),vec2(20,40),5)
--	local dist = sdRoundedBox(p - v(x, y),vec2(20,30), {0, 20, 0, 20})	
--	local dist = opOnion(p - v(x, y), sdHexagram, {15}, 3)
--	local dist = opRound(p - v(x, y), sdCross, {vec2(20,3), 3}, 8)
--	local dist = sdRoundedBox(p - v(x, y), vec2(8,32), {8,8,8,8})
--	local dist = sdHorseshoe(p - v(x, y), v(math.cos(math.pi/2),math.sin(math.pi/2)), 45,10,5)
--	local dist = sdRing(p - v(x, y), v(math.cos(math.pi/2),math.sin(math.pi/2)), 45, 5)
--	local dist = math.abs(sdBox(p - v(x, y), vec2(30,30)))-3
	
	if dist < 0 then
		grid[string.format("%d,%d", x, y)] = 1
	else
		local radius = dist
		local minX = math.max(0, math.floor(x - radius))
		local maxX = math.min(gridSize - 1, math.floor(x + radius))
		local minY = math.max(0, math.floor(y - radius))
		local maxY = math.min(gridSize - 1, math.floor(y + radius))

		for ix = minX, maxX do
			for iy = minY, maxY do
				-- Use distanceToPoint to check if (ix, iy) is within the circle.
				if geo.distanceToPoint(x, y, ix, iy) <= radius then
					local skipKey = string.format("%d,%d", ix, iy)
					grid[skipKey] = 0 -- Outside the object, mark as 0.
				end
			end
		end
	end
end

local grid = {}
for x = 0, gridSize - 1 do
	for y = 0, gridSize - 1 do
		local key = string.format("%d,%d", x, y)
		if grid[key] == nil then -- Only proceed if the cell hasn't been checked.
			checkAndUpdateWithCircle(x, y, grid, sdf)
		end
	end
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

print('render finish',playdate.getCurrentTimeMilliseconds())

function playdate.update()
	backgroundImage:draw(0, 0)
end