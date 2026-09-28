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

	class('statistics').extends(gfx.sprite)
	function statistics:init(...)
		statistics.super.init(self)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		function pd.gameWillPause()
			local menu = pd.getSystemMenu()
			menu:removeAllMenuItems()
			if not transitioning then
				menu:addMenuItem(text('slide_back'), function()
					scenemanager:transitionscene(title, true, 'statistics')
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

	statistics = {}
	function statistics:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function statistics:initialize(args)
	assets = {
		bg = newimage(save.image_path .. '/statistics/bg'),
	}

	vars = {
		handler = '',
		items = {
			'playtime',
			'gametime',
			'cumulative_score',

			'blocks_placed',
			'total_lassos',
			'outlaws_captured',
			'dynamites_exploded',

			'total_played',
			'arcade_played',
			'time_played',
			'marathon_played',
			'daily_played',
			'chill_played',

			-- TODO: add VS stats alongside VS things
		},
		list_height = 170,
		scroll_offset = 0,
		scroll_target = 0,
		scrolling_up = false,
		scrolling_down = false,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'statistics' end)

	for i = 1, #vars.items do
		vars.list_height = vars.list_height - 30
	end
end

function statistics:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end

		if pd.buttonJustReleased('up') then self:keyreleased('up') end
		if pd.buttonJustReleased('down') then self:keyreleased('down') end
		if pd.buttonJustReleased('b') then self:keyreleased('b') end

		-- TODO: use crank to scroll too!
		vars.scroll_target = vars.scroll_target - floor(pd.getCrankChange())
		if vars.scroll_target > 0 then vars.scroll_target = 0 end
		if vars.scroll_target < vars.list_height then vars.scroll_target = vars.list_height end
	end

	if vars.scrolling_up then
		vars.scroll_target = vars.scroll_target + 10
		if vars.scroll_target > 0 then
			vars.scroll_target = 0
		end
	elseif vars.scrolling_down then
		vars.scroll_target = vars.scroll_target - 10
		if vars.scroll_target < vars.list_height then
			vars.scroll_target = vars.list_height
		end
	end

	vars.scroll_offset = vars.scroll_offset + ((vars.scroll_target - vars.scroll_offset) * 0.5)
end

function statistics:draw()
	drawimage(assets.bg, 0, 0)

	local offset = vars.scroll_offset

	drawtext(root_beer, text('title_statistics'), 200, 15 + offset, center)

	for i = 1, #vars.items do
		drawtext(root_beer_med, text('statistics_' .. vars.items[i]), 40, 30 + (30 * i) + offset)

		local to_draw
		if vars.items[i] == 'playtime' or vars.items[i] == 'gametime' then
			to_draw = self:gethms(save[vars.items[i]])
		elseif vars.items[i] == 'total_played' then
			to_draw = commalize(save.arcade_played + save.time_played + save.marathon_played + save.daily_played + save.chill_played)
		else
			to_draw = commalize(save[vars.items[i]])
		end
		drawtext(root_beer, to_draw, 360, 20 + (30 * i) + offset, right)
	end

	drawontop()
end

function statistics:gethms(num)
	local hours = floor((num/30) / 3600)
	local minutes = floor((num/30) / 60 - (hours * 60))
	local seconds = floor((num/30) - (hours * 3600) - (minutes * 60))
	return hours .. text('statistics_h') .. minutes .. text('statistics_m') .. seconds .. text('statistics_s')
end

function statistics:keypressed(button)
	if vars.handler == 'statistics' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.scrolling_up = true
			vars.scrolling_down = false
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.scrolling_up = false
			vars.scrolling_down = true
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'statistics')
		end
	end
end

function statistics:keyreleased(button)
	if vars.handler == 'statistics' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.scrolling_up = false
			vars.scrolling_down = false
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.scrolling_up = false
			vars.scrolling_down = false
		end
	end
end

if platform == 'love' then return statistics end