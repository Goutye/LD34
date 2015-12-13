local class = require 'EasyLD.lib.middleclass'

local Heavy = class('Heavy')

function Heavy:initialize(entity)
	self.name = "Heavy"
	self.entity = entity
	self.time = 0
	self.timeMax = 3
	self.active = false
end

function Heavy:update(dt, top)
	if EasyLD.mouse:isPressed('l') or self.active then
		self.entity.weight = self.entity.weight * 2
		self.active = true
		self.time = self.time + dt
		if self.time >= self.timeMax then
			self.entity.bonus = nil
			self.active = false
		end
	end
end

function Heavy:updateAI(dt, top, active)
	if active or self.active then
		self.entity.weight = self.entity.weight * 2
		self.time = self.time + dt
		self.active = true
		if self.time >= self.timeMax then
			self.entity.bonus = nil
			self.active = false
		end
	end
end

function Heavy:action()

end

function Heavy:draw()
	
end

return Heavy