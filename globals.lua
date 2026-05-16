local M = {}

M.safeWidth =  display.safeActualContentWidth
M.safeHeight =  display.safeActualContentHeight

M.upside = display.contentCenterY - M.safeHeight / 2
M.leftside = display.contentCenterX - M.safeWidth / 2

M.rules = {
    players = {'player 1', 'player 2', 'player 3'},
    spies = 1,
    time = 30,
    categories = {'їжа', "Знаменитості", "спорт", "професії"},
	data = {}
}

function M.saveCategories(data)
    M.rules.data = {}
    local currentCategory

    for line in data:gmatch("[^\r\n]+") do
        local catName = line:match("^>%s*(.+)")
        
        if catName then
            currentCategory = catName
            M.rules.data[currentCategory] = {}
        elseif currentCategory then
            for word in line:gmatch("[^,]+") do
                local cleanWord = word:match("^%s*(.-)%s*$")
                if cleanWord and cleanWord ~= "" then
                    table.insert(M.rules.data[currentCategory], cleanWord)
                end
            end
        end
    end
end

function M.convertTime(time)
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    return string.format("%d:%02d", minutes, seconds)
end




return M