--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

BlockPooky.negateWarningLabel = nil
local BlockPooky_negateWarningActive = false

-- Fähigkeit-IDs für "Negate Magic" und Morphs
BlockPooky.NEGATE_IDS = {
    27706, -- Negate Magic
    28341, -- Suppression Field (Morph)
    28348, -- Absorption Field (Morph)
}
BlockPooky.NEGATE_NAMES = nil


--[[ negate warning implementation ----------------------------------------------------------------------------------]]

function BlockPooky.SetNegateWarningColor()
    if BlockPooky.config.negate then
        BlockPooky.negateWarningLabel:SetColor(unpack(BlockPooky.config.negate.color))
    else
        BlockPooky.negateWarningLabel:SetColor(1, 0, 0, 1)
    end
end

function BlockPooky.SaveNegateWarningPosition()
    local left, top = BlockPooky.negateWarning:GetLeft(), BlockPooky.negateWarning:GetTop()
    BlockPooky.config.negate.left = left
    BlockPooky.config.negate.top = top
end

function BlockPooky.LoadNegateWarningPosition()
    if BlockPooky.negateWarning then
        if BlockPooky.config and BlockPooky.config.negate then
            if BlockPooky.negateWarning:GetAnchor() ~= nil then
                BlockPooky.negateWarning:ClearAnchors()
            end
            BlockPooky.negateWarning:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.negate.left, BlockPooky.config.negate.top)
        else
            BlockPooky.ResetNegateWarningPosition()
        end
    end
end

function BlockPooky.CreateNegateWarningLabel() 
    if BlockPooky.negateWarning == nil then
        --d("CREATE negateWarningLabel")
        BlockPooky.negateWarning = CreateControl(BlockPooky.name.."NegateWarning", GuiRoot, CT_TOPLEVELCONTROL)
        local control = BlockPooky.negateWarning
        control:SetDimensions(350, 30)
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
        control:SetMovable(true) -- Verschiebbar machen
        control:SetMouseEnabled(true) -- Mausinteraktionen erlauben
        control:SetHidden(true)
        BlockPooky.negateWarningLabel = CreateControl(BlockPooky.name.."NegateWarningLabel", control, CT_LABEL)
        local label = BlockPooky.negateWarningLabel
        label:SetFont("BlockPookyBigFont")
        label:SetText(BlockPooky.config.messages.negateWarning)
        BlockPooky.negateWarningLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.negateWarningLabel:SetAnchor(TOP, BlockPooky.negateWarning, TOP, 0, 0)
        BlockPooky_negateWarningActive = false
        BlockPooky.SetNegateWarningColor()
        BlockPooky.negateWarning:SetHandler("OnMoveStop", function()
            BlockPooky.SaveNegateWarningPosition()
        end)
        BlockPooky.LoadNegateWarningPosition()
    end
end

function BlockPooky.ShowNegateWarning()
    if not BlockPooky_negateWarningActive then
        BlockPooky.negateWarning:SetHidden(false)
        BlockPooky_negateWarningActive = true
    end
    zo_callLater(function() BlockPooky.HideNegateWarning() end, 12000)
end

function BlockPooky.HideNegateWarning()
    if BlockPooky_negateWarningActive and BlockPooky.negateWarning then
        -- Keep the warning visible while the UI is in repositioning mode (lockedUI = true)
        if BlockPooky.config and BlockPooky.config.lockedUI then
            return
        end
        BlockPooky.negateWarning:SetHidden(true)
        BlockPooky_negateWarningActive = false
    end
end

function BlockPooky.RegisterNegateWarning()
    --d("REGISTER negateWarningLabel")
    if BlockPooky.config.negate.show then
        EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. "NegateWarning", EVENT_EFFECT_CHANGED, function(...) BlockPooky.OnNegateChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. "NegateWarning", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end
end

function BlockPooky.UnRegisterNegateWarning()
    if not BlockPooky.config.negate.show then
        EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. "NegateWarning")
    end
end

function BlockPooky.ResetNegateWarningPosition()
    if BlockPooky.negateWarning:GetAnchor() ~= nil then
        BlockPooky.negateWarning:ClearAnchors()
    end
    BlockPooky.negateWarning:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    BlockPooky.SaveNegateWarningPosition()
end

function BlockPooky.RestoreNegateWarningPosition()
    BlockPooky.LoadNegateWarningPosition()
end

function BlockPooky.InitNegateWarning()
    if not BlockPooky.NEGATE_NAMES then
        BlockPooky.NEGATE_NAMES = {}
        for idx = #BlockPooky.NEGATE_IDS, 1, -1 do
            --d("negate warning add: " .. BlockPooky.CleanAbilityName(BlockPooky.NEGATE_IDS[idx]))
            BlockPooky.NEGATE_NAMES[BlockPooky.CleanAbilityName(BlockPooky.NEGATE_IDS[idx])] = true
        end
    end
    BlockPooky.CreateNegateWarningLabel()
    BlockPooky.RegisterNegateWarning()
end


--[[ event handling -------------------------------------------------------------------------------------------------]]

function BlockPooky.OnNegateChanged(
        eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, 
        iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    local function isNegate(element)
        return BlockPooky.NEGATE_NAMES[element] == true
    end
    --d("UT: " .. unitTag .." changeType: " .. changeType .. "=" .. EFFECT_RESULT_GAINED .. " sourceType: " .. sourceType .. "=" .. BUFF_EFFECT_TYPE_DEBUFF)
    --d(" isNegate: " .. tostring(isNegate(BlockPooky.CleanupName(effectName))) .. " EN: " .. BlockPooky.CleanupName(effectName))
    --d(" active? " .. tostring(BlockPooky_negateWarningActive))
    if unitTag == "player" then
        if changeType == EFFECT_RESULT_GAINED -- and sourceType == 5
                and not BlockPooky_negateWarningActive and isNegate(BlockPooky.CleanupName(effectName)) then
            BlockPooky.ShowNegateWarning()
        elseif changeType == EFFECT_RESULT_FADED  and BlockPooky_negateWarningActive
                and isNegate(BlockPooky.CleanupName(effectName)) then
            BlockPooky.HideNegateWarning()
        end
    end
end
