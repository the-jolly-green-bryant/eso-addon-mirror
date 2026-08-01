GlByGrhmForOverview = {}
local ov = GlByGrhmForOverview

--/script SetCVar("Language.2","de")

local win = "main"

function ov.isInPvPArea()
	if IsPlayerInAvAWorld() == true then
		return true
	end
	if IsInAvAZone() == true then
		return true
	end    
	if IsInImperialCity() == true then
		return true
	end
	if IsInCyrodiil() == true then
		return true
	end
	if IsActiveWorldBattleground() == true then
		return true
	end
	return false
end

ov.default = {}
ov.default.offsetX = {}
ov.default.offsetY = {}
ov.default.offsetX.main = 380
ov.default.offsetY.main = 640
ov.default.offsetX.abilities = 1800
ov.default.offsetY.abilities = 600
ov.default.offsetX.equipment = 330
ov.default.offsetY.equipment = 100
ov.default.offsetX.champion = 1700
ov.default.offsetY.champion = 110
ov.default.offsetX.character = 1165
ov.default.offsetY.character = 80
ov.default.offsetX.potionAndPoison = 610
ov.default.offsetY.potionAndPoison = 630
ov.default.hidden = {}
ov.default.hidden.abilities = 0
ov.default.hidden.equipment = 0
ov.default.hidden.champion = 0
ov.default.hidden.character = 0
ov.default.hidden.potionAndPoison = 0

ov.text = {}
ov.text.character = GetString(SI_MAIN_MENU_CHARACTER)
ov.text.abilities = GetString(SI_MAIN_MENU_SKILLS)
ov.text.equipment = GetString(SI_DYEING_DYE_EQUIPMENT_TAB)
ov.text.champion = GetString(SI_GAMEPAD_CHAMPION_ENTER_BAR)
ov.text.potionAndPoison = zo_strformat("<<1>><<2>><<3>>" ,GetString(SI_ITEMTYPE7), GetString(SI_LIST_AND_SEPARATOR), GetString(SI_ITEMTYPE30))
ov.text.main = "overview"

ov.text.menu = GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)
ov.text.exit = GetString(SI_DIALOG_CLOSE)

ov.color = {}
ov.color.gold = {r = 0.85, g = 0.83, b = 0.7}
ov.color.darkgold = {r = 0.65, g = 0.63, b = 0.5}
ov.color.grey = {r = 0.7, g = 0.7, b = 0.7}
ov.color.life = {r = 1.0, g = 0.5, b = 0.15}
ov.color.endurance = {r = 0.5, g = 1.0, b = 0.5}
ov.color.magicka = {r = 0.5, g = 0.7, b = 1.0}
ov.color.white = {r = 1.0, g = 1.0, b = 1.0}
ov.color.mediumgrey = {r = 0.6, g = 0.6, b = 0.6}
ov.color.lightgrey = {r = 0.8, g = 0.8, b = 0.8}
ov.color.red = {r = 1, g = 0, b = 0}

ov.font = {}
ov.font.big = "$(BOLD_FONT)|$(KB_22)soft-shadow-thin"
ov.font.header = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
ov.font.subHeader = "$(BOLD_FONT)|$(KB_18)soft-shadow-thick"
ov.font.element = "$(BOLD_FONT)|$(KB_18)soft-shadow-thick"
ov.font.subElement = "$(BOLD_FONT)|$(KB_15)soft-shadow-thin"

ov.ctrl = {}
ov.ctrl.wm = GetWindowManager()
ov.ctrl.tlw = {}

ov.ctrl.header = {}
ov.ctrl.headerTexture = {}
ov.ctrl.subHeader = {}
ov.ctrl.subHeader[win] = {}

ov.ctrl.button = {}
ov.ctrl.xButton = {}
ov.ctrl.dividor = {}
ov.ctrl.backdrop = {}
ov.ctrl.control = {}
ov.ctrl.control[win] = {}

local menuButtonIndex = 0

function ov.getColor(rgb, a)
	if a == nil then a = 1.0 end
	return ov.color[rgb].r, ov.color[rgb].g, ov.color[rgb].b, a
end

function ov.backdrop(name, win, sizeX, sizeY, offsetX, offsetY, anchor, position, relativePosition)
	if anchor then anchor = ov.ctrl.control[win][anchor] else anchor = ov.ctrl.tlw[win] end
	if not position then position = TOPLEFT end
	if not relativePosition then relativePosition = TOPLEFT end
	ov.ctrl.control[win][name] = ov.ctrl.wm:CreateControl(string.format("OverviewControl%s-%s", name, win), ov.ctrl.tlw[win], CT_CONTROL )
	ov.ctrl.control[win][name]:SetDimensions(sizeX, sizeY + 9)
	ov.ctrl.control[win][name]:SetAnchor(position, anchor, relativePosition, offsetX, offsetY)
	ov.ctrl.control[win][name]:SetDrawLayer(0)
	
	ov.ctrl.backdrop[win] = CreateControlFromVirtual(string.format("OverviewBackdrop%s-%s", name, win), ov.ctrl.control[win][name], "ZO_SliderBackdrop")
	ov.ctrl.backdrop[win]:SetCenterColor(0.0, 0.0, 0.0, 0.7)
	ov.ctrl.backdrop[win]:SetEdgeColor(1.0, 1.0, 1.0, 0.7)
end

function ov.createSubheader(name, win, position, relativePosition, offsetX, offsetY, text, anchor)
	if anchor then anchor = ov.ctrl.control[win][anchor] else anchor = ov.ctrl.tlw[win] end
	ov.ctrl.subHeader[win][name] = ov.ctrl.wm:CreateControl(string.format("OverviewSubHeader-%s-%s", win, name), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.subHeader[win][name]:SetAnchor(position, anchor, relativePosition, offsetX, offsetY)
	ov.ctrl.subHeader[win][name]:SetFont(ov.font.subHeader)
	ov.ctrl.subHeader[win][name]:SetWrapMode(ELLIPSIS)
	ov.ctrl.subHeader[win][name]:SetColor(ov.getColor("darkgold"))
	ov.ctrl.subHeader[win][name]:SetText(text)
end

function ov.createWin(win, sizeX, sizeY)
	ov.ctrl.tlw[win] = ov.ctrl.wm:CreateTopLevelWindow(string.format("OverviewTLW-%s", win))
	ov.ctrl.tlw[win]:SetDimensions(sizeX, sizeY)
	ov.ctrl.tlw[win]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ov.savedVars.offsetX[win], ov.savedVars.offsetY[win])
	ov.ctrl.tlw[win]:SetMovable(true)
	ov.ctrl.tlw[win]:SetMouseEnabled(true)
	ov.ctrl.tlw[win]:SetHidden(true)
	ov.ctrl.tlw[win]:SetHandler("OnMoveStop", function()
		ov.savedVars.offsetX[win] = ov.ctrl.tlw[win]:GetLeft()
		ov.savedVars.offsetY[win] = ov.ctrl.tlw[win]:GetTop() end)
	ov.ctrl.tlw[win]:SetClampedToScreen(true)
	
	ov.ctrl.header[win] = ov.ctrl.wm:CreateControl(string.format("OverviewHeader-%s", win), ov.ctrl.tlw[win], CT_LABEL )
	ov.ctrl.header[win]:SetAnchor(TOP, ov.ctrl.tlw[win], TOP ,0 , 3)
	ov.ctrl.header[win]:SetFont(ov.font.header)
	ov.ctrl.header[win]:SetWrapMode(ELLIPSIS)
	ov.ctrl.header[win]:SetColor(ov.getColor("gold"))
	ov.ctrl.header[win]:SetText(ov.text[win])
	
	ov.backdrop("header", win, sizeX, sizeY)
		
	if win ~= "main" then
		ov.ctrl.xButton[win] = ov.ctrl.wm:CreateControl(string.format("OverviewXButton-%s", win), ov.ctrl.tlw[win], CT_BUTTON)
		ov.ctrl.xButton[win]:SetAnchor(TOPRIGHT, ov.ctrl.backdrop[win]["header"], TOPRIGHT, 0, 5)
		ov.ctrl.xButton[win]:SetDimensions(20, 20)
		ov.ctrl.xButton[win]:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
		ov.ctrl.xButton[win]:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
		ov.ctrl.xButton[win]:SetHandler("OnClicked", function()
			if ov.ctrl.tlw[win]:IsHidden() == false then
				ov.ctrl.button[win]:SetState(1)
				ov.ctrl.tlw[win]:SetHidden(true)
				ov.savedVars.hidden[win] = 1
			elseif ov.ctrl.tlw[win]:IsHidden() == true then
				ov.ctrl.button[win]:SetState(0)
				ov.ctrl.tlw[win]:SetHidden(false)
				ov.savedVars.hidden[win] = 0
			end
		end)
	end
end

function ov.closeAll()
	for index, value in pairs(ov.ctrl.tlw) do
		value:SetHidden(true)
	end
	--Sordrak: UnregisterForEvent
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_UNSPENT_CHAMPION_POINTS_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_ACTIVE_QUICKSLOT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_ACTION_LAYER_PUSHED, ov.layerPopped)
end

function ov.menuBlankRow() menuButtonIndex = menuButtonIndex + 1 end

function ov.createButton(name)
	ov.ctrl.button[name] = ov.ctrl.wm:CreateControl(string.format("OverviewButton-%s", name), ov.ctrl.tlw.main, CT_BUTTON)
	ov.ctrl.button[name]:SetAnchor(TOP, ov.ctrl.tlw.main, TOP, 0, 65 + (25 * menuButtonIndex))
	ov.ctrl.button[name]:SetDimensions(192, 24)
	ov.ctrl.button[name]:SetFont(ov.font.element)
	ov.ctrl.button[name]:SetText(ov.text[name])
	ov.ctrl.button[name]:SetNormalFontColor(ov.getColor("gold"))
	ov.ctrl.button[name]:SetMouseOverFontColor(ov.getColor("white"))
	ov.ctrl.button[name]:SetPressedFontColor(ov.getColor("grey"))
	
	menuButtonIndex = menuButtonIndex + 1
	
	ov.ctrl.button[name]:SetHidden(false)
	
	ov.ctrl.button[name]:SetHandler("OnClicked", function()
		if name == "exit" then
			ov.closeAll()
		else
			if ov.ctrl.tlw[name]:IsHidden() == false then
				ov.ctrl.button[name]:SetState(1)
				ov.ctrl.tlw[name]:SetHidden(true)
				ov.savedVars.hidden[name] = 1
			elseif ov.ctrl.tlw[name]:IsHidden() == true then
				ov.ctrl.button[name]:SetState(0)
				ov.ctrl.tlw[name]:SetHidden(false)
				ov.savedVars.hidden[name] = 0
			end
		end
	end)
end


function ov.start()
	for index, value in pairs(ov.savedVars.hidden) do
		if value == 1 then
				ov.ctrl.tlw[index]:SetHidden(true)
				ov.ctrl.button[index]:SetState(1)
		elseif value == 0 then
				ov.ctrl.tlw[index]:SetHidden(false)
				ov.ctrl.button[index]:SetState(0)
		end
	end
	
	ov.characterFill()
	ov.championFill()
	ov.equipmentFill()
	ov.abilitiesFill()
	ov.potionFill()
	ov.poisonFill()

	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_EFFECT_CHANGED, ov.updateCharacterFill)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_PLAYER_ACTIVATED, ov.start)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ov.equipmentUpdate)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_UNSPENT_CHAMPION_POINTS_CHANGED, ov.championUpdate)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ov.abilitiesUpdate)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_ACTION_LAYER_PUSHED, ov.layerPopped)
	EVENT_MANAGER:RegisterForEvent("Overview", EVENT_ACTIVE_QUICKSLOT_CHANGED, ov.potionFill)
	
	ov.ctrl.tlw.main:SetHidden(false)
end

function ov.equipmentUpdate()
	ov.equipmentFill()
	ov.characterFill()
	ov.poisonFill()
end 

function ov.championUpdate()
	ov.championFill()
	ov.characterFill()
end 

function ov.abilitiesUpdate()
	ov.abilitiesFill()
	ov.characterFill()
	ov.poisonFill()
end 


function ov.layerPopped(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_PUSHED then
		if layerIndex == 3 then
			ov.closeAll()
		end
	end
end

function ov.openKeyBinding()
	if ov.ctrl.tlw.main:IsHidden() == true then
		ov.start()
	else
		ov.closeAll()
	end
end


function ov.initialize(event, addonName)
	if addonName == "Overview" then
		ZO_CreateStringId("SI_BINDING_NAME_OVERVIEW_OPEN", zo_strformat("Overview <<c:1>>", GetString(SI_URL_DIALOG_OPEN)))
	
		ov.savedVars = ZO_SavedVars:New("OverviewVars", 6, nil, ov.default)	
		
		ov.createWin("main", 200, 25)
		
		ov.createSubheader("menu", win , TOP, TOP, 0, 35, ov.text.menu)
		ov.backdrop("menu", win, 200, 210, 0, 30)
		
		ov.createWin("character", 515, 25)
		ov.createWin("abilities", 565, 25)
		ov.createWin("equipment", 805, 25)
		ov.createWin("potionAndPoison", 350, 25)
		ov.createWin("champion", 820, 25)

		ov.createButton("character")
		ov.createButton("abilities")
		ov.createButton("equipment")
		ov.createButton("potionAndPoison")
		ov.createButton("champion")
		ov.menuBlankRow()
		ov.createButton("exit")
		
		ov.createCharacter()
		ov.createAbilities()
		ov.createEquipment()
		ov.createPotionAndPoison()
		ov.createChampion()
		
		EVENT_MANAGER:UnregisterForEvent("Overview", EVENT_ADD_ON_LOADED)
		
		SLASH_COMMANDS["/overview"] = function()
			ov.start()
		end

	end
end

EVENT_MANAGER:RegisterForEvent("Overview", EVENT_ADD_ON_LOADED, ov.initialize)

