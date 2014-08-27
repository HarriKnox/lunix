local drawTitle = function()
	local coords = {
		[2]={[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[3]={[1]=2048,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[4]={[1]=2048,[2]=2048,[3]=2048,[4]=2048,[5]=2048,[6]=2048,[7]=2048,[8]=512},
		[5]={[8]=512,[7]=2048},
		[6]={[8]=512,[7]=2048},
		[7]={[7]=2048,[4]=8,[5]=8,[6]=8},
		[8]={[2]=8,[3]=8,[4]=8,[5]=8,[6]=8,[7]=8,[8]=8},
		[9]={[1]=2048,[2]=8,[3]=2048,[4]=2048,[5]=2048,[6]=8,[7]=8,[8]=8},
		[10]={[1]=8,[7]=8,[8]=8,[9]=8,[5]=2048,[6]=2048},
		[11]={[7]=2048,[8]=8,[9]=8,[6]=2048},
		[12]={[8]=8,[9]=8,[7]=2048},
		[13]={[8]=8,[7]=2048},
		[14]={[8]=8,[7]=8},
		[15]={[6]=8,[7]=2048},
		[16]={[5]=2048},
		[17]={[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[18]={[1]=2048,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[19]={[1]=2048,[2]=2048,[3]=2048,[4]=512,[5]=512,[6]=2048,[7]=2048},
		[20]={[3]=2048,[4]=2048,[5]=512,[6]=512},
		[21]={[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[22]={[1]=2048,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[23]={[1]=2048,[2]=2048,[3]=2048,[4]=2048,[5]=2048,[6]=2048,[7]=2048},
		[24]={[8]=512,[2]=512},
		[25]={[1]=2048,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[26]={[1]=2048,[2]=512,[3]=512,[4]=512,[5]=512,[6]=512,[7]=512,[8]=512},
		[27]={[1]=2048,[2]=512,[3]=2048,[4]=2048,[5]=2048,[6]=2048,[7]=2048,[8]=512},
		[28]={[1]=2048,[7]=2048},
		[29]={[7]=512,[8]=512,[2]=512,[3]=512},
		[30]={[1]=2048,[2]=512,[3]=512,[4]=512,[8]=512,[6]=512,[7]=512},
		[31]={[1]=2048,[2]=2048,[3]=2048,[4]=512,[5]=512,[6]=512,[7]=2048},
		[32]={[3]=2048,[4]=512,[5]=512,[6]=512},
		[33]={[2]=512,[3]=512,[4]=512,[5]=2048,[6]=512,[7]=512,[8]=512},
		[34]={[1]=2048,[2]=512,[3]=512,[5]=2048,[6]=2048,[7]=512,[8]=512},
		[35]={[1]=2048,[2]=2048,[6]=2048,[7]=2048}
	}
	local setBC = function(color, default)
		if default == nil or (default ~= colors.white and default ~= colors.black) then
			default = colors.black
		end
		term.setBackgroundColor(default)
		if term.isColor() then
			term.setBackgroundColor(color)
		end
	end
	local setTC = function(color, default)
		if default == nil or (default ~= colors.white and default ~= colors.black) then
			default = colors.white
		end
		term.setTextColor(default)
		if term.isColor() and color ~= nil then
			term.setTextColor(color)
		end
	end
	setBC(colors.black)
	term.clear()
	for x, row in pairs(coords) do
		for y, color in pairs(row) do
			term.setCursorPos(x, y)
			setBC(color, color == colors.blue and colors.black or colors.white)
			term.write(" ")
		end
	end
	setBC(colors.black)
	setTC(colors.lightBlue)
	term.setCursorPos(15, 9)
	term.write("universal installer (not for 1.6)")
	term.setCursorPos(37, 7)
	term.write("Lunix")
	setTC(colors.lime)
	term.setCursorPos(37, 2)
	term.write("Made by")
	term.setCursorPos(37, 5)
	term.write("Thank you for")
	term.setCursorPos(37, 6)
	term.write("installing")
	term.setCursorPos(42, 7)
	term.write(". Please")
	term.setCursorPos(37, 8)
	term.write("wait a moment.")
	setTC(colors.magenta)
	term.setCursorPos(38, 3)
	term.write("Harrison Knox")
	term.setCursorPos(1, 10)
end

local logged = {}
local screenx, screeny = term.getSize()
local maxlen, maxheight = screenx - 2, screeny - 10 - 1

local convert = function(line)
	local rep = function(str, num)
		return string.rep(str, (num >= 0 and num or 0))
	end
	local indent = (string.find(line or "", "%S") or 1) - 1
	line = string.sub(line, indent + 1)
	if #line > maxlen - indent then
		line = string.sub(line, 1, (maxlen - indent - 3) / 2).."..."..string.sub(line, (maxlen - indent - 2) / -2)
	end
	return rep(" ", indent)..line..rep(" ", maxlen - indent - #line)
end

local output = function()
	term.setTextColor(colors.white)
	for row = 1, math.min(maxheight, #logged) do
		term.setCursorPos(2, row + 10)
		write(convert(logged[row]))
	end
end

local add = function(line)
	if line ~= nil then
		local logger = fs.open("LunixInstaller.log", "a")
		logger.writeLine(line)
		logger.close()
		if #logged < maxheight then
			logged[#logged + 1] = line
			output()
			return
		end
	end
	local canpush = function(line, index)
		local indent = function(line)
			return (string.find(line or "", "%S") or 1) - 1
		end
		if indent(line) <= indent(logged[index]) then
			return true
		end
		local offset = 0
		while offset < index - 1 do
			if indent(logged[index - offset]) <= indent(logged[index - offset - 1]) then
				return true
			end
			offset = offset + 1
		end
		return false
	end
	local stored = line
	if stored == nil then
		stored = table.remove(logged)
	end
	local index = #logged
	while index >= 1 do
		if canpush(stored, index) then
			local temp = logged[index]
			logged[index] = stored
			stored = temp
		end
		index = index - 1
	end
	output()
end

local getNextFile = function(name)
	local num = 0
	repeat
		num = num + 1
	until not fs.exists(name.." ("..num..")")
	return name.." ("..num..")"
end

local download = function(path, url)
	if http == nil then
		return false, "HTTP not enabled"
	end
	local ok, site = pcall(http.get, url)
	if not ok then
		return false, "Could not download "..path
	end
	local file = fs.open(path, "w")
	local line = site.readLine()
	repeat
		file.writeLine(line)
		line = site.readLine()
	until line == nil
	file.close()
	site.close()
	return true, "Downloaded "..path
end

local pop = function(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			table.remove(tab, index)
			break
		end
	end
end

local writePointers = function(list, directory)
	if #list > 0 then
		add(" Writing default pointer files")
		for index, file in ipairs(list) do
			local path = "/"..directory.."/"..string.match(file, "[^/]+$")..".lua"
			if fs.exists(path) then
				add("  "..path.." exists")
				add("   Not overwriting")
			else
				local cmd = fs.open(path, "w")
				cmd.write("shell.run(\"/rom/programs/"..file.."\", ...)")
				cmd.close()
				add("  Wrote "..path.."")
			end
		end
	end
end

local downloadFiles = function(list, customList, directory)
	if #customList > 0 then
		add(" Downloading custom "..string.match(directory, "^(.-)s?$").." files")
		for index, file in ipairs(customList) do
			local path = "/"..directory.."/"..string.match(file, "[^/]+$")..".lua"
			add("  Downloading "..path)
			if fs.exists(path) then
				local test = fs.open(path, "r")
				if test.readAll() == "shell.run(\"/rom/programs/"..file.."\", ...)" then
					test.close()
					fs.delete(path)
					add("   "..path.." exists")
					add("    Detecting it to be a default pointer file")
					add("    Overwriting "..path.."")
				else
					test.close()
					add("   "..path.." exists")
					add("    Renaming to "..getNextFile(path.."-backup"))
					fs.move(path, getNextFile(path.."-backup"))
				end
			end
			local ok, msg = download(path, "https://"..fs.combine("raw.githubusercontent.com/HarriKnox/lunix/master", path))
			add("   "..msg)
			if ok then
				pop(list, file)
			end
		end
	end
	writePointers(list, directory)
end

local abort = function()
	local x, y = term.getCursorPos()
	term.setCursorPos(1, 19)
	error()
end

drawTitle()
fs.open("LunixInstaller.log", "w").close()
if string.match(os.version(), "%d+%.*%d*") == "1.6" then
	add("This installer currently works with only")
	add(" CraftOS 1.5 and doesn't yet support 1.6 due to")
	add(" the large number of changes between the")
	add(" versions, and the fact that I still play 1.5")
	add(" in FTB. I am working on patching the installer.")
	add(" Please wait patiently for an updated release.")
	abort()
end

add("Checking Internet connectivity")
add(" Checking HTTP Module")
if http == nil then
	add("  HTTP Module is not activated")
	add("  It must be activated to download the source")
	add("  Aborting installation")
	abort()
end
add("  HTTP Module activated")

add(" Checking GitHub connection")
local gitTest = http.get("https://github.com/HarriKnox/lunix")
if gitTest == nil then
	add("  GitHub isn't accessible")
	add("  Either it's not on the whitelist (likely),")
	add("  the project was moved/removed (unlikely),")
	add("  or the site is down (very unlikely).")
	add("  Aborting installation")
	abort()
end
gitTest.close()
add("  GitHub is accessible")

add("Setting up directories")
for index, dir in ipairs({"apis", "autorun", "commands", "concurrent", "games", "home", "lunix", "programs"}) do
	add(" Creating /"..dir)
	if fs.exists(dir) then
		if fs.isDir(dir) then
			add("  /"..dir.." exists and is a directory")
			add("   Not overwriting")
		else
			add("  /"..dir.." exists and is a file")
			add("   Renaming to /"..getNextFile(dir.."-backup"))
			fs.move(dir, getNextFile(dir.."-backup"))
			fs.makeDir(dir)
			add("   /"..dir.." added")
		end
	else
		fs.makeDir(dir)
		add("  /"..dir.." added")
	end
end

add("Downloading files")
local commands = {"alias", "apis", "cd", "clear", "copy", "delete", "eject", "exit", "id", "label", "list", "mkdir", "monitor", "move", "programs", "reboot", "rename", "shutdown", "type"}
local customCommands = {"alias", "commands", "games", "label", "programs", "reboot", "shutdown", "unalias", "user"}
downloadFiles(commands, customCommands, "commands")

local programs = {"dj", "drive", "edit", "gps", "help", "lua", "redprobe", "redpulse", "redset", "shell", "time", "color/paint", "computer/hello", "http/pastebin"}
local customPrograms = {"lua"}
downloadFiles(programs, customPrograms, "programs")

local games = {"computer/adventure", "computer/worm"}
local customGames = {"minesweeper", "lightsout"}
downloadFiles(games, customGames, "games")

add(" Downloading APIs")
local apis = {
	["/apis/json"] = "",
	["/apis/complex"] = "",
	["/apis/matrix"] = ""
}
for path, url in pairs(apis) do
	add("  Downloading "..path)
	local ok, msg = download(path, url)
	add("   "..msg)
end

local system = {"dorewrites", "lunix", "runautorun", "runconcurrents", "shell"}
downloadFiles({}, system, "lunix")

add("Assessing User data")
local userlist = {}
if fs.exists("/lunix/.user_list.txt") then
	local f_ul = fs.open("/lunix/.user_list.txt", "r")
	local users = f_ul.readAll()
	f_ul.close()
	for name in string.gmatch(users, "[%w_]+") do
		userlist[#userlist + 1] = name
	end
end
local newname
if #userlist == 0 then
	add(" What username would you like to use?")
	add("  (Leave blank to set it to \"guest\")")
	add("  (Only letters, numbers, and underscore)")
	add(" ")
	local x, y = term.getCursorPos()
	term.setCursorPos(4, y)
	newname = string.gsub(read(), "[^%w_]", "")
	if newname == "" then
		newname = "guest"
	end
	table.remove(logged)
	add("   "..newname)
	local f_ul = fs.open("/lunix/.user_list.txt", "w")
	f_ul.write(newname)
	f_ul.close()
else
	add(" Found "..#userlist.." user"..(#userlist == 1 and "" or "s"))
	newname = userlist[1]
	if fs.exists("/lunix/.last_user.txt") then
		local f_lu = fs.open("/lunix/.last_user.txt", "r")
		local last = f_lu.readLine()
		f_lu.close()
		for index, name in ipairs(userlist) do
			if name == last then
				newname = name
				break
			end
		end
	end
end
add("  Setting username to "..newname)
local home = "/home/"..newname
if not fs.exists(home) then
	fs.makeDir(home)
	add("   Creating home folder for "..newname)
else
	if not fs.isDir(home) then
		add("  Backing up file "..home)
		add("   Renaming to "..getNextFile(home.."-backup"))
		fs.move(home, getNextFile(home.."-backup"))
		add("  Creating home folder for "..newname)
		fs.makeDir(home)
	end
end
local f_lu = fs.open("/lunix/.last_user.txt", "w")
f_lu.write(newname)
f_lu.close()

add("Writing startup file")
if fs.exists("/startup") then
	add(" Backing up current startup file")
	add("  Renaming it to "..getNextFile("/startup-backup"))
	fs.move("/startup", getNextFile("/startup-backup"))
end
local f_start = fs.open("/startup", "w")
f_start.write("shell.run(\"/lunix/lunix.lua\")")
f_start.close()
add(" Startup file written")
add("Lunix installation complete")
add(" Press Any key to reboot")
term.setCursorBlink(true)
local event = {os.pullEvent("key")}
if false then
	term.setCursorBlink(false)
	add(" I said press Any key,")
	add("  not press "..keys.getName(event[2]).." key")
	add(" Let's try this again.")
	add("  Press Any key to reboot")
	term.setCursorBlink(true)
	event = {os.pullEvent("key")}
	term.setCursorBlink(false)
	add(" You're not getting this are you.")
	add("  I said \"Any\", not "..keys.getName(event[2]))
	add(" You know what? This should be easy")
	add("  Just press A key on your keyboard")
	term.setCursorBlink(true)
	event = {os.pullEvent("key")}
	term.setCursorBlink(false)
	if event[2] ~= keys["a"] then
		add(" I told you to press the letter A")
		add("  not "..keys.getName(event[2]))
		add(" Whatever")
		add(" I'm just gonna reboot in 5 seconds")
		add("  Press Some key on your keyboard to make it immediate")
		local t = os.startTimer(5)
		repeat
			event = os.pullEvent()
		until (event[1] == "timer" and event[2] == t) or event[1] == "key"
		if event[1] == "key" then
			add("   Some key is not "..keys.getName(event[2]).." key")
			repeat
				event = os.pullEvent()
			until (event[1] == "timer" and event[2] == t) or event[1] == "key"
		end
	end
end
os.reboot()