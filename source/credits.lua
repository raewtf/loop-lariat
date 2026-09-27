local pd
local gfx
local center
local right

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	class('credits').extends(gfx.sprite)
	function credits:init(...)
		credits.super.init(self)
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

	credits = {}
	function credits:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function credits:initialize(args)
	assets = {
	}

	vars = {
		handler = '',
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'credits' end)

	-- TODO: newmusic()
end

function credits:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('left') then self:keypressed('left') end
		if pd.buttonJustPressed('right') then self:keypressed('right') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
	end

	-- TODO: use crank to scroll horizontally
end

function credits:draw()
	-- TODO: credits screen
	-- TODO: list of wanted posters with photographs, tacked up on a bulletin board or somethin'
	-- what they're wanted for (what they did in-game) listed underneath
	-- arbitrary reward counts

	drawontop()
end

function credits:keypressed(button)
	if vars.handler == 'credits' then
		-- TODO: use D-pad to scroll horizontally
		if button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'credits')
		end
	end
end

if platform == 'love' then return credits end