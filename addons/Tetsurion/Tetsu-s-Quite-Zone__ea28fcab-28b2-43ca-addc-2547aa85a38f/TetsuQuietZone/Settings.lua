TetsuQuietZone = TetsuQuietZone or {}
local T = TetsuQuietZone

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function Vars()
    return T.savedVars
end

local function GuildIdForSlot(slot)
    if type(GetGuildId) ~= "function" or type(GetNumGuilds) ~= "function" then
        return 0
    end
    if slot < 1 or slot > GetNumGuilds() then
        return 0
    end
    return GetGuildId(slot) or 0
end

local function GuildSlotLabel(slot)
    local id = GuildIdForSlot(slot)
    if id == 0 then
        return zo_strformat(L("GUILD_EMPTY", "<<1>>. —"), slot)
    end
    local name = GetGuildName(id)
    if type(name) ~= "string" or name == "" then
        name = tostring(id)
    end
    return zo_strformat("<<1>>. <<2>>", slot, name)
end

local function HiddenLabel()
    local n = tonumber(T.hiddenCount) or 0
    return zo_strformat(L("HIDDEN_LABEL", "Hidden this session: <<1>>"), n)
end

local function AddSection(settings, LibHarven, title, tooltip)
    if LibHarven.ST_SECTION then
        settings:AddSetting({
            type = LibHarven.ST_SECTION,
            label = title,
            tooltip = tooltip,
        })
    else
        settings:AddSetting({
            type = LibHarven.ST_LABEL,
            label = title,
            tooltip = tooltip or "",
            canSelect = true,
        })
    end
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
    settings.version = "1.0.3"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("INFO_LABEL", "Info"),
        tooltip = L("INFO_TT", ""),
        canSelect = true,
    })

    -- Root: session counter (must sit before first ST_SECTION or console swallows it)
    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = HiddenLabel,
        tooltip = L("HIDDEN_TT", ""),
        canSelect = true,
    })

    -- Root item: submenu with zone/say/yell ad filters
    AddSection(settings, LibHarven, L("ADS_SECTION", "Mute guild ads"), L("ADS_SECTION_TT", ""))

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
        disable = function()
            return vars.enabled == false
        end,
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
        disable = function()
            return vars.enabled == false
        end,
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
        disable = function()
            return vars.enabled == false
        end,
        getFunction = function()
            return vars.filterYell == true
        end,
        setFunction = function(val)
            vars.filterYell = val and true or false
        end,
    })

    -- Root item 3: submenu with per-guild mutes
    AddSection(settings, LibHarven, L("GUILD_SECTION", "Mute guild chat"), L("GUILD_SECTION_TT", ""))

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("GUILD_HINT", "ON - hide messages from this guild"),
        tooltip = L("GUILD_HINT_TT", ""),
        canSelect = true,
    })

    for slot = 1, 5 do
        settings:AddSetting({
            type = LibHarven.ST_CHECKBOX,
            label = GuildSlotLabel(slot),
            tooltip = L("MUTE_GUILD_TT", ""),
            default = false,
            disable = function()
                return GuildIdForSlot(slot) == 0
            end,
            getFunction = function()
                return T.IsGuildMuted(GuildIdForSlot(slot))
            end,
            setFunction = function(val)
                T.SetGuildMuted(GuildIdForSlot(slot), val and true or false)
            end,
        })
    end

end
