
local composer = require( "composer" )
local widget = require 'widget'
local globals = require 'globals'
local nameModule = require 'changeName'

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
			
			local shadow = display.newRoundedRect(buttonGroup, 0, y + 4, 460, 79, 10)
			shadow:setFillColor(0, 0, 0, 0.3)
			
			local buttonBg = display.newRoundedRect(buttonGroup, 0, y, 460, 75, 10)
			buttonBg:setFillColor(0.8, 0.9, 0.9)
			buttonBg.id = i
			buttonBg:addEventListener('tap', openChangeMenu)
			buttonBg:addEventListener('tap', function() return true end)
			
			buttonTexts[i] = display.newText({
				parent = buttonGroup, 
				text = globals.rules.players[i], 
				x = 0, 
				y = y, 
				width = 440, 
				height = 0, 
				font = native.systemFont, 
				fontSize = 40,
				})
			buttonTexts[i]:setFillColor(0, 0, 0)
			
			local removeIcon = display.newImage(buttonGroup, 'remove.png', buttonBg.width / 2 - 50, y)
			removeIcon.width, removeIcon.height = 50, 50
			removeIcon.id = i
			removeIcon:addEventListener('tap', removeFromList)
		end
		
		local shadow = display.newRoundedRect(buttonGroup, 0, 90 * (#globals.rules.players + 1) - 16, 460, 79, 10)
		shadow:setFillColor(0, 0, 0, 0.3)
		
		local endButtonBg = display.newRoundedRect(buttonGroup, 0, 90 * (#globals.rules.players + 1) - 20, 460, 75, 10)
		endButtonBg:setFillColor(0.6, 0.7, 0.7)
		
		local addPlayer = display.newImage(buttonGroup, 'add.png', endButtonBg.x, endButtonBg.y)
		addPlayer.width = 50
		addPlayer.height = 50
		endButtonBg:addEventListener('tap', addToList)
		
		scrollView:insert(buttonGroup)
		
end

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	
	--sceneGroup:insert(buttonGroup)
	
	scrollView = widget.newScrollView(
		{	
			width = globals.safeWidth,
			height = globals.safeHeight * 0.7 + 100,
			y = display.contentCenterY + 50,
			x = display.contentCenterX,
			backgroundColor = {0.7, 0.8, 0.8, 0.5},
			horizontalScrollDisabled = true
		}
	)

	sceneGroup:insert(scrollView)
	
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
	back:addEventListener('tap', function() composer.gotoScene( "menu" ) display.remove(buttonGroup) return true end)
	
	local title = display.newText(sceneGroup, 'PLAYERS', display.contentCenterX, upBar.y, native.systemFontBold, 40)
	title:setFillColor(0,0,0)
	
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
