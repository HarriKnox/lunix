local args = table.concat({...}, " ")
if #args == 0 then
	local list = {}
	for alias, command in pairs(shell.aliases()) do
		list[#list + 1] = alias.."="..command
	end
	table.sort(list)
	local x, y = term.getSize()
	textutils.pagedPrint(table.concat(list, "\n"), y - 3)
	return
end

local assignments = {}
for definition in string.gmatch(args, "%w+=%w+") do
	assignments[#assignments + 1] = definition
end
args = string.gsub(args, "%w+=%w+", "")
if #assignments > 0 then
	for index, line in ipairs(assignments) do
		shell.setAlias(string.match(line, "(%w+)="), string.match(line, "=(%w+)"))
	end
end

local displays = {}
for show in string.gmatch(args, "[^%s]+") do
	displays[#displays + 1] = show
end
if #displays > 0 then
	local list = {}
	local aliases = shell.aliases()
	for index, line in ipairs(displays) do
		if aliases[line] ~= nil then
			list[#list + 1] = line.."="..aliases[line]
		else
			list[#list + 1] = line.." not found"
		end
	end
	local x, y = term.getSize()
	textutils.pagedPrint(table.concat(list, "\n"), y - 3)
end