--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

BlockPooky.lastDcCast = 0
BlockPooky.lastRoaCast = 0
BlockPooky.lastVigorCast = 0

-- Registration state for the self-contained hint trackers. Each hint (DC / ROA / Vigor)
-- owns its OWN EVENT_COMBAT_EVENT handler + 1s update tick, registered only while its
-- menu toggle is ON and fully unregistered when toggled OFF. They do NOT share handler
-- code with each other or with the core combat handler (see Event Registration Pattern
-- in BlockPooky/AGENTS.md).
local BlockPooky_dcHintRegistered = false
local BlockPooky_roaHintRegistered = false
local BlockPooky_vigorHintRegistered = false

--[[ hints implementation -------------------------------------------------------------------------------------------]]

function BlockPooky.DcReadyHint(gameTimeMs)
    if BlockPooky.config.dcHint then
        if BlockPooky.lastDcCast ~= 0 and gameTimeMs - BlockPooky.lastDcCast > 25000 then
            BlockPooky.lastDcCast = 0
            BlockPooky.MessageThePooky(BlockPooky.config.messages.dcReady)
        end
    end
end

function BlockPooky.RoaReadyHint(gameTimeMs)
    if BlockPooky.config.roaHint then
        if BlockPooky.lastRoaCast ~= 0 and gameTimeMs - BlockPooky.lastRoaCast > 8000 then
            BlockPooky.lastRoaCast = 0
            BlockPooky.MessageThePooky(BlockPooky.config.messages.roaReady)
        end
    end
end

local vigorHint_active = false
function BlockPooky.UpdateCastVigorHint(gameTimeMs)
    if BlockPooky.config.vigorHint then
        if BlockPooky.lastVigorCast ~= 0 then
            local lastCastTimeMs = gameTimeMs - BlockPooky.lastVigorCast
            if vigorHint_active then
                if lastCastTimeMs > 20000 then
                    vigorHint_active = false
                    VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
                    BlockPooky.lastVigorCast = 0
                elseif lastCastTimeMs > 12000 then
                    vigorHint_active = false
                    VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
                end
            else
                if lastCastTimeMs >= 16000 then
                    vigorHint_active = true
                    VigorIndicator:SetHidden(false)
                elseif lastCastTimeMs >= 8000 then
                    vigorHint_active = true
                    VigorIndicator:SetHidden(false)
                end
            end
        elseif vigorHint_active then
            vigorHint_active = false
            VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
        end
    elseif vigorHint_active then
        vigorHint_active = false
        VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
    end
end

--[[ hint event registration ----------------------------------------------------------------------------------------]]

---EVENT_COMBAT_EVENT handler for the Dark Convergence ready hint (own registration).
---Records the player's own DC cast so DcReadyHint() can fire when it is ready again.
---Only registered while dcHint is enabled.
function BlockPooky.OnDcHintCombat(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combatLog, sourceUnitId, targetUnitId, abilityId)
    if BlockPooky.CleanupName(abilityName) ~= BlockPooky.dcAbilityName then return end
    local cleanSourceName = BlockPooky.CleanupName(sourceName):lower()
    if cleanSourceName ~= BlockPooky.player then return end
    BlockPooky.lastDcCast = GetGameTimeMilliseconds()
end

---EVENT_COMBAT_EVENT handler for the Rush of Agony ready hint (own registration).
---Records the player's own ROA cast so RoaReadyHint() can fire when it is ready again.
---Only registered while roaHint is enabled.
function BlockPooky.OnRoaHintCombat(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combatLog, sourceUnitId, targetUnitId, abilityId)
    if BlockPooky.CleanupName(abilityName) ~= BlockPooky.roaAbilityName then return end
    local cleanSourceName = BlockPooky.CleanupName(sourceName):lower()
    if cleanSourceName ~= BlockPooky.player then return end
    BlockPooky.lastRoaCast = GetGameTimeMilliseconds()
end

---EVENT_COMBAT_EVENT handler for the Vigor recast hint (own registration).
---Records the player's own Echoing Vigor cast (ability 61506) so UpdateCastVigorHint()
---can time the 8s / 16s recast reminders. Only registered while vigorHint is enabled.
function BlockPooky.OnVigorHintCombat(
    eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
    combatLog, sourceUnitId, targetUnitId, abilityId)
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if abilityId ~= 61506 then return end -- echoing vigor
    local cleanSourceName = BlockPooky.CleanupName(sourceName):lower()
    if cleanSourceName ~= BlockPooky.player then return end
    if GetGameTimeMilliseconds() - BlockPooky.lastVigorCast > 1000 then
        BlockPooky.lastVigorCast = GetGameTimeMilliseconds()
        VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
    end
end

---(Re)sync each hint's event registration with its menu toggle.
---DC, ROA and Vigor each get their own EVENT_COMBAT_EVENT handler (same C-level filter as
---the core combat handler) + their own 1s update tick, so toggling one hint never touches
---another hint's registration. Call after changing dcHint / roaHint / vigorHint.
function BlockPooky.HintsEventRegisterUpdate()
    -- Dark Convergence ready hint
    if BlockPooky.config.dcHint then
        if not BlockPooky_dcHintRegistered then
            EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "DCHint", EVENT_COMBAT_EVENT,
                function(...) BlockPooky.OnDcHintCombat(...) end)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "DCHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "DCHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_IS_ERROR, false)
            EVENT_MANAGER:RegisterForUpdate(BlockPooky.name .. "DCHintTick", 1000, BlockPooky.DcReadyHint, false)
            BlockPooky_dcHintRegistered = true
        end
    elseif BlockPooky_dcHintRegistered then
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "DCHint")
        EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name .. "DCHintTick")
        BlockPooky_dcHintRegistered = false
        BlockPooky.lastDcCast = 0
    end

    -- Rush of Agony ready hint
    if BlockPooky.config.roaHint then
        if not BlockPooky_roaHintRegistered then
            EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "ROAHint", EVENT_COMBAT_EVENT,
                function(...) BlockPooky.OnRoaHintCombat(...) end)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "ROAHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "ROAHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_IS_ERROR, false)
            EVENT_MANAGER:RegisterForUpdate(BlockPooky.name .. "ROAHintTick", 1000, BlockPooky.RoaReadyHint, false)
            BlockPooky_roaHintRegistered = true
        end
    elseif BlockPooky_roaHintRegistered then
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "ROAHint")
        EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name .. "ROAHintTick")
        BlockPooky_roaHintRegistered = false
        BlockPooky.lastRoaCast = 0
    end

    -- Vigor recast hint
    if BlockPooky.config.vigorHint then
        if not BlockPooky_vigorHintRegistered then
            EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "VigorHint", EVENT_COMBAT_EVENT,
                function(...) BlockPooky.OnVigorHintCombat(...) end)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "VigorHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "VigorHint", EVENT_COMBAT_EVENT,
                REGISTER_FILTER_IS_ERROR, false)
            EVENT_MANAGER:RegisterForUpdate(BlockPooky.name .. "VigorHintTick", 1000, BlockPooky.UpdateCastVigorHint,
                false)
            BlockPooky_vigorHintRegistered = true
        end
    elseif BlockPooky_vigorHintRegistered then
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "VigorHint")
        EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name .. "VigorHintTick")
        BlockPooky_vigorHintRegistered = false
        BlockPooky.lastVigorCast = 0
    end
end

function BlockPooky.OnVigorIndicatorMoveStop()
    BlockPooky.config.vigorUI.left = VigorIndicator:GetLeft()
    BlockPooky.config.vigorUI.top = VigorIndicator:GetTop()
end

function BlockPooky.ResetHintsPosition()
    if VigorIndicator:GetAnchor() ~= nil then
        VigorIndicator:ClearAnchors()
    end
    VigorIndicator:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, 0)
    BlockPooky.OnVigorIndicatorMoveStop()
end

function BlockPooky.RestoreHintsPosition()
    -- vigorHint
    local left = BlockPooky.config.vigorUI.left
    local top = BlockPooky.config.vigorUI.top
    if (left ~= nil and top ~= nil and left > 0 and top > 0) then
        if VigorIndicator:GetAnchor() ~= nil then
            VigorIndicator:ClearAnchors()
        end
        VigorIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        BlockPooky.ResetHintsPosition()
    end
end

function BlockPooky.SetVigorHintColor()
    if BlockPooky.config.vigorUI.color ~= nil then
        VigorIndicatorLabel:SetColor(unpack(BlockPooky.config.vigorUI.color))
    end
end
