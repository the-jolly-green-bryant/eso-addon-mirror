local DTT = { }
DTT.DEBUG = false

DTT.itemPool = nil	-- item pool list to recycle item-controlls
DTT.list = nil	-- scrolllist

DTT.ImperialCity = nil --Kaiserstadt
DTT.Cyrodiil = nil -- Cyrodiil
DTT.ColdHarbour = nil -- Kalthafen
DTT.Craglore = nil -- Kargstein

-- selected item fom scollUiElement
DTT.accountSelected = nil
DTT.charSelected = nil
DTT.zoneSelected = nil
DTT.idSelected = nil
DTT.typSelected = nil
DTT.controlId = nil

DTT.active = false
DTT.TeleportCounter = 0

--[[ SEARCH
	search all guild members
]]--
function DTT.AvailableZones()

    local availableZones = { }
    local availableCount = 1
    local playerLevel = GetUnitLevel("player") --GetPlayerDifficultyLevel()
    local playerZone = deaglTT.Lib.CutStringAtLetter(GetPlayerLocationName(), "^")
	local playerName = GetDisplayName("player") -- returns AccountId

    for guildId = 1, GetNumGuilds() do
        if availableZones == GetNumMaps() - 2 then break end
        for memberId = 1, GetNumGuildMembers(GetGuildId(guildId)) do
            local _, charName1, memberZone, _, memberAlliance, _, _, zoneId = GetGuildMemberCharacterInfo(GetGuildId(guildId), memberId)
            local memberName, _, _, memberStatus = GetGuildMemberInfo(GetGuildId(guildId), memberId)

            --if GetUnitAlliance("player") == memberAlliance and memberStatus ~= PLAYER_STATUS_OFFLINE then
            if memberStatus ~= PLAYER_STATUS_OFFLINE then
                for mapId = 1, GetNumMaps(), 1 do
                    local zoneName = GetMapInfo(mapId)
                    local zoneExist = 0
                    local zoneInsert = 0
                    local playerInZone = 0
					
					zoneName = deaglTT.Lib.CutStringAtLetter(zoneName, "^")
					
					if DTT.DEBUG and playerName == memberName then 
						d("Self was filtered.")
					end
					--player in same zone but in city = other zone
					--and same zone => teleport to wayshrine => disabled check
                    -- remove zones, not port avail. && filter own char
                    if zoneName == DTT.ImperialCity or zoneName == DTT.Cyrodiil or playerName == memberName then playerInZone = 1 end

                    -- player in zone : ignore
                    if playerInZone ~= 1 then
                        -- zone in list : ignore
                        for i = 1, #availableZones do
                            if availableZones[i].zoneName == zoneName then
                                zoneExist = 1
                                break
                            end
                        end

						-- porting to all zones is allowed, no lvl or alliance needed
                        if zoneExist ~= 1 then -- and playerLevel and playerLevel >= 50 then
							zoneInsert = 1
						end
                    end
					
					memberZone = deaglTT.Lib.CutStringAtLetter(memberZone, "^")
					
					-- member in searching zone
					local s1 = string.match(zoneName, memberZone)
					local s2 = string.match(memberZone, zoneName)
					
                    -- zone available for port
                    if (s1 ~= nil or s2 ~= nil) and zoneExist ~= 1 and zoneInsert == 1 and playerInZone ~= 1 then
                        availableZones[availableCount] = { }
						availableZones[availableCount].zoneName = zoneName
                        availableZones[availableCount].accountName = memberName
                        availableZones[availableCount].id = memberId
                        availableZones[availableCount].charName = deaglTT.Lib.CutStringAtLetter(charName1, "^")
                        availableZones[availableCount].typ = "guild"

                        availableCount = availableCount + 1
                        break
                    end
                end
            end
        end
    end

    return availableZones
end

--[[ SEARCH
	search all friends
]]--
function DTT.AvailableFriends()
    local availableFriends = { }
    local availableCount = 1

    for findex = 1, GetNumFriends() do
        local mi = { }
        mi.name, mi.note, mi.status, mi.secsincelastseen = GetFriendInfo(findex)

        if mi.status ~= PLAYER_STATUS_OFFLINE then
            local _, characterName, zoneName, _, alliance = GetFriendCharacterInfo(findex)
			local zoneNameCutter = deaglTT.Lib.CutStringAtLetter(zoneName, "^")
			
            if zoneNameCutter ~= DTT.ImperialCity and zoneNameCutter ~= DTT.Cyrodiil then
				availableFriends[availableCount] = { }
				availableFriends[availableCount].zoneName = zoneNameCutter
				availableFriends[availableCount].accountName = deaglTT.Lib.CutStringAtLetter(mi.name, "^")
				availableFriends[availableCount].charName = deaglTT.Lib.CutStringAtLetter(characterName, "^")
				availableFriends[availableCount].id = findex
				availableFriends[availableCount].typ = "friend"

				availableCount = availableCount + 1
            end
        end
    end

    return availableFriends
end

--[[ SEARCH
	search all group members
]]--
function DTT.AvailableGroupMembers()
    local availableGroupMembers = { }
    local availableCount = 1
    local pChar = string.lower(GetUnitName("player"))

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local unitName = GetUnitName(unitTag)

        if unitTag ~= nil and IsUnitOnline(unitTag) and string.lower(unitName) ~= pChar then
            local zoneName = GetUnitZone(unitTag)
            local displayName = GetUnitDisplayName(unitTag)

            availableGroupMembers[availableCount] = { }
            availableGroupMembers[availableCount].zoneName = deaglTT.Lib.CutStringAtLetter(zoneName, "^")
            availableGroupMembers[availableCount].accountName = deaglTT.Lib.CutStringAtLetter(displayName, "^")
            availableGroupMembers[availableCount].charName = deaglTT.Lib.CutStringAtLetter(unitName, "^")
            availableGroupMembers[availableCount].id = nil
            availableGroupMembers[availableCount].typ = "group"

            availableCount = availableCount + 1
        end
    end
    return availableGroupMembers
end

--[[ EVENT 
	chat button | show and hidden
]]--
function deaglTT.Teleport.UIChatButton(button)
    if button == 1 then 
        deaglTT.Teleport.ToggleUI(DTT_Teleport:IsHidden(), true)
    end
end

--[[ Toggle teleport window from keybinding
]]--
function deaglTT.Teleport.Toggle()      
    deaglTT.Teleport.ToggleUI(DTT_Teleport:IsHidden(), true)
end

--[[ Toggle UI from keybind and close button
]]--
function deaglTT.Teleport.ToggleUI(show, abort)
	-- no view and is hidden => return
    if show == false and DTT_Teleport:IsHidden() then return end
    -- view and not hidden => return
    if show == true and not DTT_Teleport:IsHidden() then return end

    if show then
        if IsUnitInCombat("player") then return end

        DTT_Teleport:SetHidden(false)
		local currenttCost = deaglTT.Settings.Teleport.teleportCost
		
		--donate button
		DTT_Teleport_ButtonDonate:SetText(deaglTT.Color[6] .. "donate " .. deaglTT.Lib.comma_value(currenttCost) .. "g")
		DTT_Teleport_ButtonDonate:SetHandler("OnClicked", function() deaglTT.Lib.SendNote(currenttCost) end)
		
        DTT.FillScrollList()
        if not SCENE_MANAGER:IsInUIMode() then SCENE_MANAGER:SetInUIMode(true) end
        deaglTT.Teleport.Initialize()

		--player not in group hidden/disable button || is groupleader
		if GetGroupSize() <= 1 or IsUnitGroupLeader("player")then
			DTT_Teleport_ButtonGroupLeader:SetEnabled(false)
			DTT_Teleport_ButtonGroupLeader:SetAlpha(0.2)
		else
			DTT_Teleport_ButtonGroupLeader:SetEnabled(true)
			DTT_Teleport_ButtonGroupLeader:SetAlpha(1)
		end
		-- set player stats
		local playerZone = deaglTT.Lib.CutStringAtLetter(GetPlayerLocationName(), "^")
		DTT_Teleport_PlayerZone:SetText(deaglTT.Color[5] .. playerZone)

		-- set teleport starts
		DTT_Teleport_TeleportCounterSession:SetText(deaglTT.Color[5] .. deaglTT.Lib.comma_value(DTT.TeleportCounterSession))
		DTT_Teleport_TeleportCounterTotal:SetText(deaglTT.Color[5] .. deaglTT.Lib.comma_value(deaglTT.Settings.Teleport.teleportCounter))
		DTT_Teleport_TeleportCounterTotalGold:SetText(deaglTT.Color[5] .. deaglTT.Lib.comma_value(currenttCost))
    else
		-- unregister event if register : increment counter & gold
		if abort then
			if DTT.DEBUG then d("(save) Unregister event EVENT_PLAYER_DEACTIVATED from CloseAction") end
			EVENT_MANAGER:UnregisterForEvent(deaglTT.Name, EVENT_PLAYER_DEACTIVATED)
			if SCENE_MANAGER:IsInUIMode() then SCENE_MANAGER:SetInUIMode(false) end SCENE_MANAGER:SetInUIMode(false) 
		end
        DTT_Teleport:SetHidden(true)
		DTT.itemPool:ReleaseAllObjects()
		
		if DTT.DEBUG then
			local activeObjCount = DTT.itemPool:GetActiveObjectCount()
			local freeObject = DTT.itemPool:GetFreeObjectCount();
			d("ActivObjects: " .. activeObjCount .. " - FreeObjects: " .. freeObject)
		end       
    end
end

--[[ Jump to Custom House
	JumpToHouse()
--]]
function deaglTT.Teleport.TeleportToHouse()
--function deaglTT.Teleport.TeleportToHouse(houseName)
    if IsUnitInCombat("player") then return end

    if DTT.DEBUG then d("Teleport: Housing ") end
	-- chat message to jump
	deaglTT.ToChat(deaglTT.Color[6] .. "Teleport " .. deaglTT.Color[5] .. " to ".. deaglTT.Color[2] .. "House")
	--JumpToHouse(houseName)
	--if houseName == nil then
		local houseId = GetHousingPrimaryHouse()
        if houseId == nil then
            deaglTT.ToChat(deaglTT.Color[6] .. "Please set primary house in the house editor.")
        else
            RequestJumpToHouse(houseId)
        end
	--else
	--	RequestJumpToHouse(houseName)
	--end
	deaglTT.Teleport.ToggleUI(false, false)
end

--[[ Teleport to Zone
--]]
function DTT.Teleport(toGroupLeader)
	if toGroupLeader == 1 then
		deaglTT.ToChat(deaglTT.Color[6] .. "Teleport " .. deaglTT.Color[5] .. " to ".. deaglTT.Color[2] .. "GroupLeader")
		deaglTT.Teleport.ToggleUI(false, false)
		JumpToGroupLeader()
	elseif not deaglTT.Lib.IsStringEmpty(DTT.accountSelected) then
			-- close the window
			deaglTT.Teleport.ToggleUI(false, false)
			-- chat message to jump
			deaglTT.ToChat(
				deaglTT.Color[6] .. "Teleport " .. deaglTT.Color[5] .. " to " ..
				deaglTT.Color[2] .. deaglTT.Lib.CutStringAtLetter(DTT.zoneSelected, "^") ..
				deaglTT.Color[5] .. " (Char: " .. DTT.charSelected .. " Account: " .. DTT.accountSelected .. " Typ: " .. DTT.typSelected .. ")")

			-- jump
			if DTT.typSelected == "friend" then JumpToFriend(DTT.accountSelected)
				elseif DTT.typSelected == "group" then JumpToGroupMember(DTT.accountSelected)
				elseif DTT.typSelected == "guild" then JumpToGuildMember(DTT.accountSelected)
			end
	end
	
	-- event for deactived player => teleport, loadscreen, ...
	if DTT.DEBUG then d("Register event EVENT_PLAYER_DEACTIVATED") end
	EVENT_MANAGER:RegisterForEvent(deaglTT.Name, EVENT_PLAYER_DEACTIVATED, 
		function(eventcode)
			if DTT.DEBUG then d("Fire event EVENT_PLAYER_DEACTIVATED") end
			DTT.IncrementTeleportCounter(GetRecallCost())
		end)
end

--[[ EVENT
	Add +1 to some stat counter & teleport gold
--]]
function DTT.IncrementTeleportCounter(cost)
	-- unregister event for deactivated player => teleport, loadscreen
	EVENT_MANAGER:UnregisterForEvent(deaglTT.Name, EVENT_PLAYER_DEACTIVATED)
	if DTT.DEBUG then d("Unregister event EVENT_PLAYER_DEACTIVATED from TeleportAction") end
	if DTT.DEBUG then d("Add " .. cost .. "g to TeleportTotalCost") end
	DTT.TeleportCounterSession = DTT.TeleportCounterSession + 1
	deaglTT.Settings.Teleport.teleportCounter = deaglTT.Settings.Teleport.teleportCounter + 1
	deaglTT.Settings.Teleport.teleportCost = deaglTT.Settings.Teleport.teleportCost + cost
end

--[[ ScrollList: create list items
--]]
function DTT.CreateListItem(itemPool)
	-- ZO_ObjectPool_CreateControl(templateName, objectPool, parentControl)
    local control = ZO_ObjectPool_CreateControl("DTT_Teleport_Index", itemPool, DTT.list.scrollChild)
    
	-- count of activ items in list
	local activObjects = DTT.itemPool:GetActiveObjectCount()
	if(activObjects == 0) then
		-- if 0 then scolllist as parent for anchor
		local anchorBtn = DTT.list.scrollChild
		control:SetAnchor(TOPLEFT, anchorBtn, TOPLEFT)
	else
		-- else last button as anchor
		local anchorBtn = itemPool:AcquireObject(activObjects)
		control:SetAnchor(TOPLEFT, anchorBtn, BOTTOMLEFT)
	end
	
    control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    control:SetWidth(130)
    control:SetHandler("OnClicked", function(self)
        DTT.accountSelected = self.player
        DTT.charSelected = self.charName
        DTT.zoneSelected = self.zone
        DTT.idSelected = self.id
        DTT.typSelected = self.typ
		DTT.controlId = self.controlId
        DTT.selected:SetHidden(false)
        DTT.selected:ClearAnchors()
        DTT.selected:SetAnchorFill(self)
    end)

	if DTT.DEBUG then
		control:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, deaglTT.Color[5] .. self.player .. " (" .. self.zone .. ") (Id:".. self.controlId.. ")") end)
	else
		control:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, deaglTT.Color[5] .. self.player .. " (" .. self.zone .. ")") end)
	end
    control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
    return control
end

--[[ ScrollList: release the items (hidden, because no way to remove an item) 
]]--
function DTT.ReleaseListItem(control)
    control:SetHidden(true)
end

--[[ ScrollList: aks and fill available zones & members
]]--
function DTT.FillScrollList()
    local data = { }
    -- guild zone member
    local zones = DTT.AvailableZones()
    -- friends
    local friends = DTT.AvailableFriends()
    -- group member
    local groups = DTT.AvailableGroupMembers()

    -- sort all single tables
    local memberSort = function(a, b) return a.charName < b.charName end
    local zoneSort = function(a, b) return a.zoneName < b.zoneName end
    table.sort(groups, memberSort)
    table.sort(zones, zoneSort)
    table.sort(friends, memberSort)

    -- merge all single tables to one
    data = deaglTT.JoinMyTables(groups, zones)
    data = deaglTT.JoinMyTables(data, friends)

	-- release all itemControl
	DTT.itemPool:ReleaseAllObjects()
		
    for i = 1, #data do
		--if a control with this id # doesn't exist yet, create it, otherwise just return the one we have
        local control = DTT.itemPool:AcquireObject(i)
        control.player = data[i].accountName
		control.charName = data[i].charName
        control.zone = data[i].zoneName
        control.typ = data[i].typ
		control.controlId = i
		
		-- set the control visible text
        if DTT.DEBUG then
			if data[i].typ == "friend" then control:SetText(deaglTT.Color[1] .. i.."-" .. data[i].charName)
			elseif data[i].typ == "group" then control:SetText(deaglTT.Color[3] .. i.. "-" .. data[i].charName)
			elseif data[i].typ == "guild" then control:SetText(deaglTT.Color[5] .. i.. "-" .. data[i].zoneName)
			end
		else
			if data[i].typ == "friend" then control:SetText(deaglTT.Color[1] .. data[i].charName)
			elseif data[i].typ == "group" then control:SetText(deaglTT.Color[3] .. data[i].charName)
			elseif data[i].typ == "guild" then control:SetText(deaglTT.Color[5] .. data[i].zoneName)
			end
		end
        control:SetHidden(false)
    end

	-- if more items controls as in dataTable, then release (hidden) it
    local activeObjCount = DTT.itemPool:GetActiveObjectCount()
    if DTT.DEBUG then
		local freeObject = DTT.itemPool:GetFreeObjectCount();
		d("ActivObjects: " .. activeObjCount .. " - FreeObjects" .. freeObject .. " - DataObjects: " .. #data)
	end
	if activeObjCount > #data then
        for i = #data + 1, activeObjCount 
			do DTT.itemPool:ReleaseObject(i) 
		end
    end
end

--[[ Initialize
]]--
function deaglTT.Teleport.Initialize()
    if DTT.active == true then return false end

    ZO_ChatWindowOptions:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -50, 6)
    DTT_ZO_ToogleButton:SetParent(ZO_ChatWindowOptions:GetParent())

    DTT.ImperialCity = deaglTT.Lib.CutStringAtLetter(GetMapInfo(26), "^")
    DTT.Cyrodiil = deaglTT.Lib.CutStringAtLetter(GetMapInfo(14), "^")
    DTT.ColdHarbour = deaglTT.Lib.CutStringAtLetter(GetMapInfo(23), "^")
    DTT.Craglore = deaglTT.Lib.CutStringAtLetter(GetMapInfo(25), "^")

    -- UI Elemente
    deaglTT.Lib.MoveWindow(DTT_Teleport, "Teleport")
    deaglTT.Lib.SetWindowPos(DTT_Teleport, "Teleport")

    deaglTT.Lib.SetTitleUI(DTT_Teleport_Title)
    deaglTT.Lib.SetVersionUI(DTT_Teleport_Version)
    deaglTT.Lib.SetStdColor(DTT_Teleport_Line)

    DTT_Teleport_ButtonTeleport:SetText(deaglTT.Color[5] .. deaglTT.lang.Teleport.Teleport)
    DTT_Teleport_ButtonGroupLeader:SetText(deaglTT.Color[3] .. deaglTT.lang.Teleport.GroupLeader)
    DTT_Teleport_ButtonHouse:SetText(deaglTT.Color[3] .. deaglTT.lang.Teleport.House)
    DTT_Teleport_ButtonRefresh:SetText(deaglTT.Color[6] .. deaglTT.lang.Teleport.New)
    
	DTT_Teleport_TeleportCounterLable:SetText(deaglTT.Color[6] .. deaglTT.lang.Teleport.CountTeleportsLable)
	DTT_Teleport_TeleportCounterSessionLable:SetText(deaglTT.Color[5] .. deaglTT.lang.Teleport.CountTeleportsSession)
	DTT_Teleport_TeleportCounterTotalLable:SetText(deaglTT.Color[5] .. deaglTT.lang.Teleport.CountTeleportsSum)
	
	DTT_Teleport_SlashCommandInfo:SetText(deaglTT.Color[6] .. deaglTT.lang.Teleport.SlashCommands)
	DTT_Teleport_ShowInfo:SetText(deaglTT.Color[5] .. deaglTT.lang.Teleport.Commands)
	
    DTT_Teleport_ButtonTeleport:SetHandler("OnClicked", function() DTT.Teleport() end)
    DTT_Teleport_ButtonGroupLeader:SetHandler("OnClicked", function() DTT.Teleport(1) end)
    DTT_Teleport_ButtonHouse:SetHandler("OnClicked", function() deaglTT.Teleport.TeleportToHouse() end)
    DTT_Teleport_ButtonRefresh:SetHandler("OnClicked", function()
        DTT.FillScrollList()
    end )
	 
    DTT.closeTeleportButton = deaglTT.Lib.CreateCloseButton(DTT_Teleport_Close, DTT_Teleport, 
        function ()
            deaglTT.Teleport.ToggleUI(false, true)
        end)
	-- CreateBlueLine(name, parent, parent2, offsetX, offsetY) 
    DTT.divider3 = deaglTT.Lib.CreateBlueLine("DTT_Teleport_Divider", DTT_Teleport, DTT_Teleport_Line, 150, 10, -10)

    -- Scrollcontainer + UI
	-- :New(createItem, releaseItem)
    DTT.itemPool = ZO_ObjectPool:New(DTT.CreateListItem, DTT.ReleaseListItem)
	--CreateUIList(name, width, parent, parent2, offsetX, offsetY, offsetY2)
    DTT.list = deaglTT.Lib.CreateUIList("DTT_Teleport_List", 140, DTT_Teleport, DTT_Teleport_Line, 10, 30, -10)

    DTT.selected = WINDOW_MANAGER:CreateControl(nil, DTT.list.scrollChild, CT_TEXTURE)
    DTT.selected:SetTexture("EsoUI\\Art\\Buttons\\generic_highlight.dds")
    deaglTT.Lib.SetStdColor(DTT.selected)
    DTT.selected:SetHidden(true)
    DTT_Teleport:SetDrawLayer(1)

	if(DTT.TeleportCounterSession == nil) then DTT.TeleportCounterSession = 0	end
	if(deaglTT.Settings.Teleport.teleportCounter == nil) then deaglTT.Settings.Teleport.teleportCounter = 0 end
	if(deaglTT.Settings.Teleport.teleportCost == nil) then deaglTT.Settings.Teleport.teleportCost = 0 end

	-- raise event: player in combat mode
	EVENT_MANAGER:RegisterForEvent(deaglTT.Name, EVENT_PLAYER_COMBAT_STATE,
	function(event, inCombat) 
		if(inCombat) then
			deaglTT.Teleport.ToggleUI(false, true)
		end
	end)
	-- raise event: player moved
	EVENT_MANAGER:RegisterForEvent(deaglTT.Name, EVENT_NEW_MOVEMENT_IN_UI_MODE, 
		function(event)
			deaglTT.Teleport.ToggleUI(false, true) 
		end)
		
	DTT.active = true
end

