--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

-- Initialized the addon names
GroupStealth = {}
GroupStealth.name = "GroupStealth"
GroupStealth.version = 12.0

GroupStealth.playerStealth = false
GroupStealth.leaderStealthState = 0
GroupStealth.leaderName = 'Group Leader'
GroupStealth.playerUserId = nil

function GroupStealth:Initialize()
	GroupStealth.leaderName = GetUnitDisplayName(GetGroupLeaderUnitTag())
	GroupStealth.playerUserId = GetUnitDisplayName('player')

	ZO_PreHook(ZO_StealthIcon, "AnimateInStealthText", GroupStealth.StartStealth)
	ZO_PreHook(ZO_StealthIcon, "HideStealthText", GroupStealth.EndStealth)
	EVENT_MANAGER:RegisterForUpdate(GroupStealth.name, 1000, GroupStealth.UpdateReticle)
	EVENT_MANAGER:RegisterForEvent(GroupStealth.Name, EVENT_LEADER_UPDATE, GroupStealth.onGroupLeaderChange)
	EVENT_MANAGER:RegisterForEvent(GroupStealth.Name, EVENT_STEALTH_STATE_CHANGED, GroupStealth.onPlayerStealth)
	EVENT_MANAGER:RegisterForEvent(GroupStealth.name, EVENT_PLAYER_ACTIVATED, GroupStealth.OnPlayerActivated)
end

-- Loads the addon; only hit once
function GroupStealth.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= GroupStealth.name then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(GroupStealth.name, EVENT_ADD_ON_LOADED)

	GroupStealth:Initialize()
end

function GroupStealth.OnPlayerActivated()
	GroupStealth.leaderName = GetUnitDisplayName(GetGroupLeaderUnitTag())
	GroupStealth.playerUserId = GetUnitDisplayName('player')
end

function GroupStealth.GetGroupStealthLabel()
	local groupStealthControl = ZO_ReticleContainerStealthIcon:GetNamedChild("GroupStealth")

	if groupStealthControl == nil then
		groupStealthControl = WINDOW_MANAGER:CreateControl(ZO_ReticleContainerStealthIcon:GetName() .. "GroupStealth", ZO_ReticleContainerStealthIcon, CT_LABEL)
		groupStealthControl:SetFont("ZoFontGame")
		groupStealthControl:SetAnchor(CENTER, ZO_ReticleContainerStealthIconStealthText, CENTER, 5, 60)
		groupStealthControl:SetDimensions(40, 30)
		groupStealthControl:SetHidden(true)
		groupStealthControl:SetFont("$(MEDIUM_FONT)|" .. 20)
	end

	groupStealthControl:SetText('')

	return groupStealthControl
end

function GroupStealth.onGroupLeaderChange(eventCode, leaderTag)
	GroupStealth.leaderName = GetUnitDisplayName(leaderTag)
end

function GroupStealth.onPlayerStealth(eventCode, unitTag, stealthState)
	if GetUnitDisplayName(unitTag) == GroupStealth.playerUserId then
		if stealthState ~= STEALTH_STATE_NONE then
			GroupStealth.playerStealth = true
		else
			GroupStealth.playerStealth = false
		end
	end
end

function GroupStealth.ScreenNotification(message, timeOnScreen)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(message)
	messageParams:SetLifespanMS(timeOnScreen)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function GroupStealth.UpdateReticle() 
	if IsUnitGroupLeader('player') == false then
		local groupLeaderStealthState = GetUnitStealthState(GetGroupLeaderUnitTag())

		if groupLeaderStealthState ~= nil then
			if GroupStealth.leaderName == nil then
				GroupStealth.leaderName = GetUnitDisplayName(GetGroupLeaderUnitTag())
			end

			if GroupStealth.leaderName == nil then
				GroupStealth.leaderName = 'Group Leader'
			end

			if groupLeaderStealthState ~= STEALTH_STATE_NONE and GroupStealth.leaderStealthState == 0 then
				GroupStealth.ScreenNotification(GroupStealth.leaderName .. " has just stealthed!", 2000)
				GroupStealth.leaderStealthState = 1
			elseif groupLeaderStealthState == STEALTH_STATE_NONE then
				if GroupStealth.leaderStealthState == 1 then
					GroupStealth.ScreenNotification(GroupStealth.leaderName .. " came out of stealth!", 2000)
				end

				GroupStealth.leaderStealthState = 0
			end
		end
	end

	if GroupStealth.playerStealth == false then
		return
	end

	local control = GroupStealth.GetGroupStealthLabel()
	local totalGroupSize = GetGroupSize()

	if totalGroupSize > 0 then
		local totalHiding = 0
		local groupSize = 0
		local groupTag = nil

		for sortIndex = 1, totalGroupSize do
			groupTag = GetGroupUnitTagByIndex(sortIndex)

			if IsUnitInGroupSupportRange(groupTag) == true then
				groupSize = groupSize + 1

				if GetUnitStealthState(groupTag) ~= STEALTH_STATE_NONE then
					totalHiding = totalHiding + 1
				end
			end
		end

		-- might only be you in range
		if groupSize > 1 then
			control:SetHidden(false)
			control:SetText(totalHiding .. "/" .. groupSize)
		else
			control:SetHidden(true)
		end
	else
		control:SetHidden(true)
	end
end

function GroupStealth.StartStealth()
	if GroupStealth.playerStealth == false then
		return
	end

	local control = GroupStealth.GetGroupStealthLabel()
	control:SetHidden(false)
end

function GroupStealth.EndStealth()
	if GroupStealth.playerStealth == true then
		return
	end

	local control = GroupStealth.GetGroupStealthLabel()
	control:SetHidden(true)
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(GroupStealth.name, EVENT_ADD_ON_LOADED, GroupStealth.OnAddOnLoaded)