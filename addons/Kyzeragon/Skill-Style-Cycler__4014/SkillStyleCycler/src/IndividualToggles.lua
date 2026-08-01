SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler

local BASE_STYLE_ID = -1 -- Just so I stop confusing myself

local SKILL_TYPES = {
    [SKILL_TYPE_ARMOR] = "Armor",
    [SKILL_TYPE_AVA] = "Alliance War",
    [SKILL_TYPE_CHAMPION] = "Champion",
    [SKILL_TYPE_CLASS] = "Class",
    [SKILL_TYPE_GUILD] = "Guild",
    [SKILL_TYPE_NONE] = "None",
    [SKILL_TYPE_RACIAL] = "Racial",
    [SKILL_TYPE_TRADESKILL] = "Craft",
    [SKILL_TYPE_WEAPON] = "Weapon",
    [SKILL_TYPE_WORLD] = "World",
}

local orderedValidSkillTypes = {}
local orderedProgressionIds = {}

-- TODO: don't save the nonsense, only the styles

-- There doesn't appear to be an API for getting info from only the progressionId, so cache it here
--[[
progressionCache = {
    [progressionId] = {
        name = "blah",
        texture = "blah",
        skillType = SKILL_TYPE_CLASS,
    },
}
]]
local progressionCache = {}

--[[
enabledStyles = {
    [progressionId] = {
        [BASE_STYLE_ID] = true, (base style)
        [collectibleId] = true,
        [collectibleId] = false,
    },
}
]]
local function CollectEnabledStylesKeys(enabledStyles)
    for skillType = 1, GetNumSkillTypes() do
        local isValidSkillType = false
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                if (numStyles > 0) then
                    table.insert(orderedProgressionIds, progressionId)
                    local name, texture = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                    progressionCache[progressionId] = {
                        name = name,
                        texture = texture,
                        skillType = skillType,
                    }

                    -- Add skill if doesn't exist; name/texture could be different if you have it morphed on the class, but it's probably ok
                    if (not enabledStyles[progressionId]) then
                        enabledStyles[progressionId] = {[BASE_STYLE_ID] = true,}
                    end

                    -- Find the newest(?) unlocked one, while printing out all and checking for current active
                    for i = 1, numStyles do
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, i)
                        -- d(zo_strformat("<<1>>, -- <<2>>", collectibleId, GetCollectibleName(collectibleId)))

                        -- For some reason, there are "styles" that don't exist but return 0 and are included in the number of styles. Unreleased?
                        if (collectibleId ~= 0) then
                            -- Add style if it doesn't exist, defaulting to true
                            if (enabledStyles[progressionId][collectibleId] == nil) then
                                enabledStyles[progressionId][collectibleId] = true
                            end

                            -- Overwrite this anyway so it's updated for the current morphs/class
                            isValidSkillType = true
                        end
                    end
                end
            end
        end
        if (isValidSkillType) then
            table.insert(orderedValidSkillTypes, skillType)
        end
    end
end
SSC.CollectEnabledStylesKeys = CollectEnabledStylesKeys
-- /script local a = {} SkillStyleCycler.CollectEnabledStylesKeys(a) d(a)

---------------------------------------------------------------------
-- Dynamically generate the settings menu
---------------------------------------------------------------------
local function CreateStyleSetting(controls, progressionId, collectibleId)
    local name
    local disabled = false
    local tooltip = "Include this style when the Cycler randomizes or cycles styles."
    if (collectibleId == BASE_STYLE_ID) then
        name = zo_strformat("|t30:30:<<1>>|t <<2>>", progressionCache[progressionId].texture, progressionCache[progressionId].name)
    else
        name = zo_strformat("|t30:30:<<1>>|t <<2>>", GetCollectibleIcon(collectibleId), GetCollectibleName(collectibleId))
        local hint = GetCollectibleHint(collectibleId)
        if (not IsCollectibleUnlocked(collectibleId)) then
            name = name .. " |t20:20:/esoui/art/miscellaneous/status_locked.dds|t"
            disabled = true
            tooltip = "Style is not unlocked."
        end
        tooltip = tooltip .. " ID: " .. tostring(collectibleId)

        -- It seems empty hints would be "Acquired through Purchase, Promotion, or Event" IF it is purchasable
        -- Not sure if there are any that aren't, but better to have the Probably disclaimer...
        if (hint ~= "") then
            tooltip = tooltip .. "\n\n" .. hint
        elseif (IsCollectiblePurchasable(collectibleId)) then
            if (SSC.sourceData[collectibleId]) then
                -- Add manual note
                tooltip = tooltip .. "\n\n" .. SSC.sourceData[collectibleId]
            else
                tooltip = tooltip .. "\n\n(Probably) " .. GetString(SI_COLLECTIBLE_TOOLTIP_PURCHASABLE)
            end
        end
    end

    table.insert(controls, {
        type = "checkbox",
        name = name,
        tooltip = tooltip,
        default = true,
        getFunc = function() return SSC.savedOptions.enabledStyles[progressionId][collectibleId] end,
        setFunc = function(value)
            SSC.savedOptions.enabledStyles[progressionId][collectibleId] = value
            SSC.BuildSkillStyleTable()
        end,
        width = "full",
        disabled = disabled,
    })
end

local function CreateSkillSettings(controls, progressionId)
    -- Skills with only 1 style (base) could have been included because of 0-collectibles
    local hasStyles = false
    local orderedStyleIds = {}
    for collectibleId, _ in pairs(SSC.savedOptions.enabledStyles[progressionId]) do
        if (collectibleId ~= BASE_STYLE_ID) then hasStyles = true end
        table.insert(orderedStyleIds, collectibleId)
    end
    if (not hasStyles) then return end
    table.sort(orderedStyleIds)

    table.insert(controls, {
        type = "description",
        title = progressionCache[progressionId].name,
        text = nil,
        width = "full",
    })

    for _, collectibleId in ipairs(orderedStyleIds) do
        CreateStyleSetting(controls, progressionId, collectibleId)
    end
end

local function CreateSkillTypeSettings(controls, skillType)
    local subControls = {}
    for _, progressionId in ipairs(orderedProgressionIds) do
        if (progressionCache[progressionId].skillType == skillType) then
            CreateSkillSettings(subControls, progressionId)
        end
    end

    table.insert(controls, {
        type = "submenu",
        name = SKILL_TYPES[skillType],
        controls = subControls,
    })
end

local function CreateToggleSettings()
    CollectEnabledStylesKeys(SSC.savedOptions.enabledStyles)

    local controls = {
        {
            type = "description",
            title = nil,
            text = "You can exclude styles from being picked by the Cycler here. ON = included, OFF = excluded.\nIf all options are OFF for a skill, Cycler will not make any changes to that skill.",
            width = "full",
        },
        {
            type = "button",
            name = "Toggle all default styles",
            tooltip = "Set all default styles below to ON or OFF",
            width = "half",
            func = function()
                local target
                for progressionId, data in pairs(SSC.savedOptions.enabledStyles) do
                    for collectibleId, _ in pairs(data) do
                        if (collectibleId == BASE_STYLE_ID) then
                            if (target == nil) then
                                target = not data[collectibleId]
                            end
                            data[collectibleId] = target
                        end
                    end
                end
                SSC.BuildSkillStyleTable()
            end,
        },
        {
            type = "button",
            name = "Toggle all collectibles",
            tooltip = "Set all non-default styles below to ON or OFF",
            width = "half",
            func = function()
                local target
                for progressionId, data in pairs(SSC.savedOptions.enabledStyles) do
                    for collectibleId, _ in pairs(data) do
                        if (collectibleId ~= BASE_STYLE_ID) then
                            if (target == nil) then
                                target = not data[collectibleId]
                            end
                            data[collectibleId] = target
                        end
                    end
                end
                SSC.BuildSkillStyleTable()
            end,
        },
    }

    for _, skillType in ipairs(orderedValidSkillTypes) do
        CreateSkillTypeSettings(controls, skillType)
    end

    return {
        type = "submenu",
        name = "Style Filters",
        controls = controls,
    }
end
SSC.CreateToggleSettings = CreateToggleSettings
