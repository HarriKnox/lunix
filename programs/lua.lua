local running = true
local commandHistory = {}
local env = {
	exit = function()
		running = false
	end
}
setmetatable(env, {__index = getfenv()})

local getfunc = function(s)
	local forcePrint = 0
	local func, e = loadstring("return "..s, "lua")
	if func == nil then
		func, e = loadstring(s, "lua")
	else
		if loadstring(s, "lua") == nil then
			forcePrint = 1
		end
	end
	return func, e, forcePrint
end

local run = function(func, e, forcePrint)
	if func then
		term.setTextColor(colors.YELLOW)
		setfenv(func, env)
		local results = {pcall(function() return func() end)}
		if results[1] then
			local n = 1
			while (n < table.maxn(results)) or (n <= forcePrint) do
				write(tostring(results[n + 1]).."\t\t")
				n = n + 1
			end
			if n > 1 then
				print()
			end
		else
			printError(results[2])
		end
	else
		printError(e)
	end
end

term.setTextColor(colors.LIGHTBLUE)
term.setBackgroundColor(colors.BLACK)
print("Lua REPL in Lunix")

local args = {...}
if #args > 0 then
	local passed = table.concat(args, " ")
	write(">>> ")
	term.setTextColor(colors.LIME)
	write(passed.."\n")
	commandHistory[#commandHistory + 1] = passed
	run(getfunc(passed))
end

while running do
	term.setTextColor(colors.CYAN)
	term.setBackgroundColor(colors.BLACK)
	write(">>> ")
	term.setTextColor(colors.LIME)
	local s = read(nil, commandHistory)
	if string.match(s, "%S") then
		commandHistory[#commandHistory + 1] = s
		local func, e, forcePrint = getfunc(s)
		if func == nil or string.match(s, ";%s*$") then
			local input = s
			while true do
				term.setTextColor(colors.LIGHTBLUE)
				write("... ")
				term.setTextColor(colors.LIME)
				s = read(nil, commandHistory)
				if s == "" then
					break
				end
				commandHistory[#commandHistory + 1] = s
				input = input.."\n"..s
			end
			func, e, forcePrint = getfunc(input)
		end
		run(func, e, forcePrint)
	end
end
