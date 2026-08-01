KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end


---------------------------------------------------------------------
-- Commands
local function HandleKDDCommand(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    local usage = "Usage: /kdd <settings || grievous || bosstimer || played || points || totalpoints || armory || junkstyle || hidelogout || normlogout || questtracker || openall || writhing || resetcraft || pocket>"

    if (length == 0) then
        CHAT_ROUTER:AddSystemMessage(usage)
        return
    end

    KyzderpsDerps:dbg(args)

    -- Toggle grievous retaliation overlay
    if (args[1] == "grievous") then
        GrievousRetaliation:SetHidden(not GrievousRetaliation:IsHidden())

    elseif (args[1] == "settings") then
        LibAddonMenu2:OpenToPanel(KyzderpsDerpsOptions)

    -- toggle bosstimer
    elseif (args[1] == "bosstimer") then
        KyzderpsDerps.savedOptions.spawnTimer.enable = not KyzderpsDerps.savedOptions.spawnTimer.enable
        SpawnTimerContainer:SetHidden(not SpawnTimerContainer:IsHidden())
        if (WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable")) then
            WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable"):UpdateValue()
        end

    -- played
    elseif (args[1] == "played") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildPlayed())

    -- points
    elseif (args[1] == "points") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildPoints())

    -- totalpoints
    elseif (args[1] == "totalpoints") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildTotalPoints())

    -- armory
    elseif (args[1] == "armory") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildArmory())

    -- junk style pages
    elseif (args[1] == "junkstyle" or args[1] == "junkstyles") then
        local junkedItems = {}
        local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
        for _, item in pairs(bagCache) do
            -- Skip items that are already junk, obviously
            if (not IsItemJunk(item.bagId, item.slotIndex)) then
                local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
                local itemType, specializedType = GetItemLinkItemType(itemLink)
                if (itemType == ITEMTYPE_CONTAINER and specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE) then
                    SetItemIsJunk(item.bagId, item.slotIndex, true)
                    if (not junkedItems[itemLink]) then
                        junkedItems[itemLink] = 0
                    end
                    junkedItems[itemLink] = junkedItems[itemLink] + 1
                end
            end
        end

        local displayMessage = "Marked the following items as junk:"
        for itemLink, num in pairs(junkedItems) do
            displayMessage = string.format("%s\n|cDDDDDD%s x%d", displayMessage, itemLink, num)
        end
        KyzderpsDerps:msg(displayMessage)

    -- resetchests
    elseif (args[1] == "resetchests") then
        KyzderpsDerps.ChatSpam.ResetCounter()

    -- List furnishings in a home with a filter, undocumented because could be... controversial
    elseif (args[1] == "furn") then
        if (length ~= 2) then
            CHAT_ROUTER:AddSystemMessage("Usage: /kdd furn <itemnamefilter>")
            return
        end

        KyzderpsDerps:msg("Furnishings in this house matching \"" .. args[2] .. "\":")
        local furnitureId = nil
        local itemId = nil
        repeat
            furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
            if furnitureId ~= nil then
                local link = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS)
                if (string.find(string.lower(GetItemLinkName(link)), string.lower(args[2]))) then
                    CHAT_ROUTER:AddSystemMessage(link)
                end
            end
        until furnitureId == nil

    -- toggles hiding on logout
    elseif (args[1] == "hide") then
        KyzderpsDerps.savedOptions.misc.hideOnLogout = not KyzderpsDerps.savedOptions.misc.hideOnLogout
        KyzderpsDerps:msg(string.format("Hiding upon logout is now set to %s", tostring(KyzderpsDerps.savedOptions.misc.hideOnLogout)))

    -- logs out without loading few addons
    elseif (args[1] == "normlogout") then
        KyzderpsDerps.PreLogout.doNotLoadOverride = true
        KyzderpsDerps:msg("Logging out without loading few addons...")
        Logout()

    -- toggles the quest tracker panel
    elseif (args[1] == "questtracker") then
        ZO_FocusedQuestTrackerPanel:SetHidden(not ZO_FocusedQuestTrackerPanel:IsHidden())

    -- re-scans and opens containers
    elseif (args[1] == "openall") then
        KyzderpsDerps.Opener.OpenAllInBackpack()

    -- opens writhing wall event crafting boxes
    elseif (args[1] == "writhing") then
        KyzderpsDerps.Opener.OpenAllWrithingCrafting()

    -- janky manual reset for priority craft reroll
    elseif (args[1] == "resetcraft") then
        KyzderpsDerps.Chatter.ResetPriority()

    -- i am forgerful
    elseif (args[1] == "kyzerg") then
        KyzderpsDerps.Sync.Kyzerg.PrintCommands()

    -- attach jogroup frame to the unit (for pocket healing!)
    elseif (args[1] == "pocket") then
        if (length ~= 2) then
            KyzderpsDerps:msg("Usage: /kdd pocket <@name> | /kdd pocket clear ")
            return
        end
        if (args[2] == "clear") then
            KyzderpsDerps.JoGroup.ClearPockets()
        else
            KyzderpsDerps.JoGroup.Pocket(args[2])
        end

    -- Unknown
    else
        CHAT_ROUTER:AddSystemMessage(usage)
    end
end

local function FixUI()
    if (MajorCourageTracker) then
        MajorCourageTracker.Reset()
    end
    if (PurgeTracker) then
        PurgeTracker.Reset()
    end
    if (HealerBFF) then
        HealerBFF.Reset()
    end
    if (JoGroup) then
        JoGroup.ReAnchor()
    end
    if (btg) then
        btg.CheckActivation()
    end
end

local function ToggleLuiIds()
    if (not LUIE or not LUIE.SpellCastBuffs) then
        KyzderpsDerps:msg("LUI SpellCastBuffs is not enabled")
        return
    end
    LUIE.SpellCastBuffs.SV.ShowDebugAbilityId = not LUIE.SpellCastBuffs.SV.ShowDebugAbilityId
    LUIE.SpellCastBuffs.Reset()
    KyzderpsDerps:msg("Toggled showing IDs on LUI buffs/debuffs")
end


---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeCommands()
    SLASH_COMMANDS["/kdd"] = HandleKDDCommand
    SLASH_COMMANDS["/fixui"] = FixUI
    SLASH_COMMANDS["/ids"] = ToggleLuiIds

    -- Porting to player
    SLASH_COMMANDS["/wayshrine"] = function() KyzderpsDerps.PortToPlayerInZone(KyzderpsDerps.savedOptions.misc.wayshrineZoneId, true) end
    SLASH_COMMANDS["/currentshrine"] = function() KyzderpsDerps.PortToPlayerInZone(GetZoneId(GetUnitZoneIndex("player")), true) end
    SLASH_COMMANDS["/ktp"] = KyzderpsDerps.PortToAny
    SLASH_COMMANDS["/ktpp"] = function(argString)
        if (argString == "") then
            KyzderpsDerps:msg("Usage: /ktpp <@name>")
            KyzderpsDerps:msg("Note: You can now use /ktp to port to both players in zones and specific players, but /ktpp will only search for specific player.")
            return
        end
        if (not StartsWith(argString, "@")) then
            argString = "@" .. argString
        end
        KyzderpsDerps.PortToAny(argString)
    end

    SLASH_COMMANDS["/refreshsurvey"] = KyzderpsDerps.Loot.RefreshSurvey

    -- Shortcut commands
    -- TODO: change to a table... and probably add /bank /merchant
    SLASH_COMMANDS["/bastian"] = function() UseCollectible(9245) end
    SLASH_COMMANDS["/mirri"] = function() UseCollectible(9353) end
    SLASH_COMMANDS["/ember"] = function() UseCollectible(9911) end
    SLASH_COMMANDS["/isobel"] = function() UseCollectible(9912) end
    SLASH_COMMANDS["/sharp"] = function() UseCollectible(11113) end
    SLASH_COMMANDS["/azandar"] = function() UseCollectible(11114) end
    SLASH_COMMANDS["/tanlorin"] = function() UseCollectible(12172) end
    SLASH_COMMANDS["/zerith"] = function() UseCollectible(12173) end

    SLASH_COMMANDS["/tythis"] = function() UseCollectible(267) end
    SLASH_COMMANDS["/nuzhimeh"] = function() UseCollectible(301) end
    SLASH_COMMANDS["/ezabi"] = function() UseCollectible(6376) end
    SLASH_COMMANDS["/fezez"] = function() UseCollectible(6378) end
    SLASH_COMMANDS["/jangleplume"] = function() UseCollectible(8994) end
    SLASH_COMMANDS["/peddler"] = function() UseCollectible(8995) end
    SLASH_COMMANDS["/steward"] = function() UseCollectible(9743) end
    SLASH_COMMANDS["/delegate"] = function() UseCollectible(9744) end
    SLASH_COMMANDS["/pyroclast"] = function() UseCollectible(11097) end
    SLASH_COMMANDS["/xyn"] = function() UseCollectible(12414) end

    SLASH_COMMANDS["/armory"] = function() UseCollectible(9745) end
    SLASH_COMMANDS["/ghrasharog"] = function() UseCollectible(9745) end

    SLASH_COMMANDS["/decon"] = function() UseCollectible(10184) end
    SLASH_COMMANDS["/giladil"] = function() UseCollectible(10184) end
end
