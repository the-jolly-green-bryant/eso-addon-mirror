-- BuildTracker.lua
--
-- Addon entry point. Initializes saved variables and registers /bt slash
-- commands so the entire data layer (builds, slots, ownership, export/
-- import) can be exercised and verified before the full paperdoll UI exists.

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= BuildTracker.name then return end
    EVENT_MANAGER:UnregisterForEvent(BuildTracker.name, EVENT_ADD_ON_LOADED)

    BuildTracker.Data.Initialize()
    BuildTracker.Notifications.Initialize()
    BuildTracker.Settings.Initialize()
    BuildTracker.Debug("Loaded, version %s", BuildTracker.version)
end

EVENT_MANAGER:RegisterForEvent(BuildTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- ---------------------------------------------------------------------------
-- Slash commands - /bt ...
-- These exist purely to exercise the data layer while there's no full UI
-- yet. /bt export and /bt import will likely stick around as a power-user
-- shortcut even once the paperdoll UI lands.
-- ---------------------------------------------------------------------------

local function PrintUsage()
    d("|c70C0F7Build Tracker commands:|r")
    d("/bt new <name>                          - create a build")
    d("/bt list                                - list all builds")
    d("/bt info <buildId>                       - popup: show a build's slots + Collection status (color-coded)")
    d("/bt ui [buildId]                         - open the visual slot editor (defaults to most recently created build)")
    d("/bt rename <buildId> <newName>           - rename a build")
    d("/bt duplicate <buildId> [newName]        - duplicate a build")
    d("/bt delete <buildId>                     - delete a build")
    d("/bt setslot <buildId> <slot> <setId> [weight|weaponType] - assign a set to a slot")
    d("    weight (armor slots): light, medium, heavy")
    d("    weaponType (weapon slots): sword, axe, mace, dagger, bow, etc.")
    d("/bt setitem <buildId> <slot> <itemId>    - assign a slot directly by itemId (bypasses LibSets)")
    d("/bt clearslot <buildId> <slot>           - clear a slot")
    d("/bt owned <buildId>                      - chat: color-coded Collection status per slot")
    d("/bt settings                             - open the loot-alert settings panel")
    if BuildTracker.Data.GetShowDebugCommands() then
        d("/bt debuglibsets [filter]                - list real LibSets function names (optionally filtered)")
        d("/bt debugitem <itemId>                   - trace an itemId through LibSets/base-game APIs")
        d("/bt debugfindpiece <setId> <itemId> [maxIndex] - scan past the reported piece count for a specific itemId")
        d("/bt debugcollection <setId>              - dump raw Set Collection data for a setId")
        d("/bt debugsetitems <setId> [itemId]      - dump GetSetItemIds() shape; optionally check one specific itemId")
        d("/bt debugsource <setId>                  - trace the 'where to find it' / reconstruction cost lookups for a setId")
    end
    d("/bt export <buildId>                     - open a copyable export window")
    d("/bt import                               - open a paste-and-import window")
    d("/bt import <string>                      - import directly from chat (legacy)")
    d("/bt debug                                - toggle debug logging")
end

local function SplitArgs(str)
    local args = {}
    for token in (str or ""):gmatch("%S+") do
        table.insert(args, token)
    end
    return args
end

local function ResolveSlot(token)
    if not token then return nil end
    return BuildTracker.SLOT_NAME_TO_ID[token:lower()]
end

-- Confident, stable ESO constants - these three have been unchanged for
-- years and are used everywhere in tooltips/addons.
local ARMOR_WEIGHT_NAME_TO_TYPE = {
    light = ARMORTYPE_LIGHT,
    medium = ARMORTYPE_MEDIUM,
    heavy = ARMORTYPE_HEAVY,
}

-- Weapon type constant names (WEAPONTYPE_SWORD, WEAPONTYPE_AXE, etc.) are
-- less certain from documentation alone, so rather than hardcode a list
-- that might have a wrong suffix, this resolves the name straight off the
-- real global constant table at runtime. If the person types a name that
-- doesn't match a real WEAPONTYPE_* constant, this correctly returns nil
-- instead of silently guessing.
local function ResolveWeaponType(name)
    if not name then return nil end
    return _G["WEAPONTYPE_" .. name:upper()]
end

local function SlashHandler(fullArgString)
    local args = SplitArgs(fullArgString)
    local cmd = args[1] and args[1]:lower() or nil

    if cmd == "new" then
        local name = table.concat(args, " ", 2)
        local id = BuildTracker.Data.CreateBuild(name)
        d(string.format("Created build #%s: %s", id, BuildTracker.Data.GetBuild(id).name))

    elseif cmd == "list" then
        local builds = BuildTracker.Data.GetAllBuildsSorted()
        if #builds == 0 then
            d("No builds yet. Try /bt new <name>")
        else
            for _, b in ipairs(builds) do
                d(string.format("#%s - %s", b.id, b.name))
            end
        end

    elseif cmd == "info" then
        local build = BuildTracker.Data.GetBuild(args[2])
        if not build then
            d("No build with that id. Use /bt list to see ids.")
        else
            local status = BuildTracker.Ownership.GetBuildOwnershipStatus(build.id)
            local lines = {}
            for _, slotId in ipairs(BuildTracker.SLOT_ORDER) do
                local slotData = build.slots[slotId]
                if slotData then
                    local setName = BuildTracker.Sets.GetSetName(slotData.setId) or ("setId " .. tostring(slotData.setId))
                    local isCollected = status[slotId]
                    local label
                    if isCollected == true then
                        label = "Collected"
                    elseif isCollected == false then
                        label = "Not collected"
                    else
                        label = "Unknown (likely crafted)"
                    end
                    table.insert(lines, string.format("  %s: %s (itemId %s) - %s", BuildTracker.SLOT_NAMES[slotId], setName, tostring(slotData.itemId), label))
                end
            end
            if #lines == 0 then table.insert(lines, "  (no slots assigned yet)") end
            BuildTracker.UI.ShowExportBox("Build #" .. build.id .. ": " .. build.name, table.concat(lines, "\n"))
        end

    elseif cmd == "ui" then
        local buildId = args[2] or BuildTracker.Data.GetDefaultBuildId()
        if not buildId then
            d("No builds yet. Try /bt new <name> first.")
        elseif not BuildTracker.Data.GetBuild(buildId) then
            d("No build with that id. Use /bt list to see ids.")
        else
            BuildTracker.UI.ShowPaperdoll(buildId)
        end

    elseif cmd == "rename" then
        local buildId = args[2]
        local newName = table.concat(args, " ", 3)
        local ok, err = BuildTracker.Data.RenameBuild(buildId, newName)
        d(ok and ("Renamed to " .. newName) or ("Error: " .. tostring(err)))

    elseif cmd == "duplicate" then
        local buildId = args[2]
        local newName = #args >= 3 and table.concat(args, " ", 3) or nil
        local newId, err = BuildTracker.Data.DuplicateBuild(buildId, newName)
        d(newId and ("Duplicated as #" .. newId) or ("Error: " .. tostring(err)))

    elseif cmd == "delete" then
        local ok, err = BuildTracker.Data.DeleteBuild(args[2])
        d(ok and "Deleted." or ("Error: " .. tostring(err)))

    elseif cmd == "setslot" then
        local buildId, slotToken, setIdStr, extraTypeStr = args[2], args[3], args[4], args[5]
        local slotId = ResolveSlot(slotToken)
        local setId = tonumber(setIdStr)

        if not slotId then
            d("Unknown slot '" .. tostring(slotToken) .. "'. Try: head, chest, neck, ring1, mainhand, etc.")
        elseif not setId then
            d("setId must be a number. Find setIds via LibSets' /lss search UI.")
        else
            local equipType = BuildTracker.SLOT_TO_EQUIP_TYPE[slotId]
            local armorType, weaponType

            if BuildTracker.IsWeaponSlot(slotId) then
                if extraTypeStr then
                    weaponType = ResolveWeaponType(extraTypeStr)
                    if not weaponType then
                        d("Unknown weapon type '" .. extraTypeStr .. "'. Try: sword, axe, mace, dagger, bow, etc.")
                        return
                    end
                end
            else
                if extraTypeStr then
                    armorType = ARMOR_WEIGHT_NAME_TO_TYPE[extraTypeStr:lower()]
                    if not armorType then
                        d("Unknown armor weight '" .. extraTypeStr .. "'. Try: light, medium, heavy")
                        return
                    end
                end
            end

            local ok, err = BuildTracker.Data.SetBuildSlot(buildId, slotId, setId, equipType, armorType, weaponType)
            d(ok and "Slot set." or ("Error: " .. tostring(err)))
        end

    elseif cmd == "setitem" then
        local buildId, slotToken, itemIdStr = args[2], args[3], args[4]
        local slotId = ResolveSlot(slotToken)
        local itemId = tonumber(itemIdStr)

        if not slotId then
            d("Unknown slot '" .. tostring(slotToken) .. "'. Try: head, chest, neck, ring1, mainhand, etc.")
        elseif not itemId then
            d("itemId must be a number.")
        else
            local ok, err = BuildTracker.Data.SetBuildSlotByItemId(buildId, slotId, itemId)
            d(ok and "Slot set." or ("Error: " .. tostring(err)))
        end

    elseif cmd == "clearslot" then
        local buildId, slotToken = args[2], args[3]
        local slotId = ResolveSlot(slotToken)
        if not slotId then
            d("Unknown slot '" .. tostring(slotToken) .. "'")
        else
            local ok, err = BuildTracker.Data.ClearBuildSlot(buildId, slotId)
            d(ok and "Slot cleared." or ("Error: " .. tostring(err)))
        end

    elseif cmd == "owned" then
        local buildId = args[2]
        local status, collectedCount, totalCount = BuildTracker.Ownership.GetBuildOwnershipStatus(buildId)
        local build = BuildTracker.Data.GetBuild(buildId)
        if not build then
            d("No build with that id.")
        else
            d(string.format("Build #%s: %s", buildId, build.name))
            d(string.format("%d/%d pieces in your Set Collection", collectedCount, totalCount))
            d("Collection Results")
            for _, slotId in ipairs(BuildTracker.SLOT_ORDER) do
                local slotData = build.slots[slotId]
                if slotData then
                    local setName = BuildTracker.Sets.GetSetName(slotData.setId) or ("setId " .. tostring(slotData.setId))
                    local isCollected = status[slotId]
                    local label
                    if isCollected == true then
                        label = "|c00FF00Collected|r"
                    elseif isCollected == false then
                        label = "|cFF3333Not collected|r"
                    else
                        label = "|cFFCC00Unknown (likely a crafted set)|r"
                    end
                    d(string.format("  %s %s: %s", setName, BuildTracker.SLOT_NAMES[slotId], label))
                end
            end
        end

    elseif cmd == "export" then
        local buildId = args[2]
        local build = BuildTracker.Data.GetBuild(buildId)
        local str, err = BuildTracker.ExportImport.ExportBuild(buildId)
        if str then
            BuildTracker.UI.ShowExportBox("Export: " .. (build and build.name or ("#" .. tostring(buildId))), str)
        else
            d("Error: " .. tostring(err))
        end

    elseif cmd == "import" then
        if args[2] then
            -- Legacy path: string typed/pasted directly after the command.
            local importStr = table.concat(args, " ", 2):gsub('^"(.*)"$', "%1")
            local newId, err = BuildTracker.ExportImport.ImportBuild(importStr)
            d(newId and ("Imported as build #" .. newId) or ("Error: " .. tostring(err)))
        else
            BuildTracker.UI.ShowImportBox(function(text)
                local newId, err = BuildTracker.ExportImport.ImportBuild(text)
                if newId then
                    d("Imported as build #" .. newId)
                else
                    d("Error: " .. tostring(err))
                end
            end)
        end

    elseif cmd == "debuglibsets" then
        local filter = args[2]
        local lib = LibSets
        if not lib then
            d("LibSets not loaded")
        else
            local names = {}
            for key, value in pairs(lib) do
                if type(key) == "string" and type(value) == "function" then
                    if not filter or key:lower():find(filter:lower(), 1, true) then
                        table.insert(names, key)
                    end
                end
            end
            table.sort(names)
            local title = "LibSets functions" .. (filter and (" matching '" .. filter .. "'") or " (all)")
            BuildTracker.UI.ShowExportBox(title, #names > 0 and table.concat(names, "\n") or "No matches found")
        end

    elseif cmd == "debugitem" then
        local itemId = tonumber(args[2])
        if not itemId then
            d("Usage: /bt debugitem <itemId>")
        else
            local lines = {}
            local itemLink = BuildTracker.Sets.BuildItemLink(itemId)
            table.insert(lines, string.format("BuildItemLink(%d): %s", itemId, tostring(itemLink)))

            if itemLink then
                local ok2, hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = pcall(GetItemLinkSetInfo, itemLink, false)
                table.insert(lines, string.format("GetItemLinkSetInfo: ok=%s hasSet=%s setName=%s bonusSetId=%s",
                    tostring(ok2), tostring(hasSet), tostring(setName), tostring(setId)))

                local ok3, isCrafted = pcall(IsItemLinkCrafted, itemLink)
                table.insert(lines, string.format("IsItemLinkCrafted: ok=%s isCrafted=%s", tostring(ok3), tostring(isCrafted)))

                local ok4, isUnlocked = pcall(IsItemSetCollectionPieceUnlocked, itemId)
                table.insert(lines, string.format("IsItemSetCollectionPieceUnlocked: ok=%s isUnlocked=%s", tostring(ok4), tostring(isUnlocked)))

                local isCollected = BuildTracker.Collections.IsItemCollected(setId, itemId)
                table.insert(lines, string.format("Collections.IsItemCollected: %s", tostring(isCollected)))

                local slotKey = BuildTracker.Sets.GetCollectionsSlotKey(itemLink)
                table.insert(lines, string.format("GetItemSetCollectionsSlotKey: %s", tostring(slotKey)))
            end
            BuildTracker.UI.ShowExportBox("Debug: item " .. itemId, table.concat(lines, "\n"))
        end

    elseif cmd == "debugfindpiece" then
        local setId = tonumber(args[2])
        local targetItemId = tonumber(args[3])
        local maxIndex = tonumber(args[4]) or 80
        if not setId or not targetItemId then
            d("Usage: /bt debugfindpiece <setId> <itemId> [maxIndex]")
        else
            local lines = {}
            local reportedOk, reportedNum = pcall(GetNumItemSetCollectionPieces, setId)
            table.insert(lines, string.format("GetNumItemSetCollectionPieces(%d) reports: %s", setId, tostring(reportedOk and reportedNum or "call failed")))
            table.insert(lines, string.format("Scanning indices 1 to %d looking for pieceId=%d ...", maxIndex, targetItemId))

            local foundAt = nil
            local consecutiveFailures = 0
            for index = 1, maxIndex do
                local ok, pieceId, slot = pcall(GetItemSetCollectionPieceInfo, setId, index)
                if ok and pieceId ~= nil then
                    consecutiveFailures = 0
                    if pieceId == targetItemId then
                        foundAt = index
                        local ok2, isUnlocked = pcall(IsItemSetCollectionSlotUnlocked, setId, slot)
                        table.insert(lines, string.format("MATCH at index %d: pieceId=%d slot=%s unlocked=%s",
                            index, pieceId, tostring(slot), ok2 and tostring(isUnlocked) or "call_failed"))
                    end
                else
                    consecutiveFailures = consecutiveFailures + 1
                    if consecutiveFailures >= 5 then
                        table.insert(lines, string.format("Stopped at index %d after 5 consecutive failures", index))
                        break
                    end
                end
            end

            if not foundAt then
                table.insert(lines, "Not found in scanned range.")
            end
            BuildTracker.UI.ShowExportBox(string.format("Debug: find piece %d in set %d", targetItemId, setId), table.concat(lines, "\n"))
        end

    elseif cmd == "debugcollection" then
        local setId = tonumber(args[2])
        if not setId then
            d("Usage: /bt debugcollection <setId>")
        else
            local lines = {}
            local ok, numPieces = pcall(GetNumItemSetCollectionPieces, setId)
            table.insert(lines, string.format("GetNumItemSetCollectionPieces(%d): call_ok=%s numPieces=%s", setId, tostring(ok), tostring(numPieces)))
            if ok and numPieces and numPieces > 0 then
                for index = 1, numPieces do
                    local ok2, pieceId, slot = pcall(GetItemSetCollectionPieceInfo, setId, index)
                    if ok2 then
                        local ok3, isUnlocked = pcall(IsItemSetCollectionSlotUnlocked, setId, slot)
                        table.insert(lines, string.format("piece #%d: pieceId=%s unlocked=%s", index, tostring(pieceId), ok3 and tostring(isUnlocked) or "call_failed"))
                    else
                        table.insert(lines, string.format("piece #%d: GetItemSetCollectionPieceInfo call failed: %s", index, tostring(pieceId)))
                    end
                end
            end
            -- Chat can't be selected/copied in ESO, so this goes through the
            -- same popup as export/import rather than a wall of d() lines.
            BuildTracker.UI.ShowExportBox("Debug: Set Collection data for setId " .. setId, table.concat(lines, "\n"))
        end

    elseif cmd == "debugsetitems" then
        local setId = tonumber(args[2])
        local targetItemId = tonumber(args[3])
        if not setId then
            d("Usage: /bt debugsetitems <setId> [itemId to search for]")
        else
            local lines = {}
            local ok, result = BuildTracker.Sets.GetSetItemIdsRaw(setId)
            table.insert(lines, string.format("GetSetItemIds(%d): call_ok=%s, type=%s", setId, tostring(ok), type(result)))

            if ok and type(result) == "table" then
                local count = 0
                local nonZeroCount = 0
                local nonZeroSample = {}

                if targetItemId then
                    local isMember = result[targetItemId] ~= nil
                    table.insert(lines, string.format("itemId %d is a key in this set's table: %s", targetItemId, tostring(isMember)))
                    if isMember then
                        local link = BuildTracker.Sets.BuildItemLink(targetItemId)
                        if link then
                            local ok2, equipType = pcall(GetItemLinkEquipType, link)
                            local ok3, armorType = pcall(GetItemLinkArmorType, link)
                            local ok4, weaponType = pcall(GetItemLinkWeaponType, link)
                            table.insert(lines, string.format("  equipType=%s armorType=%s weaponType=%s",
                                ok2 and tostring(equipType) or "err", ok3 and tostring(armorType) or "err", ok4 and tostring(weaponType) or "err"))
                        end
                    end
                    table.insert(lines, "---")
                end

                for itemId in pairs(result) do
                    count = count + 1
                    local link = BuildTracker.Sets.BuildItemLink(itemId)
                    if link then
                        local ok2, equipType = pcall(GetItemLinkEquipType, link)
                        if ok2 and equipType ~= 0 then
                            nonZeroCount = nonZeroCount + 1
                            if #nonZeroSample < 40 then
                                local ok3, armorType = pcall(GetItemLinkArmorType, link)
                                local ok4, weaponType = pcall(GetItemLinkWeaponType, link)
                                table.insert(nonZeroSample, string.format("  itemId=%s equipType=%s armorType=%s weaponType=%s",
                                    tostring(itemId), tostring(equipType), ok3 and tostring(armorType) or "err", ok4 and tostring(weaponType) or "err"))
                            end
                        end
                    end
                end

                table.insert(lines, string.format("Total entries: %d | non-dead (equipType~=0): %d", count, nonZeroCount))
                table.insert(lines, "Sample of non-dead entries (up to 40):")
                for _, line in ipairs(nonZeroSample) do table.insert(lines, line) end
            elseif ok then
                table.insert(lines, "value = " .. tostring(result))
            else
                table.insert(lines, "error = " .. tostring(result))
            end

            BuildTracker.UI.ShowExportBox("Debug: GetSetItemIds(" .. setId .. ")", table.concat(lines, "\n"))
        end

    elseif cmd == "debugsource" then
        local setId = tonumber(args[2])
        local lib = LibSets
        if not setId then
            d("Usage: /bt debugsource <setId>")
        elseif not lib then
            d("LibSets not loaded")
        else
            local lines = {}
            local lang = lib.clientLang
            table.insert(lines, "clientLang = " .. tostring(lang))

            local okCrafted, isCrafted = pcall(lib.IsCraftedSet, setId)
            table.insert(lines, string.format("IsCraftedSet: call_ok=%s isCrafted=%s", tostring(okCrafted), tostring(isCrafted)))

            local okMech, mechanicIds, mechanicNames, _, locationNames, zoneIds = pcall(lib.GetDropMechanic, setId, true, lang)
            table.insert(lines, string.format("GetDropMechanic: call_ok=%s mechanicIds=%s", tostring(okMech), tostring(mechanicIds)))
            if okMech and type(mechanicIds) == "table" then
                for i in ipairs(mechanicIds) do
                    local mn = mechanicNames and mechanicNames[i] and mechanicNames[i][lang]
                    local ln = locationNames and locationNames[i] and locationNames[i][lang]
                    local zid = zoneIds and zoneIds[i]
                    local zoneName
                    if zid then
                        local okZone, result = pcall(lib.GetZoneName, zid, lang)
                        if okZone then zoneName = result end
                    end
                    table.insert(lines, string.format("  [%d] mechanicName=%s locationName=%s zoneId=%s zoneName=%s",
                        i, tostring(mn), tostring(ln), tostring(zid), tostring(zoneName)))
                end
            end

            table.insert(lines, "---")
            table.insert(lines, "GetSetSourceText -> " .. tostring(BuildTracker.Sets.GetSetSourceText(setId)))
            table.insert(lines, "GetCraftLocationText -> " .. tostring(BuildTracker.Sets.GetCraftLocationText(setId)))

            local okItems, itemIdSet = BuildTracker.Sets.GetSetItemIdsRaw(setId)
            local firstItemId = okItems and type(itemIdSet) == "table" and next(itemIdSet)
            if firstItemId then
                local link = BuildTracker.Sets.BuildItemLink(firstItemId)
                table.insert(lines, string.format("GetSetReconstructionCost(itemId=%s) -> %s",
                    tostring(firstItemId), tostring(BuildTracker.Sets.GetSetReconstructionCost(setId, link))))
            end

            BuildTracker.UI.ShowExportBox("Debug: source info for setId " .. setId, table.concat(lines, "\n"))
        end

    elseif cmd == "settings" then
        if LibAddonMenu2 and BuildTracker.settingsPanel then
            LibAddonMenu2:OpenToPanel(BuildTracker.settingsPanel)
        else
            d("LibAddonMenu-2.0 settings panel isn't available - check it's installed and enabled.")
        end

    elseif cmd == "debug" then
        BuildTracker.debugEnabled = not BuildTracker.debugEnabled
        d("Debug logging " .. (BuildTracker.debugEnabled and "enabled" or "disabled"))

    else
        PrintUsage()
    end
end

SLASH_COMMANDS["/bt"] = SlashHandler
