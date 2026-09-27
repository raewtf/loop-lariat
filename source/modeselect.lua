local pd
local gfx
local center
local right
local rad = math.rad
local sin = math.sin
local cos = math.cos
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

-- TODO: only one daily play per day

function modeselect:initialize(args)
	assets = {
		bg_1 = newimage('images/modeselect/bg_1'),
		bg_2 = newimage('images/modeselect/bg_2'),
		bg_3 = newimage('images/modeselect/bg_3'),

		chamber = newimagetable('images/modeselect/chambers', 210, 210, 20),
		box = newnineslice('images/modeselect/box', 17, 17, 30, 30),
		text_box = newimage(300, 95)
	}

	vars = {
		handler = '',
		selections = {},
		selection = 1,
		old_chamber = 0,
		chamber = 0,
		chamber_target = 0,
		slerp = 0,
		slerp_target = 0,
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

	vars.chamber = vars.chamber + ((vars.chamber_target - vars.chamber) * 0.5)
	vars.slerp = vars.slerp + ((vars.slerp_target - vars.slerp) * 0.5)
end

function modeselect:draw()
	drawimage(assets.bg_1, 0, 0)
	drawimage(assets.bg_2, floor(value('bg_2') / 2) * 2, 0)
	drawimage(assets.bg_3, floor(value('bg_3') / 4) * 4, 0)

	drawtext(root_beer_outline, text('modeselect_prompt'), 150, 35, center)

	-- backing for current game mode highlight
	setcolor(0, 0, 0, 1, 'black')
	fillrect(0, 97, 400, 43)
	setcolor(255, 255, 255, 1, 'black')

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

			drawtext(root_beer_outline, text('modeselect_' .. vars.selections[i]), 400 - (cosc * 115), 102 - (sinc * 30), right)
		end
		slerp_offset = slerp_offset - 360 / #vars.selections
	end

	-- NOTE: draw some reactive triangles to indicate scroll direction

	-- pistol chamber that rotates
	drawimagetable(assets.chamber, (floor(vars.chamber / 3) % 20) + 1, 290, 15)

	-- game mode description
	drawimage(assets.text_box, 10, 135)

	-- NOTE: modal if selected 'arcade' or 'time', to determine length of time

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
			playsound(sfx_select)
			fademusic()
			local sel = vars.selections[vars.selection]
			if sel == 'arcade' then
				scenemanager:transitionscene(game, 'arcade')
			elseif sel == 'time' then
				scenemanager:transitionscene(game, 'time')
			elseif sel == 'marathon' then
				scenemanager:transitionscene(game, 'marathon')
			elseif sel == 'daily' then
				scenemanager:transitionscene(game, 'daily')
			elseif sel == 'vs_2p' then
				scenemanager:transitionscene(game, 'vs', '2p')
			elseif sel == 'vs_com' then
				scenemanager:transitionscene(game, 'vs', 'cpu')
			elseif sel == 'chill' then
				scenemanager:transitionscene(game, 'chill')
			end
		end
	end
end

if platform == 'love' then return modeselect end