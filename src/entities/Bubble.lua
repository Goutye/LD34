local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Bubble = class('Bubble', Entity)

function Bubble:initialize(r, pos, dir, dirDt, ratio, speed, powerSinus)
	self.collideArea = EasyLD.circle:new(pos.x, pos.y, r, EasyLD.color:new(0, 50, 200, 150))
	self.dir = dir
	self.ratio = ratio
	self.dirDt = dirDt

	self.pos = pos

	self.speedDelta = speed
	self.t = 0

	self.powerSinus = powerSinus
	self.power = r
	self.speed = EasyLD.vector:new(0,0)
	self.passive = true

	self.box = EasyLD.box:new(0,0,EasyLD.window.w, EasyLD.window.h)
end

function Bubble:tryMove()
end

function Bubble:update(dt)
	self.t = self.t + dt
	self.collideArea.r = self.power

	self.pos = self.pos + self.dir * self.speedDelta * dt + self.dir:normal() * math.sin(self.powerSinus.x * self.t) * self.powerSinus.y
	self.collideArea:moveTo(self.pos.x, self.pos.y)
	self.dir = self.dir + self.dirDt * (dt * 0.3)

	if not self.collideArea:collide(self.box) then
		self.isDead = true
	end
end

function Bubble:draw()
	self.collideArea:draw()
end

function Bubble:collide(area)
	return area:collide(self.collideArea)
end

function Bubble:onCollide(entity)
	if self.power > 0 then
		entity.growing = entity.growing + 1
		self.power = self.power - 1
	end

	if self.power == 0 then
	end
end

return Bubble