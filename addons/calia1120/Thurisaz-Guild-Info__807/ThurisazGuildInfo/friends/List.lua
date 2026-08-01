-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

TI.FRIEND = {}

local FRIEND_WINDOW = ZO_KeyboardFriendsList
local FRIEND_HEADERS = ZO_KeyboardFriendsListHeaders
local FRIEND_LIST = ZO_KeyboardFriendsListListContents
local FRIEND_LIST_MASTER = ZO_KeyboardFriendsListList
local charnameWidth = 200

local function UpdateRow(control)
	local displayNameControl = control:GetNamedChild("DisplayName")
	local zoneControl = control:GetNamedChild("Zone")

	local charNameLabel = control:GetNamedChild("CharNameName")
	if(not charNameLabel) then
		local charNameControl = TI:CreateControl(control, displayNameControl, "CharName")
		charNameLabel = TI.CreateCharNameLabel(charNameControl, displayNameControl, "Name", {charnameWidth,30}, "ZoFontGame")

		charNameLabel:SetHidden(false)
		charNameLabel:SetColor(unpack(TI.colors.headerDefault))

		zoneControl:ClearAnchors()
		zoneControl:SetAnchor(LEFT, charNameLabel, RIGHT, 0)
		zoneControl:SetWidth(zoneControl:GetWidth() - charnameWidth + 50)
	end
	charNameLabel:SetText(control.dataEntry.data.characterName)

	zoneControl.zoneText = TI:formatZoneName(control.dataEntry.data.formattedZone)
	zoneControl.timeText = TI:secsToTime(control.dataEntry.data.secsSinceLogoff)


	if(not control.dataEntry.data.online) then
		charNameLabel:SetColor(unpack(TI.colors.rosterOffline))
		zoneControl:SetText(zoneControl.timeText)

		zoneControl:SetMouseEnabled(true)
		zoneControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, self.zoneText); ZO_FriendsListRow_OnMouseEnter(control); end);
		zoneControl:SetHandler("OnMouseExit", function (self) ZO_Tooltips_HideTextTooltip(); ZO_FriendsListRow_OnMouseExit(control); end);
	else
		charNameLabel:SetColor(unpack(TI.colors.rosterOnline))
		zoneControl:SetText(zoneControl.zoneText)

		zoneControl:SetMouseEnabled(false)
	end

end

---Update Friendlist Roster if visible
local function UpdateListContents()
	if(FRIEND_LIST:IsHidden()) then return end
	--d("updateing friend list content")

	for _,row in pairs(FRIEND_LIST_MASTER.activeControls) do
		UpdateRow(row)
	end
end

---Update Friendlist Roster without checking visibility
local function UpdateListContentsRaw()
	for _,row in pairs(FRIEND_LIST_MASTER.activeControls) do
		UpdateRow(row)
	end
end

local function UpdateListHeaders()
	local displayNameControl = FRIEND_HEADERS:GetNamedChild("DisplayName")
	local zoneControl = FRIEND_HEADERS:GetNamedChild("Zone")

	local charNameLabel = FRIEND_HEADERS:GetNamedChild("CharNameName")
	if(not charNameLabel) then
		local charNameControl = TI:CreateControl(FRIEND_HEADERS, displayNameControl, "CharName")
		charNameLabel = TI.CreateCharNameLabel(charNameControl, displayNameControl, "Name", {charnameWidth,30}, "ZoFontGame")

		charNameLabel:SetText(TI.locale["CharNameHeader"])
		charNameLabel:SetHidden(false)
		charNameLabel:SetFont("ZoFontHeader")
		charNameLabel:SetColor(unpack(TI.colors.headerDefault))

--		charNameControl:SetHandler("OnMouseUp", OnCharnameClick)

		zoneControl:ClearAnchors()
		zoneControl:SetAnchor(LEFT, charNameLabel, RIGHT, 0)
		zoneControl:SetWidth(zoneControl:GetWidth() - charnameWidth + 120)
	end
end

---Updates FreindList when FRIENDS_LIST_SCENE is opened
local function OnFriendListStateChanged(oldState, newState)
	if(newState == SCENE_SHOWN) then
		UpdateListContentsRaw()
	end
end

function TI.FRIEND.Initialize()
	UpdateListHeaders()
	UpdateListContentsRaw()

	ZO_PreHook("ZO_ScrollList_UpdateScroll", UpdateListContents)
	TI.postHook("ZO_FriendsList_OnInitialized", UpdateListContents)
	TI.postHook("ZO_SortHeader_OnMouseUp", UpdateListContents)
	TI.postHook("OnSearchTextChanged", UpdateListContents, "FRIENDS_LIST")

	--Update Friend list on following events:
	EVENT_MANAGER:RegisterForEvent( "TGI_FriendStatusChanged" , EVENT_FRIEND_PLAYER_STATUS_CHANGED , UpdateListContentsRaw )
	EVENT_MANAGER:RegisterForEvent( "TGI_FriendZoneChanged" , EVENT_FRIEND_CHARACTER_ZONE_CHANGED , UpdateListContentsRaw )
	EVENT_MANAGER:RegisterForEvent( "TGI_FriendRemoved" , EVENT_FRIEND_REMOVED , UpdateListContentsRaw )
	EVENT_MANAGER:RegisterForEvent( "TGI_FriendAdded" , EVENT_FRIEND_ADDED , UpdateListContentsRaw )

	FRIENDS_LIST_SCENE:RegisterCallback("StateChange", OnFriendListStateChanged)
end
