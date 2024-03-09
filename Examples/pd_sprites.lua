import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Source/SDF2D.lua"

gfx	= playdate.graphics
vec2 = playdate.geometry.vector2D.new
playdate.display.setRefreshRate(50)

function samplePoints(p, eps)
	return  vec2(p.x + eps, p.y), vec2(p.x - eps, p.y),
			vec2(p.x, p.y + eps), vec2(p.x, p.y - eps)
end

local sw, sh = playdate.display.getSize()
local function wrap(value, max)
	return (value > max) and 0 or ((value < 0) and max or value)
end

-- Model a ball that moves around the screen as a sprite
class("Ball").extends(gfx.sprite)
function Ball:init(x, y)
	Ball.super.init(self)
	self.position = vec2(x, y)
	self.velocity = vec2(4, 4)
	self.radius = 3
	self:setImage(self:draw())
	local w, h = self:getSize()
	self:setCollideRect( -3, -3, w+3, h+3) --increase hitbox	
	self:moveTo(self.position:unpack())
end

function Ball:draw(radius)
	local im = gfx.image.new(2 * self.radius, 2 * self.radius)
	gfx.pushContext(im)
	gfx.fillCircleAtPoint(self.radius, self.radius, self.radius)
	gfx.popContext()
	return im	
end

-- We'll use the bump.lua based AABB collision detection that Playdate SDK provides as 
-- a first pass efficient detector, then pass to SDF distances when sprites overlap
function Ball:update()
	
	local _, _, collisions, numberOfCollisions = self:checkCollisions(self.x, self.y)
	for i=1,numberOfCollisions do
		local collisionDistance = collisions[i].other:distance(self.position)
		if collisionDistance <= self.radius then
			local normal = collisions[i].other:gradient(self.position)
			self.position = self.position + normal * (self.radius - collisionDistance)
			self.velocity = (self.velocity - self.velocity:projectedAlong(normal) * 2)
		end
	end

	self.position = self.position + self.velocity
	self.position.x = wrap(self.position.x, sw)
	self.position.y = wrap(self.position.y, sh)
	self:moveTo(self.position:unpack())

end

function Ball:collisionResponse(other) return "overlap" end -- to enable multi-collision resolution

-- Model SDF defined objects as sprites. Will use Ellipses for the demo.

class("Ellipse").extends(gfx.sprite)
function Ellipse:init(x, y, a, b)
	Ellipse.super.init(self)	
	self.position = vec2(x, y)
	self.a = a
	self.b = b
	self:setImage(self:draw())
	self:setCollideRect( 0, 0, self:getSize() )
	self:moveTo(self.position:unpack())
end

function Ellipse:draw()
	local im = gfx.image.new(self.a*2,self.b*2)
	gfx.pushContext(im)
	gfx.fillEllipseInRect(0,0,self.a*2,self.b*2)
	gfx.popContext()
	return im
end

function Ellipse:distance(p)
	return sdEllipse(self.position-p, vec2(self.a, self.b))
end

-- the gradient at the point of impact allows us to determine the response
function Ellipse:gradient(p)
	local xp, xm, yp, ym = samplePoints(p,1e-4)
	local px, mx, py, my = self:distance(xp), self:distance(xm), self:distance(yp), self:distance(ym)
	return vec2((px-mx)/(2e-4), (py-my)/(2e-4)):normalized()	
end

for n = 1, 16 do -- generate scene of 16 objects
	local x = sw/8 + (((n - 1) % 4)) * sw/4 + 40 * math.random() - 20
	local y = sh/8 + math.floor((n - 1) / 4) * sh/4 + 40 * math.random() - 20
	local obj = Ellipse(x, y, 30 - 20 * math.random(), 20 - 10 * math.random())
	obj:add()
end

Ball(200, 0):add()

function playdate.update()
	gfx.sprite.update()
	playdate.drawFPS(10, 10)
end