local pd
local gfx
local center
local right
local floor = math.floor

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	import 'modeselect'
	import 'howtoplay'
	import 'statistics'
	import 'options'
	import 'credits'

	class('title').extends(gfx.sprite)
	function title:init(...)
		title.super.init(self)
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

	modeselect = require 'modeselect'
	howtoplay = require 'howtoplay'
	statistics = require 'statistics'
	options = require 'options'
	credits = require 'credits'

	title = {}
	function title:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

-- NOTE: rubdubdub check
-- NOTE: on rubdubdub, move to drink scene
-- NOTE: make drink scene

function title:initialize(args)
	assets = {
		-- bg
		bg = newimage('images/title/bg'),
		clouds = newimage('images/game/clouds'),
		parallax_1 = newimage('images/title/parallax_1'),
		parallax_2 = newimage('images/title/parallax_2'),
		parallax_3 = newimage('images/title/parallax_3'),

		-- logo
		logo = newimage('images/title/logo'),

		-- arrows for the selection board
		arrow_1 = newimage('images/title/arrow_1'),
		arrow_2 = newimage('images/title/arrow_2'),
		arrow_3 = newimage('images/title/arrow_3'),
		arrow_4 = newimage('images/title/arrow_4'),

		arrow_shadow_1 = newimage('images/title/arrow_shadow_1'),
		arrow_shadow_2 = newimage('images/title/arrow_shadow_2'),
		arrow_shadow_3 = newimage('images/title/arrow_shadow_3'),
		arrow_shadow_4 = newimage('images/title/arrow_shadow_4'),

		pole = newimage('images/title/pole'),
	}

	vars = {
		returning = args[1] or false,
		from = args[2] or nil,
		handler = '',
		selections = {'modeselect', 'howtoplay', 'statistics', 'options', 'credits'},
		random_arrows = {},
		selection = 1,
		bonk_offset = 0,
		hit_edge = false,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function()
		if vars.returning then
			vars.handler = 'title'
		else
			vars.handler = 'start'
		end
	end)

	if vars.returning then
		newtimer('parallax', transitiontime, -700, -600, 'outSine')
	else
		newtimer('parallax', 1, 0, 0)
	end
	loopingtimer('clouds', 125000, 0, -1200, 'linear')

	if vars.from ~= nil then
		for i = 1, #vars.selections do
			if vars.selections[i] == vars.from then
				vars.selection = i
				break
			end
		end
	end

	randomseed()

	for i = 1, #vars.selections do
		local rand = randInt(1, 4)
		table.insert(vars.random_arrows, rand)
	end

	newmusic('audio/music/title', true, 1.2)
end

function title:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
		if pd.buttonJustPressed('a') then self:keypressed('a') end

		local ticks = pd.getCrankTicks(4)
		if vars.handler == 'title' then
			if ticks > 0 then
				vars.selection = vars.selection + 1
				if vars.selection > #vars.selections then
					vars.selection = #vars.selections
					if not vars.hit_edge then
						vars.bonk_offset = 5
						playsound(sfx_menu_bonk)
						vars.hit_edge = true
					end
				else
					playsound(sfx_menu_move)
					vars.hit_edge = false
				end
			elseif ticks < 0 then
				vars.selection = vars.selection - 1
				if vars.selection < 1 then
					vars.selection = 1
					if not vars.hit_edge then
						vars.bonk_offset = -5
						playsound(sfx_menu_bonk)
						vars.hit_edge = true
					end
				else
					playsound(sfx_menu_move)
					vars.hit_edge = false
				end
			end
		end
	end

	vars.bonk_offset = vars.bonk_offset - (vars.bonk_offset * 0.5)
end

function title:draw()
	local parallax = value('parallax')

	drawimage(assets.bg, 0, 0)
	drawimage(assets.clouds, (value('clouds') + (parallax * 0.2)) % -1200, 0)
	drawimage(assets.parallax_1, floor((parallax * 0.4) / 4) * 4, 0)
	drawimage(assets.parallax_2, floor((parallax * 0.7) / 2) * 2, 0)
	drawimage(assets.parallax_3, parallax * 1, 0)

	drawimage(assets.logo, 35 + floor((parallax * 1.5) / 2) * 2, 35)

	-- drawing the selections
	local arrow_offset

	drawimage(assets.pole, 905 + (floor((parallax * 1.2) / 4) * 4), 0)

	for i = 1, #vars.selections do
		-- offset the arrow drawing depending on its direction
		if vars.random_arrows[i] % 2 == 0 then arrow_offset = 7 else arrow_offset = -7 end

		-- draw the arrows' shadows
		drawimage(assets['arrow_shadow_' .. vars.random_arrows[i]], 965 + arrow_offset + (parallax * 1.45), 60 + (40 * i) - (#vars.selections * 20))

		-- draw the arrows
		drawimage(assets['arrow_' .. vars.random_arrows[i]], 995 + arrow_offset + (floor((parallax * 1.5) / 4) * 4), 60 + (40 * i) - (#vars.selections * 20))

		-- now draw the text.
		drawtext(vars.selection == i and root_beer_outline or root_beer, text('title_' .. vars.selections[i]), 1100 + floor((parallax * 1.5) / 4) * 4, 85 + (40 * i) - (#vars.selections * 20) + (vars.selection == i and (-2 + vars.bonk_offset) or 0), center)
	end

	drawontop()
end

function title:keypressed(button)
	if vars.handler == 'start' then
		if button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			playsound(sfx_place_block)
			playsound(sfx_match)
			vars.handler = ''
			resettimer('parallax', 1000, 0, -600, 'inOutSine', function()
				vars.handler = 'title'
			end)
		end
	elseif vars.handler == 'title' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.selection = vars.selection - 1
			if vars.selection < 1 then
				vars.selection = 1
				vars.bonk_offset = -5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
				vars.hit_edge = false
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.selection = vars.selection + 1
			if vars.selection > #vars.selections then
				vars.selection = #vars.selections
				vars.bonk_offset = 5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
				vars.hit_edge = false
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			vars.handler = ''
			resettimer('parallax', 1000, -600, 0, 'inOutSine', function()
				vars.handler = 'start'
			end)
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			playsound(sfx_select)
			local sel = vars.selections[vars.selection]
			vars.handler = ''
			resettimer('parallax', transitiontime, -600, -700, 'inSine')
			if sel == 'modeselect' then
				scenemanager:transitionscene(modeselect)
			elseif sel == 'howtoplay' then
				scenemanager:transitionscene(howtoplay)
			elseif sel == 'statistics' then
				scenemanager:transitionscene(statistics)
			elseif sel == 'options' then
				scenemanager:transitionscene(options)
			elseif sel == 'credits' then
				scenemanager:transitionscene(credits)
			end
		end
	end
end

if platform == 'love' then return title end