local pd
local gfx
local center
local right

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right

	class('options').extends(gfx.sprite)
	function options:init(...)
		options.super.init(self)
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

	options = {}
	function options:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function options:initialize(args)
	assets = {
		bg = newimage('images/options/bg'),
	}

	vars = {
		handler = '',
		selections = {'music', 'sfx', 'reduceflashing'},
		selection = 1,
		bonk_offset = 0,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'options' end)

	if platform == 'love' then
		table.insert(vars.selections, 'rumble')
		table.insert(vars.selections, 'remap')
		table.insert(vars.selections, 'fullscreen')
	end
end

function options:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('left') then self:keypressed('left') end
		if pd.buttonJustPressed('right') then self:keypressed('right') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
		if pd.buttonJustPressed('a') then self:keypressed('a') end

		-- TODO: use crank to scroll through selections if handler == 'options'
	end

	vars.bonk_offset = vars.bonk_offset - (vars.bonk_offset * 0.5)
end

function options:draw()
	drawimage(assets.bg, 0, 0)

	drawtext(root_beer_outline, text('options'), 111, 26, center)

	for i = 1, #vars.selections do
		drawtext(vars.selection == i and root_beer_med_outline or root_beer_med, text('options_' .. vars.selections[i]) .. (vars.selections[i] ~= 'remap' and text('options_' .. tostring(save[vars.selections[i]])) or ''), 278, 108 + (20 * i) - (#vars.selections * 10) + (vars.selection == i and (-2 + vars.bonk_offset) or 0), center)
	end

	drawontop()
end

function options:keypressed(button)
	if vars.handler == 'options' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.selection = vars.selection - 1
			if vars.selection < 1 then
				vars.selection = 1
				vars.bonk_offset = -5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.selection = vars.selection + 1
			if vars.selection > #vars.selections then
				vars.selection = #vars.selections
				vars.bonk_offset = 5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				playsound(sfx_select)
			elseif sel == 'sfx' then
				save.sfx = not save.sfx
				playsound(sfx_select)
			elseif sel == 'reduceflashing' then
				save.reduceflashing = save.reduceflashing - 1
				if save.reduceflashing < 0 then
					save.reduceflashing = (platform == 'peedee' and 2 or 1)
				end
				playsound(sfx_select)
			elseif sel == 'rumble' then
				save.rumble = not save.rumble
				playsound(sfx_select)
			elseif sel == 'remap' then
				playsound(sfx_menu_bonk)
			elseif sel == 'fullscreen' then
				-- TODO: swap fullscreen
				playsound(sfx_select)
			end
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				playsound(sfx_select)
			elseif sel == 'sfx' then
				save.sfx = not save.sfx
				playsound(sfx_select)
			elseif sel == 'reduceflashing' then
				save.reduceflashing = save.reduceflashing + 1
				if save.reduceflashing > (platform == 'peedee' and 2 or 1) then
					save.reduceflashing = 0
				end
				playsound(sfx_select)
			elseif sel == 'rumble' then
				save.rumble = not save.rumble
				playsound(sfx_select)
			elseif sel == 'remap' then
				playsound(sfx_menu_bonk)
			elseif sel == 'fullscreen' then
				-- TODO: swap fullscreen
				playsound(sfx_select)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			scenemanager:transitionscene(title, true, 'options')
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				playsound(sfx_select)
			elseif sel == 'sfx' then
				save.sfx = not save.sfx
				playsound(sfx_select)
			elseif sel == 'reduceflashing' then
				save.reduceflashing = save.reduceflashing + 1
				if save.reduceflashing > 2 then
					save.reduceflashing = 0
				end
				playsound(sfx_select)
			elseif sel == 'rumble' then
				save.rumble = not save.rumble
				playsound(sfx_select)
			elseif sel == 'remap' then
				playsound(sfx_select)
				-- TODO: remap steps
			elseif sel == 'fullscreen' then
				-- TODO: swap fullscreen
				playsound(sfx_select)
			end
		end
	end
end

if platform == 'love' then return options end