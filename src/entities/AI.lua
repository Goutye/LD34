local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local LightRay = require 'entities.LightRay'
local LightArea = require 'entities.LightArea'
local Bubbles = require 'entities.Bubbles'

local AI = class('AI', Entity)

local ACCELERATION = 750
local nbAI = 0

function AI:initialize(x, y, collideArea, spriteAnimation)
	self.id = nbAI
	nbAI = nbAI + 1
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
end

function AI:update(dt)
	self.acceleration = EasyLD.point:new(0, 0)

	self.collideArea.r = 5 + self.growing / 10
	self.weight = self.growing / 10 + 5

	if self.wasHit then
		self.timerInvincibility = self.timerInvincibility + dt
		if self.timerInvincibility >= self.timerInvincibilityMax then
			self.timerInvincibility = 0
			self.wasHit = false
		end
	end

	if self.growing <= -50 then self.isDead = true end
	if not self.collideArea:collide(EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h)) then
		self.isDead = true
		self.pos.x = 400
		self.pos.y = 400
	end

	self:interactWith()
end

function AI:interactWith()
	local player = EasyLD.screen.current.player
	local entities = EasyLD.screen.current:getRoundEntities()
	if #entities > 0 then
		local e = entities[#entities]
		if e.isDead then
			self:interactPlayer(player)
		elseif e:isInstanceOf(LightRay) then
			self:interactLightRay(e, player)
		elseif e:isInstanceOf(LightArea) then
			self:interactLightArea(e, player)
		elseif e:isInstanceOf(Bubbles) then
			self:interactBubbles(e, player)
		end
	else
		self:interactPlayer(player)
	end
end

function AI:interactPlayer(player)
	dir = EasyLD.vector:of(self.pos, player.pos)
	dir:normalize()
	self.acceleration.x = self.acceleration.x + ACCELERATION * dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * dir.y
end

function AI:interactBubbles(e, player)
	--Go to the shortest distance between you and a bubble
	--Have a chance to focus on the player if growing > 0

	local bubbles = e.entities

	if self.growing > player.growing and math.random() * self.growing / player.growing > 1.5 then
		dir = EasyLD.vector:of(self.pos, player.pos)
	else
		local minDist = 99999999
		local minB = {power = 0}

		for i,b in ipairs(bubbles) do
			if b.power > 0 then
				local v = EasyLD.vector:of(self.pos, b.pos)
				local dist = v:squaredLength()
				if dist * (1 + 0.025 * b.power) < minDist * (1 + 0.025 * minB.power) then
					minB = b
					minDist = dist
				end
			end
		end

		if minB.pos ~= nil then
			dir = EasyLD.vector:of(self.pos, minB.pos)
		else
			dir = EasyLD.vector:of(self.pos, player.pos)
		end
	end

	dir:normalize()
	self.acceleration.x = self.acceleration.x + ACCELERATION * dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * dir.y
end

function AI:interactLightArea(e, player)
	--Go in the area
	--Bump the player
	local dir = nil
	local poly = e.collideArea
	local x,y = 0, 0
	for _,p in ipairs(poly.p) do
		if p.x == 0 then x = -1
		elseif p.x == EasyLD.window.w then x = 1 end
		if p.y == 0 then y = -1
		elseif p.y == EasyLD.window.h then y = 1 end
	end

	x = (x + 1) /2 * EasyLD.window.w
	y = (y + 1) /2 * EasyLD.window.h
	local safestP = EasyLD.point:new(x, y)

	if poly:collide(self.collideArea) then
		--Safe => Bump

		if poly:collide(player.collideArea) then
			local distP = EasyLD.vector:of(player.pos, safestP):squaredLength()
			local dist = EasyLD.vector:of(self.pos, safestP):squaredLength()

			if distP < dist then
				--Go toward the safest point
				dir = EasyLD.vector:of(self.pos, safestP) 
			else
				--BUMP
				dir = EasyLD.vector:of(self.pos, player.pos) 
			end
		else
			print(safestP.x, safestP.y)
			dir = EasyLD.vector:of(self.pos, safestP) 
		end
	else
		local minDist = 9999999999
		local minDir = nil

		for _,p in ipairs(poly.p) do
			local dirP = EasyLD.vector:of(self.pos, p)
			local distP = dirP:squaredLength()
			if distP < minDist then
				minDist = distP
				minDir = dirP
			end
		end

		dir = EasyLD.vector:of(self.pos, safestP) + minDir
	end

	dir:normalize()
	self.acceleration.x = self.acceleration.x + ACCELERATION * dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * dir.y
end

function AI:interactLightRay(e, player)
	--Go in the light, and the shortest dist the better
	--Bump the player
	local dir = nil
	local v = EasyLD.vector:of(e.pos, self.pos)
	local proj = e.pos + e.dir * e.dir:dot(v)

	local bestDir = EasyLD.vector:of(self.pos, proj)

	if bestDir:squaredLength() < 1600 then
		local vP = EasyLD.vector:of(e.pos, player.pos)
		local projP = e.pos + e.dir * e.dir:dot(vP)
		local bestDirP = EasyLD.vector:of(player.pos, projP)

		if bestDirP:squaredLength() < 1600 then
			--player on the light
			if v:squaredLength() < vP:squaredLength() then
				--player get less light
				dir = EasyLD.vector:of(self.pos, e.pos)
			else
				--player get more light
				dir = EasyLD.vector:of(self.pos, player.pos)
			end
		else
			--player not on the light
			dir = EasyLD.vector:of(self.pos, e.pos)
		end
	else
		dir = bestDir
	end

	dir:normalize()
	self.acceleration.x = self.acceleration.x + ACCELERATION * dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * dir.y
end

function AI:onDeath()
	EasyLD.screen.current:oneIsDead()
end

function AI:onCollide(entity)
	if entity.passive or self.wasHit then
		return
	end

	if self.onCollideWith[entity.id] == nil then
		self.onCollideWith[entity.id] = 1
	else
		self.onCollideWith[entity.id] = self.onCollideWith[entity.id] + 0.1
	end
	
	self.wasHit = true

	local dir = EasyLD.vector:of(self.pos, entity.pos)
	dir:normalize()

	local speedEntity = entity.speed:dot(dir)
	if speedEntity > 0 then
		speedEntity = 0
	end

	local ratioWeight = entity.weight / self.weight

	speedEntity = speedEntity * ratioWeight * dir
	self.speed = self.speed + speedEntity --* self.onCollideWith[entity.id]
end

return AI