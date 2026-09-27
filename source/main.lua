-- Build target. 'peedee' or 'love'
platform = 'peedee'
local fps = 30

local pd
local gfx
local smp
local scale
local fullscreen

gamepad = false
music = nil
volume = 1
catalog = false

-- for the sticks
lstick_up = false
lstick_down = false
lstick_left = false
lstick_right = false
rstick_up = false
rstick_down = false
rstick_left = false
rstick_right = false

local sfx_loaded = false
local fonts_loaded = false
local floor = math.floor
local ceil = math.ceil

if platform == 'peedee' then
	import 'CoreLibs/math'
	import 'CoreLibs/timer'
	import 'CoreLibs/crank'
	import 'CoreLibs/object'
	import 'CoreLibs/sprites'
	import 'CoreLibs/graphics'
	import 'CoreLibs/animation'
	import 'CoreLibs/nineslice'

	import 'libraries/wrappers_peedee'
	import 'libraries/xorshift_peedee'
	import 'scenemanager'
	scenemanager = scenemanager()

	import 'title'

	import 'langs'

	pd = playdate
	gfx = pd.graphics
	timer = pd.timer
	smp = pd.sound.sampleplayer

	version = pd.metadata.version

	pd.display.setRefreshRate(fps)
	gfx.sprite.setAlwaysRedraw(true)

	if pd.metadata.bundleID == 'wtf.rae.looplariat' then
		catalog = true
	end
elseif platform == 'love' then
	json = require 'libraries/json'
	timer = require 'libraries/timer'
	easings = require 'libraries/easing'
	gamestate = require 'libraries/gamestate'

	require 'libraries/wrappers_love'
	require 'libraries/xorshift_love'
	scenemanager = require 'scenemanager'

	title = require 'title'

	langs = require 'langs'

	gfx = love.graphics
	fullscreen = false

	version = '1.0.0'

	gfx.setLineStyle('rough')
	gfx.setLineJoin('miter')
	gfx.setDefaultFilter('nearest', 'nearest')
	love.keyboard.setKeyRepeat(false)

	icon = love.image.newImageData('images/system/icon.png')
end

setbackgroundcolor('white')
gfx.setLineWidth(2)

-- Localized text function. if "keyboard" is passed in as true, then on the love version there should be an alternate string set for whether or not the player is using a gamepad (controller) or a keyboard.
function text(key)
	local data
	if save.lang == 'en' then
		data = langs.en
	elseif save.lang == 'fr' then
		data = langs.fr
	end
	return data and data[key] or key
end

-- Save check
function savecheck()
	if platform == 'peedee' then
    	save = pd.datastore.read()
	elseif platform == 'love' then
		if love.filesystem.read('data.json') ~= nil then
			save = json.decode(love.filesystem.read('data.json'))
		end
	end

    if save == nil then save = {} end

	if platform == 'peedee' then
		if save.gamepad == nil then save.gamepad = true end
	elseif platform == 'love' then
		if save.gamepad == nil then save.gamepad = false end
		gamepad = save.gamepad

		save.up = save.up or 'up'
		save.down = save.down or 'down'
		save.left = save.left or 'left'
		save.right = save.right or 'right'
		save.primary = save.primary or 'z'
		save.secondary = save.secondary or 'x'

		save.deadzone = save.deadzone or 0.5

		if save.clean_scaling == nil then save.clean_scaling = true end
		if save.rumble == nil then save.rumble = true end
	end

	save.lang = save.lang or 'en'
	if save.music == nil then save.music = true end
	if save.sfx == nil then save.sfx = true end

	if save.lastdaily == nil then save.lastdaily = {} end
	save.lastdaily.year = save.lastdaily.year or 0
	save.lastdaily.month = save.lastdaily.month or 0
	save.lastdaily.day = save.lastdaily.day or 0
	save.lastdaily.score = save.lastdaily.score or 0

	save.arcade_best = save.arcade_best or 0
	save.time_best = save.time_best or 0
	save.marathon_best = save.marathon_best or 0

	save.reduceflashing = save.reduceflashing or (platform == 'peedee' and 2 or platform == 'love' and 0) -- Set to "system" on peedee, "off" in love.
end

function load_common_sfx()
	if save.sfx and not sfx_loaded then
		sfx_back = newsound('audio/sfx/back')
		sfx_block_in = newsound('audio/sfx/block_in')
		sfx_explode_1 = newsound('audio/sfx/explode_1')
		sfx_explode_2 = newsound('audio/sfx/explode_2')
		sfx_explode_3 = newsound('audio/sfx/explode_3')
		sfx_game_bonk = newsound('audio/sfx/game_bonk')
		sfx_game_move = newsound('audio/sfx/game_move')
		sfx_hold = newsound('audio/sfx/hold')
		sfx_match_clear = newsound('audio/sfx/match_clear')
		sfx_match = newsound('audio/sfx/match')
		sfx_menu_bonk = newsound('audio/sfx/menu_bonk')
		sfx_menu_move = newsound('audio/sfx/menu_move')
		sfx_no_place = newsound('audio/sfx/no_place')
		sfx_place_block = newsound('audio/sfx/place_block')
		sfx_place_tnt = newsound('audio/sfx/place_tnt')
		sfx_select = newsound('audio/sfx/select')
		sfx_loaded = true
	end
end

function load_common_fonts()
	if not fonts_loaded then
		root_beer = newfont('fonts/root_beer')
		root_beer_inverted = newfont('fonts/root_beer_inverted')
		root_beer_outline = newfont('fonts/root_beer_outline')

		root_beer_med = newfont('fonts/root_beer_med')
		root_beer_med_inverted = newfont('fonts/root_beer_med_inverted')
		root_beer_med_outline = newfont('fonts/root_beer_med_outline')

		root_beer_small = newfont('fonts/root_beer_small')

		fonts_loaded = true
	end
end

fade = newimagetable('images/fade', 400, 240, 34)
fade_white = newimagetable('images/fade_white', 400, 240, 34)

if platform == 'peedee' then
	savecheck()
	load_common_sfx()
	load_common_fonts()
end

-- This function returns the inputted number, with the ordinal suffix tacked on at the end (as a string)
function ordinal(num, balls)
	local m10 = num % 10 -- This is the number, modulo'd by 10.
	local m100 = num % 100 -- This is the number, modulo'd by 100.
	if m10 == 1 and m100 ~= 11 then -- If the number ends in 1 but NOT 11...
		return tostring(num) .. text('st' .. tostring(balls and '_balls' or '')) -- add "st" on.
	elseif m10 == 2 and m100 ~= 12 then -- If the number ends in 2 but NOT 12...
		return tostring(num) .. text('nd' .. tostring(balls and '_balls' or '')) -- add "nd" on,
	elseif m10 == 3 and m100 ~= 13 then -- and if the number ends in 3 but NOT 13...
		return tostring(num) .. text('rd' .. tostring(balls and '_balls' or '')) -- add "rd" on.
	else -- If all those checks passed us by,
		return tostring(num) .. text('th' .. tostring(balls and '_balls' or '')) -- then it ends in "th".
	end
end

-- http://lua-users.org/wiki/FormattingNumbers
function commalize(amount)
  	local formatted = amount
  	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
	  		break
	  	end
    end
  	return formatted
end

-- TODO: catalog app feature
-- TODO: catalog app billboard
-- TODO: catalog app wide

if platform == 'peedee' then
	function pd.gameWillTerminate()
		savegame()
	end

	function pd.deviceWillSleep()
		savegame()
	end

	function rumble()
		-- noop
	end

	scenemanager:switchscene(title)

	function pd.update()
		-- resetting daily score if need be
		local time = getgmttime()
		if (save.lastdaily.score ~= 0) and not (save.lastdaily.year == time.year and save.lastdaily.month == time.month and save.lastdaily.day == time.day) then
			 save.lastdaily.score = 0
		end

		-- Catch-all stuff ...
		gfx.sprite.update()
		pd.timer.updateTimers()
	end

	function drawontop()
		-- noop
	end
elseif platform == 'love' then
	function love.quit()
		savegame()
	end

	function rescale(newscale)
		scale = newscale
		love.window.setMode(400 * newscale, 240 * newscale, {resizable = true, minwidth = 400, minheight = 240})
	end

	function love.keypressed(key)
		save.gamepad = gamepad
		gamepad = false
		if key == 'escape' and vars ~= nil then
			if vars.player_1 ~= nil and vars.player_1.handler ~= 'gameover' and vars.player_1.handler ~= 'results' then -- playing the game
				if vars.paused then
					game:unpause()
				else
					game:pause()
				end
			elseif vars.handler == 'remap' then -- remapping keyboard controls
				options:restorebuttons()
				playsound(sfx_back)
				vars.remap_step = 1
				vars.handler = 'options'
				savegame()
			end
		end
		if key == 'f11' then
			fullscreen = not fullscreen
			love.window.setFullscreen(fullscreen)
		end
	end

	function love.keyreleased(key)
		save.gamepad = gamepad
		gamepad = false
	end

	function love.gamepadpressed(joystick, button)
		if vars.handler ~= 'remap' then
			current_joystick = joystick
			local key
			if button == 'start' then
				key = 'escape'
			elseif button == 'dpup' then
				key = save.up
			elseif button == 'dpdown' then
				key = save.down
			elseif button == 'dpleft' then
				key = save.left
			elseif button == 'dpright' then
				key = save.right
			elseif button == 'a' then
				key = save.primary
			elseif button == 'b' then
				key = save.secondary
			end
			gamepad = true
			love.keypressed(key)
		end
	end

	function love.gamepadreleased(joystick, button)
		if vars.handler ~= 'remap' then
			current_joystick = joystick
			local key
			if button == 'start' then
				key = 'escape'
			elseif button == 'back' then
				key = 'r'
			elseif button == 'dpup' then
				key = save.up
			elseif button == 'dpdown' then
				key = save.down
			elseif button == 'dpleft' then
				key = save.left
			elseif button == 'dpright' then
				key = save.right
			elseif button == 'a' then
				key = save.primary
			elseif button == 'b' then
				key = save.secondary
			end
			gamepad = true
			love.keyreleased(key)
		end
	end

	function love.gamepadaxis(joystick, axis, value)
		if vars.handler ~= 'remap' then
			local pressedkey = ''
			local releasedkey = ''
			if axis == 'lefty' and not (lstick_left or lstick_right) then
				if value > save.deadzone then
					if not lstick_down then
						pressedkey = save.down
					end
					lstick_down = true
				else
					if lstick_down then
						releasedkey = save.down
					end
					lstick_down = false
				end
				if value < -save.deadzone then
					if not lstick_up then
						pressedkey = save.up
					end
					lstick_up = true
				else
					if lstick_up then
						releasedkey = save.up
					end
					lstick_up = false
				end
			elseif axis == 'leftx' and not (lstick_down or lstick_up) then
				if value > save.deadzone then
					if not lstick_right then
						pressedkey = save.right
					end
					lstick_right = true
				else
					if lstick_right then
						releasedkey = save.right
					end
					lstick_right = false
				end
				if value < -save.deadzone then
					if not lstick_left then
						pressedkey = save.left
					end
					lstick_left = true
				else
					if lstick_left then
						releasedkey = save.left
					end
					lstick_left = false
				end
			end
			if pressedkey ~= '' then
				gamepad = true
				current_joystick = joystick
				love.keypressed(pressedkey)
			end
			if releasedkey ~= '' then
				gamepad = true
				current_joystick = joystick
				love.keyreleased(releasedkey)
			end
		end
	end

	function love.joystickremoved()
		-- pause game if it's running and a controller is disconnected
		if vars ~= nil and vars.player_1 ~= nil and vars.player_1.handler ~= 'gameover' and vars.player_1.handler ~= 'results' and not vars.paused then game:pause() end
	end

	function rumble(left, right, duration)
		if save.rumble and save.gamepad and current_joystick:isVibrationSupported() then
			current_joystick:setVibration(left, right, duration)
		end
	end

	function love.focus(f)
		if f then
			love.mouse.setVisible(false)
		else
			love.mouse.setVisible(true)
			-- pause game if it's running and window's defocused
			if vars ~= nil and vars.player_1 ~= nil and vars.player_1.handler ~= 'gameover' and vars.player_1.handler ~= 'results' and not vars.paused then game:pause() end
		end
	end

	function love.resize(w, h)
		local fw
		local fh
		if save.clean_scaling then
			fw = floor(w / 400)
			fh = floor(h / 240)
		else
			fw = w / 400
			fh = h / 240
		end
		if fw < fh and fw >= save.scale then
			scale = fw
		elseif fh < fw and fh >= save.scale then
			scale = fh
		elseif fw == fh and fw >= save.scale then
			scale = fw
		end
	end

	function love.load()
		savecheck()
		load_common_sfx()
		load_common_fonts()

		love.window.setIcon(icon)

		min_dt = 1 / fps
		next_time = love.timer.getTime()

		rescale(2)

		scenemanager:switchscene(title)

		gamestate.registerEvents()
	end

	function love.update(dt)
		next_time = next_time + min_dt

		-- resetting daily score if need be
		local time = getgmttime()
		if (save.lastdaily.score ~= 0) and not (save.lastdaily.year == time.year and save.lastdaily.month == time.month and save.lastdaily.day == time.day) then
			 save.lastdaily.score = 0
		end

		timer.update(dt, transition)

		if vars ~= nil and not vars.paused then
			timer.update(dt)
		end

		if music ~= nil then
			music:setVolume(volume)
			if not music:isPlaying() then music = nil end
		end
	end

	function love.draw()
		gfx.clear(0, 0, 0, 1)
		gfx.setColor(1, 1, 1, 1)

		local lbw = false
		local lbh = false

		local ww, wh, flags = love.window.getMode()
		if ww > 400 * scale then lbw = true end
		if wh > 240 * scale then lbh = true end

		if lbw then gfx.translate(((floor(ww / 2) * 2) - (400 * scale)) / 2, 0) end
		if lbh then gfx.translate(0, ((floor(wh / 2) * 2) - (240 * scale)) / 2) end

		gfx.setScissor(((lbw and (((floor(ww / 2) * 2) - (400 * scale)) / 2)) or 0), ((lbh and (((floor(wh / 2) * 2) - (240 * scale)) / 2)) or 0), 400 * scale, 240 * scale)

		gfx.clear(1, 1, 1, 1)

		gfx.scale(scale)
	end

	function drawontop()
		setcolor(255, 255, 255, 1, 'black')

		if transitioning then
			drawimagetable(fade_white, floor(value('transition')), 0, 0)
		end

		gfx.setScissor()

		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
	end
end