local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local EndScreen = class('EndScreen', IScreen)

function EndScreen:initialize(gamedata)
	
end

function EndScreen:preCalcul(dt)
	return dt
end

function EndScreen:update(dt)
	if EasyLD.keyboard:isPressed(" ") then
		EasyLD.screen:nextScreen(TitleScreen:new(), "slide", {-1,0}, 2, false, "quadinout")
	end
end

function EndScreen:draw()

end

function EndScreen:onEnd()

end

return EndScreen