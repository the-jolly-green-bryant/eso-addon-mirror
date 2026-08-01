HT_Tooltip = HT_Tooltip or {}

local lastTooltipLink = nil
local lastTooltipTime = 0
local pendingTooltip = nil
local pendingTooltipTimer = nil

local function GetTimestamp()
    return os.date("%H:%M:%S")
end

local function GetVars()
    local serverKey = GetWorldName()
    HyboremTutor_Vars = HyboremTutor_Vars or {}
    HyboremTutor_Vars[serverKey] = HyboremTutor_Vars[serverKey] or {}
    return HyboremTutor_Vars[serverKey]
end

local function GetCharacterNameById(id)
    if not id or id == "0" or id == "None selected" then return "None selected" end
    if HT_LAM and HT_LAM.GetCharacterNameById then
        return HT_LAM.GetCharacterNameById(id)
    end
    return "None selected"
end

local function FilterExcluded(list, excluded)
    local filtered = {}
    for _, name in ipairs(list) do
        local isExcluded = false
        for _, exName in ipairs(excluded) do
            if exName == name then
                isExcluded = true
                break
            end
        end
        if not isExcluded then
            table.insert(filtered, name)
        end
    end
    return filtered
end

-- Sprawdza czy przedmiot może być nauczony (cena <= limit)
local function CanLearn(itemLink, charName)
    if not itemLink or not charName or charName == "None selected" then return false end
    if HT_Knowledge.IsKnownByChar(itemLink, charName) then return false end
    
    local category = HT_Knowledge.GetCategory(itemLink)
    local vars = GetVars()
    
    -- Style pages - nigdy
    if category == "STYLE" then
        return false
    end
    
    -- Scripty - tylko jeśli przypisany
    if category == "SCRIPT" then
        local scriptLearner = vars.scriptLearner or "0"
        local learnerName = GetCharacterNameById(scriptLearner)
        if learnerName ~= charName then return false end
        local isBound = itemLink:find("BIND_ON_PICKUP") ~= nil
        if isBound then return true end
        local price = LibPriceCache and LibPriceCache.GetPrice(itemLink) or 0
        local limit = HT_Knowledge.GetPriceLimit(category)
        return price > 0 and price <= limit
    end
    
    -- Motify, RECIPE, PLAN - sprawdź cenę
    local price = LibPriceCache and LibPriceCache.GetPrice(itemLink) or 0
    local limit = HT_Knowledge.GetPriceLimit(category)
    
    -- Sprawdź priorytet
    local mySlot = nil
    for i = 1, 3 do
        local slot = vars["p"..i]
        if slot and slot.char ~= "0" and slot.char ~= "None selected" then
            local slotCharName = GetCharacterNameById(slot.char)
            if slotCharName == charName then 
                mySlot = i
                break 
            end
        end
    end
    
    local hasPriority = mySlot and HT_Knowledge.HasPriority(category, mySlot) or false
    if hasPriority then
        return true
    end
    
    return price > 0 and price <= limit
end

function HT_Tooltip.AddKnowledgeTooltip(tooltip, itemLink, gamepad)
    local vars = GetVars()
    if not itemLink or not vars.enableTooltips then return end
    if not HT_Knowledge.IsInterestingItemByLink(itemLink) then return end
    
    -- Dla gamepada pobierz odpowiedni tooltip
    if gamepad then
        tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
        if not tooltip then return end
    end
    
    if not tooltip.AddLine then return end
    
    local characters = HT_Knowledge.GetAllCharacters()
    if not characters or #characters <= 1 then return end
    
    local knownList = {}
    local unknownList = {}
    local canLearnList = {}
    
    for _, charName in ipairs(characters) do
        if charName ~= "None selected" then
            local known = HT_Knowledge.IsKnownByChar(itemLink, charName)
            if known then
                table.insert(knownList, charName)
            else
                table.insert(unknownList, charName)
                -- Sprawdź czy może się nauczyć (cena <= limit)
                if CanLearn(itemLink, charName) then
                    table.insert(canLearnList, charName)
                end
            end
        end
    end
    
    if #knownList == 0 and #unknownList == 0 then return end
    
    -- Filtruj wykluczone
    local excluded = vars.excludedCharacters or {}
    local filteredKnown = FilterExcluded(knownList, excluded)
    local filteredUnknown = FilterExcluded(unknownList, excluded)
    local filteredCanLearn = FilterExcluded(canLearnList, excluded)
    
    -- Filtruj według trybu
    local tooltipMode = vars.tooltipMode or "All characters"
    
    if tooltipMode == "Only missing (can learn)" then
        filteredKnown = {}
        filteredUnknown = filteredCanLearn
    elseif tooltipMode == "Only traders" then
        local traderId = vars.trader or "0"
        local traderName = GetCharacterNameById(traderId)
        if traderName and traderName ~= "None selected" then
            local tempKnown = {}
            local tempUnknown = {}
            for _, name in ipairs(filteredKnown) do
                if name == traderName then
                    table.insert(tempKnown, name)
                end
            end
            for _, name in ipairs(filteredUnknown) do
                if name == traderName then
                    table.insert(tempUnknown, name)
                end
            end
            filteredKnown = tempKnown
            filteredUnknown = tempUnknown
        else
            filteredKnown = {}
            filteredUnknown = {}
        end
    end
    
    if #filteredKnown == 0 and #filteredUnknown == 0 then return end
    
    if gamepad then
        -- Gamepad mode - style predefiniowane
        local header = string.format("Hyborem's Tutor (%d/%d)", #filteredKnown, #filteredKnown + #filteredUnknown)
        tooltip:AddLine(header, ZO_TOOLTIP_STYLES["topSection"])
        if #filteredKnown > 0 then
            tooltip:AddLine(string.format("Known: %s", table.concat(filteredKnown, ", ")), ZO_TOOLTIP_STYLES["favor"])
        end
        if #filteredUnknown > 0 then
            tooltip:AddLine(string.format("Unknown: %s", table.concat(filteredUnknown, ", ")), ZO_TOOLTIP_STYLES["alert"])
        end
    else
        -- Keyboard mode - kolory RGB
        tooltip:AddLine("Hyborem's Tutor", "ZoFontWinH3", 0.58, 1, 0.54, CENTER)
        ZO_Tooltip_AddDivider(tooltip)
        if #filteredKnown > 0 then
            tooltip:AddLine(string.format("Known (%d): %s", #filteredKnown, table.concat(filteredKnown, ", ")), "ZoFontWinH5", 0, 1, 0, LEFT)
        end
        if #filteredUnknown > 0 then
            if #filteredKnown > 0 then
                tooltip:AddLine(" ", "ZoFontWinH5", 1, 1, 1, LEFT)
            end
            tooltip:AddLine(string.format("Unknown (%d): %s", #filteredUnknown, table.concat(filteredUnknown, ", ")), "ZoFontWinH5", 1, 0, 0, LEFT)
        end
    end
end

local function DelayedAddTooltip(control, link, gamepad)
    if pendingTooltipTimer then
        pendingTooltipTimer = nil
    end
    
    pendingTooltip = {control = control, link = link, gamepad = gamepad}
    pendingTooltipTimer = zo_callLater(function()
        if pendingTooltip and pendingTooltip.control and pendingTooltip.link then
            pcall(function()
                HT_Tooltip.AddKnowledgeTooltip(pendingTooltip.control, pendingTooltip.link, pendingTooltip.gamepad)
            end)
        end
        pendingTooltip = nil
        pendingTooltipTimer = nil
    end, 50)
end

-- Funkcja pomocnicza do hookowania tooltipów
local function TooltipHook(control, funcName, getLinkFunc)
    if not control then return end
    
    local originalFunc = control[funcName]
    if not originalFunc then return end
    
    control[funcName] = function(self, ...)
        originalFunc(self, ...)
        
        local vars = GetVars()
        if vars and vars.enableTooltips then
            local link = getLinkFunc and getLinkFunc(...) or ...
            if link and type(link) == "string" and link:find("|H") then
                local now = GetFrameTimeSeconds()
                if link == lastTooltipLink and (now - lastTooltipTime) < 0.2 then
                    return
                end
                lastTooltipLink = link
                lastTooltipTime = now
                
                local isGamepad = IsInGamepadPreferredMode()
                DelayedAddTooltip(self, link, isGamepad)
            end
        end
    end
end

-- Funkcja dla gamepada - poprawiona
local function GamepadTooltipHook(tooltipControl, functionName)
    if not tooltipControl then return end
    
    local base = tooltipControl[functionName]
    if not base then return end
    
    tooltipControl[functionName] = function(control, bagId, slotIndex, ...)
        base(control, bagId, slotIndex, ...)
        
        local vars = GetVars()
        if vars and vars.enableTooltips then
            local link = nil
            if bagId ~= nil and slotIndex ~= nil then
                link = GetItemLink(bagId, slotIndex)
            end
            if link and type(link) == "string" and link:find("|H") then
                local isGamepad = true
                DelayedAddTooltip(tooltipControl, link, isGamepad)
            end
        end
    end
end

function HT_Tooltip.HookTooltips()
    -- Keyboard tooltips
    TooltipHook(ItemTooltip, "SetLink")
    TooltipHook(ItemTooltip, "SetBagItem", function(bag, slot) return GetItemLink(bag, slot) end)
    TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    TooltipHook(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
    TooltipHook(PopupTooltip, "SetLink")
    
    -- Crafting
    if ZO_SmithingTopLevelCreationPanelResultTooltip then
        TooltipHook(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
    end
    
    if ZO_ProvisionerTopLevelTooltip then
        TooltipHook(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
    end
    
    -- Gamepad tooltips
    local leftTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
    if leftTooltip then
        GamepadTooltipHook(leftTooltip, "LayoutBagItem")
    end
    
    local rightTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
    if rightTooltip then
        GamepadTooltipHook(rightTooltip, "LayoutBagItem")
    end
    
    local movableTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP)
    if movableTooltip then
        GamepadTooltipHook(movableTooltip, "LayoutBagItem")
    end
    
    -- Gamepad inventory
    if GAMEPAD_INVENTORY then
        local originalUpdate = GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip
        if originalUpdate then
            GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip = function(self, ...)
                originalUpdate(self, ...)
                
                local vars = GetVars()
                if vars and vars.enableTooltips then
                    if self.currentSelectedData and self.currentSelectedData.bagId and self.currentSelectedData.slotIndex then
                        local itemLink = GetItemLink(self.currentSelectedData.bagId, self.currentSelectedData.slotIndex)
                        if itemLink and type(itemLink) == "string" and itemLink:find("|H") then
                            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
                            if tooltip then
                                DelayedAddTooltip(tooltip, itemLink, true)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Gamepad mail
    if ZO_MailInbox_Gamepad and ZO_MailInbox_Gamepad.InitializeKeybindDescriptors then
        local originalInit = ZO_MailInbox_Gamepad.InitializeKeybindDescriptors
        ZO_MailInbox_Gamepad.InitializeKeybindDescriptors = function(self)
            originalInit(self)
            if self.mainKeybindDescriptor and self.mainKeybindDescriptor[3] then
                local originalCallback = self.mainKeybindDescriptor[3].callback
                self.mainKeybindDescriptor[3].callback = function()
                    originalCallback()
                    local attachmentLink = GetAttachedItemLink(self.selectedMailIndex)
                    if attachmentLink then
                        local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
                        if tooltip then
                            DelayedAddTooltip(tooltip, attachmentLink, true)
                        end
                    end
                end
            end
        end
    end
    
    local vars = GetVars()
    if vars and vars.enableLogs then
        CHAT_SYSTEM:AddMessage(string.format("[%s] [HT_Tooltip] Tooltip hooks installed", GetTimestamp()))
    end
end