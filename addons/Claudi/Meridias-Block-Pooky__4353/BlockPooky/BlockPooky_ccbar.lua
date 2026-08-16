--[[
    BlockPooky CC Immunity Bar Module - Updated for ESO API Issues

    This module tracks and displays crowd control immunity duration through a visual bar.
    CC immunity can be gained from:
    - Dodge rolling (natural immunity via effects 29721/28301)
    - Consuming immunity potions (detected via effect 92416 "sicherer Stand" and
      EVENT_INVENTORY_SINGLE_SLOT_UPDATE / OnSlotUpdate)
    - Using specific skills that grant unstoppable/immunity

    The bar distinguishes TWO kinds of CC immunity (separate colors on the single bar,
    blended while both are active):
    - "hard" - immunity to hard CC (stun, knockdown, fear, disorient, ...) from immunity
      potions, the heavy-armor "Immovable" buff (92416) and Berserker Rage
    - "soft" - immunity to soft CC (snares, immobilizes/roots) from Race Against Time,
      Bird of Prey, Elusive Mist, Swift of the Falcon, Phantasmal Escape, Protective Plate
    - "both" - dodge roll grants a short window of full immunity (hard + soft)

    IMPORTANT: Direct potion detection via EVENT_ITEM_ON_COOLDOWN is currently broken in ESO API
    for custom crafted potions. The WORKING potion path is EVENT_INVENTORY_SINGLE_SLOT_UPDATE
    (OnSlotUpdate), which reliably detects when an immunity potion is consumed from the backpack.

    Detection Methods (in order of reliability):
    1. Effect monitoring - Detects immunity buffs when applied (dodge roll / long buffs) (WORKING)
    2. Inventory slot updates - Detects potion consumption via OnSlotUpdate (WORKING, primary for potions)
    3. Item cooldown events - Fallback, preserved for future ESO API fixes (BROKEN)
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

-- Potion/poison items that grant HARD CC immunity (stuns/knockdowns/disables only -
-- they do NOT block or clear snares). duration in seconds.
BlockPooky.ccImmunityItems = {
    [27039]  = { kind = "hard", duration = 10.4 }, -- Potion of Immovability / custom immunity potions
    [71071]  = { kind = "hard", duration = 10.4 }, -- Alliance Health Draught
    [112430] = { kind = "hard", duration = 10.4 }, -- Gold Coast Survivor Elixir
    [76844]  = { kind = "hard", duration = 10.4 }, -- Escapist's Poison
}

-- Skills that grant CC immunity, classified by kind:
--   "hard" = blocks hard CC (stun/knockdown/fear/disorient)
--   "soft" = blocks soft CC (snares/immobilizes/roots)
-- duration in seconds.
BlockPooky.ccImmunitySkills = {
    [177288] = { kind = "soft", duration = 4.0 }, -- Swift of the Falcon (Warden)
    [177289] = { kind = "soft", duration = 4.0 }, -- Elusive Mist (Vampire)
    [177290] = { kind = "soft", duration = 4.0 }, -- Bird of Prey (Warden)
    [177244] = { kind = "soft", duration = 4.0 }, -- Phantasmal Escape (Nightblade)
    [122260] = { kind = "soft", duration = 4.0 }, -- Race Against Time (Psijic) - does NOT block hard CC
    [108798] = { kind = "soft", duration = 4.0 }, -- Protective Plate (Dragonknight)
    [83239]  = { kind = "hard", duration = 8.0 }, -- Berserker Rage (stun immunity)
}

-- Effects that grant CC immunity, matched by ability ID from EVENT_EFFECT_CHANGED:
--   "both" = full immunity (hard + soft)
BlockPooky.ccImmunityEffects = {
    [29721] = "both", -- Dodge roll (short full-immunity window, breaks roots)
    [28301] = "both", -- Dodge roll
    [92416] = "hard", -- "sicherer Stand" - Heavy Armor Immovable buff
}

--[[ ccbar implementation -------------------------------------------------------------------------------------------]]

---Hard CC immunity color (stun/knockdown/fear/disorient immunity)
function BlockPooky.SetCCBarColor()
    if BlockPooky.config.ccBarColor then
        BlockPooky.ccStatusBar:SetColor(unpack(BlockPooky.config.ccBarColor))
    else
        BlockPooky.ccStatusBar:SetColor(0, 1, 0, 1) -- Grün für Hard-CC-Immunität
    end
end

---Soft CC immunity color (snare/immobilize immunity)
function BlockPooky.SetCCBarSoftColor()
    if BlockPooky.config.ccBarSoftColor then
        BlockPooky.ccStatusBar:SetColor(unpack(BlockPooky.config.ccBarSoftColor))
    else
        BlockPooky.ccStatusBar:SetColor(0, 0.75, 1, 1) -- Blau für Soft-CC-Immunität
    end
end

---init cc immunity bar
function BlockPooky.initCCBarUI()
    -- Prüfen, ob die ccBar bereits existiert
    if not BlockPooky.ccBar then
        BlockPooky.ccBar = CreateControl(BlockPooky.name .. "CCBar", GuiRoot, CT_TOPLEVELCONTROL)
        BlockPooky.ccBar:SetDimensions(200, 40)
        BlockPooky.ccBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
        BlockPooky.ccBar:SetHidden(true)
        BlockPooky.ccBar:SetMovable(true)      -- Verschiebbar machen
        BlockPooky.ccBar:SetMouseEnabled(true) -- Mausinteraktionen erlauben

        -- Event für das Loslassen nach dem Bewegen
        BlockPooky.ccBar:SetHandler("OnMoveStop", function()
            BlockPooky.SaveCCBarPosition()
        end)
    end

    -- Prüfen, ob das Label bereits existiert
    if not BlockPooky.ccLabel then
        BlockPooky.ccLabel = CreateControl(BlockPooky.name .. "CCLabel", BlockPooky.ccBar, CT_LABEL)
        BlockPooky.ccLabel:SetFont("ZoFontWinH4")
        BlockPooky.ccLabel:SetColor(1, 1, 1, 1) -- Weiß
        BlockPooky.ccLabel:SetText("")
        BlockPooky.ccLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.ccLabel:SetAnchor(TOP, BlockPooky.ccBar, TOP, 0, 0)
    end

    -- Prüfen, ob die Statusbar bereits existiert
    if not BlockPooky.ccStatusBar then
        BlockPooky.ccStatusBar = CreateControl(BlockPooky.name .. "CCStatus", BlockPooky.ccBar, CT_STATUSBAR)
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
    BlockPooky.config.ccBarPosition = { left = left, top = top }
end

function BlockPooky.LoadCCBarPosition()
    if BlockPooky.ccBar then
        if BlockPooky.config and BlockPooky.config.ccBarPosition then
            if BlockPooky.ccBar:GetAnchor() ~= nil then
                BlockPooky.ccBar:ClearAnchors()
            end
            BlockPooky.ccBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.ccBarPosition.left,
                BlockPooky.config.ccBarPosition.top)
        else
            BlockPooky.ResetCCBarPosition()
        end
    end
end

local BlockPooky_ccBarHardEndTime = 0
local BlockPooky_ccBarHardBeginTime = 0
local BlockPooky_ccBarSoftEndTime = 0
local BlockPooky_ccBarSoftBeginTime = 0
local BlockPooky_ccBarUpdateRegistered = false

---Register a CC immunity source on the bar.
---@param kind string "hard", "soft" or "both"
---@param beginTime number effect begin time (seconds)
---@param endTime number effect end time (seconds)
---@return boolean true if the bar state was extended/changed
function BlockPooky.showCCbar(kind, beginTime, endTime)
    if not endTime or endTime <= GetGameTimeSeconds() then return false end
    local extended = false
    if kind == "hard" or kind == "both" then
        if endTime > BlockPooky_ccBarHardEndTime then
            BlockPooky_ccBarHardEndTime = endTime
            BlockPooky_ccBarHardBeginTime = beginTime or GetGameTimeSeconds()
            extended = true
        end
    end
    if kind == "soft" or kind == "both" then
        if endTime > BlockPooky_ccBarSoftEndTime then
            BlockPooky_ccBarSoftEndTime = endTime
            BlockPooky_ccBarSoftBeginTime = beginTime or GetGameTimeSeconds()
            extended = true
        end
    end
    if extended then
        BlockPooky.StartCCBarUpdate()
    end
    return extended
end

---Ensure the 50ms bar update loop is running and refresh immediately
function BlockPooky.StartCCBarUpdate()
    if not BlockPooky_ccBarUpdateRegistered then
        BlockPooky_ccBarUpdateRegistered = true
        EVENT_MANAGER:RegisterForUpdate(BlockPooky.name .. "UpdateCCBar", 50, BlockPooky.UpdateCCBar, false)
    end
    BlockPooky.UpdateCCBar()
end

---Per-frame bar update: drains the hard & soft timers independently, picks the bar color
---based on which kind(s) are still active, and hides the bar when nothing is left.
function BlockPooky.UpdateCCBar()
    local now = GetGameTimeSeconds()
    local hardRemaining = BlockPooky_ccBarHardEndTime - now
    local softRemaining = BlockPooky_ccBarSoftEndTime - now

    if hardRemaining <= 0 then
        BlockPooky_ccBarHardEndTime = 0
        hardRemaining = 0
    end
    if softRemaining <= 0 then
        BlockPooky_ccBarSoftEndTime = 0
        softRemaining = 0
    end

    if hardRemaining <= 0 and softRemaining <= 0 then
        BlockPooky.ccBar:SetHidden(not BlockPooky.config.lockedUI)
        if BlockPooky_ccBarUpdateRegistered then
            BlockPooky_ccBarUpdateRegistered = false
            EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name .. "UpdateCCBar")
        end
        return
    end

    -- The "driver" is the kind with the longest remaining time. The bar drains from
    -- its full duration (end - begin) down to 0, like the original bar did.
    local fill, barMax
    if hardRemaining > 0 and hardRemaining >= softRemaining then
        fill = hardRemaining
        barMax = math.max(BlockPooky_ccBarHardEndTime - BlockPooky_ccBarHardBeginTime, 0.001)
    else
        fill = softRemaining
        barMax = math.max(BlockPooky_ccBarSoftEndTime - BlockPooky_ccBarSoftBeginTime, 0.001)
    end
    fill = math.min(fill, barMax)

    BlockPooky.ccStatusBar:SetMinMax(0, barMax)
    BlockPooky.ccStatusBar:SetValue(fill)
    BlockPooky.ccLabel:SetText(BlockPooky.config.messages.ccImmunity) -- Text über dem Balken
    BlockPooky.ccBar:SetHidden(false)

    -- Color by active kind(s): hard only -> hard color, soft only -> soft color,
    -- both active -> blended color
    if hardRemaining > 0 and softRemaining > 0 then
        local hc = BlockPooky.config.ccBarColor or { 0, 1, 0, 1 }
        local sc = BlockPooky.config.ccBarSoftColor or { 0, 0.75, 1, 1 }
        BlockPooky.ccStatusBar:SetColor(
            (hc[1] + sc[1]) / 2,
            (hc[2] + sc[2]) / 2,
            (hc[3] + sc[3]) / 2,
            (hc[4] + sc[4]) / 2)
    elseif hardRemaining > 0 then
        BlockPooky.SetCCBarColor()
    else
        BlockPooky.SetCCBarSoftColor()
    end
end

---Registers or unregisters CC immunity detection events based on configuration
---Primary detection: EVENT_EFFECT_CHANGED (immunity buffs) +
---                   EVENT_INVENTORY_SINGLE_SLOT_UPDATE (potion consumption via OnSlotUpdate)
---EVENT_ITEM_ON_COOLDOWN fallback preserved for future ESO API fixes
function BlockPooky.CCEventRegisterUpdate()
    if BlockPooky.config.CCImmunityHint then
        -- Primary detection method: Monitor effect changes (WORKING)
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED,
            function(...) BlockPooky.OnCCImmunityChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "CCWatcher", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG,
            "player")

        -- Fallback: Item cooldown events (currently broken for custom potions in ESO API)
        -- EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "ItemCooldown", EVENT_ITEM_ON_COOLDOWN, function(...) BlockPooky.OnItemUsed(...) end)

        -- Fallback: Inventory slot updates (currently broken for custom potions in ESO API)
        -- Register for backpack item consumption (potions)
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            function(...) BlockPooky.OnSlotUpdate(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "InventoryUpdateBackpack", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_IS_NEW_ITEM, false)
        -- Register for worn item changes (poisons on weapon slot)
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            function(...) BlockPooky.OnSlotUpdate(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_FILTER_BAG_ID, BAG_WORN)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "InventoryUpdateWorn", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_IS_NEW_ITEM, false)
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

    -- Note: Custom immunity potions ("Essenz der Unbeweglichkeit") do not reliably expose a
    -- detectable immunity effect via EVENT_EFFECT_CHANGED; potion consumption is caught by
    -- the EVENT_INVENTORY_SINGLE_SLOT_UPDATE path (OnSlotUpdate) instead.

    -- Known CC immunity effect IDs:
    -- 29721/28301: Dodge roll immunity (short duration)
    -- 92416: "sicherer Stand" - Potion immunity (long duration, ~10.4s)

    --if changeType == EFFECT_RESULT_GAINED then
    --    d("CC: " .. unitTag .. " ability " .. abilityId .. "/" .. BlockPooky.CleanupName(effectName) .. " type "
    --      .. changeType .. " unit " .. unitId .. "/" .. BlockPooky.CleanupName(unitName) .. " statusEffect " .. statusEffectType
    --      .. "iconName" .. iconName)
    --end

    if changeType == EFFECT_RESULT_GAINED then
        -- NOTE: Do NOT react to EFFECT_RESULT_FADED here. The update loop inside
        -- UpdateCCBar() owns hide/show based on the real effect end times. Reacting
        -- to FADED (as the old code did) could hide the bar early during chain
        -- dodge-rolls even though a newer immunity was still active.

        -- Known immunity effects (dodge roll = "both", heavy-armor buff = "hard")
        local effectKind = BlockPooky.ccImmunityEffects[abilityId]
        if effectKind then
            BlockPooky.showCCbar(effectKind, beginTime, endTime)
        else
            -- Skills that grant CC immunity with configured duration
            local skill = BlockPooky.ccImmunitySkills[abilityId]
            if skill then
                local beginTime = GetGameTimeSeconds()
                local endTime = beginTime + skill.duration
                BlockPooky.showCCbar(skill.kind, beginTime, endTime)
            end
        end
    end

    if changeType == EFFECT_RESULT_GAINED and BlockPooky.config.investigateEffects then
        d(string.format("Effect? Name: %s | ID: %d | BT: %s | ET: %s", BlockPooky.CleanupName(effectName), abilityId,
            beginTime, endTime))
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
        local item = BlockPooky.ccImmunityItems[itemId]
        if item then
            local beginTime = GetGameTimeSeconds()
            local endTime = beginTime + item.duration
            BlockPooky.showCCbar(item.kind, beginTime, endTime)
        end
    end
end

-- Event handler for item cooldown (fallback method, currently not working due to ESO API issues)
--[[
function BlockPooky.OnItemUsed(eventCode, itemId, cooldownDuration)
    -- Check if this item is an immunity potion
    local item = BlockPooky.ccImmunityItems[itemId]
    if item then
        local beginTime = GetGameTimeSeconds()
        local endTime = beginTime + item.duration
        BlockPooky.showCCbar(item.kind, beginTime, endTime)
    end
end
]]

---Manual trigger for CC immunity bar testing (HARD immunity)
---Use via /blockpookytestimmo command to test the CC bar display
---@param duration number|nil duration in seconds (defaults to 10.4 for potion immunity)
function BlockPooky.TriggerPotionImmunity(duration)
    duration = duration or 10.4
    local beginTime = GetGameTimeSeconds()
    local endTime = beginTime + duration
    BlockPooky.showCCbar("hard", beginTime, endTime)
end
