CrownAndCrux = CrownAndCrux or {}
CrownAndCrux.State = CrownAndCruxState

---------------------------------------------------------------  Constants / Schema
local ADDON_NAME      = "CrownAndCrux"
local SCHEMA_VERSION  = 2    -- bump when SavedVars structure changes
local SV_NAMESPACE    = "CrownAndCruxSaved"
local SV_VERSION_ROOT = 1    -- ESO API “version” parameter (not our schema)
local SV_SUBTABLE     = nil  -- no subtable key

---------------------------------------------------------------  Defaults
local defaults = {
    _schemaVersion    = SCHEMA_VERSION, -- stored schema marker
    alwaysShow        = false,
    pos               = { x = -400, y = 0 },   -- matches XML anchor
    enlargeCrown      = false,
    counterScale      = 1.0,
    leaderIconChoice  = "crown_white",         -- <shape>_<color>
    leaderCrownSize   = 128,                   -- 64 or 128

    -- Headstones feature
    headstonesEnabled = true,                  -- global on/off
}

---------------------------------------------------------------  External refs
local Events = CrownAndCruxEvents

---------------------------------------------------------------  UI Option Tables
local SCALE_OPTIONS = {
    [1.0]  = "Normal (100 %)",
    [0.75] = "Medium (75 %)",
    [0.50] = "Small (50 %)",
}

local LEADER_SIZE_OPTIONS = {
    [128] = "Large (128 px)",
    [64]  = "Medium (64 px)",
}

---------------------------------------------------------------  Textures
local LEADER_TEXTURES = {
    crown_white      = "CrownAndCrux/art/large_crown.dds",
    crown_gold       = "CrownAndCrux/art/large_crown_gold.dds",
    crown_red        = "CrownAndCrux/art/large_crown_red.dds",
    crown_teal       = "CrownAndCrux/art/large_crown_teal.dds",
    crown_pink       = "CrownAndCrux/art/large_crown_pink.dds",
    crown_purple     = "CrownAndCrux/art/large_crown_purple.dds",

    butterfly_white  = "CrownAndCrux/art/large_butterfly.dds",
    butterfly_gold   = "CrownAndCrux/art/large_butterfly_gold.dds",
    butterfly_red    = "CrownAndCrux/art/large_butterfly_red.dds",
    butterfly_teal   = "CrownAndCrux/art/large_butterfly_teal.dds",
    butterfly_pink   = "CrownAndCrux/art/large_butterfly_pink.dds",
    butterfly_purple = "CrownAndCrux/art/large_butterfly_purple.dds",
}

function CrownAndCrux.GetLeaderIconPath()
    local sv = CrownAndCrux.saved
    if not sv then return LEADER_TEXTURES.crown_white end
    return LEADER_TEXTURES[sv.leaderIconChoice] or LEADER_TEXTURES.crown_white
end

---------------------------------------------------------------  SavedVar Migration
local function MigrateSavedVars(sv)
    local v = sv._schemaVersion or 1

    -- v1 -> v2 : convert legacy keys; previously plain "crown" / "butterfly" or blue/green variants
    if v < 2 then
        local map = {
            crown = "crown_white",
            butterfly = "butterfly_white",
            crown_blue = "crown_teal",      -- renamed palette
            crown_green = "crown_pink",
            butterfly_blue = "butterfly_teal",
            butterfly_green = "butterfly_pink",
        }
        local cur = sv.leaderIconChoice
        if map[cur] then
            sv.leaderIconChoice = map[cur]
        end
        v = 2
    end

    sv._schemaVersion = v
end

---------------------------------------------------------------  Sanitization
local function SanitizeSavedVars(sv)
    -- leaderIconChoice
    if not LEADER_TEXTURES[sv.leaderIconChoice] then
        sv.leaderIconChoice = defaults.leaderIconChoice
    end

    -- leaderCrownSize numeric + whitelist
    local s = sv.leaderCrownSize
    if type(s) ~= "number" or (s ~= 64 and s ~= 128) then
        if type(s) == "string" then
            local n = tonumber(s:match("(%d+)"))
            if n == 64 or n == 128 then
                sv.leaderCrownSize = n
            else
                sv.leaderCrownSize = defaults.leaderCrownSize
            end
        else
            sv.leaderCrownSize = defaults.leaderCrownSize
        end
    end

    -- counterScale numeric + whitelist
    local cs = sv.counterScale
    if type(cs) ~= "number" or (cs ~= 1.0 and cs ~= 0.75 and cs ~= 0.50) then
        if type(cs) == "string" then
            local n = tonumber(cs:match("(%d+%.?%d*)"))
            if n == 100 then n = 1.0 elseif n == 75 then n = 0.75 elseif n == 50 then n = 0.50 end
            if n == 1.0 or n == 0.75 or n == 0.50 then
                sv.counterScale = n
            else
                sv.counterScale = defaults.counterScale
            end
        else
            sv.counterScale = defaults.counterScale
        end
    end

    -- pos table
    local p = sv.pos
    if type(p) ~= "table" or type(p.x) ~= "number" or type(p.y) ~= "number" then
        sv.pos = { x = defaults.pos.x, y = defaults.pos.y }
    end

    -- booleans
    if type(sv.alwaysShow) ~= "boolean" then sv.alwaysShow = defaults.alwaysShow end
    if type(sv.enlargeCrown) ~= "boolean" then sv.enlargeCrown = defaults.enlargeCrown end
    if type(sv.headstonesEnabled) ~= "boolean" then sv.headstonesEnabled = defaults.headstonesEnabled end
end

---------------------------------------------------------------  Apply counter scale
function CrownAndCrux.ApplyCounterScale()
    if CrownAndCruxUI then
        CrownAndCruxUI:SetScale(CrownAndCrux.saved.counterScale or 1.0)
    end
end

---------------------------------------------------------------  Settings panel
local function CreateSettingsPanel()
    local LAM = LibAddonMenu2

    LAM:RegisterAddonPanel("CAC_Panel", {
        type    = "panel",
        name    = "Crown & Crux",
        author  = "SaintAres97",
        version = "1.3.7",
    })

    local opts = {
        { type="header", name="Counter Settings" },
        {
            type    = "checkbox",
            name    = "Always show frame",
            tooltip = "Always shows the crux counter frame.",
            getFunc = function() return CrownAndCrux.saved.alwaysShow end,
            setFunc = function(v)
                CrownAndCrux.saved.alwaysShow = v
                CrownAndCruxEvents.Refresh()
            end,
            width = "full",
        },
        {
            type    = "dropdown",
            name    = "Counter size",
            tooltip = "Choose the counter's frame size.",
            choices = { "Normal (100 %)", "Medium (75 %)", "Small (50 %)" },
            getFunc = function()
                return SCALE_OPTIONS[CrownAndCrux.saved.counterScale or 1.0]
            end,
            setFunc = function(choice)
                for scale, label in pairs(SCALE_OPTIONS) do
                    if label == choice then
                        CrownAndCrux.saved.counterScale = scale
                        break
                    end
                end
                CrownAndCrux.ApplyCounterScale()
            end,
            width = "full",
        },
        {
            type    = "slider",
            name    = "Horizontal offset",
            tooltip = "Moves the counter horizontally.",
            min     = -960, max = 960, step = 10,
            getFunc = function() return CrownAndCrux.saved.pos.x end,
            setFunc = function(v)
                CrownAndCrux.saved.pos.x = v
                if CrownAndCruxUI then
                    CrownAndCruxUI:SetAnchor(CENTER, GuiRoot, CENTER, v, CrownAndCrux.saved.pos.y)
                end
            end,
            width = "full",
        },
        {
            type    = "slider",
            name    = "Vertical offset",
            tooltip = "Moves the counter vertically.",
            min     = -540, max = 540, step = 10,
            getFunc = function() return CrownAndCrux.saved.pos.y end,
            setFunc = function(v)
                CrownAndCrux.saved.pos.y = v
                if CrownAndCruxUI then
                    CrownAndCruxUI:SetAnchor(CENTER, GuiRoot, CENTER, CrownAndCrux.saved.pos.x, v)
                end
            end,
            width = "full",
        },
        {
            type    = "button",
            name    = "Reset position",
            tooltip = "Restore the counter to its default location.",
            func    = function()
                CrownAndCrux.saved.pos.x = defaults.pos.x
                CrownAndCrux.saved.pos.y = defaults.pos.y
                if CrownAndCruxUI then
                    CrownAndCruxUI:SetAnchor(CENTER, GuiRoot, CENTER, defaults.pos.x, defaults.pos.y)
                end
            end,
            width = "full",
        },
        { type="header", name="Leader Marker" },
        {
            type    = "checkbox",
            name    = "Enlarged leader crown",
            tooltip = "Show a larger icon over the current group leader.",
            getFunc = function() return CrownAndCrux.saved.enlargeCrown end,
            setFunc = function(v)
                CrownAndCrux.saved.enlargeCrown = v
                CrownAndCrux_ApplyLeaderCrown()
            end,
            width = "full",
        },
        {
            type          = "dropdown",
            name          = "Leader Marker Style",
            tooltip       = "Choose the icon and color for the floating leader marker.",
            choices       = {
                "Crown – White","Crown – Gold","Crown – Red","Crown – Teal","Crown – Pink","Crown – Purple",
                "Butterfly – White","Butterfly – Gold","Butterfly – Red","Butterfly – Teal","Butterfly – Pink","Butterfly – Purple",
            },
            choicesValues = {
                "crown_white","crown_gold","crown_red","crown_teal","crown_pink","crown_purple",
                "butterfly_white","butterfly_gold","butterfly_red","butterfly_teal","butterfly_pink","butterfly_purple",
            },
            getFunc = function() return CrownAndCrux.saved.leaderIconChoice end,
            setFunc = function(val)
                CrownAndCrux.saved.leaderIconChoice = val
                CrownAndCrux_ApplyLeaderCrown()
            end,
            default       = defaults.leaderIconChoice,
            width         = "full",
        },
        {
            type          = "dropdown",
            name          = "Leader-Crown Size",
            tooltip       = "Choose the pixel size of the leader icon.",
            choices       = { "Large (128 px)", "Medium (64 px)" },
            getFunc       = function()
                return LEADER_SIZE_OPTIONS[CrownAndCrux.saved.leaderCrownSize or 128]
            end,
            setFunc       = function(label)
                for px, txt in pairs(LEADER_SIZE_OPTIONS) do
                    if txt == label then
                        CrownAndCrux.saved.leaderCrownSize = px
                        break
                    end
                end
                CrownAndCrux_ApplyLeaderCrown()
            end,
            default       = LEADER_SIZE_OPTIONS[defaults.leaderCrownSize],
            width         = "full",
        },

        -- Headstones
        { type="header", name="Headstones (Dead Group Markers)" },
        {
            type    = "checkbox",
            name    = "Enable headstones",
            tooltip = "Show headstone icons over dead group members (overland & PvP only). Auto-disabled in dungeons & trials.",
            getFunc = function() return CrownAndCrux.saved.headstonesEnabled end,
            setFunc = function(v)
                CrownAndCrux.saved.headstonesEnabled = v
                if CrownAndCruxHeadstone and CrownAndCruxHeadstone.SetEnabled then
                    CrownAndCruxHeadstone.SetEnabled(v)
                end
            end,
            default = defaults.headstonesEnabled,
            width   = "full",
        },
    }

    LAM:RegisterOptionControls("CAC_Panel", opts)
end

---------------------------------------------------------------  Position restore
local function ApplySavedPosition()
    local p = CrownAndCrux.saved and CrownAndCrux.saved.pos
    if p and CrownAndCruxUI then
        CrownAndCruxUI:ClearAnchors()
        CrownAndCruxUI:SetAnchor(CENTER, GuiRoot, CENTER, p.x, p.y)
    end
    EVENT_MANAGER:UnregisterForEvent("CAC_Pos", EVENT_PLAYER_ACTIVATED)
end

---------------------------------------------------------------  Addon Loaded
function CrownAndCrux.OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    CrownAndCrux.saved =
        ZO_SavedVars:NewAccountWide(SV_NAMESPACE, SV_VERSION_ROOT, SV_SUBTABLE, defaults)

    -- Migrate & sanitize
    MigrateSavedVars(CrownAndCrux.saved)
    SanitizeSavedVars(CrownAndCrux.saved)

    CreateSettingsPanel()
    Events:Initialize()

    -- Bind Headstone module to our SavedVars if it's present
    if CrownAndCruxHeadstone and CrownAndCruxHeadstone.BindSaved then
        CrownAndCruxHeadstone.BindSaved(CrownAndCrux.saved)
    end

    EVENT_MANAGER:RegisterForEvent("CAC_Pos", EVENT_PLAYER_ACTIVATED, function()
        ApplySavedPosition()
        CrownAndCrux.ApplyCounterScale()
        CrownAndCrux_ApplyLeaderCrown()
        if CrownAndCruxHeadstone and CrownAndCruxHeadstone.BindSaved then
            CrownAndCruxHeadstone.BindSaved(CrownAndCrux.saved)
        end
    end)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- (Optional) debug slash (updated: removed dbgSelf)
    SLASH_COMMANDS["/cacdebug"] = function()
        d(string.format("[CAC] schema=%s icon=%s size=%s scale=%.2f headstones=%s",
            tostring(CrownAndCrux.saved._schemaVersion),
            tostring(CrownAndCrux.saved.leaderIconChoice),
            tostring(CrownAndCrux.saved.leaderCrownSize),
            tonumber(CrownAndCrux.saved.counterScale or 0),
            tostring(CrownAndCrux.saved.headstonesEnabled)))
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, CrownAndCrux.OnAddOnLoaded)
