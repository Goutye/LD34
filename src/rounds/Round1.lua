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
	self.roundName = "Round " .. (10 - self.nbAIStart)
	self.timerOnEnd = 0
	self.timerOnEndMax = 5
	self:newEvent()

	self.polyRound = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(-400, 0), EasyLD.point:new(EasyLD.window.w/2 + 100, 0), EasyLD.point:new(EasyLD.window.w/2 + 50, 100), EasyLD.point:new(-400, 100))
	self.polyRound.w = 400
	self.polyRound.h = 100
	self.polyRound:translate(-EasyLD.window.w/2, 100)

	self.polyRound2 = self.polyRound:copy()
	self.polyRound2.c = EasyLD.color:new(0,0,0,100)
	self.polyRound2:translate(6.6, -3.375)

	self.areaPolyRound = EasyLD.area:new(self.polyRound)
	self.areaPolyRound:attach(self.polyRound2)

	self.polyTop = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(EasyLD.window.w/2, 0), EasyLD.point:new(EasyLD.window.w + 400, 0), EasyLD.point:new(EasyLD.window.w + 400, 400), EasyLD.point:new(EasyLD.window.w/2-50*4, 400))
	self.polyTop.w = 400
	self.polyTop.h = 100
	self.polyTop:translate(EasyLD.window.w/2, 250)

	self.polyTop2 = self.polyTop:copy()
	self.polyTop2.c = EasyLD.color:new(0,0,0,100)
	self.polyTop2:translate(6.6, -3.375)

	self.areaPolyTop = EasyLD.area:new(self.polyTop)
	self.areaPolyTop:attach(self.polyTop2)

	self.sfx = {}
	self.sfx.fiveLast = EasyLD.sfx:new("assets/sfx/Last5seconds.wav", 0.7)
	self.sfx.fiveLast2 = EasyLD.sfx:new("assets/sfx/gg.wav", 0.7)

	self.countSecs = 10

	self.roundInfo = "Grow and be the last!"
	self.isStart = true
	self.timeStart = 0
	self.timeStartMax = 2
end

function Round:load(nbAIStart)
	self.nbAIStart = nbAIStart
	if self.nbAIStart > 4 then
		self.roundName = "Round " .. (10 - self.nbAIStart)
	elseif self.nbAIStart == 4 then
		self.roundName = "1/8-Final Round"
	elseif self.nbAIStart == 3 then
		self.roundName = "1/4-Final Round"
		self.roundInfo = self.roundName
	elseif self.nbAIStart == 2 then
		self.roundName = "1/2-Final Round"
		self.roundInfo = self.roundName
	else
		self.roundName = "Final Round"
		self.roundInfo = self.roundName
	end

	self.entities = {}
	self:newEvent()

	EasyLD.flux.to(self.areaPolyRound, 1, {x = EasyLD.window.w/1.5}, "relative"):ease("backout")
end

function Round:update(dt)
	if self.isEnd then
		self:onEnd(dt)
	elseif self.isStart then
		self.timeStart = self.timeStart + dt
		if self.timeStart >= self.timeStartMax then
			self.timeStartMax = 99999
			EasyLD.flux.to(self.areaPolyRound, 1, {x = -EasyLD.window.w/1.5}, "relative"):ease("backin"):oncomplete(function() self.isStart = false end)
		end
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

			self.endTop = EasyLD.screen.current:getTop()

			EasyLD.flux.to(self.areaPolyRound, 1, {x = EasyLD.window.w/1.5}, "relative"):ease("backout")
			EasyLD.flux.to(self.areaPolyTop, 1, {x = -EasyLD.window.w/1.5}, "relative"):ease("backout")

			local nbDead = 0
			for _,e in ipairs(self.endTop) do
				e.bonus = nil
				if e.isDead then
					nbDead = nbDead + 1
				end
			end

			if nbDead == 0 then
				self.endTop[#self.endTop].isDead = true
				--print(top[#top].growing, top[#top].isDead)
			end

		end
	end

	if self.totalTime < self.countSecs then
		if self.countSecs == 1 then
			self.sfx.fiveLast2:play()
			self.sfx.fiveLast:play(0.2 * (10 - self.countSecs + 1)/10)
		else
			self.sfx.fiveLast:play(0.2 * (10 - self.countSecs + 1)/10)
		end
		self.countSecs = self.countSecs - 1
		if self.countSecs < 0 then self.countSecs = -99999 end
	end
end

function Round:distribBonuses(i)
	for _,e in ipairs(EasyLD.screen.current:getTop()) do
		if not e.passive then
			e:setBonus(BONUS:get(e, EasyLD.screen.current:getTop(), i))
		end
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

	if self.isStart then
		self.areaPolyRound:draw()
		local box2 = EasyLD.box:new(self.polyRound.x + 200, self.polyRound.y + 10, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		font:printOutLine(self.roundInfo, 70, box2, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)
	end

	if self.isEnd then
		local top = self.endTop
		self.areaPolyRound:draw()

		local h = self.polyTop.p[3].y - self.polyTop.p[1].y
		for i = 1, 2 do
			self.polyTop.p[i + 2].y = self.polyTop.p[i].y + 30 * (2 + #top)
			self.polyTop2.p[i + 2].y = self.polyTop2.p[i].y + 30 * (2 + #top)
		end
		self.polyTop.p[4].x = self.polyTop.p[1].x - (h * 25/50)
		self.polyTop2.p[4].x = self.polyTop2.p[1].x - (h * 25/50)
		self.areaPolyTop:draw()

		local box2 = EasyLD.box:new(self.polyRound.x + 400, self.polyRound.y + 10, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		local box = EasyLD.box:new(self.polyTop.x + 60, self.polyTop.y + 30, EasyLD.window.w/3 - 100, EasyLD.window.h/3-10)
		
		--print(self.nbAIStart)
		if self.nbAIStart > 4 then
			box2.x = box2.x + 310
		elseif self.nbAIStart == 1 then
			box2.x = box2.x + 150
		end
		font:printOutLine(self.roundName, 90, box2, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)

		for i,e in ipairs(self.endTop) do
			if i == #top or e.isDead then
				local c = EasyLD.color:new(248,36,133)
				if e.name ~= nil then
					font:printOutLine("[out] ".. i ..".", 30, box, "left", "top", c, EasyLD.color:new(0,0,0), 1)
					box.x = box.x + 130
					font:printOutLine(e.name .. ": " .. math.floor(e.growing or 0), 30, box, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
					box.x = box.x - 130
				end
			elseif e.isPlayer then
				local c = EasyLD.color:new(165,54,162)
				font:printOutLine(i..". "..e.name..": " .. math.floor(e.growing or 0), 30, box, "left", "top", c, EasyLD.color:new(0,0,0), 1)
			else				
				font:printOutLine(i .. ". " .. e.name .. ": " .. math.floor(e.growing or 0), 30, box, "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(2,0,8), 1)
			end
			box.y = box.y + 30
			box.x = box.x -15
		end
	end
end

function Round:onEnd(dt)
	self.timerOnEnd = self.timerOnEnd + dt
	if self.timerOnEnd >= self.timerOnEndMax and not self.timerEndMaxDone then
		self.timerEndMaxDone = true
		EasyLD.flux.to(self.areaPolyRound, 1, {x = -EasyLD.window.w/1.5}, "relative"):ease("backin"):oncomplete(function() self.nextRound = true end)
		EasyLD.flux.to(self.areaPolyTop, 1, {x = EasyLD.window.w/1.5}, "relative"):ease("backin")
	end
end

function Round:collide(area)
	return false
end

return Round