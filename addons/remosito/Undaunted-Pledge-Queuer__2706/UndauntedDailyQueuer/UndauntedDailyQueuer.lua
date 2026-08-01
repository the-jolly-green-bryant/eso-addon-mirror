local Addon = {}
Addon.Name = "UndauntedDailyQueuer"
Addon.DisplayName = "UndauntedDailyQueuer"
Addon.Author = "remosito"
Addon.Version = "37.0"


UDQ.savedVars = {}

UDQ.GREEN_TEXT = ZO_ColorDef:New("2DC50E")
UDQ.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)
UDQ.RED_TEXT = ZO_ColorDef:New("FF6666")
UDQ.YELLOW_TEXT = ZO_ColorDef:New("FFFF00")
UDQ.ORANGE_TEXT = ZO_ColorDef:New("FFA500")


UDQ.dungeonList = {}
UDQ.currentPledgeDungeon = 0
UDQ.visibleList = {}

UDQ.selection = {
	{ n = false, v = false,},
	{ n = false, v = false,},
	{ n = false, v = false,},
}	

UDQ.guiLines = {}


function UDQ.debug(debugtext)

	if UDQ.debugOn then
		d(debugtext)
		for activityId, i in pairs(UDQ.visibleList) do
			d(string.format("%i = %s, pos %i, n = %s, v = %s", activityId, GetActivityName(activityId), i, tostring(UDQ.selection[i]["n"]), tostring(UDQ.selection[i]["v"])))
		end
	end
end


function UDQ.toggleUDQ()
	
	UDQMainWindow:SetHidden(not UDQMainWindow:IsHidden())
	UDQ.savedVars.ishidden = UDQMainWindow:IsHidden()
end


function UDQ.moveStop(control)

  UDQ.savedVars.offsetX = control:GetLeft()
  UDQ.savedVars.offsetY = control:GetTop()
end


function UDQ.resizeStop(control)

	local x,y = control:GetDimensions()
end


function UDQ.buttonPressed(control, udnumber, diff) 

	if not control.isPressed  then
		 control:SetState(BSTATE_PRESSED)
	else
		control:SetState(BSTATE_NORMAL)
	end
	control.isPressed = not control.isPressed
	UDQ.selection[udnumber][diff] = control.isPressed
	UDQ.debug("butpresout")
end


function UDQ.openStickerBook(control,udnumber)

	local zoneid = GetActivityZoneId(UDQ.dungeonList[udnumber]:GetNormalId())
	local categoryids = LibSets.GetItemSetCollectionCategoryIds(zoneid)
	if categoryids ~= nil then 
		local categorydata = LibSets.GetItemSetCollectionCategoryData(categoryids[1])
		LibSets.OpenItemSetCollectionBookOfCategoryData(categorydata)
	else 
		d("categoryids == nil")
	end
end	


function UDQ.selectAll(diff)

	for activityId, i in pairs(UDQ.visibleList) do
		control = UDQ.guiLines[i]:GetNamedChild(diff)
		UDQ.selection[i][diff] = true
		control.isPressed = true
		control:SetState(BSTATE_PRESSED)
	end
	UDQ.debug("selallout")
end


function UDQ.deselectAll(diff)

	for activityId, i in pairs(UDQ.visibleList) do
		control = UDQ.guiLines[i]:GetNamedChild(diff)
		UDQ.selection[i][diff] = false
		control.isPressed = false
		control:SetState(BSTATE_NORMAL)
	end
	UDQ.debug("deselallout")
end


function UDQ.queueMe(control)

	local noneselected = true
	ClearGroupFinderSearch()
	for activityId, i in pairs(UDQ.visibleList) do
		if UDQ.selection[i]["n"] == true then
			noneselected = false
			AddActivityFinderSpecificSearchEntry(UDQ.dungeonList[i]:GetNormalId())
		end
		if UDQ.selection[i]["v"] == true then
			noneselected = false
			AddActivityFinderSpecificSearchEntry(UDQ.dungeonList[i]:GetVeteranId() )
		end
	end
	if not noneselected then
		StartGroupFinderSearch()
	end	
	UDQ.debug("queuemeout")
end


function dumpdoubledroppers()
	local doublezone = {}
	for i = 40, 55 do
		local zoneids = LibSets.GetItemSetCollectionZoneIds(i)
		if #zoneids == 2 then
			for j = 1,2 do
				doublezone[zoneids[j]] = zoneids
			end
		end
	end
--	for zid, zoneids in pairs(doublezone) do
--		d(string.format("@#@#@#@  %d -> %d %s / %d %s", zid, zoneids[1], GetZoneNameById(zoneids[1]), zoneids[2], GetZoneNameById(zoneids[2])))
--	end

	local setids = LibSets.GetAllSetIds()
	for setid, valb in pairs(setids) do
		local zoneids = LibSets.GetZoneIds(setid)
		if zoneids ~= nil and #zoneids == 1 and doublezone[zoneids[1]] ~= nil and LibSets.GetSetType(setid) == 6 then
			d(string.format("@#@#@#@  %d %s -> {%d, %d}", setid, GetItemSetName(setid), doublezone[zoneids[1]][1], doublezone[zoneids[1]][2]))
		end
	end
end


function UDQ.addGuiLine(i, visibleRows)

	local controlName = nil
	local control = nil
	local activityId = UDQ.dungeonList[i]:GetNormalId()
	local zoneid = GetActivityZoneId(activityId)
	local row
	controlName     = string.format("%s%d", "UDQ_UD_", visibleRows)
	if UDQ.guiLines[visibleRows] == nil then
		UDQ.guiLines[visibleRows] = CreateControlFromVirtual(controlName, WINDOW_MANAGER:GetControlByName("UDQMainWindow"), "UDQLineTemplate")
	end
	row = UDQ.guiLines[visibleRows]
	row:SetHidden(false)
	if i == 1 then 
		row:SetAnchor(TOPLEFT,WINDOW_MANAGER:GetControlByName("UDQ_Header"),TOPLEFT,6,0)
	else
		row:SetAnchor(TOPLEFT,UDQ.guiLines[visibleRows-1],BOTTOMLEFT,0,0)
	end
	row.dung = row:GetNamedChild("D")
	row.dung:SetText(UDQ.dungeonList[i]:GetName())
	row.dung:SetHandler('OnMouseEnter', function() UDQ.showUDTooltip(row.dung, i) end)
	row.dung:SetHandler('OnMouseExit', function() ClearTooltip(InformationTooltip) end)
	row.dung:SetHandler('OnMouseUp', function() UDQ.openStickerBook(row.dung,i) end)
	row.norm = row:GetNamedChild("n")
	row.norm:SetHandler('OnMouseUp', function() UDQ.buttonPressed(row.norm,visibleRows,"n") end)
	row.vet = row:GetNamedChild("v")
	row.vet:SetHandler('OnMouseUp', function() UDQ.buttonPressed(row.vet,visibleRows,"v") end)
	-- get dungeon sets and masks if we dont already have it
	if  #UDQ.DUNGEONSETS[activityId] == 0 and ( UDQ.savedVars.dungeonSets[activityId] == nil or #UDQ.savedVars.dungeonSets[activityId] == 0 ) then
		UDQ.savedVars.dungeonSets[activityId] = {}
		d(string.format("@@@@@@  DungeonQueuer was missing SetInfo for: %s", UDQ.dungeonList[i]:GetName())) 
		if LibSets.checkIfSetsAreLoadedProperly() then
			local setids = LibSets.GetAllSetIds()
			for setid, valb in pairs(setids) do
				local zoneids = LibSets.GetZoneIds(setid)
				d(string.format("@@@@@@  set   zoneid %s %s", setid, zoneid))
				d(zoneids)
				if zoneids ~= nil then 
					for j = 1,#zoneids do
						if zoneids[j] == zoneid then
							table.insert(UDQ.DUNGEONSETS[activityId], setid)
							table.insert(UDQ.savedVars.dungeonSets[activityId], setid)
						end	
					end
				end
			end
		else
			d("#### notloaded properly...nooooooooooo")
		end
	end
	-- stickerbook full?
	local numtotal = 0
	local numcollected = 0
	if #UDQ.DUNGEONSETS[activityId] > 0 then 
		for j = 1,#UDQ.DUNGEONSETS[activityId] do
			numtotal = numtotal + GetNumItemSetCollectionPieces(UDQ.DUNGEONSETS[activityId][j])
			numcollected = numcollected + GetNumItemSetCollectionSlotsUnlocked(UDQ.DUNGEONSETS[activityId][j])
		end
	elseif UDQ.savedVars.dungeonSets[activityId] ~= nil then
		for j = 1,#UDQ.savedVars.dungeonSets[activityId] do
			numtotal = numtotal + GetNumItemSetCollectionPieces(UDQ.savedVars.dungeonSets[activityId][j])
			numcollected = numcollected + GetNumItemSetCollectionSlotsUnlocked(UDQ.savedVars.dungeonSets[activityId][j])
		end
	end
	if GetCompletedQuestInfo(UDQ.ACTIVITYIDNORMAL_2_QUESTID[activityId])  ~= "" then
		if numcollected == numtotal then
			row.dung:SetColor(UDQ.GREEN_TEXT:UnpackRGBA())
		else
			row.dung:SetColor(UDQ.YELLOW_TEXT:UnpackRGBA())
		end
	else
		if numcollected == numtotal then
			row.dung:SetColor(UDQ.RED_TEXT:UnpackRGBA())
		else
			row.dung:SetColor(UDQ.ORANGE_TEXT:UnpackRGBA())				
		end
	end

end


function UDQ.addDungeon(dungeon)

	if dungeon == nil then return end
	for i = 1, #UDQ.dungeonList do
		if UDQ.dungeonList[i] == dungeon then return end
	end
	local activityId = dungeon:GetNormalId()
	local collectibleName, _, _, _, unlocked = GetCollectibleInfo(GetCollectibleIdForZone(GetZoneIndex(GetActivityZoneId(activityId))))
	if not UDQ.savedVars.hideLocked or collectibleName == "" or unlocked == true then
		table.insert(UDQ.dungeonList, dungeon)
	end
end

function UDQ.updateDungeonList()

	UDQ.dungeonList = {}
	UDQ.selection = {}
	if UDQ.savedVars.undauntedDaily then
		local pledges = UndauntedDaily.GetPledgeDungeons()
		for i = 1, #pledges do
			UDQ.addDungeon(pledges[i])
		end
	end
	if UDQ.savedVars.allDungeons then
		for key, dungeon in orderedPairs(UndauntedDaily.DUNGEONS) do
			UDQ.addDungeon(dungeon)
		end
	else
		if UDQ.savedVars.missingSkillPoints then
			for key, dungeon in orderedPairs(UndauntedDaily.DUNGEONS) do
				if GetCompletedQuestInfo(UDQ.ACTIVITYIDNORMAL_2_QUESTID[dungeon:GetNormalId()])  == "" then 
					UDQ.addDungeon(dungeon)
				end
			end
		end
		if UDQ.savedVars.incompleteStickerbook then
--			d("one fine day....")
		end
	end
	for activityId, value in orderedPairs(UDQ.savedVars.additionalDungeons) do
		if value then 
			UDQ.addDungeon(UndauntedDaily.DUNGEON_BY_ACTIVITY_ID[activityId])
		end
	end
	local visibleRows = 1
	UDQ.visibleList = {}
	for i = 1, #UDQ.dungeonList do
		local activityId = UDQ.dungeonList[i]:GetNormalId()
		local collectibleName, _, _, _, unlocked = GetCollectibleInfo(GetCollectibleIdForZone(GetZoneIndex(GetActivityZoneId(activityId))))
		if not UDQ.savedVars.hideLocked or collectibleName == "" or unlocked == true then
			if not UDQ.visibleList[activityId] then
				UDQ.addGuiLine(i, visibleRows)
				UDQ.visibleList[activityId] = visibleRows
				table.insert(UDQ.selection, { n = false, v = false,})
				visibleRows = visibleRows + 1
			end
		end
	end
	WINDOW_MANAGER:GetControlByName("UDQMainWindow"):SetDimensions(172, ( visibleRows ) * 20)	
	for i = visibleRows, #UDQ.guiLines do
		
		UDQ.guiLines[i]:SetHidden(true)
	end
	UDQ.deselectAll("n")
	UDQ.deselectAll("v")
end


function UDQ.showUDTooltip(control, udi)

	local charlist = ""
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, 0)
	InformationTooltip:AddLine(UDQ.TOOLTIP_UD)
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(UDQ.TOOLTIP_UDSK)
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(UDQ.TOOLTIP_UD_SKQAVAIL)	
	for k,v in pairs(UDQ.savedVars.chars) do
		if v["gdskillpointquests"] ~= nil then			
			if v["gdskillpointquests"][UDQ.ACTIVITYIDNORMAL_2_QUESTID[UDQ.dungeonList[udi]:GetNormalId()]] == false then
				charlist = string.format("|c2DC50E%s|r(%d),%s",v["name"],v["availskillpts"], charlist)
			end
		end
	end
	InformationTooltip:AddLine(charlist)
	InformationTooltip:AddLine(UDQ.TOOLTIP_UD_SKPAVAIL, "ZoFontGameSmall")	
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(UDQ.TOOLTIP_UD_SETSHEADER)
	local activityId = UDQ.dungeonList[udi]:GetNormalId()
	if #UDQ.DUNGEONSETS[activityId] > 0 then
		for j = 1,#UDQ.DUNGEONSETS[activityId] do
			local numtotal = GetNumItemSetCollectionPieces(UDQ.DUNGEONSETS[activityId][j])
			local numcollected = GetNumItemSetCollectionSlotsUnlocked(UDQ.DUNGEONSETS[activityId][j])
			local cost = GetItemReconstructionCurrencyOptionCost(UDQ.DUNGEONSETS[activityId][j],5)
			if cost == nil then cost = 75 end
			if numtotal > 0 then -- old sets have numtotal = 0
				if numcollected == numtotal then
					InformationTooltip:AddLine(string.format("|c2DC50E%s|r(%d/%d)[%d]", LibSets.GetSetName(UDQ.DUNGEONSETS[activityId][j]), numcollected, numtotal, cost))
				else
					InformationTooltip:AddLine(string.format("|cFFFF00%s|r(%d/%d)[%d]", LibSets.GetSetName(UDQ.DUNGEONSETS[activityId][j]), numcollected, numtotal, cost))
				end
			end
		end
	else
		for j = 1,#UDQ.savedVars.dungeonSets[activityId] do
			local numtotal = GetNumItemSetCollectionPieces(UDQ.savedVars.dungeonSets[activityId][j])
			local numcollected = GetNumItemSetCollectionSlotsUnlocked(UDQ.savedVars.dungeonSets[activityId][j])
			local cost = GetItemReconstructionCurrencyOptionCost(UDQ.savedVars.dungeonSets[activityId][j],5)
			if cost == nil then cost = 75 end
			if numtotal > 0 then -- old sets have numtotal = 0
				if numcollected == numtotal then
					InformationTooltip:AddLine(string.format("|c2DC50E%s|r(%d/%d)[%d]", LibSets.GetSetName(UDQ.savedVars.dungeonSets[activityId][j]), numcollected, numtotal, cost))
				else
					InformationTooltip:AddLine(string.format("|cFFFF00%s|r(%d/%d)[%d]", LibSets.GetSetName(UDQ.savedVars.dungeonSets[activityId][j]), numcollected, numtotal, cost))
				end
			end
		end
	end
	InformationTooltip:AddLine(UDQ.TOOLTIP_UD_SETSFOOTER, "ZoFontGameSmall")	
end


function UDQ.OnSkillPointsChange( _, _, newPts)

	UDQ.savedVars.chars[UDQ.currentCharId]["availskillpts"] = GetAvailableSkillPoints()

end


--event gives back only questname...dont know way to find questid from that 
--  -> just go through all group dungeon skill point quests again and update savedVars....
function UDQ.QuestComplete( questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)

	if questType == QUEST_TYPE_DUNGEON then
		for k,v in pairs(UDQ.ACTIVITYIDNORMAL_2_QUESTID) do
			UDQ.savedVars.chars[UDQ.currentCharId]["gdskillpointquests"][v] = ( GetCompletedQuestInfo(v) ~= "" )
		end
		UDQ.updateDungeonList()
	end
end


function UDQ.savedVarsInitializer()

	if UDQ.savedVars.additionalDungeons == nil then
		UDQ.savedVars.additionalDungeons = {}
	end	
	if UDQ.savedVars.ishidden == nil then
		UDQ.savedVars.ishidden = false
		UDQ.savedVars.offsetX = 400
		UDQ.savedVars.offsetY = 400
	end
	if UDQ.savedVars.hideLocked == nil then
		UDQ.savedVars.hideLocked = false
	end	
	if UDQ.savedVars.undauntedDaily == nil then
		UDQ.savedVars.undauntedDaily = true
	end
	if UDQ.savedVars.missingSkillPoints == nil then
		UDQ.savedVars.missingSkillPoints = false
	end
	if UDQ.savedVars.incompleteStickerbook  == nil then
		UDQ.savedVars.incompleteStickerbook  = false
	end
	if UDQ.savedVars.allDungeons  == nil then
		UDQ.savedVars.allDungeons  = false		
	end
	if UDQ.savedVars.dungeonSets  == nil then
		UDQ.savedVars.dungeonSets  = {}		
	end
end


function UDQ.checkUndauntedDailyReset() 

	local pledgeDungeons = UndauntedDaily.GetPledgeDungeons()
	if UDQ.currentPledgeDungeon ~= pledgeDungeons[1]:GetNormalId() then
		UDQ.currentPledgeDungeon = pledgeDungeons[1]:GetNormalId()
		UDQ.updateDungeonList()
	end

end

function UDQ.onLoad(eventCode, name)
	
	if name ~= Addon.Name then return end
	UDQ.savedVars = ZO_SavedVars:NewAccountWide("UDQVars", 2, nil, nil, GetWorldName(), nil)
	UDQ.savedVarsInitializer()
	UDQ.updateDungeonList()
    UDQMainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, UDQ.savedVars.offsetX, UDQ.savedVars.offsetY)
    UDQMainWindow:SetHidden(UDQ.savedVars.ishidden)
	if UDQ.savedVars.chars == nil then
		UDQ.savedVars.chars = {}
	end
	UDQ.currentCharId = GetCurrentCharacterId()
	if UDQ.savedVars.chars[UDQ.currentCharId] == nil then
		UDQ.savedVars.chars[UDQ.currentCharId] = {}
	end
	UDQ.savedVars.chars[UDQ.currentCharId]["name"] = GetUnitName("player")
	UDQ.savedVars.chars[UDQ.currentCharId]["availskillpts"] = GetAvailableSkillPoints()
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_SKILL_POINTS_CHANGED, UDQ.OnSkillPointsChange)
	if UDQ.savedVars.chars[UDQ.currentCharId]["gdskillpointquests"] == nil then
		UDQ.savedVars.chars[UDQ.currentCharId]["gdskillpointquests"] = {}
	end
	UDQ.QuestComplete()
	UDQ.CreateMenu()
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_QUEST_COMPLETE, UDQ.QuestComplete)
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
	-- feeling lazy. lets just grab undaunted dailies once every minute, instead of calculate when reset timer is....
	EVENT_MANAGER:RegisterForUpdate(Addon.Name, 60000, UDQ.checkUndauntedDailyReset)
	UDQ.updateDungeonList()
end

SLASH_COMMANDS["/udq"] = UDQ.toggleUDQ
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_UNDAUNTEDDAILYQUEUER", UDQ.KEYBINDINGTEXT)
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, UDQ.onLoad)