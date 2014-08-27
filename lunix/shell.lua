local parentShell = shell

local running = true
local directory = fs.format("~")
if not fs.exists(directory) then
	directory = "/"
end
local pathVariable = ".:~/my_programs:/commands:/programs:/games"
local aliases = {
	ls = "list",
	dir = "list",
	cp = "copy",
	mv = "move",
	rm = "delete"
}
local programStack = {}
local shell = {}
local env = {shell = shell}

local run = function(command, ...)
	local path = shell.resolveProgram(command)
	if path == nil then
		printError("No such program")
		return false
	end
	programStack[#programStack + 1] = path
	local result = os.run(env, path, ...)
	programStack[#programStack] = nil
	return result
end

local runLine = function(line)
	local words = {}
	for capture in string.gmatch(line, "[^ \t]+") do
		words[#words + 1] = capture
	end

	local command = words[1]
	if command then
		return run(command, unpack(words, 2))
	end
	return false
end

shell.run = function (...)
	return runLine(table.concat({...}, " "))
end

shell.exit = function()
	running = false
end

shell.dir = function()
	return directory
end

shell.setDir = function(dir)
	dir = shell.resolve(dir)
	if fs.exists(dir) then
		directory = dir
		return true
	end
	return false
end

shell.path = function()
	return pathVariable
end

shell.setPath = function(path)
	pathVariable = path
end

shell.resolve = function(path)
	if string.match(path, "^[/~]") then
		return fs.format(path, true)
	else
		return fs.combine(directory, path)
	end
end

shell.resolveProgram = function(command)
	if aliases[command] ~= nil then
		command = aliases[command]
	end
	if string.match(command, "^[/~]") then
		local path = fs.format(command, true)
		if fs.isFile(path) then
			return path
		end
		if fs.isFile(path..".lua") then
			return path..".lua"
		end
		return nil
	end
	for path in string.gmatch(pathVariable, "[^:]+") do
		path = fs.combine(shell.resolve(path), command)
		if fs.isFile(path) then
			return path
		end
		if fs.isFile(path..".lua") then
			return path..".lua"
		end
	end
	return nil
end

shell.commands = function(includeHidden)
	local items = {}
	local path = "/commands"
	local list = fs.list(path)
	for index, file in pairs(list) do
		if fs.isFile(fs.combine(path, file)) and (includeHidden or string.sub(file, 1, 1) ~= ".") then
			items[#items + 1] = string.gsub(file, "(.+)%.[^/]+", "%1")
		end
	end
	table.sort(items)
	return items
end

shell.programs = function(includeHidden)
	local items = {}
	local path = "/programs"
	local list = fs.list(path)
	for index, file in pairs(list) do
		if fs.isFile(fs.combine(path, file)) and (includeHidden or string.sub(file, 1, 1) ~= ".") then
			items[#items + 1] = file
		end
	end
	table.sort(items)
	return items
end

shell.games = function(includeHidden)
	local items = {}
	local path = "/games"
	local list = fs.list(path)
	for index, file in pairs(list) do
		if fs.isFile(fs.combine(path, file)) and (includeHidden or string.sub(file, 1, 1) ~= ".") then
			items[#items + 1] = file
		end
	end
	table.sort(items)
	return items
end

shell.getRunningProgram = function()
	if #programStack > 0 then
		return programStack[#programStack]
	end
	return nil
end

shell.setAlias = function(command, program)
	aliases[command] = program
end

shell.clearAlias = function(command)
	aliases[command] = nil
end

shell.aliases = function()
	local list = {}
	for alias, command in pairs(aliases) do
		list[alias] = command
	end
	return list
end

local start = function()
	term.setBackgroundColor(colors.BLACK)
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.LIGHTBLUE)
	print(os.lunix().."\nMade by Harrison Knox 2014\nRunning on "..os.version())
	local commandHistory = {}
	while running do
		term.setBackgroundColor(colors.BLACK)
		term.setTextColor(colors.CYAN)
		local cwd = shell.dir()
		local label = os.getComputerLabel()
		if label == nil or  label == "" then
			if term.isColor() then
				label = "A"
			end
			if turtle then
				label = label.."Tur"
			else
				label = label.."Com"
			end
			label = label..os.getComputerID()
		end
		cwd = string.gsub(cwd, "^/home/"..os.user(), "~") 
		write(os.user().."@"..label..":"..cwd.."$ ")
		term.setTextColor(colors.LIME)
		local line = read(nil, commandHistory)
		if string.match(line, "%S") then
			commandHistory[#commandHistory + 1] = line
			term.setTextColor(colors.YELLOW)
			runLine(line)
		end
	end
end

if parentShell == nil then
	shell.run("/lunix/runautorun.lua")
end

local args = {...}
if #args > 0 then
	shell.run(...)
end
if parentShell == nil then
	parallel.waitForAny(
		function()
			shell.run("/lunix/runconcurrents.lua")
		end,
		start
	)
else
	start()
end