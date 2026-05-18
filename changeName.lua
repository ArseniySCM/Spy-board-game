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
	background:setFillColor(0,0,0, 0.4)
	background:addEventListener('tap', function() return true; end) --dont let tap on other elements
	
	--Menu
	local shadow = display.newRoundedRect(M.group, 0, 4, 380, 240, 20)
	shadow:setFillColor(unpack(globals.theme.shadow))
	
	local menu = display.newRoundedRect(M.group, 0, 0, 380, 240, 20)
	menu:setFillColor(unpack(globals.theme.card))
	
	local title = display.newText(M.group, "EDIT NAME", 0, -80, native.systemFontBold, 24)
	title:setFillColor(unpack(globals.theme.text))

	textFieldBg = display.newRoundedRect(M.group, 0, -10, 340, 60, 10)
	textFieldBg:setFillColor(unpack(globals.theme.background))
	
	nameTextField = native.newTextField(0, -10, 320, 50)
	nameTextField.text = ""
	nameTextField.hasBackground = false
	M.group:insert(nameTextField)
	
	--Buttons
	local cancel = widget.newButton({
		x = -90, y = 70,
		width = 160, height = 50,
        shape = "roundedRect",
        cornerRadius = 10,
		label = 'CANCEL',
		fontSize = 20,
		font = native.systemFontBold,
        fillColor = { default=globals.theme.accent, over=globals.theme.accent },
        labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel }
	})

	local ok = widget.newButton({
		x = 90, y = 70,
		width = 160, height = 50,
        shape = "roundedRect",
        cornerRadius = 10,
		label = 'OK',
		fontSize = 20,
		font = native.systemFontBold,
        fillColor = { default=globals.theme.primary, over=globals.theme.primary },
        labelColor = { default=globals.theme.buttonLabel, over=globals.theme.buttonLabel }
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