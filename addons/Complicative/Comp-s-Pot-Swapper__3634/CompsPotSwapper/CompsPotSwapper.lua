CompsPotSwapper = {
    name = "CompsPotSwapper",
    version = "1.1.2",
    author = "@Complicative",
}

CompsPotSwapper.Settings = {}

CompsPotSwapper.Default = {
    buffThreshold = 15,
    primarySlotIndex = 4,
    secondarySlotIndex = 3,
    buffId = 61708,
    enabled = true,
    swapCooldown = 3,
    pollingRate = 100,
    posX = 100,
    posY = 100,
}

CompsPotSwapper.lastSwappedTo = 0
CompsPotSwapper.swappedAt = 0

local LAM2 = LibAddonMenu2
local mainFragment = ZO_SimpleSceneFragment:New(CompsPotSwapperButtonControl)

function CompsPotSwapper.getPotionCooldown()
    local cooldownLeft = GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    return cooldownLeft
end

function CompsPotSwapper.getBuffDuration(buffId)
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo("player", i)
        if abilityId == buffId then
            return timeEnding - GetFrameTimeSeconds()
        end
    end
    return 0
end

function CompsPotSwapper.potSwap()
    local swapCooldown = (CompsPotSwapper.swappedAt + CompsPotSwapper.Settings.swapCooldown) - GetFrameTimeSeconds()
    if swapCooldown > 0 then
        CompsPotSwapperButtonControlButtonLabel:SetText(math.ceil(swapCooldown * 10) / 10)
        return
    end
    CompsPotSwapperButtonControlButtonLabel:SetText("")

    local potCooldown = CompsPotSwapper.getPotionCooldown() / 1000
    local buffDuration = CompsPotSwapper.getBuffDuration(CompsPotSwapper.Settings.buffId)

    --d(potCooldown, buffDuration)
    if potCooldown >= buffDuration then
        if GetCurrentQuickslot() == CompsPotSwapper.Settings.primarySlotIndex then return end
        SetCurrentQuickslot(CompsPotSwapper.Settings.primarySlotIndex)
        CompsPotSwapper.lastSwappedTo = GetCurrentQuickslot()
    elseif potCooldown >= buffDuration - CompsPotSwapper.Settings.buffThreshold then
        if GetCurrentQuickslot() == CompsPotSwapper.Settings.primarySlotIndex then return end
        SetCurrentQuickslot(CompsPotSwapper.Settings.primarySlotIndex)
        CompsPotSwapper.lastSwappedTo = GetCurrentQuickslot()
    else
        if GetCurrentQuickslot() == CompsPotSwapper.Settings.secondarySlotIndex then return end
        SetCurrentQuickslot(CompsPotSwapper.Settings.secondarySlotIndex)
        CompsPotSwapper.lastSwappedTo = GetCurrentQuickslot()
    end
end

function CompsPotSwapper.OnQuickslotChanged(eventCode, index)
    if CompsPotSwapper.lastSwappedTo ~= GetCurrentQuickslot() then
        CompsPotSwapper.swappedAt = GetFrameTimeSeconds()
    end
end

function CompsPotSwapper.toggle(enabled)
    if enabled then
        EVENT_MANAGER:RegisterForUpdate(CompsPotSwapper.name .. "Cooldown Tracker", CompsPotSwapper.Settings.pollingRate,
            CompsPotSwapper.potSwap)
        CompsPotSwapperButtonControlButtonTexture:SetColor(0, 1, 0)
        CompsPotSwapperButtonControlButtonTexture2:SetColor(0, 1, 0)
        EVENT_MANAGER:RegisterForEvent(CompsPotSwapper.name, EVENT_ACTIVE_QUICKSLOT_CHANGED,
            CompsPotSwapper.OnQuickslotChanged)
    else
        EVENT_MANAGER:UnregisterForUpdate(CompsPotSwapper.name .. "Cooldown Tracker")
        CompsPotSwapperButtonControlButtonTexture:SetColor(1, 0, 0)
        CompsPotSwapperButtonControlButtonTexture2:SetColor(1, 0, 0)
    end
end

function CompsPotSwapper.SetPosition(x, y)
    CompsPotSwapperButtonControl:ClearAnchors()
    CompsPotSwapperButtonControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function CompsPotSwapper.SavePosition()
    CompsPotSwapper.Settings.posX = CompsPotSwapperButtonControl:GetLeft()
    CompsPotSwapper.Settings.posY = CompsPotSwapperButtonControl:GetTop()
end

function CompsPotSwapper.SettingsInit()
    local panelData = {
        type = "panel",
        name = "Comp's Pot Swapper",
        author = 'Complicative',
        version = CompsPotSwapper.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("CompsPotSwapperOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Toggle on/off",
        getFunc = function() return CompsPotSwapper.Settings.enabled end,
        setFunc = function(value)
            CompsPotSwapper.Settings.enabled = value
            CompsPotSwapper.toggle(value)
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Buff ID",
        textType = TEXT_TYPE_NUMERIC,
        tooltip = "Buff ID of the buff to track",
        getFunc = function() return CompsPotSwapper.Settings.buffId end,
        setFunc = function(text) CompsPotSwapper.Settings.buffId = tonumber(text) end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "description",
        title = "Quickslot Positions",
        text =
        "                4\n        5                3\n6                                2\n        7                1\n                8",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Primary Quickslot Position",
        tooltip = "The quickslot position you want when the buff is not running/about to run out",
        min = 1,
        max = 8,
        getFunc = function() return CompsPotSwapper.Settings.primarySlotIndex end,
        setFunc = function(value) CompsPotSwapper.Settings.primarySlotIndex = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Secondary Quickslot Position",
        tooltip = "The quickslot position you want when the buff is still running",
        min = 1,
        max = 8,
        getFunc = function() return CompsPotSwapper.Settings.secondarySlotIndex end,
        setFunc = function(value) CompsPotSwapper.Settings.secondarySlotIndex = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Buff Threshold",
        tooltip = "How long has the buff to at least persist for to not switch to primary quickslot position",
        min = 0,
        max = 45,
        getFunc = function() return CompsPotSwapper.Settings.buffThreshold end,
        setFunc = function(value) CompsPotSwapper.Settings.buffThreshold = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Manual Swap Delay",
        tooltip = "How long to wait after a manual quickslot swap",
        min = 1,
        max = 10,
        getFunc = function() return CompsPotSwapper.Settings.swapCooldown end,
        setFunc = function(value) CompsPotSwapper.Settings.swapCooldown = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Polling Rate",
        tooltip = "How often should the addon check timers; Value is in ms (100 = 10 times per second)",
        min = 100,
        max = 1000,
        step = 100,
        getFunc = function() return CompsPotSwapper.Settings.pollingRate end,
        setFunc = function(value)
            CompsPotSwapper.Settings.pollingRate = value
            CompsPotSwapper.toggle(CompsPotSwapper.Settings.enabled)
        end,
    }

    LAM2:RegisterOptionControls("CompsPotSwapperOptions", optionsData)
end

function CompsPotSwapper.OnAddOnLoaded(event, addonName)
    if addonName ~= CompsPotSwapper.name then return end
    EVENT_MANAGER:UnregisterForEvent(CompsPotSwapper.name, EVENT_ADD_ON_LOADED)

    -- SavedSettings
    CompsPotSwapper.Settings = ZO_SavedVars:NewCharacterIdSettings("CompsPotSwapperSettings", 1, nil,
        CompsPotSwapper.Default)

    HUD_SCENE:AddFragment(mainFragment)
    HUD_UI_SCENE:AddFragment(mainFragment)
    SCENE_MANAGER:GetScene("inventory"):AddFragment(mainFragment)

    CompsPotSwapper.toggle(CompsPotSwapper.Settings.enabled)
    CompsPotSwapper.SetPosition(CompsPotSwapper.Settings.posX, CompsPotSwapper.Settings.posY)

    CompsPotSwapper.SettingsInit()
end

SLASH_COMMANDS["/potswapper"] = function()
    CompsPotSwapper.Settings.enabled = not
        CompsPotSwapper.Settings.enabled
    CompsPotSwapper.toggle(CompsPotSwapper.Settings.enabled)
end

ZO_CreateStringId("SI_BINDING_NAME_COMPS_POT_SWAPPER_TOGGLE", "Toggle Comp's Pot Swapper On/Off")

EVENT_MANAGER:RegisterForEvent(CompsPotSwapper.name, EVENT_ADD_ON_LOADED, CompsPotSwapper.OnAddOnLoaded)
