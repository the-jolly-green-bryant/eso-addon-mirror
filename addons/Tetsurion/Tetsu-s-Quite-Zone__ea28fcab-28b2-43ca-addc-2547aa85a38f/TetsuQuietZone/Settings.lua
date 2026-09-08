TetsuQuietZone = TetsuQuietZone or {}
local T = TetsuQuietZone

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function Vars()
    return T.savedVars
end

function T.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end
    local vars = Vars()
    if not vars then return end

    local settings = LibHarven:AddAddon(L("TITLE", "Tetsu's Quiet Zone"), {
        allowRefresh = true,
        allowDefaults = true,
    })
    if not settings then return end
    settings.version = "1.0.0"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("INFO_LABEL", "Info"),
        tooltip = L("INFO_TT", ""),
        canSelect = true,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("ENABLED", "Hide guild ads"),
        tooltip = L("ENABLED_TT", ""),
        default = true,
        getFunction = function()
            return vars.enabled ~= false
        end,
        setFunction = function(val)
            vars.enabled = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("FILTER_ZONE", "Filter zone chat"),
        tooltip = L("FILTER_ZONE_TT", ""),
        default = true,
        getFunction = function()
            return vars.filterZone ~= false
        end,
        setFunction = function(val)
            vars.filterZone = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("FILTER_SAY", "Filter say chat"),
        tooltip = L("FILTER_SAY_TT", ""),
        default = true,
        getFunction = function()
            return vars.filterSay ~= false
        end,
        setFunction = function(val)
            vars.filterSay = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("FILTER_YELL", "Filter yell chat"),
        tooltip = L("FILTER_YELL_TT", ""),
        default = false,
        getFunction = function()
            return vars.filterYell == true
        end,
        setFunction = function(val)
            vars.filterYell = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("HIDDEN_LABEL", "Hidden this session"),
        tooltip = L("HIDDEN_TT", ""),
        canSelect = true,
    })
end
