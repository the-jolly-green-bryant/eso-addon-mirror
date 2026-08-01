local CHARACTER_ONLY = 1
local ACCOUNT_ONLY = 2
local CHARACTER_AND_ACCOUNT = 3

local AIGW = AIGW or {}

AIGW.name = "AddedInfoGroupWindow"
AIGW.version = "2.1"
AIGW.lang = "en"

AIGW.Widths = {
    ["Default"] = {
        ["Sum"] = 585,                                      -- Lower than list width!
        ["Offset"] = ZO_KEYBOARD_GROUP_LIST_PADDING_X,      -- 5
        ["Leader"] = ZO_KEYBOARD_GROUP_LIST_LEADER_WIDTH,   -- 35
        ["Character"] = ZO_KEYBOARD_GROUP_LIST_NAME_WIDTH,  -- 205
        ["DisplayName"] = ZO_KEYBOARD_GROUP_LIST_NAME_WIDTH,-- Custom created element
        ["Zone"] = ZO_KEYBOARD_GROUP_LIST_ZONE_WIDTH,       -- 125
        ["Class"] = ZO_KEYBOARD_GROUP_LIST_CLASS_WIDTH,     -- 70
        ["Level"] = ZO_KEYBOARD_GROUP_LIST_LEVEL_WIDTH,     -- 75
        ["Role"] = ZO_KEYBOARD_GROUP_LIST_ROLES_WIDTH,      -- 75
        
        ["GroupWindow"] = 930 -- ZO_GroupMenu_Keyboard:GetWidth()
    },
    ["Extended"] = {
        ["Character"] = 220,
        ["DisplayName"] = 220,
        ["Zone"] = 170,
    },
    ["ExtendedSingle"] = {
        ["Character"] = 390,
        ["DisplayName"] = 390,
        ["Zone"] = 220,
    },
}

AIGW.markSelfTextureNames = {
    ["Star"] 		= "/esoui/art/ava/ava_rankicon_general.dds",
    ["Crown"] 		= "/esoui/art/lfg/lfg_leader_icon.dds",
    ["Leader"] 		= "/esoui/art/guild/guild_rankicon_leader.dds",
    ["Member"] 		= "/esoui/art/guild/guild_rankicon_member.dds",
    ["Officer"] 	= "/esoui/art/guild/guild_rankicon_officer.dds",
    ["Recruit"] 	= "/esoui/art/guild/guild_rankicon_recruit.dds",
    ["Snowflake"]	= "/esoui/art/icons/guildranks/guild_rankicon_misc03_large.dds",
    ["Tri Wing"] 	= "/esoui/art/icons/guildranks/guild_rankicon_misc04_large.dds",
    ["Gear"] 		= "/esoui/art/icons/guildranks/guild_rankicon_misc06_large.dds",
    ["Chain"] 		= "/esoui/art/icons/guildranks/guild_rankicon_misc07_large.dds", 
    ["Skillline"] 	= "/esoui/art/icons/guildranks/guild_rankicon_misc10_large.dds",
    ["Moebius"] 	= "/esoui/art/icons/guildranks/guild_rankicon_misc11_large.dds",
    ["Empty Square"]= "/esoui/art/ava/ava_rankicon_citizen.dds",
    ["Arrow Up"] 	= "/esoui/art/ava/ava_rankicon_recruit.dds",
    ["Square"] 		= "/esoui/art/ava/ava_rankicon_lieutenant.dds",
    ["Star 4 Arms"] = "/esoui/art/ava/ava_rankicon_legate.dds",
    ["Square"] 		= "/esoui/art/ava/ava_rankicon_lieutenant.dds",
}

AIGW.accountWideDefaults = {
	accountWide = true
}

AIGW.defaults = {
	displayMode = CHARACTER_ONLY,
    markSelf = false,
    markSelfTextureName = "Leader",
    sortKey = "characterName",
    shortenRole = false,
    wideMenu = false,
    tooltipMode = ACCOUNT_ONLY,
    markTankAndHeal = false,
    showAlliance = false,
    tooltipInfo = 1,
    markDead = false,
    markDeadColor = {0.63, 0.00, 0.00, 1.00},
    showAvgGroupCP = false,
    showAvARank = false,
    showGender = false,
    showTitle = false,
    showCompanions = false,
	enableCompanionDisplay = false,
}


-- Displaying average group cp
function AIGW.ModifyAvgCP(maxcp, maxplayer, mincp, minplayer, totalcp, show)
    local label = ZO_GroupList:GetNamedChild("AvgCPDisplay")

    if GetGroupSize() > 0 and show then
        local cp = totalcp or 0
        local toolTip = zo_strformat(AIGW_MAX_CP, maxcp, maxplayer) .. "\n" .. zo_strformat(AIGW_MIN_CP, mincp, minplayer)
    
        label:SetHidden(false)
        if AIGW.SV.wideMenu then
            label:SetText(zo_strformat(AIGW_AVGCP, zo_round(cp / GetGroupSize())))
        else    
            label:SetText(zo_strformat(AIGW_AVGCP_SHORT, zo_round(cp / GetGroupSize())))
        end
        
        label:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, BOTTOM, toolTip); end);
        label:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); end);
    else
        label:SetHidden(true)
    end
    
end


-- Override to include player companions in the master list. These may or may not be filtered out later
local function BuildMasterList(self)
    ZO_ClearNumericallyIndexedTable(self.masterList)

    -- Actual players
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local selectedRole = GetGroupMemberSelectedRole(unitTag)
            local isDps = selectedRole == LFG_ROLE_DPS
            local isHeal = selectedRole == LFG_ROLE_HEAL
            local isTank = selectedRole == LFG_ROLE_TANK
            local rawCharacterName = GetRawUnitName(unitTag)
            local zoneName = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(unitTag))
            local unitOnline = IsUnitOnline(unitTag)
            local displayName = GetUnitDisplayName(unitTag) or ""
            local status = unitOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
    
            self.masterList[i] = {
                index = i,
                unitTag = unitTag,
                characterName = GetUnitName(unitTag),
                rawCharacterName = rawCharacterName,
                gender = GetGenderFromNameDescriptor(rawCharacterName),
                formattedZone = zoneName,
                class = GetUnitClassId(unitTag),
                level = GetUnitLevel(unitTag),
                championPoints = GetUnitEffectiveChampionPoints(unitTag),
                leader = IsUnitGroupLeader(unitTag),
                online = unitOnline,
                isPlayer = AreUnitsEqual(unitTag, "player"),
                isDps = isDps,
                isHeal = isHeal,
                isTank = isTank,
                displayName = displayName,
                status = status,
                hasCharacter = true,
                isGroup = true,
                isCompanion = false,
                type = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_SEARCH_TYPE_NAMES,
            }
        end
    end
    
    -- Player companions
    if GetGroupSize() > 0 and GetNumCompanionsInGroup() > 0 and AIGW.SV.showCompanions then
        local companionCounter = GetGroupSize()
        
        for i = 1, GROUP_SIZE_MAX do
            local unitTag = GetGroupUnitTagByIndex(i)
            local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
            if DoesUnitExist(companionTag) then
                --d("Companion found in group: " .. companionTag)
               
                local rawCharacterName = GetRawUnitName(companionTag)
                local zoneName = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(companionTag))
                local unitOnline = IsUnitOnline(unitTag)
                local displayName = GetUnitDisplayName(unitTag) or ""
                local status = unitOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
        
                companionCounter = companionCounter + 1
                self.masterList[companionCounter] = {
                    index = companionCounter,
                    unitTag = companionTag,
                    characterName = GetUnitName(companionTag),
                    rawCharacterName = rawCharacterName,
                    gender = GetUnitGender(companionTag),
                    formattedZone = zoneName,
                    class = GetUnitClassId(companionTag),
                    level = GetUnitLevel(companionTag),
                    championPoints = GetUnitEffectiveChampionPoints(companionTag),
                    leader = false,
                    online = unitOnline,
                    isPlayer = false,
                    isDps = false,
                    isHeal = false,
                    isTank = false,
                    displayName = displayName,
                    status = status,
                    hasCharacter = true,
                    isGroup = true,
                    isCompanion = true,
                    type = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_SEARCH_TYPE_NAMES,
                }
            end 
        end
    end
end

AIGW_LIST_ENTRY_SORT_KEYS = {
    ["displayName"] = { },
    ["characterName"] = { },
    ["formattedZone"] = { tiebreaker = "displayName" },
    ["class"] = { tiebreaker = "displayName", isNumeric = true },
    ["championPoints"] = { tiebreaker = "displayName", isNumeric = true},
    ["level"] = { tiebreaker = "championPoints", isNumeric = true },
    ["role"] = { tiebreaker = "class", isNumeric = true },
}

local function CompareGroupMember(self, listEntry1, listEntry2)
    return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, AIGW_LIST_ENTRY_SORT_KEYS, self.currentSortOrder)
end

local function SortScrollList(self)
    if self.currentSortKey ~= nil and self.currentSortOrder ~= nil then
		AIGW.SV.sortKey = self.currentSortKey
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, function(listEntry1, listEntry2) return CompareGroupMember(self, listEntry1, listEntry2) end)
    end
    self:RefreshVisible()
end

function AIGW.PatchHeaders()
    --ZO_GroupListHeadersArrow:SetParent(nil)
    --ZO_GroupListHeadersArrow:SetHidden(true)
   
    -- Character Name Column
    ZO_GroupListHeadersCharacterName:SetParent(nil)
    ZO_GroupListHeadersCharacterName:SetHidden(true)
	if not AIGW_GroupListHeadersCharacterName then
		AIGW_GroupListHeadersCharacterName = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersCharacterName", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersCharacterName:SetAnchor(TOPLEFT, ZO_GroupListHeaders, TOPLEFT, ZO_KEYBOARD_GROUP_LIST_LEADER_WIDTH)
    AIGW_GroupListHeadersCharacterName:SetWidth(AIGW.Widths["Extended"].CharacterName)
    AIGW_GroupListHeadersCharacterName:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersCharacterName, GetString(AIGW_GRP_CHAR_LONG), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	
	-- Display Name Column
	if not AIGW_GroupListHeadersDisplayName then
		AIGW_GroupListHeadersDisplayName = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersDisplayName", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersDisplayName:SetAnchor(LEFT, AIGW_GroupListHeadersCharacterName, RIGHT)
    AIGW_GroupListHeadersDisplayName:SetWidth(AIGW.Widths["Extended"].DisplayName)
    AIGW_GroupListHeadersDisplayName:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersDisplayName, GetString(AIGW_GRP_ACC_LONG), "displayName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	
	-- Zone Column
    ZO_GroupListHeadersZone:SetParent(nil)
    ZO_GroupListHeadersZone:SetHidden(true)
	if not AIGW_GroupListHeadersZone then
		AIGW_GroupListHeadersZone = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersZone", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersZone:SetAnchor(LEFT, AIGW_GroupListHeadersDisplayName, RIGHT)
    AIGW_GroupListHeadersZone:SetWidth(AIGW.Widths["Extended"].Zone)
    AIGW_GroupListHeadersZone:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersZone, GetString(AIGW_GRP_LOCATION_LONG), "formattedZone", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	-- Class Column
    ZO_GroupListHeadersClass:SetParent(nil)
    ZO_GroupListHeadersClass:SetHidden(true)
	if not AIGW_GroupListHeadersClass then
		AIGW_GroupListHeadersClass = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersClass", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersClass:SetAnchor(LEFT, AIGW_GroupListHeadersZone, RIGHT)
    AIGW_GroupListHeadersClass:SetWidth(AIGW.Widths["Default"].Class)
    AIGW_GroupListHeadersClass:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersClass, GetString(AIGW_GRP_CLASS_LONG), "class", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
	
	-- Level Column
    ZO_GroupListHeadersLevel:SetParent(nil)
    ZO_GroupListHeadersLevel:SetHidden(true)
	if not AIGW_GroupListHeadersLevel then
		AIGW_GroupListHeadersLevel = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersLevel", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersLevel:SetAnchor(LEFT, AIGW_GroupListHeadersClass, RIGHT)
    AIGW_GroupListHeadersLevel:SetWidth(AIGW.Widths["Default"].Level)
    AIGW_GroupListHeadersLevel:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersLevel, GetString(AIGW_GRP_LVL), "level", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
	
	-- Role Column
    ZO_GroupListHeadersRole:SetParent(nil)
    ZO_GroupListHeadersRole:SetHidden(true)
	if not AIGW_GroupListHeadersRole then
		AIGW_GroupListHeadersRole = WINDOW_MANAGER:CreateControlFromVirtual("AIGW_GroupListHeadersRole", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	AIGW_GroupListHeadersRole:SetAnchor(LEFT, AIGW_GroupListHeadersLevel, RIGHT)
    AIGW_GroupListHeadersRole:SetWidth(AIGW.Widths["Default"].Role)
    AIGW_GroupListHeadersRole:SetHeight(32)
    ZO_SortHeader_Initialize(AIGW_GroupListHeadersRole, GetString(AIGW_GRP_ROLE_LONG), "role", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
    GROUP_LIST.sortHeaderGroup:AddHeadersFromContainer(GROUP_LIST.headers)


    GROUP_LIST.headers = {}
    local headersParent = GetControl(GROUP_LIST.control, "Headers")
    local numHeaders = headersParent:GetNumChildren()
    for i = 1, numHeaders do
        GROUP_LIST.headers[i] = headersParent:GetChild(i)
    end
    
    -- Override header coloring function
    GROUP_LIST.UpdateHeaders = function(self, active)
        self.sortHeaderGroup:SetEnabled(active)
    end
    
    
    GROUP_LIST.currentSortKey = AIGW.SV.sortKey
    GROUP_LIST.currentSortOrder = ZO_SORT_ORDER_UP
    GROUP_LIST.SortScrollList = SortScrollList
    
    ZO_PostHook(GROUP_LIST, "RefreshSort", function() AIGW.UpdateGroupList() end)
	
	AIGW.UpdateHeaderWidths()
end

function AIGW.UpdateHeaderWidths()
    local scale = "Default"

	AIGW_GroupListHeadersClass:SetWidth(AIGW.Widths[scale].Class)
	AIGW_GroupListHeadersLevel:SetWidth(AIGW.Widths[scale].Level)
	AIGW_GroupListHeadersRole:SetWidth(AIGW.Widths[scale].Role)

	if AIGW.SV.wideMenu == true then
        scale = "Extended"
        if AIGW.SV.displayMode ~= CHARACTER_AND_ACCOUNT then -- Set to extended single mode if only one column is shown
            scale = "ExtendedSingle"
        end
    end
	AIGW_GroupListHeadersCharacterName:SetWidth(AIGW.SV.displayMode == ACCOUNT_ONLY and 0 or AIGW.Widths[scale].Character + (AIGW.SV.displayMode == CHARACTER_AND_ACCOUNT and 0 or 5))
	AIGW_GroupListHeadersDisplayName:SetWidth(AIGW.SV.displayMode == CHARACTER_ONLY and 0 or AIGW.Widths[scale].DisplayName + (AIGW.SV.displayMode == CHARACTER_AND_ACCOUNT and 0 or 5))
	AIGW_GroupListHeadersZone:SetWidth(AIGW.Widths[scale].Zone + 5)

	AIGW_GroupListHeadersCharacterName:SetHidden(AIGW.SV.displayMode == ACCOUNT_ONLY)
	AIGW_GroupListHeadersDisplayName:SetHidden(AIGW.SV.displayMode == CHARACTER_ONLY)
end

--------------------------------
--------- Member rows ----------
--------------------------------

-- Modifies the group member rows
function AIGW.ModifyGroupMenuRow(control) 
    local data = control.dataEntry.data
    local groupTag = data.unitTag
    local alliance = GetUnitAlliance(data.unitTag)
    
    -- Column Scaling
    local scale = "Default"
    if AIGW.SV.wideMenu == true then
        scale = "Extended"
        if AIGW.SV.displayMode ~= CHARACTER_AND_ACCOUNT then -- Set to extended single mode if only one column is shown
            scale = "ExtendedSingle"
        end
    end
    
    local extraWidth = 0
    if AIGW.SV.shortenRole then
        extraWidth = 25
    end

    --Update Data
    AIGW.updateLeader(control, data)
    AIGW.updateCharacterName(control, data)
    AIGW.updateRole(control, data)
    AIGW.updateZone(control, data)
    AIGW.updateLevel(control, data)
    AIGW.updateDisplayName(control, data)
    
    --Update anchors
    local characterNameControl = control:GetNamedChild("CharacterName")
    local zoneControl = control:GetNamedChild("Zone")
    local displayNameControl = control:GetNamedChild("DisplayName")
    local allianceControl = control:GetNamedChild("Alliance")
    local allianceIconControl = control:GetNamedChild("AllianceIcon")
    local raceControl = control:GetNamedChild("Race")
    local classControl = control:GetNamedChild("Class")

    if AIGW.SV.displayMode == CHARACTER_AND_ACCOUNT then
        if not displayNameControl then
            displayNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "DisplayName", control, CT_LABEL)
            displayNameControl:SetFont("ZoFontGame")
            displayNameControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
            displayNameControl:SetVerticalAlignment(TOP)
            displayNameControl:SetMouseEnabled(true)
        end

        displayNameControl:SetWidth(AIGW.Widths[scale].DisplayName + extraWidth)
        
        zoneControl:SetVerticalAlignment(TOP)

        characterNameControl:SetWidth(AIGW.Widths[scale].Character + extraWidth)

        zoneControl:ClearAnchors()
        zoneControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
        zoneControl:SetWidth(AIGW.Widths[scale].Zone)   
    else
        characterNameControl:SetWidth(AIGW.Widths[scale].Character + extraWidth)
        
        if displayNameControl ~= nil then displayNameControl:SetText("") end
        
        zoneControl:ClearAnchors()
        zoneControl:SetAnchor(LEFT, characterNameControl, RIGHT, 5, 5)
        zoneControl:SetWidth(AIGW.Widths[scale].Zone)
    end
end


------------------
---- Coloring ----
------------------
local deadColor
local function GetRowColor(self, data, mouseOver)
    local textColor = data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT
    local iconColor = data.online and ZO_DEFAULT_ENABLED_COLOR or ZO_DISABLED_TEXT
    
    if IsUnitDead(data.unitTag) then
		if not deadColor then deadcolor = ZO_ColorDef:New(unpack(AIGW.SV.markDeadColor)) end
        textColor = deadColor
    end
    
    if mouseOver then
        textColor = ZO_SELECTED_TEXT
        iconColor = ZO_SELECTED_TEXT
    end

    return textColor, iconColor
end

-- Runs through each row in the roster to update it
function AIGW.UpdateGroupList()
	if ZO_GroupListList:IsHidden() == false then
        local grptotalcp = 0
        local mincp = 9999
        local maxcp = 0
        local playermin = ""
        local playermax = ""
		for _, row in pairs(ZO_GroupListList.activeControls) do
			local data = ZO_ScrollList_GetData(row) or {}
			AIGW.ModifyGroupMenuRow(row)
			
			-- Gather CP
			local cp = data.championPoints
			local newName = ''
			if AIGW.SV.displayMode == CHARACTER_ONLY or AIGW.SV.displayMode == CHARACTER_AND_ACCOUNT then
				newName = data.characterName
			else
				newName = data.displayName
			end
            if cp < mincp then
                mincp = cp
                playermin = newName
            end
            if cp > maxcp then
                maxcp = cp
                playermax = newName
            end
            grptotalcp = grptotalcp + cp
			
			-- Update colors to be right
			GROUP_LIST:ColorRow(row, data, false)
		end

        AIGW.ModifyAvgCP(maxcp, playermax, mincp, playermin, grptotalcp, AIGW.SV.showAvgGroupCP)
        
        AIGW.companionToggle:SetHidden(not AIGW.SV.enableCompanionDisplay or not IsUnitGrouped("player"))
	end
end

----------------------------------
---- Control Update Functions ----
----------------------------------

-- Update Leader Icon Control
function AIGW.updateLeader(control, data)
    local unitTag = data.unitTag

    local leaderIconControl = control:GetNamedChild("LeaderIcon")
    
    local toolTip = ""
    local leader
    local race = ""
    local class = zo_strformat("<<1>>", GetUnitClass(unitTag))

    -- Reseting the texture and visibility of the icon
	leaderIconControl:SetTexture('esoui/art/lfg/lfg_leader_icon.dds')
	leaderIconControl:SetHidden(not data.leader)
    leaderIconControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, zo_strformat("|cf79900<<1>>|r", GetString(AIGW_GRP_LEADER_TT))); ZO_GroupListRow_OnMouseEnter(control); end);
    
    -- Mark Tank and Heal functionality
    if AIGW.SV.markTankAndHeal then
        if data.isTank then
            leaderIconControl:SetHidden(false)
            leaderIconControl:SetTexture('esoui/art/lfg/lfg_tank_up.dds')
            
            if data.leader then
                leader = zo_strformat("|cf79900<<1>>|r\r\n", GetString(AIGW_GRP_LEADER_TT))
                leaderIconControl:SetTexture('esoui/art/lfg/lfg_leader_icon.dds')
            end
            
            -- Locale depended word ordering
            if AIGW.lang == "de" then
                race = zo_strformat("<<m:1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE2), race, class)
            elseif AIGW.lang == "fr" then
                race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE2), class, race)
            else
                race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE2), race, class)
            end
            
            leaderIconControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
        elseif data.isHeal then
            leaderIconControl:SetHidden(false)
            leaderIconControl:SetTexture('esoui/art/lfg/lfg_healer_up.dds')

            if data.leader then
                leader = zo_strformat("|cf79900<<1>>|r\r\n", GetString(AIGW_GRP_LEADER_TT))
                leaderIconControl:SetTexture('esoui/art/lfg/lfg_leader_icon.dds')
            end
            
            -- Locale depended word ordering
            if AIGW.lang == "de" then
                race = zo_strformat("<<m:1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE4), race, class)
            elseif AIGW.lang == "fr" then
                race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE4), class, race)
            else
                race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(unitTag)))
                toolTip = zo_strformat(AIGW_LEADER_FORMAT, leader, GetString(SI_LFGROLE4), race, class)
            end
            
            leaderIconControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
        end
    end
    
    
	-- Mark Self functionality
	if AIGW.SV.markSelf and data.isPlayer then
		leaderIconControl:SetHidden(false)
        leaderIconControl:SetTexture(AIGW.markSelfTextureNames[AIGW.SV.markSelfTextureName])
        
        if toolTip ~= "" then
            toolTip = "\r\n" .. toolTip
		elseif data.leader then
			toolTip = zo_strformat("\r\n|cf79900<<1>>|r", GetString(AIGW_GRP_LEADER_TT))
        end
        
        toolTip = zo_strformat("|c00851f<<1>>|r", GetString(AIGW_GRP_PLAYER_TT)) .. toolTip
		
        leaderIconControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);        
	end
    
    leaderIconControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    
    -- External addon patches
    if AIGW.LeaderPatch then AIGW.LeaderPatch(control, data) end
end

-- Update Character Name Control
function AIGW.updateCharacterName(control, data)
	local characterNameControl = control:GetNamedChild("CharacterName")
    
    -- Using a table to store string segments and then combining them should be much more efficient than "X .. Y .. Z"
    -- Also the code below gets much easier to follow, way less confusing concatinations with possibly empty strings
    local toolTip = {}
    
    -- Charname, Accountname
    if AIGW.SV.tooltipMode == CHARACTER_ONLY then -- Character name only
        table.insert(toolTip, data.characterName)
    elseif AIGW.SV.tooltipMode == ACCOUNT_ONLY then -- Account name only (Vanilla ESO)
        table.insert(toolTip, data.displayName)
    elseif AIGW.SV.tooltipMode == CHARACTER_AND_ACCOUNT then -- Both
        table.insert(toolTip, data.characterName)
        table.insert(toolTip, "\r\n")
        table.insert(toolTip, data.displayName)
    end
    
    -- Title
    if AIGW.SV.showTitle then
        table.insert(toolTip, "\r\n")
        title = GetUnitTitle(data.unitTag)
        if title == "" then
            title = GetString(AIGW_NO_TITLE)
        end
        table.insert(toolTip, title)
    end
    
    --Race and class
    local class = zo_strformat("<<1>>", GetUnitClass(data.unitTag))
    if AIGW.SV.tooltipInfo == 2 then -- Class only
        table.insert(toolTip, "\r\n")
        table.insert(toolTip, class)
    elseif AIGW.SV.tooltipInfo == 3 then -- Race only
        table.insert(toolTip, "\r\n")
        table.insert(toolTip, race)
    elseif AIGW.SV.tooltipInfo == 4 then -- Race and class
        table.insert(toolTip, "\r\n")
        -- Locale depended word ordering
        if AIGW.lang == "de" then
            race = zo_strformat("<<m:1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(data.unitTag)))
            table.insert(toolTip, race)
            table.insert(toolTip, " ")
            table.insert(toolTip, class)
        elseif AIGW.lang == "fr" then
            race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(data.unitTag)))
            table.insert(toolTip, class)
            table.insert(toolTip, " ")
            table.insert(toolTip, race)        
        else
            race = zo_strformat("<<1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(data.unitTag)))
            table.insert(toolTip, race)
            table.insert(toolTip, " ")
            table.insert(toolTip, class)
        end
    end
    
    -- Gender
    if AIGW.SV.showGender then
        if AIGW.SV.tooltipInfo == 1 then
            table.insert(toolTip, "\r\n")
        end
        if GetUnitGender(data.unitTag) == 1 then -- Female
            table.insert(toolTip, zo_iconFormat("/esoui/art/charactercreate/charactercreate_femaleicon_up.dds", 28, 28))
        elseif  GetUnitGender(data.unitTag) == 2 then -- Male
            table.insert(toolTip, zo_iconFormat("/esoui/art/charactercreate/charactercreate_maleicon_up.dds", 28, 28))
        end
    end
    
    --Alliance
    if AIGW.SV.showAlliance then
        table.insert(toolTip, "\r\n")
        local alliance = GetUnitAlliance(data.unitTag)
        if alliance == 1 then -- Aldmeri Dominion
            table.insert(toolTip, zo_strformat("|cc3aa4a<<C:1>>|r", GetAllianceName(alliance)))
        elseif alliance == 2 then -- Ebonheart Pact
            table.insert(toolTip, zo_strformat("|cde594a<<C:1>>|r", GetAllianceName(alliance)))
        elseif alliance == 3 then -- Daggerfall Covenant
            table.insert(toolTip, zo_strformat("|c688fb2<<C:1>>|r", GetAllianceName(alliance)))
        end
    end
    
    toolTip = table.concat(toolTip)

	characterNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
	characterNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	local name = AIGW.SV.displayMode == ACCOUNT_ONLY and data.displayName or data.characterName 
	characterNameControl:SetText(zo_strformat("<<1>>. <<2>>", data.sortIndex, name))
    
    -- External addon patches
    if AIGW.CharacterPatch then AIGW.CharacterPatch(control, data) end
end

-- Update Account Name Control (custom control)
function AIGW.updateDisplayName(control, data)
	local displayNameControl = control:GetNamedChild("DisplayName")
    if displayNameControl == nil then return end
    
	if AIGW.SV.displayMode == CHARACTER_AND_ACCOUNT then
		displayNameControl:SetHidden(false)
		displayNameControl:SetText(data.displayName)
        displayNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
        displayNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
	else
		if displayNameControl ~= nil then
			displayNameControl:SetHidden(true)
		end
	end
    
    -- External addon patches
    if AIGW.DisplayPatch then AIGW.DisplayPatch(control, data) end
end

-- Update Zone Control
function AIGW.updateZone(control, data)
	local zoneControl = control:GetNamedChild("Zone")
    
    zoneControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.formattedZone); ZO_GroupListRow_OnMouseEnter(control); end);
	zoneControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    -- External addon patches
    if AIGW.ZonePatch then AIGW.Zone(control, data) end
end

-- Update Level Control
function AIGW.updateLevel(control, data)
    if AIGW.SV.showAvARank then
        local alliance = GetUnitAlliance(data.unitTag)
        local format = "<<1>>\n<<2>><<C:3>>"
        if alliance == 1 then -- Aldmeri Dominion
            format = "<<1>>\n|cc3aa4a<<2>><<C:3>>|r"
        elseif alliance == 2 then -- Ebonheart Pact
            format = "<<1>>\n|cde594a<<2>><<C:3>>|r"
        elseif alliance == 3 then -- Daggerfall Covenant
            format = "<<1>>\n|c688fb2<<2>><<C:3>>|r"
        end
        local avaRank = GetUnitAvARank(data.unitTag)
        local toolTip = zo_strformat(format, GetString(AIGW_GRP_AVA_STRING), zo_iconFormatInheritColor(GetAvARankIcon(avaRank), 32, 32), GetAvARankName(GetUnitGender(data.unitTag), avaRank)) 
  
        local levelControl = control:GetNamedChild("Level")
        levelControl:SetMouseEnabled(true)   
        levelControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
        levelControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
        
        local championControl = control:GetNamedChild("Champion")
        championControl:SetMouseEnabled(true)
        championControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
        championControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    end
    
    -- External addon patches
    if AIGW.LevelPatch then AIGW.LevelPatch(control, data) end
end

-- Update Role Icons Control
function AIGW.updateRole(control, data)
	local healControl = control:GetNamedChild("RoleHeal")
    local dpsControl = control:GetNamedChild("RoleDPS")
    local tankControl = control:GetNamedChild("RoleTank")
    
    if AIGW.SV.shortenRole then
        -- Set all but first texture control invisible
        healControl:SetHidden(true)
        dpsControl:SetHidden(true)
        tankControl:SetHidden(false)
        
        -- Change texture of the first texture control to the selected role
        if data.isHeal then
            tankControl:SetTexture('esoui/art/lfg/lfg_healer_down.dds')
            tankControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_LFGROLE4)); ZO_GroupListRow_OnMouseEnter(control); end);
            tankControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
        elseif data.isDps then
            tankControl:SetTexture('esoui/art/lfg/lfg_dps_down.dds')
            tankControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_LFGROLE1)); ZO_GroupListRow_OnMouseEnter(control); end);
            tankControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
        elseif data.isTank then
            tankControl:SetTexture('esoui/art/lfg/lfg_tank_down.dds')
            tankControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_LFGROLE2)); ZO_GroupListRow_OnMouseEnter(control); end);
            tankControl:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
        end
        
        -- Show no icon if player is offline
        if not data.online then
            tankControl:SetHidden(true)
        end
    else
        healControl:SetHidden(false)
        dpsControl:SetHidden(false)
        tankControl:SetHidden(false)
        -- Restore tooltip
        tankControl:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(SI_LFGROLE2)); ZO_GroupListRow_OnMouseEnter(control); end);
    end
    
    -- External addon patches
    if AIGW.RolePatch then AIGW.RolePatch(control, data) end
end



function AIGW.OnGroupScroll()
	if ZO_GroupListList:IsHidden() == false then
		if GetGroupSize() > 20 then
			zo_callLater(AIGW.UpdateGroupList, 500)
		end
	end
end




function AIGW.OnGroupMemberDeath(eventCode, unitTag, isDead)
    if string.match(unitTag, "group") then
        AIGW.UpdateGroupList()
    end
end


function AIGW.ExtendedGroupMenu()
    local bg = WINDOW_MANAGER:CreateControl("AIGW_Extended_Group_Menu_BG", ZO_GroupMenu_Keyboard, CT_TEXTURE)
    bg:SetDimensions(1300, 904) -- Large texture to overlap existing one
    bg:SetAnchor(TOPLEFT, ZO_GroupMenu_Keyboard, TOPLEFT, -80, -40)
    bg:SetTexture("esoui/art/miscellaneous/centerscreen_left.dds")
    bg:SetDrawLayer(100)
    --bg:SetAlpha(0.95)
    
    local underlayLeft = WINDOW_MANAGER:CreateControl("AIGW_Extended_Group_Menu_Underlay_Left", AIGW_Extended_Group_Menu_BG, CT_TEXTURE)
    underlayLeft:SetDimensions(256, 1024)
    underlayLeft:SetAnchor(TOPLEFT, AIGW_Extended_Group_Menu_BG, TOPLEFT, 10, -72)
    underlayLeft:SetTexture("esoui/art/miscellaneous/centerscreen_indexArea_left.dds")
    
    local underlayRight = WINDOW_MANAGER:CreateControl("AIGW_Extended_Group_Menu_Underlay_Right", AIGW_Extended_Group_Menu_BG, CT_TEXTURE)
    underlayRight:SetDimensions(128, 1024)
    underlayRight:SetAnchor(TOPLEFT, AIGW_Extended_Group_Menu_Underlay_Left, TOPRIGHT, 0, 0)
    underlayRight:SetTexture("esoui/art/miscellaneous/centerscreen_indexArea_right.dds")
    
    ZO_GroupMenu_Keyboard:SetWidth(1210)

    -- Camera position calculation
    local function CalculateGroupFramingTarget()
        local x = zo_lerp(0, AIGW_Extended_Group_Menu_BG:GetLeft(), 0.5)
        local y = zo_lerp(ZO_TopBarBackground:GetBottom(), ZO_KeybindStripMungeBackgroundTexture:GetTop(), 0.55)
        return x, y
    end

    -- Camera framing fragment
    AIGW.AIGW_FRAME_TARGET_GROUP_PANEL_FRAGMENT = ZO_NormalizedPointFragment:New(CalculateGroupFramingTarget, SetFrameLocalPlayerTarget)

    -- Remove original camera position
    KEYBOARD_GROUP_MENU_SCENE:RemoveFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
    
    -- Remove original menu background
    KEYBOARD_GROUP_MENU_SCENE:RemoveFragment(TREE_UNDERLAY_FRAGMENT)
    
    
    -- Add new camera framing fragment (from group
    KEYBOARD_GROUP_MENU_SCENE:AddFragment(AIGW.AIGW_FRAME_TARGET_GROUP_PANEL_FRAGMENT)
end

-- Initializes
function AIGW.Initialize()
    ZO_PostHook(GROUP_LIST, "RefreshData", AIGW.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_UNIT_DEATH_STATE_CHANGED, AIGW.OnGroupMemberDeath)
    
    GROUP_LIST_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
            AIGW.UpdateGroupList()
        end
    end)
    
    EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_GROUP_MEMBER_JOINED, AIGW.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_GROUP_MEMBER_LEFT, AIGW.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, AIGW.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, AIGW.UpdateGroupList)
    
    ZO_PreHook("ZO_ScrollList_UpdateScroll", AIGW.OnGroupScroll)
    
    -- Adds the checkbox to show/hide companions
    local cb = WINDOW_MANAGER:CreateControlFromVirtual(ZO_GroupList:GetName() .. "ShowCompanions", ZO_GroupList, "ZO_CheckButton")
    cb:SetAnchor(RIGHT, ZO_GroupList, TOPRIGHT, -200, -22)
    ZO_CheckButton_SetLabelText(cb, GetString(AIGW_SHOW_COMPANIONS)) 
    ZO_CheckButton_SetCheckState(cb, AIGW.SV.showCompanions)
    ZO_CheckButton_SetToggleFunction(cb, function()
        AIGW.SV.showCompanions = ZO_CheckButton_IsChecked(cb)
        GROUP_LIST_MANAGER:BuildMasterList()
        GROUP_LIST:RefreshData()
    end)
    cb:SetHidden(not AIGW.SV.enableCompanionDisplay)
	AIGW.companionToggle = cb
    
    
    -- Group avg cp label
    local label = WINDOW_MANAGER:CreateControl(ZO_GroupList:GetName() .. "AvgCPDisplay", ZO_GroupList, CT_LABEL)
    label:SetFont("ZoFontHeader")
    label:SetAnchor(LEFT, ZO_GroupList, TOPLEFT, 35, -22)
    label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    label:SetVerticalAlignment(CENTER)
    label:SetMouseEnabled(true)
    
    -- Custom headers
    AIGW.PatchHeaders()
    
    --Overide for sorting
    GROUP_LIST_MANAGER.BuildMasterList = BuildMasterList
    
    GROUP_LIST.GetRowColors = GetRowColor
end


-- Gets the width a control needs to be to fit the desired text
function AIGW.GetDesiredLabelWidth(control, desiredText)
    local savedWidth = control:GetWidth()
    local savedText = control:GetText()
    control:SetWidth(999)
    control:SetText(desiredText)
    local desiredWidth = control:GetTextWidth()
    control:SetWidth(savedWidth)
    control:SetText(savedText)
    return desiredWidth
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIGW.name then
        return
	end
    EVENT_MANAGER:UnregisterForEvent(AIGW.name, EVENT_ADD_ON_LOADED)
    
    -- Creating saved vars
    AIGW.DS = ZO_SavedVars:NewAccountWide("AIGWSavedVariables", 1.0, nil, AIGW.accountWideDefaults)
    
    if AIGW.DS.accountWide then
		AIGW.SV = ZO_SavedVars:NewAccountWide("AIGWSavedVariables", 1.0, nil, AIGW.defaults)
	else
		AIGW.SV = ZO_SavedVars:New("AIGWSavedVariables", 1.0, nil, AIGW.defaults)
	end
    
    AIGW.lang = GetCVar("language.2")
    
    AIGW.InitializeAddonMenu()
    AIGW.Initialize()
    
    if AIGW.SV.wideMenu then
        AIGW.ExtendedGroupMenu()
    end
    
    AIGW.ModifyAvgCP(0, "", 0, "", nil, false)
end


EVENT_MANAGER:RegisterForEvent(AIGW.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)