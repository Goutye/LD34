local class = require 'EasyLD.lib.middleclass'

local WorldSlice = class('WorldSlice')

function WorldSlice:initialize(map, w, h)
	self.offset = EasyLD.point:new(-300,-300)
	self.mapHeight = h + 600
	self.mapWidth = w + 600
	self.map = map
	self:load()
end

function WorldSlice:load()
	self.entities = {}
	self.entitiesOrder = {}
	for i = 0, self.mapHeight - 1 do
		self.entitiesOrder[i + self.offset.y] = {}
	end
end

function WorldSlice:update(dt)
	for _,entity in ipairs(self.entities) do
		local oldY = math.floor(entity.pos.y)
		entity:update(dt)
		entity:tryMove(dt, self.map, self.entities)
		local newY = math.floor(entity.pos.y)
		if oldY ~= newY then
			if self.entitiesOrder[oldY] ~= nil then
				self.entitiesOrder[oldY][entity] = nil
			end
			if self.entitiesOrder[newY] ~= nil then
				self.entitiesOrder[newY][entity] = entity
			end
		end
	end

	local deadEntities = {}
	for id,entity in ipairs(self.entities) do
		if entity.isDead then
			--print("yes I am")
			entity:onDeath()
			if self.entitiesOrder[math.floor(entity.pos.y)] ~= nil then
				self.entitiesOrder[math.floor(entity.pos.y)][entity] = nil
			end
			table.insert(deadEntities, id)
		end
	end

	for _,id in ipairs(deadEntities) do
		table.remove(self.entities, id)
		--print("removed")
		for i = id, #self.entities do
			self.entities[i].id = i
		end
	end
end

function WorldSlice:draw()
	self.map:draw()
	for i = self.offset.y, self.offset.y + self.mapHeight - 1 do
		for _,entity in pairs(self.entitiesOrder[i]) do
			if not entity.isDead then
				entity:draw()
			end
		end
	end
end

function WorldSlice:addEntity(entity)
	table.insert(self.entities, entity)
	entity.id = #self.entities
	self.entitiesOrder[math.floor(entity.pos.y)][entity] = entity
end

function WorldSlice:removeEntity(entity)
	table.remove(self.entities, entity.id)
	for i = entity.id, #self.entities do
		self.entities[i].id = i
	end
	self.entitiesOrder[math.floor(entity.pos.y)][entity] = nil
end

return WorldSlice