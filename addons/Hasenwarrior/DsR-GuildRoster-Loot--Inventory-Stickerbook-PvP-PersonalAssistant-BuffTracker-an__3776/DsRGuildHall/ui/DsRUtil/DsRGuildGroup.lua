DsRGuildGroup = {}
local DsRGuildGroup = DsRGuildGroup  or {}

DsRGuildGroup.name = "DsRGuildGroup"

DsRGuildGroup.Widths = {
    ["Default"] = {
        ["Sum"]         = 585,                                      
        ["Offset"]      = 5,
        ["Leader"]      = 35,
        ["Character"]   = 120,
        ["DisplayName"] = 120,
        ["Zone"]        = 120,
        ["Class"]       = 70,
        ["Level"]       = 75,
        ["Role"]        = 75,
        
        ["GroupWindow"] = 930 
    },
}

DsRGuildGroup.defaults = {
    markSelf = false,
    sortKey = "characterName",
    shortenRole = false,
    wideMenu = true,
    markTankAndHeal = false,
    showAlliance = false,
    tooltipInfo = 1,
    markDead = false,
    markDeadColor = {0.63, 0.00, 0.00, 1.00},
    showAvgGroupCP = true,
    showAvARank = false,
    showGender = false,
    showTitle = false,
    -- showCompanions = true,
	-- enableCompanionDisplay = true,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Displaying average group cp
function DsRGuildGroup.ModifyAvgCP(maxcp, maxplayer, mincp, minplayer, totalcp, show)
    local label = ZO_GroupList:GetNamedChild("AvgCPDisplay")

    if GetGroupSize() > 0 and show then
        local cp = totalcp or 0
    
        label:SetHidden(false)
        label:SetText(zo_strformat(DsRGuildGroup_AVGCP, zo_round(cp / GetGroupSize())))
    else
        label:SetHidden(true)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
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
    if GetGroupSize() > 0 and GetNumCompanionsInGroup() > 0 then
        local companionCounter = GetGroupSize()
        
        for i = 1, GROUP_SIZE_MAX do
            local unitTag = GetGroupUnitTagByIndex(i)
            local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
            if DoesUnitExist(companionTag) then
               
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

DsRGuildGroup_LIST_ENTRY_SORT_KEYS = {
    ["displayName"]     = { },
    ["characterName"]   = { },
    ["formattedZone"]   = { tiebreaker = "displayName" },
    ["class"]           = { tiebreaker = "displayName", isNumeric = true },
    ["championPoints"]  = { tiebreaker = "displayName", isNumeric = true},
    ["level"]           = { tiebreaker = "championPoints", isNumeric = true },
    ["role"]            = { tiebreaker = "class", isNumeric = true },
}

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CompareGroupMember(self, listEntry1, listEntry2)
    return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, DsRGuildGroup_LIST_ENTRY_SORT_KEYS, self.currentSortOrder)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SortScrollList(self)
    if self.currentSortKey ~= nil and self.currentSortOrder ~= nil then
		-- DsRGuildGroup.SV.sortKey = self.currentSortKey
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, function(listEntry1, listEntry2) return CompareGroupMember(self, listEntry1, listEntry2) end)
    end
    self:RefreshVisible()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.PatchHeaders()
    -- Character Name Column
    ZO_GroupListHeadersCharacterName:SetParent(nil)
    ZO_GroupListHeadersCharacterName:SetHidden(true)
	if not DsRGuildGroup_GroupListHeadersCharacterName then
		DsRGuildGroup_GroupListHeadersCharacterName = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersCharacterName", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersCharacterName:SetAnchor(TOPLEFT, ZO_GroupListHeaders, TOPLEFT, ZO_KEYBOARD_GROUP_LIST_LEADER_WIDTH)
    DsRGuildGroup_GroupListHeadersCharacterName:SetWidth(DsRGuildGroup.Widths["Default"].CharacterName)
    DsRGuildGroup_GroupListHeadersCharacterName:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersCharacterName, GetString(DsRGuildGroup_GRP_CHAR_LONG), "characterName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	
	-- Display Name Column
	if not DsRGuildGroup_GroupListHeadersDisplayName then
		DsRGuildGroup_GroupListHeadersDisplayName = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersDisplayName", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersDisplayName:SetAnchor(LEFT, DsRGuildGroup_GroupListHeadersCharacterName, RIGHT)
    DsRGuildGroup_GroupListHeadersDisplayName:SetWidth(DsRGuildGroup.Widths["Default"].DisplayName)
    DsRGuildGroup_GroupListHeadersDisplayName:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersDisplayName, GetString(DsRGuildGroup_GRP_ACC_LONG), "displayName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	
	-- Zone Column
    ZO_GroupListHeadersZone:SetParent(nil)
    ZO_GroupListHeadersZone:SetHidden(true)
	if not DsRGuildGroup_GroupListHeadersZone then
		DsRGuildGroup_GroupListHeadersZone = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersZone", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersZone:SetAnchor(LEFT, DsRGuildGroup_GroupListHeadersDisplayName, RIGHT)
    DsRGuildGroup_GroupListHeadersZone:SetWidth(DsRGuildGroup.Widths["Default"].Zone)
    DsRGuildGroup_GroupListHeadersZone:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersZone, GetString(DsRGuildGroup_GRP_LOCATION_LONG), "formattedZone", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    
	-- Class Column
    ZO_GroupListHeadersClass:SetParent(nil)
    ZO_GroupListHeadersClass:SetHidden(true)
	if not DsRGuildGroup_GroupListHeadersClass then
		DsRGuildGroup_GroupListHeadersClass = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersClass", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersClass:SetAnchor(LEFT, DsRGuildGroup_GroupListHeadersZone, RIGHT)
    DsRGuildGroup_GroupListHeadersClass:SetWidth(DsRGuildGroup.Widths["Default"].Class)
    DsRGuildGroup_GroupListHeadersClass:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersClass, GetString(DsRGuildGroup_GRP_CLASS_LONG), "class", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
	
	-- Level Column
    ZO_GroupListHeadersLevel:SetParent(nil)
    ZO_GroupListHeadersLevel:SetHidden(true)
	if not DsRGuildGroup_GroupListHeadersLevel then
		DsRGuildGroup_GroupListHeadersLevel = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersLevel", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersLevel:SetAnchor(LEFT, DsRGuildGroup_GroupListHeadersClass, RIGHT)
    DsRGuildGroup_GroupListHeadersLevel:SetWidth(DsRGuildGroup.Widths["Default"].Level)
    DsRGuildGroup_GroupListHeadersLevel:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersLevel, GetString(DsRGuildGroup_GRP_LVL), "level", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
	
	-- Role Column
    ZO_GroupListHeadersRole:SetParent(nil)
    ZO_GroupListHeadersRole:SetHidden(true)
	if not DsRGuildGroup_GroupListHeadersRole then
		DsRGuildGroup_GroupListHeadersRole = WINDOW_MANAGER:CreateControlFromVirtual("DsRGuildGroup_GroupListHeadersRole", ZO_GroupListHeaders, "ZO_SortHeader")
    end
	DsRGuildGroup_GroupListHeadersRole:SetAnchor(LEFT, DsRGuildGroup_GroupListHeadersLevel, RIGHT)
    DsRGuildGroup_GroupListHeadersRole:SetWidth(DsRGuildGroup.Widths["Default"].Role)
    DsRGuildGroup_GroupListHeadersRole:SetHeight(32)
    ZO_SortHeader_Initialize(DsRGuildGroup_GroupListHeadersRole, GetString(DsRGuildGroup_GRP_ROLE_LONG), "role", ZO_SORT_ORDER_UP, TEXT_ALIGN_CENTER, "ZoFontGameLargeBold")
    
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
    
    
    GROUP_LIST.currentSortKey = DsRGuildGroup.defaults.sortKey
    GROUP_LIST.currentSortOrder = ZO_SORT_ORDER_UP
    GROUP_LIST.SortScrollList = SortScrollList
    
    ZO_PostHook(GROUP_LIST, "RefreshSort", function() DsRGuildGroup.UpdateGroupList() end)
	
	DsRGuildGroup.UpdateHeaderWidths()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.UpdateHeaderWidths()
	DsRGuildGroup_GroupListHeadersClass:SetWidth(DsRGuildGroup.Widths["Default"].Class)
	DsRGuildGroup_GroupListHeadersLevel:SetWidth(DsRGuildGroup.Widths["Default"].Level)
	DsRGuildGroup_GroupListHeadersRole:SetWidth(DsRGuildGroup.Widths["Default"].Role)

	DsRGuildGroup_GroupListHeadersCharacterName:SetWidth(DsRGuildGroup.Widths["Default"].Character + DsRGuildGroup.Widths["Default"].DisplayName)
	DsRGuildGroup_GroupListHeadersDisplayName:SetWidth(DsRGuildGroup.Widths["Default"].Character + DsRGuildGroup.Widths["Default"].DisplayName)
	DsRGuildGroup_GroupListHeadersZone:SetWidth(DsRGuildGroup.Widths["Default"].Zone + 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
------------ Member rows ----------
--------------------------------

-- Modifies the group member rows
function DsRGuildGroup.ModifyGroupMenuRow(control) 
    local data = control.dataEntry.data

    --Update Data
    DsRGuildGroup.updateLeader(control, data)
    DsRGuildGroup.updateCharacterName(control, data)
    DsRGuildGroup.updateRole(control, data)
    DsRGuildGroup.updateZone(control, data)
    DsRGuildGroup.updateDisplayName(control, data)
    DsRGuildGroup.updateLevel(control, data)
    
    --Update anchors
    local characterNameControl  = control:GetNamedChild("CharacterName")
    local zoneControl           = control:GetNamedChild("Zone")
    local displayNameControl    = control:GetNamedChild("DisplayName")

    if not displayNameControl then
        displayNameControl = WINDOW_MANAGER:CreateControl(control:GetName() .. "DisplayName", control, CT_LABEL)
        displayNameControl:SetFont("ZoFontGame")
        displayNameControl:SetAnchor(LEFT, characterNameControl, RIGHT, 0)
        displayNameControl:SetVerticalAlignment(TOP)
        displayNameControl:SetMouseEnabled(true)
    end
    displayNameControl:SetWidth(240)
    
    zoneControl:SetVerticalAlignment(TOP)
    characterNameControl:SetWidth(240)
    zoneControl:ClearAnchors()
    zoneControl:SetAnchor(LEFT, displayNameControl, RIGHT, 0)
    zoneControl:SetWidth(120)   
end


-------------------------------------------------------------------------------------------------------------------------------------------------
-- Runs through each row in the roster to update it
function DsRGuildGroup.UpdateGroupList()
	if ZO_GroupListList:IsHidden() == false then
        local grptotalcp = 0
        local mincp = 9999
        local maxcp = 0
        local playermin = ""
        local playermax = ""
		for _, row in pairs(ZO_GroupListList.activeControls) do
			local data = ZO_ScrollList_GetData(row) or {}
			DsRGuildGroup.ModifyGroupMenuRow(row)
			
			-- Gather CP
			local cp = data.championPoints
			local newName = ''
            newName = data.characterName

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

        DsRGuildGroup.ModifyAvgCP(maxcp, playermax, mincp, playermin, grptotalcp, true)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
------- Control Update Functions ----
----------------------------------

-- Update Leader Icon Control
function DsRGuildGroup.updateLeader(control, data)
    local unitTag = data.unitTag

    local leaderIconControl = control:GetNamedChild("LeaderIcon")
    local leader
    local class = zo_strformat("<<1>>", GetUnitClass(unitTag))

    -- Reseting the texture and visibility of the icon
    if data.leader then
        leaderIconControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, zo_strformat("|cf79900<<1>>|r", GetString(DsRGuildGroup_GRP_LEADER_TT))); ZO_GroupListRow_OnMouseEnter(control); end);
        leaderIconControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    end

    -- External addon patches
    if DsRGuildGroup.LeaderPatch then DsRGuildGroup.LeaderPatch(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Character Name Control
function DsRGuildGroup.updateCharacterName(control, data)
	local characterNameControl = control:GetNamedChild("CharacterName")
    
    -- Using a table to store string segments and then combining them should be much more efficient than "X .. Y .. Z"
    -- Also the code below gets much easier to follow, way less confusing concatinations with possibly empty strings
    local toolTip = {}
    
    -- Charname, Accountname
    table.insert(toolTip, data.characterName)
    table.insert(toolTip, "\r\n")
    table.insert(toolTip, data.displayName)
    
    -- Title
    table.insert(toolTip, "\r\n")
    title = GetUnitTitle(data.unitTag)
    if title == "" then
        title = GetString(DsRGuildGroup_NO_TITLE)
    end
    table.insert(toolTip, title)
    
    --Race and class
    local class = zo_strformat("<<1>>", GetUnitClass(data.unitTag))
    table.insert(toolTip, "\r\n")
    race = zo_strformat("<<m:1>>", GetRaceName(GENDER_NEUTER, GetUnitRaceId(data.unitTag)))
    table.insert(toolTip, race)
    table.insert(toolTip, " ")
    table.insert(toolTip, class)

    table.insert(toolTip, "\r\n")
    if GetUnitGender(data.unitTag) == 1 then -- Female
        table.insert(toolTip, zo_iconFormat("/esoui/art/charactercreate/charactercreate_femaleicon_up.dds", 28, 28))
    elseif  GetUnitGender(data.unitTag) == 2 then -- Male
        table.insert(toolTip, zo_iconFormat("/esoui/art/charactercreate/charactercreate_maleicon_up.dds", 28, 28))
    end
    
    --Alliance
    table.insert(toolTip, "\r\n")
    local alliance = GetUnitAlliance(data.unitTag)
    if alliance == 1 then -- Aldmeri Dominion
        table.insert(toolTip, zo_strformat("|cc3aa4a<<C:1>>|r", GetAllianceName(alliance)))
    elseif alliance == 2 then -- Ebonheart Pact
        table.insert(toolTip, zo_strformat("|cde594a<<C:1>>|r", GetAllianceName(alliance)))
    elseif alliance == 3 then -- Daggerfall Covenant
        table.insert(toolTip, zo_strformat("|c688fb2<<C:1>>|r", GetAllianceName(alliance)))
    end
    
    toolTip = table.concat(toolTip)

	local name = data.characterName 
	characterNameControl:SetText(zo_strformat("<<1>>. <<2>>", data.sortIndex, name))
    
    -- External addon patches
    if DsRGuildGroup.CharacterPatch then DsRGuildGroup.CharacterPatch(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Account Name Control (custom control)
function DsRGuildGroup.updateDisplayName(control, data)
	local displayNameControl = control:GetNamedChild("DisplayName")
    if displayNameControl == nil then return end

    displayNameControl:SetHidden(false)
	displayNameControl:SetText(data.displayName)
    displayNameControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.characterName); ZO_GroupListRow_OnMouseEnter(control); end);
    displayNameControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    -- External addon patches
    if DsRGuildGroup.DisplayPatch then DsRGuildGroup.DisplayPatch(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Zone Control
function DsRGuildGroup.updateZone(control, data)
	local zoneControl = control:GetNamedChild("Zone")
    
    zoneControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.formattedZone); ZO_GroupListRow_OnMouseEnter(control); end);
	zoneControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    -- External addon patches
    if DsRGuildGroup.ZonePatch then DsRGuildGroup.Zone(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Level Control
function DsRGuildGroup.updateLevel(control, data)
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
    local toolTip = zo_strformat(format, GetString(DsRGuildGroup_GRP_AVA_STRING), zo_iconFormatInheritColor(GetAvARankIcon(avaRank), 32, 32), GetAvARankName(GetUnitGender(data.unitTag), avaRank)) 

    local levelControl = control:GetNamedChild("Level")
    levelControl:SetMouseEnabled(true)   
    levelControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
    levelControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    local championControl = control:GetNamedChild("Champion")
    championControl:SetMouseEnabled(true)
    championControl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTip); ZO_GroupListRow_OnMouseEnter(control); end);
    championControl:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip(); ZO_GroupListRow_OnMouseExit(control); end);
    
    -- External addon patches
    if DsRGuildGroup.LevelPatch then DsRGuildGroup.LevelPatch(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Update Role Icons Control
function DsRGuildGroup.updateRole(control, data)
	local healControl = control:GetNamedChild("RoleHeal")
    local dpsControl = control:GetNamedChild("RoleDPS")
    local tankControl = control:GetNamedChild("RoleTank")
    
    healControl:SetHidden(false)
    dpsControl:SetHidden(false)
    tankControl:SetHidden(false)
    
    -- Show no icon if player is offline
    if not data.online then
        healControl:SetHidden(true)
        dpsControl:SetHidden(true)
        tankControl:SetHidden(true)
    end
    
    -- External addon patches
    if DsRGuildGroup.RolePatch then DsRGuildGroup.RolePatch(control, data) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.OnGroupScroll()
	if ZO_GroupListList:IsHidden() == false then
		if GetGroupSize() > 20 then
			zo_callLater(DsRGuildGroup.UpdateGroupList, 500)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.OnGroupMemberDeath(eventCode, unitTag, isDead)
    if string.match(unitTag, "group") then
        DsRGuildGroup.UpdateGroupList()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.ExtendedGroupMenu()
    local bg = WINDOW_MANAGER:CreateControl("DsRGuildGroup_Extended_Group_Menu_BG", ZO_GroupMenu_Keyboard, CT_TEXTURE)
    if PerfectPixel then
        bg:SetDimensions(0, 0) -- Large texture to overlap existing one
        bg:SetAnchor(TOPLEFT, ZO_GroupMenu_Keyboard, TOPLEFT, -80, -40)
        bg:SetTexture("esoui/art/miscellaneous/centerscreen_left.dds")
        bg:SetDrawLayer(100)
        bg:SetAlpha(0.85)
    else
        bg:SetDimensions(350, 904) -- Large texture to overlap existing one
        bg:SetAnchor(TOPLEFT, ZO_GroupMenu_Keyboard, TOPLEFT, -80, -40)
        bg:SetTexture("esoui/art/miscellaneous/centerscreen_left.dds")
        bg:SetDrawLayer(100)
        bg:SetAlpha(0.85)
    end

    local underlayLeft = WINDOW_MANAGER:CreateControl("DsRGuildGroup_Extended_Group_Menu_Underlay_Left", DsRGuildGroup_Extended_Group_Menu_BG, CT_TEXTURE)
    underlayLeft:SetDimensions(256, 1024)
    underlayLeft:SetAnchor(TOPLEFT, DsRGuildGroup_Extended_Group_Menu_BG, TOPLEFT, 10, -72)
    underlayLeft:SetTexture("esoui/art/miscellaneous/centerscreen_indexArea_left.dds")
    
    local underlayRight = WINDOW_MANAGER:CreateControl("DsRGuildGroup_Extended_Group_Menu_Underlay_Right", DsRGuildGroup_Extended_Group_Menu_BG, CT_TEXTURE)
    underlayRight:SetDimensions(128, 1024)
    underlayRight:SetAnchor(TOPLEFT, DsRGuildGroup_Extended_Group_Menu_Underlay_Left, TOPRIGHT, 0, 0)
    underlayRight:SetTexture("esoui/art/miscellaneous/centerscreen_indexArea_right.dds")
    
    ZO_GroupMenu_Keyboard:SetWidth(1210)

    -- Camera position calculation
    local function CalculateGroupFramingTarget()
        local x = zo_lerp(0, DsRGuildGroup_Extended_Group_Menu_BG:GetLeft(), 0.5)
        local y = zo_lerp(ZO_TopBarBackground:GetBottom(), ZO_KeybindStripMungeBackgroundTexture:GetTop(), 0.55)
        return x, y
    end

    DsRGuildGroup.DsRGuildGroup_FRAME_TARGET_GROUP_PANEL_FRAGMENT = ZO_NormalizedPointFragment:New(CalculateGroupFramingTarget, SetFrameLocalPlayerTarget)

    KEYBOARD_GROUP_MENU_SCENE:RemoveFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
    KEYBOARD_GROUP_MENU_SCENE:RemoveFragment(TREE_UNDERLAY_FRAGMENT)

    KEYBOARD_GROUP_MENU_SCENE:AddFragment(DsRGuildGroup.DsRGuildGroup_FRAME_TARGET_GROUP_PANEL_FRAGMENT)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Initializes
function DsRGuildGroup.Initialize()
    ZO_PostHook(GROUP_LIST, "RefreshData", DsRGuildGroup.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(DsRGuildGroup.name, EVENT_UNIT_DEATH_STATE_CHANGED, DsRGuildGroup.OnGroupMemberDeath)
    
    GROUP_LIST_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
            DsRGuildGroup.UpdateGroupList()
        end
    end)
    
    EVENT_MANAGER:RegisterForEvent(DsRGuildGroup.name, EVENT_GROUP_MEMBER_JOINED, DsRGuildGroup.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(DsRGuildGroup.name, EVENT_GROUP_MEMBER_LEFT, DsRGuildGroup.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(DsRGuildGroup.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, DsRGuildGroup.UpdateGroupList)
    EVENT_MANAGER:RegisterForEvent(DsRGuildGroup.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, DsRGuildGroup.UpdateGroupList)
    
    ZO_PreHook("ZO_ScrollList_UpdateScroll", DsRGuildGroup.OnGroupScroll)
    
    -- Adds the checkbox to show/hide companions
    -- local cb = WINDOW_MANAGER:CreateControlFromVirtual(ZO_GroupList:GetName() .. "ShowCompanions", ZO_GroupList, "ZO_CheckButton")
    -- cb:SetAnchor(RIGHT, ZO_GroupList, TOPRIGHT, -200, -22)
    -- ZO_CheckButton_SetLabelText(cb, GetString(DsRGuildGroup_SHOW_COMPANIONS)) 
    -- ZO_CheckButton_SetCheckState(cb, true)
    -- ZO_CheckButton_SetToggleFunction(cb, function()
    --     GROUP_LIST_MANAGER:BuildMasterList()
    --     GROUP_LIST:RefreshData()
    -- end)
    -- cb:SetHidden(not true)
	-- DsRGuildGroup.companionToggle = cb
    
    -- Group avg cp label
    local label = WINDOW_MANAGER:CreateControl(ZO_GroupList:GetName() .. "AvgCPDisplay", ZO_GroupList, CT_LABEL)
    label:SetFont("ZoFontHeader")
    label:SetAnchor(LEFT, ZO_GroupList, TOPLEFT, 35, -22)
    label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    label:SetVerticalAlignment(CENTER)
    label:SetMouseEnabled(true)
    
    -- Custom headers
    DsRGuildGroup.PatchHeaders()
    
    --Overide for sorting
    GROUP_LIST_MANAGER.BuildMasterList = BuildMasterList
    
    GROUP_LIST.GetRowColors = GetRowColor
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildGroup.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildGroup.name, EVENT_ADD_ON_LOADED)
    
    DsRGuildGroup.Initialize()
    DsRGuildGroup.ExtendedGroupMenu()
    DsRGuildGroup.ModifyAvgCP(0, "", 0, "", nil, false)
end