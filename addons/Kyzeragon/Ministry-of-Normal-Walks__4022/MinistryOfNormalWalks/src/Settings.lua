MinistryOfNormalWalks = MinistryOfNormalWalks or {}
local MNW = MinistryOfNormalWalks

local personalityIds = {}
local personalityNames = {}

-- Populates the lists with sorted entries
local function CollectPersonalities()
    local personalities = {}
    for index = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, index)
        if (IsCollectibleUnlocked(collectibleId)) then
            personalities[GetCollectibleName(collectibleId)] = collectibleId
            table.insert(personalityNames, GetCollectibleName(collectibleId))
        end
    end

    table.sort(personalityNames)
    for _, name in ipairs(personalityNames) do
        table.insert(personalityIds, personalities[name])
    end

    table.insert(personalityIds, 1, 0)
    table.insert(personalityNames, 1, "No Personality")
end

function MNW.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Ministry of Normal Walks",
        author = "Kyzeragon",
        version = MNW.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    CollectPersonalities()

    local optionsData = {
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Enable changing the below collectibles when moving or stopping. You can also use |c99FF99/normalwalk|r to quickly toggle this",
            default = false,
            getFunc = function() return MNW.savedOptions.enabled end,
            setFunc = function(value)
                MNW.savedOptions.enabled = value
                MNW.UnregisterUpdates()
                MNW.RegisterUpdates()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Polling speed",
            tooltip = "How often, in milliseconds, to check whether your character is moving. A smaller number means faster detection of movement, but may be slightly inefficient on performance",
            min = 100,
            max = 2000,
            step = 1,
            default = 300,
            width = "full",
            getFunc = function() return MNW.savedOptions.pollingDelay end,
            setFunc = function(value)
                MNW.savedOptions.pollingDelay = value
                MNW.UnregisterUpdates()
                MNW.RegisterUpdates()
            end,
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "checkbox",
            name = "Mute collectible changing sound",
            tooltip = "Changing personalities plays a UI sound. Turning this option ON will attempt to mute the collectible activated, deactivated, and not ready sounds, only for the duration of the personality change",
            default = false,
            getFunc = function() return MNW.savedOptions.muteSound end,
            setFunc = function(value)
                MNW.savedOptions.muteSound = value
            end,
            width = "full",
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "checkbox",
            name = "Block \"not ready\" alert",
            tooltip = "If the collectible is on cooldown (likely due to moving and stopping too fast), a UI alert pops up with \"This collectible is not ready yet.\" Turning this option ON will attempt to block this alert, as well as mute the collectible not ready sound",
            default = false,
            getFunc = function() return MNW.savedOptions.blockAlert end,
            setFunc = function(value)
                MNW.savedOptions.blockAlert = value
            end,
            width = "full",
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show debug chat",
            default = false,
            getFunc = function() return MNW.savedOptions.debug end,
            setFunc = function(value)
                MNW.savedOptions.debug = value
            end,
            width = "full",
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "description",
            title = "|c3bdb5eWhile Moving|r",
            text = nil,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Personality",
            tooltip = "Specify which personality to equip when you start walking",
            choices = personalityNames,
            choicesValues = personalityIds,
            getFunc = function() return MNW.savedOptions.onMove.personality end,
            setFunc = function(id)
                MNW.savedOptions.onMove.personality = id
            end,
            width = "full",
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "description",
            title = "|c3bdb5eWhile Idling|r",
            text = nil,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Personality",
            tooltip = "Specify which personality to equip when you stop moving",
            choices = personalityNames,
            choicesValues = personalityIds,
            getFunc = function() return MNW.savedOptions.onIdle.personality end,
            setFunc = function(id)
                MNW.savedOptions.onIdle.personality = id
            end,
            width = "full",
            disabled = function() return not MNW.savedOptions.enabled end,
        },
        {
            type = "description",
            title = "",
            text = "Note: I do not recommend using \"No Personality\" as the Moving personality; it can get stuck on the previous personality when moving. This is a game bug, not a bug with the addon. Instead, you can set a personality that has a normal walk, such as Cheerful or Furious.",
            width = "full",
        },
    }

    MNW.addonPanel = LAM:RegisterAddonPanel("MinistryOfNormalWalksOptions", panelData)
    LAM:RegisterOptionControls("MinistryOfNormalWalksOptions", optionsData)
end