CompsQuickslotSwapper = {
    name = "CompsQuickslotSwapper",
    version = "1.0.0",
    author = "@Complicative",
}

CompsQuickslotSwapper.Settings = {}

CompsQuickslotSwapper.Default = {
    primarySlotIndex = 4,
    secondarySlotIndex = 3,
}

CompsQuickslotSwapper.lastSwappedTo = 0
CompsQuickslotSwapper.swappedAt = 0

local LAM2 = LibAddonMenu2

function CompsQuickslotSwapper.quickslotSwap()
    if GetCurrentQuickslot() == CompsQuickslotSwapper.Settings.primarySlotIndex then
        SetCurrentQuickslot(CompsQuickslotSwapper.Settings.secondarySlotIndex)
    elseif GetCurrentQuickslot() == CompsQuickslotSwapper.Settings.secondarySlotIndex then
        SetCurrentQuickslot(CompsQuickslotSwapper.Settings.primarySlotIndex)
    else
        SetCurrentQuickslot(CompsQuickslotSwapper.Settings.primarySlotIndex)
    end
end

function CompsQuickslotSwapper.SettingsInit()
    local panelData = {
        type = "panel",
        name = "Comp's Quickslot Swapper",
        author = 'Complicative',
        version = CompsQuickslotSwapper.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("CompsQuickslotSwapperOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        title = "Quickslot Positions",
        text =
        "                4\n        5                3\n6                                2\n        7                1\n                8",
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Primary Quickslot Position",
        tooltip = "The quickslot position you want to swap to, when any other quickslot position is selected",
        min = 1,
        max = 8,
        getFunc = function() return CompsQuickslotSwapper.Settings.primarySlotIndex end,
        setFunc = function(value) CompsQuickslotSwapper.Settings.primarySlotIndex = value end,
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Secondary Quickslot Position",
        tooltip = "The quickslot position you want to swap to, when primary quickslot position is selected",
        min = 1,
        max = 8,
        getFunc = function() return CompsQuickslotSwapper.Settings.secondarySlotIndex end,
        setFunc = function(value) CompsQuickslotSwapper.Settings.secondarySlotIndex = value end,
    }

    LAM2:RegisterOptionControls("CompsQuickslotSwapperOptions", optionsData)
end

function CompsQuickslotSwapper.OnAddOnLoaded(event, addonName)
    if addonName ~= CompsQuickslotSwapper.name then return end
    EVENT_MANAGER:UnregisterForEvent(CompsQuickslotSwapper.name, EVENT_ADD_ON_LOADED)

    -- SavedSettings
    CompsQuickslotSwapper.Settings = ZO_SavedVars:NewCharacterIdSettings("CompsQuickslotSwapperSettings", 1, nil,
        CompsQuickslotSwapper.Default)

    CompsQuickslotSwapper.SettingsInit()
end

SLASH_COMMANDS["/quickslotswapper"] = function()
    d("Hello, World!")
end

ZO_CreateStringId("SI_BINDING_NAME_COMPS_QUICKSLOT_SWAPPER_TOGGLE",
    "Quickslot Swap")

EVENT_MANAGER:RegisterForEvent(CompsQuickslotSwapper.name, EVENT_ADD_ON_LOADED, CompsQuickslotSwapper.OnAddOnLoaded)
