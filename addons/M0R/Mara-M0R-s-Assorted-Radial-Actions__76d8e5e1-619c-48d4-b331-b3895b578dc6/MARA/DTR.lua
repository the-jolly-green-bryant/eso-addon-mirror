-- Code has been provided by code, as raidificator has not yet been published to console

DungeonTrialReset_Standalone = {
	name = "DungeonTrialReset_Standalone",

	-- Time allowance for what is considered a "recent" disband or rejoin,
	-- mostly to accomodate for server response times
	allowance = 5000, -- 5 seconds

	-- Time delay between invites, to avoid dropped invites
	inviteDelays = {
		{ 200, 150 }, -- 150ms for high ping (200+)
		{ 100, 125 }, -- 125ms for medium ping (100-200)
		{   0, 100 }, -- 100ms for low ping
	},

	confirmationCount = 3,
	confirmationSensitivity = 1500, -- 1.5 seconds

	selfName = GetDisplayName(),
	members = { },
	disbandLeader = "",
	disbandTime = 0,
	requestTime = 0,
	requestCount = 0,
}
local DTR = DungeonTrialReset_Standalone

function DTR.Initialize( )
	local confirmDialog = {
		canQueue = true,
		gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
		title = { text = "Reform Group" },
		mainText = { text = "Are you sure you want to disband and reform the group?" },
		buttons = {
			{ text = SI_DIALOG_CONFIRM, callback = DTR.ReformGroup },
			{ text = SI_DIALOG_CANCEL },
		},
	}

	if IsInGamepadPreferredMode() then -- if gamepad, replace buttons with onshowcallback to avoid tainting the stack
        confirmDialog.buttons = nil
        confirmDialog.OnShownCallback = function(dialog)
            local g_keybindState = KEYBIND_STRIP:GetTopKeybindStateIndex()
            local g_keybindGroupDesc = {
                {
                    alignment = KEYBIND_STRIP_ALIGN_LEFT,
                    name = GetString(SI_DIALOG_CONFIRM),
                    keybind = "DIALOG_PRIMARY",
                    callback = function() DTR.ReformGroup() end,
                },
                {
                    alignment = KEYBIND_STRIP_ALIGN_LEFT,
                    name = GetString(SI_DIALOG_CANCEL),
                    keybind = "DIALOG_NEGATIVE",
                    callback = function() end,
                }
            }
            KEYBIND_STRIP:AddKeybindButtonGroup(g_keybindGroupDesc, g_keybindState)
        end
    end
    ZO_Dialogs_RegisterCustomDialog("DTR_CONFIRMATION", confirmDialog)

	DTR.RegisterEventHandlers()
end


--------------------------------------------------------------------------------
-- Entry points
--------------------------------------------------------------------------------

function DTR.ReformGroupConfirm( )
	if (IsUnitGroupLeader("player")) then
		ZO_Dialogs_ShowPlatformDialog("DTR_CONFIRMATION")
	else
		CHAT_ROUTER:AddSystemMessage(GetString(SI_GROUPNOTIFICATIONMESSAGE1))
	end
end


--------------------------------------------------------------------------------
-- Core functions
--------------------------------------------------------------------------------

function DTR.ReformGroup( )
	DTR.members = { }
	for i = 1, GetGroupSize() do
		local member = GetUnitDisplayName(GetGroupUnitTagByIndex(i))
		if (member and member ~= DTR.selfName) then
			table.insert(DTR.members, member)
		end
	end

	DTR.disbandTime = GetGameTimeMilliseconds()
	GroupDisband()
end

function DTR.InviteMember( index, delay )
	if (index > 0) then
		GroupInviteByName(DTR.members[index])
	end
	if (index < #DTR.members) then
		zo_callLater(function() DTR.InviteMember(index + 1, delay) end, delay)
	end
end

function DTR.GetInviteDelay( )
	local ping = GetLatency()
	if (ping < 1) then ping = 1 end

	for _, entry in ipairs(DTR.inviteDelays) do
		if (ping >= entry[1]) then
			return entry[2]
		end
	end
end

function DTR.RegisterEventHandlers( )
	EVENT_MANAGER:RegisterForEvent(DTR.name, EVENT_GROUP_MEMBER_LEFT, function( eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote )
		if (isLeader and reason == GROUP_LEAVE_REASON_DISBAND) then
			local currentTime = GetGameTimeMilliseconds()
			if (not isLocalPlayer) then
				-- Disband not issued by you: prep for receiving invite
				DTR.disbandLeader = memberDisplayName
				DTR.disbandTime = currentTime
			elseif (currentTime - DTR.disbandTime < DTR.allowance) then
				-- Disband issued by player: reinvite the group
				DTR.InviteMember(0, DTR.GetInviteDelay())
			end
		end
	end)

	EVENT_MANAGER:RegisterForEvent(DTR.name, EVENT_GROUP_INVITE_RECEIVED, function( eventCode, inviterCharacterName, inviterDisplayName )
		if (inviterDisplayName == DTR.disbandLeader and GetGameTimeMilliseconds() - DTR.disbandTime < DTR.allowance) then
			AcceptGroupInvite()
		end
	end)
end
