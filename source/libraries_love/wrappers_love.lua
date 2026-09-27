local gfx = love.graphics
local floor = math.floor
local ceil = math.ceil
local sx
local sy
local sw
local sh
local cx
local cy

function savegame()
	love.filesystem.write('data.json', json.encode(save))
end

function newimage(image, y, color)
	if y ~= nil then
		local image = gfx.newCanvas(image, y)
		color = color or 'clear'
		gfx.setCanvas(image)
		if color == 'black' then
			gfx.clear(0, 0, 0, 1)
		elseif color == 'white' then
			gfx.clear(1, 1, 1, 1)
		elseif color == 'clear' then
			gfx.clear()
		end
		gfx.setCanvas()
		return image
	else
		return gfx.newImage(image .. '.png')
	end
end

function drawimage(image, x, y, flip)
	local sx = 1
	local ox = 0
	if flip == 'flipx' then
		sx = -1
		ox = image:getWidth() - 1
	end
	gfx.draw(image, floor(x), floor(y), 0, sx, 1, ox, 0)
end

function clearimage(image, color)
	color = color or 'clear'
	gfx.setCanvas(image)
	if color == 'black' then
		gfx.clear(0, 0, 0, 1)
	elseif color == 'white' then
		gfx.clear(1, 1, 1, 1)
	elseif color == 'clear' then
		gfx.clear()
	end
	gfx.setCanvas()
end

function imagesize(image)
	return image:getDimensions()
end

function newimagetable(image, width, height, cells)
	local img = gfx.newImage(image .. '-table-' .. width .. '-' .. height .. '.png')
	local w = img:getWidth()
	local h = img:getHeight()
	local indexes = {}
	for i = 1, cells do
		local column = i % (w / width)
		if column == 0 then column = (w / width) end
		local row = ceil(i / (w / width))
		indexes[i] = gfx.newQuad((column - 1) * width, (row - 1) * height, width, height, w, h)
	end
	return {img, indexes}
end

function drawimagetable(image, index, x, y)
	gfx.draw(image[1], image[2][index], floor(x), floor(y))
end

function newnineslice(image, innerx, innery, innerwidth, innerheight)
	local img = love.image.newImageData(image .. '.png')
	local width, height = img:getDimensions()
	local holdcorners = {}
	local corners = {}
	local holdedges = {}
	local edges = {}
	local holdcenter
	local center
	for i = 1, 4 do
		holdcorners[i] = love.image.newImageData(innerx, innery)
		holdedges[i] = love.image.newImageData(innerx, innery)
	end
	holdcenter = love.image.newImageData(innerx, innery)

	-- corners
	holdcorners[1]:paste(img, 0, 0, 0, 0, width, height)
	holdcorners[2]:paste(img, 0, 0, width - innerx, 0, width, height)
	holdcorners[3]:paste(img, 0, 0, width - innerx, height - innery, width, height)
	holdcorners[4]:paste(img, 0, 0, 0, height - innery, width, height)

	-- edges
	holdedges[1]:paste(img, 0, 0, innerx, 0, width, height)
	holdedges[2]:paste(img, 0, 0, width - innerx, innery, width, height)
	holdedges[3]:paste(img, 0, 0, innerx, height - innery, width, height)
	holdedges[4]:paste(img, 0, 0, 0, innery, width, height)

	-- center
	holdcenter:paste(img, 0, 0, innerx, innery, width, height)

	for i = 1, 4 do
		corners[i] = gfx.newImage(holdcorners[i])
		edges[i] = gfx.newImage(holdedges[i])
		edges[i]:setWrap('repeat', 'repeat')
	end
	center = gfx.newImage(holdcenter)
	center:setWrap('repeat', 'repeat')

	return {{width, height}, {innerx, innery, innerwidth, innerheight}, corners, edges, center}
end

function drawnineslice(image, x, y, width, height)
	imgwidth, imgheight = table.unpack(image[1])
	innerx, innery, innerwidth, innerheight = table.unpack(image[2])

	-- corners
	gfx.draw(image[3][1], 0, 0)
	gfx.draw(image[3][2], width - innerx, 0)
	gfx.draw(image[3][3], width - innerx, height - innery)
	gfx.draw(image[3][4], 0, height - innery)

	local edgequads = {}
	edgequads[1] = gfx.newQuad(0, 0, width - (innerx * 2), innery, innerx, innery)
	edgequads[2] = gfx.newQuad(0, 0, innerx, height - (innery * 2), innerx, innery)

	-- edges
	gfx.draw(image[4][1], edgequads[1], innerx, 0)
	gfx.draw(image[4][2], edgequads[2], width - innerx, innery)
	gfx.draw(image[4][3], edgequads[1], innerx, height - innery)
	gfx.draw(image[4][4], edgequads[2], 0, innery)

	-- center
	centerquad = gfx.newQuad(0, 0, width - (innerx * 2), height - (innery * 2), innerx, innery)
	gfx.draw(image[5], centerquad, innerx, innery)
end

function newtimer(name, duration, startvalue, endvalue, easing, callback, group)
	if vars ~= nil then
		if vars[name] ~= nil then
			vars[name]:remove()
			vars[name] = nil
		end
		if easing == nil then easing = 'linear' end
		vars[name .. 'value'] = startvalue
		vars[name] = timer.tween(duration / 1000, {
			[vars] = {[name .. 'value'] = endvalue}
		})
			:ease(easings[easing])
			:group(group or nil)
		vars[name].timerEndedCallback = callback or nil
		vars[name]:finish(vars[name].timerEndedCallback)
	end
end

function timerendedcallback(name, callback)
	vars[name].timerEndedCallback = callback or nil
	vars[name]:finish(vars[name].timerEndedCallback)
end

function timeleft(name)
	if vars[name] ~= nil then
		local elapsed = vars[name].elapsed
		local duration = vars[name].duration
		local timeleft = duration - elapsed
		if timeleft < 0 then timeleft = 0 end
		return (timeleft) * 1000
	elseif vars[name .. 'value'] ~= nil then
		return vars[name .. 'value']
	else
		return 0
	end
end

function value(name)
	return vars[name .. 'value']
end

function resettimer(name, duration, startvalue, endvalue, easing, callback, group)
	if vars ~= nil then
		if vars[name] ~= nil then
			vars[name]:remove()
			vars[name] = nil
		end
		if easing == nil then easing = 'linear' end
		vars[name .. 'value'] = startvalue
		vars[name] = timer.tween(duration / 1000, {
			[vars] = {[name .. 'value'] = endvalue}
		})
			:ease(easings[easing])
			:group(group or nil)
		vars[name].timerEndedCallback = callback or nil
		vars[name]:finish(vars[name].timerEndedCallback)
	end
end

function loopingtimer(name, duration, startvalue, endvalue, easing, callback, group, delay)
	newtimer(name, duration, startvalue, endvalue, easing, function()
		loopingtimer(name, duration, startvalue, endvalue, easing, callback, group)
	end, group)
end

function delaytimer(name, delay, duration, startvalue, endvalue, easing, callback, group)
	if vars ~= nil then
		vars[name .. 'value'] = startvalue
		vars[name .. 'delay'] = timer.after(delay / 1000, function()
			if vars[name .. 'value'] ~= nil then
				newtimer(name, duration, startvalue, endvalue, easing, callback, group)
			end
		end)
	end
end

function loopingdelaytimer(name, delay, duration, startvalue, endvalue, easing, callback, group)
	delaytimer(name, delay, duration, startvalue, endvalue, easing, function()
		loopingdelaytimer(name, delay, duration, startvalue, endvalue, easing, callback, group)
	end, group)
end

function afterdelay(name, duration, callback)
	if vars ~= nil then
		vars[name .. 'gate'] = true
		vars[name] = timer.after(duration / 1000, function()
			if vars[name .. 'gate'] ~= nil then
				callback()
			end
		end)
	end
end

function newfont(font)
	return gfx.newFont(font ~= nil and (font .. '.fnt') or nil, font ~= nil and (font .. '.png') or nil)
end

function drawtext(font, text, x, y, alignment)
	if font ~= nil then gfx.setFont(font) end
	x = floor(x)
	y = floor(y)
	if alignment ~= nil then
		if alignment == 'center' then
			gfx.printf(text, x - 200, y, 400, alignment)
		elseif alignment == 'right' then
			gfx.printf(text, x - 400, y, 400, alignment)
		end
	else
		gfx.print(text, x, y)
	end
end

function textwidth(font, text)
	return font:getWidth(text)
end

function newsound(sound)
	return love.audio.newSource(sound .. '.wav', 'static')
end

-- Plays a sound (stopping the previous instance if already playing). Import LÖVE sound object
function playsound(sound)
	if save.sfx then
		sound:stop()
		sound:play()
	end
end

-- Create a pool of up to five sound effects, randomly playing one of 'em. Import LÖVE sound objects
function randomizesfx(sfx1, sfx2, sfx3, sfx4, sfx5, rate)
	if save.sfx then
		local sfc = 0
		if sfx1 ~= nil then sfc = sfc + 1 end
		if sfx2 ~= nil then sfc = sfc + 1 end
		if sfx3 ~= nil then sfc = sfc + 1 end
		if sfx4 ~= nil then sfc = sfc + 1 end
		if sfx5 ~= nil then sfc = sfc + 1 end
		local rand = randInt(1, sfc)
		if rand == 1 then
			sfx1:setPitch(rate or 1)
			playsound(sfx1)
		elseif rand == 2 then
			sfx2:setPitch(rate or 1)
			playsound(sfx2)
		elseif rand == 3 then
			sfx3:setPitch(rate or 1)
			playsound(sfx3)
		elseif rand == 4 then
			sfx4:setPitch(rate or 1)
			playsound(sfx4)
		elseif rand == 5 then
			sfx5:setPitch(rate or 1)
			playsound(sfx5)
		end
	end
end

-- Fades the music out, and trashes it when finished. Should be called alongside a scene change, only if the music is expected to change. Delay can set the delay (in seconds) of the fade
function fademusic(delay)
	delay = delay or 400
	if music ~= nil then
		musicfade = timer.tween(delay / 1000, {
			[_G] = {['volume'] = 0}
		})
			:finish(function()
				if music ~= nil then love.audio.stop(music) end
			end)
			:group(transition)
	end
end

function stopmusic()
	if music ~= nil then
		love.audio.stop(music)
		music = nil
	end
end

function setmusicvolume(newvol)
	if music ~= nil then
		volume = newvol
	end
end

-- New music track. This should be called in a scene's init, only if there's no track leading into it. File is a path to an audio file in the PDX. Loop, if true, will loop the audio file. Range will set the loop's starting range.
function newmusic(file, loop, range)
	if save.music and music == nil then -- If a music file isn't actively playing...then go ahead and set a new one.
		music = love.audio.newSource(file .. '.wav', 'stream')
		volume = 1
		if loop then
			music:setLooping(true)
		end
		love.audio.play(music)
	end
end

-- r, g, b are ranges from 0 to 255. a is a range from 0 to 1
function setcolor(r, g, b, a)
	gfx.setColor(r / 255, g / 255, b / 255, a or 1)
end

function setbackgroundcolor(color)
	color = color or 'black'
	if color == 'black' then
		gfx.setBackgroundColor(0, 0, 0, 1)
	elseif color == 'white' then
		gfx.setBackgroundColor(1, 1, 1, 1)
	elseif color == 'clear' then
		gfx.setBackgroundColor(1, 1, 1, 0)
	end
end

function drawrect(x, y, w, h, r)
	x = floor(x)
	y = floor(y)
	w = floor(w)
	h = floor(h)
	local lw = gfx.getLineWidth()
	r = r or 0
	gfx.rectangle('line', x + (lw / 2), y + (lw / 2), w - lw, h - lw, r, r)
end

function fillrect(x, y, w, h, r)
	x = floor(x)
	y = floor(y)
	w = floor(w)
	h = floor(h)
	r = r or 0
	gfx.rectangle('fill', x, y, w, h, r, r)
end

function drawline(x1, y1, x2, y2)
	x1 = floor(x1)
	y1 = floor(y1)
	x2 = floor(x2)
	y2 = floor(y2)
	gfx.line(x1, y1, x2, y2)
end

function drawcircle(x, y, radius)
	x = floor(x)
	y = floor(y)
	radius = floor(radius)
	local lw = gfx.getLineWidth()
	gfx.circle('line', x, y, radius - (lw / 2))
end

function fillcircle(x, y, radius)
	x = floor(x)
	y = floor(y)
	radius = floor(radius)
	gfx.circle('fill', x, y, radius)
end

function drawtriangle(x1, y1, x2, y2, x3, y3)
	x1 = floor(x1)
	y1 = floor(y1)
	x2 = floor(x2)
	y2 = floor(y2)
	x3 = floor(x3)
	y3 = floor(y3)
	gfx.polygon('line', x1, y1, x2, y2, x3, y3)
end

function filltriangle(x1, y1, x2, y2, x3, y3)
	x1 = floor(x1)
	y1 = floor(y1)
	x2 = floor(x2)
	y2 = floor(y2)
	x3 = floor(x3)
	y3 = floor(y3)
	gfx.polygon('fill', x1, y1, x2, y2, x3, y3)
end

function drawpolygon(points, transform)
	gfx.line(points)
end

function fillpolygon(points, transform)
	gfx.polygon('fill', points)
end

function setcliprect(x, y, w, h)
	x = floor(x)
	y = floor(y)
	w = floor(w)
	h = floor(h)
	if cliprect ~= nil then
		clearcliprect() -- just in case.
	end
	cliprect = gfx.newCanvas(w, h)
	gfx.setCanvas(cliprect)
	gfx.push()
	sx, sy, sw, sh = gfx.getScissor()
	cx = x
	cy = y
	gfx.setScissor()
	gfx.origin()
	gfx.translate(-x, -y)
	gfx.clear()
end

function clearcliprect()
	gfx.setCanvas()
	gfx.setScissor(sx, sy, sw, sh)
	gfx.pop()
	drawimage(cliprect, cx, cy)
	cliprect = nil
end

function pushcontext(image)
	gfx.setCanvas(image)
	gfx.push()
	sx, sy, sw, sh = gfx.getScissor()
	gfx.setScissor()
	gfx.origin()
	gfx.clear()
end

function popcontext()
	gfx.setCanvas()
	gfx.setScissor(sx, sy, sw, sh)
	gfx.pop()
end

function gettime()
	return os.date('*t')
end

function getreduceflashing()
	return (save.reduceflashing >= 1)
end

function randomseed()
	setRandomSeed(os.time())
end