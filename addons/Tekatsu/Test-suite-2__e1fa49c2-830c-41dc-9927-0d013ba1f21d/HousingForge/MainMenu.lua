HF.MainMenu = {}
HF.MainMenu.added = false

local function IsGamepadMenuAvailable()
    if IsConsoleUI and IsConsoleUI() then return true end
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode()
end

local function CreateMenuEntry(id, data)
    local entry = ZO_GamepadEntryData:New(data.name, data.icon)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    if data.subMenu then
        entry.subMenu = {}
        for index, subData in ipairs(data.subMenu) do
            entry.subMenu[#entry.subMenu + 1] = CreateMenuEntry(index, subData)
        end
    end
    entry.data = data
    entry.id = id
    return entry
end

local function HasMenuEntry()
    if not ZO_MENU_ENTRIES then return false end
    for i = 1, #ZO_MENU_ENTRIES do
        if ZO_MENU_ENTRIES[i].id == "HousingForgeMainEntry" then
            return true
        end
    end
    return false
end

local function InsertMenuEntry()
    if HF.MainMenu.added or HasMenuEntry() then
        HF.MainMenu.added = true
        return
    end
    if not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES or not MAIN_MENU_GAMEPAD then return end

    local subItems = {
        {
            name = "Open Dashboard",
            icon = "EsoUI/Art/TreeIcons/gamepad/gp_collectionicon_housing.dds",
            activatedCallback = function() HF.OpenUI() end,
        },
        {
            name = "Record Owned House",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_browse.dds",
            activatedCallback = function() HF.RecordCurrentHouse() end,
        },
        {
            name = "Copy Visited House",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_retrieve.dds",
            activatedCallback = function() HF.CopyCurrentHouse() end,
        },
        {
            name = "Precision Blueprint Tools",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_browse.dds",
            activatedCallback = function() HF.OpenPrecisionUI() end,
        },
        {
            name = "Toggle Furniture Selection",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_browse.dds",
            activatedCallback = function()
                if HF.BlueprintTools then HF.BlueprintTools.Toggle() end
            end,
        },
        {
            name = "Save Quick Furniture Group",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_browse.dds",
            activatedCallback = function()
                if HF.BlueprintTools then HF.BlueprintTools.SaveGroup("Quick Group") end
            end,
        },
        {
            name = "Load Quick Furniture Group",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_retrieve.dds",
            activatedCallback = function()
                if HF.BlueprintTools then HF.BlueprintTools.LoadGroup("Quick Group", false) end
            end,
        },
        {
            name = "Undo Precision Move",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_retrieve.dds",
            activatedCallback = function()
                if HF.BlueprintTools then HF.BlueprintTools.Undo() end
            end,
        },
        {
            name = "Pause / Resume Housing Queue",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
            activatedCallback = function()
                local queue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
                if queue and queue.paused then HF.LayoutApplier.ResumeQueue() else HF.LayoutApplier.PauseQueue() end
            end,
        },
        {
            name = "Cancel Housing Queue",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
            activatedCallback = function() HF.LayoutApplier.CancelQueue() end,
        },
        {
            name = "Retry Failed Placements",
            icon = "EsoUI/Art/Housing/Gamepad/gp_housing_menuicon_retrieve.dds",
            activatedCallback = function() HF.LayoutApplier.RetryFailed() end,
        },
        {
            name = "Export Selected Layout",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_mail.dds",
            activatedCallback = function() HF.ExportSelectedLayout() end,
        },
        {
            name = "Export Owned Furnishings",
            icon = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_craftbag_furnishing.dds",
            activatedCallback = function() HF.OwnedFurnishingsExport.Export() end,
        },
        {
            name = "Calibration Markers",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_help.dds",
            activatedCallback = function() HF.OpenCalibrationUI() end,
        },
        {
            name = "Speed Settings",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
            activatedCallback = function()
                HF.OpenSettingsUI()
            end,
        },
    }

    local insertPos = 0
    for i = 1, #ZO_MENU_ENTRIES do
        if ZO_MENU_ENTRIES[i].id == ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER then
            insertPos = i
            break
        end
    end
    if insertPos == 0 then insertPos = #ZO_MENU_ENTRIES + 1 end

    local entry = CreateMenuEntry("HousingForgeMainEntry", {
        customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
        name = "|cAAFFAAHousingForge|r",
        icon = "EsoUI/Art/TreeIcons/gamepad/gp_collectionicon_housing.dds",
        subMenu = subItems,
    })
    table.insert(ZO_MENU_ENTRIES, insertPos, entry)
    HF.MainMenu.added = true
    MAIN_MENU_GAMEPAD:RefreshMainList()
end

function HF.MainMenu.Register()
    if not IsGamepadMenuAvailable() then return end
    if not MAIN_MENU_GAMEPAD_SCENE then return end

    local function OnStateChange(oldState, newState)
        if newState == SCENE_SHOWING then
            MAIN_MENU_GAMEPAD_SCENE:UnregisterCallback("StateChange", OnStateChange)
            InsertMenuEntry()
        end
    end

    MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", OnStateChange)
end
