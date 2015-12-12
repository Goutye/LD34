local class = require 'EasyLD.lib.middleclass'

local Round = class('Round')

local LightRay = require 'entities.LightRay'
local Bubbles = require 'entities.Bubbles'
local LightArea = require 'entities.LightArea'

function Round:initialize(slice)
	math.randomseed( os.time() )
	self.timer = 0
	self.nextEventTimer = 2

	self.slice = slice
	self.entities = {}
end

function Round:update(dt)
	for _,entity in ipairs(self.entities) do
		if not entity.isDead then
			entity:update(dt, self.slice)
		end
	end

	self.timer = self.timer + dt
	if self.timer >= self.nextEventTimer then
		self.timer = self.timer - self.nextEventTimer
		self.nextEventTimer = math.random() * 4 + 9
		self:newEvent()
	end
end

function Round:newEvent()
	local nb = math.random(3, 3)
	if nb == 1 then
		table.insert(self.entities, Bubbles:new())
	elseif nb == 2 then
		table.insert(self.entities, LightRay:new())
	else
		table.insert(self.entities, LightArea:new())
	end
end

function Round:draw()
	for _,entity in ipairs(self.entities) do
		if not entity.isDead then
			entity:draw()
		end
	end
end

function Round:collide(area)
	return false
end

return Round