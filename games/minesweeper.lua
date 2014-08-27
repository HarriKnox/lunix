if not term.isColor() then
    error("Must be played on an advanced computer/monitor/turtle")
end

generate = function(mouseX, mouseY)
    if minePercent then
        minesAmount = math.floor(screenSize[1] * screenSize[2] * minePercent / 100)
    else
        minesAmount = math.floor(math.random(screenSize[1] * screenSize[2] * 0.1, screenSize[1] * screenSize[2] * 0.2))
    end
    local count = 0
    repeat
        x = math.random(1, screenSize[1])
        y = math.random(1, screenSize[2])
        if not Spaces[x][y].mine and math.sqrt(((mouseX - x) ^ 2) + ((mouseY - y) ^ 2)) > 2 then
            Spaces[x][y].mine = true
            count = count + 1
        end
    until count == minesAmount

    for x = 1, screenSize[1] do
        for y = 1, screenSize[2] do
            if not Spaces[x][y].mine then
                local count = 0
                for dX = -1, 1 do
                    for dY = -1, 1 do
                        if x + dX >= 1 and x + dX <= screenSize[1] then
                            if y + dY >= 1 and y + dY <= screenSize[2] then
                                if Spaces[x + dX][y + dY].mine then
                                    count = count + 1
                                end
                            end
                        end
                    end
                end
                Spaces[x][y].number = count
            end
        end
    end
end

show = function(x, y)
    Spaces[x][y].revealed = true
    if Spaces[x][y].mine then
        kill()
    elseif Spaces[x][y].number == 0 then
        local poses = {{x = x, y = y, dX = -1, dY = -1}}
        repeat
            local sel = poses[#poses]
            if sel.x + sel.dX >= 1 and sel.x + sel.dX <= screenSize[1] and sel.y + sel.dY >= 1 and sel.y + sel.dY <= screenSize[2] and Spaces[sel.x + sel.dX][sel.y + sel.dY].flag == 0 and not Spaces[sel.x + sel.dX][sel.y + sel.dY].revealed then
                Spaces[sel.x + sel.dX][sel.y + sel.dY].revealed = true
                if Spaces[sel.x + sel.dX][sel.y + sel.dY].number == 0 then
                    table.insert(poses, {x = sel.x + sel.dX, y = sel.y + sel.dY, dX = -1, dY = -1})
                end
            else
                sel.dX = sel.dX + 1
                if sel.dX == 2 then
                    sel.dX = -1
                    sel.dY = sel.dY + 1
                    if sel.dY == 2 then
                        table.remove(poses)
                    end
                end
            end
        until #poses == 0
    end
end

showAround = function(x, y)
    Spaces[x][y].reveal = true
    if Spaces[x][y].mine then
        kill()
    else
        for dX = -1, 1 do
            for dY = -1, 1 do
                if x + dX >= 1 and x + dX <= screenSize[1] and y + dY >= 1 and y + dY <= screenSize[2] and not Spaces[x + dX][y + dY].revealed and Spaces[x + dX][y + dY].flag == 0 then
                    show(x + dX, y + dY)
                end
            end
        end
    end
end

nextFlag = function(status)
    if status == 2 then
        return 0
    end
    return status + 1
end

draw = function()
    for y = 1, screenSize[2] do
        for x = 1, screenSize[1] do
            term.setCursorPos(x, y)
            if not Spaces[x][y].revealed then
                if Spaces[x][y].flag == 0 then
                    term.setBackgroundColor(colors.lightGray)
                    term.setTextColor(colors.gray)
                    term.write("-")
                elseif Spaces[x][y].flag == 1 then
                    term.setBackgroundColor(colors.cyan)
                    term.setTextColor(colors.blue)
                    term.write("F")
                elseif Spaces[x][y].flag == 2 then
                    term.setBackgroundColor(colors.magenta)
                    term.setTextColor(colors.purple)
                    term.write("?")
                end
            elseif not Spaces[x][y].mine then
                term.setBackgroundColor(colors.black)
                if Spaces[x][y].number == 0 then
                    term.write(" ")
                else
                    term.setTextColor(newColors[Spaces[x][y].number])
                    term.write(tonumber(Spaces[x][y].number))
                end
            end
        end
    end
end

reset = function()
    Spaces = {}
    for x = 1, screenSize[1] do
        Spaces[x] = {}
        for y = 1, screenSize[2] do
            Spaces[x][y] = {flag = 0, revealed = false, mine = false, number = 0}
        end
    end
end

kill = function()
    running = false
    for x = 1, screenSize[1] do
        for y = 1, screenSize[2] do
            if Spaces[x][y].mine then
                term.setCursorPos(x, y)
                term.setBackgroundColor(colors.red)
                term.setTextColor(colors.black)
                term.write("X")
            end
        end
    end
    repeat
        event = {os.pullEvent()}
    until (event[1] == "mouse_click" and not monitor) or event[1] == "monitor_touch" or event[1] == "monitor_resize" or event[1] == "char"
    if event[1] == "char" and event[2] == "q" then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        error()
    end
    term.setBackgroundColor(colors.black)
end

win = function()
    running = false
    for x = 1, screenSize[1] do
        for y = 1, screenSize[2] do
            if Spaces[x][y].mine then
                term.setCursorPos(x, y)
                term.setBackgroundColor(colors.green)
                term.setTextColor(colors.black)
                term.write("X")
            end
        end
    end
    repeat
        event = {os.pullEvent()}
    until (event[1] == "mouse_click" and not monitor) or event[1] == "monitor_touch" or event[1] == "monitor_resize" or event[1] == "char"
    if event[1] == "char" and event[2] == "q" then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1, 1)
        error()
    end
    term.setBackgroundColor(colors.black)
end

allDone = function()
    local flagMine = 0
    local nonMine = 0
    for x = 1, screenSize[1] do
        for y = 1, screenSize[2] do
            if Spaces[x][y].mine and Spaces[x][y].flag == 1 and not Spaces[x][y].revealed then
                flagMine = flagMine + 1
            elseif not Spaces[x][y].mine and Spaces[x][y].flag == 0 and Spaces[x][y].revealed then
                nonMine = nonMine + 1
            end
        end
    end
    return flagMine == minesAmount or nonMine == ((screenSize[1] * screenSize[2]) - minesAmount)
end

gameLoop = function()
    while running do
        draw()
        local event = {}
        repeat
            event = {os.pullEvent()}
        until (event[1] == "mouse_click" and not monitor) or event[1] == "char" or event[1] == "monitor_touch" or event[1] == "monitor_resize"
        if event[1] == "mouse_click" or event[1] == "monitor_touch" then
            if newGame then
                if event[1] == "monitor_touch" or event[2] == 1 or event[2] == 3 then
                    generate(event[3], event[4])
                end
                newGame = false
                monitor = event[1] == "monitor_touch"
            end
            if event[1] == "mouse_click" and not monitor then
                clickFuncs[event[2]](event[3], event[4])
            elseif event[1] == "monitor_touch" then
                show(event[3], event[4])
            end
        elseif event[1] == "char" and event[2] == "q" then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1, 1)
            error()
        elseif event[1] == "monitor_resize" then
            running = false
        end
        if allDone() then
            win()
        end
    end
end

if ... then
    minePercent = tonumber(...)
else
    minePercent = nil
end
minesAmount = 0
term.setCursorBlink(false)
newColors = {}
monitor = false
for i = 1, 8 do
    newColors[i] = 2 ^ (i - 1)
end
clickFuncs = {
    show,
    function(x, y)
        if not Spaces[x][y].revealed then
            Spaces[x][y].flag = nextFlag(Spaces[x][y].flag)
        end
    end,
    showAround
}
while true do
    screenSize = {term.getSize()}
    newGame = true
    running = true
    reset()
    gameLoop()
end
