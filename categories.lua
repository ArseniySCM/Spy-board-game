
local composer = require( "composer" )
local globals = require 'globals'
local widget = require 'widget'

local scene = composer.newScene()

--data block

	local scrollView
	local checkmarks = {}
	local data
	local path = system.pathForFile( "categories.txt", system.DocumentsDirectory )
	
--end
 
 
local file, errorString = io.open( path, "r" )
if file then

    data = file:read( "*a" )
    io.close( file )
end

--manage categories
local function addCategory(event)

	if table.indexOf(globals.rules.categories, event.target.id) == nil then	--if category disabled
	
		table.insert(globals.rules.categories, event.target.id)
		checkmarks[event.target.index].fill = { type="image", filename='checkmark.png'}
		
	else --if enabled
	
		table.remove(globals.rules.categories, table.indexOf(globals.rules.categories, event.target.id))
		checkmarks[event.target.index].fill = { type="image", filename='remove.png'}
		
	end
	
end

--create category buttons
local buttonGroup = display.newGroup()

local function createCategories()

		display.remove(buttonGroup)
		buttonGroup = nil
		buttonGroup = display.newGroup()
		buttonGroup.x = scrollView.width / 2
		
		local N = 0
		
		for k, _ in pairs(globals.rules.data) do
		
			N = N + 1
			local y = 90 * N - 20
			
			local shadow = display.newRoundedRect(buttonGroup, 0, y + 4, 460, 79, 10)
			shadow:setFillColor(0, 0, 0, 0.3)
			
			local buttonBg = display.newRoundedRect(buttonGroup, 0, y, 460, 75, 10)
			buttonBg:setFillColor(0.8, 0.9, 0.9)
			buttonBg.id = k
			buttonBg.index = N
			buttonBg:addEventListener('tap', addCategory)
			
			local categoryName = display.newText({
				parent = buttonGroup, 
				text = k, 
				x = - globals.safeWidth * 0.1, 
				y = y, 
				width = globals.safeWidth * 0.6, 
				height = 0, 
				font = native.systemFont, 
				fontSize = 37,
				})
		
			categoryName:setFillColor(0.2, 0.2, 0.2)
			
			
			checkmarks[N] = display.newImage(buttonGroup, 'remove.png', buttonBg.width / 2 - 50, y)
			checkmarks[N].width, checkmarks[N].height = 50, 50
			
			if table.indexOf(globals.rules.categories, k) then	--enable checking
			
				checkmarks[N].fill = { type="image", filename='checkmark.png'}
				
			else
			
				checkmarks[N].fill = { type="image", filename='remove.png'}
				
			end
		end
		
		scrollView:insert(buttonGroup)
		
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	
	scrollView = widget.newScrollView(
		{	
			width = globals.safeWidth,
			height = globals.safeHeight - 100,
			y = display.contentCenterY + 50,
			x = display.contentCenterX,
			backgroundColor = {0.7, 0.8, 0.8, 0.5},
			horizontalScrollDisabled = true,
			bottomPadding = 60
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
	
	local title = display.newText(sceneGroup, 'CATEGORIES', display.contentCenterX, upBar.y, native.systemFontBold, 40)
	title:setFillColor(0,0,0)
	
	createCategories()
	scrollView:toFront()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		createCategories()
		
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------

return scene
