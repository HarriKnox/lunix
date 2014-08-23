if fs.exists("/apis") and fs.isDir("/apis") then
	local files = fs.list("/apis")
	for index, file in ipairs(files) do
		if string.match(file, "^[^.]") and fs.isFile("/apis/"..file) then
			os.loadAPI("/apis/"..file)
		end
	end
end

if fs.exists("/autorun") and fs.isDir("/autorun") then
	local files = fs.list("/autorun")
	for index, file in ipairs(files) do
		if string.match(file, "^[^.]") and fs.isFile("/autorun/"..file) then
			shell.run("/autorun/"..file)
		end
	end
end