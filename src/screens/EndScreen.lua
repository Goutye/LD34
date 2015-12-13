local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local EndScreen = class('EndScreen', IScreen)

function EndScreen:initialize(gamedata)
	self.player = gamedata.player
	self.top = gamedata.nbRemaining + 1
end

function EndScreen:preCalcul(dt)
	return dt
end

function EndScreen:update(dt)
	if EasyLD.mouse:isPressed("l") then
		EasyLD.screen:nextScreen(TitleScreen:new(), "slide", {-1,0}, 2, false, "quadinout")
	end
end

function EndScreen:draw()
	EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(5, 0, 11)):draw()
	if self.player.isDead then
		font:print("You have been defeated!", 60, EasyLD.box:new(0,100,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
		font:print("You grew a lot dude ("..self.top..". ".. math.floor(self.player.growing) ..") but that wasn't enough!", 40, EasyLD.box:new(0,170,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	else
		font:print("You are worthy of the Druid of the Grow!", 60, EasyLD.box:new(0,100,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
		font:print("You grew a lot dude (".. math.floor(self.player.growing) .."). I can't even see your leaves anymore!", 34, EasyLD.box:new(0,170,EasyLD.window.w, EasyLD.window.h), "center", nil, EasyLD.color:new(255,255,255))
	end
end

function EndScreen:onEnd()

end

return EndScreen