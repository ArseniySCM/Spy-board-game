local composer = require("composer")
local widget = require("widget")
local globals = require("globals")
local icons = require("icons")
local network = require("network")

local scene = composer.newScene()

local statusText
local codeField
local codeLabel
local isHosting = false
local currentRoomCode = ""

local function onData(data)
    if data.type == "start" then
        globals.rules.players = data.players
        globals.rules.spies = data.spies
        globals.rules.wishedWord = data.word
        globals.rules.imposters = data.imposters
        globals.isMultiplayer = true
        globals.myPlayerName = data.yourName
        composer.gotoScene("game")
    elseif data.type == "join" then
        if isHosting then
            table.insert(globals.rules.players, data.playerName)
            statusText.text = "Players (" .. #globals.rules.players .. "): " .. table.concat(globals.rules.players, ", ")
            network.send({type = "lobbyUpdate", players = globals.rules.players})
        end
    elseif data.type == "lobbyUpdate" then
        globals.rules.players = data.players
        statusText.text = "Players (" .. #globals.rules.players .. "): " .. table.concat(globals.rules.players, ", ")
    end
end

local function updateLoop()
    network.update(onData)
end

local function joinByCode()
    local code = codeField.text
    if not code or code == "" then
        statusText.text = "Please enter a code"
        return
    end
    
    statusText.text = "Searching for room " .. code .. "..."
    network.findServerByCode(code, function(ip)
        if ip then
            if network.startClient(ip) then
                network.send({type = "join", playerName = "Guest " .. math.random(100)})
                statusText.text = "Connected! Waiting for host..."
                codeField.isVisible = false
            else
                statusText.text = "Failed to connect to " .. ip
            end
        else
            statusText.text = "Room " .. code .. " not found"
        end
    end)
end

function scene:create(event)
    local sceneGroup = self.view

    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.safeActualContentWidth, display.safeActualContentHeight)
    background:setFillColor(unpack(globals.theme.background))

    local upBar = display.newRect(sceneGroup, display.contentCenterX, globals.upside + 50, globals.safeWidth, 100)
    upBar:setFillColor(unpack(globals.theme.primary))
    
    local backGroup = icons.newBack(sceneGroup, globals.leftside + 50, upBar.y, 40, globals.theme.buttonLabel)
    backGroup:addEventListener('tap', function() composer.gotoScene("menu") end)

    local title = display.newText(sceneGroup, 'MULTIPLAYER', display.contentCenterX, upBar.y, native.systemFontBold, 36)
    title:setFillColor(unpack(globals.theme.buttonLabel))
    statusText = display.newText({
        parent = sceneGroup,
        text = "Host a game or enter code to join",
        x = display.contentCenterX,
        y = 200,
        font = native.systemFont,
        fontSize = 22,
        align = "center"
    })
    statusText:setFillColor(unpack(globals.theme.text))

    local hostBtn
    local joinBtn
    local startBtn

    hostBtn = widget.newButton({
        x = display.contentCenterX, y = 320,
        width = 300, height = 70,
        shape = "roundedRect",
        cornerRadius = 15,
        label = "HOST NEW GAME",
        font = native.systemFontBold,
        fontSize = 24,
        fillColor = { default=globals.theme.primary, over=globals.theme.secondary },
        labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel },
        onRelease = function()
            if network.startServer() then
                isHosting = true
                currentRoomCode = tostring(math.random(1000, 9999))
                globals.rules.players = {"Host"}
                statusText.text = "Room Code: " .. currentRoomCode .. "\nWaiting for players..."
                
                hostBtn.isVisible = false
                joinBtn.isVisible = false
                codeField.isVisible = false
                
                -- Broadcast room code
                timer.performWithDelay(1000, function() 
                    network.broadcastPresence("Spy Room", currentRoomCode) 
                end, 0)
                
                startBtn = widget.newButton({
                    x = display.contentCenterX, y = 550,
                    width = 300, height = 80,
                    shape = "roundedRect",
                    cornerRadius = 15,
                    label = "START GAME",
                    font = native.systemFontBold,
                    fontSize = 24,
                    fillColor = { default=globals.theme.primary, over=globals.theme.secondary },
                    labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel },
                    onRelease = function()
                        if #globals.rules.players < 3 then
                            statusText.text = "Need at least 3 players!"
                            return
                        end
                        local imposters = {}
                        local p = {unpack(globals.rules.players)}
                        for i=1, globals.rules.spies do
                            local r = math.random(#p)
                            table.insert(imposters, p[r])
                            table.remove(p, r)
                        end
                        local words = {}
                        for _, cat in pairs(globals.rules.categories) do
                            if globals.rules.data[cat] then
                                for _, w in ipairs(globals.rules.data[cat]) do table.insert(words, w) end
                            end
                        end
                        local word = words[math.random(#words)] or "SECRET"
                        
                        network.send({
                            type = "start",
                            players = globals.rules.players,
                            spies = globals.rules.spies,
                            word = word,
                            imposters = imposters,
                            yourName = "Client" 
                        })
                        onData({type = "start", players = globals.rules.players, spies = globals.rules.spies, word = word, imposters = imposters, yourName = "Host"})
                    end
                })
                sceneGroup:insert(startBtn)
            end
        end
    })
    sceneGroup:insert(hostBtn)

    codeField = native.newTextField(display.contentCenterX, 420, 160, 50)
    codeField.placeholder = "CODE"
    codeField.inputType = "number"
    codeField.font = native.newFont(native.systemFontBold, 24)
    codeField.align = "center"
    sceneGroup:insert(codeField)

    joinBtn = widget.newButton({
        x = display.contentCenterX, y = 500,
        width = 300, height = 70,
        shape = "roundedRect",
        cornerRadius = 15,
        label = "JOIN WITH CODE",
        font = native.systemFontBold,
        fontSize = 24,
        fillColor = { default=globals.theme.secondary, over=globals.theme.primary },
        labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel },
        onRelease = joinByCode
    })
    sceneGroup:insert(joinBtn)
end

function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("enterFrame", updateLoop)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", updateLoop)
        network.stop()
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
