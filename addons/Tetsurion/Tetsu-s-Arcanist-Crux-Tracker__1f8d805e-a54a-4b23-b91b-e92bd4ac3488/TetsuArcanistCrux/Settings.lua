TetsuArcanistCrux = TetsuArcanistCrux or {}
local T = TetsuArcanistCrux

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function Vars()
    return T.savedVars
end

local function IconsOff()
    local v = Vars()
    return not (v and v.showIcons ~= false)
end

local function NumberOff()
    local v = Vars()
    return not (v and v.showNumber == true)
end

local function BarOff()
    local v = Vars()
    return not (v and v.showBar ~= false)
end

local function SoundOff()
    local v = Vars()
    return not (v and v.soundEnabled ~= false)
end

local function TriangleOff()
    local v = Vars()
    if IconsOff() then return true end
    return not (v and v.iconLayout == "triangle")
end

local function ColorGet(tbl, d1, d2, d3, d4)
    if type(tbl) ~= "table" then
        return d1, d2, d3, d4
    end
    return tonumber(tbl[1]) or d1, tonumber(tbl[2]) or d2, tonumber(tbl[3]) or d3, tonumber(tbl[4]) or d4
end

local function ColorSet(tbl, r, g, b, a)
    tbl[1] = r
    tbl[2] = g
    tbl[3] = b
    tbl[4] = a or 1
end

local function SoundItems()
    return {
        { name = L("SOUND_KILL", "Killing blow"), data = "kill" },
        { name = L("SOUND_DUEL", "Duel start"), data = "duel" },
        { name = L("SOUND_ALERT", "Alert"), data = "alert" },
        { name = L("SOUND_NOTIFY", "Notification"), data = "notify" },
        { name = L("SOUND_DISCOVER", "Objective found"), data = "discover" },
        { name = L("SOUND_RUNE", "Potency rune"), data = "rune" },
        { name = L("SOUND_GLYPH", "Glyph removed"), data = "glyph" },
        { name = L("SOUND_QUEST", "Quest tick"), data = "quest" },
        { name = L("SOUND_LEVEL", "Level up"), data = "level" },
        { name = L("SOUND_MAIL", "New mail"), data = "mail" },
        { name = L("SOUND_SKILL", "Skill gained"), data = "skill" },
        { name = L("SOUND_LOCK", "Lock success"), data = "lock" },
        { name = L("SOUND_READY", "Ready check"), data = "ready" },
        { name = L("SOUND_TICK", "Countdown tick"), data = "tick" },
        { name = L("SOUND_BGMIN", "Battleground 1 min"), data = "bgmin" },
        { name = L("SOUND_BGGO", "Battleground start"), data = "bggo" },
        { name = L("SOUND_TRIALOK", "Trial complete"), data = "trialok" },
        { name = L("SOUND_TRIALNO", "Trial failed"), data = "trialno" },
        { name = L("SOUND_ACHIEVE", "Achievement"), data = "achieve" },
        { name = L("SOUND_SKY", "Skyshard"), data = "sky" },
        { name = L("SOUND_QDONE", "Quest complete"), data = "qdone" },
        { name = L("SOUND_QACC", "Quest accepted"), data = "qacc" },
        { name = L("SOUND_CHAMP", "Champion commit"), data = "champ" },
        { name = L("SOUND_ABIL", "Ability unlocked"), data = "abil" },
        { name = L("SOUND_COLL", "Collectible"), data = "coll" },
        { name = L("SOUND_BOOK", "Book acquired"), data = "book" },
        { name = L("SOUND_ESS", "Essence rune"), data = "ess" },
        { name = L("SOUND_ASP", "Aspect rune"), data = "asp" },
        { name = L("SOUND_ALC", "Alchemy solvent"), data = "alc" },
        { name = L("SOUND_FRIEND", "Friend invite"), data = "friend" },
        { name = L("SOUND_GJOIN", "Group join"), data = "gjoin" },
        { name = L("SOUND_KOS", "Kill on sight"), data = "kos" },
        { name = L("SOUND_LBREAK", "Lockpick break"), data = "lbreak" },
        { name = L("SOUND_KICK", "Instance kick"), data = "kick" },
        { name = L("SOUND_FANFARE", "Level fanfare"), data = "fanfare" },
        { name = L("SOUND_MEDAL", "Battleground medal"), data = "medal" },
        { name = L("SOUND_SPT", "Skill point"), data = "spt" },
        { name = L("SOUND_MAP", "Map discovered"), data = "map" },
    }
end

local function SoundLabel(id)
    local items = SoundItems()
    for i = 1, #items do
        if items[i].data == id then return items[i].name end
    end
    return items[1].name
end

local function LayoutItems()
    return {
        { name = L("LAYOUT_ROW_H", "Row horizontal"), data = "rowH" },
        { name = L("LAYOUT_ROW_V", "Row vertical"), data = "rowV" },
        { name = L("LAYOUT_TRI", "Triangle at reticle"), data = "triangle" },
    }
end

local function LayoutLabel(id)
    if id == "rowV" then return L("LAYOUT_ROW_V", "Row vertical") end
    if id == "triangle" then return L("LAYOUT_TRI", "Triangle at reticle") end
    return L("LAYOUT_ROW_H", "Row horizontal")
end

local function Refresh()
    if T.UIRefresh then T.UIRefresh() end
end

function T.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end
    local vars = Vars()
    if not vars then return end

    local settings = LibHarven:AddAddon(L("TITLE", "Tetsu's Arcanist Crux Tracker"), {
        allowRefresh = true,
        allowDefaults = true,
    })
    if not settings then return end
    settings.version = T.VERSION or "1.0.0"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarven.ST_LABEL,
        label = L("INFO_LABEL", "Info"),
        tooltip = L("INFO_TT", ""),
        canSelect = true,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SHOW_ICONS", "Show icons"),
        tooltip = L("SHOW_ICONS_TT", ""),
        default = true,
        getFunction = function()
            return vars.showIcons ~= false
        end,
        setFunction = function(val)
            vars.showIcons = val and true or false
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SHOW_NUMBER", "Show number"),
        tooltip = L("SHOW_NUMBER_TT", ""),
        default = false,
        getFunction = function()
            return vars.showNumber == true
        end,
        setFunction = function(val)
            vars.showNumber = val and true or false
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SHOW_BAR", "Color Fatecarver slot"),
        tooltip = L("SHOW_BAR_TT", ""),
        default = true,
        getFunction = function()
            return vars.showBar ~= false
        end,
        setFunction = function(val)
            vars.showBar = val and true or false
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("COMBAT_ONLY", "Only in combat"),
        tooltip = L("COMBAT_ONLY_TT", ""),
        default = true,
        getFunction = function()
            return vars.combatOnly ~= false
        end,
        setFunction = function(val)
            vars.combatOnly = val and true or false
            Refresh()
        end,
    })

    if LibHarven.ST_COLOR then
        settings:AddSetting({
            type = LibHarven.ST_COLOR,
            label = L("COLOR2", "Color at 2 Crux"),
            tooltip = L("COLOR2_TT", ""),
            default = { 1.00, 0.85, 0.15, 1 },
            getFunction = function()
                return ColorGet(vars.color2, 1.00, 0.85, 0.15, 1)
            end,
            setFunction = function(r, g, b, a)
                if type(vars.color2) ~= "table" then vars.color2 = {} end
                ColorSet(vars.color2, r, g, b, a)
                Refresh()
            end,
        })

        settings:AddSetting({
            type = LibHarven.ST_COLOR,
            label = L("COLOR3", "Color at 3 Crux"),
            tooltip = L("COLOR3_TT", ""),
            default = { 0.95, 0.18, 0.16, 1 },
            getFunction = function()
                return ColorGet(vars.color3, 0.95, 0.18, 0.16, 1)
            end,
            setFunction = function(r, g, b, a)
                if type(vars.color3) ~= "table" then vars.color3 = {} end
                ColorSet(vars.color3, r, g, b, a)
                Refresh()
            end,
        })
    end

    settings:AddSetting({
        type = LibHarven.ST_CHECKBOX,
        label = L("SOUND_ENABLE", "Sound at 3 Crux"),
        tooltip = L("SOUND_ENABLE_TT", ""),
        default = true,
        getFunction = function()
            return vars.soundEnabled ~= false
        end,
        setFunction = function(val)
            vars.soundEnabled = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_DROPDOWN,
        label = L("SOUND_PICK", "Sound"),
        tooltip = L("SOUND_PICK_TT", ""),
        items = SoundItems(),
        default = L("SOUND_KILL", "Killing blow"),
        disable = SoundOff,
        getFunction = function()
            return SoundLabel(vars.soundId or "kill")
        end,
        setFunction = function(_, itemName, itemData)
            local id = itemData and itemData.data or "kill"
            vars.soundId = id
            if T.PlayCue then T.PlayCue() end
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("SOUND_VOL", "Sound volume"),
        tooltip = L("SOUND_VOL_TT", ""),
        min = 0,
        max = 5,
        step = 1,
        default = 2,
        disable = SoundOff,
        getFunction = function()
            return tonumber(vars.soundVolume) or 2
        end,
        setFunction = function(val)
            vars.soundVolume = tonumber(val) or 2
        end,
    })

    if LibHarven.ST_BUTTON then
        settings:AddSetting({
            type = LibHarven.ST_BUTTON,
            label = L("TEST_ALL", "Test all"),
            tooltip = L("TEST_ALL_TT", ""),
            buttonText = L("TEST_BTN", "Preview"),
            clickHandler = function()
                if T.Preview then T.Preview("all") end
            end,
        })
    end

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("SEC_ICONS", "Icons"),
        tooltip = L("SEC_ICONS_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_DROPDOWN,
        label = L("ICON_LAYOUT", "Layout"),
        tooltip = L("ICON_LAYOUT_TT", ""),
        items = LayoutItems(),
        default = L("LAYOUT_TRI", "Triangle around reticle"),
        disable = IconsOff,
        getFunction = function()
            return LayoutLabel(vars.iconLayout or "triangle")
        end,
        setFunction = function(_, itemName, itemData)
            vars.iconLayout = itemData and itemData.data or "triangle"
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_SIZE", "Icon size"),
        tooltip = L("ICON_SIZE_TT", ""),
        min = 24,
        max = 96,
        step = 2,
        default = 30,
        disable = IconsOff,
        getFunction = function()
            return tonumber(vars.iconSize) or 30
        end,
        setFunction = function(val)
            vars.iconSize = tonumber(val) or 30
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_X", "Icons X"),
        tooltip = L("ICON_X_TT", ""),
        min = -800,
        max = 800,
        step = 2,
        default = 0,
        disable = IconsOff,
        getFunction = function()
            return tonumber(vars.iconX) or 0
        end,
        setFunction = function(val)
            vars.iconX = tonumber(val) or 0
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_Y", "Icons Y"),
        tooltip = L("ICON_Y_TT", ""),
        min = -500,
        max = 500,
        step = 2,
        default = 0,
        disable = IconsOff,
        getFunction = function()
            return tonumber(vars.iconY) or 0
        end,
        setFunction = function(val)
            vars.iconY = tonumber(val) or 0
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_A12", "Icon opacity at 1–2"),
        tooltip = L("ICON_A12_TT", ""),
        min = 10,
        max = 100,
        step = 5,
        default = 50,
        disable = IconsOff,
        getFunction = function()
            return tonumber(vars.iconAlpha12) or 50
        end,
        setFunction = function(val)
            vars.iconAlpha12 = tonumber(val) or 50
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_A3", "Icon opacity at 3"),
        tooltip = L("ICON_A3_TT", ""),
        min = 10,
        max = 100,
        step = 5,
        default = 100,
        disable = IconsOff,
        getFunction = function()
            return tonumber(vars.iconAlpha3) or 100
        end,
        setFunction = function(val)
            vars.iconAlpha3 = tonumber(val) or 100
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("ICON_RADIUS", "Distance from center"),
        tooltip = L("ICON_RADIUS_TT", ""),
        min = 24,
        max = 180,
        step = 2,
        default = 50,
        disable = TriangleOff,
        getFunction = function()
            return tonumber(vars.iconRadius) or 50
        end,
        setFunction = function(val)
            vars.iconRadius = tonumber(val) or 50
            Refresh()
        end,
    })

    if LibHarven.ST_BUTTON then
        settings:AddSetting({
            type = LibHarven.ST_BUTTON,
            label = L("TEST_ICONS", "Test icons"),
            tooltip = L("TEST_ICONS_TT", ""),
            buttonText = L("TEST_BTN", "Preview"),
            disable = IconsOff,
            clickHandler = function()
                if T.Preview then T.Preview("icons") end
            end,
        })
    end

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("SEC_NUMBER", "Number"),
        tooltip = L("SEC_NUMBER_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("NUM_SIZE", "Number size"),
        tooltip = L("NUM_SIZE_TT", ""),
        min = 18,
        max = 96,
        step = 2,
        default = 42,
        disable = NumberOff,
        getFunction = function()
            return tonumber(vars.numberSize) or 42
        end,
        setFunction = function(val)
            vars.numberSize = tonumber(val) or 42
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("NUM_A12", "Number opacity at 1–2"),
        tooltip = L("NUM_A12_TT", ""),
        min = 10,
        max = 100,
        step = 5,
        default = 50,
        disable = NumberOff,
        getFunction = function()
            return tonumber(vars.numAlpha12) or 50
        end,
        setFunction = function(val)
            vars.numAlpha12 = tonumber(val) or 50
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("NUM_A3", "Number opacity at 3"),
        tooltip = L("NUM_A3_TT", ""),
        min = 10,
        max = 100,
        step = 5,
        default = 100,
        disable = NumberOff,
        getFunction = function()
            return tonumber(vars.numAlpha3) or 100
        end,
        setFunction = function(val)
            vars.numAlpha3 = tonumber(val) or 100
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("NUM_X", "Number X"),
        tooltip = L("NUM_X_TT", ""),
        min = -800,
        max = 800,
        step = 2,
        default = 0,
        disable = NumberOff,
        getFunction = function()
            return tonumber(vars.numberX) or 0
        end,
        setFunction = function(val)
            vars.numberX = tonumber(val) or 0
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("NUM_Y", "Number Y"),
        tooltip = L("NUM_Y_TT", ""),
        min = -500,
        max = 500,
        step = 2,
        default = 0,
        disable = NumberOff,
        getFunction = function()
            return tonumber(vars.numberY) or 0
        end,
        setFunction = function(val)
            vars.numberY = tonumber(val) or 0
            Refresh()
        end,
    })

    if LibHarven.ST_BUTTON then
        settings:AddSetting({
            type = LibHarven.ST_BUTTON,
            label = L("TEST_NUMBER", "Test number"),
            tooltip = L("TEST_NUMBER_TT", ""),
            buttonText = L("TEST_BTN", "Preview"),
            disable = NumberOff,
            clickHandler = function()
                if T.Preview then T.Preview("number") end
            end,
        })
    end

    settings:AddSetting({
        type = LibHarven.ST_SECTION,
        label = L("SEC_BAR", "Action bar"),
        tooltip = L("SEC_BAR_TT", ""),
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("BAR_A2", "Bar opacity at 2 Crux"),
        tooltip = L("BAR_A2_TT", ""),
        min = 10,
        max = 90,
        step = 5,
        default = 20,
        disable = BarOff,
        getFunction = function()
            return tonumber(vars.barAlpha2) or 20
        end,
        setFunction = function(val)
            vars.barAlpha2 = tonumber(val) or 20
            Refresh()
        end,
    })

    settings:AddSetting({
        type = LibHarven.ST_SLIDER,
        label = L("BAR_A3", "Bar opacity at 3 Crux"),
        tooltip = L("BAR_A3_TT", ""),
        min = 10,
        max = 90,
        step = 5,
        default = 40,
        disable = BarOff,
        getFunction = function()
            return tonumber(vars.barAlpha3) or 40
        end,
        setFunction = function(val)
            vars.barAlpha3 = tonumber(val) or 40
            Refresh()
        end,
    })

    if LibHarven.ST_BUTTON then
        settings:AddSetting({
            type = LibHarven.ST_BUTTON,
            label = L("TEST_BAR", "Test bar color"),
            tooltip = L("TEST_BAR_TT", ""),
            buttonText = L("TEST_BTN", "Preview"),
            disable = BarOff,
            clickHandler = function()
                if T.Preview then T.Preview("bar") end
            end,
        })
    end
end
