
local composer = require( "composer" )
local widget = require 'widget'
local globals = require 'globals'
local nameModule = require 'changeName'
local icons = require 'icons'

local scene = composer.newScene()

	local buttonTexts = {}
	local scrollView

--Name operators
local function removeFromList(event)

	if #globals.rules.players > 3 then
	
		table.remove(globals.rules.players, event.target.id)
		createButtons()
		
	end
	
	return true
end


local function addToList(event)

		table.insert(globals.rules.players, 'player ' .. #globals.rules.players + 1)
		createButtons()
		
	return true
end


local function openChangeMenu(event)

	nameModule.open(event.target.id) 
	
	return true

end

--create all buttons
local buttonGroup = display.newGroup() --all buttons in this group

function createButtons()

		display.remove(buttonGroup)
		buttonGroup = nil
		buttonGroup = display.newGroup()
		buttonGroup.x = scrollView.width / 2
		
		for i=1, #globals.rules.players do --create buttons
		
			local y = 90 * i - 20
			
			local shadow = display.newRoundedRect(buttonGroup, 0, y + 4, 460, 79, 15)
			shadow:setFillColor(unpack(globals.theme.shadow))
			
			local buttonBg = display.newRoundedRect(buttonGroup, 0, y, 460, 75, 15)
			buttonBg:setFillColor(unpack(globals.theme.card))
			buttonBg.id = i
			buttonBg:addEventListener('tap', openChangeMenu)
			buttonBg:addEventListener('tap', function() return true end)
			
			buttonTexts[i] = display.newText({
				parent = buttonGroup, 
				text = globals.rules.players[i], 
				x = -20, 
				y = y, 
				width = 380, 
				height = 0, 
				font = native.systemFont, 
				fontSize = 32,
				})
			buttonTexts[i]:setFillColor(unpack(globals.theme.text))
			
			local removeIconGroup = icons.newRemove(buttonGroup, buttonBg.width / 2 - 40, y, 30, globals.theme.accent)
			removeIconGroup.id = i
			removeIconGroup:addEventListener('tap', removeFromList)
		end
		
		local shadow = display.newRoundedRect(buttonGroup, 0, 90 * (#globals.rules.players + 1) - 16, 460, 79, 15)
		shadow:setFillColor(unpack(globals.theme.shadow))
		
		local endButtonBg = display.newRoundedRect(buttonGroup, 0, 90 * (#globals.rules.players + 1) - 20, 460, 75, 15)
		endButtonBg:setFillColor(unpack(globals.theme.primary))
		
		icons.newPlus(buttonGroup, endButtonBg.x, endButtonBg.y, 40, globals.theme.buttonLabel)
		endButtonBg:addEventListener('tap', addToList)
		
		scrollView:insert(buttonGroup)
		
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
	backGroup:addEventListener('tap', function() composer.gotoScene( "menu" ) display.remove(buttonGroup) return true end)
	
	local title = display.newText(sceneGroup, 'PLAYERS', display.contentCenterX, upBar.y, native.systemFontBold, 36)
	title:setFillColor(unpack(globals.theme.buttonLabel))
	
	scrollView = widget.newScrollView(
		{	
			width = globals.safeWidth,
			height = globals.safeHeight - 150,
			y = display.contentCenterY + 60,
			x = display.contentCenterX,
			backgroundColor = {0,0,0,0},
			horizontalScrollDisabled = true
		}
	)
	sceneGroup:insert(scrollView)

	createButtons()
	scrollView:toFront()
	nameModule.create()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		createButtons()
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------

return scene
