Reforged.Modules.register({
    id      = "locations",
    enabled = function() return Reforged.Settings.ShowLocations ~= "br" end,
    activate = function()
        local rsd      = Reforged.Settings.Data
        local locs     = rsd.Locations
        local staticLocs = Reforged.Data.Locations
        local COLOR = Reforged.COLOR_SECONDARY
        local RESET = Reforged.COLOR_RESET

        -- AwesomeGuildStore: during its internal location queries it must receive
        -- plain PT names. Temporarily suppress color codes in those calls.
        local AGScolor1 = COLOR
        local AGScolor2 = RESET

        if Reforged.IsAddonRunning("AwesomeGuildStore") then
            if AwesomeGuildStore.class and AwesomeGuildStore.class.StoreLocationHelper then
                local helper = AwesomeGuildStore.class.StoreLocationHelper
                local function disableColor() AGScolor1 = "" AGScolor2 = "" end
                local function restoreColor() AGScolor1 = COLOR AGScolor2 = RESET end
                Reforged.Hooks.pre(helper,  "CollectStoresOnCurrentMap", disableColor)
                Reforged.Hooks.pre(helper,  "UpdateKioskAndStore",       disableColor)
                Reforged.Hooks.post(helper, "CollectStoresOnCurrentMap", restoreColor)
                Reforged.Hooks.post(helper, "UpdateKioskAndStore",       restoreColor)
            end
        end

        -- EasyTravel: must see PT-only names when rebuilding player lists
        if Reforged.IsAddonRunning("EasyTravel") then
            local backup
            local function disable() backup = Reforged.Settings.ShowLocations ; Reforged.Settings.ShowLocations = "br" end
            local function restore() Reforged.Settings.ShowLocations = backup end
            if EasyTravel.PlayerList and EasyTravel.PlayerList.Rebuild then
                Reforged.Hooks.pre(EasyTravel.PlayerList, "Rebuild", disable)
                Reforged.Hooks.post(EasyTravel.PlayerList, "Rebuild", restore)
            end
            if EasyTravel.class and EasyTravel.class.PlayerList and EasyTravel.class.PlayerList.Rebuild then
                Reforged.Hooks.pre(EasyTravel.class.PlayerList, "Rebuild", disable)
                Reforged.Hooks.post(EasyTravel.class.PlayerList, "Rebuild", restore)
            end
        end

        -- Unboxer: must see PT-only DLC names
        if Reforged.IsAddonRunning("Unboxer") then
            if Unboxer.classes and Unboxer.classes.rules and Unboxer.classes.rules.rewards
            and Unboxer.classes.rules.rewards.Solo then
                local backup
                Reforged.Hooks.pre(Unboxer.classes.rules.rewards.Solo, "GetDlcs",
                    function() backup = Reforged.Settings.ShowLocations ; Reforged.Settings.ShowLocations = "br" end)
                Reforged.Hooks.post(Unboxer.classes.rules.rewards.Solo, "GetDlcs",
                    function() Reforged.Settings.ShowLocations = backup end)
            end
        end

        -- Core translation helper: returns EN name or nil.
        -- Dump data takes priority; falls back to static map if dump is absent/incomplete
        -- (dump stores raw "zone:N:0" / "poi:N:M" references until DumpEn converts them).
        local rawRefPattern = "^%a+:%d+:%d+$"
        local function translate(name)
            if name == nil or Reforged.Settings == nil or Reforged.Settings.ShowLocations == "br" then return nil end
            -- Guard: if the name already contains a parenthetical suffix it was
            -- already translated by a previous hook in the chain — skip it.
            if string.find(name, "%(") then return nil end
            local key    = ZO_CachedStrFormat("<<z:1>>", name)
            local result = locs[key]
            if result == nil or string.match(result, rawRefPattern) then
                result = staticLocs[key]
            end
            return result
        end

        local function applyMode(ptName, enName)
            local mode = Reforged.Settings.ShowLocations
            if mode == "bren" then return ptName .. " \n(" .. enName .. ")"
            elseif mode == "enbr" then return enName .. " \n(" .. ptName .. ")"
            elseif mode == "en"  then return enName
            end
            return ptName
        end

        -- Map header (uses AGS-aware color codes)
        Reforged.Hooks.replace("GetMapLocationTooltipHeader", function(orig)
            return function(...)
                local header = ZO_CachedStrFormat(SI_ZONE_NAME, orig(...))
                local en = translate(header)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then return header .. "\n" .. AGScolor1 .. en .. AGScolor2
                    elseif mode == "enbr" then return en .. "\n" .. AGScolor1 .. header .. AGScolor2
                    elseif mode == "en" then return en
                    end
                end
                return header
            end
        end)

        Reforged.Hooks.replace("GetPOIInfo", function(orig)
            return function(...)
                local name, t2, start, finish = orig(...)
                local en = translate(name)
                if en then name = applyMode(ZO_CachedStrFormat(SI_ZONE_NAME, name), en) end
                return name, t2, start, finish
            end
        end)

        Reforged.Hooks.replace("GetMapMouseoverInfo", function(orig)
            return function(...)
                local name, tex, w, h, x, y = orig(...)
                local en = translate(name)
                if en then
                    local pt = ZO_CachedStrFormat(SI_ZONE_NAME, name)
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then name = pt .. "\n" .. en
                    elseif mode == "enbr" then name = en .. "\n" .. pt
                    elseif mode == "en" then name = en
                    end
                end
                return name, tex, w, h, x, y
            end
        end)

        Reforged.Hooks.replace("GetMapName", function(orig)
            return function(...)
                local name = orig(...)
                local en = translate(name)
                if en then return applyMode(ZO_CachedStrFormat(SI_ZONE_NAME, name), en) end
                return name
            end
        end)

        Reforged.Hooks.replace("GetFastTravelNodeInfo", function(orig)
            return function(...)
                local known, name, nx, ny, icon, glow, poi, inMap, locked = orig(...)
                local en = translate(name)
                if en then name = applyMode(name, en) end
                return known, name, nx, ny, icon, glow, poi, inMap, locked
            end
        end)

        Reforged.Hooks.replace("GetKeepName", function(orig)
            return function(...)
                local name = ZO_CachedStrFormat(SI_ZONE_NAME, orig(...))
                local en = translate(name)
                if en then return applyMode(name, en) end
                return name
            end
        end)

        Reforged.Hooks.replace("GetMapInfoByIndex", function(orig)
            return function(...)
                local name, t, c, z, d = orig(...)
                local en = translate(name)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then name = name .. " (" .. en .. ")"
                    elseif mode == "enbr" then name = en .. " (" .. name .. ")"
                    elseif mode == "en" then name = en
                    end
                end
                return name, t, c, z, d
            end
        end)

        Reforged.Hooks.replace("GetZoneNameByIndex", function(orig)
            return function(...)
                local zone = orig(...)
                if zone == nil then return zone end
                zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
                local en = translate(zone)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then return zone .. " (" .. en .. ")"
                    elseif mode == "enbr" then return en .. " (" .. zone .. ")"
                    elseif mode == "en" then return en
                    end
                end
                return zone
            end
        end)

        Reforged.Hooks.replace("GetUnitZone", function(orig)
            return function(...)
                local zone = orig(...)
                if zone == nil then return zone end
                zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
                local en = translate(zone)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then return zone .. " (" .. en .. ")"
                    elseif mode == "enbr" then return en .. " (" .. zone .. ")"
                    elseif mode == "en" then return en
                    end
                end
                return zone
            end
        end)

        Reforged.Hooks.replace("GetZoneNameById", function(orig)
            return function(...)
                local zone = orig(...)
                if zone == nil then return zone end
                zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
                local en = translate(zone)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then return zone .. " (" .. en .. ")"
                    elseif mode == "enbr" then return en .. " (" .. zone .. ")"
                    elseif mode == "en" then return en
                    end
                end
                return zone
            end
        end)

        Reforged.Hooks.replace("GetActivityInfo", function(orig)
            return function(...)
                local name, lMin, lMax, cpMin, cpMax, grp, grpMin, desc, sort = orig(...)
                if name == nil then return name, lMin, lMax, cpMin, cpMax, grp, grpMin, desc, sort end
                name = ZO_CachedStrFormat(SI_ZONE_NAME, name)
                local en = translate(name)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then name = name .. " (" .. en .. ")"
                    elseif mode == "enbr" then name = en .. " (" .. name .. ")"
                    elseif mode == "en" then name = en
                    end
                end
                return name, lMin, lMax, cpMin, cpMax, grp, grpMin, desc, sort
            end
        end)

        Reforged.Hooks.replace("GetCadwellZoneInfo", function(orig)
            return function(...)
                local zone, desc, order = orig(...)
                local en = translate(zone)
                if en then
                    local mode = Reforged.Settings.ShowLocations
                    if mode == "bren" then zone = zone .. " (" .. en .. ")"
                    elseif mode == "enbr" then zone = en .. " (" .. zone .. ")"
                    elseif mode == "en" then zone = en
                    end
                end
                return zone, desc, order
            end
        end)

        -- Friend and Guild member zone display
        local function patchZoneField(data)
            if not data or not data.formattedZone then return end
            local en = translate(data.formattedZone)
            if not en then return end
            local mode = Reforged.Settings.ShowLocations
            if mode == "bren" then data.formattedZone = data.formattedZone .. " (" .. en .. ")"
            elseif mode == "enbr" then data.formattedZone = en .. " (" .. data.formattedZone .. ")"
            elseif mode == "en" then data.formattedZone = en
            end
        end

        Reforged.Hooks.replace("GetFriendCharacterInfo", function(orig)
            return function(...)
                local a, b, zone, c, d, e, f, g, h = orig(...)
                if zone then
                    zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
                    local en = translate(zone)
                    if en then zone = applyMode(zone, en) end
                end
                return a, b, zone, c, d, e, f, g, h
            end
        end)

        Reforged.Hooks.replace("GetGuildMemberCharacterInfo", function(orig)
            return function(...)
                local a, b, zone, c, d, e, f, g, h = orig(...)
                if zone then
                    zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
                    local en = translate(zone)
                    if en then zone = applyMode(zone, en) end
                end
                return a, b, zone, c, d, e, f, g, h
            end
        end)

        Reforged.Hooks.post(FRIENDS_LIST_MANAGER, "OnFriendCharacterZoneChanged",
            function(_, displayName)
                patchZoneField(FRIENDS_LIST_MANAGER:FindDataByDisplayName(displayName))
            end)

        Reforged.Hooks.post(GUILD_ROSTER_MANAGER, "OnGuildMemberPlayerStatusChanged",
            function(_, displayName, _, newStatus)
                if newStatus ~= PLAYER_STATUS_OFFLINE then
                    patchZoneField(GUILD_ROSTER_MANAGER:FindDataByDisplayName(displayName))
                end
            end)

        Reforged.Hooks.post(GUILD_ROSTER_MANAGER, "OnGuildMemberCharacterZoneChanged",
            function(_, displayName)
                patchZoneField(GUILD_ROSTER_MANAGER:FindDataByDisplayName(displayName))
            end)

        -- Patch zone names already cached in the list before our hook was installed
        local function patchExistingFriendsData()
            if not FRIENDS_LIST_MANAGER.masterList then return end
            for _, data in ipairs(FRIENDS_LIST_MANAGER.masterList) do
                patchZoneField(data)
            end
        end
        Reforged.Hooks.post(FRIENDS_LIST_MANAGER, "BuildMasterList", patchExistingFriendsData)
        patchExistingFriendsData()

        -- Zone-change alert text
        Reforged.Hooks.replace("ZO_AlertText_GetHandlers", function(orig)
            return function()
                local handlers = orig()
                handlers[EVENT_ZONE_CHANGED] = function(zoneName, subzoneName)
                    local targetName = subzoneName ~= "" and subzoneName or zoneName
                    if targetName == "" then return end
                    local mode = Reforged.Settings.ShowLocations
                    if mode ~= "br" then
                        local en = locs[ZO_CachedStrFormat("<<z:1>>", targetName)]
                        if en then
                            if mode == "bren" then
                                targetName = targetName .. "\n" .. COLOR .. en .. RESET
                            elseif mode == "enbr" then
                                targetName = en .. "\n" .. COLOR .. ZO_CachedStrFormat(SI_ZONE_NAME, targetName) .. RESET
                            else
                                targetName = en
                            end
                        end
                    end
                    return UI_ALERT_CATEGORY_ALERT, ZO_CachedStrFormat(SI_ALERTTEXT_LOCATION_FORMAT, targetName)
                end
                return handlers
            end
        end)

        -- LFG finder: patch dungeon location names
        local function patchLFGLocations()
            local locs2 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[2]
            local locs3 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[3]

            local function patchList(list, isVet)
                for i = 1, #list do
                    local en = rsd.Locations[zo_strlower(list[i]["rawName"])]
                    if en then
                        local mode = Reforged.Settings.ShowLocations
                        local ptName = list[i]["rawName"]
                        local displayName
                        if mode == "bren" then
                            displayName = ZO_CachedStrFormat(SI_ZONE_NAME, ptName .. " |cffffff(" .. en .. ")")
                        elseif mode == "enbr" then
                            displayName = ZO_CachedStrFormat(SI_ZONE_NAME, en .. " |cffffff(" .. ptName .. ")")
                        elseif mode == "en" then
                            displayName = ZO_CachedStrFormat(SI_ZONE_NAME, en)
                        else
                            displayName = ZO_CachedStrFormat(SI_ZONE_NAME, ptName)
                        end
                        if isVet then
                            if string.find(list[i]["nameKeyboard"], "target_veteranRank_icon") then
                                list[i]["nameKeyboard"] = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t " .. displayName
                            end
                        else
                            list[i]["nameKeyboard"] = displayName
                            list[i]["nameGamepad"]  = displayName
                        end
                    end
                end
            end

            if locs2 then patchList(locs2, false) end
            if locs3 then patchList(locs3, true)  end
        end

        patchLFGLocations()

        -- Cadwell's Almanac and map font style
        CADWELLS_ALMANAC:RefreshList()
        local mode = Reforged.Settings.ShowLocations
        if mode == "bren" or mode == "enbr" then
            ZO_WorldMapCornerTitle:SetFont("ZoFontWinH3")
        else
            ZO_WorldMapCornerTitle:SetFont("ZoFontWinH1")
        end
        local scrollData = ZO_ScrollList_GetDataList(ZO_WorldMapLocationsList)
        ZO_ClearNumericallyIndexedTable(scrollData)
        WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
        WORLD_MAP_LOCATIONS:BuildLocationList()
    end,
})
