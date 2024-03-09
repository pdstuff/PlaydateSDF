-- An example of how to implement ray marching with SDF functions on the Playdate.
-- Ray marching is probably too slow for real time effects, but some effects like shadows
-- could be built in the background.
import "CoreLibs/object"
import "CoreLibs/graphics"
import "Source/SDF2D.lua"

gfx	= playdate.graphics
v = playdate.geometry.vector2D.new
pd.display.setRefreshRate(50)

local backgroundImage = gfx.image.new(400,220)
gfx.pushContext(backgroundImage)
gfx.drawLine(200,10,370,100)
gfx.setColor(playdate.graphics.kColorBlack)
gfx.fillCircleAtPoint(200, 90, 20)
gfx.fillCircleAtPoint(100,90,30)	
gfx.setColor(playdate.graphics.kColorClear)
gfx.fillCircleAtPoint(120,90,24)
gfx.setColor(playdate.graphics.kColorBlack)
gfx.setLineWidth(6)
gfx.drawArc(100, 190, 20, 45, 315)
gfx.popContext(backgroundImage)

function getMinDist(p)	
	return math.min(sdCircle(p - v(200, 90), 20), 
					sdMoon(p - v(100, 90), 20, 30, 24),
					sdArc(p - v(100, 190), v(math.sin(135*math.pi/180),math.cos(135*math.pi/180)), 20, 3),
					sdSegment(p, v(200,10), v(370,100)))
end

function castRay(o, a)

	local md, ld, cd = 600, 600, 0
		
	while cd < md do
		
		local cx, cy = o.x + math.cos(a) * cd, o.y + math.sin(a) * cd		
		gfx.drawLine(o.x, o.y, cx, cy)
		local d = getMinDist(v(o.x + math.cos(a) * cd, o.y + math.sin(a) * cd))		
		if d < 1 then break end
		gfx.drawCircleAtPoint(cx, cy, d)
		ld = d
		cd += ld 
		
	end
end

local i = 0
local nr = 400
local sa = 2 * math.pi

function playdate.update()

	gfx.sprite.update()

	i+=1
	if i >= nr then i = 0 end
	local a = (i / nr) * sa
	local o = geo.vector2D.new(i,130)
	
	local surfaceImage = backgroundImage:copy()
	gfx.pushContext(surfaceImage)
	castRay(o, a)
	gfx.popContext(surfaceImage)
	
	gfx.clear()
	surfaceImage:draw(0, 0)

end