local addon = {
    name = 'BattlegroundModeSaver',
    version = '1.4.1',
    author = 'BadCompany309/imPDA',
    defaults = {
        lastSelectedMode = nil 
    }
}

local function GetModeItem(modeName)
    for i, item in ipairs(BATTLEGROUND_FINDER_KEYBOARD.filterComboBox.m_sortedItems) do
        if item.name == modeName then return item end
    end
end

--local MESSAGE_COOLDOWN = 1 -- 1 second cooldown
--local messageBuffer = {}
--local function _(message)
    --local now = GetTimeStamp()
    --local last = messageBuffer[message] or 0

    --if now - last > MESSAGE_COOLDOWN then
        --messageBuffer[message] = now
        --d(message)
    --end
--end

local function HookModeSelection()
    ZO_PostHook(BATTLEGROUND_FINDER_KEYBOARD.filterComboBox, 'SelectItem', function(_, item)
        if not item then return end  -- must be impossible scenario? still better to check
        if not BATTLEGROUND_FINDER_KEYBOARD.filterComboBox:IsDropdownVisible() then return end
        -- if item.name == addon.savedVariables.lastSelectedMode then return end

        --d('Selected mode: ' .. item.name)
        addon.savedVariables.lastSelectedMode = item.name
    end)
end

local function DecorateModeFilterInitialization()
    ZO_PostHook(BATTLEGROUND_FINDER_KEYBOARD, 'RefreshFilters', function()
        local rememberedModeItem = addon.savedVariables.lastSelectedMode and GetModeItem(addon.savedVariables.lastSelectedMode)

        if rememberedModeItem and rememberedModeItem.name ~= BATTLEGROUND_FINDER_KEYBOARD.filterComboBox:GetSelectedItemData().name and BATTLEGROUND_FINDER_KEYBOARD.fragment:IsShowing() then
            d('Restoring mode: ' .. rememberedModeItem.name)
            BATTLEGROUND_FINDER_KEYBOARD.filterComboBox:SelectItem(rememberedModeItem)
        end
    end)
end



function addon:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide('BattlegroundModeSaverSavedVariables', 1, nil, self.defaults)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        DecorateModeFilterInitialization()
        HookModeSelection()
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
    end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    addon:Initialize()

    local text = string.format('[BGS] %s v%s loaded', addon.name, addon.version)
    zo_callLater(function() d(text) end, 500)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)