local class = require 'EasyLD.lib.middleclass'

local Corrupted = class('Corrupted')

sfx2 = EasyLD.sfx:new("assets/sfx/corrupted.wav", 0.2)

function Corrupted:initialize(entity)
	self.name = "Corruption"
	self.entity = entity
	self.sfx = EasyLD.sfx:new("assets/sfx/use_bonus.wav", 0.2)
	self.wasActived = false
end

function Corrupted:update(dt, top)
	if EasyLD.mouse:isPressed(1) then
		top[1].isCorrupted = true
		self.entity.bonus = nil
		self.sfx:play()
	end
end

function Corrupted:updateAI(dt, top, active)
	if active and not self.wasActived then
		top[1].isCorrupted = true
		self.wasActived = true
		if top[1].isPlayer then

			sfx2:play()
		end
		self.entity.bonus = nil
	end
end

function Corrupted:action()

end

function Corrupted:draw()
	
end

return Corrupted