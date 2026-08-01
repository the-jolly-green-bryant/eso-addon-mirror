FDR = FDR or {}
FDR.name = "FavoriteDungeonRotation"
FDR.version = "1.2.0"

FDR.checkboxList = {}
FDR.selectedItems = 0

FDR.textures = {
	[true] = "/FavoriteDungeonRotation/textures/fav.dds",
	[false] = "/FavoriteDungeonRotation/textures/nonfav.dds"
}

function FDR.CheckQueueButton()
	
	local inGroup = GetGroupSize() > 0
	local isLead = AreUnitsEqual(GetGroupLeaderUnitTag(), "player")
	
	local enabled = true
	
	if (inGroup == true and isLead == false) or FDR.selectedItems == 0 then
		enabled = false
	end
	
	FDR_QueueFavButton:SetEnabled(enabled)
end

function FDR.QueueFavorites()

	ClearGroupFinderSearch()
	
	for id, dungeon in pairs(FDR.savedVariables.dungeons) do
		if dungeon.checked == true then
			AddActivityFinderSpecificSearchEntry(id)
		end
	end
	
	StartGroupFinderSearch()
end

function FDR.ToggleFavorites(checkbox, data)
	
	local checked = not FDR.savedVariables.dungeons[data.id].checked
	FDR.savedVariables.dungeons[data.id].checked = checked
	
	checkbox:SetNormalTexture(FDR.textures[checked])
	checkbox:SetPressedTexture(FDR.textures[checked])
	checkbox:SetMouseOverTexture(FDR.textures[checked])
	
	if checked == true then
		FDR.selectedItems = FDR.selectedItems + 1
	else
		FDR.selectedItems = FDR.selectedItems - 1
	end
	
	FDR.CheckQueueButton()
end

function FDR.Hooksecbtn()
	
	queueFavButton = CreateControlFromVirtual("FDR_QueueFavButton", ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton, "ZO_DefaultButton")
	queueFavButton:SetText("Queue Favorites")
	queueFavButton:SetAnchor(CENTER, ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton, TOPLEFT, -100, 14)
	queueFavButton:SetDimensions(200, 28)
	queueFavButton:SetHandler("OnClicked", function() FDR.QueueFavorites() end)
	
	-- check amount of checked boxes
	for id, dungeon in pairs(FDR.savedVariables.dungeons) do
		if dungeon.checked == true then
			FDR.selectedItems = FDR.selectedItems + 1
		end
	end
	FDR.CheckQueueButton()
	
	-- move button to make up some space for queue fav button
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains = ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton:GetAnchor(0)
	ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton:ClearAnchors()
	ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton:SetAnchor(point, relativeTo, relativePoint, offsetX + 100, offsetY)
	
	-- move lock text to original location
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains = ZO_DungeonFinder_KeyboardLockReason:GetAnchor(0)
	ZO_DungeonFinder_KeyboardLockReason:ClearAnchors()
	ZO_DungeonFinder_KeyboardLockReason:SetAnchor(point, relativeTo, relativePoint, offsetX - 100, offsetY)
end

function FDR.HookDungeonList()

	local dungeonList = DUNGEON_FINDER_KEYBOARD["navigationTree"]["templateInfo"]["ZO_ActivityFinderTemplateNavigationEntry_Keyboard"]
	local originalSetupFunction = dungeonList.setupFunction
	dungeonList.setupFunction = function(node, control, data, open)
		
		-- check if checkbox was already created. if not, do so.
		if not (FDR.checkboxList[data.id] ~= nil) then
		
			local dungeon = {}
			
			dungeon.name = data.rawName
			dungeon.checked = (FDR.savedVariables.dungeons[data.id] ~= nil and FDR.savedVariables.dungeons[data.id].checked == true) and true or false
			
			local checkbox = CreateControlFromVirtual("FDR_ListItem_" .. data.id, control, "ZO_CheckButton")
			checkbox:SetAnchor(CENTER, parent, TOPLEFT, -15, 13)
			checkbox:SetNormalTexture(FDR.textures[dungeon.checked])
			checkbox:SetPressedTexture(FDR.textures[dungeon.checked])
			checkbox:SetMouseOverTexture(FDR.textures[dungeon.checked])
			ZO_CheckButton_SetCheckState(checkbox, dungeon.checked)
			ZO_CheckButton_SetToggleFunction(checkbox, function() FDR.ToggleFavorites(checkbox, data) end)
			
			FDR.savedVariables.dungeons[data.id] = dungeon
			FDR.checkboxList[data.id] = true
		end
		
		-- create the original list
		originalSetupFunction(node, control, data, open)
	end
end

function FDR.OnAddOnLoaded(_, addonName)
	if addonName ~= FDR.name then return end
	
	local defaults = { dungeons = {}}
	FDR.savedVariables = ZO_SavedVars:NewAccountWide("FDRSV", 1, nil, defaults)
	
	FDR.HookDungeonList()
	FDR.Hooksecbtn()
	
	EVENT_MANAGER:RegisterForEvent(FDR.name, EVENT_LEADER_UPDATE, FDR.CheckQueueButton)
	EVENT_MANAGER:RegisterForEvent(FDR.name, EVENT_GROUP_MEMBER_LEFT, FDR.CheckQueueButton)
end

EVENT_MANAGER:RegisterForEvent(FDR.name, EVENT_ADD_ON_LOADED, FDR.OnAddOnLoaded)
