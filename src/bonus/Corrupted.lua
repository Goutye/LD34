local class = require 'EasyLD.lib.middleclass'

local Corrupted = class('Corrupted')

function Corrupted:initialize(entity)
	self.name = "Corrupted"
	self.entity = entity
end

function Corrupted:update(dt, top)
	if EasyLD.mouse:isPressed('l') then
		top[1].isCorrupted = true
		self.entity.bonus = nil
	end
end

function Corrupted:updateAI(dt, top, active)
	if active then
		top[1].isCorrupted = true
		self.entity.bonus = nil
	end
end

function Corrupted:action()

end

function Corrupted:draw()
	
end

return Corrupted