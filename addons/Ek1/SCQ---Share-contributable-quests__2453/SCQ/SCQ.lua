SCQ = {
	TITLE = "Share contributable quests",	-- Enduser friendly version of the add-on's name
	AUTHOR = "Ek1",
	DESCRIPTION = "Shares quests to party members that can contribute to the quest.",
	VERSION = "1.3.200324",
	LIECENSE = "BY-SA = Creative Commons Attribution-ShareAlike 4.0 International License",
	URL = "https://github.com/Ek1/SCQ"
}
local ADDON = "SCQ"	-- Codereview friendly reference to this add-on.

local membersSupporting = {}
local groupMembers = {}
local supported = false
local doSharing = false
local delayBeforeSharing = 500

-- Starting to do magic
function SCQ.Start()

	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_MEMBER_JOINED,	SCQ.EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_MEMBER_CONNECTED_STATUS,	SCQ.EVENT_GROUP_MEMBER_CONNECTED_STATUS)

	supported = false

	d( ADDON .. ": started. Listening to group size changes and when party member is close enough to support.")
end

-- 100028 EVENT_GROUP_MEMBER_JOINED (number eventCode, string memberCharacterName, string memberDisplayName, boolean isLocalPlayer)
function SCQ.EVENT_GROUP_MEMBER_JOINED(_ , memberCharacterName, memberDisplayName, isLocalPlayer)

	if isLocalPlayer then
		EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_SUPPORT_RANGE_UPDATE,	SCQ.EVENT_GROUP_SUPPORT_RANGE_UPDATE)
		EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_QUEST_ADDED,	SCQ.EVENT_QUEST_ADDED)
		EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED,	SCQ.EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_DEACTIVATED,	SCQ.EVENT_PLAYER_DEACTIVATED)
		EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_MEMBER_LEFT,	SCQ.EVENT_GROUP_MEMBER_LEFT)
		d( ADDON .. ": You joined a group with Your " .. zo_strformat("<<1>>", memberCharacterName) .. " consisting of " .. zo_strformat("<<n:1>>", GetGroupSize() ) .. " brave adventurers  ")
		membersSupporting = {}
		membersSupporting[0] = 0
	else
		d( ADDON .. ": " .. ZO_LinkHandler_CreateLinkWithoutBrackets(memberDisplayName, nil, CHARACTER_LINK_TYPE, memberDisplayName) .. " joined the group with " .. zo_strformat("<<1>>", memberCharacterName) .. " making us " .. zo_strformat("<<n:1>>", GetGroupSize() ) .. " undaunted adventurers" )
	end

	doSharing = true

--	SCQ.fixMembersInSupportRange()

	--d( ADDON .. ": delay before sharing " .. delayBeforeSharing)

	if doSharing and supported then
		zo_callLater( SCQ.QuestSharingAtPlayerZone, delayBeforeSharing )
		doSharing = false
	end
end

-- API 100026	EVENT_QUEST_ADDED (number eventCode, number journalIndex, string questName, string objectiveName)
function SCQ.EVENT_QUEST_ADDED (_, journalIndex, questName, objectiveName)
	if GetIsQuestSharable(journalIndex) then
		doSharing = true
	end

	if doSharing and supported then
		zo_callLater( SCQ.QuestSharingAtPlayerZone, delayBeforeSharing )
		doSharing = true
	end
end

--	EVENT_GROUP_MEMBER_CONNECTED_STATUS (number eventCode, string unitTag, boolean isOnline)
function SCQ.EVENT_GROUP_MEMBER_CONNECTED_STATUS (_, string_unitTag, boolean_isOnline)
	SCQ.fixMembersInSupportRange()
end

-- EVENT_PLAYER_DEACTIVATED (number eventCode)
function SCQ.EVENT_PLAYER_DEACTIVATED(_)
	supported = false
	EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED,	SCQ.EVENT_PLAYER_ACTIVATED)
end

--	EVENT_PLAYER_ACTIVATED (number eventCode, boolean initial)
function SCQ.EVENT_PLAYER_ACTIVATED(_, _)
	zo_callLater( SCQ.fixMembersInSupportRange, delayBeforeSharing )
end

--	Inefficient support range checker that needs to be done when exiting loading screen as EVENT_GROUP_SUPPORT_RANGE_UPDATE is not updated then
function SCQ.fixMembersInSupportRange()

	groupMembers = {}
	membersSupporting = {}
	membersSupporting[0] = 0

	for i = 1, GetGroupSize() do
		local focusedGroupTag = GetGroupUnitTagByIndex(i)
		local focusedUnitDisplayName = GetUnitDisplayName( focusedGroupTag )

		if IsUnitInGroupSupportRange( focusedGroupTag ) and not IsUnitPlayer(focusedGroupTag) then
			membersSupporting[0] = membersSupporting[0] + 1
			membersSupporting[membersSupporting[0]] = focusedUnitDisplayName
		end
		groupMembers[i] = focusedUnitDisplayName
		groupMembers[focusedUnitDisplayName] = i
	end

	if 0 < membersSupporting[0] then
		supported = true
	else 
		supported = false
	end

	local orderInGroup = groupMembers[GetDisplayName()] or GetGroupSize()
	delayBeforeSharing = orderInGroup * GetLatency()	-- Use latency as multiplier to push back sharing to have somekind of logic what quest comletion to have among members. With 150ms latency it means last member in party waits for 3,6 seconds until sharing quests.
end

-- Following keeps track of the members that are in support range
-- 100028 EVENT_GROUP_SUPPORT_RANGE_UPDATE (number eventCode, string unitTag, boolean status)
function SCQ.EVENT_GROUP_SUPPORT_RANGE_UPDATE(_, unitTag, isSupporting)

	if not membersSupporting then
		membersSupporting = {}
		membersSupporting[0] = 0
	end
	--d( SCQ.TITLE .. ": EVENT_GROUP_SUPPORT_RANGE_UPDATE " .. membersSupporting[0] .. "/" .. GetGroupSize() .. " party members in support range before check")

	if isSupporting then
		membersSupporting[0] = 1 + membersSupporting[0] or 2
		--d( SCQ.TITLE .. ": EVENT_GROUP_SUPPORT_RANGE_UPDATE updated to " .. membersSupporting[0] .. "/" .. GetGroupSize() .. " party members in support range")
--[[ 		if GetGroupSize() < membersSupporting[0] then	-- There can't be more people supporting than there are members in group
			membersSupporting[0] = GetGroupSize() or 2
			--d( SCQ.TITLE .. ": EVENT_GROUP_SUPPORT_RANGE_UPDATE fixed to " .. membersSupporting[0] .. "/" .. GetGroupSize() .. " party members in support range")
		end ]]
	else
		membersSupporting[0] = membersSupporting[0] - 1 or 1
		--d( SCQ.TITLE .. ": EVENT_GROUP_SUPPORT_RANGE_UPDATE updated to " .. membersSupporting[0] .. "/" .. group[0] .. " party members in support range")
--[[ 		if membersSupporting[0] < 1 then	-- Player is always in support range of himself
			membersSupporting[0] = 1
			--d( SCQ.TITLE .. ": EVENT_GROUP_SUPPORT_RANGE_UPDATE fixed to " .. membersSupporting[0] .. "/" .. group[0] .. " party members in support range")
		end ]]
	end

	if 1 < membersSupporting[0] then
		supported = true
	else
		supported = false
	end

	if doSharing and supported then
		SCQ.TargetedQuestSharing( GetUnitZoneIndex("player") )
		doSharing = false
	end
end

-- Wrapping for zo_callLater function.
function SCQ.QuestSharingAtPlayerZone()
	SCQ.TargetedQuestSharing( GetUnitZoneIndex("player" ) )
end

-- Quests in target zone sharing
-- Optionally takes int_ZoneIndex and int_questRepeatType as arguments for more specific sahres
function SCQ.TargetedQuestSharing( targetZoneIndex, questRepeatTypeFromZeroToTwo )

	if targetZoneIndex == nil then
		targetZoneIndex = GetUnitZoneIndex("player")	-- If not target was given, presume target is players zone
	end
	local questRepeatTypeMinimumToShare = questRepeatTypeFromZeroToTwo or 0	-- if no limit was given, presume everything is wanted

	for i = 1, GetNumJournalQuests() do

		if GetIsQuestSharable(i) then	-- If it can't be shared, don't even bother

			if questRepeatTypeMinimumToShare <= GetJournalQuestRepeatType(i) then

				local journalQuestLocationZoneName, objectiveName, journalQuestLocationZoneIndex, poiIndex =	GetJournalQuestLocationInfo(i)
				local JournalQuestStartingZoneIndex = GetJournalQuestStartingZone(i)

				if targetZoneIndex == journalQuestLocationZoneName or targetZoneIndex == JournalQuestStartingZoneIndex then
					ShareQuest(i)
					d( ADDON .. ": shared #" .. i .. " " .. GetJournalQuestName(i) .. " that locates in " .. journalQuestLocationZoneName)
				end
			end
		end
	end
end	-- Quests in target zone sharing

-- Slashcommand enabled for the add-on 
function SCQSlashShare( arg)
	
	-- numberic calls from 0 to 3 (100030: QUEST_REPEAT_MAX_VALUE) share those type quests 
	if type(arg) == "number" and
		QUEST_REPEAT_MIN_VALUE <= arg and
		arg <= QUEST_REPEAT_MAX_VALUE then
		SCQ.TargetedQuestSharing( GetUnitZoneIndex("player", arg ) )
	-- if there is no arg, share all local quests
	elseif not arg then
		SCQ.TargetedQuestSharing( GetUnitZoneIndex("player") )
	-- incase arg is not number then the user most likely wants help
	else
		d("/sql      Share all shareable quests in Your location")
		d("/sql <#>  Share shareable quests in Your location that are type #")
		d("0 = Can't re repeated aka story quests")
		d("1 = Pledge")
		d("2 = Daily")
		d("3 = Repeatable")
	end
end

-- 100028 EVENT_GROUP_MEMBER_LEFT (number eventCode, string memberCharacterName, GroupLeaveReason reason, boolean isLocalPlayer, boolean isLeader, string memberDisplayName, boolean actionRequiredVote)
function SCQ.EVENT_GROUP_MEMBER_LEFT(_ , memberCharacterName, GroupLeaveReason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)

	if isLocalPlayer then
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_QUEST_ADDED)
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_GROUP_MEMBER_LEFT)
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_PLAYER_DEACTIVATED)
		d( ADDON .. ": Now soloing.")
		supported = false
		membersSupporting = {}
		membersSupporting[0] = 0
	else
		SCQ.fixMembersInSupportRange()
		d( ADDON .. ": " .. ZO_LinkHandler_CreateLinkWithoutBrackets(memberDisplayName, nil, CHARACTER_LINK_TYPE, memberDisplayName) .. " left the group with " .. zo_strformat("<<1>>", memberCharacterName) .. " making us " .. zo_strformat("<<n:1>>", GetGroupSize() ) .. " undaunted adventurers" )
	end
end

-- Kill the add-on if needed for some reason. Also a list of stuff that needs to be remembered.
function SCQ.Stop()

	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_QUEST_ADDED)

	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_GROUP_MEMBER_CONNECTED_STATUS)
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_GROUP_MEMBER_LEFT)

	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_PLAYER_DEACTIVATED)

	d( ADDON .. ": stopped")
end

-- Variable to keep count how many loads have been done before it was this ones turn.
local loadOrder = 1
function SCQ.GotLoaded(_, loadedAddOnName)
	if loadedAddOnName == ADDON then
	--	Seems it is our time so lets stop listening load trigger and initialize the add-on
		d( SCQ.TITLE .. " (" .. ADDON .. ")".. ": load order " ..  loadOrder .. ", starting")
		EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
		ZO_CreateStringId("SI_BINDING_NAME_SCQ_SHARE_MY_ZONES_QUESTS", "Share quests in your zone")
		SCQ.Start()
		SLASH_COMMANDS["/scq"] = SCQSlashShare
	end
	loadOrder = loadOrder + 1
end

-- Registering the SCQ's initializing event when add-on's are loaded 
EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, SCQ.GotLoaded)