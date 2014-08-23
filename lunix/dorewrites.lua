_G._LUNIX = "Lunix Prototype v0.0"

_G.new = function(super)
	local object = {}
	setmetatable(object, super)
	super.__index = super
	return object
end

_G.intable = function(item, list)
	if type(list) == "table" then
		for key, value in pairs(list) do
			if value == item then
				return true
			end
		end
	else
		error("expected value, table")
	end
	return false
end

_G.read = function(replaceChar, history)
	if type(replaceChar) ~= "string" then
		replaceChar = ""
	end
	term.setCursorBlink(true)
	local line = ""
	local stored = ""
	local pos = 0
	local scroll = 1
	local width, height = term.getSize()
	local cursorX, cursorY = term.getCursorPos()
	if type(history) ~= "table" then
		history = {}
	end
	local historyPos = #history + 1
	while true do
		local length = width - cursorX
		if pos + 1 > scroll + length then
			scroll = pos - length + 1
		end
		if length - (pos - scroll) < 8 and scroll + length - 1 < #line then
			scroll = pos + 8 - length
		end
		if pos + 1 < scroll then
			scroll = pos + 1
		end
		if pos > 7 and pos - scroll < 7 then
			scroll = pos - 7
		end
		local startX = cursorX - scroll + 1
		term.setCursorPos(startX + scroll - 1, cursorY)
		local word = string.sub(line, scroll, scroll + length)
		if #replaceChar > 0 then
			word = string.rep(replaceChar, #word)
		end
		if #word < length then
			word = word..string.rep(" ", length - #word)
		end
		term.write(word.." ")
		term.setCursorPos(startX + pos, cursorY)
		local event = {os.pullEvent({"key", "char", "monitor_touch", "mouse_click", "paste"})}
		if intable(event[1], {"char", "paaste"}) then
			line = string.sub(line, 1, pos)..event[2]..string.sub(line, pos + 1)
			pos = pos + #event[2]
			historyPos = #history + 1
		elseif event[1] == "key" then
			if event[2] == keys["enter"] then
				break
			elseif event[2] == keys["left"] then
				if pos > 0 then
					pos = pos - 1
				end
			elseif event[2] == keys["right"] then
				if pos < #line then
					pos = pos + 1
				end
			elseif event[2] == keys["backspace"] then
				if pos > 0 then
					line = string.sub(line, 1, pos - 1)..string.sub(line, pos + 1)
					pos = pos - 1
				end
			elseif event[2] == keys["delete"] then
				line = string.sub(line, 1, pos)..string.sub(line, pos + 2)
			elseif event[2] == keys["home"] then
				pos = 0
			elseif event[2] == keys["end"] then
				pos = #line
			elseif intable(event[2], {keys["up"], keys["down"]}) then
				if event[2] == keys["up"] then
					if historyPos > 1 then
						historyPos = historyPos - 1
						if historyPos == #history + 1 then
							line = stored
						elseif historyPos == #history then
							stored = line
						end
					end
				else
					if historyPos < #history + 2 then
						historyPos = historyPos + 1
						if historyPos == #history + 1 then
							line = stored
						elseif historyPos == #history + 2 then
							stored = line
							line = ""
						end
					end
				end
				if historyPos <= #history then
					line = history[historyPos]
				end
				pos = #line
			end
		elseif intable(event[1], {"mouse_click", "monitor_touch"}) then
			if event[4] == cursorY then
				pos = event[3] - startX
				if pos < 0 then
					pos = 0
				elseif pos > #line then
					pos = #line
				end
			end
		end
	end
	term.setCursorBlink(false)
	term.setCursorPos(cursorX, cursorY)
	term.write(line)
	print()
	return line
end

colors.WHITE = 1
colors.ORANGE = 2
colors.MAGENTA = 4
colors.LIGHTBLUE = 8
colors.YELLOW = 16
colors.LIME = 32
colors.PINK = 64
colors.GREY = 128
colors.GRAY = 128
colors.LIGHTGREY = 256
colors.LIGHTGRAY = 256
colors.CYAN = 512
colors.PURPLE = 1024
colors.BLUE = 2048
colors.BROWN = 4096
colors.GREEN = 8192
colors.RED = 16384
colors.BLACK = 32768

colors[1] = "WHITE"
colors[2] = "ORANGE"
colors[4] = "MAGENTA"
colors[8] = "LIGHTBLUE"
colors[16] = "YELLOW"
colors[32] = "LIME"
colors[64] = "PINK"
colors[128] = "GREY"
colors[256] = "LIGHTGREY"
colors[512] = "CYAN"
colors[1024] = "PURPLE"
colors[2048] = "BLUE"
colors[4096] = "BROWN"
colors[8192] = "GREEN"
colors[16384] = "RED"
colors[32768] = "BLACK"

colors.grey = colors.gray
colours.gray = colours.grey
colors.lightGrey = colors.lightGray
colours.lightGray = colours.lightGrey

colors.getNextColor = function(ID)
	if ID == colors.BLACK then
		return colors.WHITE
	end
	return ID * 2
end

colors.getPrevColor = function(ID)
	if ID == colors.WHITE then
		return colors.BLACK
	end
	return ID / 2
end

colors.getColorName = function(ID, American)
	if type(ID) == "number" then
		ID = colors[ID]
	end
	if ID == colors[128] and American == true then
		return "Gray"
	end
	if ID == colors[256] then
		if American == true then
			return "Light Gray"
		end
		return "Light Grey"
	elseif ID == colors[8] then
		return "Light Blue"
	end
	return string.upper(string.sub(ID, 1, 1))..string.lower(string.sub(ID, 2))
end

colours.getNextColor = colors.getNextColor
colours.getPrevColor = colors.getPrevColor
colours.getColorName = colors.getColorName

fs.format = function(path, root)
	if path == nil then
		error("path is nil", 3)
	end
	path = path.."/"
	while string.match(path, "/+%./+") do
		path = string.gsub(path, "/+%./+", "/", 1)
	end
	while string.match(path, "/+[^/]+/+%.%./+") do
		path = string.gsub(path, "/+[^/]+/+%.%./+", "/", 1)
	end
	path = string.gsub(path, "^~/", "/home/"..os.user().."/")
	path = string.gsub(path, "^%./", "")
	path = string.gsub(path, "^%.%./", "/")
	path = string.gsub(path, "^/+%.%./", "/")
	if root then
		path = "/"..path
	end
	path = string.gsub(path, "/+", "/")
	if string.match(path, ".+/$") then
		path = string.gsub(path, "/$", "")
	end
	return path
end

fs.combine = function(parent, child)
	if parent == nil or child == nil then
		error("Expected string, string")
	end
	if parent == "" then
		return fs.format(child)
	end
	return fs.format(parent.."/"..child)
end

local fs_defaults = {}
do -- Rewriting all of the FS module using the just-defined fs.format to convert paths to fs-readable paths (ie, no special symbols: ~ . ..)
	for index, funcName in ipairs({"list", "exists", "getName", "getDrive", "getSize", "getFreeSpace"}) do -- These just point to functions that return 1 thing based on what's passed
		fs_defaults[funcName] = fs[funcName]
		fs[funcName] = function(path)
			return fs_defaults[funcName](fs.format(path, true))
		end
	end

	for index, funcName in ipairs({"isDir", "isReadOnly"}) do -- These ensure that the path exists before returning
		fs_defaults[funcName] = fs[funcName]
		fs[funcName] = function(path)
			return fs.exists(path) and fs_defaults[funcName](fs.format(path))
		end
	end

	for index, funcName in ipairs({"makeDir", "delete"}) do -- These don't return anything
		fs_defaults[funcName] = fs[funcName]
		fs[funcName] = function(path)
			fs_defaults[funcName](fs.format(path, true))
		end
	end

	for index, funcName in ipairs({"move", "copy"}) do -- These take 2 arguments, and don't return anything
		fs_defaults[funcName] = fs[funcName]
		fs[funcName] = function(fromPath, toPath)
			fs_defaults[funcName](fs.format(fromPath, true), fs.format(toPath, true))
		end
	end

	fs_defaults["open"] = fs["open"] -- This is here just for the sake of consistency.
	fs["open"] = function(path, mode)
		return fs_defaults["open"](fs.format(path, true), mode)
	end
end

fs.isFile = function(path)
	return fs.exists(path) and not fs.isDir(path)
end

fs.getDir = function(path)
	return fs.combine("", string.match(path, "(.*)/."))
end

fs.getExt = function(path)
	return string.match(path, "[^./]%.([^/]*)$")
end

os.loadAPI = function(path)
	local name = fs.getName(path)
	if fs.getExt(name) ~= "" then
		name = string.sub(name, 1, #name - #(fs.getExt(name)) - 1)
	end
	if not fs.isFile(path) then
		path = path..".lua"
		if not fs.isFile(path) then
			printerror("API "..name.." doesn't exist")
		end
	end
	local env = {}
	setmetatable(env, {__index = _G})
	local func, err = loadfile(path)
	local result
	if func then
		setfenv(func, env)
		result = func()
	else
		printError(err)
		return false
	end
	if type(result) == "table" then
		_G[name] = result
		return true
	end
	local api = {}
	for k,v in pairs(env) do
		api[k] = v
	end
	_G[name] = api
	return true
end

os.lunix = function()
	return _G._LUNIX
end

os.pullEvent = function(eventNames)
	local event = {}
	repeat
		event = {os.pullEventRaw()}
	until event[1] == "terminate" or (string.match(event[1], "^[^.]") and eventNames == nil) or (type(eventNames) == "table" and intable(event[1], eventNames)) or (type(eventNames) == "string" and event[1] == eventNames)
	if event[1] == "terminate" then
		error("Terminated", 0)
	end
	return unpack(event)
end

local user = "guest"
os.user = function()
	return user
end

os.setUser = function(newUser)
	local userlist = {}
	local f_ul = fs.open("/lunix/.user_list.txt", "r")
	if f_ul then
		local users = f_ul.readAll()
		f_ul.close()
		for name in string.gmatch(users, "[%w_]+") do
			userlist[#userlist + 1] = name
		end
	end
	if #userlist == 0 then
		userlist = {"guest"}
		f_ul = fs.open("/lunix/.user_list.txt", "w")
		f_ul.write("guest")
		f_ul.close()
		newUser = "guest"
	end
	if intable(newUser, userlist) then
		user = newUser
		local f_lu = fs.open("/lunix/.last_user.txt", "w")
		f_lu.write(user)
		f_lu.close()
		return true
	end
	return false
end

local setBC = term.setBackgroundColor
term.setBackgroundColor = function(iscolor, isntcolor)
	if not intable(isntcolor, {colors.WHITE, colors.BLACK}) then
		isntcolor = colors.BLACK
	end
	setBC(isntcolor)
	if term.isColor() or intable(iscolor, {colors.WHITE, colors.BLACK}) then
		setBC(iscolor)
	end
end

local setTC = term.setTextColor
term.setTextColor = function(iscolor, isntcolor)
	if not intable(isntcolor, {colors.WHITE, colors.BLACK}) then
		isntcolor = colors.WHITE
	end
	setTC(isntcolor)
	if term.isColor() or intable(iscolor, {colors.WHITE, colors.BLACK}) then
		setTC(iscolor)
	end
end

textutils.serialize = function(thing, recurstack)
	if type(recurstack) ~= "table" then
		recurstack = {}
	end
	if type(thing) == "table" then
		local result = "{"
		for key, value in pairs(thing) do
			if intable(type(key), {"table", "string", "number", "boolean", "nil"}) and intable(type(value), {"table", "string", "number", "boolean", "nil"}) and recurstack[value] == nil then
				recurstack[value] = true
				result = result..("["..textutils.serialize(key, recurstack).."]="..textutils.serialize(value, recurstack)..",")
				recurstack[value] = nil
			end
		end
		result = result.."}"
		return result
	elseif type(thing) == "string" then
		return "\""..thing.."\""
	elseif intable(type(thing), {"number", "boolean", "nil"}) then
		return tostring(thing)
	end
end