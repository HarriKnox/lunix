if not term.isColor() then
	error("Must be played on an advanced computer/monitor/turtle")
end

generate = function(mouseX, mouseY)
	if lightPercent then
		if lightPercent > 0 then
			lightsAmount = math.floor(screenSize[1] * screenSize[2] * lightPercent / 100)
		else
			lightsAmount = 0
		end
	else
		lightsAmount = math.floor(math.random(screenSize[1] * screenSize[2] * 0.1, screenSize[1] * screenSize[2] * 0.2))
	end
	if lightsAmount > 0 then
		local count = 0
		repeat
			x = math.random(1, screenSize[1])
			y = math.random(1, screenSize[2])
			if not Spaces[x][y].hit then
				if showGen then
					draw()
					os.sleep(0)
				end
				switch(x, y)
				count = count + 1
			end
		until count == lightsAmount
	end
end

switch = function(x, y)
	Spaces[x][y].hit = not Spaces[x][y].hit
	for dX = -1, 1 do
		for dY = -1, 1 do
			if x + dX >= 1 and x + dX <= screenSize[1] and y + dY >= 1 and y + dY <= screenSize[2] then
				Spaces[x + dX][y + dY].lit = not Spaces[x + dX][y + dY].lit
			end
		end
	end
end

draw = function()
	for y = 1, screenSize[2] do
		for x = 1, screenSize[1] do
			term.setCursorPos(x, y)
			if Spaces[x][y].lit then
				if cheat and Spaces[x][y].hit then
					term.setTextColor(colors.red)
					term.setBackgroundColor(colors.orange)
				else
					term.setTextColor(colors.orange)
					term.setBackgroundColor(colors.yellow)
				end
			else
				if cheat and Spaces[x][y].hit then
					term.setTextColor(colors.green)
					term.setBackgroundColor(colors.lime)
				else
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.green)
				end
			end
			term.write("-")
		end
	end
end

reset = function()
	Spaces = {}
	for x = 1, screenSize[1] do
		Spaces[x] = {}
		for y = 1, screenSize[2] do
			Spaces[x][y] = {lit = false, hit = false}
		end
	end
	generate()
end

allDone = function()
	local lit = 0
	for x = 1, screenSize[1] do
		for y = 1, screenSize[2] do
			if Spaces[x][y].lit then
				lit = lit + 1
			end
		end
	end
	return lit == 0 and lightPercent ~= 0
end

gameLoop = function()
	while running do
		draw()
		local event = {}
		repeat
			event = {os.pullEvent()}
		until (event[1] == "mouse_click" and not monitor) or event[1] == "char" or event[1] == "monitor_touch" or event[1] == "monitor_resize"
		if event[1] == "mouse_click" or event[1] == "monitor_touch" then
			switch(event[3], event[4])
		elseif event[1] == "char" then
			if event[2] == "q" then
				term.setBackgroundColor(colors.black)
				term.clear()
				term.setCursorPos(1, 1)
				error()
			elseif event[2] == "c" then
				cheat = not cheat
			elseif event[2] == "r" then
				running = false
			end
		elseif event[1] == "monitor_resize" then
			running = false
		end
		if allDone() then
			running = false
		end
	end
end


do
	local args = {...}
	if tonumber(args[1]) then
		lightPercent = tonumber(args[1])
	elseif tonumber(args[2]) then
		lightPercent = tonumber(args[2])
	else
		lightPercent = nil
	end
	if lightPercent then
		if lightPercent < 0 then
			lightPercent = 0
		elseif lightPercent > 100 then
			lightPercent = 100
		end
	end
	if args[1] == "g" or args[2] == "g" then
		showGen = true
	else
		showGen = false
	end
end
term.setCursorBlink(false)
while true do
	screenSize = {term.getSize()}
	running = true
	cheat = false
	reset()
	gameLoop()
end