local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local Player = class('Player', Entity)

function Player:initialize(x, y, collideArea, spriteAnimation)
	self.name = -1
	self.isPlayer = true
	self.pos = EasyLD.point:new(x, y)
	self.speed = EasyLD.vector:new(0, 0)
	self.acceleration = EasyLD.vector:new(0, 0)

	self.collideArea = collideArea
	self.spriteAnimation = spriteAnimation
	self.isDead = false

	self.growing = 50
	self.weight = 5

	self.wasHit = false
	self.timerInvincibilityMax = 0.02
	self.timerInvincibility = 0

	self.onCollideWith = {}

	self.prevPos = self.pos:copy()

	self.isCorrupted = false
	self.time = 0
	self.timeCorrupted = 5

	self.bonus = nil
	self.bonusName = nil

	self.wait = false
	self.timerWait = 0
	self.timerWaitMax = 0.2

	self.boxBonus = EasyLD.box:new(-200, EasyLD.window.h/4 - 50, 300, 60, EasyLD.color:new(75,0,200, 150))
	self.poly = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(0,50), EasyLD.point:new(25,0), EasyLD.point:new(350,0), EasyLD.point:new(325,50))
	self.poly:moveTo(self.boxBonus.x - 100, self.boxBonus.y + 100)
	self.poly2 = self.poly:copy()
	self.poly2.c = EasyLD.color:new(0, 0, 0, 100)
	self.poly2:translate(6.6, -3.375)

	self.areaPoly = EasyLD.area:new(self.poly)
	self.areaPoly:attach(self.poly2)

	self.sfx = {}
	--self.sfx.bonusCome = EasyLD.sfx:new("assets/sfx/gg2.wav", 0.7)
	self.sfx.collide = EasyLD.sfx:new("assets/sfx/Collide2.wav", 0.15)

end

function Player:update(dt)
	self.dt = dt
	local ACCELERATION = 750 + self.growing /2

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

	if self.bonus ~= nil then
		self.bonus:update(dt, EasyLD.screen.current:getTop())
	end

	if self.isCorrupted then
		self.collideArea.c = EasyLD.color:new(0, 112, 225)
		self.growing = self.growing - 0.075
		self.time = self.time + dt
		if self.time >= self.timeCorrupted then
			self.time = 0
			self.isCorrupted = false
		end
	else
		self.collideArea.c = EasyLD.color:new(165,54,162)
	end

	if self.gotBonus and self.bonus == nil and not self.isEasing then
		self.isEasing = true
		EasyLD.flux.to(self.boxBonus, 1, {x = EasyLD.window.w + 2}):ease("backin"):oncomplete(
				function ()
					self.isEasing = false
					self.gotBonus = false
					self.boxBonus:moveTo(-200, EasyLD.window.h/4 - 50)
				end
			)
		EasyLD.flux.to(self.areaPoly, 1, {x = EasyLD.window.w + 2}):ease("backin"):oncomplete(
				function ()
					self.areaPoly:moveTo(-300, EasyLD.window.h/4 + 50)
				end
			)
	end

	if self.wait then
		self.timerWait = self.timerWait + dt
		if self.timerWait >= self.timerWaitMax then
			self.timerWait = 0
			self.wait = false
		end
	end
end

function Player:onDeath()

end

function Player:onCollide(entity)
	if entity.passive or self.wasHit then
		return
	end

	if self.isCorrupted then
		self.growing = self.growing - 0.75
		entity.growing = entity.growing + 0.75
		if not self.wait then
			sfx2:play()
			self.wait = true
		end
	else
		if not self.wait then
			self.sfx.collide:play()
			self.wait = true
		end
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
		--print("here", self.speed.x, self.speed.y, self.onCollideWith[entity.id])
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

function Player:setBonus(bonus)
	if bonus == nil then return end
	self.bonus = bonus
	self.bonusName = bonus.name

	self.gotBonus = true
	EasyLD.flux.to(self.boxBonus, 1, {x = EasyLD.window.w / 2 - 150}):ease("backout")
	EasyLD.flux.to(self.areaPoly, 1, {x = EasyLD.window.w / 2 - 200}):ease("backout")
end

function Player:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
		if self.bonus ~= nil then
			self.bonus:draw()
		end
	end
end

function Player:drawUI()
	if self.gotBonus then
		self.areaPoly:draw()
		self.boxBonus:translate(10, 60)
		self.boxBonus.w = self.boxBonus.w - 20
		self.boxBonus.h = self.boxBonus.h - 20
		font:printOutLine(self.bonusName, 40, self.boxBonus, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
		self.boxBonus.w = self.boxBonus.w + 20
		self.boxBonus.h = self.boxBonus.h + 20
		self.boxBonus:translate(-10, -60)


		self.boxBonus:translate(180, 60)
		if self.bonus ~= nil and self.bonus.active then
			font:printOutLine(round(self.bonus.timeMax - self.bonus.time, 2), 40, self.boxBonus, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
		end
		self.boxBonus:translate(-180, -60)
	end
end

return Player