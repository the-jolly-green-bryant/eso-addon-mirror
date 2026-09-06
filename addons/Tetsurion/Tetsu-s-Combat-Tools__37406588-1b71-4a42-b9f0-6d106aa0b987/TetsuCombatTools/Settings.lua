TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function Vars()
    return T.savedVars
end

local function SkillOff()
    local v = Vars()
    return not (v and v.skillEnabled ~= false)
end

local function StatusOff()
    local v = Vars()
    return not (v and v.statusEnabled ~= false)
end

local function StatusIconOff()
    local v = Vars()
    return StatusOff() or not (v and v.statusIcon ~= false)
end

local function StatusTextOff()
    local v = Vars()
    return StatusOff() or not (v and v.statusText == true)
end

local function StatusSoundOff()
    local v = Vars()
    return StatusOff() or not (v and v.statusSound ~= false)
end

local function ConsOff()
    local v = Vars()
    return not (v and v.consEnabled ~= false)
end

local function SoundItems()
    return {
        { name = L("SOUND_DUEL", "Duel start"), data = "duel" },
        { name = L("SOUND_ALERT", "Alert"), data = "alert" },
        { name = L("SOUND_NOTIFY", "Notification"), data = "notify" },
        { name = L("SOUND_DISCOVER", "Objective found"), data = "discover" },
    }
end

local function SoundLabel(id)
    if id == "alert" then return L("SOUND_ALERT", "Alert") end
    if id == "notify" then return L("SOUND_NOTIFY", "Notification") end
    if id == "discover" then return L("SOUND_DISCOVER", "Objective found") end
    return L("SOUND_DUEL", "Duel start")
end

local function ShowItems()
    return {
        { name = L("SHOW_COMBAT", "In combat only"), data = "combat" },
        { name = L("SHOW_ALWAYS", "Always"), data = "always" },
        { name = L("SHOW_IDLE", "After last press"), data = "idle" },
    }
end

local function ShowLabel(mode)
    if mode == "always" then return L("SHOW_ALWAYS", "Always") end
    if mode == "idle" then return L("SHOW_IDLE", "After last press") end
    return L("SHOW_COMBAT", "In combat only")
end

function T.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end
    local vars = Vars()
    if not vars then return end

    local settings = LibHarven:AddAddon(L("TITLE", "Tetsu's Combat Tools"), {
        allowRefresh = true,
        allowDefaults = true,
    })
    if not settings then return end
    settings.version = "1.2.4"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("INFO_LABEL", "Info"),
        tooltip = L("INFO_TT", ""),
        canSelect = true,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SKILL_ENABLE", "Skill Tracking"),
        tooltip = L("SKILL_ENABLE_TT", ""),
        default = true,
        getFunction = function()
            return vars.skillEnabled ~= false
        end,
        setFunction = function(val)
            vars.skillEnabled = val and true or false
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("STATUS_ENABLE", "Combat Status"),
        tooltip = L("STATUS_ENABLE_TT", ""),
        default = true,
        getFunction = function()
            return vars.statusEnabled ~= false
        end,
        setFunction = function(val)
            vars.statusEnabled = val and true or false
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("CONS_ENABLE", "Consumables"),
        tooltip = L("CONS_ENABLE_TT", ""),
        default = true,
        getFunction = function()
            return vars.consEnabled ~= false
        end,
        setFunction = function(val)
            vars.consEnabled = val and true or false
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("SKILL_SECTION", "Skill Tracking"),
        tooltip = L("SKILL_SECTION_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SKILL_SLOTS", "History slots"),
        tooltip = L("SKILL_SLOTS_TT", ""),
        min = 4,
        max = 8,
        step = 1,
        default = 6,
        disable = SkillOff,
        getFunction = function()
            return vars.skillSlots or 6
        end,
        setFunction = function(val)
            vars.skillSlots = tonumber(val) or 6
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SKILL_SCALE", "Icon scale %"),
        tooltip = L("SKILL_SCALE_TT", ""),
        min = 50,
        max = 160,
        step = 5,
        default = 100,
        disable = SkillOff,
        getFunction = function()
            return vars.skillScale or 100
        end,
        setFunction = function(val)
            vars.skillScale = tonumber(val) or 100
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SKILL_X", "Offset X"),
        tooltip = L("SKILL_X_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 0,
        disable = SkillOff,
        getFunction = function()
            return vars.skillOffsetX or 0
        end,
        setFunction = function(val)
            vars.skillOffsetX = tonumber(val) or 0
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SKILL_Y", "Offset Y"),
        tooltip = L("SKILL_Y_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 330,
        disable = SkillOff,
        getFunction = function()
            local y = tonumber(vars.skillOffsetY)
            if y == nil then return 330 end
            return y
        end,
        setFunction = function(val)
            vars.skillOffsetY = tonumber(val) or 330
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_DROPDOWN,
        label = L("SKILL_SHOW", "When to show"),
        tooltip = L("SKILL_SHOW_TT", ""),
        items = ShowItems(),
        default = L("SHOW_COMBAT", "In combat only"),
        disable = SkillOff,
        getFunction = function()
            return ShowLabel(vars.skillShow)
        end,
        setFunction = function(control, itemName, itemData)
            vars.skillShow = (itemData and itemData.data) or "combat"
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SKILL_HIDE", "Hide after (sec)"),
        tooltip = L("SKILL_HIDE_TT", ""),
        min = 3,
        max = 15,
        step = 1,
        default = 8,
        disable = SkillOff,
        getFunction = function()
            return vars.skillHideAfter or 8
        end,
        setFunction = function(val)
            vars.skillHideAfter = tonumber(val) or 8
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SKILL_GCD", "GCD bar"),
        tooltip = L("SKILL_GCD_TT", ""),
        default = true,
        disable = SkillOff,
        getFunction = function()
            return vars.skillShowGcd ~= false
        end,
        setFunction = function(val)
            vars.skillShowGcd = val and true or false
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SKILL_WEAVE", "Weave frames"),
        tooltip = L("SKILL_WEAVE_TT", ""),
        default = true,
        disable = SkillOff,
        getFunction = function()
            return vars.skillShowWeave ~= false
        end,
        setFunction = function(val)
            vars.skillShowWeave = val and true or false
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SKILL_LA", "Show light attacks"),
        tooltip = L("SKILL_LA_TT", ""),
        default = false,
        disable = SkillOff,
        getFunction = function()
            return vars.skillLightAttacks == true
        end,
        setFunction = function(val)
            vars.skillLightAttacks = val and true or false
            if T.SkillRefresh then T.SkillRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("STATUS_SECTION", "Combat Status"),
        tooltip = L("STATUS_SECTION_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("STATUS_ICON", "Icon"),
        tooltip = L("STATUS_ICON_TT", ""),
        default = true,
        disable = StatusOff,
        getFunction = function()
            return vars.statusIcon ~= false
        end,
        setFunction = function(val)
            vars.statusIcon = val and true or false
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_ICON_X", "Icon offset X"),
        tooltip = L("STATUS_ICON_X_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 0,
        disable = StatusIconOff,
        getFunction = function()
            return vars.statusIconX or 0
        end,
        setFunction = function(val)
            vars.statusIconX = tonumber(val) or 0
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_ICON_Y", "Icon offset Y"),
        tooltip = L("STATUS_ICON_Y_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 0,
        disable = StatusIconOff,
        getFunction = function()
            return vars.statusIconY or 0
        end,
        setFunction = function(val)
            vars.statusIconY = tonumber(val) or 0
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_ICON_SCALE", "Icon scale %"),
        tooltip = L("STATUS_ICON_SCALE_TT", ""),
        min = 30,
        max = 180,
        step = 5,
        default = 50,
        disable = StatusIconOff,
        getFunction = function()
            return vars.statusIconScale or 50
        end,
        setFunction = function(val)
            vars.statusIconScale = tonumber(val) or 50
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_ICON_ALPHA", "Icon opacity %"),
        tooltip = L("STATUS_ICON_ALPHA_TT", ""),
        min = 10,
        max = 100,
        step = 5,
        default = 50,
        disable = StatusIconOff,
        getFunction = function()
            return vars.statusIconAlpha or 50
        end,
        setFunction = function(val)
            vars.statusIconAlpha = tonumber(val) or 50
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("STATUS_TEXT", "Text"),
        tooltip = L("STATUS_TEXT_TT", ""),
        default = false,
        disable = StatusOff,
        getFunction = function()
            return vars.statusText == true
        end,
        setFunction = function(val)
            vars.statusText = val and true or false
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_TEXT_X", "Text offset X"),
        tooltip = L("STATUS_TEXT_X_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 0,
        disable = StatusTextOff,
        getFunction = function()
            return vars.statusTextX or 0
        end,
        setFunction = function(val)
            vars.statusTextX = tonumber(val) or 0
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_TEXT_Y", "Text offset Y"),
        tooltip = L("STATUS_TEXT_Y_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 250,
        disable = StatusTextOff,
        getFunction = function()
            local y = tonumber(vars.statusTextY)
            if y == nil then return 250 end
            return y
        end,
        setFunction = function(val)
            vars.statusTextY = tonumber(val) or 250
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("STATUS_TEXT_SCALE", "Text scale %"),
        tooltip = L("STATUS_TEXT_SCALE_TT", ""),
        min = 50,
        max = 180,
        step = 5,
        default = 100,
        disable = StatusTextOff,
        getFunction = function()
            return vars.statusTextScale or 100
        end,
        setFunction = function(val)
            vars.statusTextScale = tonumber(val) or 100
            if T.StatusRefresh then T.StatusRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("STATUS_SOUND", "Sound on combat start"),
        tooltip = L("STATUS_SOUND_TT", ""),
        default = true,
        disable = StatusOff,
        getFunction = function()
            return vars.statusSound ~= false
        end,
        setFunction = function(val)
            vars.statusSound = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_DROPDOWN,
        label = L("STATUS_SOUND_PICK", "Start sound"),
        tooltip = L("STATUS_SOUND_PICK_TT", ""),
        items = SoundItems(),
        default = L("SOUND_DUEL", "Duel start"),
        disable = StatusSoundOff,
        getFunction = function()
            return SoundLabel(vars.statusSoundId)
        end,
        setFunction = function(control, itemName, itemData)
            vars.statusSoundId = (itemData and itemData.data) or "duel"
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("CONS_SECTION", "Consumables"),
        tooltip = L("CONS_SECTION_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("CONS_X", "Offset X"),
        tooltip = L("CONS_X_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 0,
        disable = ConsOff,
        getFunction = function()
            return vars.consOffsetX or 0
        end,
        setFunction = function(val)
            vars.consOffsetX = tonumber(val) or 0
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("CONS_Y", "Offset Y"),
        tooltip = L("CONS_Y_TT", ""),
        min = -500,
        max = 500,
        step = 10,
        default = 220,
        disable = ConsOff,
        getFunction = function()
            local y = tonumber(vars.consOffsetY)
            if y == nil then return 220 end
            return y
        end,
        setFunction = function(val)
            vars.consOffsetY = tonumber(val) or 220
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("CONS_SCALE", "Scale %"),
        tooltip = L("CONS_SCALE_TT", ""),
        min = 50,
        max = 180,
        step = 5,
        default = 100,
        disable = ConsOff,
        getFunction = function()
            return vars.consScale or 100
        end,
        setFunction = function(val)
            vars.consScale = tonumber(val) or 100
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("CONS_FOOD_WARN", "Food warn (min)"),
        tooltip = L("CONS_FOOD_WARN_TT", ""),
        min = 1,
        max = 15,
        step = 1,
        default = 5,
        disable = ConsOff,
        getFunction = function()
            return vars.consFoodWarn or 5
        end,
        setFunction = function(val)
            vars.consFoodWarn = tonumber(val) or 5
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("CONS_POT_WARN", "Potion warn (sec)"),
        tooltip = L("CONS_POT_WARN_TT", ""),
        min = 5,
        max = 20,
        step = 1,
        default = 10,
        disable = ConsOff,
        getFunction = function()
            return vars.consPotWarn or 10
        end,
        setFunction = function(val)
            vars.consPotWarn = tonumber(val) or 10
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("CONS_POT_COMBAT", "Potion only in combat"),
        tooltip = L("CONS_POT_COMBAT_TT", ""),
        default = false,
        disable = ConsOff,
        getFunction = function()
            return vars.consPotCombat == true
        end,
        setFunction = function(val)
            vars.consPotCombat = val and true or false
            if T.ConsRefresh then T.ConsRefresh() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("CONS_FOOD_SOUND", "Sound when food ends"),
        tooltip = L("CONS_FOOD_SOUND_TT", ""),
        default = false,
        disable = ConsOff,
        getFunction = function()
            return vars.consFoodSound == true
        end,
        setFunction = function(val)
            vars.consFoodSound = val and true or false
        end,
    })
end
