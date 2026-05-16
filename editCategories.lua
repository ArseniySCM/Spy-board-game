
local composer = require( "composer" )
local globals = require 'globals'

local scene = composer.newScene()

	--data
	local data
	local path = system.pathForFile( "categories.txt", system.DocumentsDirectory )
	local textBox
 
--import data
local file, errorString = io.open( path, "r" )
if file then

    data = file:read( "*a" )
    io.close( file )
end
 
file = nil


local function backAndSave()
	composer.gotoScene( "menu" )

	local file, errorString = io.open( path, "w" )
	 
	if file then

		file:write( textBox.text )
		io.close( file )
	end
	
	globals.saveCategories(textBox.text)

file = nil
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
	back:addEventListener('tap', backAndSave)
	
	local title = display.newText({
		parent = sceneGroup, 
		text = 'EDIT CATEGORIES\n(Back for save)', 
		x = display.contentCenterX, 
		y = upBar.y, 
		font = native.systemFontBold, 
		fontSize = 32,
		align = 'center'
	})
	title:setFillColor(0,0,0)
	
	
	textBox = native.newTextBox(
		display.contentCenterX,
		display.contentCenterY + 55,
		globals.safeWidth,
		globals.safeHeight - 130
	)
	
	sceneGroup:insert(textBox)
	
	textBox.isEditable = true
	textBox.size = 22
	textBox.text = data
end



-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		textBox.isVisible = true

	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then

		textBox.isVisible = false

	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
