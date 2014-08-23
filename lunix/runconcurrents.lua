local processes = {}
if fs.exists("/concurrent") then
	if fs.isDir("/concurrent") then
		local files = fs.list("/concurrent")
		for index, file in ipairs(files) do
			if string.match(file, "^[^.]") and fs.isFile("/concurrent/"..file) then
				processes[#processes] = function()
					pcall(shell.run, "/concurrent/"..file)
				end
			end
		end
	end
else
	fs.makeDir("/concurrent")
end
if #processes > 0 then
	parallel.waitForAll(unpack(processes))
end
while true do
	os.pullEventRaw()
end