local addon = {
    name = "TraitRename",
    title = "Trait Rename",
    version = "1.5.11",
    author = "silvereyes",
}
local defaults = {
    replacementText = { }
}

--[[ Opens the addon settings panel ]]
function addon.OpenSettingsPanel()
    LibAddonMenu2:OpenToPanel(addon.settingsPanel)
end
local function GetTraitStringId(traitIndex)
    local traitStringId = _G[zo_strformat("SI_ITEMTRAITTYPE<<1>>", traitIndex)]
    return traitStringId
end
--[[ Removes any ESO color code markers from the start and end of the given text. ]]
local function StripColorAndWhitespace(text)
    text = zo_strtrim(text)
    text = string.gsub(text, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]", "")
    text = string.gsub(text, "|r", "")
    return text
end
function addon.OverrideTraitText(traitIndex, value)
    local traitStringId = GetTraitStringId(traitIndex)
    SafeAddString(traitStringId, value, 1)
end
local function CreateTraitOption(optionsTable, traitIndex, gearCategoryStringId)
    local traitStringId = GetTraitStringId(traitIndex)
    local tooltip = zo_strformat(GetString(SI_PREPOSTEROUS_TEXT_TOOLTIP_FORMAT), 
                                 GetString(traitStringId),
                                 GetString(gearCategoryStringId))
    local traitOption = {
        type = "editbox",
        width = "full",
        name = GetString(traitStringId),
        tooltip = tooltip,
        isExtraWide = true,
        getFunc = function() return addon.settings.replacementText[traitIndex] end,
        setFunc = function(value)
            addon.settings.replacementText[traitIndex] = value
            addon.OverrideTraitText(traitIndex, value)
        end,
        default = defaults.replacementText[traitIndex],
    }
    
    table.insert(optionsTable, traitOption)
end
local function UpgradeSettings(self, settings)
    if settings.dataVersion and settings.dataVersion > 2 then
        return
    end
    
    -- Bugfix in data upgrade code for data version 2
    if settings.dataVersion == 2 and type(settings.replacementText) == "table" 
       and settings.replacementText[17] and type(settings.replacementText[17]) == "table"
    then
        settings.dataVersion = 3
        settings.replacementText[17] = settings.replacementText[17][17]
        
    elseif settings.dataVersion == 1 and type(settings.replacementText) == "string" then
        local prosperousReplacementText = settings.replacementText
        settings.replacementText = {}
        for traitIndex = ITEM_TRAIT_TYPE_MIN_VALUE, ITEM_TRAIT_TYPE_MAX_VALUE do
            settings.replacementText[traitIndex] = defaults.replacementText[traitIndex]
        end
        settings.replacementText[17] = prosperousReplacementText
    end
    
    settings.dataVersion = 4
end
local function InitialOverride()
    -- Perform the initial override
    for traitIndex = ITEM_TRAIT_TYPE_MIN_VALUE, ITEM_TRAIT_TYPE_MAX_VALUE do
        local traitStringId = GetTraitStringId(traitIndex)
        if addon.settings.replacementText[traitIndex] then
            SafeAddVersion(traitStringId, 1)
            local traitText = addon.settings.replacementText[traitIndex]
            addon.OverrideTraitText(traitIndex, traitText)
        end
    end
end
function addon.Refresh()
    InitialOverride()
end
local isMasterWritQuest
local function OnQuestOffered(eventCode)
    local questInfo = GetOfferedQuestInfo()
    -- Restore original trait names before accepting a Master Writ quest
    if string.match(questInfo, "Rolis Hlaalu") then
        isMasterWritQuest = true
        for traitIndex = ITEM_TRAIT_TYPE_MIN_VALUE, ITEM_TRAIT_TYPE_MAX_VALUE do
            local traitStringId = GetTraitStringId(traitIndex)
            SafeAddString(traitStringId, defaults.replacementText[traitIndex], 1)
        end
    end
end
local function OnChatterEnd(eventCode)
    -- Reapply custom trait names after a Master Writ dialog closes
    if isMasterWritQuest then
        isMasterWritQuest = nil
        InitialOverride()
    end
end
local function SlashCommand(argument)
    if not argument or argument == "settings" then
        addon.OpenSettingsPanel()
        
    elseif argument == "refresh" or argument == "reload" then
        addon.Refresh()
    end
end
local function OnAddonLoaded(event, name)
    if name ~= addon.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    
    -- Default to base game trait names
    for traitIndex = ITEM_TRAIT_TYPE_MIN_VALUE, ITEM_TRAIT_TYPE_MAX_VALUE do
        defaults.replacementText[traitIndex] = GetString(GetTraitStringId(traitIndex))
    end

    -- Initialize saved variables
    addon.settings = LibSavedVars:NewAccountWide("Preposterous_Account", defaults)
                                 :AddCharacterSettingsToggle("Preposterous_Character")
    if LSV_Data.EnableDefaultsTrimming then
        addon.settings:EnableDefaultsTrimming()
    end
    
    local panelData = {
        type = "panel",
        name = addon.title,
        displayName = addon.title,
        author = addon.author,
        version = addon.version,
        website = "https://www.esoui.com/downloads/info1634-TraitRename.html",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    addon.settingsPanel = LibAddonMenu2:RegisterAddonPanel(addon.name .. "Options", panelData)

    local optionsTable = {
        -- Account-wide settings
        addon.settings:GetLibAddonMenuAccountCheckbox(),
    }
    
    -- No trait
    CreateTraitOption(optionsTable, 0)
    
    table.insert(optionsTable,
        
        -- Armor Trait
        {
            type = "header",
            width = "full",
            name = GetString(SI_ITEMTYPE45),
        }
    )
    for traitIndex=11,20 do
        CreateTraitOption(optionsTable, traitIndex, SI_SPECIALIZEDITEMTYPE300)
    end
    CreateTraitOption(optionsTable, 25)

    table.insert(optionsTable,
    
        -- Weapon Trait
        {
            type = "header",
            width = "full",
            name = GetString(SI_ITEMTYPE46),
        }
    )
    
    for traitIndex=1,10 do
        CreateTraitOption(optionsTable, traitIndex, SI_SPECIALIZEDITEMTYPE250)
    end
    CreateTraitOption(optionsTable, 26)
    
    
    table.insert(optionsTable,
    
        -- Jewelry
        {
            type = "header",
            width = "full",
            name = GetString(SI_GAMEPADITEMCATEGORY38),
        }
    )
    for traitIndex=21,24 do
        CreateTraitOption(optionsTable, traitIndex, SI_GAMEPADITEMCATEGORY38)
    end
    if ITEM_TRAIT_TYPE_MAX_VALUE > 27 then
        for traitIndex=27,33 do
            CreateTraitOption(optionsTable, traitIndex, SI_GAMEPADITEMCATEGORY38)
        end
    end
    
    LibAddonMenu2:RegisterOptionControls(addon.name .. "Options", optionsTable)
    
    InitialOverride()

    SLASH_COMMANDS["/ptrait"]       = SlashCommand
    SLASH_COMMANDS["/preposterous"] = SlashCommand
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_QUEST_OFFERED, OnQuestOffered)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CHATTER_END, OnChatterEnd)

   

Preposterous = addon
