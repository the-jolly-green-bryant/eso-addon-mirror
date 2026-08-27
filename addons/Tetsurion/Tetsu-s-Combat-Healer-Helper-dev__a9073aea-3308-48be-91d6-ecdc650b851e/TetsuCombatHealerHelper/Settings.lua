TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

local function ColorGet(tbl, dr, dg, db, da)
    tbl = tbl or {}
    return tbl.r or dr, tbl.g or dg, tbl.b or db, tbl.a or da
end

local function ColorSet(tbl, r, g, b, a)
    tbl.r, tbl.g, tbl.b, tbl.a = r, g, b, a
    return tbl
end

local function SlotItems()
    local items = {}
    for i = 1, #T.SlotCatalog do
        items[i] = {
            name = T.SlotLabel(T.SlotCatalog[i].key),
            data = T.SlotCatalog[i].key,
        }
    end
    return items
end

local function Dropdown(settings, label, tooltip, defaultKey, getter, setter)
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = label,
        tooltip = tooltip,
        items = SlotItems(),
        default = T.SlotLabel(defaultKey),
        getFunction = function()
            return T.SlotLabel(getter() or "off")
        end,
        setFunction = function(control, itemName, itemData)
            local key = (itemData and itemData.data) or "off"
            setter(key)
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })
end

function T.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end
    local L = T.L
    local vars = T.savedVars
    if not vars or not L then return end

    local settings = LibHarven:AddAddon(L.TITLE, { allowRefresh = true, allowDefaults = true })
    if not settings then return end
    settings.version = "1.3.2"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = L.INFO_LABEL,
        tooltip = L.INFO_TT,
        canSelect = true,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.ENABLED_LABEL,
        tooltip = L.ENABLED_TT,
        default = true,
        getFunction = function()
            return vars.enabled ~= false
        end,
        setFunction = function(val)
            vars.enabled = val and true or false
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HUD_LABEL,
        tooltip = L.HUD_TT,
        default = true,
        getFunction = function()
            return vars.hudList ~= false
        end,
        setFunction = function(val)
            vars.hudList = val and true or false
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.WORLD_PIPS_LABEL,
        tooltip = L.WORLD_PIPS_TT,
        default = true,
        getFunction = function()
            return vars.worldPips ~= false
        end,
        setFunction = function(val)
            vars.worldPips = val and true or false
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.ICON_SIZE_LABEL,
        tooltip = L.ICON_SIZE_TT,
        min = 24,
        max = 72,
        step = 4,
        default = 40,
        getFunction = function()
            return vars.iconSize or 40
        end,
        setFunction = function(val)
            vars.iconSize = tonumber(val) or 40
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.HEAD_HEIGHT_LABEL or "Head icon height",
        tooltip = L.HEAD_HEIGHT_TT or "Metres above the unit origin (feet). Raise if icons sit in the chest.",
        min = 12,
        max = 32,
        step = 1,
        default = 22,
        getFunction = function()
            return math.floor(((vars.headHeight or 2.15) * 10) + 0.5)
        end,
        setFunction = function(val)
            vars.headHeight = (tonumber(val) or 22) / 10
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = L.HEAD_MODE_LABEL or "Head icon mode",
        tooltip = L.HEAD_MODE_TT or "Auto uses 3D render space (same as the old puddle). Screen pins icons on the HUD if 3D fails in a zone.",
        items = {
            { name = L.HEAD_MODE_AUTO or "Auto (3D world)", data = "auto" },
            { name = L.HEAD_MODE_SCREEN or "Screen overlay", data = "screen" },
        },
        default = L.HEAD_MODE_AUTO or "Auto (3D world)",
        getFunction = function()
            if vars.headMode == "screen" then
                return L.HEAD_MODE_SCREEN or "Screen overlay"
            end
            return L.HEAD_MODE_AUTO or "Auto (3D world)"
        end,
        setFunction = function(control, itemName, itemData)
            vars.headMode = (itemData and itemData.data) or "auto"
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.HEAD_SECTION,
        tooltip = L.HEAD_SECTION_TT,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = L.IH_COLOR_LABEL,
        tooltip = L.IH_COLOR_TT,
        default = { 0.25, 0.95, 0.45, 1 },
        getFunction = function()
            return ColorGet(vars.ihColor, 0.25, 0.95, 0.45, 1)
        end,
        setFunction = function(r, g, b, a)
            vars.ihColor = ColorSet(vars.ihColor or {}, r, g, b, a)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = L.PRAYER_COLOR_LABEL,
        tooltip = L.PRAYER_COLOR_TT,
        default = { 1, 0.2, 0.2, 1 },
        getFunction = function()
            return ColorGet(vars.prayerColor, 1, 0.2, 0.2, 1)
        end,
        setFunction = function(r, g, b, a)
            vars.prayerColor = ColorSet(vars.prayerColor or {}, r, g, b, a)
        end,
    })

    Dropdown(settings, L.HEAD_EXTRA_LABEL, L.HEAD_EXTRA_TT, "off",
        function() return vars.headExtraKey or "off" end,
        function(key) vars.headExtraKey = key end)

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = L.HEAD_EXTRA_COLOR_LABEL,
        tooltip = L.HEAD_EXTRA_COLOR_TT,
        default = { 1, 0.45, 0.15, 1 },
        getFunction = function()
            return ColorGet(vars.headExtraColor, 1, 0.45, 0.15, 1)
        end,
        setFunction = function(r, g, b, a)
            vars.headExtraColor = ColorSet(vars.headExtraColor or {}, r, g, b, a)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.HUD_SECTION,
        tooltip = L.HUD_SECTION_TT,
    })

    for i = 1, 5 do
        local idx = i
        Dropdown(settings,
            (L.HUD_COL_LABEL or "HUD buff %d"):format(idx),
            L.HUD_COL_TT or "Green dot in this column when the player HAS the buff.",
            (idx == 1 and "powerfulAssault") or (idx == 2 and "majorCourage") or (idx == 3 and "echoingVigor") or "off",
            function()
                return vars["hudBuff" .. idx] or "off"
            end,
            function(key)
                vars["hudBuff" .. idx] = key
            end)
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.HUD_X_LABEL or "HUD offset X",
        tooltip = L.HUD_X_TT or "Move the buff grid left (negative) or right.",
        min = -400,
        max = 80,
        step = 10,
        default = 0,
        getFunction = function()
            return vars.hudOffsetX or 0
        end,
        setFunction = function(val)
            vars.hudOffsetX = tonumber(val) or 0
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.HUD_Y_LABEL or "HUD offset Y",
        tooltip = L.HUD_Y_TT or "Move the buff grid up (negative) or down.",
        min = -80,
        max = 400,
        step = 10,
        default = 0,
        getFunction = function()
            return vars.hudOffsetY or 0
        end,
        setFunction = function(val)
            vars.hudOffsetY = tonumber(val) or 0
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.HUD_SCALE_LABEL or "HUD scale %",
        tooltip = L.HUD_SCALE_TT or "Size of the buff grid.",
        min = 70,
        max = 140,
        step = 5,
        default = 100,
        getFunction = function()
            return math.floor(((vars.hudScale or 1) * 100) + 0.5)
        end,
        setFunction = function(val)
            vars.hudScale = (tonumber(val) or 100) / 100
            if T.Heads then T.Heads.RefreshAll() end
        end,
    })
end
