local class = require 'EasyLD.lib.middleclass'

local LightArea = class('LightArea')

local sfxLA = EasyLD.sfx:new("assets/sfx/lightarea.wav", 0.1)
local sfxCollide = EasyLD.sfx:new("assets/sfx/collide.wav", 0.1)

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
			local color = nil
			if (i + j * 4) % 2 == 0 then color = EasyLD.color:new(251,40,249,0)
			else color = EasyLD.color:new(201,30,199,0) end
			table.insert(self.polygons, EasyLD.polygon:new("fill", color, points[j * 4 + i], points[j * 4 + i + 1], points[(j+1) * 4 + i + 1], points[(j+1) * 4 + i]))
		end
	end

	self.safePolygon = math.random(1, 6)
	self.collideArea = self.polygons[self.safePolygon]
	self.collideArea.c = EasyLD.color:new(248,36, 133)

	self.doDmg = false
	self.power = 0.25

	self.alpha = 0
	self.nbTimes = 6
	self.timerDead = 0
	self.timerDeadMax = 9

	self:drawLineTimer()
	sfxLA:play(0.1)

	self.playerShake = false
	self.timeShake = 0
end

function LightArea:update(dt, slice)
	for _,entity in ipairs(slice.entities) do
		if not entity:collide(self) and self.doDmg and not entity.passive then
			entity.growing = entity.growing - self.power

			if entity.isPlayer then
				if not self.playerShake then
					self.playerShake = true
					EasyLD.camera:shake({x = 5, y = 5}, 0.2)
					sfxCollide:play()
				else
					self.timeShake = self.timeShake + dt
					if self.timeShake >= 0.2 then
						self.timeShake = 0
						self.playerShake = false
					end
				end
			end
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

function LightArea:isEnded()
	return self.timerDead >= self.timerDeadMax
end

function LightArea:collide(area)
	return not area:collide(self.collideArea)
end

return LightArea