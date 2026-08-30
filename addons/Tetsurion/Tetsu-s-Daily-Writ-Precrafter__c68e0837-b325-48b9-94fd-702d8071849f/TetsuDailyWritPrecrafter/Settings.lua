TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}

function TetsuDailyWritPrecrafter.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = TetsuDailyWritPrecrafter.L
    local vars = TetsuDailyWritPrecrafter.savedVars
    if not vars or not L then return end

    local settings = LibHarven:AddAddon(L.TITLE, { allowRefresh = true })
    if not settings then return end

    settings.version = "2.4.3"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = L.INFO_LABEL,
        tooltip = L.INFO_TT,
        canSelect = true,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.COMPAT_LWC_LABEL,
        tooltip = L.COMPAT_LWC_TT,
        default = true,
        getFunction = function()
            return vars.compatLazyWrit ~= false
        end,
        setFunction = function(val)
            vars.compatLazyWrit = val and true or false
            if val then
                local cs = TetsuDailyWritPrecrafter.GetCharSettings()
                if cs then cs.preCraftEnabled = true end
            end
            zo_callLater(function()
                if ReloadUI then ReloadUI() end
            end, 250)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.PRECRAFT_ENABLED_LABEL,
        tooltip = L.PRECRAFT_ENABLED_TT,
        default = true,
        getFunction = function()
            if vars.compatLazyWrit ~= false then return true end
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            return cs and cs.preCraftEnabled == true
        end,
        setFunction = function(val)
            if vars.compatLazyWrit ~= false then return end
            local cs = TetsuDailyWritPrecrafter.GetCharSettings()
            if cs then
                cs.preCraftEnabled = val and true or false
            end
            if TetsuDailyWritPrecrafter.Crafting and TetsuDailyWritPrecrafter.Crafting.AddStationKeybind then
                zo_callLater(function()
                    TetsuDailyWritPrecrafter.Crafting.AddStationKeybind()
                end, 100)
            end
        end,
        disable = function()
            return vars.compatLazyWrit ~= false
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.PRECRAFT_DAYS_LABEL,
        tooltip = function()
            if TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat() then
                return L.PRECRAFT_DAYS_TT_COMPAT or L.PRECRAFT_DAYS_TT
            end
            return L.PRECRAFT_DAYS_TT
        end,
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

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.QUIET_INFO_LABEL,
        tooltip = L.QUIET_INFO_TT,
        default = false,
        getFunction = function()
            return vars.quietInfo == true
        end,
        setFunction = function(val)
            vars.quietInfo = val and true or false
        end,
    })

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
            if vars.compatLazyWrit ~= false then return false end
            return vars.autoQuest ~= false
        end,
        setFunction = function(val)
            if vars.compatLazyWrit ~= false then return end
            vars.autoQuest = val
        end,
        disable = function()
            return vars.compatLazyWrit ~= false
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.AUTO_BOX_LABEL,
        tooltip = L.AUTO_BOX_TT,
        default = true,
        getFunction = function()
            if vars.compatLazyWrit ~= false then return false end
            return vars.autoBox ~= false
        end,
        setFunction = function(val)
            if vars.compatLazyWrit ~= false then return end
            vars.autoBox = val
        end,
        disable = function()
            return vars.compatLazyWrit ~= false
        end,
    })
end
