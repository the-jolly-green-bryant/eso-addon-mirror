AIGR = {}
local AIGR = AIGR

AIGR.name = "AddedInfoGuildRoster"
AIGR.version = "1.4"

-- In case you want to change these, the sum has to be 620.
-- Also note, that text sometimes does not get truncated.
AIGR.Widths = {
    ["DisplayName"] = 175,
    ["Character"] = 205,
    ["Zone"] = 200,
}

AIGR.GuildMemberOnlineStatus = {}
AIGR.LogonTime = GetTimeStamp()

-- Changes the header row
function ModifyGuildMemberMenuHeader()  
    -- Account Name
    ZO_GuildRosterHeadersDisplayName:SetWidth(AIGR.Widths.DisplayName)
    ZO_GuildRosterHeadersDisplayName:ClearAnchors()
    ZO_GuildRosterHeadersDisplayName:SetAnchor(LEFT, ZO_GuildRosterHeadersRank, RIGHT, 10)
    
    -- Character Name
    -- The added column label control
    local characterNameColumn = ZO_GuildRosterHeadersCharacterName
    
    -- if column label doesn't exist yet, create it
    if not characterNameColumn then
        characterNameColumn = WINDOW_MANAGER:CreateControlFromVirtual(ZO_GuildRosterHeaders:GetName() .. "CharacterName", ZO_GuildRosterHeaders, "ZO_SortHeader")
        characterNameColumn:SetAnchor(TOPLEFT, ZO_GuildRosterHeadersDisplayName, TOPRIGHT)
        characterNameColumn:SetDimensions(AIGR.Widths.Character, 32)
    end
     
    ZO_SortHeader_Initialize(characterNameColumn, GetString(SI_GROUP_LIST_PANEL_NAME_HEADER):upper(), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    GUILD_ROSTER_KEYBOARD.sortHeaderGroup:AddHeader(characterNameColumn)
    
    -- Zone
    ZO_GuildRosterHeadersZone:SetWidth(AIGR.Widths.Zone)
    ZO_GuildRosterHeadersZone:ClearAnchors()
    ZO_GuildRosterHeadersZone:SetAnchor(LEFT, characterNameColumn, RIGHT, 0)     
end

-- Modifies the guild member rows
local function ModifyGuildMemberMenuRow(control) 
    -- Display Name
    local displayNameControl = control:GetNamedChild("DisplayName")
	
    displayNameControl:ClearAnchors()
    displayNameControl:SetAnchor(LEFT, control:GetNamedChild("RankIcon"), RIGHT, 5)
    displayNameControl:SetWidth(AIGR.Widths.DisplayName)
    
    -- Character Name
    local characterNameControl = control:GetNamedChild("CharacterName")
    if characterNameControl == nil then
		characterNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "CharacterName", control, CT_LABEL)
		characterNameControl:SetFont("ZoFontGame")
		characterNameControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
		characterNameControl:SetVerticalAlignment(BOTTOM)
	end

    characterNameControl:SetColor((control.dataEntry.data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT):UnpackRGB())
    characterNameControl:SetWidth(AIGR.Widths.Character)
	characterNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, control.dataEntry.data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	characterNameControl:SetText(control.dataEntry.data.characterName)
 
    -- Zone
    local zoneControl = control:GetNamedChild("Zone")
    zoneControl:ClearAnchors()
    zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
    zoneControl:SetWidth(AIGR.Widths.Zone)
    
    -- Class (move a bit further left than normal)
    local classControl = control:GetNamedChild("ClassIcon")
    classControl:ClearAnchors()
    classControl:SetAnchor(LEFT, zoneControl, RIGHT, 14)
    
    -- Note (move a bit further left than normal)
    local noteControl = control:GetNamedChild("Note")
    noteControl:ClearAnchors()
    noteControl:SetAnchor(LEFT, control:GetNamedChild("Level"), RIGHT, 0)
end

function AIGR.OnSceneChange(oldState, newState)
    if newState == "showing" then zo_callLater(AIGR.UpdateGuildRosterList, 100) end
end

local function OnGroupScroll()
	if ZO_GuildRoster:IsHidden() == false then zo_callLater(AIGR.UpdateGuildRosterList, 250) end
end

-- Runs through each row in the roster to update it
function AIGR.UpdateGuildRosterList()
	if ZO_GuildRoster:IsHidden() == false then
		for _, row in pairs(ZO_GuildRosterList.activeControls) do
			ModifyGuildMemberMenuRow(row)
		end
	end
end

local function GetOnlineTimeForGuildMember(displayName)
	local guildMemberTimestamp = AIGR.GuildMemberOnlineStatus[displayName]
	if not guildMemberTimestamp then return "" end
	local onlineSeconds = GetTimeStamp() - guildMemberTimestamp
	
	if(onlineSeconds < ZO_ONE_MINUTE_IN_SECONDS) then
        return zo_strformat("|cffffff< <<1>>.|r",ZO_FormatTime(60, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
    else
        return zo_strformat("|cffffff<<X:1>>.|r", ZO_FormatTime(onlineSeconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_ASCENDING))
    end

	-- return ZO_FormatTime(onlineSeconds, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS)
end

function OnGuildMemberStatusChanged(evt, guildId, displayName, oldStatus, newStatus)
	if newStatus == PLAYER_STATUS_OFFLINE then
		AIGR.GuildMemberOnlineStatus[displayName] = nil
	else
		if not AIGR.GuildMemberOnlineStatus[displayName] then
			AIGR.GuildMemberOnlineStatus[displayName] = GetTimeStamp()
		end
	end
end


-- Initializes
local function Initialize()
    GUILD_ROSTER_KEYBOARD.Alliance_OnMouseEnter = function(self, control)
        local row = control:GetParent()
        local data = ZO_ScrollList_GetData(row)
        if(data.alliance) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
            SetTooltipText(InformationTooltip, ZO_ColorDef:New(GetAllianceColor(data.alliance)):Colorize(data.formattedAllianceName))
        end
        self:EnterRow(row)
    end

	-- Guild member online since feature
	for guildIndex = 1, GetNumGuilds() do
		local guildId = GetGuildId(guildIndex)
		for i = 1, GetNumGuildMembers(guildId) do
			local displayName, _, _, playerStatus = GetGuildMemberInfo(guildId, i)
			if playerStatus ~= PLAYER_STATUS_OFFLINE then
				AIGR.GuildMemberOnlineStatus[displayName] = AIGR.LogonTime
			end
		end
	end
	
	EVENT_MANAGER:RegisterForEvent(AIGR.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberStatusChanged)
	GUILD_ROSTER_KEYBOARD.Status_OnMouseEnter = function(self, control)
		local row = control:GetParent()
		local data = ZO_ScrollList_GetData(row)

		if data and data.status then
			InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)        
			if data.status == PLAYER_STATUS_OFFLINE then
				SetTooltipText(InformationTooltip, zo_strformat(SI_SOCIAL_LIST_LAST_ONLINE, ZO_FormatDurationAgo(data.secsSinceLogoff + GetFrameTimeSeconds() - data.timeStamp)))
			else
				SetTooltipText(InformationTooltip, GetString("SI_PLAYERSTATUS", data.status) .. ": " .. GetOnlineTimeForGuildMember(data.displayName))
			end
		end

		self:EnterRow(row)
	end


    ZO_PostHook(GUILD_ROSTER_MANAGER, "RefreshAll", AIGR.UpdateGuildRosterList)
	GUILD_ROSTER_SCENE:RegisterCallback("StateChange", AIGR.OnSceneChange)
    ZO_PreHook("ZO_ScrollList_UpdateScroll", OnGroupScroll)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIGR.name then return end
  
    EVENT_MANAGER:UnregisterForEvent(AIGR.name, EVENT_ADD_ON_LOADED)
	Initialize()
	
	-- Slighlty change the width of the window
    ZO_KeyboardFriendsList:SetWidth(950) 
    
    ModifyGuildMemberMenuHeader()
end
EVENT_MANAGER:RegisterForEvent(AIGR.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)