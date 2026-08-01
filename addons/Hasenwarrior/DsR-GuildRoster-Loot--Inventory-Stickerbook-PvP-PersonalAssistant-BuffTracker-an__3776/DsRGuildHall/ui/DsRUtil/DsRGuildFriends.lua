DsRGuildFriends = {}
local DsRGuildFriends = DsRGuildFriends

DsRGuildFriends.Widths = {
    ["DisplayName"] = 190,
    ["Character"] = 220,
    ["Zone"] = 210,
}

DsRGuildFriends.FriendOnlineStatus = {}
DsRGuildFriends.LogonTime          = GetTimeStamp()

local tins = table.insert

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Changes the header row
local function ModifyFriendListHeader()  
    -- Account Name
    ZO_KeyboardFriendsListHeadersDisplayName:SetWidth(DsRGuildFriends.Widths.DisplayName)
    ZO_KeyboardFriendsListHeadersDisplayName:ClearAnchors()
    ZO_KeyboardFriendsListHeadersDisplayName:SetAnchor(LEFT, ZO_KeyboardFriendsListHeadersAlliance, RIGHT, 20)
    
    -- Character Name
    -- The added column label control
    local characterNameColumn = ZO_KeyboardFriendsListHeadersCharacterName
    
    -- if column label doesn't exist yet, create it
    if not characterNameColumn then
        characterNameColumn = WINDOW_MANAGER:CreateControlFromVirtual(ZO_KeyboardFriendsListHeaders:GetName() .. "CharacterName", ZO_KeyboardFriendsListHeaders, "ZO_SortHeader")
        characterNameColumn:SetAnchor(TOPLEFT, ZO_KeyboardFriendsListHeadersDisplayName, TOPRIGHT)
        characterNameColumn:SetDimensions(DsRGuildFriends.Widths.Character, 32)
    end
    ZO_SortHeader_Initialize(characterNameColumn, GetString(SI_GROUP_LIST_PANEL_NAME_HEADER):upper(), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    FRIENDS_LIST.sortHeaderGroup:AddHeader(characterNameColumn)
    
    -- Zone
    ZO_KeyboardFriendsListHeadersZone:SetWidth(DsRGuildFriends.Widths.Zone)
    ZO_KeyboardFriendsListHeadersZone:ClearAnchors()
    ZO_KeyboardFriendsListHeadersZone:SetAnchor(LEFT, characterNameColumn, RIGHT, 0)     

end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Modifies the guild member rows
local function ModifyFriendListRow(control) 

    -- Display Name
    local displayNameControl = control:GetNamedChild("DisplayName")

    displayNameControl:ClearAnchors()
    displayNameControl:SetAnchor(LEFT, control:GetNamedChild("AllianceIcon"), RIGHT, 15)
    displayNameControl:SetWidth(DsRGuildFriends.Widths.DisplayName)
    
    -- Character Name
    local characterNameControl = control:GetNamedChild("CharacterName")
    if characterNameControl == nil then
		characterNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "CharacterName", control, CT_LABEL)
		characterNameControl:SetFont("ZoFontGame")
		characterNameControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
		characterNameControl:SetVerticalAlignment(BOTTOM)
	end
	
	characterNameControl:SetColor((control.dataEntry.data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT):UnpackRGB())
    characterNameControl:SetWidth(DsRGuildFriends.Widths.Character)
	characterNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, control.dataEntry.data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	characterNameControl:SetText(control.dataEntry.data.characterName)
 
    -- Zone
    local zoneControl = control:GetNamedChild("Zone")
    zoneControl:ClearAnchors()
    zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
    zoneControl:SetWidth(DsRGuildFriends.Widths.Zone)
    
    -- Class (move a bit further left than normal)
    local classControl = control:GetNamedChild("ClassIcon")
    classControl:ClearAnchors()
    classControl:SetAnchor(LEFT, zoneControl, RIGHT, 14)
    
    -- Note (move a bit further left than normal)
    local noteControl = control:GetNamedChild("Note")
    noteControl:ClearAnchors()
    noteControl:SetAnchor(LEFT, control:GetNamedChild("Level"), RIGHT, 0)
end

-------------------------------------------------------------------------------------------------------------------------------------------------

-- GIBT AKTUELL ERRORMELDUNGEN WENN LISTE GROSS IST!!!!!!

-- function DsRGuildFriends.FriendListCustomIcons()
--     local setupEntry = FRIENDS_LIST_MANAGER.SetupEntry
--     function FRIENDS_LIST_MANAGER:SetupEntry( control, data, selected )
--         setupEntry( self, control, data, selected )

--         local AllCont    = control:GetNamedChild( "AllianceIcon" )

--         -- AllianceIcon
--         if data.alliance == 1 then
--             AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_aldmeri.dds" )
--         elseif data.alliance == 2 then
--             AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_ebonheart.dds" )
--         elseif data.alliance == 3 then
--             AllCont:SetTexture( "/esoui/art/ava/ava_hud_emblem_daggerfall.dds" )
--         end
--     end
-- end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function OnSceneChange(old, new)
    if new == "showing" then zo_callLater(DsRGuildFriends.UpdateFriendList, 50) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function OnGroupScroll()
	if ZO_KeyboardFriendsList:IsHidden() == false then zo_callLater(DsRGuildFriends.UpdateFriendList, 100) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Runs through each row in the roster to update it
function DsRGuildFriends.UpdateFriendList()
	if ZO_KeyboardFriendsList:IsHidden() == false then
		for _, row in pairs(ZO_KeyboardFriendsListList.activeControls) do
			ModifyFriendListRow(row)
            -- DsRGuildFriends.FriendListCustomIcons()
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetOnlineTimeForFriend(displayName)
	local friendTimestamp = DsRGuildFriends.FriendOnlineStatus[displayName]
	if not friendTimestamp then return "" end
	local onlineSeconds = GetTimeStamp() - friendTimestamp
	
	if(onlineSeconds < ZO_ONE_MINUTE_IN_SECONDS) then
        return zo_strformat("|cffffff< <<1>>.|r",ZO_FormatTime(60, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
    else
        return zo_strformat("|cffffff<<X:1>>.|r", ZO_FormatTime(onlineSeconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function OnFriendStatusChanged(evt, displayName, characterName, oldStatus, newStatus)
	if newStatus == PLAYER_STATUS_OFFLINE then
		DsRGuildFriends.FriendOnlineStatus[displayName] = nil
	else
		if not DsRGuildFriends.FriendOnlineStatus[displayName] then
			DsRGuildFriends.FriendOnlineStatus[displayName] = GetTimeStamp()
		end
	end
    if DsRAutoINV.cfg.ExtraNamesLogin ~= nil and DsRAutoINV.cfg.FriendsOnOff == true then
        DsRGuildFriends.LoadNamesStatus(evt, displayName, characterName, oldStatus, newStatus)
    end
    if DsRAutoINV.cfg.FriendsOnOff == false and DsRAutoINV.cfg.FriendsColor == true then
        if newStatus == PLAYER_STATUS_OFFLINE then
            d(zo_strformat(GetString(DsRGuildMenue_DsRFriendsOFFLINE), ZO_LinkHandler_CreatePlayerLink(displayName), characterName))
        elseif newStatus == PLAYER_STATUS_ONLINE then
            d(zo_strformat(GetString(DsRGuildMenue_DsRFriendsONLINE), ZO_LinkHandler_CreatePlayerLink(displayName), characterName))
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Extra Name Login / Logoff 
function DsRGuildFriends.LoadNamesStatus(evt, displayName, characterName, oldStatus, newStatus)
	local splitted  = DsRGuildFriends.createList()

	for k,v in pairs(splitted) do
        if displayName == v then
            if newStatus == PLAYER_STATUS_OFFLINE then
                d(zo_strformat(GetString(DsRGuildMenue_DsRFriendsOFFLINE), ZO_LinkHandler_CreatePlayerLink(displayName), characterName))
            elseif newStatus == PLAYER_STATUS_ONLINE then
                d(zo_strformat(GetString(DsRGuildMenue_DsRFriendsONLINE), ZO_LinkHandler_CreatePlayerLink(displayName), characterName))
            end
        end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildFriends.createList()
    local splitted = {}

    for line in DsRAutoINV.cfg.ExtraNamesLogin:gmatch("[^\r\n;]+") do
        tins(splitted, line)
    end
    return splitted
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Initializes
local function Initialize()
    FRIENDS_LIST.Alliance_OnMouseEnter = function(self, control)
        local row    = control:GetParent()
        local data   = ZO_ScrollList_GetData(row)
        if(data.alliance) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            if data.alliance == 1 then
                SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Aldmeri)))
            elseif data.alliance == 2 then
                SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Ebonheart)))
            elseif data.alliance == 3 then
                SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(GetString(DsR_Daggerfall)))
            end
        end
        self:EnterRow(row)
    end

	-- Friend online since feature
	for i = 1, GetNumFriends() do
		local displayName, _, playerStatus = GetFriendInfo(i)
		if playerStatus ~= PLAYER_STATUS_OFFLINE then
			DsRGuildFriends.FriendOnlineStatus[displayName] = DsRGuildFriends.LogonTime
		end
	end
	
	EVENT_MANAGER:RegisterForEvent(DsRGuildFriends.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, OnFriendStatusChanged)
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

	if DsRAutoINV.cfg.FriendsOnOff == false and DsRAutoINV.cfg.FriendsColor == true then
        EVENT_MANAGER:UnregisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED)
    elseif DsRAutoINV.cfg.FriendsOnOff == true then
		EVENT_MANAGER:UnregisterForEvent("ChatRouter", EVENT_FRIEND_PLAYER_STATUS_CHANGED)
	end

	ZO_PostHook(ZO_FriendsList, "RefreshData", DsRGuildFriends.UpdateFriendList)
    FRIENDS_LIST_SCENE:RegisterCallback("StateChange", OnSceneChange)
    ZO_PreHook("ZO_ScrollList_UpdateScroll", OnGroupScroll)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildFriends.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildFriends.name, EVENT_ADD_ON_LOADED) 
    Initialize()
    
    ZO_KeyboardFriendsList:SetWidth(950) 
    
    ModifyFriendListHeader()
    -- DsRGuildFriends.FriendListCustomIcons()
end
