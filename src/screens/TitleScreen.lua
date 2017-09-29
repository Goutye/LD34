local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local TitleScreen = class('TitleScreen', IScreen)

local GameScreen = require 'screens.GameScreen'

local RoundTitle = require 'rounds.RoundTitle'
local Player = require 'entities.Player'
local AI = require 'entities.AI'
local World = require 'World'
local Map = require 'Map'

function TitleScreen:initialize()
	self.map = Map:new()
	self.slice = World:new(self.map, EasyLD.window.w, EasyLD.window.h)

	for i = 0, 1 do
		for j = 0, 1 do
			self.slice:addEntity(AI:new(300 + i *600, 300 + j *300, EasyLD.circle:new(300 + i *100, 300 + j *100, 5, EasyLD.color:new(255,0,200))))
		end
	end

	self.rounds = {RoundTitle:new(self.slice)}
	self.currentRound = 1

	self.entities = {}
	for _,p in ipairs(self.slice.entities) do
		table.insert(self.entities, p)
		p.growing = 300
	end

	self.nbAIs = #self.entities - 1
	self.nbAIsStart = self.nbAIs

	self.BGbefore = EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(239, 222, 239))
	self.BG = EasyLD.box:new(0, 0, EasyLD.window.w, EasyLD.window.h, EasyLD.color:new(255, 255, 255))
	self.imgBG = EasyLD.image:new("assets/background.png")
	self.BG:attachImg(self.imgBG)

	self.BGtime = 0
	self.BGcolor = {EasyLD.color:new(217,231,250), EasyLD.color:new(239, 222, 239), EasyLD.color:new(255, 216, 234), EasyLD.color:new(239, 222, 239)}
	self.BGcurrent = 1
	self.BGtimer = nil
	self:changeColor()

	self.polygon = EasyLD.polygon:new("fill", EasyLD.color:new(0,0,0,240), EasyLD.point:new(-100, 0), EasyLD.point:new(400, 0), EasyLD.point:new(375, 50), EasyLD.point:new(-100, 50))
	self.poly2 = self.polygon:copy()
	self.poly2.c = EasyLD.color:new(0, 0, 0, 100)
	self.poly2:translate(6.6, -3.375)
	self.areaPoly = EasyLD.area:new(self.polygon)
	self.areaPoly:attach(self.poly2)

	playlist:play("next")

	self.start = true
end

function TitleScreen:preCalcul(dt)
	return dt
end

function TitleScreen:changeColor()
	self.BGcurrent = self.BGcurrent % #self.BGcolor + 1
	self.BGtimer = EasyLD.flux.to(self.BGbefore.c, 2, {r = self.BGcolor[self.BGcurrent].r, g = self.BGcolor[self.BGcurrent].g, b = self.BGcolor[self.BGcurrent].b}):ease("linear"):oncomplete(function() self:changeColor() end)
end

function TitleScreen:update(dt)
	if self.start then 
		self.rounds[1]:load(#self.entities - 1)
		self.start = false end

	self.BGtime = self.BGtime + dt
	self.slice:update(dt)
	self.rounds[self.currentRound]:update(dt)

	if EasyLD.mouse:isPressed(1) then
		EasyLD.screen:nextScreen(GameScreen:new(), "fusion", nil, 0.5, false, "quadinout")
	end
end

function TitleScreen:draw()
	local timeB = os.clock()
	local nbCut = math.max((1 -self.BGtime / 60) * 4 + 2, 2)
	if self.BGtime > 30 then
		EasyLD.camera:scaleTo(1 + FLUX_FCT["sineinout"](math.abs((self.BGtime % nbCut) /nbCut - 0.5) * 2) * 0.1)
	end

	self.BGbefore:draw()
	EasyLD.graphics:setColor(EasyLD.color:new(255,255,255))
	local x = (self.BGtime % 10)/10 * 1280
	self.BG:moveTo(x, 0)
	self.BG:draw()
	self.BG:moveTo(x -1280, 0)
	self.BG:draw()
	EasyLD.box:new(x - 5, 0, 6, EasyLD.window.h, EasyLD.color:new(255,255,255)):draw()
	EasyLD.camera:reset()

	self.slice:draw()

	if self.rounds[self.currentRound].isEnd or true then
		local r= self.rounds[self.currentRound]
		local ratio = -math.abs(r.timerOnEnd / (r.timerOnEndMax + 1) - 0.5) * 2 + 1
		if ratio > 0.33 then ratio = 0.33 end
		ratio = 0.1
		EasyLD.postfx:use("blurDir", -25 * ratio, 50 * ratio )
	end
	self.rounds[self.currentRound]:draw()

	self.areaPoly:draw()

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

	local bonusSize = math.max(10 - secs, 0)
	local tilt = math.abs((bonusSize % 2) / 2 - 0.5) * 2
	if bonusSize > 6 then tilt = math.abs(bonusSize % 1 - 0.5) * 2 end

	local c = EasyLD.color:new(255, 255*tilt, 255*tilt/2 + 255/2)

	font2:printOutLine(math.floor(r.totalTime/60)..":  :"..milli, 60, EasyLD.box:new(50, -5, 190, 50), "left", "top", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 2)
	font2:printOutLine(sec, 60, EasyLD.box:new(118, -5, 190, 50), "left", "top", c, EasyLD.color:new(0,0,0), 2)

	table.sort(self.entities, function(a,b) return a.growing > b.growing end)

	EasyLD.postfx:use("pixelate", 2, 2)

	font:printOutLine("Growing / Two buttons controls", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h), "right", "bottom", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
	font:printOutLine("Goutye - LD34", 20, EasyLD.box:new(0, 0,EasyLD.window.w, EasyLD.window.h-20), "right", "bottom", EasyLD.color:new(255,255,255), EasyLD.color:new(0,0,0), 1)
end

function TitleScreen:onEnd()
end

function TitleScreen:oneIsDead()
	self.nbAIs = self.nbAIs - 1
end

function TitleScreen:getRoundEntities()
	return self.rounds[self.currentRound].entities
end

function TitleScreen:getSliceEntities()
	return self.slice.entities
end

function TitleScreen:getTop()
	return self.entities
end

return TitleScreen