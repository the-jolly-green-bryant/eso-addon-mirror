local GS = GetString

local mundusLocs = { -- mundus locations for tooltip
	[13984] = { 108,	20, 117}, 	-- shadow
	[13985] = {383, 19, 57}, 		-- tower
	[13940] = {58, 104, 101}, 		-- warrior
	[13974] = {108,	20, 117,}, 		-- serpent
	[13943] = {383, 19, 57 ,}, 		-- mage
	[13976] = {381 ,3, 41 ,}, 		-- lord
	[13977] = {382, 92, 103,}, 		-- steed
	[13978] = {383, 19, 57,}, 		-- lady
	[13979] = {382 ,92, 103,}, 		-- apprentice
	[13980] = {58, 104 ,101,} ,		-- ritual
	[13981] = {381, 3, 41,}, 		-- lover
	[13982] = {108, 20, 117,},		-- atronarch
	[13975] = {58, 104, 101,}, 		-- thief
}

local mundusAbs = {
  [13984] = 60599, -- shadow
  [13985] = 60554, -- tower
  [13940] = 60462, -- warrior
  [13974] = 60594, -- serpent
  [13943] = 60550, -- mage
  [13978] = 60579, -- lord
  [13977] = 60604, -- steed
  [13976] = 60574, -- lady
  [13979] = 60556, -- apprentice
  [13980] = 60589, -- ritual
  [13981] = 60584, -- lover
  [13982] = 60569, -- atronach
  [13975] = 60610, -- thief
}

local mundusFurniture = {
  [13984] = 125457, -- shadow
  [13985] = 125454, -- tower
  [13940] = 125453, -- warrior
  [13974] = 125458, -- serpent
  [13943] = 125460, -- mage
  [13978] = 126034, -- lord
  [13977] = 125456, -- steed
  [13976] = 125452, -- lady
  [13979] = 125451, -- apprentice
  [13980] = 125459, -- ritual
  [13981] = 125461, -- lover
  [13982] = 119556, -- atronach
  [13975] = 125455, -- thief
}

local currentMundusId = false

local function getCurrentMundus()
	local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", i)
		if mundusAbs[id] then return id end
	end
	return false
end


local function findMundusInHome()
	if currentMundusId == getCurrentMundus() or not currentMundusId then return end
	local furnitureId = GetNextPlacedHousingFurnitureId()
	while furnitureId do
		local name = GetPlacedHousingFurnitureInfo(furnitureId)
		local itemL, collectibleL = GetPlacedFurnitureLink(furnitureId)
		if GetItemLinkItemId(itemL) == mundusFurniture[currentMundusId] then
			local x,y,z = HousingEditorGetFurnitureWorldPosition(furnitureId)
			d(itemL)
			x, y = GetNormalizedWorldPosition((GetUnitWorldPosition("player")), x, y, z)
			PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, x, y)
			break
		end
		furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
	end
end

CSPS.findMundusInHome = findMundusInHome

function CSPS.showMundusTooltip(control, mundusId)	
	mundusId = mundusId or currentMundusId
	if not mundusId or mundusId == 0 then ZO_Tooltips_ShowTextTooltip(control, RIGHT, GS(SI_STATS_MUNDUS_TITLE)) return end

	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(zo_strformat("<<C:1>> |t28:28:<<2>>|t", GetAbilityName(mundusId), GetAbilityIcon(mundusId)), "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	local r,g,b =  ZO_NORMAL_TEXT:UnpackRGB()
	local mundusDescription = GetAbilityDescription(mundusId)
	-- Who knows why some descriptions are missing the dot. Or why they had separate abilityIds for the stones at some point...
	if not string.sub(mundusDescription, -1) == "." then mundusDescription = string.format("%s.", mundusDescription) end
	InformationTooltip:AddLine(mundusDescription, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
	local mLL = mundusLocs[mundusId]
	local mundusLocText = {}
	for i, v in pairs(mLL) do
		table.insert(mundusLocText, zo_strformat("<<C:1>>", GetZoneNameById(v)))
	end
	InformationTooltip:AddLine(string.format("%s: %s", GS(SI_ZONECOMPLETIONTYPE12), ZO_GenerateCommaSeparatedList(mundusLocText)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 

end

local function changeMundus(mundusId, mundusName)
	mundusName = mundusName or mundusId and mundusId ~= 0 and zo_strformat("<<C:1>>", GetAbilityName(mundusId)) or "-"
	CSPSWindowMundusLabel:SetText(string.match(mundusName, "%s(%S+)$"))
	currentMundusId = mundusId
	CSPS.currentMundus = currentMundusId
	if currentMundusId == getCurrentMundus() then
		CSPSWindowMundusLabel:SetColor(CSPS.colors.green:UnpackRGB())
	else
		CSPSWindowMundusLabel:SetColor(CSPS.colors.orange:UnpackRGB())
	end
end
	
function CSPS.showMundusMenu()

	local mundusAlphabetical = {}
	local mundusIdByName = {}
	
	
	for mundusId, abilityId in pairs(mundusAbs) do
		local mundusName = zo_strformat("<<C:1>>", GetAbilityName(mundusId))
		table.insert(mundusAlphabetical, mundusName)
		mundusIdByName[mundusName] = mundusId
	end
	
	table.sort(mundusAlphabetical)
	
	ClearMenu()
	
	for _, mundusName in pairs(mundusAlphabetical) do
		local mundusId = mundusIdByName[mundusName]
		local mundusDescription = GetAbilityDescription(mundusId)
		if not string.sub(mundusDescription, -1) == "." then mundusDescription = string.format("%s.", mundusDescription) end
		
		AddCustomMenuItem(mundusName, function() changeMundus(mundusId, mundusName) end)

		local menuItemControl = ZO_Menu.items[#ZO_Menu.items].item 
		menuItemControl.onEnter = function() ZO_Tooltips_ShowTextTooltip(menuItemControl, RIGHT, mundusDescription)	end
		menuItemControl.onExit = function() ZO_Tooltips_HideTextTooltip() end
	
	end
	ShowMenu()
end
	
function CSPS.InitializeMundusMenu()
	
	changeMundus(getCurrentMundus(), false)
	
	local EM = EVENT_MANAGER
	for mundusId, abilityId in pairs(mundusAbs) do
		EM:RegisterForEvent("CSPS_MUNDUS_"..mundusId, EVENT_EFFECT_CHANGED, function() CSPS.setMundus() end)
		EM:AddFilterForEvent("CSPS_MUNDUS_"..mundusId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mundusId)
		EM:AddFilterForEvent("CSPS_MUNDUS_"..mundusId, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	end
	
end

function CSPS.setMundus(mundusId)
	mundusId = mundusId or currentMundusId
	changeMundus(mundusId, nil)
end

function CSPS.setCurrentMundus()
	currentMundusId = getCurrentMundus()
	CSPS.setMundus(currentMundusId)
end

function CSPS.getMundus()
	return currentMundusId or 0
end