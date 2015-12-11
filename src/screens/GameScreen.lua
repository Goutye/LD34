local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

function GameScreen:initialize()
	
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:update(dt)
	if EasyLD.mouse:isPressed("r") then
		--self.hero.gotTreasure = true
		--self.idCurrent = #self.floors
		--self.hero.life = 0
	end
end

function GameScreen:draw()
	font:printOutLine("??? - LD34", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h), "center", "center", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
end

function GameScreen:onEnd()
end

return GameScreen