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
			if not transitioning then
				menu:addMenuItem(text('slide_back'), function()
					scenemanager:transitionscene(title, true, 'credits')
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

	credits = {}
	function credits:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function credits:initialize(args)
	assets = {
		bg = newimage(save.image_path .. '/credits/bg'),
	}

	vars = {
		handler = '',
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'credits' end)
end

function credits:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('b') then self:keypressed('b') end
	end
end

function credits:draw()
	drawimage(assets.bg, 0, 0)

	drawtext(root_beer, text('credits_name_1'), 113, 166, center)
	drawtext(root_beer_med, text('credits_desc_1'), 116, 193, center)

	drawtext(root_beer_med, text('accomplices'), 215, 30)

	drawtext(root_beer_med, text('credits_name_2'), 210, 55)
	drawtext(root_beer_med, text('credits_desc_2'), 375, 70, right)

	drawtext(root_beer_med, text('credits_name_3'), 210, 90)
	drawtext(root_beer_med, text('credits_desc_3'), 371, 105, right)

	drawtext(root_beer_med, text('credits_name_4'), 210, 125)
	drawtext(root_beer_med, text('credits_desc_4'), 365, 140, right)

	drawtext(root_beer_small, text('credits_name_5'), 210, 165)
	drawtext(root_beer_med, text('credits_desc_5'), 365, 213, right)

	drawontop()
end

function credits:keypressed(button)
	if vars.handler == 'credits' then
		if button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'credits')
		end
	end
end

if platform == 'love' then return credits end