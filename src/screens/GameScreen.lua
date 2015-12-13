local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local EndScreen = require 'screens.EndScreen'

local Player = require 'entities.Player'
local AI = require 'entities.AI'
local World = require 'World'
local Map = require 'Map'

local Round1 = require 'rounds.Round1'

function GameScreen:initialize()
	self.player = Player:new(700, 500, EasyLD.circle:new(700, 500, 5))
	self.map = Map:new()
	self.slice = World:new(self.map, EasyLD.window.w, EasyLD.window.h)

	self.slice:addEntity(self.player)
	for i = 0, 2 do
		for j = 0, 2 do
			self.slice:addEntity(AI:new(300 + i *100, 300 + j *100, EasyLD.circle:new(300 + i *100, 300 + j *100, 5, EasyLD.color:new(255,0,200))))
		end
	end

	self.rounds = {Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice)}
	self.currentRound = 1

	self.entities = {}
	for _,p in ipairs(self.slice.entities) do
		table.insert(self.entities, p)
	end

	self.nbAIs = #self.entities - 1
	self.nbAIsStart = self.nbAIs
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:update(dt)
	self.slice:update(dt)
	self.rounds[self.currentRound]:update(dt)

	if self.rounds[self.currentRound].nextRound then
		self.slice:update(dt)

		self.currentRound = self.currentRound + 1
		self.entities = {}
		for _,p in ipairs(self.slice.entities) do
			table.insert(self.entities, p)
		end

		if self.player.isDead or #self.entities == 1 then
			EasyLD:nextScreen(EndScreen:new({player = self.player, nbRemaining = #self.entities}), "cover", {0,1}, 3, true, "bounceout")
		end
		
		if self.currentRound > #self.rounds then
			self.currentRound = self.currentRound - 1 
			print("End")
		else
			self.rounds[self.currentRound].slice = self.rounds[self.currentRound - 1].slice
		end
		self.rounds[self.currentRound].nbAIStart = #self.entities - 1
	end
end

function GameScreen:draw()
	EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(5, 0, 11)):draw()

	self.slice:draw()
	self.rounds[self.currentRound]:draw()
	--[[
	table.sort(self.entities, function(a,b) return a.growing > b.growing end)
	for i,p in ipairs(self.entities) do
		local bonusName = p.bonus and p.bonus.name or "none"
		font:print(i .. ". ".. p.name .. ": " .. round(p.growing, 1) .. "   " .. bonusName, 20, EasyLD.box:new(0,80 + i * 20,100,20), "left", "top", EasyLD.color:new(255,255,255))
	end

	font:print("Nb AIs: " .. self.nbAIs, 20, EasyLD.box:new(0,0, 100, 20), "left", "top", EasyLD.color:new(255,255,255))]]--

	local r = self.rounds[self.currentRound]
	local secs = r.totalTime % 60
	local sec = math.floor(secs)
	local milli = round((secs - sec) * 1000, 0)
	if milli < 0 then milli = 1000 + milli end
	if milli < 100 then milli = "0" .. milli end
	if tonumber(milli) < 10 then milli = "0" .. milli end
	if sec < 10 then sec = "0" .. sec end

	local bonusSize = math.max(20 - sec, 0) * 2

	font2:print(math.floor(r.totalTime/60)..":"..sec..":"..milli, 60 + bonusSize, EasyLD.box:new(EasyLD.window.w/2 - 150 - bonusSize/2, 0, 190, 50), "left", "top", EasyLD.color:new(255,255,255))

	self.player:drawUI()
	table.sort(self.entities, function(a,b) return a.growing > b.growing end)
end

function GameScreen:onEnd()
end

function GameScreen:oneIsDead()
	self.nbAIs = self.nbAIs - 1
end

function GameScreen:getRoundEntities()
	return self.rounds[self.currentRound].entities
end

function GameScreen:getSliceEntities()
	return self.slice.entities
end

function GameScreen:getTop()
	return self.entities
end

return GameScreen