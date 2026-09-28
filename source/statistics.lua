local pd
local gfx
local center
local right

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
	}

	vars = {
		handler = '',
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'statistics' end)
end

function statistics:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('b') then self:keypressed('b') end
	end
end

function statistics:draw()
	-- NOTE: BG image for statistics menu

	-- NOTE: draw all the statistics

	drawontop()
end

function statistics:keypressed(button)
	if vars.handler == 'statistics' then
		if button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'statistics')
		end
	end
end

if platform == 'love' then return statistics end