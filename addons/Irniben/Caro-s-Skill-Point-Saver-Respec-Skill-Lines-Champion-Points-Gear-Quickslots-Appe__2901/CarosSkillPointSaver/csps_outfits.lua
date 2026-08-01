local GS = GetString
CSPS.outfits = {current = {slots = {}}}
local outfits = CSPS.outfits
local outfitCollectibleTypes = {
	COLLECTIBLE_CATEGORY_TYPE_HAT,
	COLLECTIBLE_CATEGORY_TYPE_HAIR,
	COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
	COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
	COLLECTIBLE_CATEGORY_TYPE_COSTUME,
	COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
	COLLECTIBLE_CATEGORY_TYPE_SKIN,
	COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
	COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,

	COLLECTIBLE_CATEGORY_TYPE_MOUNT,
	COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
	--COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE,handled separately
}

local actionFXTopLevel = GetCategoryInfoFromCollectibleCategoryId(104) --it's hardcoded... categorytype not working here...

local dyeColor = ZO_ColorDef:New(1,1,1)

outfits.current = {}
outfits.current.actionFX = {}

local ttAddLine = CSPS.helperFunctions.ttAddLine
local function getShiftApplyText() 
	return string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t + %s: %s", GS("SI_KEYCODE", CSPS.savedVariables.settings.jumpShiftKey or 7), GS(SI_APPLY))
end
local function getMonturName(monturIndex)
	if not monturIndex or monturIndex == 0 then return GS(SI_NO_OUTFIT_EQUIP_ENTRY) end
	local monturName = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, monturIndex)
	if not monturName or monturName == "" then monturName = string.format("%s %s", GS(SI_OUTFIT_SELECTOR_TITLE), monturIndex) end
	return string.format("%s) %s", monturIndex, monturName)
end

local function findActiveActionFXOverride(actionFXCategory)
	local _, numCollectibles = GetCollectibleSubCategoryInfo(actionFXTopLevel, actionFXCategory)
	for i=1, numCollectibles do
		local collectibleId = GetCollectibleId(actionFXTopLevel, actionFXCategory, i)
		if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			return collectibleId
		end
	end
end

local function getCurrentOutfitIndex()
	if  STATS.control:IsHidden() then return GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0 end
	return STATS.pendingEquipOutfitIndex or 0
end


function outfits.read()
	
	local ignoreEmptyOutfitslots = CSPS.savedVariables.settings.ignoreEmptyOutfitslots -- this entry is a reverse boolean! should be named DONOTignore!
	
	outfits.current.montur = getCurrentOutfitIndex()
	if outfits.current.montur == 0 and not ignoreEmptyOutfitslots then outfits.current.montur = nil end
	outfits.current.title = GetCurrentTitleIndex() or 0
	if outfits.current.title == 0 and not ignoreEmptyOutfitslots then outfits.current.title = nil end
	outfits.current.slots = {}
	for _, outfitCollectibleType in pairs(outfitCollectibleTypes) do
		outfits.current.slots[outfitCollectibleType] = GetActiveCollectibleByType(outfitCollectibleType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		if outfits.current.slots[outfitCollectibleType] == 0 and not ignoreEmptyOutfitslots then outfits.current.slots[outfitCollectibleType] = nil end
	end
	
	local _, numActionFXCats = GetCollectibleCategoryInfo(actionFXTopLevel)
	for actionFXCategory = 1, numActionFXCats do
		outfits.current.actionFX[actionFXCategory] = collectibleId
		outfits.current.actionFX[actionFXCategory] = findActiveActionFXOverride(actionFXCategory) or ignoreEmptyOutfitslots and 0 or nil
	end
	
end

local function applyActionFX(actionFXCategory, collectibleId)
	if collectibleId and collectibleId ~= 0 and not IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
		UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	elseif collectibleId == 0 then
		local currentCollectible = findActiveActionFXOverride(actionFXCategory)
		if currentCollectible then UseCollectible(currentCollectible, GAMEPLAY_ACTOR_CATEGORY_PLAYER) end
	end
end

function outfits.apply(outfitTable)
	outfitTable = outfitTable or outfits.current
	if outfitTable.montur and outfitTable.montur ~= getCurrentOutfitIndex() then
		if not outfitTable.montur or outfitTable.montur == 0 then
			UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		else
			EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitTable.montur)
		end
	end

	if outfitTable.title and outfitTable.title ~= (GetCurrentTitleIndex() or 0) then
		SelectTitle(outfitTable.title)
	end
	
	for outfitCollectibleType, collectibleId in pairs(outfitTable.slots) do
		if collectibleId ~= GetActiveCollectibleByType(outfitCollectibleType, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			if collectibleId and collectibleId ~= 0 then
				UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			else
				UseCollectible(GetActiveCollectibleByType(outfitCollectibleType, GAMEPLAY_ACTOR_CATEGORY_PLAYER), GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			end
		end
	end
	for actionFXCategory, collectibleId in pairs (outfits.current.actionFX) do
		applyActionFX(actionFXCategory, collectibleId)
	end
end

function outfits.addToTooltip(outfitTable)
	outfitTable = outfitTable or outfits.current	
	local outfitName = getMonturName(outfitTable.montur)
	ttAddLine(string.format("%s: %s", GS(SI_OUTFIT_SELECTOR_TITLE), outfitName))
	ttAddLine(zo_strformat("<<C:1>> <<C:2>>", GS(SI_STATS_TITLE), GetTitle(outfitTable.title or 0) or "-"))
	for outfitCollectibleType, collectibleId in pairs(outfitTable.slots) do
		ttAddLine(string.format("%s: %s", GS("SI_COLLECTIBLECATEGORYTYPE", outfitCollectibleType), GetCollectibleLink(collectibleId)))
	end
end

function outfits.compress(outfitTable)
	outfitTable = outfitTable or outfits.current
	if not outfitTable.slots then return nil end
	local compressedSlots = {}
	for outfitCollectibleType, collectibleId in pairs(outfits.current.slots) do
		if collectibleId then table.insert(compressedSlots, string.format("%s:%s", outfitCollectibleType, collectibleId)) end
	end
	local compressedActionFX = {}
	for cat, collectibleId in pairs(outfits.current.actionFX) do
		if collectibleId then table.insert(compressedActionFX, collectibleId ~= 0 and collectibleId or GetCollectibleCategoryId(actionFXTopLevel, cat)) end
	end
	if #compressedActionFX > 0 then table.insert(compressedSlots, string.format("%s:%s", COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, table.concat(compressedActionFX, "."))) end
	local compressedString = {outfitTable.montur or "-", outfitTable.title or "-", table.concat(compressedSlots, ",")}
	return table.concat(compressedString, ";")
end

function outfits.extract(compressedString, outfitTable)
	outfitTable = outfitTable or outfits.current
	outfitTable.slots = {}
	if not compressedString or compressedString == "" then return outfitTable end
	local montur, title, slots = SplitString(";", compressedString)
	outfitTable.montur = montur ~= "-" and tonumber(montur) or nil
	outfitTable.title = title ~= "-" and tonumber(title) or nil
	if slots and slots ~= "" then
		for _, collectibleEntry in pairs({SplitString(",", slots)}) do
			local outfitCollectibleType, collectibleId = SplitString(":", collectibleEntry)
			outfitCollectibleType = tonumber(outfitCollectibleType)
			if outfitCollectibleType == COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE then
				local compressedActionFX = {SplitString(".", collectibleId)}
				outfitTable.actionFX = {}
				for i, v in pairs(compressedActionFX) do
					local actionColId = tonumber(v)
					if actionColId < 420 then
						_, actionColId = GetCategoryInfoFromCollectibleCategoryId(actionColId)
						outfitTable.actionFX[actionColId] = 0
					else
						local topLevel, cat, index = GetCategoryInfoFromCollectibleId(actionColId)
						if topLevel == actionFXTopLevel then
							outfitTable.actionFX[cat] = actionColId
						end
					end
				end
			else
				outfitTable.slots[outfitCollectibleType] = tonumber(collectibleId) or 0
			end
		end
	end
	return outfitTable
end

function outfits.setSlot(outfitCollectibleType, actionValue)
	outfits.current.slots[outfitCollectibleType] = actionValue
	CSPS.unsavedChanges = true
	CSPS.refreshTree()
end

local function showMonturTooltip(control, monturIndex)
	if not monturIndex or monturIndex == 0 then return end
	InitializeTooltip(InformationTooltip, control, LEFT, 0, 0, RIGHT)
	ttAddLine(zo_strformat("<<C:1>>", getMonturName(monturIndex)), "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	for i=1, 31 do
		local collectibleId, _, dye1, dye2, dye3 = GetOutfitSlotInfo(GAMEPLAY_ACTOR_CATEGORY_PLAYER, monturIndex, i)
		local dyes = {dye1, dye2, dye3}
		if collectibleId and collectibleId > 0 then
			local partName = zo_strformat("<<C:1>>", GetCollectibleName(collectibleId))
			if string.len(partName) > 25 then partName = string.sub(partName, 1, 23).."..." end
			local colorNames = {}
			for j=1,3 do
				if dyes[j] and dyes[j] ~= 0 then 
					local dyeName, _, _, _, _, r,g,b = GetDyeInfoById(dyes[j])
					dyeColor:SetRGB(r,g,b)
					dyeName = dyeColor:Colorize("|t24:24:esoui/art/dye/gamepad/dye_circle.dds:inheritcolor|t")
					table.insert(colorNames, dyeName)							
				end 
			end

			if #colorNames > 0 then
				partName = string.format("%s %s", partName, table.concat(colorNames, ""))
			end
			
			ttAddLine(string.format("|t32:32:%s|t %s", GetCollectibleIcon(collectibleId), partName))
		end
	end	
end

function outfits.showMonturMenu()
	ClearMenu()
	
	for i=0, GetNumUnlockedOutfits() do
		AddCustomMenuItem(getMonturName(i), function() outfits.current.montur = i CSPS.unsavedChanges = true CSPS.refreshTree() end)
		AddCustomMenuTooltip(function(itemControl, inside) 
			if not inside then ZO_Tooltips_HideTextTooltip() return end
			showMonturTooltip(itemControl, i)
		end)
	end
	
	ShowMenu()
end

local function getAchievementListByTitles(titleTable)
	local achievementIds = {}
	local dungeonAchieve = {}
	local trialAchieve = {}
	local otherTitles = {}
	
	local numCategories = GetNumAchievementCategories()
	for achievementTopLevelIndex=1, numCategories do
		local _, numSubCats, numAchievements = GetAchievementCategoryInfo(achievementTopLevelIndex)
		local function checkAchievement(achievementId) 
			local hasTitle, achievedTitle =  GetAchievementRewardTitle(achievementId)
			
			if hasTitle and not titleTable or titleTable and titleTable[achievedTitle] then
				achievementIds[achievedTitle] = achievementId
				return achievedTitle
			end
		end
		for achievementIndex=1, numAchievements do
			local achievementId = GetAchievementId(achievementTopLevelIndex, nil, achievementIndex)
			local achievedTitle = checkAchievement(achievementId)
			if achievedTitle then
				if achievementTopLevelIndex == 5 then 
					table.insert(dungeonAchieve, achievedTitle) 
				else
					local points = GetAchievementRewardPoints(achievementId)
					otherTitles[points] = otherTitles[points] or {}
					table.insert(otherTitles[points], achievedTitle)
				end	
			end 
		end
		local auxSubCats = numAchievements == 0 and numSubCats - 1 or numSubCats
		for subCategoryIndex=1, numSubCats do
			local _, numSubAchievements = GetAchievementSubCategoryInfo(achievementTopLevelIndex, subCategoryIndex)
			for achievementIndex=1, numSubAchievements do
				local achievementId = GetAchievementId(achievementTopLevelIndex, subCategoryIndex, achievementIndex)
				local achievedTitle = checkAchievement(achievementId)
				if achievedTitle then
					if achievementTopLevelIndex == 4 and subCategoryIndex == 1 or achievementTopLevelIndex > 10 and auxSubCats > 2 and subCategoryIndex == auxSubCats then
						table.insert(trialAchieve, achievedTitle)
					elseif achievementTopLevelIndex > 10 and auxSubCats == 1 then 
						table.insert(dungeonAchieve, achievedTitle) 
						-- this won't give us the dungeons from imperial city, but they don't have titles anyway... 
						-- and I really didn't want to hardcode the achievementIds...
					else
						local points = GetAchievementRewardPoints(achievementId)
						otherTitles[points] = otherTitles[points] or {}
						table.insert(otherTitles[points], achievedTitle)
					end
				end
			end
		end
	end
	return achievementIds, dungeonAchieve, trialAchieve, otherTitles
end

CSPS.getAL = getAchievementListByTitles

local function getAchievementByTitle(title)
	if not title or title == "" then return false end
	local achievementIds = getAchievementListByTitles({[title] = true})
	return achievementIds[title] or false
end

function outfits.showTitleMenu()
	
	local titlesByName = {}
	local alphabeticalTitles = {}
	
	for i=1, GetNumTitles() do
		titlesByName[GetTitle(i)] = i
		table.insert(alphabeticalTitles, GetTitle(i))
	end
	
	local sortedTitleNames = {{}}
	local sortedTitleListNames = {}
	
	local firstLetter = false
	local nextList = {}
	table.sort(alphabeticalTitles)
	
	for _, title in pairs(alphabeticalTitles) do
		local myFirstLetter = string.upper(string.sub(title, 1,1))
		firstLetter = firstLetter or myFirstLetter
		if myFirstLetter == firstLetter then 
			table.insert(nextList, title)
		else
			if #sortedTitleNames[#sortedTitleNames] + #nextList >= 21 and #sortedTitleNames[#sortedTitleNames] > 0 then
				table.insert(sortedTitleNames, {})
			end
			for i, v in pairs(nextList) do
				table.insert(sortedTitleNames[#sortedTitleNames], v)
			end
			nextList = {title}
			firstLetter = myFirstLetter
		end
	end
	
	for listIndex, subList in pairs(sortedTitleNames) do
		sortedTitleListNames[listIndex] = string.format("%s-%s", string.sub(subList[1], 1,1), string.sub(subList[#subList], 1,1))
	end
	
	local achievementIds, dungeonAchieve, trialAchieve, otherTitles = getAchievementListByTitles(titlesByName)
	
	table.sort(dungeonAchieve)
	table.sort(trialAchieve)
	table.insert(sortedTitleNames, dungeonAchieve)
	local placeholderPosition = #sortedTitleNames
	table.insert(sortedTitleListNames, string.format("%s (%s)", GS(SI_CONSOLEACTIVITYTYPE1), GS(SI_DUNGEONDIFFICULTY2)))
	table.insert(sortedTitleNames, trialAchieve)
	table.insert(sortedTitleListNames, string.format("%s", GS(SI_INSTANCETYPE3)))
	
	for i, v in pairs({5,10,15,50}) do
		if otherTitles[v] then
			table.sort(otherTitles[v])
			table.insert(sortedTitleNames, otherTitles[v])
			table.insert(sortedTitleListNames, string.format("%s (%s %s)", GS(SI_FURNITURETHEMETYPE1), v, GS(	SI_GUILD_RECRUITMENT_ACHIEVEMENT_POINTS_HEADER)))
		end
	end
	
	ClearMenu()
	for listIndex, subList in pairs(sortedTitleNames) do
		if listIndex == placeholderPosition then AddCustomMenuItem("-", function() end) end
		local subMenu = {}
		for _, titleName in pairs(subList) do
			local achievementId = achievementIds[titleName]
			local tooltip = false
			if achievementId then 
				tooltip = function(control, inside) -- would use AchievementTooltip but there's no icon in it and me wants more beautiful icons!
					if not inside then ClearTooltip(InformationTooltip) return "" end
					local name, description, _, texture = GetAchievementInfo(achievementId)
					InitializeTooltip(InformationTooltip, control, LEFT, 0, 15, RIGHT)
					ttAddLine(zo_strformat("<<C:1>>", name), "ZoFontWinH2")
					ttAddLine(string.format("\n|t48:48:%s|t\n", texture))
					ZO_Tooltip_AddDivider(InformationTooltip)
					ttAddLine(zo_strformat("<<1>>", description))
					return ""
				end
			end
			table.insert(subMenu, {label = titleName, callback = function() outfits.current.title = titlesByName[titleName] CSPS.unsavedChanges = true CSPS.refreshTree() end, tooltip = tooltip or nil})
		end
		AddCustomSubMenuItem(sortedTitleListNames[listIndex], subMenu) 
	end
	ShowMenu()
	return titlesByName, achievementIds
end

local function showActionFXTooltip(control, collectibleId)
	if collectibleId == 0 or not collectibleId then return false end
	local name, description, icon, _, unlocked, _, _, _, hint = GetCollectibleInfo(collectibleId)
	InitializeTooltip(InformationTooltip, itemControl, LEFT)
	ttAddLine(zo_strformat("<<C:1>>", name), "ZoFontWinH2", not unlocked and ZO_ERROR_COLOR or nil)
	ttAddLine(string.format("\n|t48:48:%s|t\n", icon))
	ZO_Tooltip_AddDivider(InformationTooltip)
	ttAddLine(zo_strformat("<<1>>", description))
	if not unlocked and hint and hint ~= "" then
		ttAddLine(zo_strformat("<<1>>", hint), nil, ZO_ORANGE)
	end
	return true
end

function outfits.showActionFXMenu(actionFXCategory)
	if not actionFXCategory then return end
	local _, numCollectibles = GetCollectibleSubCategoryInfo(actionFXTopLevel, actionFXCategory)
	ClearMenu()
	local sortedCollectibles = {}
	local lockedCollectibles = {}
	
	for i=1, numCollectibles do
		
		local collectibleId = GetCollectibleId(actionFXTopLevel, actionFXCategory, i)

		local name, description, icon, _, unlocked, _, _, _, hint = GetCollectibleInfo(collectibleId)
		table.insert(unlocked and sortedCollectibles or lockedCollectibles, {name, icon, unlocked, collectibleId})
	end
	
	local function addItem(name, icon, unlocked, collectibleId)
		name = zo_strformat("<<C:1>>", name)
		if not unlocked then name = ZO_ORANGE:Colorize(name) end
		AddCustomMenuItem(name, function() 
			outfits.current.actionFX[actionFXCategory] = collectibleId 
			CSPS.unsavedChanges = true
			CSPS.refreshTree() 
		end)		
		AddCustomMenuTooltip(function(itemControl, inside) 
			if not inside then ZO_Tooltips_HideTextTooltip() return end
			showActionFXTooltip(itemControl, collectibleId)
		end)
	end
	for i, v in pairs(sortedCollectibles) do 
		addItem(unpack(v))
	end
	if #sortedCollectibles > 0 and #lockedCollectibles > 0 then AddCustomMenuItem("-", function() end) end
	for i, v in pairs(lockedCollectibles) do
		addItem(unpack(v))
	end
	ShowMenu()
end

local function doesActionFXFit(actionFXCategory, collectibleId)
	if not collectibleId then return false end
	if collectibleId ~= 0 then return IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) end
	return not findActiveActionFXOverride(actionFXCategory)
end

local function NodeSetupOutfit(node, control, data, open, userRequested, enabled)

	-- control.receiveDragFunction = function() receiveDrag(mySlot) end
	local ctrText = control:GetNamedChild("Text")
	local ctrIndicator = control:GetNamedChild("Indicator")
	local ctrIcon = control:GetNamedChild("Icon")
	local ctrMinus = control:GetNamedChild("BtnMinus")
	local ctrUnequip = control:GetNamedChild("BtnUnequip")
	local colTbl = CSPS.colors
	local errorColor = colTbl.white
	ctrIndicator:SetHidden(true) -- will add this later
	control:SetHandler("OnMouseUp", function(self, button, upInside, ctrl, alt, shift)
		if not upInside then return end
		if button == 2 then
			if data.outfitCollectibleType then
				CSPS.openCollectibleList(data.outfitCollectibleType)
				CSPS.refreshTree()
			elseif data.isTitle then
				outfits.showTitleMenu()
			elseif data.isMontur then
				outfits.showMonturMenu()
			elseif data.actionFXCategory then
				outfits.showActionFXMenu(data.actionFXCategory)
			end
		elseif button == 1 then
			local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
			myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
			if not myShiftKey then return end
			
			if data.outfitCollectibleType then
				local slotData = outfits.current.slots[data.outfitCollectibleType]
				if not slotData then return end
				if slotData == 0 then 
					UseCollectible(GetActiveCollectibleByType(data.outfitCollectibleType, GAMEPLAY_ACTOR_CATEGORY_PLAYER), GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				else
					UseCollectible(slotData)
				end
			elseif data.isTitle and outfits.current.title then 
				SelectTitle(outfits.current.title)
			elseif data.isMontur and outfits.current.montur then
				if outfits.current.montur == 0 then 
					UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				else
					EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfits.current.montur)
				end
			elseif data.actionFXCategory then
				applyActionFX(data.actionFXCategory, outfits.current.actionFX[data.actionFXCategory])
			else
				return
			end
			zo_callLater(function() CSPS.refreshTree() end, 420)
		end
	end)
	if data.isMontur then
		local monturName = getMonturName(outfits.current.montur)	
		if outfits.current.montur and outfits.current.montur ~= 0 then
			control.tooltipFunction = function()
				showMonturTooltip(ctrText, outfits.current.montur)	
				ZO_Tooltip_AddDivider(InformationTooltip)
				ttAddLine(getShiftApplyText())
				ttAddLine(GS(CSPS_QS_TT_Edit))
			end -- GS(SI_APPLY))
			
			ctrMinus:SetHidden(false)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.montur = nil CSPS.unsavedChanges = true CSPS.refreshTree() end)
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.montur = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)
			if getCurrentOutfitIndex() == outfits.current.montur then errorColor = colTbl.green end
		elseif outfits.current.montur then
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, getShiftApplyText().."\n"..GS(CSPS_QS_TT_Edit)) end
			ctrMinus:SetHidden(false)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.montur = nil CSPS.unsavedChanges = true CSPS.refreshTree() end)
			ctrUnequip:SetHidden(true)
			monturName = GS(SI_QUICKSLOTS_EMPTY)
			if getCurrentOutfitIndex() == 0 then errorColor = colTbl.green end
		else
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, GS(CSPS_QS_TT_Edit)) end
			ctrMinus:SetHidden(true)
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.montur = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)
			monturName = "-"
		end
		ctrText:SetText(string.format("%s: %s", GS(SI_OUTFIT_SELECTOR_TITLE), monturName))
		ctrIcon:SetTexture("ESOUI/art/restyle/keyboard/dyes_tabicon_outfitstyledye_up.dds")
	elseif data.isTitle then
		local title = GetTitle(outfits.current.title)
		if outfits.current.title == 0 then 
			title = GS(SI_QUICKSLOTS_EMPTY)
			ctrMinus:SetHidden(false)
			ctrUnequip:SetHidden(true)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.title = nil CSPS.unsavedChanges = true  CSPS.refreshTree() end)
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, getShiftApplyText().."\n"..GS(CSPS_QS_TT_Edit)) end
			if (GetCurrentTitleIndex() or 0) == 0 then errorColor = colTbl.green end
		elseif not outfits.current.title or title == "" then
			title = "-"
			ctrMinus:SetHidden(true)
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.title = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, GS(CSPS_QS_TT_Edit)) end
		else
			ctrMinus:SetHidden(false)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.title = nil CSPS.unsavedChanges = true  CSPS.refreshTree() end)
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.title = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)
			control.tooltipFunction = function()
				InitializeTooltip(InformationTooltip, ctrText, LEFT, 0, 0, RIGHT)
				ttAddLine(zo_strformat("<<C:1>>", title), "ZoFontWinH2")
				local achievementId = getAchievementByTitle(title)
				if achievementId then
					local achievementName, achievementDescription, _, achievementTexture = GetAchievementInfo(achievementId)
					ZO_Tooltip_AddDivider(InformationTooltip)
					ttAddLine(string.format("\n|t48:48:%s|t\n", achievementTexture))
					ttAddLine(zo_strformat("<<C:1>>", achievementName), "ZoFontWinH3")
					ttAddLine(zo_strformat("<<1>>", achievementDescription))		
				end
				ZO_Tooltip_AddDivider(InformationTooltip)	
				ttAddLine(getShiftApplyText())
				ttAddLine(GS(CSPS_QS_TT_Edit))
			end
			if GetCurrentTitleIndex() == outfits.current.title then errorColor = colTbl.green end
		end
		ctrText:SetText(string.format("%s: %s", GS(SI_STATS_TITLE), title))
		ctrIcon:SetTexture("ESOUI/art/treeicons/achievements_indexicon_general_up.dds")
	elseif data.actionFXCategory then
		local catName = GetCollectibleSubCategoryInfo(actionFXTopLevel, data.actionFXCategory)
		local currentName, currentDescription, currentIcon = "-", "", "esoui/art/actionbar/passiveabilityframe_round_empty.dds"
		local unlocked = true
		local collectibleId = outfits.current.actionFX[data.actionFXCategory]
		if collectibleId and collectibleId ~= 0 then
			currentName, currentDescription, currentIcon, _, unlocked = GetCollectibleInfo(collectibleId)
		end
		currentName = collectibleId == 0 and GS(SI_QUICKSLOTS_EMPTY) or currentName
		control.tooltipFunction = function()
			if showActionFXTooltip(ctrText, collectibleId) then 
				ttAddLine(getShiftApplyText())
				ttAddLine(GS(CSPS_QS_TT_Edit))
			else
				ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, collectibleId and getShiftApplyText().."\n"..GS(CSPS_QS_TT_Edit) or GS(CSPS_QS_TT_Edit))
			end
		end
		ctrUnequip:SetHidden(collectibleId and collectibleId == 0)
		ctrMinus:SetHidden(not collectibleId)
		ctrMinus:SetHandler("OnClicked", function() outfits.current.actionFX[data.actionFXCategory] = nil CSPS.unsavedChanges = true  CSPS.refreshTree() end)
		ctrUnequip:SetHandler("OnClicked", function() outfits.current.actionFX[data.actionFXCategory] = 0 CSPS.unsavedChanges = true  CSPS.refreshTree() end)
		ctrText:SetText(zo_strformat("<<1>>: <<C:2>>", catName, currentName))
		errorColor = not unlocked and colTbl.red or doesActionFXFit(data.actionFXCategory, collectibleId) and colTbl.green or colTbl.white
		
		ctrIcon:SetTexture(currentIcon)
	else
		local name = "-"
		local description = ""
		local textureName = "esoui/art/actionbar/passiveabilityframe_round_empty.dds"
		local slotData = outfits.current.slots[data.outfitCollectibleType]
		if slotData and slotData ~= 0 then
			name, description, textureName = GetCollectibleInfo(slotData)
			ctrMinus:SetHidden(false)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.slots[data.outfitCollectibleType] = nil CSPS.unsavedChanges = true  CSPS.refreshTree() end)
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.slots[data.outfitCollectibleType] = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)			
			control.tooltipFunction = function()
				InitializeTooltip(InformationTooltip, ctrText, LEFT, 0, 0, RIGHT)
				ttAddLine(zo_strformat("<<C:1>>", name), "ZoFontWinH2")
				ttAddLine(string.format("\n|t64:64:%s|t\n", textureName), "ZoFontGame")
				ZO_Tooltip_AddDivider(InformationTooltip)
				ttAddLine(description, "ZoFontGame")
				ZO_Tooltip_AddDivider(InformationTooltip)
				ttAddLine(getShiftApplyText())
				ttAddLine(GS(CSPS_QS_TT_Edit))
			end
		errorColor = IsCollectibleActive(slotData, GAMEPLAY_ACTOR_CATEGORY_PLAYER) and colTbl.green or colTbl.white	
		elseif slotData then
			ctrUnequip:SetHidden(true)
			ctrMinus:SetHidden(false)
			ctrMinus:SetHandler("OnClicked", function() outfits.current.slots[data.outfitCollectibleType] = nil CSPS.unsavedChanges = true  CSPS.refreshTree() end)
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, getShiftApplyText().."\n"..GS(CSPS_QS_TT_Edit)) end
			name = GS(SI_QUICKSLOTS_EMPTY)
			if GetActiveCollectibleByType(data.outfitCollectibleType, GAMEPLAY_ACTOR_CATEGORY_PLAYER) == 0 then errorColor = colTbl.green end
		else
			ctrUnequip:SetHidden(false)
			ctrUnequip:SetHandler("OnClicked", function() outfits.current.slots[data.outfitCollectibleType] = 0 CSPS.unsavedChanges = true CSPS.refreshTree() end)
			ctrMinus:SetHidden(true)
			
			control.tooltipFunction = function() ZO_Tooltips_ShowTextTooltip(ctrText, RIGHT, GS(CSPS_QS_TT_Edit)) end
		end
		ctrText:SetText(zo_strformat("<<1>>: <<C:2>>", GS("SI_COLLECTIBLECATEGORYTYPE", data.outfitCollectibleType), name))
		ctrIcon:SetTexture(textureName)
	end
	ctrText:SetColor(errorColor:UnpackRGB())
end

function CSPS.setupOutfitSection(control, node, data)
	local btnApply = control:GetNamedChild("BtnApply")
	if node:IsOpen() and not data.fillContent then
		btnApply:SetHidden(false)
		btnApply:SetWidth(21)
		btnApply:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnApply, RIGHT, GS(SI_APPLY)) end)
		btnApply:SetHandler("OnClicked", function() 	
			outfits.apply()
			zo_callLater(function() CSPS.refreshTree() end, 420)
		end)
	else
		btnApply:SetHidden(true)
	end
end

function CSPS.setupOutfitTree()
	local myTree = CSPS.getTreeControl()
	myTree:AddTemplate("CSPSOutfitLE", NodeSetupOutfit, nil, nil, 24, 0)
	local fillContent = {}
	table.insert(fillContent, {"CSPSOutfitLE", {isTitle = true}})
	table.insert(fillContent, {"CSPSOutfitLE", {isMontur = true}})
	for _, outfitCollectibleType in pairs(outfitCollectibleTypes) do
		table.insert(fillContent, {"CSPSOutfitLE", {outfitCollectibleType = outfitCollectibleType}})
	end
	local _, numActionFXCats = GetCollectibleCategoryInfo(actionFXTopLevel)
	for actionFXCategory = 1, numActionFXCats do
		table.insert(fillContent, {"CSPSOutfitLE", {actionFXCategory = actionFXCategory}})
	end
	local overNode = myTree:AddNode("CSPSLH", {name = GetCollectibleCategoryNameByCategoryId(13), isMainCat=true, variant=9, fillContent=fillContent})
end
