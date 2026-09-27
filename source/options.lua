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
		hit_edge = false,
	}
	afterdelay('inputdelay', transitioning and transitiontime or 0, function() vars.handler = 'options' end)

	if platform == 'love' then
		table.insert(vars.selections, 'rumble')
		table.insert(vars.selections, 'clean_scaling')
		table.insert(vars.selections, 'remap')
		vars.remap_step = 1
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

		local ticks = pd.getCrankTicks(4)
		if vars.handler == 'options' then
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

function options:draw()
	drawimage(assets.bg, 0, 0)

	drawtext(root_beer_outline, text('options'), 111, 26, center)

	for i = 1, #vars.selections do
		drawtext(vars.selection == i and root_beer_med_outline or root_beer_med, text('options_' .. vars.selections[i]) .. (vars.selections[i] ~= 'remap' and text('options_' .. tostring(save[vars.selections[i]])) or ''), 278, 108 + (20 * i) - (#vars.selections * 10) + (vars.selection == i and (-2 + vars.bonk_offset) or 0), center)
	end

	-- NOTE: modal for keyboard remapping

	drawontop()
end

function options:holdbuttons()
	vars.heldup = save.up
	vars.helddown = save.down
	vars.heldleft = save.left
	vars.heldright = save.right
	vars.heldprimary = save.primary
	vars.heldsecondary = save.secondary
end

function options:restorebuttons()
	save.up = vars.heldup
	save.down = vars.helddown
	save.left = vars.heldleft
	save.right = vars.heldright
	save.primary = vars.heldprimary
	save.secondary = vars.heldsecondary
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
		elseif button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/title', true, 1.2)
				else
					stopmusic()
				end
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
				rumble(1, 1, 0.5)
				playsound(sfx_select)
			elseif sel == 'remap' then
				playsound(sfx_menu_bonk)
			elseif sel == 'clean_scaling' then
				save.clean_scaling = not save.clean_scaling
				local w, h, _ = love.window.getMode()
				love.resize(w, h)
				playsound(sfx_select)
			end
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/title', true, 1.2)
				else
					stopmusic()
				end
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
				rumble(1, 1, 0.5)
				playsound(sfx_select)
			elseif sel == 'remap' then
				playsound(sfx_menu_bonk)
			elseif sel == 'clean_scaling' then
				save.clean_scaling = not save.clean_scaling
				local w, h, _ = love.window.getMode()
				love.resize(w, h)
				playsound(sfx_select)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			scenemanager:transitionscene(title, true, 'options')
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			local sel = vars.selections[vars.selection]
			if sel == 'music' then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/title', true, 1.2)
				else
					stopmusic()
				end
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
				rumble(1, 1, 0.5)
				playsound(sfx_select)
			elseif sel == 'remap' then
				vars.remap_step = 1
				vars.handler = 'remap'
				playsound(sfx_select)
			elseif sel == 'clean_scaling' then
				save.clean_scaling = not save.clean_scaling
				local w, h, _ = love.window.getMode()
				love.resize(w, h)
				playsound(sfx_select)
			end
		end
	elseif vars.handler == 'remap' then
		local valid = true
		if vars.remap_step == 1 then
			save.up = button
		elseif vars.remap_step == 2 then
			if save.up == button then
				valid = false
			else
				save.down = button
			end
		elseif vars.remap_step == 3 then
			if save.up == button or save.down == button then
				valid = false
			else
				save.left = button
			end
		elseif vars.remap_step == 4 then
			if save.up == button or save.down == button or save.left == button then
				valid = false
			else
				save.right = button
			end
		elseif vars.remap_step == 5 then
			if save.up == button or save.down == button or save.left == button or save.right == button then
				valid = false
			else
				save.primary = button
			end
		elseif vars.remap_step == 6 then
			if save.up == button or save.down == button or save.left == button or save.right == button or save.primary == button then
				valid = false
			else
				save.secondary = button
			end
		end
		-- Great pyramid, am i right?
		if valid then
			playsound(sfx_select)
			vars.remap_step = vars.remap_step + 1
			if vars.remap_step > 6 then
				vars.handler = 'options'
				self:holdbuttons()
				savegame()
			end
		else
			playsound(sfx_menu_bonk)
		end
	end
end

if platform == 'love' then return options end