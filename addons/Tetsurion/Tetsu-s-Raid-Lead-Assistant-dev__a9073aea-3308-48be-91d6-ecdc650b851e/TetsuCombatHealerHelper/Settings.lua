TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

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
            if T.Hud then T.Hud.RefreshAll() end
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
    settings.version = "1.6.0"
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
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HUD_LABEL or "Show healer HUD",
        tooltip = L.HUD_TT or "Name grid with per-player dots.",
        default = true,
        getFunction = function()
            return vars.hudList ~= false
        end,
        setFunction = function(val)
            vars.hudList = val and true or false
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.PAIR_PANELS_LABEL or "Show buff / debuff panels",
        tooltip = L.PAIR_PANELS_TT or "Raid buffs and boss debuffs. Independent from the healer HUD.",
        default = true,
        getFunction = function()
            return vars.showPairPanels ~= false
        end,
        setFunction = function(val)
            vars.showPairPanels = val and true or false
            if T.Panels then T.Panels.Refresh() end
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.SORT_ROLE_LABEL or "Sort HUD by role",
        tooltip = L.SORT_ROLE_TT or "Tanks first, then healers, then DPS.",
        default = true,
        getFunction = function()
            return vars.sortByRole ~= false
        end,
        setFunction = function(val)
            vars.sortByRole = val and true or false
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HEALCUT_LABEL or "Mark heal cut / Defile",
        tooltip = L.HEALCUT_TT or "Red ✖ next to the name when the player has Defile or a heal-absorb.",
        default = true,
        getFunction = function()
            return vars.showHealCut ~= false
        end,
        setFunction = function(val)
            vars.showHealCut = val and true or false
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.LOWHP_TANKS_LABEL or "Low HP warning: tanks only",
        tooltip = L.LOWHP_TANKS_TT or "Off = color any low-HP row red.",
        default = true,
        getFunction = function()
            return vars.lowHpTanksOnly ~= false
        end,
        setFunction = function(val)
            vars.lowHpTanksOnly = val and true or false
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.LOWHP_PCT_LABEL or "Low HP threshold %",
        tooltip = L.LOWHP_PCT_TT or "Row name turns red at or below this health percent.",
        min = 15,
        max = 60,
        step = 5,
        default = 35,
        getFunction = function()
            return vars.lowHpPercent or 35
        end,
        setFunction = function(val)
            vars.lowHpPercent = tonumber(val) or 35
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.POS_SECTION or "HUD position",
        tooltip = L.POS_SECTION_TT or "Move and scale the windows.",
    })

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
            if T.Hud then T.Hud.RefreshAll() end
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
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.PAIR_X_LABEL or "Buff/debuff offset X",
        tooltip = L.PAIR_X_TT or "Used when the healer HUD is off. Moves raid + boss panels together.",
        min = -400,
        max = 80,
        step = 10,
        default = 0,
        getFunction = function()
            return vars.pairOffsetX or 0
        end,
        setFunction = function(val)
            vars.pairOffsetX = tonumber(val) or 0
            if T.Panels then T.Panels.Refresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.PAIR_Y_LABEL or "Buff/debuff offset Y",
        tooltip = L.PAIR_Y_TT or "Used when the healer HUD is off. Moves raid + boss panels together.",
        min = -80,
        max = 400,
        step = 10,
        default = 0,
        getFunction = function()
            return vars.pairOffsetY or 0
        end,
        setFunction = function(val)
            vars.pairOffsetY = tonumber(val) or 0
            if T.Panels then T.Panels.Refresh() end
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
            if T.Hud then T.Hud.RefreshAll() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = L.OOC_ALPHA_LABEL or "Out of combat opacity %",
        tooltip = L.OOC_ALPHA_TT or "How solid the HUDs are when you are not in combat. Combat is always 100%.",
        min = 25,
        max = 100,
        step = 5,
        default = 70,
        getFunction = function()
            return vars.oocAlpha or 70
        end,
        setFunction = function(val)
            vars.oocAlpha = tonumber(val) or 70
            if T.Hud then T.Hud.RefreshAll() end
            if T.Panels then T.Panels.Refresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.HUD_SECTION or "Healer buff columns",
        tooltip = L.HUD_SECTION_TT or "Per-player dots on the healer HUD.",
    })

    for i = 1, 5 do
        local idx = i
        Dropdown(settings,
            (L.HUD_COL_LABEL or "HUD buff %d"):format(idx),
            L.HUD_COL_TT or "Green dot in this column when the player HAS the buff.",
            (idx == 1 and "prayer") or (idx == 2 and "powerfulAssault") or (idx == 3 and "majorCourage") or (idx == 4 and "orbLockout") or "off",
            function()
                return vars["hudBuff" .. idx] or "off"
            end,
            function(key)
                vars["hudBuff" .. idx] = key
            end)
    end

    local colorItems = {
        { name = "Green", data = "green" },
        { name = "Blue", data = "blue" },
        { name = "Red", data = "red" },
        { name = "Yellow", data = "yellow" },
        { name = "Orange", data = "orange" },
        { name = "Purple", data = "purple" },
        { name = "Cyan", data = "cyan" },
        { name = "White", data = "white" },
    }
    local colorTitle = {
        green = "Green", blue = "Blue", red = "Red", yellow = "Yellow",
        orange = "Orange", purple = "Purple", cyan = "Cyan", white = "White",
    }
    local colorDefault = { "green", "yellow", "cyan", "orange", "purple" }
    for i = 1, 5 do
        local idx = i
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_DROPDOWN,
            label = (L.HUD_COL_COLOR or "Column %d color"):format(idx),
            tooltip = L.HUD_COL_COLOR_TT or "Color of the lit square in this healer-tracker column.",
            items = colorItems,
            default = colorTitle[colorDefault[idx]] or "Green",
            getFunction = function()
                local key = vars["hudColColor" .. idx] or colorDefault[idx]
                return colorTitle[key] or "Green"
            end,
            setFunction = function(control, itemName, itemData)
                vars["hudColColor" .. idx] = (itemData and itemData.data) or "green"
                if T.Hud then T.Hud.RefreshAll() end
            end,
        })
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.RAID_BUFFS or "Raid buffs",
        tooltip = L.RAID_BUFFS_TT or "Group Major/Minor coverage. One toggle per pair.",
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.SHOW_RAID_PANEL or "Show raid buff panel",
        tooltip = "",
        default = true,
        getFunction = function() return vars.showRaidPanel ~= false end,
        setFunction = function(val)
            vars.showRaidPanel = val and true or false
            if T.Panels then T.Panels.Refresh() end
        end,
    })
    if T.RaidBuffPairs then
        for i = 1, #T.RaidBuffPairs do
            local id = T.RaidBuffPairs[i].id
            settings:AddSetting({
                type = LibHarvensAddonSettings.ST_CHECKBOX,
                label = (T.EnglishName and T.EnglishName[id]) or id,
                tooltip = L["PAIR_DESC_" .. string.upper(id)] or L.PAIR_TT or "Major and Minor together.",
                default = true,
                getFunction = function()
                    return vars["buffPair_" .. id] ~= false
                end,
                setFunction = function(val)
                    vars["buffPair_" .. id] = val and true or false
                    if T.Panels then T.Panels.Refresh() end
                end,
            })
        end
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.BOSS_DEBUFFS or "Boss debuffs",
        tooltip = L.BOSS_DEBUFFS_TT or "Named Major/Minor on nearby bosses. Off-Balance shows Active / Immune.",
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.SHOW_BOSS_PANEL or "Show boss debuff panel",
        tooltip = "",
        default = true,
        getFunction = function() return vars.showBossPanel ~= false end,
        setFunction = function(val)
            vars.showBossPanel = val and true or false
            if T.Panels then T.Panels.Refresh() end
        end,
    })
    if T.BossDebuffPairs then
        for i = 1, #T.BossDebuffPairs do
            local id = T.BossDebuffPairs[i].id
            settings:AddSetting({
                type = LibHarvensAddonSettings.ST_CHECKBOX,
                label = (T.EnglishName and T.EnglishName[id]) or id,
                tooltip = L["PAIR_DESC_" .. string.upper(id)] or L.PAIR_TT or "Major and Minor together.",
                default = true,
                getFunction = function()
                    return vars["debuffPair_" .. id] ~= false
                end,
                setFunction = function(val)
                    vars["debuffPair_" .. id] = val and true or false
                    if T.Panels then T.Panels.Refresh() end
                end,
            })
        end
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.CUSTOM_LABELS or "HUD names",
        tooltip = L.CUSTOM_LABELS_TT or "Your text is shown on the HUDs. Healer columns use the first 5 letters, raid/boss panels the first 8.",
    })

    local editType = LibHarvensAddonSettings.ST_EDIT or LibHarvensAddonSettings.ST_EDITBOX or LibHarvensAddonSettings.ST_TEXT
    vars.customLabel = vars.customLabel or {}

    local function AddNameEdit(key)
        if not editType then return end
        settings:AddSetting({
            type = editType,
            label = T.EnglishName[key] or key,
            tooltip = L.CUSTOM_LABEL_TT or "Leave empty for the English name. Healer HUD: 5 letters. Buff/debuff panels: 8 letters.",
            default = T.EnglishName[key] or key,
            getFunction = function()
                return vars.customLabel[key] or ""
            end,
            setFunction = function(val)
                if type(val) == "string" then
                    vars.customLabel[key] = val
                else
                    vars.customLabel[key] = ""
                end
                if T.Hud then T.Hud.RefreshAll() end
                if T.Panels then T.Panels.Refresh() end
            end,
        })
    end

    if T.SlotCatalog then
        for i = 1, #T.SlotCatalog do
            local key = T.SlotCatalog[i].key
            if key and key ~= "off" then
                AddNameEdit(key)
            end
        end
    end
    if T.RaidBuffPairs then
        for i = 1, #T.RaidBuffPairs do
            AddNameEdit(T.RaidBuffPairs[i].id)
        end
    end
    if T.BossDebuffPairs then
        for i = 1, #T.BossDebuffPairs do
            AddNameEdit(T.BossDebuffPairs[i].id)
        end
    end
end
