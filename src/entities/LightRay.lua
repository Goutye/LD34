local class = require 'EasyLD.lib.middleclass'

local LightRay = class('LightRay')

function LightRay:initialize()
	local angle = math.random() * math.pi/16 + math.pi/64
	local side = math.random(0,1)

	self.isDead = false
	self.power = 100
	self.growRateMax = EasyLD.vector(EasyLD.window.w,0)
	self.growRateMax = self.growRateMax:length()

	self.dir = EasyLD.vector:new(math.random() - 0.5, math.random() - 0.5)
	self.dir:normalize()

	if side < 1 then
		self.pos = EasyLD.point:new(0, 0)
		if self.dir.x > 0 then
			self.pos.x = math.random(0, EasyLD.window.w / 2)
		else
			self.pos.x = math.random(EasyLD.window.w / 2, EasyLD.window.w - 1)
		end
		if self.dir.y < 0 then
			self.pos.y = EasyLD.window.h - 1
		end 
	else
		self.pos = EasyLD.point:new(0, 0)
		if self.dir.y > 0 then
			self.pos.y = math.random(0, EasyLD.window.h / 2)
		else
			self.pos.y = math.random(EasyLD.window.h / 2, EasyLD.window.h - 1)
		end
		if self.dir.x < 0 then
			self.pos.x = EasyLD.window.w - 1
		end 
	end

	local points =  {self.pos}
	self.dir:rotate(angle)

	table.insert(points, self.pos + self.dir * 1500)
	self.dir:rotate(-angle * 2)
	table.insert(points, self.pos + self.dir * 1500)

	self.dir:rotate(angle)

	self.collideArea = EasyLD.polygon:new("fill", EasyLD.color:new(248,36,133,255), unpack(points))
end

function LightRay:update(dt, slice)
	for _,entity in ipairs(slice.entities) do
		if entity:collide(self) and not entity.passive then
			local growRate = EasyLD.vector:of(self.pos, entity.pos)
			growRate = (1 - growRate:length() / self.growRateMax)
			self.power = self.power - growRate
			entity.growing = entity.growing + growRate
			self.collideArea.c.a = self.power / 100 *255

			if self.power <= 0 then
				self.isDead = true
				return
			end
		end
	end
end

function LightRay:draw()
	self.collideArea:draw()
end

function LightRay:collide(area)
	return area:collide(self.collideArea)
end

function LightRay:isEnded()
	return self.power <= 0
end

return LightRay