
local composer = require( "composer" )
local globals = require 'globals'
local icons = require 'icons'

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
	background:setFillColor(unpack(globals.theme.background))
	
	local upBar = display.newRect(sceneGroup, display.contentCenterX, globals.upside + 50, globals.safeWidth, 100)
	upBar:setFillColor(unpack(globals.theme.primary))
	
	local backGroup = icons.newBack(sceneGroup, globals.leftside + 50, upBar.y, 40, globals.theme.buttonLabel)
	backGroup:addEventListener('tap', function() composer.gotoScene( "menu" ) return true end)
	
	local title = display.newText(sceneGroup, 'SETTINGS', display.contentCenterX, upBar.y, native.systemFontBold, 36)
	title:setFillColor(unpack(globals.theme.buttonLabel))
	
	for a=1, 2 do
	
		local posY = 150 + 100 * a
		
		local shadow = display.newRoundedRect(sceneGroup, display.contentCenterX, posY + 4, 440, 79, 15)
		shadow:setFillColor(unpack(globals.theme.shadow))
			
		local buttonBg = display.newRoundedRect(sceneGroup, display.contentCenterX, posY, 440, 75, 15)
		buttonBg:setFillColor(unpack(globals.theme.card))
		
		texts[a] = display.newText({
			parent = sceneGroup,
			x = display.contentCenterX,
			y = posY,
			align = 'center',
			text = 'non',
			font = native.systemFont,
			fontSize = 28,
		})
		texts[a]:setFillColor(unpack(globals.theme.text))
		
		local addBtn = display.newRect(sceneGroup, display.contentCenterX + buttonBg.width / 2 - 40, posY, 60, 60)
		addBtn.isVisible = false
		addBtn.isHitTestable = true
		addBtn.id = a
		addBtn:addEventListener('tap', addF)
		icons.newPlus(sceneGroup, addBtn.x, addBtn.y, 30, globals.theme.primary)

		local minusBtn = display.newRect(sceneGroup, display.contentCenterX - buttonBg.width / 2 + 40, posY, 60, 60)
		minusBtn.isVisible = false
		minusBtn.isHitTestable = true
		minusBtn.id = a
		minusBtn:addEventListener('tap', minusF)
		icons.newMinus(sceneGroup, minusBtn.x, minusBtn.y, 30, globals.theme.accent)
	end
	
	texts[1].text = 'Spies: ' .. globals.rules.spies..' - '..#globals.rules.players .. ' players'
	texts[2].text = 'Time: ' .. globals.convertTime(globals.rules.time)
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
