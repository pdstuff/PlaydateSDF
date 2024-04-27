playdate.display.setRefreshRate(2)

local sdimages = {}
local sdscores = {}

local images_done = false

function calculateAverage(numbers)
	local sum = 0
	local count = 0
	for _, value in ipairs(numbers) do
		sum = sum + value
		count = count + 1
	end
	local average = sum / count
	return average
end

local labels = {"sdCircle", "sdSegment", "sdBox", "sdOrientedBox", "sdRoundedBox", "sdRoundSquare", "sdRhombus", "sdTrapezoid", "sdParallelogram", "sdEquilateralTriangle", "sdTriangleIsosceles", "sdTriangle", "sdQuad", "sdUnevenCapsule", "sdEgg", "sdPie", "sdCutDisk", "sdMoon", "sdVesica", "sdOrientedVesica", "sdTunnel", "sdArc", "sdRing", "sdHorseshoe", "sdParabola", "sdCross", "sdRoundedX", "sdEllipse", "sdStar5", "sdHexagram", "sdPentagon", "sdRegularPolygon (5)", "sdHexagon", "sdRegularPolygon (6)", "sdOctagon", "sdRegularPolygon (8)", "sdPolygon", "sdSegmentLinf", "sdBoxLinf", "sdRhombusLinf", "sdEllipseLinf"}

function playdate.update()

	if not images_done then
		for i=1,#labels do
			local img, score, td = benchmark(i,0)
			sdimages[i] = img
			sdscores[i] = {}
			img:draw(0, 0)
			coroutine.yield()
		end
		images_done = true
	end
	
	for i=1,#labels do
		local _, score, td = benchmark(i,1)
		table.insert(sdscores[i], score)
		print(labels[i], #sdscores[i], calculateAverage(sdscores[i]))
		sdimages[i]:draw(0,0)
		coroutine.yield()
	end

end

