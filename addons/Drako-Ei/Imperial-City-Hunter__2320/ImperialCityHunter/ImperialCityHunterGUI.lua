ImperialCityHunter.GUI_TITLE_PADDING = 30
ImperialCityHunter.MAP_SIZE = 130
ImperialCityHunter.ICON_SIZE = 40
ImperialCityHunter.BOSS_RADIUS_RATIO = 0.5
ImperialCityHunter.bossIcons = {}


function ImperialCityHunter:createMonsterIcon(districtName, x, y)
	local bossIcon = {}

	local icon = WINDOW_MANAGER:CreateControl("ImperialCityHunterWIN_Icon_"..x.."_"..y, ImperialCityHunterWIN, CT_TEXTURE)
	local midMapSize = ImperialCityHunter.MAP_SIZE/2
	local midIconSize = ImperialCityHunter.ICON_SIZE/2
	icon:SetDrawLayer(1)
	icon:SetDimensions(ImperialCityHunter.ICON_SIZE, ImperialCityHunter.ICON_SIZE)
	icon:SetTexture("ImperialCityHunter/Resources/monster.dds")
	icon:SetAnchor(TOPLEFT, ImperialCityHunterWIN_Map, TOPLEFT, midMapSize - midIconSize + x, midMapSize - midIconSize + y)
	bossIcon['icon'] = icon

	local deadIcon = WINDOW_MANAGER:CreateControl("ImperialCityHunterWIN_DeadIcon_"..x.."_"..y, ImperialCityHunterWIN, CT_TEXTURE)
	local midMapSize = ImperialCityHunter.MAP_SIZE/2
	local midIconSize = ImperialCityHunter.ICON_SIZE/2
	deadIcon:SetDrawLayer(2)
	deadIcon:SetDimensions(ImperialCityHunter.ICON_SIZE, ImperialCityHunter.ICON_SIZE)
	deadIcon:SetTexture("ImperialCityHunter/Resources/dead_monster.dds")
	deadIcon:SetAnchor(TOPLEFT, ImperialCityHunterWIN_Map, TOPLEFT, midMapSize - midIconSize + x, midMapSize - midIconSize + y)
	deadIcon:SetHidden(true)
	bossIcon['dead'] = deadIcon


	local bossCooldown = WINDOW_MANAGER:CreateControl("ImperialCityHunterWIN_Caption_"..x.."_"..y, ImperialCityHunterWIN, CT_LABEL)
	bossCooldown:SetDrawLayer(3)
	bossCooldown:SetText("|cFFFFFF00|r")
	bossCooldown:SetFont("ZoFontWinH5")
	bossCooldown:SetColor(1, 1, 1, 1)
	bossCooldown:SetAnchor(TOPLEFT, deadIcon, TOPLEFT, 13, 10)
	bossCooldown:SetHidden(true)
	bossIcon['text'] = bossCooldown

	ImperialCityHunter.bossIcons[districtName] = bossIcon
end

function ImperialCityHunter:saveWinPos()
	ImperialCityHunter.savedVariables.left = ImperialCityHunterWIN:GetLeft()
	ImperialCityHunter.savedVariables.top = ImperialCityHunterWIN:GetTop()
end

function ImperialCityHunter:restoreWinPos()
	local left = ImperialCityHunter.savedVariables.left
	local top = ImperialCityHunter.savedVariables.top
	ImperialCityHunterWIN:ClearAnchors()
	ImperialCityHunterWIN:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function ImperialCityHunter:enableDistrictIcon(districtName)
	local bossIcon = ImperialCityHunter.bossIcons[districtName]
	bossIcon['dead']:SetHidden(true)
	bossIcon['text']:SetText("|cFFFFFF00|r")
	bossIcon['text']:SetHidden(true)
end

function ImperialCityHunter:setDistrictRespawnTime(districtName, milliSeconds)
	local bossIcon = ImperialCityHunter.bossIcons[districtName]
	bossIcon['dead']:SetHidden(false)
	local minutes = math.ceil((milliSeconds/1000)/60)
	if (minutes < 10) then
		bossIcon['text']:SetText("|cFFFFFF0"..minutes.."|r")
	else
		bossIcon['text']:SetText("|cFFFFFF"..minutes.."|r")
	end
	bossIcon['text']:SetHidden(false)
end

function ImperialCityHunter:resetIcons()
	for k, v in pairs(ImperialCityHunter.districts) do
		ImperialCityHunter:enableDistrictIcon(k)
	end
end

function ImperialCityHunter:createGUI()
	-- WINDOW CREATION
	local window = WINDOW_MANAGER:CreateTopLevelWindow("ImperialCityHunterWIN")
	window:SetDrawLayer(0)
	window:SetHidden(true)
	window:SetAnchor(LEFT, GuiRoot, CENTER, 0, 0)
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:SetMouseEnabled(true)
	window:SetDimensions(ImperialCityHunter.MAP_SIZE, ImperialCityHunter.MAP_SIZE + ImperialCityHunter.GUI_TITLE_PADDING)
	window:SetHandler("OnMoveStop", function()
		ImperialCityHunter:saveWinPos()
	end)

	-- WINDOW BACKGROUND
	WINDOW_MANAGER:CreateControlFromVirtual("ImperialCityHunterWIN_BG", ImperialCityHunterWIN, "ZO_DefaultBackdrop")

	-- WINDOW TITLE
	local title = WINDOW_MANAGER:CreateControl("ImperialCityHunterWIN_Title", ImperialCityHunterWIN, CT_LABEL)
	title:SetText("|c0083FFIC Hunter|r")
	title:SetFont("ZoFontWinH3")
	title:SetColor(1, 1, 1, 1)
	title:SetAnchor(TOP, ImperialCityHunterWIN, TOP, 0, 2)

	local map = WINDOW_MANAGER:CreateControl("ImperialCityHunterWIN_Map", ImperialCityHunterWIN, CT_BUTTON)
	map:SetDrawLayer(0)
	map:SetDimensions(ImperialCityHunter.MAP_SIZE, ImperialCityHunter.MAP_SIZE)
	map:SetState(BSTATE_NORMAL)
	map:SetNormalTexture("ImperialCityHunter/Resources/map.dds")
	map:SetAnchor(TOPLEFT, ImperialCityHunterWIN, TOPLEFT, 0, ImperialCityHunter.GUI_TITLE_PADDING)

	ImperialCityHunter:createMonsterIcon('Temple District', 0, 90*ImperialCityHunter.BOSS_RADIUS_RATIO)
	ImperialCityHunter:createMonsterIcon('Memorial District', 0, -85*ImperialCityHunter.BOSS_RADIUS_RATIO)
	ImperialCityHunter:createMonsterIcon('Arena District', 75*ImperialCityHunter.BOSS_RADIUS_RATIO, -40*ImperialCityHunter.BOSS_RADIUS_RATIO)
	ImperialCityHunter:createMonsterIcon('Elven Gardens District', -75*ImperialCityHunter.BOSS_RADIUS_RATIO, -40*ImperialCityHunter.BOSS_RADIUS_RATIO)
	ImperialCityHunter:createMonsterIcon('Arboretum District', 75*ImperialCityHunter.BOSS_RADIUS_RATIO, 50*ImperialCityHunter.BOSS_RADIUS_RATIO)
	ImperialCityHunter:createMonsterIcon('Nobles District', -75*ImperialCityHunter.BOSS_RADIUS_RATIO, 50*ImperialCityHunter.BOSS_RADIUS_RATIO)
end