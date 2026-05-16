local M = {}

local widget = require 'widget'
local globals = require 'globals'

	local playerIndex
	local textFieldBg
	local nameTextField


function M.create()

	M.group = display.newGroup()
	M.group.x, M.group.y = display.contentCenterX, display.contentCenterY --group position
	
	--functions of buttons
	local function closeMenu() --press cancel
	
		M.group.isVisible = false
		nameTextField.isVisible = false
		
		return true
	end
	
	local function confirm() --press ok
	
		M.group.isVisible = false
		nameTextField.isVisible = false
		
		globals.rules.players[playerIndex] = nameTextField.text
		createButtons()
		
		return true
	end
	
	local background = display.newRect(M.group, 0, 0, globals.safeWidth, globals.safeHeight)
	background:setFillColor(0,0,0, 0.3)
	background:addEventListener('tap', function() return true; end) --dont let tap on other elements
	
	--Menu
	local shadow = display.newRoundedRect(M.group, 0, 4, 374, 204, 20)
	shadow:setFillColor(0.1, 0.5, 0.5)
	
	local menu = display.newRoundedRect(M.group, 0, 0, 370, 200, 20)
	menu:setFillColor(0.3, 0.8, 0.8, 0.9)
	
	textFieldBg = display.newRoundedRect(M.group, 0, -50, 360, 65, 20)
	textFieldBg:setFillColor(0.2, 0.7, 0.7, 0.9)
	
	nameTextField = native.newTextField(0, - 50, 330, 55)
	nameTextField.text = tostring( globals.rules.players[i] )
	nameTextField.hasBackground = false
	M.group:insert(nameTextField)
	
	--Buttons
	local cancel = widget.newButton({
		x = menu.width / - 4, y = 60,
		
		width = menu.width * 0.5,
		height = 50,
		
		label = 'Cancel',
		fontSize = 27,
		font = native.systemFont,
	})

	local ok = widget.newButton({
		x = menu.width / 4, y = 60,
		
		width = menu.width * 0.5,
		height = 50,
		
		label = 'Ok',
		fontSize = 27,
		font = native.systemFont,
	})
	
	M.group:insert(ok)
	M.group:insert(cancel)
	
	ok:addEventListener('tap', confirm)
	cancel:addEventListener('tap', closeMenu)
	
	M.group.isVisible = false
	nameTextField.isVisible = false
	
end

--open this menu
function M.open(id)

	playerIndex = id
	
	nameTextField.text = globals.rules.players[playerIndex]
	
	M.group.isVisible = true
	nameTextField.isVisible = true
	
end

return M