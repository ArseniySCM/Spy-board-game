local composer = require( "composer" )
local globals = require 'globals'
local widget = require 'widget'
local icons = require 'icons'

local scene = composer.newScene()

--data block

	local scrollView
	local checkmarks = {}
	local data
	local path = system.pathForFile( "categories.txt", system.DocumentsDirectory )
	
--manage categories
local function addCategory(event)
    local index = event.target.index
    local id = event.target.id
    
	if table.indexOf(globals.rules.categories, id) == nil then	--if category disabled
		table.insert(globals.rules.categories, id)
	else --if enabled
		table.remove(globals.rules.categories, table.indexOf(globals.rules.categories, id))
	end
    
    -- Update icon
    display.remove(checkmarks[index])
    if table.indexOf(globals.rules.categories, id) then
        checkmarks[index] = icons.newCheck(event.target.parent, event.target.x + 180, event.target.y, 30, globals.theme.primary)
    else
        checkmarks[index] = icons.newRemove(event.target.parent, event.target.x + 180, event.target.y, 30, globals.theme.accent)
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
			
			local shadow = display.newRoundedRect(buttonGroup, 0, y + 4, 460, 79, 15)
			shadow:setFillColor(unpack(globals.theme.shadow))
			
			local buttonBg = display.newRoundedRect(buttonGroup, 0, y, 460, 75, 15)
			buttonBg:setFillColor(unpack(globals.theme.card))
			buttonBg.id = k
			buttonBg.index = N
			buttonBg:addEventListener('tap', addCategory)
			
			local categoryName = display.newText({
				parent = buttonGroup, 
				text = k, 
				x = -20, 
				y = y, 
				width = 320, 
				height = 0, 
				font = native.systemFont, 
				fontSize = 32,
				})
		
			categoryName:setFillColor(unpack(globals.theme.text))
			
			if table.indexOf(globals.rules.categories, k) then	--enable checking
				checkmarks[N] = icons.newCheck(buttonGroup, 180, y, 30, globals.theme.primary)
			else
				checkmarks[N] = icons.newRemove(buttonGroup, 180, y, 30, globals.theme.accent)
			end
		end
		
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
	
	local title = display.newText(sceneGroup, 'CATEGORIES', display.contentCenterX, upBar.y, native.systemFontBold, 36)
	title:setFillColor(unpack(globals.theme.buttonLabel))
	
	scrollView = widget.newScrollView(
		{	
			width = globals.safeWidth,
			height = globals.safeHeight - 150,
			y = display.contentCenterY + 60,
			x = display.contentCenterX,
			backgroundColor = {0,0,0,0},
			horizontalScrollDisabled = true,
			bottomPadding = 60
		}
	)
	sceneGroup:insert(scrollView)
	
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
