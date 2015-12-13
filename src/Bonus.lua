local class = require 'EasyLD.lib.middleclass'

local Bonus = class('Bonus')

local Breath = require 'bonus.Breath'
local Acceleration = require 'bonus.Acceleration'
local Corrupted = require 'bonus.Corrupted'
local Heavy = require 'bonus.Heavy'

function Bonus:initialize()
	self.rankPool = {0.25, 0.5, 0.75, 1.01}
	self.pool = {
		{Acceleration, Heavy},
		{Breath, Acceleration, Heavy, Acceleration, Heavy},
		{Breath, Acceleration, Corrupted},
		{Breath, Corrupted}
	}
end

function Bonus:get(entity, top)
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
			return self.pool[i][math.random(1, #self.pool[i])]:new(entity, top)
		end
	end
end

function Bonus:draw()
	
end

return Bonus