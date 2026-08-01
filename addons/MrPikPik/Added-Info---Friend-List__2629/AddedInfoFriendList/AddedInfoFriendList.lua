AIFL = {}
local AIFL = AIFL

AIFL.name = "AddedInfoFriendList"
AIFL.version = "1.3.1"

-- In case you want to change these, the sum has to be 620.
-- Also note, that text sometimes does not get truncated.
AIFL.Widths = {
    ["DisplayName"] = 190,
    ["Character"] = 220,
    ["Zone"] = 210,
}

AIFL.FriendOnlineStatus = {}
AIFL.LogonTime = GetTimeStamp()

-- Changes the header row
local function ModifyFriendListHeader()  
    -- Account Name
    ZO_KeyboardFriendsListHeadersDisplayName:SetWidth(AIFL.Widths.DisplayName)
    ZO_KeyboardFriendsListHeadersDisplayName:ClearAnchors()
    ZO_KeyboardFriendsListHeadersDisplayName:SetAnchor(LEFT, ZO_KeyboardFriendsListHeadersAlliance, RIGHT, 20)
    
    -- Character Name
    -- The added column label control
    local characterNameColumn = ZO_KeyboardFriendsListHeadersCharacterName
    
    -- if column label doesn't exist yet, create it
    if not characterNameColumn then
        characterNameColumn = WINDOW_MANAGER:CreateControlFromVirtual(ZO_KeyboardFriendsListHeaders:GetName() .. "CharacterName", ZO_KeyboardFriendsListHeaders, "ZO_SortHeader")
        characterNameColumn:SetAnchor(TOPLEFT, ZO_KeyboardFriendsListHeadersDisplayName, TOPRIGHT)
        characterNameColumn:SetDimensions(AIFL.Widths.Character, 32)
    end
    ZO_SortHeader_Initialize(characterNameColumn, GetString(SI_GROUP_LIST_PANEL_NAME_HEADER):upper(), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    FRIENDS_LIST.sortHeaderGroup:AddHeader(characterNameColumn)
    
    -- Zone
    ZO_KeyboardFriendsListHeadersZone:SetWidth(AIFL.Widths.Zone)
    ZO_KeyboardFriendsListHeadersZone:ClearAnchors()
    ZO_KeyboardFriendsListHeadersZone:SetAnchor(LEFT, characterNameColumn, RIGHT, 0)     

end

-- Modifies the guild member rows
local function ModifyFriendListRow(control) 
    -- Display Name
    local displayNameControl = control:GetNamedChild("DisplayName")
    
    displayNameControl:ClearAnchors()
    displayNameControl:SetAnchor(LEFT, control:GetNamedChild("AllianceIcon"), RIGHT, 15)
    displayNameControl:SetWidth(AIFL.Widths.DisplayName)
    
    -- Character Name
    local characterNameControl = control:GetNamedChild("CharacterName")
    if characterNameControl == nil then
		characterNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "CharacterName", control, CT_LABEL)
		characterNameControl:SetFont("ZoFontGame")
		characterNameControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
		characterNameControl:SetVerticalAlignment(BOTTOM)
	end
	
	characterNameControl:SetColor((control.dataEntry.data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT):UnpackRGB())
    characterNameControl:SetWidth(AIFL.Widths.Character)
	characterNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, control.dataEntry.data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	characterNameControl:SetText(control.dataEntry.data.characterName)
 
    -- Zone
    local zoneControl = control:GetNamedChild("Zone")
    zoneControl:ClearAnchors()
    zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
    zoneControl:SetWidth(AIFL.Widths.Zone)
    
    -- Class (move a bit further left than normal)
    local classControl = control:GetNamedChild("ClassIcon")
    classControl:ClearAnchors()
    classControl:SetAnchor(LEFT, zoneControl, RIGHT, 14)
    
    -- Note (move a bit further left than normal)
    local noteControl = control:GetNamedChild("Note")
    noteControl:ClearAnchors()
    noteControl:SetAnchor(LEFT, control:GetNamedChild("Level"), RIGHT, 0)
end

local function OnSceneChange(old, new)
    if new == "showing" then zo_callLater(AIFL.UpdateFriendList, 50) end
end

local function OnGroupScroll()
	if ZO_KeyboardFriendsList:IsHidden() == false then zo_callLater(AIFL.UpdateFriendList, 100) end
end

-- Runs through each row in the roster to update it
function AIFL.UpdateFriendList()
	if ZO_KeyboardFriendsList:IsHidden() == false then
		for _, row in pairs(ZO_KeyboardFriendsListList.activeControls) do
			ModifyFriendListRow(row)
		end
	end
end

local function GetOnlineTimeForFriend(displayName)
	local friendTimestamp = AIFL.FriendOnlineStatus[displayName]
	if not friendTimestamp then return "" end
	local onlineSeconds = GetTimeStamp() - friendTimestamp
	
	if(onlineSeconds < ZO_ONE_MINUTE_IN_SECONDS) then
        return zo_strformat("|cffffff< <<1>>.|r",ZO_FormatTime(60, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
    else
        return zo_strformat("|cffffff<<X:1>>.|r", ZO_FormatTime(onlineSeconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING))
    end

	-- return ZO_FormatTime(onlineSeconds, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS)
end

function OnFriendStatusChanged(evt, displayName, characterName, oldStatus, newStatus)
	if newStatus == PLAYER_STATUS_OFFLINE then
		AIFL.FriendOnlineStatus[displayName] = nil
	else
		if not AIFL.FriendOnlineStatus[displayName] then
			AIFL.FriendOnlineStatus[displayName] = GetTimeStamp()
		end
	end
end

-- Initializes
local function Initialize()
    FRIENDS_LIST.Alliance_OnMouseEnter = function(self, control)
        local row = control:GetParent()
        local data = ZO_ScrollList_GetData(row)
        if(data.alliance) then        
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(data.formattedAllianceName))
        end
        self:EnterRow(row)
    end

	-- Friend online since feature
	for i = 1, GetNumFriends() do
		local displayName, _, playerStatus = GetFriendInfo(i)
		if playerStatus ~= PLAYER_STATUS_OFFLINE then
			AIFL.FriendOnlineStatus[displayName] = AIFL.LogonTime
		end
	end
	
	EVENT_MANAGER:RegisterForEvent(AIFL.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, OnFriendStatusChanged)
	FRIENDS_LIST.Status_OnMouseEnter = function(self, control)
		local row = control:GetParent()
		local data = ZO_ScrollList_GetData(row)

		if data and data.status then
			InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)        
			if data.status == PLAYER_STATUS_OFFLINE then
				SetTooltipText(InformationTooltip, zo_strformat(SI_SOCIAL_LIST_LAST_ONLINE, ZO_FormatDurationAgo(data.secsSinceLogoff + GetFrameTimeSeconds() - data.timeStamp)))
			else
				SetTooltipText(InformationTooltip, GetString("SI_PLAYERSTATUS", data.status) .. ": " .. GetOnlineTimeForFriend(data.displayName))
			end
		end

		self:EnterRow(row)
	end

	ZO_PostHook(ZO_FriendsList, "RefreshData", AIFL.UpdateFriendList)
    FRIENDS_LIST_SCENE:RegisterCallback("StateChange", OnSceneChange)
    ZO_PreHook("ZO_ScrollList_UpdateScroll", OnGroupScroll)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIFL.name then return end
  
    EVENT_MANAGER:UnregisterForEvent(AIFL.name, EVENT_ADD_ON_LOADED) 
    Initialize()
    
    -- Slighlty change the width of the window
    ZO_KeyboardFriendsList:SetWidth(950) 
    
    ModifyFriendListHeader()
end
EVENT_MANAGER:RegisterForEvent(AIFL.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)