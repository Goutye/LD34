local class = require 'EasyLD.lib.middleclass'

local Bonus = class('Bonus')

local Breath = require 'bonus.Breath'
local Acceleration = require 'bonus.Acceleration'
local Corrupted = require 'bonus.Corrupted'
local Heavy = require 'bonus.Heavy'

function Bonus:initialize()
	self.rankPool = {0.25, 0.5, 0.75, 1.01}
	self.pool = {}
	self.pool[2] = {
		{Acceleration, Heavy},
		{Breath, Acceleration, Heavy, Acceleration, Heavy},
		{Breath, Acceleration, Corrupted},
		{Breath, Corrupted}
	}

	self.pool[1] = {
		{Acceleration},
		{Acceleration},
		{Acceleration},
		{Acceleration}
	}

	self.pool[3] = {
		{Acceleration},
		{Breath, Acceleration},
		{Breath, Acceleration},
		{Breath, Acceleration}
	}

	self.pool[4] = {
		{Acceleration, Heavy},
		{Breath, Heavy, Heavy},
		{Breath, Heavy},
		{Breath, Acceleration}
	}

	self.pool[5] = {
		{Acceleration, Heavy},
		{Breath, Acceleration, Heavy, Acceleration, Heavy},
		{Breath, Corrupted},
		{Corrupted}
	}
end

function Bonus:get(entity, top, id)
	if id == nil then id = 2 end
	local rank = 0
	local nbPlayers = 0
	for i,e in ipairs(top) do
		if e.id == entity.id then
			rank = i
		end
		if not e.isDead then
			nbPlayers = nbPlayers + 1
		end
	end

	local score = (rank - 1) / (nbPlayers - 1)

	for i = 1, #self.rankPool do
		if score < self.rankPool[i] then
			return Breath:new(entity, top)--self.pool[id][i][math.random(1, #self.pool[id][i])]:new(entity, top)
		end
	end
end

function Bonus:draw()
	
end

return Bonus