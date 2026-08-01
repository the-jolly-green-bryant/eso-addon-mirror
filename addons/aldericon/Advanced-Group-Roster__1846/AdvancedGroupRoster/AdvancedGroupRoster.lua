
function SharedChatSystem:ShowPlayerContextMenu(playerName, rawName)
    ClearMenu()

    local otherPlayerIsDecoratedName = IsDecoratedDisplayName(playerName)
    local localPlayerIsGrouped = IsUnitGrouped("player")
    local localPlayerIsGroupLeader = IsUnitGroupLeader("player")
    local otherPlayerIsInPlayersGroup = IsPlayerInGroup(rawName)

    if IsGroupModificationAvailable() then
        if not localPlayerIsGrouped or (localPlayerIsGroupLeader and not otherPlayerIsInPlayersGroup) then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_GROUP), function() 
            local SENT_FROM_CHAT = false
            local DISPLAY_INVITED_MESSAGE = true
            TryGroupInviteByName(playerName, SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE) end)
        elseif otherPlayerIsInPlayersGroup and localPlayerIsGroupLeader then
            AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_REMOVE_GROUP), function() GroupKickByName(rawName) end)
        end
    end

    local function IgnoreSelectedPlayer()
        if not IsIgnored(rawName) then
            AddIgnore(playerName)
        end
    end

    AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() self:StartTextEntry(nil, CHAT_CHANNEL_WHISPER, playerName) end)

    if(not IsIgnored(rawName)) then
        AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE), IgnoreSelectedPlayer)
    end

    if(not IsFriend(rawName)) then
        AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_ADD_FRIEND), function() ZO_Dialogs_ShowDialog("REQUEST_FRIEND", {name = rawName}) end)
    end

    AddMenuItem(zo_strformat(SI_CHAT_PLAYER_CONTEXT_REPORT, rawName), function()
        ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(playerName, IgnoreSelectedPlayer)
    end)

	if localPlayerIsGrouped == true and localPlayerIsGroupLeader == false and otherPlayerIsInPlayersGroup == false then
		AddMenuItem('Invite Player (SL)', function() CHAT_SYSTEM:StartTextEntry('invite ' .. playerName, CHAT_CHANNEL_PARTY) end)
	end

    if(ZO_Menu_GetNumMenuItems() > 0) then
        ShowMenu()
    end
end

function GROUP_LIST:GroupListRow_OnMouseUp(control, button, upInside)
    if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then
        ClearMenu()

        local data = ZO_ScrollList_GetData(control)

        if data then
			local unitTag = data.unitTag
			local displayName = data.displayName

			if AdvancedGroupRoster.sortRoster() == true then
				displayName = AdvancedGroupRoster.sortedRosterKeys[data.index]
				data = AdvancedGroupRoster.sortedGroupRoster[displayName]
				unitTag = AdvancedGroupRoster.findGroupUnitTag(displayName)
			end
		
            if data.isPlayer then
                AddMenuItem(GetString(SI_GROUP_LIST_MENU_LEAVE_GROUP), function() ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG") end)
            elseif data.online then
                if IsChatSystemAvailableForCurrentPlatform() then
                    AddMenuItem(GetString(SI_SOCIAL_LIST_PANEL_WHISPER), function() StartChatInput("", CHAT_CHANNEL_WHISPER, data.characterName) end)
                end

                AddMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function() JumpToHouse(data.displayName) end)
                AddMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function() JumpToGroupMember(data.characterName) end)
            end

            if IsGroupModificationAvailable() then
                local modicationRequiresVoting = DoesGroupModificationRequireVote()

                if GROUP_LIST.playerIsLeader then
                    if data.isPlayer then
                        if not modicationRequiresVoting then
                            AddMenuItem(GetString(SI_GROUP_LIST_MENU_DISBAND_GROUP), function() ZO_Dialogs_ShowDialog("GROUP_DISBAND_DIALOG") end)
                        end
                    else
                        if not modicationRequiresVoting then
                            AddMenuItem(GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP), function() GroupKick(unitTag) end)
                        end
                    end
                end

                --Cannot vote for yourself
                if modicationRequiresVoting and not data.isPlayer then
                    AddMenuItem(GetString(SI_GROUP_LIST_MENU_VOTE_KICK_FROM_GROUP), function() BeginGroupElection(GROUP_ELECTION_TYPE_KICK_MEMBER, ZO_GROUP_ELECTION_DESCRIPTORS.NONE, unitTag) end)
                end
            end

            --Per design, promoting doesn't expressly fall under the mantle of "group modification"
            if GROUP_LIST.playerIsLeader and not data.isPlayer and data.online then
                AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function() GroupPromote(unitTag) end)
            end

			-- AGR code
			if data.isPlayer == false then
				if AdvancedGroupRoster.SV.listSecLeaders[displayName] ~= nil and AdvancedGroupRoster.SV.listSecLeaders[displayName] == true then
					AddMenuItem('Remove Secondary Leader', function() AdvancedGroupRoster:unmakeSecondaryLeader(displayName) end)
				else
					AddMenuItem('Add Secondary Leader', function() AdvancedGroupRoster:makeSecondaryLeader(displayName) end)
				end

				if GROUP_LIST.playerIsLeader == false then
					AddMenuItem('Kick Player (SL)', function() CHAT_SYSTEM:StartTextEntry('kick ' .. displayName, CHAT_CHANNEL_PARTY) end)
					AddMenuItem('Promote Player (SL)', function() CHAT_SYSTEM:StartTextEntry('promote ' .. displayName, CHAT_CHANNEL_PARTY) end)
				end
			end

			if AdvancedGroupRoster.rosterStatus[displayName] ~= nil then
				if AdvancedGroupRoster.rosterStatus[displayName].isAway == true then
					AddMenuItem('Clear AFK Status', function() AdvancedGroupRoster.clearAwayMessage(displayName) d("Cleared away status for: "..displayName) end)
				end
			end

            GROUP_LIST:ShowMenu(control)
        end
    end
end

function AdvancedGroupRoster:makeSecondaryLeader(displayName)
	AdvancedGroupRoster.SV.secLeaders = AdvancedGroupRoster.SV.secLeaders .. '\n' .. displayName
	AdvancedGroupRoster.BuildSecondaryLeaders()
end

function AdvancedGroupRoster:unmakeSecondaryLeader(displayName)
	local lines = AdvancedGroupRoster.Explode("\n", AdvancedGroupRoster.SV.secLeaders)

	for lineIndex=#lines, 1, -1 do
		local leader = lines[lineIndex]

		if not (leader) or leader == displayName then
			table.remove(lines, lineIndex)
			AdvancedGroupRoster.SV.listSecLeaders[leader] = false
		else
			AdvancedGroupRoster.SV.listSecLeaders[leader] = true
		end
	end

	AdvancedGroupRoster.SV.secLeaders = table.concat(lines, "\n")
end

function AdvancedGroupRoster.OnGroupScroll()
	if ZO_GroupListList:IsHidden() == false then
		if GetGroupSize() > 20 then
			zo_callLater(AdvancedGroupRoster.UpdateGroupList, 500)
		end
	end
end

-- Whenever a player joines or leaves group
function AdvancedGroupRoster.OnGroupPlayerChange(memberCharacterName)
	if AdvancedGroupRoster.SV.trackGroupStatus == false then
		return
	end

	AdvancedGroupRoster.clearAwayMessage(memberCharacterName)
end

function AdvancedGroupRoster.OnGroupPlayerEnter(eventCode, memberCharacterName)
	local memberCharacterName = zo_strformat("<<1>>", memberCharacterName)

	AdvancedGroupRoster.OnGroupPlayerChange(memberCharacterName)
	AdvancedGroupRoster.InitializePlayerArray(memberCharacterName)
	AdvancedGroupRoster.UpdateTimeInGroup(memberCharacterName)
end

function AdvancedGroupRoster.OnGroupPlayerLeave(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	local memberCharacterName = zo_strformat("<<1>>", memberCharacterName)

	AdvancedGroupRoster.OnGroupPlayerChange(memberCharacterName)
	AdvancedGroupRoster.UpdateTimeInGroup(memberCharacterName)

	if isLocalPlayer then
        AdvancedGroupRoster.kickTable = {}
    else
        local unitName = GetUnitName(unitTag):gsub("%^.+", "")
        AdvancedGroupRoster.kickTable[unitName] = nil
    end
end

function AdvancedGroupRoster.UpdateRowColors()
	if AdvancedGroupRoster.SV.sameLocColors == AdvancedGroupRoster.defaultRowColor then
		return
	end

	if ZO_GroupListList:IsHidden() == false then
		for _,control in pairs(ZO_GroupListList.activeControls) do
			local characterNameControl = control:GetNamedChild("CharacterName")
			local zoneControl = control:GetNamedChild("Zone")
			local lvlControl = control:GetNamedChild("Level")

			if AdvancedGroupRoster.playerZone == control.dataEntry.data.formattedZone then
				zoneControl:SetColor(unpack(AdvancedGroupRoster.SV.sameLocColors))
			else
				zoneControl:SetColor(unpack(AdvancedGroupRoster.defaultRowColor))
			end
			
			characterNameControl:SetColor(unpack(AdvancedGroupRoster.defaultRowColor))
			lvlControl:SetColor(unpack(AdvancedGroupRoster.defaultRowColor))
		end
	end
end

-- Everytime the user 'loads', either by transitioning between zones or just reloading
function AdvancedGroupRoster.OnPlayerActivated(eventCode, initial)
	AdvancedGroupRoster.playerInPvP = IsPlayerInAvAWorld()
	AdvancedGroupRoster.playerName = zo_strformat("<<1>>", GetUnitName('player'))
	AdvancedGroupRoster.playerZone = zo_strformat(SI_SOCIAL_LIST_LOCATION_FORMAT, GetUnitZone('player'))
	AdvancedGroupRoster.EditRosterHeader()

	if AdvancedGroupRoster.SV.raidAttendance == false then
		return
	end

	AdvancedGroupRoster.ExportRaidAttendance(true)
end

-- modifies the roster header
function AdvancedGroupRoster.EditRosterHeader()
	local displayNameLabel = ZO_GroupListHeadersDisplayName

	if AdvancedGroupRoster.SV.utilizeGroupNotes == true then
		if AdvancedGroupRoster.SV.useUserId == 3 then
			ZO_GroupListHeadersZone:SetDimensions(50, AdvancedGroupRoster.columnHeight)
		else
			ZO_GroupListHeadersZone:SetDimensions(100, AdvancedGroupRoster.columnHeight)
		end

		ZO_GroupListHeadersClass:SetDimensions(50, AdvancedGroupRoster.columnHeight)
	elseif AdvancedGroupRoster.SV.useUserId == 3 then
		ZO_GroupListHeadersZone:SetDimensions(60, AdvancedGroupRoster.columnHeight)
	elseif AdvancedGroupRoster.SV.useUserId == 2 or AdvancedGroupRoster.SV.useUserId == 1 then
		ZO_GroupListHeadersZone:SetDimensions(120, AdvancedGroupRoster.columnHeight)
		ZO_GroupListHeadersClass:SetDimensions(50, AdvancedGroupRoster.columnHeight)
	end
	
	if AdvancedGroupRoster.SV.useUserId == 3 then
		ZO_GroupListHeadersCharacterName:SetText("USERID")

		if displayNameLabel == nil then
			displayNameLabel = WINDOW_MANAGER:CreateControl(ZO_GroupListHeaders:GetName() .. "DisplayName", ZO_GroupListHeaders, CT_LABEL)
			displayNameLabel:SetFont("ZoFontHeader")
			displayNameLabel:SetColor(0.77, 0.76, 0.62, 1)
			displayNameLabel:SetDimensions(AdvancedGroupRoster.characterWidth, AdvancedGroupRoster.columnHeight)
			displayNameLabel:SetAnchor(LEFT, ZO_GroupListHeadersCharacterName, RIGHT, 0)
			displayNameLabel:SetText("USERID")
			displayNameLabel:SetVerticalAlignment(TOP)
		end

		displayNameLabel:SetHidden(false)
		ZO_GroupListHeadersCharacterName:SetDimensions(AdvancedGroupRoster.characterWidth, AdvancedGroupRoster.columnHeight)
		ZO_GroupListHeadersZone:ClearAnchors()
		ZO_GroupListHeadersZone:SetAnchor(2, displayNameLabel, 8, 0)
		ZO_GroupListHeadersZone:SetText("LOC.")

		ZO_GroupListHeadersCharacterName:SetText("CHARACTER")
	elseif AdvancedGroupRoster.SV.useUserId == 2 then
		ZO_GroupListHeadersCharacterName:SetText("USERID")
	end

	if AdvancedGroupRoster.SV.useUserId == 2 or AdvancedGroupRoster.SV.useUserId == 1 then
		ZO_GroupListHeadersCharacterName:SetDimensions(AdvancedGroupRoster.normalCharacterWidth, AdvancedGroupRoster.columnHeight)

		if displayNameLabel ~= nil then
			displayNameLabel:SetHidden(true)
		end

		ZO_GroupListHeadersZone:ClearAnchors()
		ZO_GroupListHeadersZone:SetAnchor(2, ZO_GroupListHeadersCharacterName, 8, 0)
		ZO_GroupListHeadersZone:SetText("LOCATION")

		if AdvancedGroupRoster.SV.useUserId == 1 then
			ZO_GroupListHeadersCharacterName:SetText("CHARACTER NAME")
		end
	end

	if (AdvancedGroupRoster.SV.pvpRankLevel == 2 and AdvancedGroupRoster.playerInPvP == true) or AdvancedGroupRoster.SV.pvpRankLevel == 3 then
		ZO_GroupListHeadersLevel:SetText("RANK")
	elseif AdvancedGroupRoster.SV.allianceIcon == true then
		ZO_GroupListHeadersLevel:SetText("ALLIANCE")
	else
		ZO_GroupListHeadersLevel:SetText("LVL")
	end
end

function AdvancedGroupRoster.sortRosterRow(control)
	local displayName = AdvancedGroupRoster.sortedRosterKeys[control.dataEntry.data.index]
	
	if displayName == nil then
		return
	end
	
	local info = AdvancedGroupRoster.sortedGroupRoster[displayName]
	
	if info == nil then
		return
	end

	-- Column 1, Leader / Me
	updateLeader(control, info.isLeader, info.isPlayer, displayName)
	
	-- Column 2, USERID / Character Name
	updateCharacterName(control, info.index, info.nameToolTip, info.name)
	
	-- Possible column 2A, USERID / Character Name
	updateDisplayName(control, displayName)
	
	-- Column 3, LOCATION
	updateLocation(control, info.location)

	-- Column 4, Class
	updateClass(control, info.classId)

	-- Column 5, LVL / PVP Rank / Alliance
	updateLevel(control, info.pvpRank, info.alliance, info.championPoints, info.level)
	
	-- Column 6, Role
	updateRole(control, info.isHeal, info.isDps, info.isTank)
	
	-- Possible column 7, notes
	updateNotes(control, displayName)
end

function updateLeader(control, isLeader, isPlayer, displayName)
	local leaderIconControl = control:GetNamedChild("LeaderIcon")
	leaderIconControl:SetTexture('EsoUI/Art/LFG/LFG_leader_icon.dds')
	leaderIconControl:SetHidden(not isLeader)

	local addAwayMessage = false
	
	if AdvancedGroupRoster.SV.markSelf == true and isPlayer == true then
		leaderIconControl:SetHidden(false)
		leaderIconControl:SetTexture(GetAvARankIcon(41))
		leaderIconControl:SetColor(1, 1, 1, 1)

		if AdvancedGroupRoster.rosterStatus[displayName] ~= nil then
			if AdvancedGroupRoster.rosterStatus[displayName].isAway == true then
				leaderIconControl:SetColor(1, 0, 0, 1)
				addAwayMessage = true
			end
		end
	elseif AdvancedGroupRoster.rosterStatus[displayName] ~= nil then
		if control.dataEntry.data.leader == true then
			if AdvancedGroupRoster.rosterStatus[displayName].isAway == true then
				leaderIconControl:SetColor(1, 0, 0, 1)
				addAwayMessage = true
			else
				leaderIconControl:SetColor(1, 1, 1, 1)
			end
		elseif AdvancedGroupRoster.rosterStatus[displayName].isAway == true then
			leaderIconControl:SetHidden(false)
			leaderIconControl:SetTexture(GetPlayerStatusIcon(PLAYER_STATUS_AWAY))
			addAwayMessage = true
		end
	end
	
	if addAwayMessage == true then
		local awayToolTipStr = 'Away'

		if AdvancedGroupRoster.rosterStatus[displayName].message ~= '' then
			awayToolTipStr = awayToolTipStr .. "\r\nMessage: '" .. AdvancedGroupRoster.rosterStatus[displayName].message .. "'"
		end

		if AdvancedGroupRoster.rosterStatus[displayName].timer ~= '' then
			awayToolTipStr = awayToolTipStr .. "\r\nWent Away At: " .. AdvancedGroupRoster.rosterStatus[displayName].timer
		end

		leaderIconControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, awayToolTipStr); ZO_GroupListRow_OnMouseEnter(control); end);
		leaderIconControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	else
		leaderIconControl:SetHandler("OnMouseEnter", function (self) end);
		leaderIconControl:SetHandler("OnMouseExit", function () end);
	end
end

function updateCharacterName(control, index, toolTip, name)
	local characterNameControl = control:GetNamedChild("CharacterName")
	characterNameControl:SetColor(unpack(AdvancedGroupRoster.defaultRowColor))
	characterNameControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	characterNameControl:SetText(index..". "..name)
end

function updateDisplayName(control, displayName)
	local displayNameControl = control:GetNamedChild("DisplayName")

	if AdvancedGroupRoster.SV.useUserId == 3 then
		displayNameControl:SetHidden(false)
		displayNameControl:SetText(displayName)
	elseif AdvancedGroupRoster.SV.useUserId == 1 or AdvancedGroupRoster.SV.useUserId == 2 then
		if displayNameControl ~= nil then
			displayNameControl:SetHidden(true)
		end
	end
end

function updateLocation(control, location)
	local zoneControl = control:GetNamedChild("Zone")

	if AdvancedGroupRoster.playerZone == location then
		zoneControl:SetColor(unpack(AdvancedGroupRoster.SV.sameLocColors))
	else
		zoneControl:SetColor(unpack({0.46274510025978, 0.73725491762161, 0.76470589637756, 1}))
	end
	
	zoneControl:SetText(location)
	zoneControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, location); ZO_GroupListRow_OnMouseEnter(control); end);
	zoneControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
end

function updateClass(control, classId)
	local classControl2 = control:GetNamedChild("Class2")
	local _, _, _, _, _, _, texture, _, _, _ = GetClassInfo(GetClassIndexById(classId))
	classControl2:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetClassName(GENDER_NEUTER, classId)); ZO_GroupListRow_OnMouseEnter(control); end);
	classControl2:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	classControl2:SetNormalTexture(texture)
end

function updateLevel(control, rankNum, unitAlliance, championPoints, level)
	local lvlControl = control:GetNamedChild("Level")
	lvlControl:SetColor(unpack(AdvancedGroupRoster.defaultRowColor))
	
	local championControl = control:GetNamedChild("Champion")
	local championControl2 = control:GetNamedChild("Champion2")
	
	if championControl2 == nil then
		championControl2 = WINDOW_MANAGER:CreateControl(control:GetName() .. "Champion2", control, CT_BUTTON)
		championControl2:SetDimensions(30, AdvancedGroupRoster.columnHeight)
		championControl2:SetAnchor(LEFT, lvlControl, LEFT, -5)
	end
	
	championControl:SetHidden(true)
	
	if (AdvancedGroupRoster.SV.pvpRankLevel == 2 and AdvancedGroupRoster.playerInPvP == true) or AdvancedGroupRoster.SV.pvpRankLevel == 3 then
		championControl2:SetNormalTexture(GetAvARankIcon(rankNum))
		lvlControl:SetText(rankNum)
	elseif AdvancedGroupRoster.SV.allianceIcon == true then
		local alliance = ''

		if unitAlliance == 1 then -- AD
			alliance = 'AD'
		elseif unitAlliance == 2 then -- EP
			alliance = 'EP'
		elseif unitAlliance == 3 then -- DC
			alliance = 'DC'
		end

		championControl2:SetNormalTexture(GetAllianceSymbolIcon(unitAlliance))
		lvlControl:SetText(alliance)
	else
		if championPoints <= 0 then
			lvlControl:SetText(level)
			championControl2:SetNormalTexture('esoui/art/fx/texture/blacksquare.dds')
		else
			lvlControl:SetText(championPoints)
			championControl2:SetNormalTexture('esoui/art/mainmenu/menubar_champion_down.dds')
		end
	end
end

function updateRole(control, isHeal, isDps, isTank)
	local healControl = control:GetNamedChild("RoleHeal")

	if isHeal == true then
		healControl:SetTexture('esoui/art/lfg/lfg_healer_down.dds')
		healControl:SetColor(unpack(AdvancedGroupRoster.SV.healColors))
		healControl:SetHidden(false)
	else
		healControl:SetTexture('esoui/art/lfg/lfg_healer_disabled.dds')
		healControl:SetColor(1, 1, 1, 1)

		if AdvancedGroupRoster.SV.showRoles == true then
			healControl:SetHidden(true)
		else
			healControl:SetHidden(false)
		end
	end

	local dpsControl = control:GetNamedChild("RoleDPS")

	if isDps == true then
		dpsControl:SetTexture('esoui/art/lfg/lfg_dps_down.dds')
		dpsControl:SetColor(unpack(AdvancedGroupRoster.SV.dpsColors))
		dpsControl:SetHidden(false)
	else
		dpsControl:SetTexture('esoui/art/lfg/lfg_dps_disabled.dds')
		dpsControl:SetColor(1, 1, 1, 1)
		
		if AdvancedGroupRoster.SV.showRoles == true then
			dpsControl:SetHidden(true)
		else
			dpsControl:SetHidden(false)
		end
	end

	local tankControl = control:GetNamedChild("RoleTank")

	if isTank == true then
		tankControl:SetTexture('esoui/art/lfg/lfg_tank_down.dds')
		tankControl:SetColor(unpack(AdvancedGroupRoster.SV.tankColors))
		tankControl:SetHidden(false)
	else
		tankControl:SetTexture('esoui/art/lfg/lfg_tank_disabled.dds')
		tankControl:SetColor(1, 1, 1, 1)
		
		if AdvancedGroupRoster.SV.showRoles == true then
			tankControl:SetHidden(true)
		else
			tankControl:SetHidden(false)
		end
	end
end

function updateNotes(control, displayName)
	if AdvancedGroupRoster.SV.utilizeGroupNotes == false then
		return
	end

	local noteControl = control:GetNamedChild("Note")

	local groupRosterNote = ''
		
	if AdvancedGroupRoster.SV.groupRoster[displayName] ~= nil then
		groupRosterNote = AdvancedGroupRoster.SV.groupRoster[displayName]
	end
		
	if groupRosterNote ~= '' then
		noteControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, groupRosterNote); ZO_GroupListRow_OnMouseEnter(control); end);
		noteControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	else
		noteControl:SetHandler("OnMouseEnter", function (self) end);
		noteControl:SetHandler("OnMouseExit", function () end);
	end

	noteControl:SetHandler("OnClicked", function (self) AdvancedGroupRoster.onNoteClicked(self, groupRosterNote, displayName) end);
end

-- does the changes to each row of the roster
function AdvancedGroupRoster.modifyRosterRow(control)
	local data = control.dataEntry.data
	local displayName = data.displayName
	local characterNameControl = control:GetNamedChild("CharacterName")
	local characterName = data.characterName
	local toolTipStr = characterName

	local index = data.index
	local newName = ''
	toolTipStr = toolTipStr .. "\r\n" .. displayName

	if AdvancedGroupRoster.SV.listNicknames[displayName] ~= nil then
		newName = AdvancedGroupRoster.SV.listNicknames[displayName]
	elseif AdvancedGroupRoster.SV.listNicknames[characterName] ~= nil then
		newName = AdvancedGroupRoster.SV.listNicknames[characterName]
	elseif AdvancedGroupRoster.SV.useUserId == 1 or AdvancedGroupRoster.SV.useUserId == 3 then
		newName = characterName
	else
		newName = displayName
	end

	if AdvancedGroupRoster.SV.raidManagementEnable == true then
		toolTipStr  = toolTipStr .. "\r\n" .. "Role: "..AdvancedGroupRoster.getRole(characterName)
	end

	updateCharacterName(control, index, toolTipStr, newName)

	local groupTag = data.unitTag

	if AdvancedGroupRoster.currentSession.players[characterName] == nil then
		AdvancedGroupRoster.InitializePlayerArray(characterName)
	end

	if AdvancedGroupRoster.currentSession.players[characterName] ~= nil then
		if AdvancedGroupRoster.currentSession.players[characterName].atName == 'Unknown' then
			AdvancedGroupRoster.currentSession.players[characterName].atName = GetUnitDisplayName(groupTag)
		end
	end

	updateLevel(control, GetUnitAvARank(groupTag), GetUnitAlliance(groupTag), data.championPoints, data.level)

	updateRole(control, data.isHeal, data.isDps, data.isTank)

	updateLeader(control, data.leader, data.isPlayer, displayName)
	
	local zoneControl = control:GetNamedChild("Zone")
	updateLocation(control, data.formattedZone)

	local displayNameControl = control:GetNamedChild("DisplayName")

	local classControl = control:GetNamedChild("Class")
	local classControl2 = control:GetNamedChild("Class2")

	if AdvancedGroupRoster.sortRoster() == true then
		classControl:SetHidden(true)

		if classControl2 == nil then
			classControl2 = WINDOW_MANAGER:CreateControl(control:GetName() .. "Class2", control, CT_BUTTON)
			classControl2:SetDimensions(30, AdvancedGroupRoster.columnHeight)
			classControl2:SetAnchor(LEFT, zoneControl, RIGHT, 12)
			updateClass(control, data.class)
		end
		
		classControl2:SetHidden(false)
	else
		classControl:SetHidden(false)

		if classControl2 ~= nil then
			classControl2:SetHidden(true)
		end
	end
	
	if AdvancedGroupRoster.SV.useUserId == 3 then
		if displayNameControl == nil then
			displayNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "DisplayName", control, CT_LABEL)
			displayNameControl:SetFont("ZoFontGame")
			displayNameControl:SetColor(unpack({0.46274510025978, 0.73725491762161, 0.76470589637756, 1}))
			displayNameControl:SetDimensions(AdvancedGroupRoster.characterWidth, AdvancedGroupRoster.columnHeight)
			displayNameControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
			displayNameControl:SetVerticalAlignment(TOP)
		end

		zoneControl:SetVerticalAlignment(TOP)

		characterNameControl:SetDimensions(AdvancedGroupRoster.characterWidth, AdvancedGroupRoster.columnHeight)

		zoneControl:ClearAnchors()
		zoneControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
		zoneControl:SetDimensions(70, AdvancedGroupRoster.columnHeight)
		
		classControl:ClearAnchors()
		classControl:SetAnchor(LEFT, zoneControl, RIGHT, 0)
	elseif AdvancedGroupRoster.SV.useUserId == 1 or AdvancedGroupRoster.SV.useUserId == 2 then
		characterNameControl:SetDimensions(AdvancedGroupRoster.normalCharacterWidth, AdvancedGroupRoster.columnHeight)

		zoneControl:ClearAnchors()
		zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
		zoneControl:SetDimensions(AdvancedGroupRoster.normalZoneWidth, AdvancedGroupRoster.columnHeight)
		
		classControl:ClearAnchors()
		classControl:SetAnchor(LEFT, zoneControl, RIGHT, 0)
	end
	
	updateDisplayName(control, displayName)

	local noteControl = control:GetNamedChild("Note")

	if AdvancedGroupRoster.SV.utilizeGroupNotes == true then
		if noteControl == nil then
			noteControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "Note", control, CT_BUTTON)
			noteControl:SetDimensions(32, AdvancedGroupRoster.columnHeight)
			noteControl:SetAnchor(LEFT, control:GetNamedChild("RoleDPS"), RIGHT, 0)
			noteControl:SetNormalTexture('EsoUI/Art/Contacts/social_note_up.dds')
			noteControl:SetPressedTexture('EsoUI/Art/Contacts/social_note_down.dds')
			noteControl:SetMouseOverTexture('EsoUI/Art/Contacts/social_note_over.dds')
		end
		
		noteControl:SetHidden(false)
		classControl:SetDimensions(30, AdvancedGroupRoster.columnHeight)
		
		if classControl2 ~= nil then
			classControl2:ClearAnchors()
			classControl2:SetAnchor(LEFT, zoneControl, RIGHT, 0)
		end

		updateNotes(control, displayName)
	else
		if noteControl ~= nil then
			noteControl:SetHidden(true)
		end
		
		classControl:SetDimensions(50, AdvancedGroupRoster.columnHeight)
		
		if classControl2 ~= nil then
			classControl2:ClearAnchors()
			classControl2:SetAnchor(LEFT, zoneControl, RIGHT, 12)
		end
	end

	if AdvancedGroupRoster.sortRoster() == true then
		local defaultArray = {}
		defaultArray.index = index
		defaultArray.name = newName
		defaultArray.nameToolTip = toolTipStr
		defaultArray.location = data.formattedZone
		defaultArray.classId = data.class
		defaultArray.pvpRank = GetUnitAvARank(groupTag)
		defaultArray.alliance = GetUnitAlliance(groupTag) 
		defaultArray.championPoints = data.championPoints
		defaultArray.isHeal = data.isHeal
		defaultArray.isDps = data.isDps
		defaultArray.isTank = data.isTank
		defaultArray.isLeader = data.leader
		defaultArray.isPlayer = data.isPlayer
		defaultArray.online = IsUnitOnline(groupTag)
		defaultArray.characterName = characterName
		defaultArray.displayName = displayName
		defaultArray.level = data.level

		AdvancedGroupRoster.sortedGroupRoster[displayName] = defaultArray
	end
end

-- runs through each row in the roster to update it
function AdvancedGroupRoster.UpdateGroupList()
	if ZO_GroupListList:IsHidden() == false then
		if AdvancedGroupRoster.sortRoster() == true then
			AdvancedGroupRoster.sortedGroupRoster = {}
			AdvancedGroupRoster.sortedRosterKeys = {}
		end

		for _,row in pairs(ZO_GroupListList.activeControls) do
			AdvancedGroupRoster.modifyRosterRow(row)
		end

		if AdvancedGroupRoster.sortRoster() == true then
			for k in pairs(AdvancedGroupRoster.sortedGroupRoster) do
				table.insert(AdvancedGroupRoster.sortedRosterKeys, k)
			end
			
			table.sort(AdvancedGroupRoster.sortedRosterKeys)

			for _,row in pairs(ZO_GroupListList.activeControls) do
				AdvancedGroupRoster.sortRosterRow(row)
			end
		end
	end
end

function AdvancedGroupRoster.sortRoster()
	if AdvancedGroupRoster.SV.rosterSortUserID == true and GetGroupSize() <= 20 then
		return true
	end
	
	return false
end

function AdvancedGroupRoster.onChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	local from = zo_strformat("<<1>>", fromDisplayName)

	if from == nil or from == '' then
		return
	end

	if AdvancedGroupRoster.SV.groupInviteEnabled == true and (AdvancedGroupRoster.SV.groupInviteString ~= '' or AdvancedGroupRoster.SV.groupInviteString2 ~= '') then
		if (channelType ~= CHAT_CHANNEL_ZONE and AdvancedGroupRoster.SV.groupInviteNonZone == true) or AdvancedGroupRoster.SV.groupInviteNonZone == false then
			local foundInviteString = false

			if text == AdvancedGroupRoster.SV.groupInviteString or text == AdvancedGroupRoster.SV.groupInviteString2 then
				foundInviteString = true
			end

			if AdvancedGroupRoster.SV.groupInviteCaseSensitive == false and foundInviteString == false then
				if string.lower(text) == string.lower(AdvancedGroupRoster.SV.groupInviteString) or string.lower(text) == string.lower(AdvancedGroupRoster.SV.groupInviteString2) then
					foundInviteString = true
				end
			end

			if foundInviteString == true then
				if GetGroupSize() >= AdvancedGroupRoster.SV.groupInviteSize then
					AdvancedGroupRoster.checkRaidManagementKick()
				end

				if GetGroupSize() <= AdvancedGroupRoster.SV.groupInviteSize then
					local canInvite = AdvancedGroupRoster.checkRaidManagementInvite(zo_strformat("<<1>>", fromName))

					if canInvite == 'true' then
						d("Inviting user: "..from)
						GroupInviteByName(from)
					elseif canInvite ~= 'false' then
						d(canInvite)
					end
				end
			end
		end
	end

	if AdvancedGroupRoster.SV.trackGroupStatus == false and AdvancedGroupRoster.SV.secLeaders == '' then
		return
	end

	-- only look for requests from group
	if channelType ~= CHAT_CHANNEL_PARTY then
		return
	end

	if AdvancedGroupRoster.SV.secLeaders ~= '' then
		if IsUnitGroupLeader('player') == true then
			if AdvancedGroupRoster.SV.listSecLeaders[from] ~= nil and AdvancedGroupRoster.SV.listSecLeaders[from] == true then
				if string.find(string.lower(text), 'invite') then
					local username = string.sub(text, string.len('invite')+2)

					if string.len(username) > 1 then
						GroupInviteByName(username)
						d(from .. " invited " .. username)
					end
				elseif string.find(string.lower(text), 'kick') then
					local username = string.sub(text, string.len('kick')+2)

					if string.len(username) > 1 then
						GroupKick(AdvancedGroupRoster.findGroupUnitTag(username))
						d(from .. " kicked " .. username)
					end
				elseif string.find(string.lower(text), 'promote') then
					local username = string.sub(text, string.len('kick')+2)

					if string.len(username) > 1 then
						GroupPromote(AdvancedGroupRoster.findGroupUnitTag(username))
						d(from .. " promoted " .. username .. " to be group leader")
					end
				end
			end
		end
	end

	if AdvancedGroupRoster.SV.trackGroupStatus == true then
		for awayMessage,_ in pairs(AdvancedGroupRoster.SV.listAwayMessages) do
			if string.find(string.lower(text), string.lower(awayMessage)) then
				local datestring = tostring(GetDate())
				local year = tonumber(datestring:sub(1,4))
				local month = tonumber(datestring:sub(5,6))
				local day = tonumber(datestring:sub(7,8))
				local timer = year .. "-" .. month .. "-" .. day .. " " .. tostring(GetTimeString())

				if AdvancedGroupRoster.rosterStatus[from] ~= nil then
					AdvancedGroupRoster.rosterStatus[from].isAway = true
					AdvancedGroupRoster.rosterStatus[from].message = text
					AdvancedGroupRoster.rosterStatus[from].timer = timer
				else
					local defaultStatusArray = {}
					defaultStatusArray.isAway = true
					defaultStatusArray.message = text
					defaultStatusArray.timer = timer

					AdvancedGroupRoster.rosterStatus[from] = defaultStatusArray
				end

				AdvancedGroupRoster.UpdateGroupList()

				return
			end
		end

		AdvancedGroupRoster.clearAwayMessage(from)
	end
end

function AdvancedGroupRoster.clearAwayMessage(name)
	if AdvancedGroupRoster.rosterStatus[name] ~= nil then
		if AdvancedGroupRoster.rosterStatus[name].isAway == true then
			AdvancedGroupRoster.rosterStatus[name].isAway = false
			AdvancedGroupRoster.rosterStatus[name].message = ''
			AdvancedGroupRoster.rosterStatus[name].timer = ''

			AdvancedGroupRoster.UpdateGroupList()
		end
	end
end

-- when updating setting, always reset all in group
function AdvancedGroupRoster.UpdateGroupMemberStatus()
	for displayName,_ in pairs(AdvancedGroupRoster.rosterStatus) do
		AdvancedGroupRoster.rosterStatus[displayName].isAway = false
		AdvancedGroupRoster.rosterStatus[displayName].message = ''
		AdvancedGroupRoster.rosterStatus[displayName].timer = ''
	end
end

-- Thanks to pChat for creating such a nice way to make nicknames!
function AdvancedGroupRoster.BuildNicknames()
	AdvancedGroupRoster.SV.listNicknames = {}

	if AdvancedGroupRoster.SV.nicknames ~= "" then
		local lines = AdvancedGroupRoster.Explode("\n", AdvancedGroupRoster.SV.nicknames)

		for lineIndex=#lines, 1, -1 do
			local oldName, newName = string.match(lines[lineIndex], "(@?[%w_-]+) ?= ?([%w- ]+)")

			if not (oldName and newName) then
				table.remove(lines, lineIndex)
			else
				AdvancedGroupRoster.SV.listNicknames[oldName] = newName
			end
		end

		AdvancedGroupRoster.SV.nicknames = table.concat(lines, "\n")
	end
end

-- ability to reset the color options back to default
function AdvancedGroupRoster.OnResetColorOptions()
	AdvancedGroupRoster.SV.healColors=AdvancedGroupRoster.defaultRoleColor
	AdvancedGroupRoster.SV.tankColors=AdvancedGroupRoster.defaultRoleColor
	AdvancedGroupRoster.SV.dpsColors=AdvancedGroupRoster.defaultRoleColor
	AdvancedGroupRoster.SV.sameLocColors=AdvancedGroupRoster.defaultRowColor
end

-- Initalizing the 'Group Note Edit' form
function AdvancedGroupRoster:OnInitialized(self)
	ZO_Dialogs_RegisterCustomDialog("GROUP_EDIT_NOTE",   
    {
        customControl = self,
        setup = EditNoteDialogSetup,
        title = {
            text = "EDIT NOTE",
        },
        buttons = {
            [1] = {
                control =   GetControl(self, "Save"),
                text =      "SAVE",
                callback =  function(dialog)
                                local data = dialog.data
                                local note = GetControl(dialog, "NoteEdit"):GetText()

                                if note ~= data.note then
                                    data.changedCallback(data.displayName, note)
                                end
                            end,
            },
            [2] = {
                control =   GetControl(self, "Cancel"),
                text =      "CANCEL",
            }
        }
    })
end

-- when the note button is clicked
function AdvancedGroupRoster.onNoteClicked(control, note, displayName)
	local noteEditedFunction = function(displayName, note)
		AdvancedGroupRoster.SV.groupRoster[displayName] = note
		AdvancedGroupRoster.UpdateGroupList()
    end

    ZO_Dialogs_ShowDialog("GROUP_EDIT_NOTE", {displayName = displayName, changedCallback = noteEditedFunction})
	AdvancedGroupRosterWindowDisplayName:SetText(displayName)
	AdvancedGroupRosterWindowNoteEdit:SetText(note)
end

-- grabbed from pChat; writes out your choosen away messages
function AdvancedGroupRoster.BuildAwayMessages()
	AdvancedGroupRoster.SV.listAwayMessages = {}

	if AdvancedGroupRoster.SV.awayMessages ~= "" then
		local lines = AdvancedGroupRoster.Explode("\n", AdvancedGroupRoster.SV.awayMessages)

		for lineIndex=#lines, 1, -1 do
			local message = lines[lineIndex]

			if not (message) then
				table.remove(lines, lineIndex)
			elseif message ~= '' then
				AdvancedGroupRoster.SV.listAwayMessages[message] = true
			end
		end

		AdvancedGroupRoster.SV.awayMessages = table.concat(lines, "\n")
	end
end

function AdvancedGroupRoster.BuildSecondaryLeaders()
	AdvancedGroupRoster.SV.listSecLeaders = {}

	if AdvancedGroupRoster.SV.secLeaders ~= "" then
		local lines = AdvancedGroupRoster.Explode("\n", AdvancedGroupRoster.SV.secLeaders)

		for lineIndex=#lines, 1, -1 do
			local leader = lines[lineIndex]

			if not (leader) then
				table.remove(lines, lineIndex)
			else
				AdvancedGroupRoster.SV.listSecLeaders[leader] = true
			end
		end

		AdvancedGroupRoster.SV.secLeaders = table.concat(lines, "\n")
	end
end
