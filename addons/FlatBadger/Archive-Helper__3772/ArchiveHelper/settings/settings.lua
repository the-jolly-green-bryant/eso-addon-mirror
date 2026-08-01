local AH = _G.ArchiveHelper

AH.LAM = _G.LibAddonMenu2

local panel = {
    type = "panel",
    name = "Archive Helper",
    displayName = zo_iconFormat("/esoui/art/icons/poi/poi_endlessdungeon_complete.dds") .. " |cff9900Archive Helper|r",
    author = "Flat Badger",
    version = AH.LC.GetAddonVersion(AH.Name),
    registerForRefresh = true
}
local favouriteChoices = {}
local favouriteChoiceValues = {}

local function doSort(tin, tout1, tout2)
    table.sort(
        tin,
        function(a, b)
            return a.name < b.name
        end
    )

    for _, choice in ipairs(tin) do
        table.insert(tout1, choice.name)
        table.insert(tout2, choice.id)
    end
end

do
    local tmpTable = {}

    for abilityId, _ in pairs(AH.ABILITIES) do
        local name = GetAbilityName(abilityId, "player")

        if (name and name ~= "") then
            table.insert(tmpTable, { id = abilityId, name = AH.LC.Format(name) })
        end
    end

    doSort(tmpTable, favouriteChoices, favouriteChoiceValues)
end

local removeChoices = {}
local removeChoiceValues = {}

local function populateRemovableOptions(doNotFill)
    local choices = AH.Vars.Favourites

    if (#choices == 0) then
        return {}
    end

    local tmpTable = {}

    for _, choice in ipairs(choices) do
        local name = GetAbilityName(choice, "player")
        local icon = GetAbilityIcon(choice)

        table.insert(tmpTable, { id = choice, name = AH.LC.Format(name), icon = icon })
    end

    if (not doNotFill) then
        doSort(tmpTable, removeChoices, removeChoiceValues)
    end

    return tmpTable
end

local function getFavourites()
    local removed = populateRemovableOptions(true)
    local text = ""

    if (#removed > 0) then
        table.sort(
            removed,
            function(a, b)
                return a.name < b.name
            end
        )

        for _, ability in ipairs(removed) do
            text = text .. zo_iconFormat(ability.icon, 24, 24)
            text = text .. " " .. ability.name .. AH.LF
        end
    end

    return text
end

local function updateFavourites()
    _G.ARCHIVEHELPER_FAVOURITES_LIST.data.text = getFavourites()
    _G.ARCHIVEHELPER_FAVOURITES_LIST:UpdateValue()
end

local removeIgnoreChoices = {}
local removeIgnoreChoiceValues = {}

local function populateRemovableIgnoreOptions(doNotFill)
    local choices = AH.Vars.Ignore

    if (#choices == 0) then
        return {}
    end

    local tmpTable = {}

    for _, choice in ipairs(choices) do
        local name = GetAbilityName(choice, "player")
        local icon = GetAbilityIcon(choice)

        table.insert(tmpTable, { id = choice, name = AH.LC.Format(name), icon = icon })
    end

    if (not doNotFill) then
        doSort(tmpTable, removeIgnoreChoices, removeIgnoreChoiceValues)
    end

    return tmpTable
end

local function getIgnore()
    local removed = populateRemovableIgnoreOptions()
    local text = ""

    if (#removed > 0) then
        table.sort(
            removed,
            function(a, b)
                return a.name < b.name
            end
        )

        for _, ability in ipairs(removed) do
            text = text .. zo_iconFormat(ability.icon, 24, 24)
            text = text .. " " .. ability.name .. AH.LF
        end
    end

    return text
end

local function updateIgnore()
    _G.ARCHIVEHELPER_IGNORE_LIST.data.text = getIgnore()
    _G.ARCHIVEHELPER_IGNORE_LIST:UpdateValue()
end

local function getSecondsOptions()
    local seconds = {}

    for sec = 20, 60, 5 do
        table.insert(seconds, sec)
    end

    return seconds
end

local function buildOptions()
    populateRemovableOptions()

    local optional = ""
    local yellow = AH.LC.Yellow

    if (not AH.Chat) then
        optional = yellow:Colorize(GetString(_G.ARCHIVEHELPER_OPTIONAL_LIBS_CHAT))
    end

    if (not _G.LibDataShare) then
        if (optional ~= "") then
            optional = optional .. AH.LF
        end

        optional = optional .. yellow:Colorize(GetString(_G.ARCHIVEHELPER_OPTIONAL_LIBS_SHARE))
    end

    local options = {
        [1] = {
            type = "description",
            text = optional,
            width = "full"
        },
        [2] = {
            type = "header",
            name = AH.LC.Format(SI_BINDING_NAME_TOGGLE_NOTIFICATIONS),
            width = "full"
        },
        [3] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_PROGRESS_ACHIEVEMENT),
            getFunc = function()
                return AH.Vars.Notify
            end,
            setFunc = function(value)
                AH.Vars.Notify = value
            end,
            width = "full"
        },
        [4] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_PROGRESS_CHAT),
            tooltip = AH.LC.Format(_G.ARCHIVEHELPER_REQUIRES),
            getFunc = function()
                return AH.Vars.NotifyChat
            end,
            setFunc = function(value)
                AH.Vars.NotifyChat = value
            end,
            disabled = function()
                return (not AH.Vars.Notify) or (not AH.Chat)
            end,
            width = "full"
        },
        [5] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_PROGRESS_SCREEN),
            getFunc = function()
                return AH.Vars.NotifyScreen
            end,
            setFunc = function(value)
                AH.Vars.NotifyScreen = value
            end,
            disabled = function()
                return not AH.Vars.Notify
            end,
            width = "full"
        },
        [6] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_SELECTION),
            tooltip = AH.LC.Format(_G.ARCHIVEHELPER_REQUIRES) ..
                ". " .. AH.LC.Format(_G.ARCHIVEHELPER_SHOW_COUNT_TOOLTIP),
            getFunc = function()
                return AH.Vars.ShowSelection
            end,
            setFunc = function(value)
                AH.Vars.ShowSelection = value
            end,
            disabled = function()
                return not AH.Chat
            end,
            width = "full"
        },
        [7] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_SELECTION_DISPLAY_NAME),
            tooltip = function()
                if (_G.ARCHIVEHELPER_SHOW_SELECTION_DISPLAY_NAME_TOOLTIP) then
                    return string.format(
                        "%s. %s",
                        AH.LC.Format(_G.ARCHIVEHELPER_SHOW_SELECTION_DISPLAY_NAME_TOOLTIP),
                        AH.LC.Format(_G.ARCHIVEHELPER_REQUIRES)
                    )
                else
                    return AH.LC.Format(_G.ARCHIVEHELPER_REQUIRES)
                end
            end,
            getFunc = function()
                return AH.Vars.UseDisplayName
            end,
            setFunc = function(value)
                AH.Vars.UseDisplayName = value
            end,
            disabled = function()
                return not AH.Chat or (not AH.Vars.ShowSelection)
            end,
            width = "full"
        },
        [8] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_TERRAIN_WARNING),
            tooltip = function()
                if (_G.ARCHIVEHELPER_SHOW_TERRAIN_WARNING_TOOLTIP) then
                    return AH.LC.Format(_G.ARCHIVEHELPER_SHOW_TERRAIN_WARNING_TOOLTIP)
                end
            end,
            getFunc = function()
                return AH.Vars.TerrainWarnings
            end,
            setFunc = function(value)
                AH.Vars.TerrainWarnings = value
                AH.SetTerrainWarnings(value)
            end
        },
        [9] = {
            type = "header",
            name = AH.LC.Format(SI_ITEMFILTERTYPE5),
            width = "full"
        },
        [10] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_REMINDER),
            tooltip = AH.LC.Format(_G.ARCHIVEHELPER_REMINDER_TOOLTIP),
            getFunc = function()
                return AH.Vars.ShowNotice
            end,
            setFunc = function(value)
                AH.Vars.ShowNotice = value
            end,
            width = "full"
        },
        [11] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_REMINDER_QUEST),
            getFunc = function()
                return AH.Vars.CheckQuestItems
            end,
            setFunc = function(value)
                AH.Vars.CheckQuestItems = value
            end,
            width = "full"
        },
        [12] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_PREVENT),
            tooltip = AH.LC.Format(_G.ARCHIVEHELPER_PREVENT_TOOLTIP),
            getFunc = function()
                return AH.Vars.PreventSelection
            end,
            setFunc = function(value)
                AH.Vars.PreventSelection = value
            end,
            width = "full"
        },
        [13] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_AUDITOR),
            getFunc = function()
                return AH.Vars.Auditor
            end,
            setFunc = function(value)
                AH.Vars.Auditor = value
            end,
            width = "full",
            disabled = function()
                return not IsCollectibleUnlocked(AH.AUDITOR)
            end
        },
        [14] = {
            type = "header",
            name = AH.LC.Format(_G.ARCHIVEHELPER_BONUS),
            width = "full"
        },
        [15] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_ECHO),
            getFunc = function()
                return AH.Vars.ShowTimer
            end,
            setFunc = function(value)
                AH.Vars.ShowTimer = value
            end,
            width = "full"
        },
        [16] = {
            type = "dropdown",
            name = string.format(
                "%s (%s)",
                AH.LC.Format(SI_ABILITY_TOOLTIP_DURATION_LABEL),
                AH.LC.Format(_G.ARCHIVEHELPER_SECONDS):lower()
            ),
            choices = getSecondsOptions(),
            getFunc = function()
                return AH.Vars.EchoingDenTimer
            end,
            setFunc = function(value)
                AH.Vars.EchoingDenTimer = value
            end,
            disabled = function()
                return not AH.Vars.ShowTimer
            end,
            width = "full"
        },
        [17] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_COUNT),
            tooltip = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_COUNT_TOOLTIP),
            getFunc = function()
                return AH.Vars.CountTomes
            end,
            setFunc = function(value)
                AH.Vars.CountTomes = value
            end,
            width = "full"
        },
        [18] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_CROSSING_HELPER),
            getFunc = function()
                return AH.Vars.ShowHelper
            end,
            setFunc = function(value)
                AH.Vars.ShowHelper = value
            end,
            width = "full"
        },
        [19] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHOW_THEATRE_WARNING),
            getFunc = function()
                return AH.Vars.Theatre
            end,
            setFunc = function(value)
                AH.Vars.Theatre = value
            end,
            width = "full"
        },
        [20] = {
            type = "header",
            name = AH.LC.Format(SI_INTERFACE_OPTIONS_NAMEPLATES_TARGET_MARKERS),
            width = "full"
        },
        [21] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_FABLED_MARKER),
            tooltip = function()
                if (not AH.CompatibilityCheck()) then
                    return AH.LC.Format(_G.ARCHIVEHELPER_FABLED_TOOLTIP)
                end
            end,
            getFunc = function()
                return AH.Vars.FabledCheck
            end,
            setFunc = function(value)
                AH.Vars.FabledCheck = value
            end,
            disabled = function()
                return not AH.CompatibilityCheck()
            end,
            width = "full"
        },
        [22] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHARD_MARKER),
            tooltip = function()
                if (not AH.CompatibilityCheck()) then
                    return AH.LC.Format(_G.ARCHIVEHELPER_FABLED_TOOLTIP)
                end
            end,
            getFunc = function()
                return AH.Vars.ShardCheck
            end,
            setFunc = function(value)
                AH.Vars.ShardCheck = value
            end,
            width = "full"
        },
        [23] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_SHARD_IGNORE),
            tooltip = function()
                if (not AH.CompatibilityCheck()) then
                    return AH.LC.Format(_G.ARCHIVEHELPER_FABLED_TOOLTIP)
                end
            end,
            getFunc = function()
                return AH.Vars.ShardIgnore or false
            end,
            setFunc = function(value)
                AH.Vars.ShardIgnore = value
            end,
            disabled = function()
                return not AH.Vars.ShardCheck
            end,
            width = "full"
        },
        [24] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_GW_MARKER),
            getFunc = function()
                return AH.Vars.GwCheck
            end,
            setFunc = function(value)
                AH.Vars.GwCheck = value
            end,
            width = "full"
        },
        [25] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_GW_PLAY),
            getFunc = function()
                return AH.Vars.GwPlay or false
            end,
            setFunc = function(value)
                AH.Vars.GwPlay = value
            end,
            disabled = function()
                return not AH.Vars.GwCheck
            end,
            width = "full"
        },
        [26] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_MARAUDER_MARKER) ..
                " " .. zo_iconFormat("/esoui/art/targetmarkers/target_white_skull_64.dds", 24, 24),
            getFunc = function()
                return AH.Vars.MarauderCheck
            end,
            setFunc = function(value)
                AH.Vars.MarauderCheck = value
            end,
            width = "full"
        },
        [27] = {
            type = "checkbox",
            name = AH.LC.Format(_G.ARCHIVEHELPER_MARAUDER_INCOMING_PLAY),
            getFunc = function()
                return AH.Vars.MarauderPlay or false
            end,
            setFunc = function(value)
                AH.Vars.MarauderPlay = value
            end,
            width = "full"
        }
    }

    options[#options + 1] = {
        type = "header",
        name = AH.LC.Format(SI_INTERFACE_OPTIONS_INDICATORS),
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = AH.LC.GetIconTexture(string.format("/esoui/art/%s.dds", AH.ICONS.ACH.name), AH.LC.Red, 24, 24) ..
            " " .. AH.LC.Format(SI_ZONECOMPLETIONTYPE3),
        getFunc = function()
            return AH.Vars.MarkAchievements
        end,
        setFunc = function(value)
            AH.Vars.MarkAchievements = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = zo_iconFormat(string.format("/esoui/art/%s.dds", AH.ICONS.WOLF.name), 24, 24) ..
            " " .. AH.LC.Format(SI_ENDLESS_DUNGEON_SUMMARY_AVATAR_VISIONS_HEADER),
        getFunc = function()
            return AH.Vars.MarkAvatar
        end,
        setFunc = function(value)
            AH.Vars.MarkAvatar = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = yellow:Colorize("(1)   ") .. AH.LC.Format(_G.ARCHIVEHELPER_STACKS),
        getFunc = function()
            return AH.Vars.ShowStacks
        end,
        setFunc = function(value)
            AH.Vars.ShowStacks = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = AH.LC.GetIconTexture(string.format("/esoui/art/%s.dds", AH.ICONS.FAV.name), AH.LC.Green, 24, 24) ..
            " " .. AH.LC.Format(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER),
        getFunc = function()
            return AH.Vars.MarkFavourites
        end,
        setFunc = function(value)
            AH.Vars.MarkFavourites = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = zo_iconFormat(string.format("/esoui/art/%s.dds", AH.ICONS.AVOID.name), 24, 24) ..
            "|r " .. AH.LC.Format(_G.ARCHIVEHELPER_AVOID),
        getFunc = function()
            return AH.Vars.MarkIgnore
        end,
        setFunc = function(value)
            AH.Vars.MarkIgnore = value
        end,
        width = "full"
    }

    options[#options + 1] = {
        type = "header",
        name = AH.LC.Format(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER),
        width = "full"
    }

    options[#options + 1] = {
        type = "dropdown",
        name = AH.LC.Format(SI_COLLECTIBLE_ACTION_ADD_FAVORITE),
        choices = favouriteChoices,
        choicesValues = favouriteChoiceValues,
        scrollable = true,
        getFunc = function()
        end,
        setFunc = function(value)
            if (ZO_IsElementInNumericallyIndexedTable(AH.Vars.Favourites, value)) then
                return
            end

            table.insert(AH.Vars.Favourites, value)
            updateFavourites()
        end,
        disabled = function()
            return not AH.Vars.MarkFavourites
        end
    }

    options[#options + 1] = {
        type = "dropdown",
        name = AH.LC.Format(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE),
        choices = removeChoices,
        choicesValues = removeChoiceValues,
        scrollable = true,
        getFunc = function()
        end,
        setFunc = function(value)
            if (ZO_IsElementInNumericallyIndexedTable(AH.Vars.Favourites, value)) then
                AH.Vars.Favourites =
                    AH.LC.Filter(
                        AH.Vars.Favourites,
                        function(v)
                            return v ~= value
                        end
                    )

                updateFavourites()
            end
        end,
        disabled = function()
            return #AH.Vars.Favourites == 0 or (not AH.Vars.MarkFavourites)
        end
    }

    options[#options + 1] = {
        type = "description",
        text = AH.LC.Red:Colorize(AH.LC.Format(_G.ARCHIVEHELPER_WARNING)),
        width = "full"
    }

    options[#options + 1] = {
        type = "description",
        text = getFavourites(),
        width = "full",
        reference = "ARCHIVEHELPER_FAVOURITES_LIST",
        disabled = function()
            return not AH.Vars.MarkFavourites
        end
    }

    options[#options + 1] = {
        type = "header",
        name = AH.LC.Format(_G.ARCHIVEHELPER_AVOID),
        width = "full"
    }

    options[#options + 1] = {
        type = "checkbox",
        name = AH.LC.Format(_G.ARCHIVEHELPER_USE_AUTO_AVOID),
        tooltip = AH.LC.Format(_G.ARCHIVEHELPER_USE_AUTO_AVOID_TOOLTIP),
        getFunc = function()
            return AH.Vars.AutoCheck
        end,
        setFunc = function(value)
            if (value) then
                AH.EnableAutoCheck()
            else
                AH.DisableAutoCheck()
            end
        end,
        disabled = function()
            return not AH.Vars.MarkIgnore
        end
    }

    options[#options + 1] = {
        type = "dropdown",
        name = AH.LC.Format(_G.ARCHIVEHELPER_ADD_AVOID),
        choices = favouriteChoices,
        choicesValues = favouriteChoiceValues,
        scrollable = true,
        getFunc = function()
        end,
        setFunc = function(value)
            if (ZO_IsElementInNumericallyIndexedTable(AH.Vars.Ignore, value)) then
                return
            end

            table.insert(AH.Vars.Ignore, value)
            updateIgnore()
        end,
        disabled = function()
            return not AH.Vars.MarkIgnore
        end
    }

    options[#options + 1] = {
        type = "dropdown",
        name = AH.LC.Format(_G.ARCHIVEHELPER_REMOVE_AVOID),
        choices = removeIgnoreChoices,
        choicesValues = removeIgnoreChoiceValues,
        scrollable = true,
        getFunc = function()
        end,
        setFunc = function(value)
            if (ZO_IsElementInNumericallyIndexedTable(AH.Vars.Ignore, value)) then
                AH.Vars.Ignore =
                    AH.LC.Filter(
                        AH.Vars.Ignore,
                        function(v)
                            return v ~= value
                        end
                    )

                updateIgnore()
            end
        end,
        disabled = function()
            return #AH.Vars.Ignore == 0 or (not AH.Vars.MarkIgnore)
        end
    }

    options[#options + 1] = {
        type = "description",
        text = AH.LC.Red:Colorize(AH.LC.Format(_G.ARCHIVEHELPER_WARNING)),
        width = "full"
    }

    options[#options + 1] = {
        type = "description",
        text = getIgnore(),
        width = "full",
        reference = "ARCHIVEHELPER_IGNORE_LIST",
        disabled = function()
            return not AH.Vars.MarkIgnore
        end
    }

    return options
end

function AH.RegisterSettings()
    local options = buildOptions()

    AH.OptionsPanel = AH.LAM:RegisterAddonPanel("ArchiveHelperOptionsPanel", panel)
    AH.LAM:RegisterOptionControls("ArchiveHelperOptionsPanel", options)
end
