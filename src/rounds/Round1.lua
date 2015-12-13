local class = require 'EasyLD.lib.middleclass'

local Round = class('Round')

local LightRay = require 'entities.LightRay'
local Bubbles = require 'entities.Bubbles'
local LightArea = require 'entities.LightArea'

local BonusF = require 'Bonus'
BONUS = BonusF:new()

function Round:initialize(slice)
	math.randomseed( os.time() )
	self.timer = 0
	self.nextEventTimer = 1

	self.slice = slice
	self.entities = {}
	self.totalTime = 60
	self.bonus = {false, false}
	self.nbAIStart =  #self.slice.entities - 1

	self.timerOnEnd = 0
	self.timerOnEndMax = 5
	self:newEvent()
end

function Round:update(dt)
	if self.isEnd then
		self:onEnd(dt)
	else
		for _,entity in ipairs(self.entities) do
			if not entity.isDead then
				entity:update(dt, self.slice)
			end
		end

		if #self.entities > 0 and self.entities[#self.entities]:isEnded() then
			self.timer = self.timer + dt
			if self.timer >= self.nextEventTimer then
				self:newEvent()
				self.timer = 0
				self.nextEventTimer = math.random() * 1
			end
		end

		self.totalTime = self.totalTime - dt
		if self.totalTime < 40 and not self.bonus[1] then
			self.bonus[1] = true
			self:distribBonuses()
		elseif self.totalTime < 20 and not self.bonus[2] then
			self.bonus[2] = true
			self:distribBonuses()
		elseif self.totalTime < 0 then
			self.totalTime = 0
			self.isEnd = true
		end
	end
end

function Round:distribBonuses()
	for _,e in ipairs(EasyLD.screen.current:getTop()) do
		e:setBonus(BONUS:get(e, EasyLD.screen.current:getTop()))
	end
end

function Round:newEvent()
	local nb = math.random(1, 4)
	if nb == 1 then
		table.insert(self.entities, Bubbles:new())
	elseif nb >= 2 and nb < 4 then
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

	if self.isEnd then
		local top = EasyLD.screen.current:getTop()
		EasyLD.box:new(EasyLD.window.w/3, EasyLD.window.h/3, EasyLD.window.w/3, 30 * #top + 100, EasyLD.color:new(40,0,100, 150)):draw()

		local box = EasyLD.box:new(EasyLD.window.w/3 + 100, EasyLD.window.h/3+10, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		
		
		for i,e in ipairs(top) do
			if i == #top or e.isDead then
				box.y = box.y + 30
				font:printOutLine(i .. ". " .. e.name .. ": " .. math.floor(e.growing), 30, box, "left", "top", EasyLD.color:new(70,0,255), EasyLD.color:new(0,0,0), 1)
			else
				box.y = box.y + 30
				font:printOutLine(i .. ". " .. e.name .. ": " .. math.floor(e.growing), 30, box, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)
			end
		end
	end
end

function Round:onEnd(dt)
	if self.nbAIStart == EasyLD.screen.current.nbAIs then
		local top = EasyLD.screen.current:getTop()
		top[#top].isDead = true
		print(top[#top].growing, top[#top].isDead)
	end

	self.timerOnEnd = self.timerOnEnd + dt
	if self.timerOnEnd >= self.timerOnEndMax then
		self.nextRound = true
	end
end

function Round:collide(area)
	return false
end

return Round