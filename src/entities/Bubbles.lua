local class = require 'EasyLD.lib.middleclass'

local Bubbles = class('Bubbles')
local Bubble = require 'entities.Bubble'

function Bubbles:initialize()
	local side = math.random(0,1)
	self.nbBubbles = math.random(10, 20)
	self.r = 10
	self.ratioArc = math.random() /2 + .5
	self.speedBubble = 100 + math.random() * 100
	self.powerSinus = EasyLD.point:new(2 + math.random() * 8, 1 + math.random() * 3)

	self.dir = EasyLD.vector:new(math.random() - 0.5, math.random() - 0.5)
	self.dir:normalize()
	self.pos = EasyLD.point:new(0, 0)
	self.dirDt = self.dir:normal()
	if math.random(1,2) == 1 then
		self.dirDt.x = -self.dirDt.x
		self.dirDt.y = -self.dirDt.y
	end

	if side < 1 then
		if self.dir.x > 0 then
			self.pos.x = math.random(0, EasyLD.window.w / 2)
		else
			self.pos.x = math.random(EasyLD.window.w / 2, EasyLD.window.w - 1)
		end
		if self.dir.y < 0 then
			self.pos.y = EasyLD.window.h - 1 + self.r
		else
			self.pos.y = - self.r
		end 
	else
		if self.dir.y > 0 then
			self.pos.y = math.random(0, EasyLD.window.h / 2)
		else
			self.pos.y = math.random(EasyLD.window.h / 2, EasyLD.window.h - 1)
		end
		if self.dir.x < 0 then
			self.pos.x = EasyLD.window.w - 1 + self.r
		else
			self.pos.x = - self.r
		end
	end

	self.isDead = false

	self.timer = 0
	self.timerNextBubble = 0.5 + math.random() / 2

	self.entities = {}
end

function Bubbles:update(dt, slice)

	self.timer = self.timer + dt
	if self.timer >= self.timerNextBubble then
		self.timer = self.timer - self.timerNextBubble
		self:nextBubble(slice)
	end
end

function Bubbles:nextBubble(slice)
	local bble = Bubble:new(10, self.pos, self.dir, self.dirDt, self.ratioArc, self.speedBubble, self.powerSinus)
	slice:addEntity(bble)
	table.insert(self.entities, bble)
	
	self.nbBubbles = self.nbBubbles - 1
	
	if self.nbBubbles == 0 then
		self.isDead = true
	end
end

function Bubbles:draw()
	
end

function Bubbles:collide(area)
	
end

return Bubbles