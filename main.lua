package.path = package.path .. ';src/?.lua'
package.path = package.path .. ';lib/?.lua'

require 'EasyLD'

TitleScreen = require 'screens.TitleScreen'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 800


function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function EasyLD:load()
	EasyLD.window:resize(WINDOW_WIDTH, WINDOW_HEIGHT)
	EasyLD.window:setTitle("LD34 - Goutye")


	music = {}
	--music.gg = EasyLD.music:new("assets/musics/titlescreen.mp3", nil, true)
	playlist = EasyLD.playlist:new("ambiance", "fading", true)
	playlist:add(EasyLD.music:new("assets/musics/m1.ogg"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/m2.ogg"), nil, true)
	playlist:add(EasyLD.music:new("assets/musics/m3.ogg"), nil, true)

	for _,m in ipairs(playlist.list) do
		m:setVolume(0.3)
		m:setLooping(true)
	end

	font = EasyLD.font:new("assets/fonts/visitor.ttf")
	font2 = EasyLD.font:new("assets/fonts/Nouveau_IBM.ttf")

	EasyLD:nextScreen(TitleScreen:new())
end

function EasyLD:preCalcul(dt)
	-- local fps = EasyLD:getFPS()
	-- if fps ~= 0 then
	-- 	return 1/120
	-- else
	-- 	return dt
	-- end
	return dt
end

function EasyLD:update(dt)

end

function EasyLD:draw()
	--font:print("FPS: "..EasyLD:getFPS(), 20, EasyLD.box:new(0, WINDOW_HEIGHT-50, 100, 50), nil, "bottom", EasyLD.color:new(255,255,255))
end