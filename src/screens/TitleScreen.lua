local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local TitleScreen = class('TitleScreen', IScreen)

local GameScreen = require 'screens.GameScreen'

function TitleScreen:initialize()
	
end

function TitleScreen:preCalcul(dt)
	return dt
end

function TitleScreen:update(dt)
	if EasyLD.keyboard:isPressed(" ") then
		EasyLD.screen:nextScreen(TutorialScreen:new(), "slide", {-1,0}, 2, false, "quadinout")
	end
end

function TitleScreen:draw()
	font:printOutLine("??? - LD34", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h), "right", "bottom", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
end

function TitleScreen:onEnd()
end

return TitleScreen