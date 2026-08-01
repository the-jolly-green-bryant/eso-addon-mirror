local Goto_template = ZO_Object:Subclass()
local Goto = Goto_template:New()

Goto.addonName = "Goto"
Goto.defaults = {}
Goto.playerdata = {}
Goto.groupUnitTags = {}

ZO_CreateStringId("GOTO_NAME", "Goto")

local GOTO_PANE = {}
local GOTO_SCROLLLIST_DATA = 1
local GOTO_SCROLLLIST_SORT_KEYS = {
    ["zoneName"] = { },
    ["playerName"] = {  tiebreaker = "zoneName" },
}

goto_debug_unlocked_dlc = false

local function hook(baseFunc,newFunc)
    return function(...)
        return newFunc(baseFunc,...)
    end
end

local function getpunitUnlockedZones()
    local unlockedzones = {}
    local difficultylevel = 2
    local zonename, _, idx, idy

    for idx = 0, difficultylevel do
        for idy = 1, GetNumZonesForDifficultyLevel(idx) do
            zonename, _, _ = GetCadwellZoneInfo(idx, idy)
            unlockedzones[zonename] = 1
        end
    end

    unlockedzones[GetZoneNameByIndex(GetZoneIndex(888))] = 1 -- Craglorn
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(347))] = 1 -- Coldharbor
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(535))] = 1 -- Betnikh
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(534))] = 1 -- Stros M'Kai
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(537))] = 1 --[537] = "Khenarthi's Roost"
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(281))] = 1 --[281] = "Bal Foyen
    unlockedzones[GetZoneNameByIndex(GetZoneIndex(280))] = 1 --[280] = "Bleakrock Isle"


    -- DLC -- Thanks to Ayantir for showing me how to determine what DLC exists and
    -- whether it is unlocked
    --[[ collectible ids
      491 - SoH
      306 - Dark brotherhood
      254 - Thieves Guild
      215 - Orsinium
      154 - Imperial City
      ]]
    -- Create a table with DLC id <--> zone list

    local _, _, numCollectibles, _, _, _, _ = GetCollectibleCategoryInfo(COLLECTIBLE_CATEGORY_TYPE_DLC)
    for i=1, numCollectibles do
        local collectibleId = GetCollectibleId(COLLECTIBLE_CATEGORY_TYPE_DLC, nil, i)
        local collectibleName, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
        if goto_debug_ublocked_dlc then
            d("DLC ".. collectibleName .. "( ".. collectibleId .. ") unlocked : " .. tostring(unlocked))
        end
        if unlocked then
            if collectibleId == 215 then
                unlockedzones['Wrothgar'] = 1
            elseif collectibleId == 254 then
                unlockedzones["Hew's Bane"] = 1
            elseif collectibleId == 306 then
                unlockedzones['The Gold Coast'] = 1
            end
        end
    end

    return unlockedzones
end

local function isInGroup(playerName)
    local idx
    for idx = 1, GetGroupSize() do
        local groupUnitTag = GetGroupUnitTagByIndex(idx)
        local unitName = GetUnitName(groupUnitTag)
        if playerName == unitName then
                return true
        end
    end
    return false
end

local function getUnitInfo(atname)
end

local function getPlayerInfo(tabletopopulate)
    local punitName = GetUnitName("player")
    local prawUnitName = GetRawUnitName("player")
    local punitUnlockedZones = getpunitUnlockedZones()
    local guildnum, idx, findex

    for guildnum = 1, GetNumGuilds() do
        local guildID = GetGuildId(guildnum)
        local numMembers = GetNumGuildMembers(guildID)
        local memberindex

        for memberindex = 1, numMembers do
            local mi = {} --mi == "member info"

            mi.name, mi.note, mi.rankindex, mi.status, mi.secsincelastseen =
                GetGuildMemberInfo(guildID,memberindex)
            if mi.status == 1 then -- only collect info for online players
                mi.hasCh, mi.chname, mi.zone, mi.class, mi.alliance, mi.level, mi.vr =
                    GetGuildMemberCharacterInfo(guildID, memberindex)
                mi.unitname = mi.chname
                if tabletopopulate[mi.unitname] ~= nil then
                    mi.guildnames = zo_strformat("<<T:1>>\n<<T:2>>", tabletopopulate[mi.unitname].guildnames, GetGuildName(guildID))
                else
                    mi.guildnames = GetGuildName(guildID)
                end
                -- Don't display user, players in Cyrodiil
                if mi.chname ~= prawUnitName and mi.zone ~= "Cyrodiil" and punitUnlockedZones[mi.zone] ~= nil then
                    tabletopopulate[mi.unitname] = mi
                end
            end
        end
    end

    -- This should catch group members that aren't in a guild the player is in
    for idx = 1, GetGroupSize() do
        local mi = {}
        local groupUnitTag = GetGroupUnitTagByIndex(idx)
        mi.unitname = GetUnitName(groupUnitTag)
        if mi.unitname ~= punitName and tabletopopulate[mi.unitname] == nil and groupUnitTag ~= nil
                and IsUnitOnline(groupUnitTag) then
            mi.zone = GetUnitZone(groupUnitTag)
            mi.class = GetUnitClassId(groupUnitTag)
            mi.level = GetUnitLevel(groupUnitTag)
            mi.vr = GetUnitVeteranRank(groupUnitTag)
            mi.guildnames = "Grouped"

            tabletopopulate[mi.unitname] = mi
        end
    end

    -- This should catch any friends that are not in a guild the player is in
    for findex = 1, GetNumFriends() do
        local mi = {} --mi == "member info"

        mi.name, mi.note, mi.status, mi.secsincelastseen = GetFriendInfo(findex)
        if mi.status == 1 then -- only collect info for online players
            mi.hasCh, mi.chname, mi.zone, mi.class, mi.alliance, mi.level, mi.vr =
                GetFriendCharacterInfo(findex)
            mi.unitname = mi.chname
            mi.guildnames = "Friend"

            -- Don't display user, or players in Cyrodiil
            if  tabletopopulate[mi.unitname] == nil and mi.zone ~= "Cyrodiil" and punitUnlockedZones[mi.zone] ~= nil then
                tabletopopulate[mi.unitname] = mi
            end
        end
    end
end

local function populateScrollList(listdata)
    local player
    local scrollData = ZO_ScrollList_GetDataList(GOTO_PANE.ScrollList)

    ZO_ClearNumericallyIndexedTable(scrollData)

    for _, player in pairs(listdata) do
        if player.name ~= nil then -- was in guild or friends list
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GOTO_SCROLLLIST_DATA,
                {
                    playerName = player.unitname,
                    zoneName = player.zone,
                    playerClass = player.class,
                    playerLevel = player.level,
                    playerVr = player.vr,
                    playeratName = player.name,
                    playerGuilds = player.guildnames,
                }
            )
            )
        else -- not in guild or friends list; no way to determine @name or guilds
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GOTO_SCROLLLIST_DATA,
                {
                    playerName = player.unitname,
                    zoneName = player.zone,
                    playerClass = player.class,
                    playerLevel = player.level,
                    playerVr = player.vr,
                    playeratName = player.unitname,
                    playerGuilds = player.guildnames,
                }
            )
            )
        end
    end

    ZO_ScrollList_Commit(GOTO_PANE.ScrollList)
    GOTO_PANE.sortHeaders:SelectHeaderByKey("zoneName")
end

local function createGotoPane()
    local x,y = ZO_WorldMapLocations:GetDimensions()
    local _, point, relativeTo, relativePoint, offsetX, offsetY = ZO_WorldMapLocations:GetAnchor()

    GOTO_PANE = WINDOW_MANAGER:CreateTopLevelWindow(nil)
    GOTO_PANE:SetMouseEnabled(true)
    GOTO_PANE:SetMovable( false )
    GOTO_PANE:SetClampedToScreen(true)
    GOTO_PANE:SetDimensions( x, y )
    GOTO_PANE:SetAnchor( point, relativeTo, relativePoint, offsetX, offsetY )
    GOTO_PANE:SetHidden( true )

    -- Create Sort Headers
    GOTO_PANE.Headers = WINDOW_MANAGER:CreateControl("$(parent)Headers",GOTO_PANE,nil)
    GOTO_PANE.Headers:SetAnchor( TOPLEFT, GOTO_PANE, TOPLEFT, 0, 0 )
    GOTO_PANE.Headers:SetHeight(32)

    GOTO_PANE.Headers.Name = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Name",GOTO_PANE.Headers,"ZO_SortHeader")
    GOTO_PANE.Headers.Name:SetDimensions(150,32)
    GOTO_PANE.Headers.Name:SetAnchor( TOPLEFT, GOTO_PANE.Headers, TOPLEFT, 8, 0 )
    ZO_SortHeader_Initialize(GOTO_PANE.Headers.Name, "Name", "playerName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    ZO_SortHeader_SetTooltip(GOTO_PANE.Headers.Name, "Sort on player name")

    GOTO_PANE.Headers.Location = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Location",GOTO_PANE.Headers,"ZO_SortHeader")
    GOTO_PANE.Headers.Location:SetDimensions(150,32)
    GOTO_PANE.Headers.Location:SetAnchor( LEFT, GOTO_PANE.Headers.Name, RIGHT, 18, 0 )
    ZO_SortHeader_Initialize(GOTO_PANE.Headers.Location, "Zone", "zoneName", ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontGameLargeBold")
    ZO_SortHeader_SetTooltip(GOTO_PANE.Headers.Location, "Sort on zone")

    GOTO_PANE.sortHeaders = ZO_SortHeaderGroup:New(GOTO_PANE:GetNamedChild("Headers"), SHOW_ARROWS)
    GOTO_PANE.sortHeaders:RegisterCallback(
        ZO_SortHeaderGroup.HEADER_CLICKED,
        function(key, order)
            table.sort(
                ZO_ScrollList_GetDataList(GOTO_PANE.ScrollList),
                function(entry1, entry2)
                    if isInGroup(entry1.data.playerName) then
                        if not isInGroup(entry2.data.playerName) then
                            return true -- 1 (group member) comes before 2 (non-member)
                        end
                    else
                        if isInGroup(entry2.data.playerName) then
                            return false -- 1 (non-member) comes after 2 (group member)
                        end
                    end
                    -- both members or both non-members, break the tie using the usual column sorting rules
                    return ZO_TableOrderingFunction(entry1.data, entry2.data, key, GOTO_SCROLLLIST_SORT_KEYS, order)
                end)
            ZO_ScrollList_Commit(GOTO_PANE.ScrollList)
        end)
    GOTO_PANE.sortHeaders:AddHeadersFromContainer()

    -- Create a scrollList
    GOTO_PANE.ScrollList = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)GotoScrollList", GOTO_PANE, "ZO_ScrollList")
    GOTO_PANE.ScrollList:SetDimensions(x, y-32)
    GOTO_PANE.ScrollList:SetAnchor(TOPLEFT, GOTO_PANE.Headers, BOTTOMLEFT, 0, 0)

    -- Add a datatype to the scrollList
    ZO_ScrollList_AddDataType(GOTO_PANE.ScrollList, GOTO_SCROLLLIST_DATA, "GotoRow", 23,
        function(control, data)

            local nameLabel = control:GetNamedChild("Name")
            local locationLabel = control:GetNamedChild("Location")

            local friendColor = ZO_ColorDef:New(0.3, 1, 0, 1)
            local groupColor = ZO_ColorDef:New(0.46, .73, .76, 1)

            local displayedlevel = 0

            nameLabel:SetText(zo_strformat("<<T:1>>", data.playerName))

            if data.playerLevel < 50 then
                displayedlevel = data.playerLevel
            else
                displayedlevel = "CP" .. data.playerVr
            end

            nameLabel.tooltipText = zo_strformat("<<T:1>>\n<<X:2>> <<X:3>>\n<<X:4>>",
                data.playeratName, displayedlevel, GetClassName(1, data.playerClass), data.playerGuilds)

            locationLabel:SetText(zo_strformat("<<C:1>>", data.zoneName))

            if isInGroup(data.playerName) then
                ZO_SelectableLabel_SetNormalColor(nameLabel, groupColor)
                ZO_SelectableLabel_SetNormalColor(locationLabel, groupColor)

            elseif IsFriend(data.playerName) then
                ZO_SelectableLabel_SetNormalColor(nameLabel, friendColor)
                ZO_SelectableLabel_SetNormalColor(locationLabel, friendColor)

            else
                ZO_SelectableLabel_SetNormalColor(nameLabel, ZO_NORMAL_TEXT)
                ZO_SelectableLabel_SetNormalColor(locationLabel, ZO_NORMAL_TEXT)
            end
        end
    )

    local buttonData = {
        normal = "EsoUI/Art/mainmenu/menubar_journal_up.dds",
        pressed = "EsoUI/Art/mainmenu/menubar_journal_down.dds",
        highlight = "EsoUI/Art/mainmenu/menubar_journal_over.dds",
    }

    --
    -- Create a fragment from the window and add it to the modeBar of the WorldMap RightPane
    --
    local gotoFragment = ZO_FadeSceneFragment:New(GOTO_PANE)
    WORLD_MAP_INFO.modeBar:Add(GOTO_NAME, {gotoFragment}, buttonData)
end



local function debugZone(zonename) end

local function processSlashCommands(argslist)
    local options = {}
    local searchResult = { string.match(argslist,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

    local function help()
        --d("/goto @name\tJump to shrine nearest @name")
        --d("/goto aliasname\tJump to shrine nearest character with alias \"aliasname\"")
        --d("/goto leader\tJump to party leader")
        --d("/galias @name|\"character name\" aliasname")
        --d("-- assign aliasname to either @name or \"character name\"")
        -- d("/goto debug zonename\tDebug zone (there's a friend there, why isn't it in my list?)")
        d("Under Construction")
        d("/goto debugdlc\tToggle DLC debug info")
    end
    if #options == 0 or options[1] == "help" then
        help()
    elseif options[1] == "debug" then
        if options[2] ~= nil then
            debugZone(options[2])
        else
            help()
        end
    elseif options[1] == "debugdlc" then
        if goto_debug_unlocked_dlc == true then
            d("Disabling goto dlc debug")
            goto_debug_unlocked_dlc = false
        else
            d("Enabling goto dlc debug")
            goto_debug_unlocked_dlc = true
        end
        d("goto_debug_unlocked_dlc:" .. tostring(goto_debug_unlocked_dlc))
    else
        help()
    end
end

local function WorldMapStateChanged(_, newState)
    if (newState == SCENE_SHOWING) then
    	Goto.playerdata = { }
    	getPlayerInfo(Goto.playerdata)
        populateScrollList(Goto.playerdata)
    end
end

function Goto:EVENT_ADD_ON_LOADED(_, addonName, ...)
    if addonName == Goto.addonName then
        Goto.SavedVariables = ZO_SavedVars:New("Goto_SavedVariables", 2, nil, Goto.defaults)
        createGotoPane()

        SLASH_COMMANDS["/goto"] = processSlashCommands

        EVENT_MANAGER:UnregisterForEvent(Goto.addonName, EVENT_ADD_ON_LOADED)
        EVENT_MANAGER:RegisterForEvent(Goto.addonName, EVENT_PLAYER_ACTIVATED, function(...) Goto:EVENT_PLAYER_ACTIVATED(...) end)
        WORLD_MAP_SCENE:RegisterCallback("StateChange", WorldMapStateChanged)
        GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", WorldMapStateChanged)
    end
end


function Goto:EVENT_PLAYER_ACTIVATED(...)
    --d("|cFF2222Goto|r addon loaded")
    EVENT_MANAGER:UnregisterForEvent(Goto.addonName, EVENT_PLAYER_ACTIVATED)
end


EVENT_MANAGER:RegisterForEvent(Goto.addonName, EVENT_ADD_ON_LOADED, function(...) Goto:EVENT_ADD_ON_LOADED(...) end )


function nameOnMouseUp(self, button, upInside)
    --d("MouseUp:" .. self:GetText() .. ":" .. tostring(button) .. ":" .. tostring(upInside) )
    local unitName = self:GetText()

    if button == 1 then -- left
        if IsFriend(unitName) then
            JumpToFriend(unitName)
        elseif isInGroup(unitName) then
            JumpToGroupMember(unitName)
        else
            JumpToGuildMember(unitName)
        end

    elseif button == 2 then -- right
        ZO_ScrollList_RefreshVisible(GOTO_PANE.ScrollList)

    else -- middle
        Goto.playerdata = {}
        getPlayerInfo(Goto.playerdata)
        populateScrollList(Goto.playerdata)
    end
end

