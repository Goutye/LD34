local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Player = class('Player', Entity)

function Player:initialize(x, y, collideArea, spriteAnimation)
	self.id = -1
	self.pos = EasyLD.point:new(x, y)
	self.speed = EasyLD.vector:new(0, 0)
	self.acceleration = EasyLD.vector:new(0, 0)

	self.collideArea = collideArea
	self.spriteAnimation = spriteAnimation
	self.isDead = false

	self.growing = 0
	self.weight = 5

	self.wasHit = false
	self.timerInvincibilityMax = 0.02
	self.timerInvincibility = 0

	self.onCollideWith = {}

	self.prevPos = self.pos:copy()
end

function Player:update(dt)
	self.dt = dt
	local ACCELERATION = 750

	self.acceleration = EasyLD.point:new(0, 0)
	local pos = EasyLD.mouse:getPosition()
	local dir = EasyLD.vector:of(self.pos, pos)
	if dir:squaredLength() > 1 then
		dir:normalize()
	end

	self.acceleration.x = self.acceleration.x + ACCELERATION * dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * dir.y

	if self.growing <= -50 then self.isDead = true end
	self.collideArea.r = 5 + self.growing / 10
	self.weight = self.growing / 10 + 5

	if self.wasHit then
		self.timerInvincibility = self.timerInvincibility + dt
		if self.timerInvincibility >= self.timerInvincibilityMax then
			self.timerInvincibility = 0
			self.wasHit = false
		end
	end
end

function Player:onDeath()

end

function Player:onCollide(entity)
	if entity.passive or self.wasHit then
		return
	end

	if self.onCollideWith[entity.id] == nil then
		self.onCollideWith[entity.id] = 1
	else
		self.onCollideWith[entity.id] = self.onCollideWith[entity.id] + 0.01
	end

	if self.pos == self.prevPos then
		if self.onCollideWith[entity.id] == nil then
			self.onCollideWith[entity.id] = 1
		else
			self.onCollideWith[entity.id] = self.onCollideWith[entity.id] + 0.02
		end
		local v = EasyLD.vector:of(entity.pos, self.pos)
		local dist = v:length()
		local ratio = 1 - dist/(self.collideArea.r + entity.collideArea.r)
		local ratioWeight = entity.weight / self.weight
		v:normalize()
		self.speed = v * ratio * ratioWeight * self.onCollideWith[entity.id]
		self.pos = self.pos + self.speed
		self.collideArea:moveTo(self.pos.x, self.pos.y)
		print("here", self.speed.x, self.speed.y, self.onCollideWith[entity.id])
		return
	end

	self.onCollideWith[entity.id] = 1
	
	self.wasHit = true

	local dir = EasyLD.vector:of(self.pos, entity.pos)
	dir:normalize()

	local speedEntity = entity.speed:dot(dir)
	if speedEntity > 0 then
		speedEntity = 0
	end

	local ratioWeight = entity.weight / self.weight

	speedEntity = speedEntity * ratioWeight * dir
	self.speed = self.speed + speedEntity
	self.pos = self.pos + speedEntity * self.dt
	self.collideArea:moveTo(self.pos.x, self.pos.y)

	self.prevPos = self.pos:copy()
end

return Player