if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

--- AND Logic:
--- false,false = false
--- true,false = false
--- true, true = true
--- OR logic:
--- false,false = false
--- true,false = true
--- true,true = true

-------------------------------------------------------------------------
---Utilities
-------------------------------------------------------------------------

function PUG:preCheck()
    --- start building the alert box
    local msg = {
        [1] = "\n"
    }
    local charges, currentCharges, maxCharges, x, cond
    local buff = false
    local numBuffs = GetNumBuffs("player")
    --- pale order ring on? ItemId = 171436
    if GetItemId(BAG_WORN, EQUIP_SLOT_RING1) == 171436 or GetItemId(BAG_WORN, EQUIP_SLOT_RING2) == 171436 then
        table.insert(msg, "|cFF0000 |l1:1:1:4:5:FFC000|l--> RING OF PALE ORDER EQUIPPED! <--|l|r\n\n")
    end

    --- any buffs active
    table.insert(msg, "|c009900 |l1:1:1:4:5:FFC000|lActive Buffs|l|r")
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, _, _, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        --- vamp stage 4? abilityId = 135402 stage 3 = 135400
        if abilityId == 135402 then
            table.insert(msg, 2, "|cFF0000|l1:1:1:4:5:FFC000|l--> VAMPIRE STAGE 4! <--|l|r\n\n")
        end
        if timeEnding ~= timeStarted then
            buff = true
            table.insert(msg, "\n|t32:32:" .. iconFilename .. "|t " .. buffName .. "\n|c00FF00Time Left: |r" .. FormatTimeSeconds(timeEnding - (GetGameTimeSeconds()), 2, 1) .. "\n")
        end
    end
    if not buff then
        table.insert(msg, "\n|cFF0000No|r Food or Drink Active\n")
    end

    --- check armor and enchant
    if PUG.SV.minCond > 1 then
        table.insert(msg, "\n|c009900|l1:1:1:4:5:FFC000|lGear Condition|l|r\n")
        x = ""
        ZO_Inventory_EnumerateEquipSlots(function(a)
            cond = GetItemCondition(BAG_WORN, a)
            if cond > 0 and cond ~= 100 then
                x = PUG.color.green
                if cond <= PUG.SV.minCond then
                    x = PUG.color.red
                end
                table.insert(msg, GetItemName(BAG_WORN, a) .. " is at: " .. x .. cond .. "%|r\n")
            end
        end)
    end
    x = ""
    if PUG.SV.minCharges > 1 then
        table.insert(msg, "\n|c009900|l1:1:1:4:5:FFC000|lEnchant or Poison|l|r\n")

        if HasItemInSlot(BAG_WORN, EQUIP_SLOT_POISON) then
            x = "Front Bar |cFFC000" .. GetItemName(BAG_WORN, EQUIP_SLOT_POISON) .. "|r is Slotted\n"
        else
            x = ""
            currentCharges, maxCharges = GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
            if maxCharges > 0 then
                charges = (currentCharges * 100) / maxCharges
                if charges <= PUG.SV.minCharges then
                    charges = "|cFF0000" .. charges .. "%|r\n"
                else
                    charges = "|c00FF00" .. charges .. "%|r\n"
                end
                x = "Front Main-Hand Ench: " .. charges
            end
            table.insert(msg, x)
            x = ""

            currentCharges, maxCharges = GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_OFF_HAND)
            if maxCharges > 0 then
                charges = (currentCharges * 100) / maxCharges
                if charges <= PUG.SV.minCharges then
                    charges = "|cFF0000" .. charges .. "%|r\n"
                else
                    charges = "|c00FF00" .. charges .. "%|r\n"
                end
                x = "Front Off-Hand Ench: " .. charges
            end
            table.insert(msg, x)
            x = ""
        end
        table.insert(msg, x)

        if HasItemInSlot(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) then
            x = "Back Bar |cFFC000" .. GetItemName(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) .. "|r is Slotted\n"
        else
            x = ""
            currentCharges, maxCharges = GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
            if maxCharges > 0 then
                charges = (currentCharges * 100) / maxCharges
                if charges <= PUG.SV.minCharges then
                    charges = "|cFF0000" .. charges .. "%|r\n"
                else
                    charges = "|c00FF00" .. charges .. "%|r\n"
                end
                x = "Back Main-Hand Ench: " .. charges
            end
            table.insert(msg, x)
            x = ""

            currentCharges, maxCharges = GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
            if maxCharges > 0 then
                charges = (currentCharges * 100) / maxCharges
                if charges <= PUG.SV.minCharges then
                    charges = "|cFF0000" .. charges .. "%|r\n"
                else
                    charges = "|c00FF00" .. charges .. "%|r\n"
                end
                x = "Back Off-Hand Ench: " .. charges
            end
            table.insert(msg, x)
            x = ""
        end
    end

    --- Miscellaneous items
    table.insert(msg, x)
    x = ""
    table.insert(msg, "\n|c009900|l1:1:1:4:5:FFC000|lMisc.|l|r\n")
    local misc = false

    if not PUG.SV.setEncounterLog then
        if IsEncounterLogEnabled() then
            x = "|c00FF00ON|r\n"
        else
            x = "|cFF0000OFF|r\n"
        end
        table.insert(msg, "Encounter Log is " .. x)
        misc = true
    end
    x = ""

    if PUG.SV.freeSlots > 0 then
        x = GetNumBagFreeSlots(BAG_BACKPACK)
        if x >= PUG.SV.freeSlots then
            x = "|c00FF00" .. x .. "|r"
        else
            x = "|cFF0000" .. x .. "|r"
        end
        table.insert(msg, "You have " .. x .. " free bag slots.\n")
        misc = true
    end
    x = ""

    ---item:33271: soul gem
    ---item:61079: crown repair kit
    ---item:44879: grand repair kit
    ---item:157516: group repair kit

    if PUG.SV.showGemsAndKits then
        local gems, kits = 0, 0
        local gem, kit = "", ""
        for i = 1, GetBagSize(BAG_BACKPACK, i) do
            if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, i) or GetItemId(BAG_BACKPACK, i) == 33271 then
                --PUG:debug("gem " .. i)
                gems = gems + GetSlotStackSize(BAG_BACKPACK, i)
            end
            if IsItemRepairKit(BAG_BACKPACK, i) or GetItemId(BAG_BACKPACK, i) == 44879 or GetItemId(BAG_BACKPACK, i) == 157516 then
                --PUG:debug("kit " .. i)
                kits = kits + GetSlotStackSize(BAG_BACKPACK, i)
            end
        end

        if gems > 0 then
            gem = "|c00FF00" .. gems .. "|r"
        else
            gem = "|cFF0000" .. gems .. "|r"
        end

        if kits > 0 then
            kit = "|c00FF00" .. kits .. "|r"
        else
            kit = "|cFF0000" .. kits .. "|r"
        end

        table.insert(msg, "You have " .. gem .. " soul gems\nand " .. kit .. " repair kits.\n")
        misc = true
    end

    if not misc then
        table.remove(msg)
    end
    --- send it off
    PUG.alertBox.confirm = true
    PUG.alertBox.pause = false
    PUG.alertBox.delay = 0
    PUGmoAlertBoxWindowConfirm:SetHidden(false)
    --PUG:debug(msg)
    PUG:addAlert(table.concat(msg))
end

-------------------------------------------------------------------------
--- if the name is the same as marked.name it removes marker and returns,
--- if not then removes any active marker and sets up maker for name
function PUG:markPlayer(name)
    if GetGroupSize() == 0 then
        return
    end
    if not PUG.data.isOSI then
        PUG:nonOSI(name)
        return
    end

    if IsUnitInCombat("player") then
        PUG:removeMarker()
        return d("Player marking not allowed while in combat")
    end
    if name == PUG.data.marked.name then
        PUG:removeMarker()
        return
    end
    PUG:removeMarker()
    PUG.data.hide = false
    PUGmoGO()

    for i = 1, 12 do
        local tag = "group" .. i
        if name == GetUnitDisplayName(tag) then
            --PUG:debug("found")

            PUG.data.marked = {
                icon = nil,
                delay = os.time() + PUG.SV.markedDelay,
                tag = tag,
                name = name,
            }
            local _, x, y, z = GetUnitRawWorldPosition(tag)
            PUG.data.marked.icon = OSI.CreatePositionIcon(
                    x, y, z, -- world coordinates
                    "PUGmo/icons/curse00.dds", -- icon texture path
                    OSI.GetIconSize() * 1.5, -- optional icon size
                    { 1, 0, 1 }, -- optional icon color {r,g,b}
                    0, -- optional icon offset in meters

            -- optional callback function
            -- the data object passed to the callback function contains:
            -- texture, size, color, offset
                    function(data)
                        if not PUG.data.marked.icon then
                            return
                        end
                        if IsUnitInCombat("player") then
                            if PUG.data.button then
                                PUG.data.button:SetEdgeColor(0, 0, 0)
                                --PUG:debug("in combat edge off")

                            end
                            PUG:removeMarker()
                            return
                        end
                        _, x, y, z = GetUnitRawWorldPosition(PUG.data.marked.tag)
                        PUG.data.marked.icon.x = x
                        PUG.data.marked.icon.y = y
                        PUG.data.marked.icon.z = z

                        -- simple bounce animation along the y-axis
                        data.offset = 2.5 + math.sin(GetGameTimeMilliseconds() / 1000 * 2)

                        if PUG.data.marked.delay > os.time() then
                            return
                        end
                        if PUG.data.button then
                            PUG.data.button:SetEdgeColor(0, 0, 0)
                            --PUG:debug("timer expired edge off")
                        end
                        PUG:removeMarker()
                    end
            )
            break
        end
        --PUG:debug(i)
    end
end
-------------------------------------------------------------------------
--- if there is no active marker it returns
--- turns off edgecolor for current button,
--- turns off arrow,
--- clears all marked data
function PUG:removeMarker()

    if not PUG.data.marked.icon then
        return
    end

    OSI.DiscardPositionIcon(PUG.data.marked.icon)
    PUG.data.marked = {
        icon = nil,
        delay = 0,
        tag = "",
        name = "",
    }
end
-------------------------------------------------------------------------

function PUG:nonOSI(name)
    if name == PUG.data.marked.name and PUG.data.button then
        PUG.data.button:SetEdgeColor(0, 0, 0)
        PUG.data.marked.name = ""
        PUG.data.button = nil
        --PUG:debug("nonOSI same name clicked - edge off")
        return
    else
        PUG.data.marked.name = name
        --PUG:debug("nonOSI Different name ")
        --PUG.data.button:SetEdgeColor(1, 0, 0)
        return
    end
end
-------------------------------------------------------------------------
function PUG:itemsToChat()
    --PUG:debug("*** itemsToChat")
    PUG.myLootList = {}
    local channel = CHAT_CHANNEL_PARTY
    local name = nil
    if IsShiftKeyDown() then
        if PUG.SV.bestFriend ~= "" then
            --- the best friend needs to be in group. If they left before the lest was sent it wont go
            for j = 1, 12 do
                --PUG:debug(GetUnitDisplayName("group" .. j))
                if GetUnitDisplayName("group" .. j) == PUG.SV.bestFriend then
                    channel = CHAT_CHANNEL_WHISPER
                    name = PUG.SV.bestFriend
                    break
                end
            end
            --- they are not in the group
            if not name then
                return
            end
        else
            --- no bestFriend setup
            return
        end
    end

    local putOnList = false
    local numOfItems = 0
    for i = 1, GetBagSize(BAG_BACKPACK) do
        local itemLink = GetItemLink(BAG_BACKPACK, i)
        --PUG:debug("-item #" .. i)
        --- if you want to save it for your bestie then lock it and it won't be linked
        if not IsItemPlayerLocked(BAG_BACKPACK, i) then
            --PUG:debug("-not locked")
            --- it came out of the coffer or it was bound from inventory, don't link it
            if (not IsItemBound(BAG_BACKPACK, i)) then
                --PUG:debug("-not bound")
                if IsItemLinkSetCollectionPiece(itemLink) then
                    --PUG:debug("-is collectable")
                    if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
                        --PUG:debug("-collected")
                        --PUG:debug("-skip legendary?", PUG.SV.skipLegendary)
                        --- skip legendary gear? (which should be only jewelery)
                        --- AND logic states true AND true = true everything else is false
                        --- to continue the result must be true
                        --- so true and true means we want to stop so we need to invert the result

                        if not (GetItemDisplayQuality(BAG_BACKPACK, i) == ITEM_DISPLAY_QUALITY_LEGENDARY and PUG.SV.skipLegendary) then
                            --PUG:debug("-not legendary")
                            --PUG:debug("-skip jewelery?", PUG.SV.skipJewelery)
                            --- skip all jewelery?
                            if not (GetItemLinkFilterTypeInfo(itemLink) == ITEMFILTERTYPE_JEWELRY and PUG.SV.skipJewelery) then
                                --PUG:debug("-not jewelery")
                                --GetItemQualityColor()
                                if GetItemBoPTimeRemainingSeconds(BAG_BACKPACK, i) > 0 then
                                    --PUG:debug("-time left to trade")
                                    local old = false
                                    --- oldLoot was made when we entered a new dungeon and that wont be listed. It will not know if you entered the
                                    --- same dungeon and got the same loot before the timer expires. It will not list it, it should be rare.
                                    if PUG.data.oldLoot then
                                        for j = 1, #PUG.data.oldLoot do
                                            --PUG:debug("* Old Loot *: " .. itemLink .. " <-- bag = old --> " .. PUG.data.oldLoot[j])
                                            if itemLink == PUG.data.oldLoot[j] then
                                                old = true
                                            end
                                        end
                                    end
                                    --PUG:debug("put on list?", not old)
                                    if not old then
                                        putOnList = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if putOnList then
            if numOfItems == 4 or numOfItems == 0 then
                PUG.myLootList[#PUG.myLootList + 1] = ""
                numOfItems = 0
            end
            PUG.myLootList[#PUG.myLootList] = PUG.myLootList[#PUG.myLootList] .. GetItemLink(BAG_BACKPACK, i, LINK_STYLE_BRACKETS) .. " "
            putOnList = false
            numOfItems = numOfItems + 1
            --PUG:debug("add it in")
        end
    end
    if #PUG.myLootList > 0 then
        --if name then
        --    PUG.myLootList[1] = "Do you want any of these? " .. PUG.myLootList[1]
        --end
        PUG:msgToChat(PUG.myLootList[1], channel, name)
    end
    --PUG:debug("msgToChat ***")
end

-------------------------------------------------------------------------
--- All of the internal strings in a link still count toward the 750 character limit for chat messages!
--- Links that are just added to the local chat window, rather than being sent over the network, have no such length restriction.
-------------------------------------------------------------------------
function PUG:msgToChat(msg, channel, name)
    local who = ""
    if name then
        who = "\nTo: " .. PUG.color.fushia .. name .. "|r" .. PUG.color.yellow
    end
    if msg ~= "" then
        PUG:addAlert(PUG.color.yellow .. "\nHIT " .. PUG.color.red .. " [ENTER]  " .. PUG.color.yellow .. "TO SEND" .. who .. "\nOR CLEAR THE CHAT BOX\n\n|r" .. msg .. "\n", "/esoui/art/campaign/campaign_tabicon_history_down.dds")
    end
    channel = channel or 3
    name = name or ""
    msg = msg or ""
    --PUG:debug("*** msgToChat: " .. msg .. " Channel: " .. channel .. " Name: " .. name .. " msgToChat ***")
    if channel == CHAT_CHANNEL_WHISPER  then
        StartChatInput(msg, channel, name)
        CHAT_SYSTEM:Maximize()
        return
    end
    CHAT_SYSTEM:SetChannel(channel)
    CHAT_SYSTEM.textEntry:SetText(msg)
    CHAT_SYSTEM:Maximize()
end

----CHAT_CHANNEL_WHISPER = 2
----CHAT_CHANNEL_PARTY = 3
----CHAT_CHANNEL_WHISPER_SENT = 4
----CHAT_CHANNEL_GUILD_1 = 12
----CHAT_CHANNEL_GUILD_2 = 13
----CHAT_CHANNEL_GUILD_3 = 14
----CHAT_CHANNEL_GUILD_4 = 15
----CHAT_CHANNEL_GUILD_5 = 16
----CHAT_CHANNEL_ZONE = 31
----CHAT_CHANNEL_ZONE_LANGUAGE_1 = 32
----CHAT_CHANNEL_ZONE_LANGUAGE_2 = 33
----CHAT_CHANNEL_ZONE_LANGUAGE_3 = 34
----CHAT_CHANNEL_ZONE_LANGUAGE_4 = 35
----CHAT_CHANNEL_ZONE_LANGUAGE_5 = 36

-------------------------------------------------------------------------
function PUG:convertRGBToHex(r, g, b)
    return string.format("|c%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

-------------------------------------------------------------------------
-- Table To String
-- http://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- Alundaio @ answered Feb 6 at 7:23
-------------------------------------------------------------------------
function PUG:tableToString(node)
    -- to make output beautiful
    local function tab(amt)
        local str = ""
        for i = 1, amt do
            str = str .. "--"
        end
        return str
    end

    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. tab(depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    return output_str
end

function PUG:ShowOnlyCategory(categoryId)
    ZO_ScrollList_HideAllCategories(PUGmoWindowZoneListLFG)
    ZO_ScrollList_ShowCategory(PUGmoWindowZoneListLFG, categoryId)
end
function PUG:HideCategory(categoryId)
    ZO_ScrollList_HideCategory(PUGmoWindowZoneListLFG, categoryId)
end
