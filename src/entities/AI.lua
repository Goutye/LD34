local class = require 'EasyLD.lib.middleclass'
local Entity = require 'EasyLD.Entity'

local LightRay = require 'entities.LightRay'
local LightArea = require 'entities.LightArea'
local Bubbles = require 'entities.Bubbles'

local Breath = require 'bonus.Breath'
local Acceleration = require 'bonus.Acceleration'
local Corrupted = require 'bonus.Corrupted'

local AI = class('AI', Entity)

local ACCELERATION = 750
local nbAI = 0

local name = {"Roger", "Doge", "Moon Moon", "Suteben", "Fanzie", "Number", "Fromage", "Rikka", "Mike", "Goutye", "Saitama", "Chino", "Araragi", "Kidanger", "Senpai", "Waifu", "Albert", "Lelouch", "Harry", "Light", "Okabe", "Ushio"}

function AI:initialize(x, y, collideArea, spriteAnimation)
	local n = math.random(1, #name)
	self.name = name[n]
	table.remove(name, n)
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
	self.prevPos = self.pos:copy()

	self.isCorrupted = false
	self.time = 0
	self.timeCorrupted = 5
	
	self.bonus = nil
	self.newEventLaunched = false
	self.prevEvent = nil

	self.dir = nil
	self.frame = 1
	self.maxFrame = 5
end

function AI:update(dt)
	ACCELERATION = 600 + self.growing /2
	self.dt = dt
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

	if self.growing <= -50 then self.isDead = true
		self.collideArea.r = 0 end
	if not self.collideArea:collide(EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h)) then
		self.isDead = true
		self.collideArea.r = 0
	end

	self.frame = self.frame + 1
	if self.frame >= self.maxFrame then
		self:interactWith(dt * self.maxFrame)
		self.frame = 0
		if self.dir == nil then self.dir = EasyLD.vector:new(EasyLD.window.w / 2, EasyLD.window.h / 2) end
		self.dir:normalize()
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
		self.collideArea.c = EasyLD.color:new(248,36,133)
	end

	if self.bonus ~= nil then
		self.bonus:updateAI(dt, EasyLD.screen.current:getTop())
	end
	if self.dir == nil then self.dir = EasyLD.vector:new(0,1) end
	self.acceleration.x = self.acceleration.x + ACCELERATION * self.dir.x
	self.acceleration.y = self.acceleration.y + ACCELERATION * self.dir.y
end

function AI:interactWith(dt)
	local opponents = {}
	for _,o in ipairs(EasyLD.screen.current:getSliceEntities()) do
		if o.id ~= self.id then
			table.insert(opponents, o)
		end
	end

	local entities = EasyLD.screen.current:getRoundEntities()
	if #entities > 0 then
		local e = entities[#entities]
		if e.isDead then
			self:interactOpponents(opponents)
		elseif e:isInstanceOf(LightRay) then
			self:interactLightRay(e, opponents)
		elseif e:isInstanceOf(LightArea) then
			self:interactLightArea(e, opponents)
		elseif e:isInstanceOf(Bubbles) then
			self:interactBubbles(e, opponents)
		end

		self.newEventLaunched = self.prevEvent ~= e
		self.prevEvent = e
	else
		self:interactOpponents(opponents)
	end

	self:interactBonus(dt, opponents)
end

function AI:interactBonus(dt, opponents)
	local e = self.bonus
	if e == nil then
		return
	elseif e:isInstanceOf(Breath) then
		local nb = 0
		for _,o in ipairs(opponents) do
			local v = EasyLD.vector:of(self.pos, o.pos)
			if v:squaredLength() < 30000 then
				nb = nb + 1
			end
		end

		if nb / #opponents >= 0.5 and e.time >= e.timeMax then
			e:updateAI(dt, nil, true)
		end
	elseif e:isInstanceOf(Acceleration) then
		if self.newEventLaunched then
			EasyLD.timer.after(math.random() * 5, function() e:updateAI(dt, nil, true) end)
		end
	elseif e:isInstanceOf(Heavy) then
		EasyLD.timer.after(math.random() * 5, function() e:updateAI(dt, nil, true) end)
	elseif e:isInstanceOf(Corrupted) then
		EasyLD.timer.after(math.random() * 5, function() e:updateAI(dt, EasyLD.screen.current:getTop(), true) end)
	end
end

function AI:interactOpponents(opponents)
	if self.isCorrupted then
		self:interactCorrupted(opponents)
		return
	end
	local target = nil
	local growing = -500
	for _,o in ipairs(opponents) do
		if not o.passive and o.growing > growing  and self.growing > o.growing then
			growing = o.growing
			target = o
		end
	end
	if target == nil then
		target = {pos = EasyLD.point:new(EasyLD.window.w / 2, EasyLD.window.h / 2)}
	end
	self.dir = EasyLD.vector:of(self.pos, target.pos)
end

function AI:interactCorrupted(opponents)
	local minDir = nil
	local minDist = 9999999999
	for _,o in ipairs(opponents) do
		if not o.passive then
			local v = EasyLD.vector:of(o.pos, self.pos)
			local dist = v:squaredLength()
			if dist < minDist then
				minDir = v
				minDist = dist
			end
		end
	end

	if minDir == nil then
		minDir = EasyLD.vector:of(self.pos, EasyLD.point:new(EasyLD.window.w / 2, EasyLD.window.h / 2))
	end

	self.dir = minDir
end

function AI:interactBubbles(e, opponents)
	--Go to the shortest distance between you and a bubble
	--Have a chance to focus on the opponents if growing > 0
	local dir
	local minDirO = nil
	local minDistO = 9999999999
	if self.isCorrupted then
		for _,o in ipairs(opponents) do
			if not o.passive then
				local v = EasyLD.vector:of(o.pos, self.pos)
				local dist = v:squaredLength()
				if dist < minDistO then
					minDirO = v
					minDistO = dist
				end
			end
		end
	end

	local bubbles = e.entities

	local target = nil
	local growing = -500
	for _,o in ipairs(opponents) do
		if not o.passive and o.growing > growing  and self.growing > o.growing then
			growing = o.growing
			target = o
		end
	end

	if target ~= nil and self.growing > target.growing and math.random() * self.growing / target.growing > 1.5 then
		dir = EasyLD.vector:of(self.pos, target.pos)
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
			if self.isCorrupted and minDistO < minDist then
				dir = minDirO
			else
				dir = EasyLD.vector:of(self.pos, minB.pos)
			end
		else
			if target == nil then
				if self.isCorrupted then
					dir = minDirO
				else
					target = {pos = EasyLD.point:new(EasyLD.window.w / 2, EasyLD.window.h / 2)}
					dir = EasyLD.vector:of(self.pos, target.pos)
				end
			end
		end
	end

	self.dir = dir
end

function AI:interactLightArea(e, opponents)
	--Go in the area
	--Bump the player
	local minDirO = nil
	local minDistO = 9999999999
	if self.isCorrupted then
		for _,o in ipairs(opponents) do
			if not o.passive then
				local v = EasyLD.vector:of(o.pos, self.pos)
				local dist = v:squaredLength()
				if dist < minDistO then
					minDirO = v
					minDistO = dist
				end
			end
		end
	end

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

		if not self.isCorrupted then
			local target = nil
			local dist = EasyLD.vector:of(self.pos, safestP):squaredLength()
			for _,o in ipairs(opponents) do
				if poly:collide(o.collideArea) then
					local distP = EasyLD.vector:of(o.pos, safestP):squaredLength()
					
					if distP > dist then
						dir = EasyLD.vector:of(self.pos, o.pos) 
						dist = distP
					end
				end
			end
		end

		if dir == nil then
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

	self.dir = dir
end

function AI:interactLightRay(e, opponents)
	--Go in the light, and the shortest dist the better
	--Bump the player
	local minDirO = nil
	local minDistO = 9999999999
	if self.isCorrupted then
		for _,o in ipairs(opponents) do
			if not o.passive then
				local v = EasyLD.vector:of(o.pos, self.pos)
				local dist = v:squaredLength()
				if dist < minDistO then
					minDirO = v
					minDistO = dist
				end
			end
		end
	end

	local dir = nil
	local v = EasyLD.vector:of(e.pos, self.pos)
	local dist = v:squaredLength()
	local proj = e.pos + e.dir * e.dir:dot(v)

	local bestDir = EasyLD.vector:of(self.pos, proj)

	if bestDir:squaredLength() < 1600 then
		local target = nil
		local growing = -500
		for _,o in ipairs(opponents) do
			local vP = EasyLD.vector:of(e.pos, o.pos)
			local projP = e.pos + e.dir * e.dir:dot(vP)
			local bestDirP = EasyLD.vector:of(o.pos, projP)
			local distP = vP:squaredLength()

			if bestDirP:squaredLength() < 1600 then
				--player on the light
				if dist >= distP then
					--player get more light

					if self.isCorrupted then
						dist = 0
						dir = minDirO
					else
						dist = distP
						dir = bestDirP
					end
				end
			end
		end

		if dir == nil then
			dir = EasyLD.vector:of(self.pos, e.pos)
		end
	else
		dir = bestDir
	end

	self.dir = dir
end

function AI:onDeath()
	EasyLD.screen.current:oneIsDead()
end

function AI:onCollide(entity)
	if entity.passive or self.wasHit then
		return
	end

	if self.isCorrupted then
		self.growing = self.growing - 0.75
		entity.growing = entity.growing + 0.75
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
		--print("there", self.speed.x, self.speed.y, self.onCollideWith[entity.id])
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
	self.pos = self.pos + speedEntity * (self.dt or 0.01)
	self.collideArea:moveTo(self.pos.x, self.pos.y)

	self.prevPos = self.pos:copy()
end

function AI:draw()
	if self.spriteAnimation ~= nil then
		self.spriteAnimation:draw(self.pos)
	else
		self.collideArea:draw() --Comment this line for real, if test, uncomment
		if self.bonus ~= nil then
			self.bonus:draw()
		end
	end
end

function AI:setBonus(bonus)
	self.bonus = bonus
end

return AI