local NecroCatIcons = "NecroCatIcons"
local LAM = LibAddonMenu2

-- 1. Твой оригинальный список иконок
local ICONS = {
    ["Кошка"] = "NecroCatIcons/imgs/Necrocat.dds",
    ["Кошка2"] = "NecroCatIcons/imgs/Necrocat2.dds",
    ["Кошка3"] = "NecroCatIcons/imgs/Necrocat3.dds",
    ["Praid"] = "NecroCatIcons/imgs/Pra1d.dds",
    ["Praid2"] = "NecroCatIcons/imgs/Pra1d2.dds",
    ["Praid3"] = "NecroCatIcons/imgs/Pra1d3.dds",
    ["Pra1d4"] = "NecroCatIcons/imgs/Pra1d4.dds",
    ["Julia"] = "NecroCatIcons/imgs/Julia.dds",
    ["Julia2"] = "NecroCatIcons/imgs/Julia2.dds",
    ["Julia3"] = "NecroCatIcons/imgs/Julia3.dds",
    ["Avi"] = "NecroCatIcons/imgs/AviryNa.dds",
    ["Avi2"] = "NecroCatIcons/imgs/AviryNa2.dds",
    ["Avi3"] = "NecroCatIcons/imgs/AviryNa3.dds",
    ["StarIDNova"] = "NecroCatIcons/imgs/StarIDNova.dds",
    ["Soul_Hagans"] = "NecroCatIcons/imgs/SoulHagans.dds",
    ["Soul_Hagans2"] = "NecroCatIcons/imgs/SoulHagans2.dds",
    ["Tegaro"] = "NecroCatIcons/imgs/Tegaro.dds",
    ["Moonrae"] = "NecroCatIcons/imgs/Moonrae.dds",
    ["Crown"] = "NecroCatIcons/imgs/Crown.dds",
    ["Tesoshnik"] = "NecroCatIcons/imgs/Tesoshnik.dds",
    ["DontUp"] = "NecroCatIcons/imgs/DontUp.dds",
    ["F"] = "NecroCatIcons/imgs/F.dds",
    ["Loot"] = "NecroCatIcons/imgs/Loot.dds",
    ["Tails"] = "NecroCatIcons/imgs/tails.dds",
    ["FoxyAnezka"] = "NecroCatIcons/imgs/FoxyAnezka.dds",
    ["Wildmile98"] = "NecroCatIcons/imgs/Wildmile98.dds",
    ["ArCrass"] = "NecroCatIcons/imgs/ArCrass.dds",
}

-- Константа для отключения
local DISABLED_OPTION = "--- ВЫКЛЮЧЕНО ---"

-- Список имен для меню (добавляем пункт отключения)
local ICON_NAMES = { DISABLED_OPTION }
for name, _ in pairs(ICONS) do table.insert(ICON_NAMES, name) end
table.sort(ICON_NAMES)

-- 2. Твои настройки по умолчанию
local Defaults = {
    users = {
        ["@NecroCat_Crimson"]   = "Кошка3",
        ["@horusgor"]           = "Кошка2",
        ["@Gonzo-Cat"]          = "Кошка2",
        ["@Praid_Crimson"]      = "Praid3",
        ["@Chio-Cill"]          = "Julia",
        ["@AviryNa"]            = "Avi",
        ["@Star_ID.Nova"]       = "StarIDNova",
        ["@Soul_Hagans"]        = "Soul_Hagans",
        ["@Tegaro"]             = "Tegaro",
        ["@Moonrae"]            = "Moonrae",
        ["@TESOSHNIK"]          = "Tesoshnik",
        ["@TESOSHNIK_REBIRTH"]  = "Tesoshnik",
        ["@Primo_Kilert007"]    = "Tails",
        ["@Jerry_Russo"]        = "Tails",
        ["@SoulBeast"]          = "Tails",
        ["@FoxyAnezka"]         = "FoxyAnezka",
        ["@Wildmile98"]          = "Wildmile98",
        ["@ArCrass"]             = "ArCrass",
    }
}

local db

-- 3. Применение в OSI (с проверкой на выключение)
local function ApplyIconsToOSI()
    if not OSI or not OSI.AddUniqueIconPack then return end
    
    local uniquePack = {}
    for user, iconName in pairs(db.users) do
        -- Если выбрано "ВЫКЛЮЧЕНО", мы просто НЕ добавляем этого юзера в список для OSI
        if iconName ~= DISABLED_OPTION then
            uniquePack[user] = ICONS[iconName]
        end
    end
    
    -- Отправляем пак в Оди. Те, кого мы пропустили, останутся без иконки от нашего аддона.
    OSI.AddUniqueIconPack(uniquePack)
    
    -- Регистрация всех иконок в общем списке Оди
    local customIcons = {}
    for _, path in pairs(ICONS) do table.insert(customIcons, path) end
    OSI.AddCustomIconPack(customIcons)
    
    if OSI.RefreshAllIcons then OSI.RefreshAllIcons() end
end

-- 4. Твоё меню настроек
local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "NecroCatIcons",
        displayName = "|cFFFF00NecroCat|r Icons",
        author = "Soul_Hagans",
        version = "1.4.1",
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel("NecroCatIcons", panelData)

    local optionsData = {}
    table.insert(optionsData, { type = "header", name = "Настройка иконок (выберите статус выключено, чтобы убрать иконку)" })

    local sortedUsernames = {}
    for user, _ in pairs(db.users) do table.insert(sortedUsernames, user) end
    table.sort(sortedUsernames)

    for _, user in ipairs(sortedUsernames) do
        table.insert(optionsData, {
            type = "dropdown",
            name = "Иконка для " .. user,
            choices = ICON_NAMES,
            getFunc = function() return db.users[user] or DISABLED_OPTION end,
            setFunc = function(value) 
                db.users[user] = value 
                ApplyIconsToOSI()
            end,
            width = "full",
        })
    end
    LAM:RegisterOptionControls("NecroCatIcons", optionsData)
end

-- 5. Инициализация
local function Initialize(event, addonName)
    if addonName ~= NecroCatIcons then return end

    db = ZO_SavedVars:NewAccountWide("NecroCatIconsVars", 10, nil, Defaults, GetWorldName())
    

    ApplyIconsToOSI()
    if LAM then CreateSettingsMenu() end
    
    EVENT_MANAGER:UnregisterForEvent(NecroCatIcons, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(NecroCatIcons, EVENT_ADD_ON_LOADED, Initialize)