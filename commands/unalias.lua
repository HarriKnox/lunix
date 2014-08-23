local args = {...}
if #args == 0 then
	print("Usage: unalias [-a] name [name ...]")
	return
end
local aliases = shell.aliases()
if args[1] == "-a" then
	for alias, command in pairs(aliases) do
		shell.clearAlias(alias)
	end
	return
end
for index, alias in ipairs(args) do
	if aliases[alias] ~= nil then
		shell.clearAlias(alias)
	else
		print(alias.." not found")
	end
end