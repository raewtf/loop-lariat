local pd
local gfx
local center
local right

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	class('drink').extends(gfx.sprite)
	function drink:init(...)
		drink.super.init(self)
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

	drink = {}
	function drink:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

-- TODO: create the drink scene

function drink:initialize(args)
	assets = {
	}

	vars = {
		handler = '',
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'drink' end)
end

function drink:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('a') then self:keypressed('a') end
	end
end

function drink:draw()
	drawontop()
end

function drink:keypressed(button)
	if vars.handler == 'drink' then
		if button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
		end
	end
end

if platform == 'love' then return drink end