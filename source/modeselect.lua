local pd
local gfx
local center
local right
local rad = math.rad
local sin = math.sin
local cos = math.cos
local find = string.find
local floor = math.floor

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	class('modeselect').extends(gfx.sprite)
	function modeselect:init(...)
		modeselect.super.init(self)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		function pd.gameWillPause()
			local menu = pd.getSystemMenu()
			menu:removeAllMenuItems()
			if not transitioning then
				menu:addMenuItem(text('slide_back'), function()
					scenemanager:transitionscene(title, true, 'modeselect')
				end)
			end
		end

		self:initialize(args)
		gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
			self:draw()
		end)

		self:add()
	end
elseif platform == 'love' then
	gfx = love.graphics
	center = 'center'
	right = 'right'

	modeselect = {}
	function modeselect:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

-- NOTE: display best score for current mode
-- NOTE: display save.lastdaily.score for daily run, if it's somethin' other than zero.

function modeselect:initialize(args)
	assets = {
		bg_1 = newimage('images/modeselect/bg_1'),
		bg_2 = newimage('images/modeselect/bg_2'),
		bg_3 = newimage('images/modeselect/bg_3'),

		chamber = newimagetable('images/modeselect/chambers', 210, 210, 20),

		box = newnineslice('images/modeselect/box', 17, 17, 30, 30),
		text_box = newimage(300, 95),

		half = newimage('images/half'),
		modal = newimage(300, 190),
	}

	pushcontext(assets.modal)
		drawnineslice(assets.box, 0, 0, 300, 190)
	popcontext()

	vars = {
		handler = '',
		selections = {},
		selection = 1,
		old_chamber = 0,
		chamber = 0,
		chamber_target = 0,
		slerp = 0,
		slerp_target = 0,
		modal_bonk_offset = 0,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'modeselect' end)

	table.insert(vars.selections, 'arcade')
	table.insert(vars.selections, 'time')
	table.insert(vars.selections, 'marathon')
	table.insert(vars.selections, 'daily')
	-- TODO: re-enable these once i actually get 2P working. sorry jammers!
	-- table.insert(vars.selections, 'vs_com')
	-- only show VS 2P mode in the PC build.
	-- if platform == 'love' then table.insert(vars.selections, 'vs_2p') end
	table.insert(vars.selections, 'chill')

	if getreduceflashing() then
		newtimer('bg_2', 1, 0, 0)
		newtimer('bg_3', 1, 0, 0)
	else
		loopingtimer('bg_2', 3000, 0, -65, 'linear')
		loopingtimer('bg_3', 2500, -66, -1, 'linear')
	end

	self:text_box()
end

function modeselect:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
		if pd.buttonJustPressed('a') then self:keypressed('a') end

		-- NOTE: add crank selecting/hit edge variable to decision modal

		local ticks = pd.getCrankTicks(6)
		if vars.handler == 'modeselect' then
			if ticks > 0 then
				vars.selection = vars.selection + 1
				if vars.selection > #vars.selections then
					vars.selection = 1
				end
				self:text_box()
				playsound(sfx_menu_move)
				vars.chamber_target = vars.chamber_target + (360 / 6)
				vars.slerp_target = vars.slerp_target + (360 / #vars.selections)
			elseif ticks < 0 then
				vars.selection = vars.selection - 1
				if vars.selection < 1 then
					vars.selection = #vars.selections
				end
				self:text_box()
				playsound(sfx_menu_move)
				vars.chamber_target = vars.chamber_target - (360 / 6)
				vars.slerp_target = vars.slerp_target - (360 / #vars.selections)
			end
		end
	end

	local time = getgmttime()
	vars.dailyrunnable = not (save.lastdaily.year == time.year and save.lastdaily.month == time.month and save.lastdaily.day == time.day)

	vars.chamber = vars.chamber + ((vars.chamber_target - vars.chamber) * 0.5)
	vars.slerp = vars.slerp + ((vars.slerp_target - vars.slerp) * 0.5)

	vars.modal_bonk_offset = vars.modal_bonk_offset - (vars.modal_bonk_offset * 0.5)
end

function modeselect:draw()
	drawimage(assets.bg_1, 0, 0)
	drawimage(assets.bg_2, floor(value('bg_2') / 2) * 2, 0)
	drawimage(assets.bg_3, floor(value('bg_3') / 4) * 4, 0)

	drawtext(root_beer_outline, text('modeselect_prompt'), 150, 25, center)
	drawtext(root_beer_med_outline, text('modeselect_prompt_2'), 150, 55, center)

	-- backing for current game mode highlight
	setcolor(0, 0, 0, 1, 'black')
	fillrect(0, 97, 400, 43)
	setcolor(255, 255, 255, 1, 'black')

	if vars.selections[vars.selection] == 'daily' and not vars.dailyrunnable then
		local time = getgmttime()
		if time.hour < 23 then
			drawtext(root_beer_med_inverted, text('modeselect_refreshes_in') .. (24 - time.hour) .. text('modeselect_h'), 10, 111)
		elseif time.minute < 59 then
			drawtext(root_beer_med_inverted, text('modeselect_refreshes_in') .. (60 - time.minute) .. text('modeselect_m'), 10, 111)
		else
			drawtext(root_beer_med_inverted, text('modeselect_refreshes_in') .. (60 - time.second) .. text('modeselect_s'), 10, 111)
		end
	end

	-- rotation logic for current game mode highlight
	local slerp_offset = vars.slerp
	local radc
	local sinc
	local cosc

	-- drawing the current game mode highlight
	for i = 1, #vars.selections do
		if i == vars.selection then
			radc = rad(slerp_offset)
			sinc = sin(radc)
			cosc = cos(radc)

			drawtext(root_beer_inverted, text('modeselect_' .. vars.selections[i]), 400 - (cosc * 115), 104 - (sinc * 20), right)
		end
		slerp_offset = slerp_offset - 360 / #vars.selections
	end

	-- pistol chamber that rotates
	drawimagetable(assets.chamber, (floor(vars.chamber / 3) % 20) + 1, 290, 15)

	-- game mode description
	drawimage(assets.text_box, 10, 135)

	if find(vars.handler, '_modal') then
		drawimage(assets.half, 0, 0)
		drawimage(assets.modal, 50, 25)

		drawtext(root_beer_med, text('modeselect_time_prompt'), 200, 50, center)

		for i = 1, #vars.modal_selections do
			drawtext(vars.modal_selection == i and root_beer_outline or root_beer, text(vars.modal_selections[i]), 200, 100 + (30 * i) - (15 * #vars.modal_selections) + (vars.modal_selection == i and (-2 + vars.modal_bonk_offset) or 0), center)
		end
	end

	drawontop()
end

function modeselect:text_box()
	assets.text_box = newimage(300, 95)
	pushcontext(assets.text_box)
		drawnineslice(assets.box, 0, 0, 300, 95)
		drawtext(root_beer_med, text('modeselect_' .. vars.selections[vars.selection] .. '_desc'), 20, 21)
	popcontext()
end

function modeselect:keypressed(button)
	if vars.handler == 'modeselect' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.selection = vars.selection + 1
			if vars.selection > #vars.selections then
				vars.selection = 1
			end
			self:text_box()
			playsound(sfx_menu_move)
			vars.chamber_target = vars.chamber_target + (360 / 6)
			vars.slerp_target = vars.slerp_target + (360 / #vars.selections)
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.selection = vars.selection - 1
			if vars.selection < 1 then
				vars.selection = #vars.selections
			end
			self:text_box()
			playsound(sfx_menu_move)
			vars.chamber_target = vars.chamber_target - (360 / 6)
			vars.slerp_target = vars.slerp_target - (360 / #vars.selections)
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'modeselect')
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			local moving = true
			local sel = vars.selections[vars.selection]
			if sel == 'arcade' then
				vars.modal_selections = {'1min', '5min', '10min'}
				vars.modal_selection = 1
				vars.handler = 'arcade_modal'
				playsound(sfx_select)
				setmusicvolume(0.5)
				moving = false
			elseif sel == 'time' then
				vars.modal_selections = {'1min', '5min', '10min'}
				vars.modal_selection = 1
				vars.handler = 'time_modal'
				playsound(sfx_select)
				setmusicvolume(0.5)
				moving = false
			elseif sel == 'marathon' then
				scenemanager:transitionscene(game, 'marathon')
			elseif sel == 'daily' then
				if vars.dailyrunnable then
					scenemanager:transitionscene(game, 'daily')
					save.lastdaily = getgmttime()
					save.lastdaily.score = 0
					save.lastdaily.sent = false
				else
					playsound(sfx_menu_bonk)
					moving = false
				end
			elseif sel == 'vs_2p' then
				scenemanager:transitionscene(game, 'vs', '2p')
			elseif sel == 'vs_com' then
				scenemanager:transitionscene(game, 'vs', 'com')
			elseif sel == 'chill' then
				scenemanager:transitionscene(game, 'chill')
			end
			if moving then
				playsound(sfx_select)
				fademusic()
			end
		end
	elseif find(vars.handler, '_modal') then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.modal_selection = vars.modal_selection - 1
			if vars.modal_selection < 1 then
				vars.modal_selection = 1
				vars.modal_bonk_offset = -5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.modal_selection = vars.modal_selection + 1
			if vars.modal_selection > #vars.modal_selections then
				vars.modal_selection = #vars.modal_selections
				vars.modal_bonk_offset = 5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			setmusicvolume(1)
			vars.handler = 'modeselect'
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			playsound(sfx_select)
			fademusic()
			local sel = vars.modal_selections[vars.modal_selection]
			if sel == '1min' then
				if vars.handler == 'arcade_modal' then
					scenemanager:transitionscene(game, 'arcade', 60000)
				elseif vars.handler == 'time_modal' then
					scenemanager:transitionscene(game, 'time', 60000)
				end
			elseif sel == '5min' then
				if vars.handler == 'arcade_modal' then
					scenemanager:transitionscene(game, 'arcade', 300000)
				elseif vars.handler == 'time_modal' then
					scenemanager:transitionscene(game, 'time', 300000)
				end
			elseif sel == '10min' then
				if vars.handler == 'arcade_modal' then
					scenemanager:transitionscene(game, 'arcade', 600000)
				elseif vars.handler == 'time_modal' then
					scenemanager:transitionscene(game, 'time', 600000)
				end
			end
		end
	end
end

if platform == 'love' then return modeselect end