-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- MainMenu library (SpringPeace Framework)
-----------------------------------------------------------

SPFLibMainMenu = SPFLibMainMenu or {}

function SPFLibMainMenu.CreateMainMenuEntry(data)
    local name = data.name
    if type(name) == "function" then
        name = "" --will be updated whenever the list is generated
    end

    local entry = ZO_GamepadEntryData:New(name, data.icon, nil, nil, data.isNewCallback)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)

    local header = data.header
    if header then
        entry:SetHeader(header)
    end

    entry.id = data.id
    entry.canLevel = data.canLevel
    entry.narrationText = data.narrationText
    entry.subLabelsNarrationText = data.subLabelsNarrationText

    entry.data = data
    return entry
end

local function GetMenuIndexAndEntry(menu, scene, name, id)
    for i, entry in ipairs(menu or {}) do
        local entryId = entry and entry.id or nil
        local sceneName = nil
        local entryName = nil
        if entry and entry.data then
            sceneName = entry.data.scene
            if type(entry.data.name) == "function" then
                entryName = entry.data.name()
            else
                entryName = entry.data.name
            end
        else
            sceneName = entry and entry.scene
            if type(entry and entry.name) == "function" then
                entryName = entry.name()
            else
                entryName = entry and entry.name
            end
        end
        if scene and sceneName and sceneName == scene then
            return i, entry
        end
        if name and entryName and entryName == name then
            return i, entry
        end
        if id and entryId and entryId == id then
            return i, entry
        end
    end
    return nil, nil
end

function SPFLibMainMenu.GetMenuIndex(scene, name, id)
    local index, _ = GetMenuIndexAndEntry(ZO_MENU_ENTRIES, scene, name, id)
    return index
end

function SPFLibMainMenu.GetSubMenuIndex(scene, name, id, subScene, subName, subId)
    local index, entry = GetMenuIndexAndEntry(ZO_MENU_ENTRIES, scene, name, id)

    if entry then
        local subIndex, _ = GetMenuIndexAndEntry(entry.subMenu, subScene, subName, subId)
        return index, subIndex
    end

    return nil, nil
end

function SPFLibMainMenu.GetActivityFinderIndex()
    return SPFLibMainMenu.GetMenuIndex(
        ZO_GAMEPAD_ACTIVITY_FINDER_ROOT_SCENE_NAME,
        GetString(SI_MAIN_MENU_ACTIVITY_FINDER),
        ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER
    )
end

function SPFLibMainMenu.GetLoreLibraryIndex()
    return SPFLibMainMenu.GetSubMenuIndex(
        nil,
        GetString(SI_MAIN_MENU_JOURNAL),
        ZO_MENU_MAIN_ENTRIES.JOURNAL,
        "loreLibraryGamepad",
        GetString(SI_GAMEPAD_MAIN_MENU_JOURNAL_LORE_LIBRARY),
        4
    )
end

function SPFLibMainMenu.Refresh()
    if MAIN_MENU_GAMEPAD.RefreshMainList then
        MAIN_MENU_GAMEPAD:RefreshMainList()
    elseif MAIN_MENU_GAMEPAD.RefreshLists then
        MAIN_MENU_GAMEPAD:RefreshLists()
    end
end

function SPFLibMainMenu.AddMainMenuEntry(data, insertIndex)
    data.id = #ZO_MENU_ENTRIES + 1

    local newEntry = SPFLibMainMenu.CreateMainMenuEntry(data)

    if insertIndex then
        table.insert(ZO_MENU_ENTRIES, insertIndex, newEntry)
    else
        table.insert(ZO_MENU_ENTRIES, newEntry)
    end

    SPFLibMainMenu.Refresh()
end

function SPFLibMainMenu.AddMainMenuSubEntry(data, mainIndex, insertIndex)
    data.id = #ZO_MENU_ENTRIES + 1

    local newEntry = SPFLibMainMenu.CreateMainMenuEntry(data)

    local mainMenuEntry = ZO_MENU_ENTRIES[mainIndex]
    if not mainMenuEntry or not mainMenuEntry.subMenu then
        table.insert(ZO_MENU_ENTRIES, newEntry)
    end

    if insertIndex then
        table.insert(mainMenuEntry.subMenu, insertIndex, newEntry)
    else
        table.insert(mainMenuEntry.subMenu, newEntry)
    end

    SPFLibMainMenu.Refresh()
end
