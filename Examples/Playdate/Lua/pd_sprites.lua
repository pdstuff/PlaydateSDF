-- This file demos a circular ball bouncing between ellipses

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Source/Lua/SDF2D.lua" -- Ensure the right location!

gfx	= playdate.graphics
vec2 = playdate.geometry.vector2D.new
playdate.display.setRefreshRate(50) 

local sw, sh = playdate.display.getSize()

-- Model a ball that moves around the screen as a sprite
class("Ball").extends(gfx.sprite)
function Ball:init(x, y)
	Ball.super.init(self)
	self.velocity = vec2(4, 4)
	self.radius = 3
	self:setImage(self:draw())
	local w, h = self:getSize()
	self:setCollideRect( -3, -3, w+3, h+3) --increase hitbox	
	self:moveTo(x, y)
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
	
	local x, y = self.x, self.y
	local _, _, collisions, numberOfCollisions = self:checkCollisions(self.x, self.y)
	for i=1,numberOfCollisions do
		local collisionDistance = collisions[i].other:distance(x, y)
		if collisionDistance <= self.radius then
			local normal = collisions[i].other:gradient(x, y)
			x += normal.x * (self.radius - collisionDistance)
			y += normal.y * (self.radius - collisionDistance)	
			self.velocity = (self.velocity - self.velocity:projectedAlong(normal) * 2)
		end
	end

	x += self.velocity.x
	y += self.velocity.y
	x = (x > sw) and 0 or ((x < 0) and sw or x)
	y = (y > sh) and 0 or ((y < 0) and sh or y)
	self:moveTo(x, y)

end

function Ball:collisionResponse(other) return "overlap" end -- to enable multi-collision resolution

-- Model SDF defined objects as sprites. Will use Ellipses for the demo.

class("Ellipse").extends(gfx.sprite)
function Ellipse:init(x, y, a, b)
	Ellipse.super.init(self)	
	self.a = a
	self.b = b
	self:setImage(self:draw())
	self:setCollideRect( 0, 0, self:getSize() )
	self:moveTo(x,y)
end

function Ellipse:draw()
	local im = gfx.image.new(self.a*2,self.b*2)
	gfx.pushContext(im)
	gfx.fillEllipseInRect(0,0,self.a*2,self.b*2)
	gfx.popContext()
	return im
end

function Ellipse:distance(x, y)
	return sdEllipse(self.x-x, self.y-y, self.a, self.b)
end

-- the gradient at the point of impact allows us to determine the response
-- we measure the gradient from the distance of nearby points
function Ellipse:gradient(x, y)
	local xpx, xpy, xmx, xmy, ypx, ypy, ymx, ymy = x + 1e-4, y, x - 1e-4, y, x, y + 1e-4, x, y - 1e-4
	local px, mx, py, my = self:distance(xpx,xpy), self:distance(xmx,xmy), self:distance(ypx,ypy), self:distance(ymx,ymy)
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