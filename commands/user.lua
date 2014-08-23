local printUsage = function()
	print("Usage:")
	print("user list")
	print("user set <name>")
	print("user add <name>")
	print("user del <name>")
	print("user rename <name> <new_name>")
end

local setUsers = function(userlist)
	if #userlist == 0 then
		userlist = {"guest"}
	end
	f_ul = fs.open("/lunix/.user_list.txt", "w")
	f_ul.write(table.concat(userlist, "\n"))
	f_ul.close()
end

local getUsers = function()
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
		setUsers(userlist)
	end
	return userlist
end

local getName = function(name)
	return string.gsub(name, "[^%w_]", "")
end

local args = {...}
if #args == 0 or #args > 3 then
	printUsage()
	return
end
if args[1] == "list" then
	local userlist = getUsers()
	table.sort(userlist)
	textutils.pagedTabulate(userlist)
	return
end

if #args <= 1 then
	printUsage()
	return
end
local name = getName(args[2])
if args[1] == "set" then
	if name ~= "" then
		if intable(name, getUsers()) then
			os.setUser(name)
			if os.user() == name then
				if not fs.exists("~") then
					fs.makeDir("~")
				end
				shell.setDir("~")
				print("User changed to "..name)
			else
				printError("Unknown issue when changing user to "..name)
			end
		else
			printError("User "..name.." doesn't exist")
		end
	else
		printError("Unusable username: "..args[2])
	end
	return
elseif args[1] == "add" then
	if name ~= "" then
		local users = getUsers()
		if not intable(name, users) then
			users[#users + 1] = name
			setUsers(users)
			if not fs.exists("/home/"..name) then
				fs.makeDir("/home/"..name)
			end
			print("Username "..name.." added")
		else
			printError("User "..name.." already exists")
		end
	else
		printError("Unusable username: "..args[2])
	end
	return
elseif args[1] == "del" then
	if name ~= "" then
		local users = getUsers()
		if intable(name, users) then
			for index, username in ipairs(users) do
				if username == name then
					table.remove(users, index)
					break
				end
			end
			setUsers(users)
			if os.user() == name then
				os.setUser(users[1])
				shell.setDir("~")
			end
			print("User "..name.." deleted.")
			print(name.."'s files will remain on this computer")
			--[[print("Would you like to delete their personal files? (this cannot be undone)")
			write("Y/N: ")
			local event
			repeat
				event = {os.pullEvent("char")}
			until event[1] == "char" and intable(event[2], {"y", "Y", "n", "N"})
			print(event[2])
			if intable(event[2], {"y", "Y"}) then
				fs.]]
		else
			printError("User "..name.." doesn't exist")
		end
	else
		printError("User "..args[2].." doesn't exist")
	end
	return
end

if #args <= 2 then
	printUsage()
	return
end
if args[1] == "rename" then
	if name ~= "" then
		local otherName = getName(args[3])
		if otherName ~= "" then
			local users = getUsers()
			if intable(name, users) then
				if not intable(otherName, users) then
					for index, username in ipairs(users) do
						if username == name then
							users[index] = otherName
							break
						end
					end
					setUsers(users)
					if os.user() == name then
						os.setUser(otherName)
						shell.setDir("~")
					end
					print("User "..name.." renamed to "..otherName)
					if not fs.exists("/home/"..otherName) then
						if fs.exists("/home/"..name) then
							fs.move("/home/"..name, "/home/"..otherName)
						else
							fs.makeDir("/home/"..otherName)
						end
					else
						printError("Home folder for user "..otherName.." already exists. Not moving directory over.")
					end
				else
					printError("User "..otherName.." already exists")
				end
			else
				printError("User "..name.." doesn't exist")
			end
		else
			printError("Unusable username: "..args[3])
		end
	else
		printError("User "..args[2].." doesn't exist")
	end
	return
else
	printUsage()
	return
end