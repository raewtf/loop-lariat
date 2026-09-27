local pd
local gfx
local center
local right

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	import 'game'

	class('howtoplay').extends(gfx.sprite)
	function howtoplay:init(...)
		howtoplay.super.init(self)
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

	game = require 'game'

	howtoplay = {}
	function howtoplay:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function howtoplay:initialize(args)
	assets = {
		bg_1 = newimage('images/howtoplay/bg_1'),
		bg_2 = newimage('images/howtoplay/bg_2'),
		bg_3 = newimage('images/howtoplay/bg_3'),
		bg_4 = newimage('images/howtoplay/bg_4'),
		bg_5 = newimage('images/howtoplay/bg_5'),
		bg_6 = newimage('images/howtoplay/bg_6'),
	}

	vars = {
		handler = '',
		page = 1,
		hit_edge = false,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'howtoplay' end)
end

function howtoplay:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('left') then self:keypressed('left') end
		if pd.buttonJustPressed('right') then self:keypressed('right') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end

		local ticks = pd.getCrankTicks(4)
		if vars.handler == 'howtoplay' then
			if ticks > 0 then
				vars.page = vars.page + 1
				if vars.page > 6 then
					vars.page = 6
					if not vars.hit_edge then
						playsound(sfx_menu_bonk)
						vars.hit_edge = true
					end
				else
					vars.hit_edge = false
					playsound(sfx_menu_move)
				end
			elseif ticks < 0 then
				vars.page = vars.page - 1
				if vars.page < 1 then
					vars.page = 1
					if not vars.hit_edge then
						playsound(sfx_menu_bonk)
						vars.hit_edge = true
					end
				else
					vars.hit_edge = false
					playsound(sfx_menu_move)
				end
			end
		end
	end
end

function howtoplay:draw()
	drawimage(assets['bg_' .. vars.page], 0, 0)

	if vars.page % 2 == 1 then
		drawtext(root_beer_med, text('howtoplay_' .. vars.page), 30, 45)
	else
		drawtext(root_beer_med, text('howtoplay_' .. vars.page), 370, 35, right)
	end

	if vars.page == 2 then
		drawtext(root_beer_med, text('block_label_lasso'), 115, 45)
		drawtext(root_beer_med, text('block_label_outlaw'), 145, 85)
		drawtext(root_beer_med, text('block_label_tnt'), 125, 135)
		drawtext(root_beer_med, text('block_label_tumble'), 145, 180)
	end

	drawontop()
end

function howtoplay:keypressed(button)
	if vars.handler == 'howtoplay' then
		if button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
			vars.page = vars.page - 1
			if vars.page < 1 then
				vars.page = 1
				playsound(sfx_menu_bonk)
			else
				vars.hit_edge = false
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
			vars.page = vars.page + 1
			if vars.page > 6 then
				vars.page = 6
				playsound(sfx_menu_bonk)
			else
				vars.hit_edge = false
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'howtoplay')
		end
	end
end

if platform == 'love' then return howtoplay end