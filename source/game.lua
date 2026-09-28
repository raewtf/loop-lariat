local pd
local gfx
local center
local right
local exp = math.exp
local min = math.min
local max = math.max
local floor = math.floor
local find = string.find
local format = string.format

if platform == 'peedee' then
	pd = playdate
	gfx = pd.graphics
	center = kTextAlignment.center
	right = kTextAlignment.right


	class('game').extends(gfx.sprite)
	function game:init(...)
		game.super.init(self)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		function pd.gameWillPause()
			local menu = pd.getSystemMenu()
			menu:removeAllMenuItems()
			if not transitioning and vars.player_1.handler ~= 'waiting' and vars.player_1.handler ~= 'gameover' and vars.player_1.handler ~= 'results' then
				menu:addMenuItem(text('slide_quit'), function()
					scenemanager:transitionscene(modeselect)
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

	game = {}
	function game:enter(current, ...)
		local args = {...} -- Arguments passed in through the scene management will arrive here

		self:initialize(args)
	end
end

function game:initialize(args)
	assets = {
		-- cursors!
		cursor = newimage(save.image_path .. '/game/cursor'),
		cursor_bonk_1 = newimage(save.image_path .. '/game/cursor_bonk_1'),
		cursor_bonk_2 = newimage(save.image_path .. '/game/cursor_bonk_2'),
		cursor_place_1 = newimage(save.image_path .. '/game/cursor_place_1'),
		cursor_place_2 = newimage(save.image_path .. '/game/cursor_place_2'),

		-- lasso blocks!
		lasso_u_d = newimage(save.image_path .. '/game/blocks/lasso_u_d'),
		lasso_u_d_connect_u = newimage(save.image_path .. '/game/blocks/lasso_u_d_connect_u'),
		lasso_u_d_connect_d = newimage(save.image_path .. '/game/blocks/lasso_u_d_connect_d'),
		lasso_u_d_connect_u_d = newimage(save.image_path .. '/game/blocks/lasso_u_d_connect_u_d'),

		lasso_l_r = newimage(save.image_path .. '/game/blocks/lasso_l_r'),
		lasso_l_r_connect_l = newimage(save.image_path .. '/game/blocks/lasso_l_r_connect_l'),
		lasso_l_r_connect_r = newimage(save.image_path .. '/game/blocks/lasso_l_r_connect_r'),
		lasso_l_r_connect_l_r = newimage(save.image_path .. '/game/blocks/lasso_l_r_connect_l_r'),

		lasso_u_l = newimage(save.image_path .. '/game/blocks/lasso_u_l'),
		lasso_u_l_connect_u = newimage(save.image_path .. '/game/blocks/lasso_u_l_connect_u'),
		lasso_u_l_connect_l = newimage(save.image_path .. '/game/blocks/lasso_u_l_connect_l'),
		lasso_u_l_connect_u_l = newimage(save.image_path .. '/game/blocks/lasso_u_l_connect_u_l'),

		lasso_u_r = newimage(save.image_path .. '/game/blocks/lasso_u_r'),
		lasso_u_r_connect_u = newimage(save.image_path .. '/game/blocks/lasso_u_r_connect_u'),
		lasso_u_r_connect_r = newimage(save.image_path .. '/game/blocks/lasso_u_r_connect_r'),
		lasso_u_r_connect_u_r = newimage(save.image_path .. '/game/blocks/lasso_u_r_connect_u_r'),

		lasso_d_l = newimage(save.image_path .. '/game/blocks/lasso_d_l'),
		lasso_d_l_connect_d = newimage(save.image_path .. '/game/blocks/lasso_d_l_connect_d'),
		lasso_d_l_connect_l = newimage(save.image_path .. '/game/blocks/lasso_d_l_connect_l'),
		lasso_d_l_connect_d_l = newimage(save.image_path .. '/game/blocks/lasso_d_l_connect_d_l'),

		lasso_d_r = newimage(save.image_path .. '/game/blocks/lasso_d_r'),
		lasso_d_r_connect_d = newimage(save.image_path .. '/game/blocks/lasso_d_r_connect_d'),
		lasso_d_r_connect_r = newimage(save.image_path .. '/game/blocks/lasso_d_r_connect_r'),
		lasso_d_r_connect_d_r = newimage(save.image_path .. '/game/blocks/lasso_d_r_connect_d_r'),

		-- block effects (shine and clear)
		block_shine_1 = newimage(save.image_path .. '/game/block_shine_1'),
		block_shine_2 = newimage(save.image_path .. '/game/block_shine_2'),
		block_shine_3 = newimage(save.image_path .. '/game/block_shine_3'),

		block_clear_1 = newimage(save.image_path .. '/game/block_clear_1'),
		block_clear_2 = newimage(save.image_path .. '/game/block_clear_2'),
		block_clear_3 = newimage(save.image_path .. '/game/block_clear_3'),
		block_clear_4 = newimage(save.image_path .. '/game/block_clear_4'),

		-- ...blocks!
		tnt = newimage(save.image_path .. '/game/blocks/tnt'),
		tnt_prime_1 = newimage(save.image_path .. '/game/blocks/tnt_prime_1'),
		tnt_prime_2 = newimage(save.image_path .. '/game/blocks/tnt_prime_2'),

		outlaw = newimage(save.image_path .. '/game/blocks/outlaw'),
		tumble = newimage(save.image_path .. '/game/blocks/tumble'),

		countdown = newimagetable(save.image_path .. '/game/countdown', 400, 240, 60),

		-- pause assets
		half = newimage(save.image_path .. '/half'),
		box = newnineslice(save.image_path .. '/modeselect/box', 17, 17, 30, 30),
		modal = newimage(300, 190),
	}

	pushcontext(assets.modal)
		drawnineslice(assets.box, 0, 0, 300, 190)
	popcontext()

	vars = {
		mode = args[1] or 'time', -- 'arcade', 'time', 'marathon', 'daily', 'vs', or 'chill'
		arg1 = args[2], -- if 'arcade' or 'time', number in milliseconds. if 'vs', string that's either '2p' or 'com'.
		arg2 = args[3], -- if 'vs', array with number of wins for each player.
		garbage_threshold = 3,
		paused = false,
		pause_bonk_offset = 0,
		results_bonk_offset = 0,
		time_up = false,
	}

	loopingtimer('tnt_prime_1', 150, 1, 2.99, 'linear')
	loopingtimer('tnt_prime_2', 100, 2, 3.99, 'linear')
	loopingtimer('anim_overlay', 2000, 1, 4.99, 'linear')

	if vars.mode == 'daily' then
		local time = getgmttime()
		vars.seed = time.year .. format('%02d', time.month) .. format('%02d', time.day)
		setRandomSeed(vars.seed)
	else
		randomseed()
	end

	-- defining player stats, scores, 'n' such
	for i = 1, (vars.mode == 'vs' and 2 or 1) do
		vars['player_' .. i] = {}
		local p = vars['player_' .. i]

		p.handler = 'waiting' -- play handler
		p.score = 0 -- score
		p.lassos = 0 -- lassos this round
		-- blocks being juggled
		p.blocks = {
			bag = {},

			current_x_offset = 0,
			current_y_offset = 0,


			hold = '',
			hold_used = false,
			hold_x_offset = 0,
			hold_y_offset = 0,

			tnt_prime_level = 0,
		}

		-- creating the first two blocks (and the initial bag)
		p.blocks.current = self:random_block(i)
		p.blocks.next = self:random_block(i)

		-- grid cursor
		p.cursor = {
			x = 3,
			y = 3,
			x_offset = 0,
			y_offset = 0,
		}
		newtimer('anim_cursor_place_' .. i, 0, 3, 3)
		newtimer('anim_cursor_bonk_' .. i, 0, 3, 3)

		-- game board grid
		p.board = {
			{{}, {}, {}, {}, {}},
			{{}, {}, {}, {}, {}},
			{{}, {}, {}, {}, {}},
			{{}, {}, {}, {}, {}},
			{{}, {}, {}, {}, {}},
		}
		p.first_lasso_segment = {}
		p.lassos_in_match = {}
		newtimer('anim_board_shake_' .. i, 0, 0, 0)

		-- garbage tumbleweed status. only necessary in vs mode
		if vars.mode == 'vs' then
			p.garbage = {
				amount = 0,
				old_amount = 0,
				warning_level = 0,
			}
		end

		-- defining player-specific variables
		if vars.mode == 'vs' then
			if i == 1 then
				p.board_x_origin = 24
			elseif i == 2 then
				p.board_x_origin = 256
			end
			p.board_y_origin = 72
		else
			p.board_x_origin = 140
			p.board_y_origin = 60
		end
	end

	if vars.mode == 'arcade' then
		save.arcade_played = save.arcade_played + 1
		assets.bg = newimage(save.image_path .. '/game/bg_arcade_1')
		assets.clouds = newimage(save.image_path .. '/game/clouds')
		assets.bg_2 = newimage(save.image_path .. '/game/bg_arcade_2')
		assets.ui = newimage(save.image_path .. '/game/1p_ui')
		loopingtimer('clouds', 125000, 0, -1200, 'linear')
	elseif vars.mode == 'time' then
		save.time_played = save.time_played + 1
		assets.bg = newimage(save.image_path .. '/game/bg_time_1')
		assets.clouds = newimage(save.image_path .. '/game/clouds')
		assets.bg_2 = newimage(save.image_path .. '/game/bg_time_2')
		assets.ui = newimage(save.image_path .. '/game/1p_ui')
		assets.anim_overlay = newimagetable(save.image_path .. '/game/time_anim_overlay', 400, 240, 4)
		loopingtimer('clouds', 125000, 0, -1200, 'linear')
	elseif vars.mode == 'marathon' then
		save.marathon_played = save.marathon_played + 1
		assets.bg = newimage(save.image_path .. '/game/bg_marathon')
		assets.ui = newimage(save.image_path .. '/game/1p_ui')
		assets.anim_overlay = newimagetable(save.image_path .. '/game/marathon_anim_overlay', 400, 240, 4)
	elseif vars.mode == 'daily' then
		save.daily_played = save.daily_played + 1
		assets.bg = newimage(save.image_path .. '/game/bg_daily')
		assets.ui = newimage(save.image_path .. '/game/1p_ui')
		assets.anim_overlay = newimagetable(save.image_path .. '/game/daily_anim_overlay', 400, 240, 4)
	elseif vars.mode == 'vs' then
		if vars.arg1 == '2p' then
			save.vs_2p_played = save.vs_2p_played + 1
		elseif vars.arg1 == 'com' then
			save.vs_com_played = save.vs_com_played + 1
		end
		-- TODO: colorize win images in löve
		assets.wins_0_0 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_0_0')
		assets.wins_1_0 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_1_0')
		assets.wins_2_0 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_2_0')
		assets.wins_0_1 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_0_1')
		assets.wins_0_2 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_0_2')
		assets.wins_1_1 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_1_1')
		assets.wins_1_2 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_1_2')
		assets.wins_2_1 = newimage(save.image_path .. '/game/wins/wins_' .. vars.arg1 .. '_2_1')

		assets.bg = newimage(save.image_path .. '/game/bg_vs_1')
		assets.clouds = newimage(save.image_path .. '/game/clouds')
		assets.bg_2 = newimage(save.image_path .. '/game/bg_vs_2')
		assets.ui = newimage(save.image_path .. '/game/2p_ui')
		loopingtimer('clouds', 125000, 0, -1200, 'linear')
	elseif vars.mode == 'chill' then
		save.chill_played = save.chill_played + 1
		assets.bg = newimage(save.image_path .. '/game/bg_chill')
		assets.ui = newimage(save.image_path .. '/game/1p_ui')
		assets.anim_overlay = newimagetable(save.image_path .. '/game/chill_anim_overlay', 400, 240, 4)
	end

	afterdelay('outlaw_delay', 1000, function()
		-- place down the outlaws
		self:place_outlaws(1)
		if vars.mode == 'vs' then self:place_outlaws(2) end

		afterdelay('countdown_delay', 1000, function()
			-- TODO: change 2p's handler if mode is VS
			if vars.mode == 'chill' then
				if vars.player_1.handler == 'waiting' then vars.player_1.handler = 'playing' end
				newmusic('audio/music/chill', true)
			else
				newmusic('audio/music/countdown')
				newtimer('countdown', 4000, 1, 60, 'linear', function()
					if vars.mode == 'arcade' or vars.mode == 'time' then
						local arg1 = vars.arg1
						newtimer('time', arg1 ~= nil and arg1 or 60000, arg1 ~= nil and arg1 or 60000, 0, 'linear', function()
							vars.time_up = true
							self:over(1)
						end)
					end

					if vars.player_1.handler == 'waiting' then vars.player_1.handler = 'playing' end
					afterdelay('start_music', 500, function()
						newmusic('audio/music/game', true)
					end)
				end)
			end
		end)
	end)
end

function game:update()
	if platform == 'peedee' then
		if pd.buttonJustPressed('up') then self:keypressed('up') end
		if pd.buttonJustPressed('down') then self:keypressed('down') end
		if pd.buttonJustPressed('left') then self:keypressed('left') end
		if pd.buttonJustPressed('right') then self:keypressed('right') end
		if pd.buttonJustPressed('b') then self:keypressed('b') end
		if pd.buttonJustPressed('a') then self:keypressed('a') end

		if vars.player_1.handler == 'results' then
			local ticks = pd.getCrankTicks(4)

			if ticks > 0 then
				vars.results_selection = vars.results_selection + 1
				if vars.results_selection > #vars.results_selections then
					vars.results_selection = #vars.results_selections
					if not vars.results_hit_edge then
						vars.results_hit_edge = true
						vars.results_bonk_offset = 5
						playsound(sfx_menu_bonk)
					end
				else
					vars.results_hit_edge = false
					playsound(sfx_menu_move)
				end
			elseif ticks < 0 then
				vars.results_selection = vars.results_selection - 1
				if vars.results_selection < 1 then
					vars.results_selection = 1
					if not vars.results_hit_edge then
						vars.results_hit_edge = true
						vars.results_bonk_offset = -5
						playsound(sfx_menu_bonk)
					end
				else
					vars.results_hit_edge = false
					playsound(sfx_menu_move)
				end
			end
		end
	end

	for i = 1, (vars.mode == 'vs' and 2 or 1) do
		local p = vars['player_' .. i]
		p.cursor.x_offset = p.cursor.x_offset - (p.cursor.x_offset * 0.5)
		p.cursor.y_offset = p.cursor.y_offset - (p.cursor.y_offset * 0.5)
		p.blocks.current_x_offset = p.blocks.current_x_offset - (p.blocks.current_x_offset * 0.5)
		p.blocks.current_y_offset = p.blocks.current_y_offset - (p.blocks.current_y_offset * 0.5)
		p.blocks.hold_x_offset = p.blocks.hold_x_offset - (p.blocks.hold_x_offset * 0.5)
		p.blocks.hold_y_offset = p.blocks.hold_y_offset - (p.blocks.hold_y_offset * 0.5)
	end

	if vars.player_1.handler == 'playing' then save.gametime = save.gametime + 1 end

	-- doing mid-game checks
	for i = 1, (vars.mode == 'vs' and 2 or 1) do
		local p = vars['player_' .. i]

		if p.handler == 'playing' then
			local tiles = 0
			local tiles_filled = 0
			local tiles_excluding_edges = 0
			local tiles_filled_excluding_edges = 0
			local outlaws_on_board = 0
			local is_edge

			for n = 1, #p.board do
				for j = 1, #p.board[1] do
					-- total number of tiles on the board
					tiles = tiles + 1

					-- calculating the tiles that aren't edges, for outlaw spawning
					is_edge = true
					if n ~= 1 and n ~= #p.board and j ~= 1 and j ~= #p.board[1] then
						is_edge = false
						tiles_excluding_edges = tiles_excluding_edges + 1
					end

					-- check if block exists
					if p.board[n][j].block ~= nil then
						-- this tile is filled with something!
						tiles_filled = tiles_filled + 1
						if not is_edge then tiles_filled_excluding_edges = tiles_filled_excluding_edges + 1 end

						-- check if that block's an outlaw, while we're in here
						if p.board[n][j].block == 'outlaw' then
							outlaws_on_board = outlaws_on_board + 1
						end
					end
				end
			end

			-- this player has no outlaws on their board. give 'em some more!
			if outlaws_on_board == 0 and tiles_filled_excluding_edges <= (tiles_excluding_edges - 3) then self:place_outlaws(i) end

			-- if the entire board is full, and the player doesn't have a TNT to potentially clear it with,
			if tiles_filled == tiles and (p.blocks.current ~= 'tnt' and p.blocks.held ~= 'tnt') then
				if vars.mode == 'chill' then
					-- in chill mode, there's no game overs. just clear the board and let them try again
					if p.handler == 'playing' then p.handler = 'clearing' end
					afterdelay('clear_board', 500, function()
						for n = 1, #p.board do
							for j = 1, #p.board[1] do
								p.board[n][j] = {}
								newtimer('anim_block_clear_' .. i .. '_' .. n .. '_' .. j, 150, 1, 5)
							end
						end
						playsound(sfx_match_clear)
						resettimer('anim_board_shake_' .. i, 500, 5, 0, 'linear', function()
							if p.handler == 'clearing' then -- check if handler's still waiting; otherwise don't return input.
								p.handler = 'playing'
							end
						end)
					end)
				else
					-- run game over sequence!!
					self:over(i)
				end
			end
		end
	end

	vars.pause_bonk_offset = vars.pause_bonk_offset - (vars.pause_bonk_offset * 0.5)
	vars.results_bonk_offset = vars.results_bonk_offset - (vars.results_bonk_offset * 0.5)
end

function game:draw()
	-- drawing the background
	drawimage(assets.bg, 0, 0)
	if assets.clouds ~= nil then drawimage(assets.clouds, value('clouds'), 0) end
	if assets.bg_2 ~= nil then drawimage(assets.bg_2, 0, 0) end
	if assets.anim_overlay ~= nil then drawimagetable(assets.anim_overlay, floor(value('anim_overlay')), 0, 0) end

	-- UI drawing
	-- TODO: less confusing way to display NOW and NEXT?
	if vars.mode == 'vs' then
		drawimage(assets.ui, 0, 0)

		-- score/time displays
		drawtext(root_beer_med_outline, text('1p_score'), 163, 51)
		drawtext(root_beer_outline, commalize(vars.player_1.score), 163, 62)
		if vars.arg1 == '2p' then
			drawtext(root_beer_med_outline, text('2p_score'), 237, 99, right)
		elseif vars.arg1 == 'com' then
			drawtext(root_beer_med_outline, text('com_score'), 237, 99, right)
		end
		drawtext(root_beer_outline, commalize(vars.player_2.score), 237, 110, right)
		drawtext(root_beer_med_outline, text('wins'), 200, 147, center)
		-- TODO: win sprites
		-- empty and full. best 2 of 3, winning spot in the middle
		-- 158 Y

		-- 1p's blocks
		local p = vars.player_1

		drawtext(root_beer_med_outline, text('next'), 52, 23, right)
		drawimage(assets[p.blocks.next], 25, 40)

		drawtext(root_beer_med_outline, text('now'), 56, 23)
		drawimage(assets[p.blocks.current], 59 + p.blocks.current_x_offset, 40 + p.blocks.current_y_offset)

		drawtext(root_beer_med_outline, text('hold'), 131, 23, center)
		if assets[p.blocks.hold] ~= nil then drawimage(assets[p.blocks.hold], 119 + p.blocks.hold_x_offset, 40 + p.blocks.hold_y_offset) end

		-- 2p's blocks
		local p = vars.player_2

		drawtext(root_beer_med_outline, text('next'), 284, 23, right)
		drawimage(assets[p.blocks.next], 257, 40)

		drawtext(root_beer_med_outline, text('now'), 288, 23)
		drawimage(assets[p.blocks.current], 291 + p.blocks.current_x_offset, 40 + p.blocks.current_y_offset)

		drawtext(root_beer_med_outline, text('hold'), 363, 23, center)
		if assets[p.blocks.hold] ~= nil then drawimage(assets[p.blocks.hold], 351 + p.blocks.hold_x_offset, 40 + p.blocks.hold_y_offset) end
	else
		local p = vars.player_1
		drawimage(assets.ui, 0, 0)

		-- score/time display
		drawtext(root_beer_med_outline, text('score'), 272, 51)
		drawtext(root_beer_outline, commalize(p.score), 272, 62)

		if vars.mode == 'daily' then
			drawtext(root_beer_med_outline, text('seed'), 272, 99)
			drawtext(root_beer_med_outline, vars.seed, 272, 114)
		elseif vars.mode == 'chill' then
			drawtext(root_beer_med_outline, text('lassos'), 272, 99)
			drawtext(root_beer_outline, commalize(p.lassos), 272, 110)
		else
			drawtext(root_beer_med_outline, text('best'), 272, 99)
			drawtext(root_beer_outline, commalize(max(p.score, save[vars.mode .. '_best'])), 272, 110)
		end

		if vars.mode == 'arcade' or vars.mode == 'time' then
			drawtext(root_beer_med_outline, text('timer'), 272, 147)
			local time = value('time')
			if time == nil then time = vars.arg1 ~= nil and vars.arg1 or 60000 end
			drawtext(root_beer_outline, format('%02d:%02d', floor((time / 1000) / 60), floor((time / 1000) % 60)), 272, 158)
		elseif vars.mode == 'marathon' or vars.mode == 'daily' then
			drawtext(root_beer_med_outline, text('lassos'), 272, 147)
			drawtext(root_beer_outline, commalize(p.lassos), 272, 158)
		end

		-- blocks
		drawtext(root_beer_med_outline, text('next'), 83, 81, center)
		drawimage(assets[p.blocks.next], 73, 61)

		drawtext(root_beer_med_outline, text('now'), 119, 44, center)
		drawimage(assets[p.blocks.current], 107 + p.blocks.current_x_offset, 61 + p.blocks.current_y_offset)

		drawtext(root_beer_med_outline, text('hold'), 108, 174, center)
		if assets[p.blocks.hold] ~= nil then drawimage(assets[p.blocks.hold], 107 + p.blocks.hold_x_offset, 155 + p.blocks.hold_y_offset) end
	end

	-- defining block/cursor height
	local block_w, block_h = imagesize(assets.lasso_u_d)
	local cursor_w, cursor_h = imagesize(assets.cursor)
	local cursor_w_diff = (cursor_w - block_w) / 2
	local cursor_h_diff = (cursor_h - block_h) / 2

	local shake_value
	local bs_x
	local bs_y

	local shine_value
	local clear_value

	local tnt_prime_level
	local tnt_prime_value

	local flash = getreduceflashing()

	-- drawing game board for the player(s)
	for i = 1, (vars.mode == 'vs' and 2 or 1) do
		local p = vars['player_' .. i]
		shake_value = flash and 0 or value('anim_board_shake_' .. i)

		for n = 1, #p.board do
			bs_x = floor((randFloat(-1, 1) * shake_value) / 2) * 2

			for j = 1, #p.board[1] do
				bs_y = floor((randFloat(-1, 1) * shake_value) / 2) * 2
				local tile = p.board[n][j]

				if tile.block ~= nil then
					-- TNT drawing with prime effect
					if tile.block == 'tnt' then
						tnt_prime_level = p.blocks.tnt_prime_level

						if tnt_prime_level == 0 then
							drawimage(assets.tnt, p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
						elseif tnt_prime_level == 1 then
							tnt_prime_value = floor(value('tnt_prime_1'))
							drawimage(tnt_prime_value > 1 and assets.tnt_prime_1 or assets.tnt, p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
						elseif tnt_prime_level == 2 then
							tnt_prime_value = floor(value('tnt_prime_2'))
							drawimage(tnt_prime_value > 2 and assets.tnt_prime_2 or assets.tnt_prime_1, p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
						end
					else
						drawimage(assets[tile.block], p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
					end

					-- draw shine animation for appearing
					shine_value = flash and nil or value('anim_block_shine_' .. i .. '_' .. n .. '_' .. j)
					if shine_value ~= nil and shine_value >= 1 and shine_value <= 3 then
						drawimage(assets['block_shine_' .. floor(shine_value)], p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
					end

				end

				-- draw clear animation for disappearing, regardless of if there's actually a block there.
				clear_value = flash and nil or value('anim_block_clear_' .. i .. '_' .. n .. '_' .. j)
				if clear_value ~= nil and clear_value >= 1 and clear_value <= 4 then
					drawimage(assets['block_clear_' .. floor(clear_value)], p.board_x_origin + ((n - 1) * block_w) + bs_x, p.board_y_origin + ((j - 1) * block_h) + bs_y)
				end
			end
		end

		local place_value = floor(value('anim_cursor_place_' .. i))
		local bonk_value = floor(value('anim_cursor_bonk_' .. i))
		local cursor

		if bonk_value == 1 then
			cursor = assets.cursor_bonk_1
		elseif bonk_value == 2 then
			cursor = assets.cursor_bonk_2
		elseif place_value == 1 then
			cursor = assets.cursor_place_1
		elseif place_value == 2 then
			cursor = assets.cursor_place_2
		else
			cursor = assets.cursor
		end

		bs_x = floor((randFloat(-1, 1) * shake_value) / 2) * 2
		bs_y = floor((randFloat(-1, 1) * shake_value) / 2) * 2

		drawimage(cursor, (p.board_x_origin - cursor_w_diff) + ((p.cursor.x - 1) * block_w) + p.cursor.x_offset + bs_x, (p.board_y_origin - cursor_h_diff) + ((p.cursor.y - 1) * block_h) + p.cursor.y_offset + bs_y)
	end

	if vars.countdown ~= nil and timeleft('countdown') > 0 then
		drawimagetable(assets.countdown, floor(value('countdown')), 0, 0)
	end

	-- pause screen
	if vars.paused then
		drawimage(assets.half, 0, 0)
		drawimage(assets.modal, 50, 25)

		drawtext(root_beer_med, text('paused'), 200, 50, center)

		for i = 1, #vars.pause_selections do
			drawtext(vars.pause_selection == i and root_beer_outline or root_beer, text(vars.pause_selections[i]), 200, 85 + (30 * i) - (15 * #vars.pause_selections) + (vars.pause_selection == i and (-2 + vars.pause_bonk_offset) or 0), center)
		end

		if vars.pause_selections[#vars.pause_selections] == 'quit' then
			drawtext(root_beer_small, text('quit_warning'), 200, 160, center)
		end
	end

	-- results screen
	if vars.player_1.handler == 'results' then
		drawimage(assets.half, 0, 0)
		drawimage(assets.modal, 50, 25)

		drawtext(root_beer, vars.time_up and text('timeup') or text('gameover'), 200, 50, center)

		drawtext(root_beer_med, text('your_score'), 80, 95)
		drawtext(root_beer, commalize(vars.player_1.score), 322, 84, right)

		-- display best score if mode isn't daily (where there is no best score).
		if vars.mode ~= 'daily' then
			if vars.new_best then
				drawtext(root_beer_med, text('new_best'), 80, 114)
			else
				drawtext(root_beer_med, text('best_score') .. commalize(save[vars.mode .. '_best']), 80, 114)
			end
		end

		-- total lassos that game
		drawtext(root_beer_med, text('total_lassos') .. commalize(vars.player_1.lassos), 320, 114, right)

		-- selection ooptions
		for i = 1, #vars.results_selections do
			drawtext(vars.results_selection == i and root_beer_med_outline or root_beer_med, text(vars.results_selections[i]), 200, 150 + (20 * i) - (10 * #vars.results_selections) + (vars.results_selection == i and (-2 + vars.results_bonk_offset) or 0), center)
		end

		-- TODO: VS end screen stuff
		-- if it's VS, add a point to the player who didn't lose
		-- if it's VS, show the player who won the match
		-- if it's VS and there's no 3-set winner, just play again
		-- if it's VS and there *is* a 3-set winner, just go back
		-- if there's a 3-set winner, show them more prominently than just round winner, btw
	end

	drawontop()
end

-- pause function, in löve
function game:pause()
	if not vars.paused then
		setmusicvolume(0.5)
		vars.player_1.oldhandler = vars.player_1.handler
		vars.player_1.handler = 'paused'
		if vars.mode == 'vs' then
			vars.player_2.oldhandler = vars.player_2.handler
			vars.player_2.handler = 'paused'
		end
		vars.pause_selections = {'resume'}
		if vars.player_1.oldhandler ~= 'waiting' then
			table.insert(vars.pause_selections, 'quit')
		end
		vars.pause_selection = 1
		vars.paused = true
	end
end

-- unpause function, in löve
function game:unpause()
	if vars.paused then
		setmusicvolume(1)
		vars.paused = false
		vars.player_1.handler = vars.player_1.oldhandler
		if vars.mode == 'vs' then
			vars.player_2.handler = vars.player_2.oldhandler
		end
	end
end

-- Shuffly code from https://gist.github.com/Uradamus/10323382
function game:shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = randInt(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

-- placing outlaws in the grid, grandomly
function game:place_outlaws(player)
	-- player arg
	local p = vars['player_' .. player]
	local outlaws_placed = 0
	local outlaws_needed = randInt(1, 3)
	local outlaws_queued = {}
	local outlaw_queued

	if p.handler == 'playing' then p.handler = 'placing_outlaws' end

	while outlaws_placed < outlaws_needed do
		local x = randInt(2, #p.board - 1)
		local y = randInt(2, #p.board[1] - 1)

		-- making sure there isn't already an outlaw queued for the new spot
		outlaw_queued = false
		for i = 1, #outlaws_queued do
			if outlaws_queued[i][1] == x and outlaws_queued[i][2] == y then
				outlaw_queued = true
			end
		end

		if p.board[x][y].block == nil and not outlaw_queued then
			table.insert(outlaws_queued, {x, y})
			afterdelay('outlaw_' .. player .. '_' .. outlaws_placed, outlaws_placed * 100, function()
				p.board[x][y] = {
					original_block = 'outlaw',
					block = 'outlaw',
				}
				newtimer('anim_block_shine_' .. player .. '_' .. x .. '_' .. y, 150, 1, 4)
				playsound(sfx_block_in)
				if outlaws_placed == outlaws_needed and p.handler == 'placing_outlaws' then
					p.handler = 'playing'
				end
			end)
			outlaws_placed = outlaws_placed + 1
		end
	end
end

-- generate a (weighted-)random block to add into the player's queue.
function game:random_block(player)
	-- player arg
	local p = vars['player_' .. player]

	if p.blocks.bag[1] == nil then -- there's nothing in the bag. we need to make a new bag!
		local new_bag = {
			'lasso_u_d',
			'lasso_u_d',
			'lasso_u_d',
			'lasso_l_r',
			'lasso_l_r',
			'lasso_l_r',
			'lasso_u_l',
			'lasso_u_r',
			'lasso_d_l',
			'lasso_d_r',
			'tnt',
			'tnt',
		}

		p.blocks.bag = self:shuffle(new_bag)
	end

	local new_item = table.remove(p.blocks.bag)
	return new_item
end

-- sends a block to the holding place, depending on its status.
function game:hold_block(player)
	-- player arg
	local p = vars['player_' .. player]

	if p.blocks.hold_used == false then
		p.blocks.hold_used = true

		playsound(sfx_hold)

		if p.blocks.hold == '' then -- if there's no hold piece already,
			p.blocks.hold = p.blocks.current -- move current to hold,
			p.blocks.current = p.blocks.next -- move next to current,
			p.blocks.current_x_offset = -37
			if vars.mode == 'vs' then
				p.blocks.hold_x_offset = -60
			else
				p.blocks.hold_y_offset = -94
			end
			p.blocks.next = self:random_block(player) -- create a new block for next.
		else -- ...if there is a hold piece already,
			local hold_hold = p.blocks.hold -- make a quick copy of hold
			p.blocks.hold = p.blocks.current -- swap current into hold,
			p.blocks.current = hold_hold -- and swap hold into current.
			if vars.mode == 'vs' then
				p.blocks.current_x_offset = 60
				p.blocks.hold_x_offset = -60
			else
				p.blocks.current_y_offset = 94
				p.blocks.hold_y_offset = -94
			end
			hold_hold = nil -- we don't need this anymore.
		end
	end
end

-- place a block down on the game board grid, if available.
function game:place_block(player)
	-- player arg
	local p = vars['player_' .. player]
	local block = p.blocks.current
	local x = p.cursor.x
	local y = p.cursor.y

	if block == 'tnt' then -- TNT can be placed down anywhere.
		-- placing FX on the cursor and block
		resettimer('anim_cursor_place_' .. player, 150, 1, 3)
		newtimer('anim_block_shine_' .. player .. '_' .. x .. '_' .. y, 150, 1, 4)
		if not self:is_com(player) then save.blocks_placed = save.blocks_placed + 1 end
		rumble(0.5, 0.5, 0.1)
		playsound(sfx_place_tnt)

		p.score = p.score + 5
		if not self:is_com(player) then save.cumulative_score = save.cumulative_score + 5 end

		p.board[x][y] = {
			original_block = 'tnt', -- read-only!
			block = 'tnt'
		}
		if p.handler == 'playing' then p.handler = 'tnt_waiting' end

		p.blocks.current = p.blocks.next -- move the 'next' block into the current position
		p.blocks.current_x_offset = -37

		p.blocks.next = self:random_block(player) -- draw a random block from the bag for the next block
		p.blocks.hold_used = false

		self:find_lasso_segment(1, true) -- to update lasso blocks

		-- TNT priming animation, and final explosion logic
		afterdelay('tnt_prime_1_' .. player, 333, function() p.blocks.tnt_prime_level = 1 rumble(0.25, 0.25, 0.3) end)
		afterdelay('tnt_prime_2_' .. player, 666, function() p.blocks.tnt_prime_level = 2 rumble(0.5, 0.5, 0.3) end)
		afterdelay('tnt_explosion_' .. player, 1000, function()
			if not self:is_com(player) then save.dynamites_exploded = save.dynamites_exploded + 1 end
			-- explosion SFX (sorry for the global call)
			playsound(_G['sfx_explode_' .. randInt(1, 3)])

			rumble(1, 1, 0.75)
			p.board[x][y] = {}
			p.blocks.tnt_prime_level = 0
			newtimer('anim_block_clear_' .. player .. '_' .. x .. '_' .. y, 150, 1, 5)

			resettimer('anim_board_shake_' .. player, 750, 5, 0, 'linear', function()
				if p.handler == 'tnt_waiting' then -- check if handler's still waiting; otherwise don't return input.
					p.handler = 'playing'
				end
			end)
		end)
	elseif p.board[x][y].block == nil then -- other blocks can't be placed atop eachother
		-- placing FX on the cursor and block
		resettimer('anim_cursor_place_' .. player, 150, 1, 3)
		newtimer('anim_block_shine_' .. player .. '_' .. x .. '_' .. y, 150, 1, 4)
		if not self:is_com(player) then save.blocks_placed = save.blocks_placed + 1 end
		rumble(0.5, 0.5, 0.1)
		playsound(sfx_place_block)

		p.score = p.score + 5
		if not self:is_com(player) then save.cumulative_score = save.cumulative_score + 5 end

		p.board[x][y] = {
			original_block = block, -- read-only!
			block = block,
		} -- place the block down!

		p.blocks.current = p.blocks.next -- move the 'next' block into the current position
		p.blocks.current_x_offset = -37

		p.blocks.next = self:random_block(player) -- draw a random block from the bag for the next block
		p.blocks.hold_used = false

		lasso = self:find_lasso_segment(player)
		if not lasso then
			self:garbage_check(player)
		end
	else
		resettimer('anim_cursor_bonk_' .. player, 150, 1, 3)
		playsound(sfx_no_place)
	end
end

-- comb through the player's game board grid, finding a lasso segment to start scouting from
-- if skip_match bool is enabled, it doesn't actually process any matches. just for updating the lasso images
function game:find_lasso_segment(player, skip_match)
	local p = vars['player_' .. player]

	for i = 1, #p.board do
		for n = 1, #p.board[i] do

			p.first_lasso_segment = {i, n}
			self:lasso_check(player, i, n, '', true, skip_match or false)

			p.first_lasso_segment = {}
			-- clearing check status on each item
			for j = 1, #p.board do
				for z = 1, #p.board[j] do
					p.board[j][z].checked = false
				end
			end

			if p.handler == 'matching' then
				break
			end

			p.lassos_in_match = {}
		end
		if p.handler == 'matching' then
			break
		end
	end

	if p.handler ~= 'matching' then return false end
end

-- pass in a lasso segment. this function will check for any connections, and then start checking any adjacent lasso segments.
function game:lasso_check(player, x, y, skip_dir, skip_final, skip_match)
	-- defining tile
	local p = vars['player_' .. player]
	local tile = p.board[x][y]

	if (p.first_lasso_segment[1] == x and p.first_lasso_segment[2] == y) and not skip_final then
		self:lasso_match(player)
		return
	end

	-- if the block is a lasso, and it's not already accounted for, then...let's do some stuff to it!
	if tile.block ~= nil and find(tile.block, 'lasso') then
		tile.block = tile.original_block
		table.insert(p.lassos_in_match, {x, y})
		tile.checked = true

		local connections = {} -- connections bank for this block
		local block_matches = {} -- list of X and Y coords for adjacent, continuous lassos

		local dirs = self:lasso_dirs(p, x, y) -- get list of directions the lasso's facing
		local dir
		local new_dirs
		local new_dir

		-- check if any direction(s) are linked up continuously with another block
		for i = 1, #dirs do
			dir = dirs[i]
			-- up direction check
			if dir == 'u' then
				new_dirs = self:lasso_dirs(p, x, (y - 1) < 1 and 0 or (y - 1))
				if new_dirs ~= nil then
					for n = 1, #new_dirs do
						new_dir = new_dirs[n]
						if new_dir == 'd' then
							table.insert(connections, 'u')
							if skip_dir ~= 'u' then table.insert(block_matches, {x, (y - 1) < 1 and 0 or (y - 1), 'd'}) end
							break
						end
					end
				end
			end
			-- down direction check
			if dir == 'd' then
				new_dirs = self:lasso_dirs(p, x, (y + 1) > #p.board and 0 or (y + 1))
				if new_dirs ~= nil then
					for n = 1, #new_dirs do
						new_dir = new_dirs[n]
						if new_dir == 'u' then
							table.insert(connections, 'd')
							if skip_dir ~= 'd' then table.insert(block_matches, {x, (y + 1) > #p.board and 0 or (y + 1), 'u'}) end
							break
						end
					end
				end
			end
			-- left direction check
			if dir == 'l' then
				new_dirs = self:lasso_dirs(p, (x - 1) < 1 and 0 or (x - 1), y)
				if new_dirs ~= nil then
					for n = 1, #new_dirs do
						new_dir = new_dirs[n]
						if new_dir == 'r' then
							table.insert(connections, 'l')
							if skip_dir ~= 'l' then table.insert(block_matches, {(x - 1) < 1 and 0 or (x - 1), y, 'r'}) end
							break
						end
					end
				end
			end
			-- right direction check
			if dir == 'r' then
				new_dirs = self:lasso_dirs(p, (x + 1) > #p.board[1] and 0 or (x + 1), y)
				if new_dirs ~= nil then
					for n = 1, #new_dirs do
						new_dir = new_dirs[n]
						if new_dir == 'l' then
							table.insert(connections, 'r')
							if skip_dir ~= 'r' then table.insert(block_matches, {(x + 1) > #p.board[1] and 0 or (x + 1), y, 'l'}) end
							break
						end
					end
				end
			end
		end

		if connections[1] ~= nil then -- if there are connections to the current lasso...
			tile.block = tile.original_block .. '_connect'
			for i = 1, #connections do
				tile.block = tile.block .. '_' .. connections[i]
			end

			local sk = skip_match and true or false

			-- fetch the list of block matches
			for i = 1, min(#block_matches, 1) do
				local block_match = block_matches[i]
				self:lasso_check(player, block_match[1], block_match[2], block_match[3], sk, sk) -- and try to check the adjacent ones next.
			end
		end
	end
end

-- returns an array of directions in which the current lasso is pointing.
function game:lasso_dirs(p, x, y)
	if x == 0 or y == 0 then return nil end
	local tile = p.board[x][y].block
	local dirs = {}
	if tile ~= nil and find(tile, 'lasso') then
		if find(tile, '_u') == 6 or find(tile, '_u') == 8 then table.insert(dirs, 'u') end
		if find(tile, '_d') == 6 or find(tile, '_d') == 8 then table.insert(dirs, 'd') end
		if find(tile, '_l') == 6 or find(tile, '_l') == 8 then table.insert(dirs, 'l') end
		if find(tile, '_r') == 6 or find(tile, '_r') == 8 then table.insert(dirs, 'r') end
		return dirs
	else
		return nil
	end
end

function game:is_com(player)
	return (vars.arg1 == 'com' and player == 2)
end

-- run this function if a full lasso loop has been found!
function game:lasso_match(player)
	local p = vars['player_' .. player]

	if p.handler == 'playing' then p.handler = 'matching' end
	playsound(sfx_match)
	p.lassos = p.lassos + 1
	if not self:is_com(player) then save.total_lassos = save.total_lassos + 1 end

	if vars.mode == 'arcade' then
		local time = value('time')
		local new_time = time + (20000 * exp(-0.105 * p.lassos))
		resettimer('time', new_time, new_time, 0, 'linear', function()
			self:over(1)
			vars.time_up = true
		end)
	end

	for i = 1, #p.lassos_in_match do
		local anim_lasso_x = p.lassos_in_match[i][1]
		local anim_lasso_y = p.lassos_in_match[i][2]
		afterdelay('anim_match_' .. i .. '_' .. player, (50 * i), function()
			p.score = p.score + (5 * i)
			if not self:is_com(player) then save.cumulative_score = save.cumulative_score + (5 * i) end
			rumble(0.5, 0.5, 0.1)
			newtimer('anim_block_shine_' .. player .. '_' .. anim_lasso_x .. '_' .. anim_lasso_y, 150, 1, 4)
		end)
	end

	afterdelay('lasso_match_' .. player, 1000, function()
		local intersections
		local lasso_x
		local lasso_y
		local outlaws_caught = 0

		-- let's see what other tiles we need to remove.
		for i = 1, #p.board do
			for n = 1, #p.board[i] do
				tile = p.board[i][n]

				-- outlaw/tumble! let's check against the rightward lassos (thanks 2Darray!)
				if tile.block == 'outlaw' or tile.block == 'tumble' then
					intersections = 0

					for j = 1, #p.lassos_in_match do
						-- get lasso X and Y coords
						lasso_x = p.lassos_in_match[j][1]
						lasso_y = p.lassos_in_match[j][2]

						-- rightward lasso! let's see if there's a connected lasso above that one.
						if lasso_x > i and n == lasso_y then
							for z = 1, #p.lassos_in_match do
								lasso_x2 = p.lassos_in_match[z][1]
								lasso_y2 = p.lassos_in_match[z][2]

								-- this lasso is above the last one!
								if lasso_x == lasso_x2 and lasso_y - 1 == lasso_y2 then
									intersections = intersections + 1
								end
							end
						end
					end

					if intersections % 2 == 1 then -- if the intersection's odd, it's inside the walls.
						p.board[i][n] = {}
						if tile.block == 'outlaw' then outlaws_caught = outlaws_caught + 1 end
						newtimer('anim_block_clear_' .. player .. '_' .. i .. '_' .. n, 150, 1, 5)
					end
				end
			end
		end

		p.score = p.score + (100 * outlaws_caught)
		if not self:is_com(player) then
			save.outlaws_captured = save.outlaws_captured + outlaws_caught
			save.cumulative_score = save.cumulative_score + (100 * outlaws_caught)
		end

		rumble(0.5, 0.5, 0.5)

		for i = 1, #p.lassos_in_match do
			local lasso_x = p.lassos_in_match[i][1]
			local lasso_y = p.lassos_in_match[i][2]
			p.board[lasso_x][lasso_y] = {}
			newtimer('anim_block_clear_' .. player .. '_' .. lasso_x .. '_' .. lasso_y, 150, 1, 5)
		end
		p.lassos_in_match = {}
		playsound(sfx_match_clear)
		resettimer('anim_board_shake_' .. player, 500, 5, 0, 'linear', function()
			if p.handler == 'matching' then -- check if handler's still waiting; otherwise don't return input.
				p.handler = 'playing'
			end
		end)
	end)
end

function game:garbage_check(player)
	-- TODO: garbage check
		-- only do in VS mode
		-- garbage check and advance warning level (if there's garbage)
		-- garbage imminent warning SFX
		-- garbage throw down SFX
		-- rumble on garbage throw down
end

function game:over(player)
	-- this player lost! remember that.
	local p = vars['player_' .. player]

	stopmusic()
	playsound(_G['sfx_explode_' .. randInt(1, 3)])
	p.handler = 'gameover'
	rumble(1, 1, 1)

	if vars.mode == 'daily' then
		save.lastdaily.score = p.score
	elseif vars.mode ~= 'vs' then
		if save[vars.mode .. '_best'] ~= nil and p.score > save[vars.mode .. '_best'] then
			vars.new_best = true
			save[vars.mode .. '_best'] = p.score
		end
	end

	if vars.time ~= nil then
		local time = value('time')
		resettimer('time', 0, time, time, 'linear', function()
		end)
	end

	resettimer('anim_board_shake_' .. player, 1000, 5, 0, 'linear', function()
		afterdelay('results_delay', 1000, function()
			newmusic('audio/music/chill', true)
			vars.results_selections = {'new_game', 'go_back'}
			vars.results_selection = 1
			vars.results_hit_edge = false
			if p.handler == 'gameover' then p.handler = 'results' end
		end)
	end)

	-- TODO: increment save win counters accordingly for VS modes
	-- TODO: increment arg2 win counters accordingly for VS modes, too
end

function game:keypressed(button)
	if vars.player_1.handler == 'playing' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.player_1.cursor.y = vars.player_1.cursor.y - 1
			if vars.player_1.cursor.y < 1 then
				vars.player_1.cursor.y = 1
				resettimer('anim_cursor_bonk_1', 75, 1, 3)
				vars.player_1.cursor.y_offset = -3
				playsound(sfx_game_bonk)
			else
				vars.player_1.cursor.y_offset = 5
				playsound(sfx_game_move)
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.player_1.cursor.y = vars.player_1.cursor.y + 1
			if vars.player_1.cursor.y > #vars.player_1.board[1] then
				vars.player_1.cursor.y = #vars.player_1.board[1]
				resettimer('anim_cursor_bonk_1', 75, 1, 3)
				vars.player_1.cursor.y_offset = 3
				playsound(sfx_game_bonk)
			else
				vars.player_1.cursor.y_offset = -5
				playsound(sfx_game_move)
			end
		elseif button == (platform == 'peedee' and 'left' or platform == 'love' and save.left) then
			vars.player_1.cursor.x = vars.player_1.cursor.x - 1
			if vars.player_1.cursor.x < 1 then
				vars.player_1.cursor.x = 1
				resettimer('anim_cursor_bonk_1', 75, 1, 3)
				vars.player_1.cursor.x_offset = -3
				playsound(sfx_game_bonk)
			else
				vars.player_1.cursor.x_offset = 5
				playsound(sfx_game_move)
			end
		elseif button == (platform == 'peedee' and 'right' or platform == 'love' and save.right) then
			vars.player_1.cursor.x = vars.player_1.cursor.x + 1
			if vars.player_1.cursor.x > #vars.player_1.board then
				vars.player_1.cursor.x = #vars.player_1.board
				resettimer('anim_cursor_bonk_1', 75, 1, 3)
				vars.player_1.cursor.x_offset = 3
				playsound(sfx_game_bonk)
			else
				vars.player_1.cursor.x_offset = -5
				playsound(sfx_game_move)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			self:hold_block(1)
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			self:place_block(1)
		end
	elseif vars.player_1.handler == 'paused' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.pause_selection = vars.pause_selection - 1
			if vars.pause_selection < 1 then
				vars.pause_selection = 1
				vars.pause_bonk_offset = -5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.pause_selection = vars.pause_selection + 1
			if vars.pause_selection > #vars.pause_selections then
				vars.pause_selection = #vars.pause_selections
				vars.pause_bonk_offset = 5
				playsound(sfx_menu_bonk)
			else
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			self:unpause()
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			playsound(sfx_select)
			local sel = vars.pause_selections[vars.pause_selection]
			if sel == 'resume' then
				self:unpause()
			elseif sel == 'quit' then
				fademusic()
				scenemanager:transitionscene(modeselect)
			end
		end
	elseif vars.player_1.handler == 'results' then
		if button == (platform == 'peedee' and 'up' or platform == 'love' and save.up) then
			vars.results_selection = vars.results_selection - 1
			if vars.results_selection < 1 then
				vars.results_selection = 1
				vars.results_bonk_offset = -5
				playsound(sfx_menu_bonk)
			else
				vars.results_hit_edge = false
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'down' or platform == 'love' and save.down) then
			vars.results_selection = vars.results_selection + 1
			if vars.results_selection > #vars.results_selections then
				vars.results_selection = #vars.results_selections
				vars.results_bonk_offset = 5
				playsound(sfx_menu_bonk)
			else
				vars.results_hit_edge = false
				playsound(sfx_menu_move)
			end
		elseif button == (platform == 'peedee' and 'b' or platform == 'love' and save.secondary) then
			playsound(sfx_back)
			fademusic()
			scenemanager:transitionscene(modeselect)
		elseif button == (platform == 'peedee' and 'a' or platform == 'love' and save.primary) then
			playsound(sfx_select)
			fademusic()
			local sel = vars.results_selections[vars.results_selection]
			if sel == 'new_game' then
				scenemanager:transitionscene(game, vars.mode, vars.arg1, vars.arg2)
			elseif sel == 'go_back' then
				scenemanager:transitionscene(modeselect)
			end
		end
	end
end

if platform == 'love' then return game end