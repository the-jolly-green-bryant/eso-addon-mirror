--[[
    BlockPooky CC Immunity Bar Module - Updated for ESO API Issues
    
    This module tracks and displays crowd control immunity duration through a visual bar.
    CC immunity can be gained from:
    - Dodge rolling (natural immunity via effects 29721/28301)
    - Consuming immunity potions (detected via effect 92416 "sicherer Stand")
    - Using specific skills that grant unstoppable/immunity
    
    IMPORTANT: Direct potion detection via EVENT_ITEM_ON_COOLDOWN and EVENT_INVENTORY_SINGLE_SLOT_UPDATE
    is currently broken in ESO API for custom crafted potions. The system now uses effect-based detection
    as the primary method, monitoring the immunity buffs when they are applied.
    
    Detection Methods (in order of reliability):
    1. Effect monitoring - Primary method, detects immunity buffs when applied (WORKING)
    2. Item cooldown events - Fallback, preserved for future API fixes (BROKEN)
    3. Inventory slot updates - Fallback, preserved for future API fixes (BROKEN)
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

-- Legacy potion ID table - kept for fallback detection when ESO fixes API
BlockPooky.unstoppableItems = {
    [27039]=10.4,  -- Potion of Immovability / Custom immunity potions (including cold cost)
    [71071]=10.4,  -- Alliance Health Draught
    [112430]=10.4, -- Gold Coast Survivor Elixir  
    [76844]=10.4, -- Escapist's Poison
}

-- Skills that grant CC immunity/unstoppable with their duration in seconds
BlockPooky.unstoppableSkills = {
    [177288]=4.0, -- Raschheit des Falken (Swift of the Falcon)
    [177289]=4.0, -- Trügerischer Räuber (Elusive Mist)
    [177290]=4.0, -- Raubvogel (Bird of Prey)
    [177244]=4.0, -- Illusorische Flucht (Phantasmal Escape)
    [122260]=4.0, -- Gegen die Zeit (Race Against Time)
    [108798]=4.0, -- Beschützende Platte (Protective Plate)
    [83239]=8.0, -- Berserkerwut (Berserker Rage)
}

--[[ ccbar implementation -------------------------------------------------------------------------------------------]]

function BlockPooky.SetCCBarColor()
    if BlockPooky.config.ccBarColor then
        BlockPooky.ccStatusBar:SetColor(unpack(BlockPooky.config.ccBarColor))
    else
        BlockPooky.ccStatusBar:SetColor(0, 1, 0, 1) -- Grün für Immunität
    end
end

---init cc immunity bar
function BlockPooky.initCCBarUI()
    -- Prüfen, ob die ccBar bereits existiert
    if not BlockPooky.ccBar then
        BlockPooky.ccBar = CreateControl(BlockPooky.name.."CCBar", GuiRoot, CT_TOPLEVELCONTROL)
        BlockPooky.ccBar:SetDimensions(200, 40)
        BlockPooky.ccBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
        BlockPooky.ccBar:SetHidden(true)
        BlockPooky.ccBar:SetMovable(true) -- Verschiebbar machen
        BlockPooky.ccBar:SetMouseEnabled(true) -- Mausinteraktionen erlauben

        -- Event für das Loslassen nach dem Bewegen
        BlockPooky.ccBar:SetHandler("OnMoveStop", function()
            BlockPooky.SaveCCBarPosition()
        end)
    end

    -- Prüfen, ob das Label bereits existiert
    if not BlockPooky.ccLabel then
        BlockPooky.ccLabel = CreateControl(BlockPooky.name.."CCLabel", BlockPooky.ccBar, CT_LABEL)
        BlockPooky.ccLabel:SetFont("ZoFontWinH4")
        BlockPooky.ccLabel:SetColor(1, 1, 1, 1) -- Weiß
        BlockPooky.ccLabel:SetText("")
        BlockPooky.ccLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.ccLabel:SetAnchor(TOP, BlockPooky.ccBar, TOP, 0, 0)
    end

    -- Prüfen, ob die Statusbar bereits existiert
    if not BlockPooky.ccStatusBar then
        BlockPooky.ccStatusBar = CreateControl(BlockPooky.name.."CCStatus", BlockPooky.ccBar, CT_STATUSBAR)
        BlockPooky.ccStatusBar:SetDimensions(200, 20)
        BlockPooky.ccStatusBar:SetAnchor(BOTTOM, BlockPooky.ccBar, BOTTOM, 0, 0)
        BlockPooky.ccStatusBar:SetMinMax(0, 1)
        BlockPooky.SetCCBarColor()
    end

    -- Lade die gespeicherte Position
    BlockPooky.LoadCCBarPosition()
end

function BlockPooky.SaveCCBarPosition()
    local left, top = BlockPooky.ccBar:GetLeft(), BlockPooky.ccBar:GetTop()
    BlockPooky.config.ccBarPosition = {left = left, top = top}
end

function BlockPooky.LoadCCBarPosition()
    if BlockPooky.ccBar then
        if BlockPooky.config and BlockPooky.config.ccBarPosition then
            if BlockPooky.ccBar:GetAnchor() ~= nil then
                BlockPooky.ccBar:ClearAnchors()
            end
            BlockPooky.ccBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.ccBarPosition.left, BlockPooky.config.ccBarPosition.top)
        else
            BlockPooky.ResetCCBarPosition()
        end
    end
end


local BlockPooky_ccBarActiveEndTime = 0
local BlockPooky_ccBarFromPotion = false
function BlockPooky.showCCbar(beginTime, endTime)
    local showed = false;
    if endTime > BlockPooky_ccBarActiveEndTime then
        showed = true;
        BlockPooky_ccBarActiveEndTime = endTime
        local duration = endTime - beginTime
        BlockPooky.ccStatusBar:SetMinMax(0, duration)
        BlockPooky.ccStatusBar:SetValue(duration)
        BlockPooky.ccLabel:SetText(BlockPooky.config.messages.ccImmunity) -- Text über dem Balken
        BlockPooky.ccBar:SetHidden(false)

        -- Update-Funktion für die Leiste starten
        EVENT_MANAGER:RegisterForUpdate(BlockPooky.name.."UpdateCCBar", 50, function()
            local remaining = BlockPooky_ccBarActiveEndTime - GetGameTimeSeconds()
            if remaining <= 0 then
                BlockPooky.ccBar:SetHidden(not BlockPooky.config.lockedUI)
                EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name.."UpdateCCBar")
            else
                BlockPooky.ccStatusBar:SetValue(remaining)
            end
        end)
    end
    return showed
end

---Registers or unregisters CC immunity detection events based on configuration
---Primary detection uses EVENT_EFFECT_CHANGED to monitor immunity buffs when applied
---Fallback methods preserved for future ESO API fixes
function BlockPooky.CCEventRegisterUpdate()
    if BlockPooky.config.CCImmunityHint then
        -- Primary detection method: Monitor effect changes (WORKING)
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED, function(...) BlockPooky.OnCCImmunityChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        
    -- Fallback: Item cooldown events (currently broken for custom potions in ESO API)
    -- EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "ItemCooldown", EVENT_ITEM_ON_COOLDOWN, function(...) BlockPooky.OnItemUsed(...) end)
        
        -- Fallback: Inventory slot updates (currently broken for custom potions in ESO API)
    -- Register for backpack item consumption (potions)
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) BlockPooky.OnSlotUpdate(...) end )
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false)
    -- Register for worn item changes (poisons on weapon slot)
    EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) BlockPooky.OnSlotUpdate(...) end )
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(BlockPooky.name.."InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false)
    else
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "CCWatcher")
    -- EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "ItemCooldown")
    EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "InventoryUpdateBackpack")
    EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "InventoryUpdateWorn")
    end
end

function BlockPooky.ResetCCBarPosition()
    if BlockPooky.ccBar:GetAnchor() ~= nil then
        BlockPooky.ccBar:ClearAnchors()
    end
    BlockPooky.ccBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    BlockPooky.SaveCCBarPosition()
end

function BlockPooky.RestoreCCBarPosition()
    BlockPooky.LoadCCBarPosition()
end

--[[ event handling -------------------------------------------------------------------------------------------------]]

---Primary CC immunity detection via effect monitoring
---This function detects immunity buffs when they are applied and determines their source
---@param eventCode number EVENT_EFFECT_CHANGED
---@param changeType number EFFECT_RESULT_GAINED or EFFECT_RESULT_FADED  
---@param effectSlot number effect slot number
---@param effectName string localized effect name
---@param unitTag string unit tag ("player")
---@param beginTime number effect start time in seconds
---@param endTime number effect end time in seconds  
---@param stackCount number effect stack count
---@param iconName string effect icon path
---@param buffType number buff type
---@param effectType number effect type
---@param abilityType number ability type  
---@param statusEffectType number status effect type
---@param unitName string unit name
---@param unitId number unit ID
---@param abilityId number ability ID of the effect
---@param sourceType number source type
function BlockPooky.OnCCImmunityChanged(
    eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
    iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end -- Only process player effects
    
    -- Note: Custom immunity potions ("Essenz der Unbeweglichkeit") do not show 
    -- any detectable immunity effect in ESO API, making automatic detection impossible.
    
    -- Known CC immunity effect IDs:
    -- 29721/28301: Dodge roll immunity (short duration)
    -- 92416: "sicherer Stand" - Potion immunity (long duration, ~10.4s)

    --if changeType == EFFECT_RESULT_GAINED then
    --    d("CC: " .. unitTag .. " ability " .. abilityId .. "/" .. BlockPooky.CleanupName(effectName) .. " type " 
    --      .. changeType .. " unit " .. unitId .. "/" .. BlockPooky.CleanupName(unitName) .. " statusEffect " .. statusEffectType
    --      .. "iconName" .. iconName)
    --end

    if abilityId == 29721 or abilityId == 28301 or abilityId == 92416 then -- CC Immunity Buffs: 29721/28301 (dodge roll), 92416 (sicherer Stand/immovability)
        if changeType == EFFECT_RESULT_GAINED then
            -- Determine if immunity is from potion based on duration
            local duration = endTime - beginTime
            local isFromPotion = duration >= 10.0 -- Potions typically give 10+ seconds, skills give less
            
            if BlockPooky.showCCbar(beginTime, endTime) then
                BlockPooky_ccBarFromPotion = isFromPotion
            end
        elseif changeType == EFFECT_RESULT_FADED and BlockPooky_ccBarFromPotion == false then
            BlockPooky.ccBar:SetHidden(not BlockPooky.config.lockedUI)
            EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name.."UpdateCCBar")
        end
    elseif changeType == EFFECT_RESULT_GAINED then
        
        local unstoppableDuration = BlockPooky.unstoppableSkills[abilityId]
        -- d("CC: " .. abilityId .. " : " .. tostring(unstoppableDuration))s
        if unstoppableDuration then
            local beginTime = GetGameTimeSeconds()
            local endTime = beginTime + unstoppableDuration
            if BlockPooky.showCCbar(beginTime, endTime) then
                BlockPooky_ccBarFromPotion = true
            end
        end
    end

    if changeType == EFFECT_RESULT_GAINED and BlockPooky.config.investigateEffects then
        d(string.format("Effect? Name: %s | ID: %d | BT: %s | ET: %s", BlockPooky.CleanupName(effectName), abilityId, beginTime, endTime))
    end
end

-- Event handler for inventory slot updates (WORKING, primary method for potion detection)
function BlockPooky.OnSlotUpdate(
        eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- Only process valid item consumption/use events
    if isNewItem or stackCountChange ~= -1 then
        return
    end
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink then
        local itemId = GetItemLinkItemId(itemLink)
        local unstoppableDuration = BlockPooky.unstoppableItems[itemId]
        if unstoppableDuration then
            local beginTime = GetGameTimeSeconds()
            local endTime = beginTime + unstoppableDuration
            if BlockPooky.showCCbar(beginTime, endTime) then
                BlockPooky_ccBarFromPotion = true
            end
        end
    end
end

-- Event handler for item cooldown (fallback method, currently not working due to ESO API issues)
--[[
-- Event handler for item cooldown (fallback method, currently not working due to ESO API issues)
function BlockPooky.OnItemUsed(eventCode, itemId, cooldownDuration)
    -- Check if this item is an immunity potion
    local duration = BlockPooky.unstoppableItems[itemId]
    if duration then
        local beginTime = GetGameTimeSeconds()
        local endTime = beginTime + duration
        if BlockPooky.showCCbar(beginTime, endTime) then
            BlockPooky_ccBarFromPotion = true
        end
    end
end
]]

---Manual trigger for CC immunity bar testing
---Use via /blockpookytestimmo command to test the CC bar display
---@param duration number|nil duration in seconds (defaults to 10.4 for potion immunity)
--[[
---Manual trigger for CC immunity bar testing
---Use via /blockpookytestimmo command to test the CC bar display
---@param duration number|nil duration in seconds (defaults to 10.4 for potion immunity)
function BlockPooky.TriggerPotionImmunity(duration)
    duration = duration or 10.4
    local beginTime = GetGameTimeSeconds()
    local endTime = beginTime + duration
    if BlockPooky.showCCbar(beginTime, endTime) then
        BlockPooky_ccBarFromPotion = true
    end
end
]]