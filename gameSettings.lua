
local composer = require( "composer" )
local globals = require 'globals'

local scene = composer.newScene()

local texts = {}

--Operators
local function minusF(event)

	local id = event.target.id
	
	if id == 1 and globals.rules.spies > 0 then --minus spies
	
		globals.rules.spies = globals.rules.spies - 1
		texts[1].text = 'Spies: ' .. globals.rules.spies .. ' - ' .. #globals.rules.players .. ' players'
	elseif id == 2 and globals.rules.time > 0 then --minus time
	
		globals.rules.time = globals.rules.time - 30
		texts[2].text = 'Time: ' .. globals.convertTime(globals.rules.time)
	end
end

local function addF(event)

	local id = event.target.id
	
	if id == 1 and globals.rules.spies <= #globals.rules.players - 2 then --add spies
	
		globals.rules.spies = globals.rules.spies + 1
		texts[1].text = 'Spies: ' .. globals.rules.spies .. ' - ' .. #globals.rules.players .. ' players'
		
	elseif id == 2 then --add time
	
		globals.rules.time = globals.rules.time + 30
		texts[2].text = 'Time: ' .. globals.convertTime(globals.rules.time)
		
	end
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
	
	local upBar = display.newRect(sceneGroup, display.contentCenterX, globals.upside + 50, globals.safeWidth, 100)
	upBar:setFillColor(0.55, 0.7, 0.7)
	
	local back = display.newImage(sceneGroup, 'back-arrow.png', globals.leftside + 50, upBar.y)
	back.width, back.height = 60, 60
	back:addEventListener('tap', function() composer.gotoScene( "menu" ) return true end)
	
	local title = display.newText(sceneGroup, 'SETTINGS', display.contentCenterX, upBar.y, native.systemFontBold, 40)
	title:setFillColor(0,0,0)
	
	for a=1, 2 do
	
		local posY = 70 + 90 * a
		
		local shadow = display.newRoundedRect(sceneGroup, display.contentCenterX, posY + 4, 440, 79, 10)
		shadow:setFillColor(0, 0, 0, 0.3)
			
		local buttonBg = display.newRoundedRect(sceneGroup, display.contentCenterX, posY, 440, 75, 10)
		buttonBg:setFillColor(0.8, 0.9, 0.9)
		
		texts[a] = display.newText({
			parent = sceneGroup,
			x = display.contentCenterX,
			y = posY,
			align = 'center',
			text = 'non',
			font = native.systemFont,
			fontSize = 28,
		})
		texts[a]:setFillColor(0, 0, 0)
		
		local add = display.newImage(sceneGroup, 'add.png', display.contentCenterX + buttonBg.width / 2 - 30, posY)
		add.width, add.height = 40, 40
		add.id = a
		add:addEventListener('tap', addF)

		local minus = display.newImage(sceneGroup, 'minus.png', display.contentCenterX - buttonBg.width / 2 + 30, posY)
		minus.width, minus.height = 40, 40
		minus.id = a
		minus:addEventListener('tap', minusF)
	end
	
	texts[1].text = 'Spies: ' .. globals.rules.spies..' - '..#globals.rules.players .. ' players'
	texts[2].text = 'Time: ' .. globals.convertTime(globals.rules.time)
	
	local text = display.newText(sceneGroup,'Таймер не працює :(', display.contentCenterX, display.contentCenterY, native.systemFont, 30)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		texts[1].text = 'Spies: ' .. globals.rules.spies..' - '..#globals.rules.players .. ' players'
		texts[2].text = 'Time: ' .. globals.convertTime(globals.rules.time)
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------

return scene
