local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local Player = require 'entities.Player'
local AI = require 'entities.AI'
local World = require 'World'
local Map = require 'Map'

local Round1 = require 'rounds.Round1'

function GameScreen:initialize()
	self.player = Player:new(500, 500, EasyLD.circle:new(500, 500, 5))
	self.map = Map:new()
	self.slice = World:new(self.map, EasyLD.window.w, EasyLD.window.h)

	self.slice:addEntity(self.player)
	self.slice:addEntity(AI:new(300, 300, EasyLD.circle:new(300, 300, 5, EasyLD.color:new(255,0,0))))
	self.slice:addEntity(AI:new(700, 400, EasyLD.circle:new(700, 400, 5, EasyLD.color:new(140,0,0))))
	self.slice:addEntity(AI:new(1000, 600, EasyLD.circle:new(1000, 600, 5, EasyLD.color:new(140,140,0))))

	self.rounds = {Round1:new(self.slice)}
	self.currentRound = 1

	self.entities = {}
	for _,p in ipairs(self.slice.entities) do
		table.insert(self.entities, p)
	end

	self.nbAIs = #self.entities - 1
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:update(dt)
	self.slice:update(dt)
	self.rounds[self.currentRound]:update(dt)
end

function GameScreen:draw()
	self.slice:draw()
	self.rounds[self.currentRound]:draw()

	table.sort(self.entities, function(a,b) return a.growing > b.growing end)
	for i,p in ipairs(self.entities) do
		font:print(i .. ". ".. p.id .. ": " .. p.growing, 20, EasyLD.box:new(0,80 + i * 20,100,20), "left", "up", EasyLD.color:new(255,255,255))
	end

	font:print("Nb AIs: " .. self.nbAIs, 20, EasyLD.box:new(0,0, 100, 20), "left", "up", EasyLD.color:new(255,255,255))
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

return GameScreen