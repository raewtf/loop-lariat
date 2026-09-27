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

-- TODO: how to play screen

function howtoplay:initialize(args)
	assets = {
	}

	vars = {
		handler = '',
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'howtoplay' end)
end

function howtoplay:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('left') then self:keypressed('left') end
		if pd.buttonJustPressed('right') then self:keypressed('right') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
		if pd.buttonJustPressed('a') then self:keypressed('a') end
	end
end

function howtoplay:draw()
	drawontop()
end

function howtoplay:keypressed(button)
	if vars.handler == 'howtoplay' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
		elseif button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'howtoplay')
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
		end
	end
end

if platform == 'love' then return howtoplay end