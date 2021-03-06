function love.load()
	EasyLD:load()
	EasyLD:postLoad("Löve2D")
	love.screen = love.graphics.newCanvas()
end

local currDt = 0
local frate =  1/60

function love.update(dt)
	currDt = currDt + dt
	if currDt >= frate then
		dt = currDt
		currDt = 0

		dt = EasyLD:preCalcul(dt)
		dt = EasyLD:preCalculScreen(dt)
		if EasyLD.screen.current then
			EasyLD.screen:update(dt)
		end
		EasyLD:update(dt)
		EasyLD:updateComponents(dt)
	end
end

function love.draw()
	love.screen:clear()
	love.graphics.setCanvas(love.screen)
	EasyLD.camera:draw()
	if EasyLD.screen.current then
		EasyLD.screen:draw()
	end
	EasyLD:draw()
	EasyLD.graphics:setColor()

	love.graphics.setCanvas()
	EasyLD.camera:push()
	EasyLD.camera:reset()
	love.graphics.draw(love.screen, 0, 0)
	EasyLD.camera:pop()
end