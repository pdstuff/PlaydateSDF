--[[
This is a more complex demo
- a scene made of interconnected SDFs each with collision response
- multiple collision response handling
- gravity and restitution modelling
In practice, the shape objects in this demo could be better handled as sprites, as these come with
AABB bounding box and tunnel controlled collision detection, plus helper methods for drawing and moving.
--]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Source/SDF2D.lua"

pd = playdate
gfx	= pd.graphics
geo	= pd.geometry
vec2 = geo.vector2D.new

fps = 50
pd.display.setRefreshRate(fps)

local sw, sh = pd.display.getSize()

-- We'll build a sequence of quads along a bezier curve
function drawQuad(p, q)
	gfx.drawPolygon(q[1].x,q[1].y,q[2].x,q[2].y,q[3].x,q[3].y,q[4].x,q[4].y,q[1].x,q[1].y)
end

function bezierPoint(t, P0, P1, P2)
	return vec2((1 - t)^2 * P0.x + 2 * (1 - t) * t * P1.x + t^2 * P2.x,
				(1 - t)^2 * P0.y + 2 * (1 - t) * t * P1.y + t^2 * P2.y)
end

function bezierTangent(t, P0, P1, P2)
	return ((P1 - P0) * 2 * (1 - t) + (P2 - P1) * 2 * t):normalized()
end

function buildBezierQuads ()	
	local P0, P1, P2 = vec2(20, 30), vec2(100, 200), vec2(200, 90)
	local terrain = {}
	local po = nil
	for t = 0, 1, 0.05 do
		local point = bezierPoint(t, P0, P1, P2)
		local tangent = bezierTangent(t, P0, P1, P2)
		local normal = vec2(-tangent.y, tangent.x):normalized()
		local off = {point + normal * 10, point - normal * 10}
		if po then
			local bb = { 	math.min(po[1].x, po[2].x, off[2].x, off[1].x),
							math.max(po[1].x, po[2].x, off[2].x, off[1].x),
							math.min(po[1].y, po[2].y, off[2].y, off[1].y),
							math.max(po[1].y, po[2].y, off[2].y, off[1].y)}
			table.insert(terrain, {sdQuad, vec2(0,0), {po[1], po[2], off[2], off[1]}, bb, drawQuad})
		end
		po = off 
	end
	return terrain
end	

local terrain = buildBezierQuads()

-- draw the shapes
local backgroundImage = gfx.image.new(sw,sh)
gfx.pushContext(backgroundImage)
for i=1, #terrain do 
	local o = terrain[i]
	local drawFn = o[5]
	drawFn(o[2],o[3]) 
end
gfx.popContext(backgroundImage)

class("Ball").extends(gfx.sprite)
function Ball:init(x, y)
	Ball.super.init(self)
	self.position = geo.vector2D.new(x, y)
	self.velocity = geo.vector2D.new(0, 1)
	self.radius = 3
	self:setSize(self.radius*2,self.radius*2)
	self:collisionsEnabled(false) -- not using sprite collision detection at all
	self:moveTo(self.position:unpack())
end

function Ball:draw() gfx.fillCircleAtPoint(self.radius, self.radius, self.radius) end

function samplePoints(p, f, offset, params)
	local eps = 1e-4
	local ds = {f(vec2(p.x + eps, p.y)-offset, table.unpack(params)),
			f(vec2(p.x - eps, p.y)-offset, table.unpack(params)),
			f(vec2(p.x, p.y + eps)-offset, table.unpack(params)),
			f(vec2(p.x, p.y - eps)-offset, table.unpack(params))}
	return vec2((ds[1]-ds[2])/(2*eps), (ds[3]-ds[4])/(2*eps)):normalized()
end

function Ball:update()
	self.velocity.y = self.velocity.y + 9.81/20 -- apply gravity factor

	-- Check for collisions here. 
	-- In this first loop we push embedded points out to shape surfaces and collect the collisions for resolution.
	local collisions = {}
	for i=1, #terrain do
		local o = terrain[i]
		local bb = o[4]
		if self.position.x > bb[1]-self.radius and self.position.x < bb[2]+self.radius -- cheap BB collision detection
		   and self.position.y > bb[3]-self.radius and self.position.y < bb[4]+self.radius then
			local f = o[1]
			local dist = f(self.position-o[2], table.unpack(o[3])) -- expensive shape collision detection
			if dist < self.radius then
				local normal = samplePoints(self.position, f, o[2], o[3]) -- calculate gradient
				table.insert(collisions, {
					normal = normal,
					penetration = self.radius - dist,
					object = o })				
				self.position = self.position + normal * ((self.radius - dist) + 0.05)
			end
		end
	end

	-- In this loop we average the normals across multiple collided objects to assess the response
	if #collisions > 0 then
		local combinedNormal = vec2(0, 0)
		for _, collision in ipairs(collisions) do
			combinedNormal = combinedNormal + collision.normal
		end
		combinedNormal = combinedNormal:normalized()
		local velocityPerpendicular = self.velocity:projectedAlong(combinedNormal)
		local velocityParallel = self.velocity - velocityPerpendicular
		velocityPerpendicular = -velocityPerpendicular * 0.65 -- restitution factor
		self.velocity = velocityPerpendicular + velocityParallel
	end

	-- it's possible to get objects embedded in other objects if the moving object is fast and/or the collides objects are small
	-- tuning the physics for anything more than simple use cases takes effort.
	
	self.position = self.position + self.velocity / fps	
	if self.position.y > sh then
		self.position = geo.vector2D.new(40, 20)
		self.velocity = geo.vector2D.new(0, 1)
	end
	self:moveTo(self.position:unpack())
end

Ball(40, 20):add()

function playdate.update()
	-- example of running the physics many times in a frame to reduce ball travel for more continuous detection
	-- its feasible to run a whole trajectory in a separate timeline to the rendered graphics timeline
	for i=1,4 do 
		gfx.sprite.update()
	end
	backgroundImage:draw(0, 0)

	playdate.drawFPS(10, 10)
end