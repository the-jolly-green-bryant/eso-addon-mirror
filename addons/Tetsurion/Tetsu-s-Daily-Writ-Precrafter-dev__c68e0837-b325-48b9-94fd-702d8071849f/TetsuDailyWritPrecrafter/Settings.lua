TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}

function TetsuDailyWritPrecrafter.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = TetsuDailyWritPrecrafter.L
    local vars = TetsuDailyWritPrecrafter.savedVars
    if not vars or not L then return end

    local settings = LibHarven:AddAddon(L.TITLE)
    if not settings then return end

    settings.version = "2.0.2"
    settings.author = "Tetsurion"

    -- Automation section
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.OPTIONS_SECTION_LABEL,
        tooltip = L.OPTIONS_SECTION_TT,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.AUTO_QUEST_LABEL,
        tooltip = L.AUTO_QUEST_TT,
        default = true,
        getFunction = function()
            return vars.autoQuest ~= false
        end,
        setFunction = function(val)
            vars.autoQuest = val
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.AUTO_BOX_LABEL,
        tooltip = L.AUTO_BOX_TT,
        default = true,
        getFunction = function()
            return vars.autoBox ~= false
        end,
        setFunction = function(val)
            vars.autoBox = val
        end,
    })

    -- Pre-craft section (per character)
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.PRECRAFT_SECTION_LABEL,
        tooltip = L.PRECRAFT_SECTION_TT,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.PRECRAFT_ENABLED_LABEL,
        tooltip = L.PRECRAFT_ENABLED_TT,
        default = false,
        getFunction = function()
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            return cs and cs.preCraftEnabled == true
        end,
        setFunction = function(val)
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            if cs then
                cs.preCraftEnabled = val and true or false
            end
            -- Refresh keybind if currently at a station
            if TetsuDailyWritPrecrafter.Crafting and TetsuDailyWritPrecrafter.Crafting.AddStationKeybind then
                zo_callLater(function()
                    TetsuDailyWritPrecrafter.Crafting.AddStationKeybind()
                end, 100)
            end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.PRECRAFT_DAYS_LABEL,
        tooltip = L.PRECRAFT_DAYS_TT,
        min = 1,
        max = 10,
        step = 1,
        default = 3,
        getFunction = function()
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            return (cs and cs.preCraftDays) or 3
        end,
        setFunction = function(val)
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            if cs then
                val = tonumber(val) or 3
                if val < 1 then val = 1 end
                if val > 10 then val = 10 end
                cs.preCraftDays = val
            end
            if TetsuDailyWritPrecrafter.Crafting and TetsuDailyWritPrecrafter.Crafting.AddStationKeybind then
                zo_callLater(function()
                    TetsuDailyWritPrecrafter.Crafting.AddStationKeybind()
                end, 100)
            end
        end,
    })
end
