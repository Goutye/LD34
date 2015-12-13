local class = require 'EasyLD.lib.middleclass'

local IScreen = require 'EasyLD.IScreen'
local GameScreen = class('GameScreen', IScreen)

local EndScreen = require 'screens.EndScreen'

local Player = require 'entities.Player'
local AI = require 'entities.AI'
local World = require 'World'
local Map = require 'Map'

local Round1 = require 'rounds.Round1'

function GameScreen:initialize()
	self.player = Player:new(700, 500, EasyLD.circle:new(700, 500, 5))
	self.map = Map:new()
	self.slice = World:new(self.map, EasyLD.window.w, EasyLD.window.h)

	self.slice:addEntity(self.player)
	for i = 0, 2 do
		for j = 0, 1 do
			self.slice:addEntity(AI:new(300 + i *100, 300 + j *100, EasyLD.circle:new(300 + i *100, 300 + j *100, 5, EasyLD.color:new(255,0,200))))
		end
	end

	self.rounds = {Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice), Round1:new(self.slice)}
	self.currentRound = 1

	self.entities = {}
	for _,p in ipairs(self.slice.entities) do
		table.insert(self.entities, p)
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
end

function GameScreen:preCalcul(dt)
	return dt
end

function GameScreen:update(dt)
	self.BGtime = self.BGtime + dt
	self.slice:update(dt)
	self.rounds[self.currentRound]:update(dt)

	if self.rounds[self.currentRound].nextRound then
		self.slice:update(dt)

		self.currentRound = self.currentRound + 1
		self.entities = {}
		for _,p in ipairs(self.slice.entities) do
			table.insert(self.entities, p)
		end

		if self.player.isDead or #self.entities == 1 then
			EasyLD:nextScreen(EndScreen:new({player = self.player, nbRemaining = #self.entities}), "cover", {0,1}, 3, true, "bounceout")
		end
		
		if self.currentRound > #self.rounds then
			self.currentRound = self.currentRound - 1 
			print("End")
		else
			self.rounds[self.currentRound].slice = self.rounds[self.currentRound - 1].slice
		end
		self.rounds[self.currentRound]:load(#self.entities - 1)
		playlist:play("next")
	end
end

function GameScreen:changeColor()
	self.BGcurrent = self.BGcurrent % #self.BGcolor + 1
	self.BGtimer = EasyLD.flux.to(self.BGbefore.c, 2, {r = self.BGcolor[self.BGcurrent].r, g = self.BGcolor[self.BGcurrent].g, b = self.BGcolor[self.BGcurrent].b}):ease("linear"):oncomplete(function() self:changeColor() end)
end

function GameScreen:draw()
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

	if self.rounds[self.currentRound].isEnd then
		local r= self.rounds[self.currentRound]
		local ratio = -math.abs(r.timerOnEnd / (r.timerOnEndMax + 1) - 0.5) * 2 + 1
		if ratio > 0.33 then ratio = 0.33 end
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

	font2:printOutLine(math.floor(r.totalTime/60)..":{r:255|g:"..(255*tilt).."|b:"..(255*tilt/2 + 255/2).."|"..sec.."}"..":"..milli, 60, EasyLD.box:new(50, 0, 190, 50), "left", "top", EasyLD.color:new(255 - bonusSize,255 - bonusSize * 5,255 - bonusSize), EasyLD.color:new(0,0,0), 2)

	if tonumber(sec) < 4 and secs > 0 then
		font2:printOutLine("{r:255|g:"..(255).."|b:"..(255).."|"..tonumber(sec).."}", 200, EasyLD.box:new(EasyLD.window.w/2 - 20, 300, 190, 300), "left", "top", EasyLD.color:new(255,255,255, 255*FLUX_FCT["quadinout"](1-tilt)), EasyLD.color:new(0,0,0, 0), 1)
	end

	self.player:drawUI()
	table.sort(self.entities, function(a,b) return a.growing > b.growing end)
	
	if self.player.isCorrupted then
		local ratio = self.player.time/self.player.timeCorrupted
		local x = 15
		if ratio < 0.2 then x = ratio * 5 * x
		elseif ratio >0.8 then x = (1-ratio) * 5 * x end
		EasyLD.postfx:use("distortion", ratio*3, x, x)
	end

	EasyLD.postfx:use("pixelate", 2, 2)
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

function GameScreen:getTop()
	return self.entities
end

return GameScreen