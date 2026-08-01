-- LootTrackerSolution.lua


-- Creates a namespace for the addon.
LootTrackerSolution = {}

local LTS = LootTrackerSolution


LTS.TamrielTradeCentre = false
LTS.Name = "LootTrackerSolution"


-- Initializes the addon.
function LTS.Initialize()
    -- Инициализация модулей

    LTS.Localization.Initialize()
    LTS.Tracking.Initialize()
    LTS.LootStorageModule.Initialize()

    -- Установка настроек автолута
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, LTS.LootStorageModule:GetGeneralSetting("AutoLootDefault") and "1" or "0")

    -- Показывать окно журнала, если оно не скрыто
    if not LTS.LootStorageModule:GetGeneralSetting("MainWindowIsHidden") then
        LTS.LootJournalWindow.ToggleWindow()
    end
end

-- Event handler for the addon loaded event.
function LTS.OnAddOnLoaded(eventCode, addonName)
    if addonName == "TamrielTradeCentre" then
        LTS.TamrielTradeCentre = true
    end
    if addonName == LTS.Name then
        LTS.Initialize()
        EVENT_MANAGER:UnregisterForEvent(LTS.Name, EVENT_ADD_ON_LOADED)
    end
end



-- Event handler for the hotkey pressed event.
function OnHotkeyPressed()
    -- Обработчик события нажатия горячей клавиши
    CHAT_SYSTEM:AddMessage("--Test--")
    LTS.LootJournalWindow.ToggleWindow()
end




-- Registers the addon initialization function.
EVENT_MANAGER:RegisterForEvent(LTS.Name, EVENT_ADD_ON_LOADED, LTS.OnAddOnLoaded)


-- Creates a string ID for the loot tracker test button binding.
ZO_CreateStringId("SI_BINDING_NAME_LOOT_TRACKER_TEST", "Solution Test Button")

