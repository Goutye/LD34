local class = require 'EasyLD.lib.middleclass'

local LightArea = class('LightArea')

function LightArea:initialize()
	local points = {}
	table.insert(points, EasyLD.point:new(0,0))
	table.insert(points, EasyLD.point:new(math.random(50, EasyLD.window.w/2), 0))
	table.insert(points, EasyLD.point:new(math.random(EasyLD.window.w/2, EasyLD.window.w-50), 0))
	table.insert(points, EasyLD.point:new(EasyLD.window.w,0))

	table.insert(points, EasyLD.point:new(0, math.random(50, EasyLD.window.h-50)))
	table.insert(points, EasyLD.point:new(math.random(50, EasyLD.window.w/2), math.random(50, EasyLD.window.h-50)))
	table.insert(points, EasyLD.point:new(math.random(EasyLD.window.w/2, EasyLD.window.w-50), math.random(0, EasyLD.window.h-1)))
	table.insert(points, EasyLD.point:new(EasyLD.window.w, math.random(50, EasyLD.window.h-50)))

	table.insert(points, EasyLD.point:new(0,EasyLD.window.h))
	table.insert(points, EasyLD.point:new(math.random(50, EasyLD.window.w/2), EasyLD.window.h))
	table.insert(points, EasyLD.point:new(math.random(EasyLD.window.w/2, EasyLD.window.w-50), EasyLD.window.h))
	table.insert(points, EasyLD.point:new(EasyLD.window.w,EasyLD.window.h))

	self.polygons = {}
	for j = 0, 1 do
		for i = 1, 3 do
			table.insert(self.polygons, EasyLD.polygon:new("fill", EasyLD.color:new(43,11,109,0), points[j * 4 + i], points[j * 4 + i + 1], points[(j+1) * 4 + i + 1], points[(j+1) * 4 + i]))
		end
	end

	self.safePolygon = math.random(1, 6)
	self.collideArea = self.polygons[self.safePolygon]
	self.collideArea.c = EasyLD.color:new(255,255, 0)

	self.doDmg = false
	self.power = 0.25

	self.alpha = 0
	self.nbTimes = 6
	self.timerDead = 0
	self.timerDeadMax = 10

	self:drawLineTimer()
end

function LightArea:update(dt, slice)
	for _,entity in ipairs(slice.entities) do
		if not entity:collide(self) and self.doDmg and not entity.passive then
			entity.growing = entity.growing - self.power
		end
	end

	self.timerDead = self.timerDead + dt
	if self.timerDead >= self.timerDeadMax then
		self.isDead = true
	end
end

function LightArea:drawLineTimer()
	if self.nbTimes > 0 then
		if self.alpha >= 199 then
			self.timer = EasyLD.flux.to(self, 0.5, {alpha = 0}):ease("quadinout"):oncomplete(function() self:drawLineTimer()
				self.nbTimes = self.nbTimes - 1
			end)
		else
			self.timer = EasyLD.flux.to(self, 0.5, {alpha = 200}):ease("quadinout"):oncomplete(function() self:drawLineTimer() 
				self.nbTimes = self.nbTimes - 1
			end)
		end
	elseif self.nbTimes == 0 then
		self.timer = EasyLD.flux.to(self, 1, {alpha = 150}):ease("quadinout"):oncomplete(function() self.doDmg = true
			self.timer = nil
		end)
	end
end

function LightArea:draw()
	for i,p in ipairs(self.polygons) do
		if self.nbTimes > 0 then
			if i == self.safePolygon then
				p.mode = "line"
				p.c.a = self.alpha
				p:draw()
			end
		else
			p.mode = "fill"
			if i ~= self.safePolygon then
				p.c.a = self.alpha
				p:draw()
			end
		end
	end
end

function LightArea:collide(area)
	return not area:collide(self.collideArea)
end

return LightArea