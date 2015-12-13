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
	self.totalTime = 11
	self.bonus = {false, false}
	self.nbAIStart =  #self.slice.entities - 1
	self.roundName = "Round " .. (10 - self.nbAIStart)
	self.timerOnEnd = 0
	self.timerOnEndMax = 5
	self:newEvent()

	self.polyRound = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(-400, 0), EasyLD.point:new(EasyLD.window.w/2 + 100, 0), EasyLD.point:new(EasyLD.window.w/2 + 50, 100), EasyLD.point:new(-400, 100))
	self.polyRound.w = 400
	self.polyRound.h = 100
	self.polyRound:translate(-EasyLD.window.w/2, 100)

	self.polyTop = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(EasyLD.window.w/2, 0), EasyLD.point:new(EasyLD.window.w + 400, 0), EasyLD.point:new(EasyLD.window.w + 400, 400), EasyLD.point:new(EasyLD.window.w/2-50*4, 400))
	self.polyTop.w = 400
	self.polyTop.h = 100
	self.polyTop:translate(EasyLD.window.w/2, 250)

	self.sfx = {}
	self.sfx.fiveLast = EasyLD.sfx:new("assets/sfx/Last5seconds.wav", 0.7)
	self.sfx.fiveLast2 = EasyLD.sfx:new("assets/sfx/gg.wav", 0.7)

	self.countSecs = 10
end

function Round:load(nbAIStart)
	self.nbAIStart = nbAIStart
	if self.nbAIStart > 2 then
		self.roundName = "Round " .. (10 - self.nbAIStart)
	elseif self.nbAIStart == 2 then
		self.roundName = "1/2-Final Round"
	else
		self.roundName = "Final Round"
	end
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

			EasyLD.flux.to(self.polyRound, 1, {x = EasyLD.window.w/1.5}, "relative"):ease("backout")
			EasyLD.flux.to(self.polyTop, 1, {x = -EasyLD.window.w/1.5}, "relative"):ease("backout")

			for _,e in ipairs(EasyLD.screen.current:getTop()) do
				e.bonus = nil
			end
		end
	end

	if self.totalTime < self.countSecs then
		if self.countSecs == 1 then
			self.sfx.fiveLast2:play()
			self.sfx.fiveLast:play(self.sfx.fiveLast.volume * (10 - self.countSecs + 1)/10)
		else
			self.sfx.fiveLast:play(self.sfx.fiveLast.volume * (10 - self.countSecs + 1)/10)
		end
		self.countSecs = self.countSecs - 1
		if self.countSecs < 0 then self.countSecs = -99999 end
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
		self.polyRound:draw()

		local h = self.polyTop.p[3].y - self.polyTop.p[1].y
		for i = 1, 2 do
			self.polyTop.p[i + 2].y = self.polyTop.p[i].y + 30 * (2 + #top)
		end
		self.polyTop.p[4].x = self.polyTop.p[1].x - (h * 25/50)
		self.polyTop:draw()

		local box2 = EasyLD.box:new(self.polyRound.x + 400, self.polyRound.y + 10, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		local box = EasyLD.box:new(self.polyTop.x + 60, self.polyTop.y + 30, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		
		--print(self.nbAIStart)
		if self.nbAIStart > 2 then
			box2.x = box2.x + 310
		elseif self.nbAIStart == 1 then
			box2.x = box2.x + 150
		end
		font:printOutLine(self.roundName, 90, box2, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)

		for i,e in ipairs(top) do
			if i == #top or e.isDead then
				local c = EasyLD.color:new(248,36,133)
				font:printOutLine("{r:"..c.r.."|g:"..c.g.."|b:"..c.b.."|[out] "..i ..".} " .. e.name .. ": " .. math.floor(e.growing), 30, box, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
				box.y = box.y + 30
				box.x = box.x -15
			else				
				font:printOutLine(i .. ". " .. e.name .. ": " .. math.floor(e.growing), 30, box, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)
				box.y = box.y + 30
				box.x = box.x - 15
			end
		end
	end
end

function Round:onEnd(dt)
	if self.nbAIStart == EasyLD.screen.current.nbAIs then
		local top = EasyLD.screen.current:getTop()
		top[#top].isDead = true
		--print(top[#top].growing, top[#top].isDead)
	end

	self.timerOnEnd = self.timerOnEnd + dt
	if self.timerOnEnd >= self.timerOnEndMax and not self.timerEndMaxDone then
		self.timerEndMaxDone = true
		EasyLD.flux.to(self.polyRound, 1, {x = -EasyLD.window.w/1.5}, "relative"):ease("backin"):oncomplete(function() self.nextRound = true end)
		EasyLD.flux.to(self.polyTop, 1, {x = EasyLD.window.w/1.5}, "relative"):ease("backin")
	end
end

function Round:collide(area)
	return false
end

return Round