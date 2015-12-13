local class = require 'EasyLD.lib.middleclass'

local Acceleration = class('Acceleration')

function Acceleration:initialize(entity)
	self.name = "Boost"
	self.time = 0
	self.timeMax = 2
	self.entity = entity
	self.active = false
	self.sfx = EasyLD.sfx:new("assets/sfx/boost2.wav", 0.5)
end

function Acceleration:update(dt)
	if EasyLD.mouse:isPressed('l') and not self.active then
		self.active = true
		self.entity.speed = self.entity.speed * 2
		self.sfx:play()
	end

	if self.active then
		self:action()

		self.time = self.time + dt
		if self.time >= self.timeMax then
			self.active = false
			self.time = 0
			self.entity.bonus = nil
		end
	end
end

function Acceleration:updateAI(dt, top, active)
	if active and  not self.active then
		self.active = true
		self.entity.speed = self.entity.speed * 2
	end

	if self.active then
		self:action()

		self.time = self.time + dt
		if self.time >= self.timeMax then
			self.active = false
			self.time = 0
			self.entity.bonus = nil
		end
	end
end

function Acceleration:action()
	self.entity.speed = self.entity.speed * 1.04
end

function Acceleration:draw()
	
end

return Acceleration