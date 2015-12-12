local class = require 'EasyLD.lib.middleclass'

local Map = class('Map')

function Map:initialize()
	self.areaCollide = EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h)
end

function Map:update(dt)
	
end

function Map:draw()

end

function Map:collide(e)
	area = e.collideArea
	if not area:collideBox(self.areaCollide, true) then

		if area.x - area.r < 0 or area.x + area.r >= EasyLD.window.w then

			local offset = math.min(math.abs(area.x - area.r), math.abs(EasyLD.window.w - area.x - area.r))
			if area.x - area.r >= 0 then offset = -offset end

			local n = EasyLD.vector:new(offset, 0)
			local dirE = e.speed:copy()
			dirE:normalize()
			local cos = n:dot(dirE)

			if cos < 0 then
				e.speed.x = -e.speed.x
				e.pos = e.pos - (cos * dirE)
			else
				e.pos = e.pos + (cos * dirE)
			end
		end

		if area.y - area.r < 0 or area.y + area.r >= EasyLD.window.h then

			local offset = math.min(math.abs(area.y - area.r), math.abs(EasyLD.window.h - area.y - area.r))
			if area.y - area.r >= 0 then offset = -offset end

			local n = EasyLD.vector:new(0, offset)
			local dirE = e.speed:copy()
			dirE:normalize()
			local cos = dirE:dot(n)

			if cos < 0 then
				e.speed.y = -e.speed.y
				e.pos = e.pos - (cos * dirE)
			else
				e.pos = e.pos + (cos * dirE)
			end
		end
	end
end

return Map