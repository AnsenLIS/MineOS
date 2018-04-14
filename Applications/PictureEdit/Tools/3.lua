
local GUI = require("GUI")
local image = require("image")
local tool = {}

------------------------------------------------------

tool.shortcut = "Re"
tool.keyCode = 46
tool.about = "Resizer tool allows to change picture size in real time. You can specify preffered direction, input width and height modifiers and smart script will do the rest."

local x, y, stepX, stepY, buttonWidth, buttonHeight, buttonCount, buttons, currentX, currentY = 1, 1, 2, 1, 7, 3, 3, {}

local buttonsContainer = GUI.container(1, 1, (buttonWidth + stepX) * buttonCount - stepX, (buttonHeight + stepY) * buttonCount - stepY)
local buttonsLayout = GUI.layout(1, 1, buttonsContainer.width, buttonsContainer.height, 1, 1)
buttonsLayout:setCellAlignment(1, 1, GUI.alignment.horizontal.center, GUI.alignment.vertical.top)
buttonsLayout:addChild(buttonsContainer)

local widthInput = GUI.input(1, 1, 1, 1, 0x2D2D2D, 0xC3C3C3, 0x5A5A5A, 0x2D2D2D, 0xD2D2D2, "", "Width")
local heightInput = GUI.input(1, 1, 1, 1, 0x2D2D2D, 0xC3C3C3, 0x5A5A5A, 0x2D2D2D, 0xD2D2D2, "", "Height")

local expandButton = GUI.roundedButton(1, 1, 36, 1, 0x696969, 0xE1E1E1, 0x2D2D2D, 0xE1E1E1, "Expand")
local cropButton = GUI.roundedButton(1, 1, 36, 1, 0x696969, 0xE1E1E1, 0x2D2D2D, 0xE1E1E1, "Crop")

expandButton.colors.disabled.background, expandButton.colors.disabled.text = 0x4B4B4B, 0x787878
cropButton.colors = expandButton.colors

local function try(x, y, symbol)
	if buttons[y] and buttons[y][x] then
		buttons[y][x].text = symbol
	end
end

local function set(x, y)
	for i = 1, #buttonsContainer.children do
		buttonsContainer.children[i].text = " "
	end

	currentX, currentY = x, y

	try(x, y, "⬤")
	try(x + 1, y, "▶")
	try(x - 1, y, "◀")
	try(x, y + 1, "▼")
	try(x, y - 1, "▲")
	try(x + 1, y + 1, "↘")
	try(x + 1, y - 1, "↗")
	try(x - 1, y + 1, "↙")
	try(x - 1, y - 1, "↖")
end

for j = 1, buttonCount do
	buttons[j] = {}
	for i = 1, buttonCount do
		buttons[j][i] = buttonsContainer:addChild(GUI.button(x, y, buttonWidth, buttonHeight, 0x2D2D2D, 0xB4B4B4, 0x696969, 0xD2D2D2, " "))
		buttons[j][i].onTouch = function()
			set(i, j)
			buttons[j][i]:getFirstParent():drawOnScreen()
		end

		x = x + buttonWidth + stepX
	end

	x, y = 1, y + buttonHeight + stepY
end

set(2, 2)

tool.onSelection = function(mainContainer)
	mainContainer.currentToolLayout:addChild(buttonsLayout)
	mainContainer.currentToolLayout:addChild(widthInput)
	mainContainer.currentToolLayout:addChild(heightInput)
	mainContainer.currentToolLayout:addChild(expandButton)
	mainContainer.currentToolLayout:addChild(cropButton)

	widthInput.onInputFinished = function()
		expandButton.disabled = not widthInput.text:match("%d+") or not heightInput.text:match("%d+")
		cropButton.disabled = expandButton.disabled

		mainContainer:drawOnScreen()
	end

	expandButton.onTouch = function()
		local width, height = tonumber(widthInput.text), tonumber(heightInput.text)
		
		mainContainer.image.data = image.expand(mainContainer.image.data,
			currentY > 1 and height or 0,
			currentY < 3 and height or 0,
			currentX > 1 and width or 0,
			currentX < 3 and width or 0,
		0x0, 0x0, 1, " ")

		mainContainer.image.reposition()
		mainContainer:drawOnScreen()
	end

	cropButton.onTouch = function()
		local width, height = tonumber(widthInput.text), tonumber(heightInput.text)
		
		mainContainer.image.data = image.crop(mainContainer.image.data,
			currentX == 1 and 1 or width + 1,
			currentY == 1 and 1 or height + 1,
			(currentX == 1 or currentX == 3) and mainContainer.image.width - width or mainContainer.image.width - width * 2,
			(currentY == 1 or currentY == 3) and mainContainer.image.height - height or mainContainer.image.height - height * 2
		)

		mainContainer.image.reposition()
		mainContainer:drawOnScreen()
	end

	heightInput.onInputFinished = widthInput.onInputFinished
	widthInput.onInputFinished()
end

tool.eventHandler = function(mainContainer, object, eventData)
	if eventData[1] == "touch" then
		
	end
end


------------------------------------------------------

return tool