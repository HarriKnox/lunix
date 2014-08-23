os.run({}, "/lunix/dorewrites.lua")

if fs.exists("/lunix/.last_user.txt") then
	local fr = fs.open("/lunix/.last_user.txt", "r")
	local user = "guest"
	if fr then
		user = fr.readAll()
		fr.close()
	end
	os.setUser(user)
else
	os.setUser("guest")
end

os.run({}, "/lunix/shell.lua")

--shell.exit()