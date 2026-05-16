local composer = require( "composer" )
local widget = require( "widget" )
local globals = require 'globals'

local scene = composer.newScene()

-- Data
local card
local cardText
local cardGroup = display.newGroup()
local variants = {}
local wishedWord
local title
local nextPlayer
local finalText -- Новий текстовий об'єкт для фінального екрана
local imposters = {}
local thisPlayer = 1
local isRoundOver = false -- Прапорець для відстеження стану гри

-- Таблиця для збереження поточних кольорів картки (RGB)
local currentCardColor = { 0.8, 0.8, 0.1 }      -- Для закритої
local currentCardColorOpen = { 0.85, 0.85, 0.15 } -- Для відкритої

-- Допоміжна функція для генерації яскравих та гарних кольорів (HSL в RGB)
local function HSLtoRGB(h, s, l)
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = l - c / 2
    local r, g, b = 0, 0, 0

    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end

    return r + m, g + m, b + m
end

-- Функція оновлення кольору картки під поточного гравця
local function updateCardColor()
    local totalPlayers = #globals.rules.players or 4
    
    -- Крок відтінку залежить від кількості гравців, щоб кольори максимально відрізнялися
    -- Додаємо зміщення (наприклад, 35), щоб перший колір не завжди був червоним
    local hue = ((thisPlayer - 1) * (360 / totalPlayers) + 35) % 360
    
    -- Насиченість 75%, Яскравість 50% для закритої картки (соковитий колір)
    local r, g, b = HSLtoRGB(hue, 0.75, 0.5)
    currentCardColor = { r, g, b }
    
    -- Трохи світліший відтінок для відкритої картки (Яскравість 58%)
    local ro, go, bo = HSLtoRGB(hue, 0.75, 0.58)
    currentCardColorOpen = { ro, go, bo }
    
    -- Одразу фарбуємо картку, якщо вона вже створена
    if card then
        card:setFillColor(unpack(currentCardColor))
    end
end

local function prepare()
    imposters = {} 
    variants = {}
    isRoundOver = false
    
    local reply = { unpack(globals.rules.players) }
    
    for i = 1, globals.rules.spies do
        if #reply > 0 then
            local rand = math.random(1, #reply)
            table.insert(imposters, reply[rand])
            table.remove(reply, rand)
        end
    end
        
    for k, v in pairs(globals.rules.categories) do
        if globals.rules.data[v] then
            for q = 1, #globals.rules.data[v] do
                table.insert(variants, globals.rules.data[v][q])
            end
        end
    end

    if #variants > 0 then
        wishedWord = variants[math.random(#variants)]
    else
        wishedWord = "NO WORDS"
    end
    
    local name = globals.rules.players[thisPlayer] or "PLAYER"
    title.text = string.upper(name)
    
    -- Оновлюємо колір для першого гравця
    updateCardColor()

    -- Повертаємо видимість елементів карти та скидаємо кнопку
    cardGroup.isVisible = true
    title.isVisible = true
    if finalText then finalText.isVisible = false end
    if nextPlayer then nextPlayer:setLabel("NEXT PLAYER") end
end

-- Перехід до наступного гравця або завершення раунду
local function toNext()
    -- Якщо раунд закінчено і натиснуто кнопку "START NEW GAME"
    if isRoundOver then
        thisPlayer = 1
        prepare()
        return true
    end

    -- Скидаємо фокус екрана та прапорець фліпу, щоб кнопка ніколи не блокувалася
    display.currentStage:setFocus(nil)
    isFlipped = false
    if flipTransition then 
        transition.cancel(flipTransition) 
        flipTransition = nil
    end
    
    -- Повертаємо картку у вихідний стан (лицьовою стороною вниз)
    cardGroup.xScale = 1
    if card then card:setFillColor(unpack(currentCardColor)) end
    if cardText then cardText.text = 'TAP FOR FLIP' end

    -- Логіка зміни гравця
    thisPlayer = thisPlayer + 1
    
    if thisPlayer > #globals.rules.players then
        -- Усі гравці подивилися свої картки!
        isRoundOver = true
        cardGroup.isVisible = false -- Ховаємо картку
        title.isVisible = false     -- Ховаємо ім'я верхнього гравця
        
        -- Обираємо випадкового гравця, який ходитиме першим
        local randomFirstPlayer = globals.rules.players[math.random(1, #globals.rules.players)]
        
        -- Показуємо текст фіналу
        finalText.text = "ALL PLAYERS KNOW ROLES!\n\nFIRST PLAYER:\n" .. string.upper(randomFirstPlayer)
        finalText.isVisible = true
        
        -- Міняємо текст на кнопці
        nextPlayer:setLabel("START NEW GAME")
    else
        local name = globals.rules.players[thisPlayer] or "PLAYER"
        title.text = string.upper(name)
        updateCardColor()
    end
end

-- Анімація фліпу картки
local flipTransition 
local isFlipped = false 

local function flip(event)
    -- Якщо раунд завершено, ігноруємо тачі до картки
    if isRoundOver then return true end

    local target = event.target 
    
    if event.phase == "began" and not isFlipped then
        isFlipped = true
        display.currentStage:setFocus(target)
        
        if flipTransition then transition.cancel(flipTransition) end
        
        flipTransition = transition.to(cardGroup, {
            time = 120, 
            xScale = 0,
            transition = easing.outQuad,
            onComplete = function()
                local currentPlayerName = globals.rules.players[thisPlayer]
                local isImposter = table.indexOf(imposters, currentPlayerName) ~= nil
                
                cardText.text = isImposter and 'YOU IMPOSTER!' or wishedWord
                
                -- Використовуємо згенерований світлий колір для відкритої картки
                card:setFillColor(unpack(currentCardColorOpen))
                
                flipTransition = transition.to(cardGroup, {
                    time = 100,
                    xScale = 1,
                    transition = easing.outQuad,
                    onComplete = function() flipTransition = nil end
                })
            end
        })
        
    elseif event.phase == "moved" and isFlipped then
        local bounds = target.contentBounds
        if  event.x < display.contentCenterX - 160 or event.x > display.contentCenterX + 160 or event.y < display.contentCenterY - 255 or event.y > display.contentCenterY + 195 then
            event.phase = "ended"
            flip(event)
        end

    elseif (event.phase == "ended" or event.phase == "cancelled") and isFlipped then
        isFlipped = false
        display.currentStage:setFocus(nil)
        
        if flipTransition then transition.cancel(flipTransition) end
        
        flipTransition = transition.to(cardGroup, {
            time = 120, 
            xScale = 0,
            transition = easing.outQuad,
            onComplete = function()
                -- Повертаємо згенерований базовий колір для закритої картки
                card:setFillColor(unpack(currentCardColor))
                cardText.text = 'TAP FOR FLIP'
                
                flipTransition = transition.to(cardGroup, {
                    time = 100,
                    xScale = 1,
                    transition = easing.outQuad,
                    onComplete = function() flipTransition = nil end
                })
            end
        })
    end

    return true
end

-- create()
function scene:create( event )
    local sceneGroup = self.view

    local background = display.newRect(sceneGroup, 
        display.contentCenterX, 
        display.contentCenterY, 
        display.safeActualContentWidth, 
        display.safeActualContentHeight)
    background:setFillColor(0.65, 0.8, 0.8)

    local upBar = display.newRect(sceneGroup, display.contentCenterX, globals.upside + 40, globals.safeWidth, 80)
    upBar:setFillColor(0.55, 0.7, 0.7)
    
    local back = display.newImage(sceneGroup, 'back-arrow.png', globals.leftside + 50, upBar.y)
    back.width, back.height = 60, 60
    back:addEventListener('tap', function() composer.gotoScene( "menu" ) end)
    
    sceneGroup:insert(cardGroup)
    cardGroup.x, cardGroup.y = display.contentCenterX, display.contentCenterY - 30
    
    card = display.newRoundedRect(cardGroup, 0, 0, 320, 450, 60)
    card:setFillColor(unpack(currentCardColor)) -- Ставимо стартовий колір
    card:addEventListener('touch', flip)
    
    local textBg = display.newRoundedRect(cardGroup, 0, 110, 300, 180, 60)
    textBg:setFillColor(1, 1, 1, 0.3)
    
    cardText = display.newText({
        parent = cardGroup, 
        text = 'TAP FOR FLIP', 
        x = 0, y = textBg.y, 
        width = textBg.width, 
        height = 0,
        font = native.systemFontBold, 
        fontSize = 35,
        align = 'center',
    })
    cardText:setFillColor(0.6, 0, 0.6)
    
    title = display.newText(cardGroup, "PLAYER", 0, -150, native.systemFontBold, 40)
    title:setFillColor(0, 0, 0)
    
    -- Створення тексту для випадкового першого гравця (ховається за замовчуванням)
    finalText = display.newText({
        parent = sceneGroup,
        text = "",
        x = display.contentCenterX,
        y = display.contentCenterY - 30,
        width = display.safeActualContentWidth - 60,
        font = native.systemFontBold,
        fontSize = 32,
        align = "center"
    })
    finalText:setFillColor(0.2, 0.2, 0.2)
    finalText.isVisible = false

    nextPlayer = widget.newButton({
        x = display.contentCenterX,
        y = display.contentCenterY + display.actualContentHeight / 2 - 100,
        label = "NEXT PLAYER",
        shape = "roundedRect",
        width = 280, height = 80,
        cornerRadius = 15,
        fontSize = 20,
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } },
        fillColor = { default={0, 0, 0}, over={0, 0, 0, 0.8} },
    })
    nextPlayer:addEventListener('tap', toNext)
    sceneGroup:insert(nextPlayer)
end

-- show()
function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then
        thisPlayer = 1 
        prepare()
    elseif ( phase == "did" ) then
        -- Код після повної появи сцени
    end
end

-- hide()
function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        -- Примусово знімаємо будь-який фокус при виході з гри в меню
        display.currentStage:setFocus(nil)
        isFlipped = false
        if flipTransition then 
            transition.cancel(flipTransition) 
            flipTransition = nil
        end
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene