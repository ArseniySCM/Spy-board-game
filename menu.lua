
local composer = require( "composer" )
local widget = require( "widget" )
local math = require( "math" )
local globals = require( "globals" )

local scene = composer.newScene()

local buttonColor = {0.8, 0.9, 0.9}
local buttons = {'start', 'multiplayer', 'players', 'settings', 'categories', 'edit categories'}

local function openMenu(event)
	if event.target.id == 'start' then
		globals.isMultiplayer = false
		composer.gotoScene( "game" )
		return
	end
	
	if event.target.id == 'multiplayer' then
		composer.gotoScene( "multiplayer" )
		return
	end
	
	if event.target.id == 'players' then
		composer.gotoScene( "players" )
		return
	end
	
	if event.target.id == 'settings' then
		composer.gotoScene( "gameSettings" )
		return
	end
	
	if event.target.id == 'categories' then
		composer.gotoScene( "categories" )
		return
	end
	
	if event.target.id == 'edit categories' then
		composer.gotoScene( "editCategories" )
		return
	end
	
	return true
end


-- create()
function scene:create( event )

	local sceneGroup = self.view
	 
	--Background
	local background = display.newRect(sceneGroup, 
		display.contentCenterX, 
		display.contentCenterY, 
		display.safeActualContentWidth, 
		display.safeActualContentHeight)
	background:setFillColor(unpack(globals.theme.background))

	--Game title in main menu
	local gameName = display.newText({
		text = 'SPY GAME',
		x = display.contentCenterX,
		y = globals.upside + 120, 
		font = native.systemFontBold,
		fontSize = 64,
		align = 'center',
		parent = sceneGroup
	})
	gameName:setFillColor(unpack(globals.theme.primary))
	
	--Create all menu buttons
	for btn=1, #buttons do 
	
		local buttonGroup = display.newGroup()
		buttonGroup.x = display.contentCenterX
		buttonGroup.y = 150 + 100 * btn
		
		local shadow = display.newRoundedRect(buttonGroup, 0, 4, 408, 86, 15)
		shadow:setFillColor(unpack(globals.theme.shadow))
		
		--button template
		local menuButton = widget.newButton({
		x = 0, y = 0,
		width = 400, height = 80,
		
		shape = "roundedRect",
		cornerRadius = 15,
		
		label = string.upper(buttons[btn]),
		font = native.systemFontBold,
		fontSize = 24,
		id = buttons[btn],
		
		fillColor = { default=globals.theme.primary, over=globals.theme.secondary },
		labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel },
		})
		
		sceneGroup:insert(buttonGroup)
		buttonGroup:insert(menuButton)
		
		menuButton:addEventListener('tap', openMenu)
		
	end
	
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
-- -----------------------------------------------------------------------------------

return scene
