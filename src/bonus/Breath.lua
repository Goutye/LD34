local class = require 'EasyLD.lib.middleclass'

local Breath = class('Breath')

function Breath:initialize(entity)
	self.name = "Repulse"
	self.time = 0.5
	self.timeMax = 1
	self.entity = entity
	self.max = 300
	self.active = false

	surf = EasyLD.surface:new(64,64)
	surf:drawOn()
	EasyLD.box:new(0,0,64,64):draw()
	EasyLD.surface:drawOnScreen()
	self.system = EasyLD.particles:new(entity.pos, surf)
	self.system:setEmissionRate(20)
	self.system:setLifeTime(1)
	self.system:setInitialVelocity(100)
	self.system:setInitialAcceleration(00)
	self.system:setDirection(math.pi, math.pi*2)
	self.system:setColors({[0] = EasyLD.color:new(255,0,0,150), 
					[0.3] = EasyLD.color:new(255,0,255,125), 
					[0.7] = EasyLD.color:new(255,255,255,100), 
					[1] = EasyLD.color:new(255,255,255,0)})
	self.system:setSizes({[0] = 16,
					[0.3] = 12,
					[0.7] = 8,
					[1] = 2})
	self.system:setTexture(surf)
	self.emit = false

	self.sfx = EasyLD.sfx:new("assets/sfx/breath.wav", 0.7)
end

function Breath:update(dt)
	if EasyLD.mouse:isDown('l') then
		self.time = self.time + dt
	elseif EasyLD.mouse:isReleased('l') and not self.emit then
		self.sfx:play()
		self.emit = true
		self.system:emit(70)
		self:action(math.min(self.time / self.timeMax, 1))
		self.time = 0
	end
	self.system.follower:moveTo(self.entity.pos.x, self.entity.pos.y)
	self.system:update(dt)
end

function Breath:updateAI(dt, top, active)
	self.time = self.time + dt
	if active and not self.emit then
		self.system.follower:moveTo(self.entity.pos.x, self.entity.pos.y)
		self.system:emit(35)
		self:action(math.min(self.time / self.timeMax, 1))
		self.time = 0
	end
	self.system:update(dt)
end

function Breath:action(percent)
	local entities = EasyLD.screen.current:getSliceEntities()

	for _,e in ipairs(entities) do
		if e.id ~= self.entity.id then
			local v = EasyLD.vector:of(self.entity.pos, e.pos)
			local dist = v:length()
			v:normalize()
			local ratioDist = math.max(1 - dist/self.max, 0)
			local ratioWeight = (self.entity.growing or 50) * 2 / (e.growing or 50)
			--print( ratioDist, ratioWeight, percent)
			v = v * 600 * ratioWeight * percent * ratioDist
			e.speed = v + e.speed * (1 - ratioDist)

			if e.isPlayer and ratioDist > 0 then
				--player
				EasyLD.camera:tilt(v, 20, 1)
			end
		end
	end

	self.timer = EasyLD.timer.after(1, 
					function() 
						self.entity.bonus = nil 
					end)
end

function Breath:draw()
	self.system:draw()
end

return Breath