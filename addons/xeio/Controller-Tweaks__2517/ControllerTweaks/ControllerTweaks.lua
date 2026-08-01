local CT = ControllerTweaks

local function Init(event, name)
    if name ~= CT.AddonName then return end

    EVENT_MANAGER:UnregisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED)

    local plugins = {CT.Inventory, CT.Chat, CT.Tooltips, CT.GroupFinder, CT.Provisioning, CT.Loot}
    for i, plugin in ipairs(plugins) do
        plugin:AddSettingsAndOptions(CT.OptionsPanel)
    end

    CT.Settings:LoadSavedSettings()

    for i, plugin in ipairs(plugins) do
        plugin:Init()
    end

    CT.OptionsPanel:RegisterOptions()
end

EVENT_MANAGER:RegisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED, Init)