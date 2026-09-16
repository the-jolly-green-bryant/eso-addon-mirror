-- Common Works — settings (LibAddonMenu-2.0)
-- LibAddonMenu is a hard dependency, so it is here whenever this file runs.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

-- Tab: Quest Tracker — the panel itself, plus appearance.
-- LAM wants a picker's default as {r=,g=,b=,a=}; the rest of the addon stores {r,g,b,a}.
-- Use the default palette so LAM resets to the default theme.
local function PickerDefault(key)
    local c = CW.GetPaletteColor(CW.DEFAULT_PALETTE, key)
    return { r = c[1], g = c[2], b = c[3], a = c[4] }
end

local function ThemeColor(key, name, tooltip)
    return {
        type    = "colorpicker",
        name    = name,
        tooltip = tooltip,
        getFunc = function() return unpack(CW.SavedVars.appearance[key]) end,
        setFunc = function(r, g, b, a)
            CW.SavedVars.appearance[key] = { r, g, b, a }; CW.UI.SyncTheme()
        end,
        default = PickerDefault(key),
    }
end

local Underlined = function() return CW.SavedVars.appearance.dividerUnderline == true end

-- Saved-variable color picker; CW.defaults supplies the reset color.
local function ColorOption(name, key, off, apply, tooltip)
    local c = CW.defaults[key]
    return {
        type    = "colorpicker",
        name    = name,
        tooltip = tooltip,
        getFunc = function() return unpack(CW.SavedVars[key]) end,
        setFunc = function(r, g, b, a)
            CW.SavedVars[key] = { r, g, b, a }
            apply()
        end,
        disabled = off,
        default  = { r = c[1], g = c[2], b = c[3], a = c[4] },
    }
end

-- Sound pickers preview each choice; volume is a repeat count, not gain.
local ALERT_VOLUME_TIP = "Set to 0 to mute the sound. If higher values make no difference, try a shorter sound."

local function SoundOption(name, key, off, play, tooltip)
    return {
        type          = "dropdown",
        name          = name,
        tooltip       = tooltip,
        choices       = CW.SOUND_NAMES,
        choicesValues = CW.SOUND_KEYS,
        getFunc  = function() return CW.SavedVars[key] end,
        setFunc  = function(v) CW.SavedVars[key] = v; play() end,
        disabled = off,
        default  = CW.defaults[key],
    }
end

local function VolumeOption(name, key, off, play, tooltip, max)
    return {
        type     = "slider",
        name     = name,
        tooltip  = tooltip or ALERT_VOLUME_TIP,
        min      = 0, max = max or 10, step = 1,
        getFunc  = function() return CW.SavedVars[key] end,
        setFunc  = function(v) CW.SavedVars[key] = v; play() end,
        disabled = off,
        default  = CW.defaults[key],
    }
end

-- Font face and size controls; default range 14-72, with repaint on change.
local function FontFaceOption(name, prefix, off, apply)
    return {
        type     = "dropdown",
        name     = name,
        choices  = CW.UI.FONT_NAMES,
        getFunc  = function() return CW.SavedVars[prefix .. "FontFace"] end,
        setFunc  = function(v) CW.SavedVars[prefix .. "FontFace"] = v; apply() end,
        disabled = off,
        default  = CW.defaults[prefix .. "FontFace"],
    }
end

local function FontSizeOption(name, prefix, off, apply, tooltip, min, max)
    return {
        type     = "slider",
        name     = name,
        tooltip  = tooltip,
        min      = min or 14, max = max or 72, step = 1,
        getFunc  = function() return CW.SavedVars[prefix .. "FontSize"] end,
        setFunc  = function(v) CW.SavedVars[prefix .. "FontSize"] = v; apply() end,
        disabled = off,
        default  = CW.defaults[prefix .. "FontSize"],
    }
end

local function BlastbonesOff() return CW.SavedVars.blastbonesEnabled ~= true end
local function CcImmunityOff() return CW.SavedVars.ccImmunityEnabled ~= true end
local function ChatAlertsOff() return CW.SavedVars.chatAlerts ~= true end
local function IncomingAlertOff() return CW.SavedVars.incomingAlertEnabled ~= true end
local function GcdAlertOff() return CW.SavedVars.gcdAlertEnabled ~= true end
local function HealthAlertOff() return CW.SavedVars.healthAlertEnabled ~= true end
local function LaHitSoundOff() return CW.SavedVars.laHitSound ~= true end
local function LaStatsOff() return CW.SavedVars.laStats ~= true end
local function LoreBookPinsOff() return CW.SavedVars.loreBookPins ~= true end
local function LtBuildOff() return CW.SavedVars.ltBuildDisplay ~= true end
local function LtBuildSetsOff() return LtBuildOff() or CW.SavedVars.ltBuildSets == false end
local function NegateAlertOff() return CW.SavedVars.negateAlertEnabled ~= true end
local function OffBalanceOff() return CW.SavedVars.showOffBalanceTracker ~= true end
local function PoisonAlertOff() return CW.SavedVars.ltPoisonAlert ~= true end
-- The icon defaults on, so an absent key is not "off".
local function MountSprintIconOff() return CW.SavedVars.showMountSprintIcon == false end
local function LaFlashOff() return LaStatsOff() or CW.SavedVars.laStatsFlash ~= true end

-- One checkbox per ability group, including morphs (e.g. Glory and Oppression).
-- Keep rows flat: the tabbed shell fixes their positions at build time,
-- so expanding a LAM submenu would overlap the rows below.
local incomingAlertsByKey = {}
for _, entry in ipairs(CW.INCOMING_ALERTS) do incomingAlertsByKey[entry.key] = entry end

local function IncomingAlertOption(key)
    local entry = incomingAlertsByKey[key]
    return {
        type     = "checkbox",
        name     = entry.name,
        tooltip  = "Warn when " .. entry.name .. " or one of its morphs damages you.",
        getFunc  = function() return CW.SavedVars[entry.sv] == true end,
        setFunc  = function(v)
            CW.SavedVars[entry.sv] = v
            CW.UpdateIncomingAlertTracking()
        end,
        disabled = IncomingAlertOff,
        default  = CW.defaults[entry.sv],
    }
end


local function QuestTrackerTab()
    return {
        {
            type    = "slider",
            name    = "Background opacity",
            min     = 0, max = 100, step = 5,
            getFunc = function() return zo_round(CW.SavedVars.backdropAlpha * 100) end,
            setFunc = function(v)
                CW.SavedVars.backdropAlpha = v / 100
                CW.UI.SyncBackdrop()
            end,
            default = CW.defaults.backdropAlpha * 100,
        },
        {
            type    = "checkbox",
            name    = "Hide in combat",
            getFunc = function() return CW.SavedVars.stowInCombat end,
            setFunc = function(v)
                CW.SavedVars.stowInCombat = v
                CW.inCombat = IsUnitInCombat("player")
                CW.SyncVisibility()
            end,
            default = CW.defaults.stowInCombat,
        },
        {
            type    = "checkbox",
            name    = "Hide quest tracker in instances",
            tooltip = "Hide quests, dailies, pledges and Tomes in group dungeons, trials, Infinite Archive and Battlegrounds. Activity and queue information stays visible.",
            getFunc = function() return CW.SavedVars.hideQuestTrackerInInstances == true end,
            setFunc = function(v)
                CW.SavedVars.hideQuestTrackerInInstances = v
                CW.UI.Redraw()
            end,
            default = CW.defaults.hideQuestTrackerInInstances,
        },
        {
            type     = "checkbox",
            name     = "Show active quest while hidden",
            tooltip  = "Keep your assisted quest visible when hiding quest sections in instances.",
            getFunc  = function() return CW.SavedVars.showActiveQuestInInstances ~= false end,
            setFunc  = function(v)
                CW.SavedVars.showActiveQuestInInstances = v
                CW.UI.Redraw()
            end,
            disabled = function() return CW.SavedVars.hideQuestTrackerInInstances ~= true end,
            default  = CW.defaults.showActiveQuestInInstances,
        },
        {
            type    = "checkbox",
            name    = "Auto-claim Tome Points",
            tooltip = "Claim completed Tome challenges automatically and show the points earned for five minutes.",
            getFunc = function() return CW.SavedVars.autoClaimTomePoints == true end,
            setFunc = function(v)
                CW.SavedVars.autoClaimTomePoints = v
                if v then CW.AutoClaimTomePoints() end
            end,
            default = CW.defaults.autoClaimTomePoints,
        },
        {
            type    = "checkbox",
            name    = "Lock panel position",
            getFunc = function() return CW.SavedVars.pinned end,
            setFunc = function(v)
                CW.SavedVars.pinned = v
                CW.UI.SyncLock()
            end,
            default = CW.defaults.pinned,
        },

        { type = "header", name = "Appearance" },
        {
            type    = "dropdown",
            name    = "Color theme",
            tooltip = "Apply the theme's colors to the whole panel, replacing your individual color choices.",
            choices = CW.PALETTE_NAMES,
            getFunc = function() return CW.GetPaletteLabel(CW.SavedVars.appearance.preset) end,
            setFunc = function(label)
                CW.ApplyPreset(CW.GetPaletteIdByLabel(label))
                CW.UI.SyncTheme()
                -- Theme changes must refresh the individual color pickers.
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", CW.settingsPanel)
            end,
            default = CW.GetPaletteLabel(CW.DEFAULT_PALETTE),
        },
        {
            type    = "dropdown",
            name    = "Font",
            choices = CW.UI.FONT_NAMES,
            getFunc = function() return CW.SavedVars.appearance.typeface end,
            setFunc = function(v) CW.SavedVars.appearance.typeface = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.typeface,
        },
        {
            type    = "dropdown",
            name    = "Font style",
            tooltip = "Set the text shadow to improve readability against bright backgrounds.",
            -- No outline: the client draws none on the bundled DM Sans .slug fonts.
            choices       = { "Normal", "Soft shadow (thin)", "Soft shadow (thick)", "Shadow" },
            choicesValues = { "", "soft-shadow-thin", "soft-shadow-thick", "shadow" },
            getFunc = function() return CW.SavedVars.appearance.fontStyle end,
            setFunc = function(v) CW.SavedVars.appearance.fontStyle = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.fontStyle,
        },
        {
            type    = "slider",
            name    = "Header size",
            tooltip = "Size of quest titles, section headings and the activity queue.",
            min     = 14, max = 28, step = 1,
            getFunc = function() return CW.SavedVars.appearance.pt.title end,
            setFunc = function(v) CW.SavedVars.appearance.pt.title = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.pt.title,
        },
        {
            type    = "slider",
            name    = "Objective / row size",
            min     = 12, max = 24, step = 1,
            getFunc = function() return CW.SavedVars.appearance.pt.body end,
            setFunc = function(v) CW.SavedVars.appearance.pt.body = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.pt.body,
        },
        {
            type    = "slider",
            name    = "Panel width",
            min     = 300, max = 560, step = 20,
            getFunc = function() return CW.SavedVars.appearance.panelWidth end,
            setFunc = function(v) CW.SavedVars.appearance.panelWidth = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.panelWidth,
        },
        {
            type    = "slider",
            name    = "Divider height",
            tooltip = "Thickness of header dividers or underlines; 0 hides them.",
            min     = 0, max = 10, step = 1,
            getFunc = function() return CW.SavedVars.appearance.dividerHeight end,
            setFunc = function(v) CW.SavedVars.appearance.dividerHeight = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.dividerHeight,
        },
        {
            type    = "slider",
            name    = "Divider width",
            tooltip = "Width of dividers as a percentage of the panel width. Values above 100% extend past both edges.",
            min     = 10, max = 120, step = 5,
            getFunc = function() return CW.SavedVars.appearance.dividerWidthPct end,
            setFunc = function(v) CW.SavedVars.appearance.dividerWidthPct = v; CW.UI.SyncTheme() end,
            disabled = Underlined,
            default = CW.defaults.appearance.dividerWidthPct,
        },
        {
            type    = "checkbox",
            name    = "Underline headers",
            tooltip = "Draw dividers under header text instead of above each section.",
            getFunc = Underlined,
            setFunc = function(v) CW.SavedVars.appearance.dividerUnderline = v; CW.UI.SyncTheme() end,
            default = CW.defaults.appearance.dividerUnderline,
        },
        ThemeColor("headerColor", "Header color",
            "Color of the Zone Guide label and PvP scroll flags."),
        ThemeColor("activeTitleColor", "Title color",
            "Color of quest titles, PvP keep rows and the Zone Guide headline."),
        ThemeColor("activeObjColor", "Objective color", "Every objective row, in every section."),
        ThemeColor("activeDoneColor", "Completed color", "Color of completed objectives and checkmarks."),
        ThemeColor("activeCountColor", "Counter color",
            "Color of progress counts and the activity queue status."),
        ThemeColor("trackedTomeHeaderColor", "Tracked & Tomes title color",
            "The Tracked Quests header and both Tome sub-headers."),
        ThemeColor("dividerColor", "Divider color", "Color of header dividers and underlines."),
    }
end

-- Blastbones controls share the GCD Alerts page.
local function BlastbonesOptions()
    return {
        {
            type    = "checkbox",
            name    = "Blastbones rhythm tones",
            tooltip = "Play rhythm tones when Blighted Blastbones spawns and at two delays afterward.",
            getFunc = function() return CW.SavedVars.blastbonesEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.blastbonesEnabled = v
                CW.UpdateBlastbonesTracking()
            end,
            default = CW.defaults.blastbonesEnabled,
        },
        SoundOption("Tone 0 sound (on summon)", "blastbonesSound0", BlastbonesOff, function() CW.PreviewBlastbonesTone(0) end,
            "Sound played when the skeleton spawns. Selecting one plays a preview."),
        VolumeOption("Tone 0 volume (on summon)", "blastbonesVolume0", BlastbonesOff, function() CW.PreviewBlastbonesTone(0) end,
            nil, 20),
        SoundOption("Tone 1 sound", "blastbonesSound1", BlastbonesOff, function() CW.PreviewBlastbonesTone(1) end,
            "First tone after the summon. Selecting one plays a preview."),
        VolumeOption("Tone 1 volume", "blastbonesVolume1", BlastbonesOff, function() CW.PreviewBlastbonesTone(1) end,
            nil, 20),
        {
            type     = "slider",
            name     = "Tone 1 delay (seconds)",
            tooltip  = "Seconds after the skeleton spawns before the first tone plays.",
            min      = 0.2, max = 3.0, step = 0.1,
            decimals = 1,
            getFunc  = function()
                return CW.SavedVars.blastbonesDelay1 / 1000
            end,
            setFunc  = function(v) CW.SavedVars.blastbonesDelay1 = v * 1000 end,
            disabled = BlastbonesOff,
            default  = CW.defaults.blastbonesDelay1 / 1000,
        },
        SoundOption("Tone 2 sound", "blastbonesSound2", BlastbonesOff, function() CW.PreviewBlastbonesTone(2) end,
            "Second tone after the summon. Selecting one plays a preview."),
        VolumeOption("Tone 2 volume", "blastbonesVolume2", BlastbonesOff, function() CW.PreviewBlastbonesTone(2) end,
            nil, 20),
        {
            type     = "slider",
            name     = "Tone 2 delay (seconds)",
            tooltip  = "Seconds after the skeleton spawns before the second tone plays.",
            min      = 0.2, max = 5.0, step = 0.1,
            decimals = 1,
            getFunc  = function()
                return CW.SavedVars.blastbonesDelay2 / 1000
            end,
            setFunc  = function(v) CW.SavedVars.blastbonesDelay2 = v * 1000 end,
            disabled = BlastbonesOff,
            default  = CW.defaults.blastbonesDelay2 / 1000,
        },
        {
            type    = "button",
            name    = "Test tones",
            tooltip = "Preview all three tones with the selected volumes and delays.",
            func    = function()
                CW.FireBlastbonesTones()
            end,
            disabled = BlastbonesOff,
            width   = "half",
        },
    }
end

-- Tab: GCD Alerts — "you can cast again" warnings, per ability.
-- LAM has no repeater; "Watched ability" binds widgets to the runtime CW.gcdAlertEditIndex.

-- LAM captures choices by reference: refill in place and rebuild dropdown items.
-- UpdateValue alone does not re-read choices.
local function RefreshGcdControls()
    CW.RefreshGcdBarChoices()
    CW.RefreshGcdEntryChoices()
    if CW_GcdBarDropdown and CW_GcdBarDropdown.UpdateChoices then
        CW_GcdBarDropdown:UpdateChoices()
    end
    if CW_GcdEntryDropdown and CW_GcdEntryDropdown.UpdateChoices then
        CW_GcdEntryDropdown:UpdateChoices()
    end
    if CW.settingsPanel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", CW.settingsPanel)
    end
end
CW.RefreshGcdSettings = RefreshGcdControls

local function AddGcdAndReport(abilityId)
    local index, reason = CW.AddGcdAlert(abilityId)
    if index then
        CW.gcdAlertEditIndex = index
        RefreshGcdControls()
        local name = CW.GcdAbilityName(abilityId)
        d(string.format(CW.BRAND .. " GCD alert %s: %s (%d)",
            reason == "already watched" and "already watching" or "now watching",
            name ~= "" and name or "unnamed ability", abilityId))
    else
        d(CW.BRAND .. " GCD alert not added: " .. tostring(reason))
    end
end

-- LAM calls getFunc even on disabled controls; handle nil.
local function GcdEditorDisabled()
    return CW.SavedVars.gcdAlertEnabled ~= true or CW.CurrentGcdAlert() == nil
end

local function GcdEntryKind()
    local e = CW.CurrentGcdAlert()
    return e and (e.kind or "gcd") or "gcd"
end

-- The ON/OFF colors mean nothing unless a toggle check is running for the ability.
local function GcdToggleColorDisabled()
    if GcdEditorDisabled() then return true end
    local e = CW.CurrentGcdAlert()
    return (e and e.toggle or "none") == "none"
end

-- Cast and expire controls share a groupset slot; only one applies to each entry.
local function GcdCastOptions()
    return {
        {
            type     = "editbox",
            name     = "Alert text",
            tooltip  = "Text shown when the global cooldown ends; leave blank to use the ability name.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e and e.text or ""
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.text = zo_strtrim(v or "")
            end,
            isMultiline = false,
            disabled = GcdEditorDisabled,
            default  = "",
        },
        {
            type     = "dropdown",
            name     = "Toggle suffix (ON / OFF)",
            tooltip  = "Add ON or OFF to toggle alerts based on the action bar or a buff on you. Automatic chooses the check for known toggles.",
            choices       = CW.GCD_TOGGLE_MODE_NAMES,
            choicesValues = CW.GCD_TOGGLE_MODES,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return (e and e.toggle) or "none"
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.toggle = v
            end,
            disabled = GcdEditorDisabled,
            default  = "none",
        },
        {
            type     = "editbox",
            name     = "Buff ID (optional)",
            tooltip  = "Enter the buff's effect ID if ON/OFF is wrong. Leave blank to use the built-in ID.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return (e and e.toggleEffectId) and tostring(e.toggleEffectId) or ""
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                local n = tonumber(tostring(v or ""):match("%d+") or "")
                e.toggleEffectId = (n and n > 0) and n or nil
            end,
            isMultiline = false,
            disabled = function()
                if GcdEditorDisabled() then return true end
                local e = CW.CurrentGcdAlert()
                local mode = (e and e.toggle) or "none"
                if mode == "auto" then
                    mode = CW.GCD_TOGGLE_BARS[e.id] and "bar" or "buff"
                end
                return mode ~= "buff"
            end,
            default  = "",
        },
        {
            type     = "colorpicker",
            name     = "Text color",
            tooltip  = "Text color when no toggle suffix is used.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                local c = (e and e.color) or CW.defaults.gcdAlertColor
                return c[1], c[2], c[3], c[4]
            end,
            setFunc  = function(r, g, b, a)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.color = { r, g, b, a or 1 }
                CW.UI.gcdAlertColor = nil
                CW.UI.ApplyGcdAlertStyle()
                CW.UI.ApplyGcdAlertVisibility()
            end,
            disabled = GcdEditorDisabled,
            default  = { r = 0.35, g = 1.00, b = 0.45, a = 1.00 },
        },
        {
            type     = "colorpicker",
            name     = "Color when ON",
            tooltip  = "Text color when the toggle is ON.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                local c = (e and e.colorOn) or CW.defaults.gcdAlertColorOn
                return c[1], c[2], c[3], c[4]
            end,
            setFunc  = function(r, g, b, a)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.colorOn = { r, g, b, a or 1 }
                CW.UI.gcdAlertColor = nil
                CW.UI.ApplyGcdAlertStyle()
                CW.UI.ApplyGcdAlertVisibility()
            end,
            disabled = GcdToggleColorDisabled,
            default  = { r = 0.35, g = 1.00, b = 0.45, a = 1.00 },
        },
        {
            type     = "colorpicker",
            name     = "Color when OFF",
            tooltip  = "Text color when the toggle is OFF.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                local c = (e and e.colorOff) or CW.defaults.gcdAlertColorOff
                return c[1], c[2], c[3], c[4]
            end,
            setFunc  = function(r, g, b, a)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.colorOff = { r, g, b, a or 1 }
                CW.UI.gcdAlertColor = nil
                CW.UI.ApplyGcdAlertStyle()
                CW.UI.ApplyGcdAlertVisibility()
            end,
            disabled = GcdToggleColorDisabled,
            default  = { r = 1.00, g = 0.42, b = 0.35, a = 1.00 },
        },
    }
end

local function ExpireOptions()
    return {
        {
            type     = "slider",
            name     = "Lead time (s)",
            tooltip  = "Start the reminder this many seconds before the buff expires; 0 warns only when it expires.",
            min      = 0,
            max      = 5,
            step     = 0.5,
            decimals = 1,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e and e.leadSeconds or 3
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.leadSeconds = v end
            end,
            disabled = GcdEditorDisabled,
            default  = 3,
        },
        {
            type     = "slider",
            name     = "Hold after expiry (s)",
            tooltip  = "Keep the icon visible for this many seconds after the buff expires.",
            min      = 1,
            max      = 3,
            step     = 0.5,
            decimals = 1,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e and e.holdSeconds or 1
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.holdSeconds = v end
            end,
            disabled = GcdEditorDisabled,
            default  = 1,
        },
        {
            type     = "checkbox",
            name     = "Annoying reminder",
            tooltip  = "In combat, keep blinking after the hold time until you recast the ability or leave combat.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e ~= nil and e.annoying == true
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.annoying = v end
            end,
            disabled = GcdEditorDisabled,
            default  = false,
        },
        {
            type     = "slider",
            name     = "Icon scale (%)",
            tooltip  = "Size of this ability's icon as a percentage of the shared icon size.",
            min      = 50,
            max      = 250,
            step     = 10,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return zo_round((e and e.iconScale or 1) * 100)
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.iconScale = v / 100 end
            end,
            disabled = GcdEditorDisabled,
            default  = 100,
        },
        {
            type     = "checkbox",
            name     = "Show icon when expiring",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e ~= nil and e.showIcon ~= false
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.showIcon = v end
            end,
            disabled = GcdEditorDisabled,
            default  = true,
        },
        {
            type     = "checkbox",
            name     = "Show timer when expiring",
            tooltip  = "Show the countdown number under the icon.",
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return e ~= nil and e.showTimer ~= false
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if e then e.showTimer = v end
            end,
            disabled = GcdEditorDisabled,
            default  = true,
        },
    }
end

local function GcdAlertTab()
    local options = {
        {
            type = "description",
            text = "Get alerts when the global cooldown ends or a buff you applied is about to expire. Drag the alerts to position them while this tab is open.",
        },
        {
            type    = "checkbox",
            name    = "Enable GCD alerts",
            tooltip = "Enable alerts for the abilities in your watch list.",
            getFunc = function() return CW.SavedVars.gcdAlertEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.gcdAlertEnabled = v
                CW.UpdateGcdAlertTracking()
                if not v then CW.ClearGcdAlert() end
                CW.UI.ApplyGcdAlertStyle()
                local open = CW.UI.SettingsPanelOpen()
                CW.UI.SetGcdAlertPlacementMode(v == true and open == true)
            end,
            default = CW.defaults.gcdAlertEnabled,
        },

        { type = "header", name = "Add an ability" },
        {
            type      = "dropdown",
            reference = "CW_GcdBarDropdown",
            name      = "From your bars",
            tooltip   = "Choose an ability from either action bar, including ultimates. Reopen settings to refresh the list.",
            choices       = CW.GCD_BAR_CHOICE_NAMES,
            choicesValues = CW.GCD_BAR_CHOICE_IDS,
            getFunc  = function() return CW.gcdStagedBarId end,
            setFunc  = function(v) CW.gcdStagedBarId = v end,
            width    = "half",
        },
        {
            type    = "button",
            name    = "Add selected",
            tooltip = "Start watching the ability picked above.",
            func    = function()
                if CW.gcdStagedBarId then
                    AddGcdAndReport(CW.gcdStagedBarId)
                else
                    d(CW.BRAND .. " GCD alert: pick an ability from the list first.")
                end
            end,
            width   = "half",
        },
        {
            type     = "editbox",
            name     = "...or an ability ID",
            tooltip  = "Enter an ability ID to watch a skill that isn't on your bars.",
            getFunc  = function() return CW.gcdStagedIdText or "" end,
            setFunc  = function(v) CW.gcdStagedIdText = zo_strtrim(v or "") end,
            isMultiline = false,
            width    = "half",
        },
        {
            type    = "button",
            name    = "Add ID",
            tooltip = "Start watching the ability ID typed above.",
            func    = function()
                AddGcdAndReport(tonumber(CW.gcdStagedIdText or ""))
            end,
            width   = "half",
        },

        { type = "header", name = "Configure a watched ability" },
        {
            type      = "dropdown",
            reference = "CW_GcdEntryDropdown",
            name      = "Watched ability",
            tooltip   = "Choose which ability to edit; each has its own alert settings.",
            choices       = CW.GCD_ENTRY_CHOICE_NAMES,
            choicesValues = CW.GCD_ENTRY_CHOICE_INDEXES,
            getFunc  = function() return CW.gcdAlertEditIndex end,
            setFunc  = function(v)
                CW.gcdAlertEditIndex = v
                if CW.settingsPanel then
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", CW.settingsPanel)
                end
            end,
        },
        {
            type    = "checkbox",
            name    = "Glow when usable",
            tooltip = "Highlight this ability on the action bar when it is usable, even if its alert type is Off.",
            getFunc = function()
                local e = CW.CurrentGcdAlert()
                return e ~= nil and e.glow == true
            end,
            setFunc = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.glow = v
                CW.UpdateAbilityGlow()
            end,
            disabled = function() return CW.CurrentGcdAlert() == nil end,
            default  = false,
        },
        {
            type      = "dropdown",
            name      = "Alert type",
            tooltip   = "Choose a GCD alert, a buff expiry reminder, or Off to disable this ability's alerts.",
            choices       = { "Off", "GCD", "Expiring" },
            choicesValues = { "off", "gcd", "expire" },
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                if not e then return "gcd" end
                if e.enabled == false then return "off" end
                return (e.kind or "gcd") == "expire" and "expire" or "gcd"
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                if v == "off" then
                    e.enabled = false
                else
                    e.enabled = true
                    if v == "expire" and (e.kind or "gcd") ~= "expire" then
                        e.volume = 0   -- Expiry reminders default to a visual cue.
                    end
                    e.kind = v
                end
                CW.UpdateGcdAlertTracking()
                RefreshGcdControls()
            end,
            disabled = GcdAlertOff,
            default  = "gcd",
        },
        -- Reserve the taller group's height to keep later controls fixed.
        {
            type    = "groupset",
            key     = "gcdAlertKind",
            getFunc = GcdEntryKind,
            groups  = {
                { key = "gcd",    options = GcdCastOptions() },
                { key = "expire", options = ExpireOptions() },
            },
        },
        {
            type     = "dropdown",
            name     = "Sound",
            tooltip  = "Selecting a sound plays a preview.",
            choices       = CW.SOUND_NAMES,
            choicesValues = CW.SOUND_KEYS,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return (e and e.sound) or CW.defaults.healthAlertSound
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.sound = v
                CW.PlayGcdAlertSound(CW.gcdAlertEditIndex)
            end,
            disabled = GcdEditorDisabled,
            default  = "DUEL_START",
        },
        {
            type     = "slider",
            name     = "Volume",
            tooltip  = ALERT_VOLUME_TIP,
            min      = 0,
            max      = 10,
            step     = 1,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return (e and e.volume) or 0
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.volume = v
                CW.PlayGcdAlertSound(CW.gcdAlertEditIndex)
            end,
            disabled = GcdEditorDisabled,
            default  = 3,
        },
        {
            type     = "slider",
            name     = "On-screen time (s)",
            tooltip  = "How long the text stays visible; 0 plays only the sound.",
            min      = 0,
            max      = 3,
            step     = 0.1,
            decimals = 1,
            getFunc  = function()
                local e = CW.CurrentGcdAlert()
                return ((e and e.duration) or 0) / 1000
            end,
            setFunc  = function(v)
                local e = CW.CurrentGcdAlert()
                if not e then return end
                e.duration = v * 1000
            end,
            disabled = GcdEditorDisabled,
            default  = 0.8,
        },
        {
            type    = "button",
            name    = "Test alert",
            tooltip = "Preview this ability's alert.",
            func    = function()
                local e = CW.CurrentGcdAlert()
                if e and (e.kind or "gcd") == "expire" then
                    CW.TestExpireReminder(CW.gcdAlertEditIndex)
                else
                    CW.FireGcdAlert(CW.gcdAlertEditIndex)
                end
            end,
            disabled = GcdEditorDisabled,
            width   = "half",
        },
        {
            type      = "button",
            name      = "Stop watching this ability",
            tooltip   = "Remove this ability and its settings from the watch list.",
            isDangerous = true,
            warning   = "This removes the ability and its settings from the watch list.",
            func      = function()
                local index = CW.gcdAlertEditIndex
                if CW.RemoveGcdAlert(index) then
                    RefreshGcdControls()
                end
            end,
            disabled  = GcdEditorDisabled,
            width     = "half",
        },

        { type = "header", name = "Appearance and timing (shared by every alert)" },
        FontFaceOption("Font", "gcdAlert", GcdAlertOff, CW.UI.ApplyGcdAlertStyle),
        FontSizeOption("Font size", "gcdAlert", GcdAlertOff, CW.UI.ApplyGcdAlertStyle),
        FontFaceOption("Expire timer font", "expireReminder", GcdAlertOff, CW.UI.ApplyExpireReminderStyle),
        FontSizeOption("Expire timer size", "expireReminder", GcdAlertOff, CW.UI.ApplyExpireReminderStyle),
        {
            type     = "slider",
            name     = "Expire icon size",
            tooltip  = "Base size for buff expiry icons.",
            min      = 16,
            max      = 128,
            step     = 2,
            getFunc  = function() return CW.SavedVars.expireReminderIconSize end,
            setFunc  = function(v)
                CW.SavedVars.expireReminderIconSize = v
                CW.UI.ApplyExpireReminderStyle()
            end,
            disabled = GcdAlertOff,
            default  = CW.defaults.expireReminderIconSize,
        },
        {
            type     = "slider",
            name     = "Give up after (s)",
            tooltip  = "Cancel the pending GCD alert if the cooldown hasn't ended within this many seconds.",
            min      = 0.5,
            max      = 5,
            step     = 0.1,
            decimals = 1,
            getFunc  = function()
                return CW.SavedVars.gcdAlertMaxWaitMs / 1000
            end,
            setFunc  = function(v) CW.SavedVars.gcdAlertMaxWaitMs = v * 1000 end,
            disabled = GcdAlertOff,
            default  = CW.defaults.gcdAlertMaxWaitMs / 1000,
        },
    }

    options[#options + 1] = { type = "header", name = "Blastbones" }
    for _, o in ipairs(BlastbonesOptions()) do options[#options + 1] = o end

    return options
end

-- Tab: Alerts — on-screen combat warnings.
local function AlertTab()
    return {

        { type = "header", name = "Low Health Alert" },
        {
            type    = "checkbox",
            name    = "Low health alert",
            tooltip = "Show a warning and play a sound when your health is at or below the threshold. Drag the warning to move it while this tab is open.",
            getFunc = function() return CW.SavedVars.healthAlertEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.healthAlertEnabled = v
                CW.UpdateHealthAlertTracking()
                CW.UI.ApplyHealthAlertStyle()
                local open = CW.UI.SettingsPanelOpen()
                CW.UI.SetHealthAlertPlacementMode(v == true and open == true)
            end,
            default = CW.defaults.healthAlertEnabled,
        },
        {
            type     = "editbox",
            name     = "Alert text",
            tooltip  = "Warning text; leave blank to use LOW HEALTH.",
            getFunc  = function() return CW.SavedVars.healthAlertText end,
            setFunc  = function(v)
                CW.SavedVars.healthAlertText = zo_strtrim(v or "")
                CW.UI.ApplyHealthAlertText()
            end,
            isMultiline = false,
            disabled = HealthAlertOff,
            default  = CW.defaults.healthAlertText,
        },
        {
            type     = "slider",
            name     = "Health threshold",
            tooltip  = "Warn at or below this percentage of maximum health.",
            min      = 5, max = 50, step = 1,
            getFunc  = function() return CW.SavedVars.healthAlertThreshold end,
            setFunc  = function(v) CW.SavedVars.healthAlertThreshold = v end,
            disabled = HealthAlertOff,
            default  = CW.defaults.healthAlertThreshold,
        },
        FontFaceOption("Health alert font", "healthAlert", HealthAlertOff, CW.UI.ApplyHealthAlertStyle),
        FontSizeOption("Health alert font size", "healthAlert", HealthAlertOff, CW.UI.ApplyHealthAlertStyle),
        ColorOption("Health alert color", "healthAlertColor", HealthAlertOff, CW.UI.ApplyHealthAlertStyle),
        {
            type     = "slider",
            name     = "Display time (ms)",
            tooltip  = "How long the warning stays visible; 0 plays only the sound.",
            min      = 0, max = 2000, step = 50,
            getFunc  = function() return CW.SavedVars.healthAlertDuration end,
            setFunc  = function(v) CW.SavedVars.healthAlertDuration = v end,
            disabled = HealthAlertOff,
            default  = CW.defaults.healthAlertDuration,
        },
        {
            type     = "slider",
            name     = "Repeat delay (seconds)",
            tooltip  = "Minimum time between warnings while health stays low; 0 warns on every health update.",
            min      = 0, max = 5, step = 0.5,
            decimals = 1,
            getFunc  = function()
                return CW.SavedVars.healthAlertCooldown / 1000
            end,
            setFunc  = function(v) CW.SavedVars.healthAlertCooldown = v * 1000 end,
            disabled = HealthAlertOff,
            default  = CW.defaults.healthAlertCooldown / 1000,
        },
        SoundOption("Alert sound", "healthAlertSound", HealthAlertOff, function() CW.PlayHealthAlertSound() end,
            "Selecting a sound plays a preview."),
        VolumeOption("Sound volume", "healthAlertVolume", HealthAlertOff, function() CW.PlayHealthAlertSound() end),

        { type = "header", name = "Off Balance Tracker" },
        {
            type    = "checkbox",
            name    = "Off balance tracker",
            tooltip = "Show OFF BALANCE while your target is off balance. Drag the warning to move it while this tab is open.",
            getFunc = function() return CW.SavedVars.showOffBalanceTracker == true end,
            setFunc = function(v)
                CW.SavedVars.showOffBalanceTracker = v
                CW.UpdateOffBalanceTracking()
                CW.UI.ApplyOffBalanceTrackerStyle()
                local open = CW.UI.SettingsPanelOpen()
                CW.UI.SetOffBalanceTrackerPlacementMode(v == true and open == true)
            end,
            default = CW.defaults.showOffBalanceTracker,
        },
        FontFaceOption("Off balance font", "offBalance", OffBalanceOff, CW.UI.ApplyOffBalanceTrackerStyle),
        {
            type     = "checkbox",
            name     = "Off Balance Flash",
            tooltip  = "Flash the background when the OFF BALANCE warning appears.",
            getFunc  = function() return CW.SavedVars.offBalanceFlash == true end,
            setFunc  = function(v)
                CW.SavedVars.offBalanceFlash = v
                CW.UI.ResetOffBalanceFlash()
            end,
            disabled = OffBalanceOff,
            default  = CW.defaults.offBalanceFlash,
        },
        FontSizeOption("Off balance font size", "offBalance", OffBalanceOff, CW.UI.ApplyOffBalanceTrackerStyle),
        {
            type     = "slider",
            name     = "Off balance bar height",
            tooltip  = "Height of the bar showing how long Off Balance lasts; 0 hides it.",
            min      = 0, max = 20, step = 1,
            getFunc  = function() return CW.SavedVars.offBalanceBarHeight end,
            setFunc  = function(v)
                CW.SavedVars.offBalanceBarHeight = v
                CW.UI.ApplyOffBalanceTrackerStyle()
            end,
            disabled = OffBalanceOff,
            default  = CW.defaults.offBalanceBarHeight,
        },
        ColorOption("Off balance color", "offBalanceColor", OffBalanceOff, CW.UI.ApplyOffBalanceTrackerStyle),
    }
end

-- Tab: QOL Tweaks — extras belonging to neither the tracker nor the combat alerts.

local function QolTab()
    return {

        { type = "header", name = CW.L.DF_SETTING_HEADER },
        { type = "description", text = CW.L.DF_SETTING_DESC },
        {
            type    = "checkbox",
            name    = CW.L.DF_SETTING,
            tooltip = CW.L.DF_SETTING_TIP,
            getFunc = function() return CW.SavedVars.dungeonFinderEnhance end,
            setFunc = function(v) CW.SavedVars.dungeonFinderEnhance = v end,
            default = CW.defaults.dungeonFinderEnhance,
            requiresReload = true,
        },

        { type = "header", name = "Mounted Sprint" },
        {
            type    = "checkbox",
            name    = "Toggle sprint while mounted",
            tooltip = "Enable ESO's Toggle Sprint setting while mounted and restore your previous setting when you dismount.",
            getFunc = function() return CW.SavedVars.toggleSprintOnMount ~= false end,
            setFunc = function(v)
                CW.SavedVars.toggleSprintOnMount = v
                CW.UpdateMountedToggleSprint()
            end,
            default = CW.defaults.toggleSprintOnMount,
        },
        {
            type    = "checkbox",
            name    = "Show mounted sprint icon",
            tooltip = "Show an icon while mounted Toggle Sprint is active; it lights up when sprinting uses stamina.",
            getFunc = function() return CW.SavedVars.showMountSprintIcon ~= false end,
            setFunc = function(v)
                CW.SavedVars.showMountSprintIcon = v
                CW.UpdateMountStaminaTracking()
                CW.UI.ApplyMountSprintIconVisibility()
            end,
            default = CW.defaults.showMountSprintIcon,
        },
        {
            type     = "slider",
            name     = "Mounted sprint icon scale",
            tooltip  = "Size of the mounted sprint icon as a percentage.",
            min      = 10, max = 100, step = 5,
            getFunc  = function()
                return CW.UI.MountSprintIconScale()
            end,
            setFunc  = function(v)
                CW.SavedVars.mountSprintIconScale = v
                CW.UI.ApplyMountSprintIconSize()
                CW.UI.ApplyMountSprintIconVisibility()
            end,
            disabled = MountSprintIconOff,
            default  = CW.defaults.mountSprintIconScale,
        },
        ColorOption("Mounted sprint icon tint", "mountSprintIconTint", MountSprintIconOff, CW.UI.PreviewMountSprintIconTint,
            "Color of the icon while sprinting uses mount stamina."),

        { type = "header", name = "PvP" },
        {
            type    = "checkbox",
            name    = "Group and friendly health bars in PvP",
            tooltip = "Show group and friendly health bars only when injured in PvP zones. Your previous health bar settings return when you leave.",
            getFunc = function() return CW.SavedVars.friendlyHealthBarsInPvp ~= false end,
            setFunc = function(v)
                CW.SavedVars.friendlyHealthBarsInPvp = v
                CW.UpdateFriendlyHealthBars()
            end,
            default = CW.defaults.friendlyHealthBarsInPvp,
        },

        { type = "header", name = GetString(SI_WINDOW_TITLE_TRADING_HOUSE) },
        {
            type = "description",
            text = function() return CW.AwesomeGuildStoreAvailable() and "" or CW.L.AGS_MISSING end,
        },
        {
            type    = "checkbox",
            name    = CW.L.GUILD_STORE_SHOW_TRAIT,
            tooltip = CW.L.GUILD_STORE_SHOW_TRAIT_TIP,
            getFunc = function() return CW.SavedVars.guildStoreShowTrait end,
            setFunc = function(v) CW.SavedVars.guildStoreShowTrait = v end,
            disabled = function() return not CW.AwesomeGuildStoreAvailable() end,
            default = CW.defaults.guildStoreShowTrait,
            requiresReload = true,
        },
        {
            type    = "checkbox",
            name    = CW.L.STORE_IGNORE_SETTING,
            tooltip = CW.L.STORE_IGNORE_SETTING_TIP,
            getFunc = function() return CW.SavedVars.storeIgnoreList end,
            setFunc = function(v) CW.SavedVars.storeIgnoreList = v end,
            disabled = function() return not CW.AwesomeGuildStoreAvailable() end,
            default = CW.defaults.storeIgnoreList,
            requiresReload = true,
        },
        {
            type    = "checkbox",
            name    = CW.L.PURCHASE_LOG_SETTING,
            tooltip = CW.L.PURCHASE_LOG_SETTING_TIP,
            getFunc = function() return CW.SavedVars.purchaseLog end,
            setFunc = function(v) CW.SavedVars.purchaseLog = v end,
            disabled = function() return not CW.AwesomeGuildStoreAvailable() end,
            default = CW.defaults.purchaseLog,
            requiresReload = true,
        },
        {
            type    = "checkbox",
            name    = "Promote TTC menu entries",
            tooltip = "Move TTC search and price history to the main right-click menu, with gold-quality lookups for gear. Requires a UI reload.",
            getFunc = function() return CW.SavedVars.ttcPromoteMenuEntries ~= false end,
            setFunc = function(v) CW.SavedVars.ttcPromoteMenuEntries = v end,
            default = CW.defaults.ttcPromoteMenuEntries,
            requiresReload = true,
        },

        { type = "header", name = "Master Writs" },
        {
            type = "description",
            text = function() return CW.WritBridgeAvailable() and "" or CW.L.WRITBRIDGE_MISSING end,
        },
        {
            type     = "checkbox",
            name     = "Chain master writ turn-ins",
            tooltip  = "Turn in one crafted master writ to start the chain; moving or pressing Esc stops it. Requires WritWorthy and Lazy Writ Crafter with Auto Accept on.",
            getFunc  = function() return CW.SavedVars.autoWritTurnIn == true end,
            setFunc  = function(v)
                CW.SavedVars.autoWritTurnIn = v
                CW.UpdateWritBridge()
            end,
            disabled = function()
                return not (CW.WritBridgeAvailable())
            end,
            default  = CW.defaults.autoWritTurnIn,
        },
        {
            type     = "slider",
            name     = "Window close timeout (ms)",
            tooltip  = "How long to try closing Rolis's merchant window before asking you to close it. Set to 0 to always close it yourself.",
            min      = 0,
            max      = 5000,
            step     = 250,
            getFunc  = function() return CW.SavedVars.writCloseTimeoutMs end,
            setFunc  = function(v) CW.SavedVars.writCloseTimeoutMs = v end,
            disabled = function() return CW.SavedVars.autoWritTurnIn ~= true end,
            default  = CW.defaults.writCloseTimeoutMs,
        },

        { type = "header", name = "Lore Books" },
        {
            type = "description",
            text = function() return CW.LoreBookPinsAvailable() and "" or CW.L.LOREBOOKS_MISSING end,
        },
        {
            type     = "checkbox",
            name     = "Show uncollected lore books in 3D",
            tooltip  = "Show nearby uncollected lore books at your character's height. Requires LoreBooks and CrutchAlerts.",
            getFunc  = function() return CW.SavedVars.loreBookPins == true end,
            setFunc  = function(v)
                CW.SavedVars.loreBookPins = v
                CW.UpdateLoreBookPins()
            end,
            disabled = function()
                return not (CW.LoreBookPinsAvailable())
            end,
            default  = CW.defaults.loreBookPins,
        },
        {
            type     = "slider",
            name     = "Max distance",
            tooltip  = "Maximum distance in meters at which book pins appear.",
            min      = 25,
            max      = 300,
            step     = 5,
            getFunc  = function() return CW.SavedVars.loreBookPinDistance end,
            setFunc  = function(v) CW.SavedVars.loreBookPinDistance = v end,
            disabled = LoreBookPinsOff,
            default  = CW.defaults.loreBookPinDistance,
        },
        {
            type     = "slider",
            name     = "Icon size",
            tooltip  = "Size of each floating book icon. 100 is roughly one meter across.",
            min      = 50,
            max      = 300,
            step     = 10,
            getFunc  = function() return CW.SavedVars.loreBookPinSize end,
            setFunc  = function(v)
                CW.SavedVars.loreBookPinSize = v
                -- Size is read when an icon is created, so redraw to apply it.
                CW.QueueLoreBookPinRebuild()
            end,
            disabled = LoreBookPinsOff,
            default  = CW.defaults.loreBookPinSize,
        },
        {
            type     = "slider",
            name     = "Height offset",
            tooltip  = "Raise or lower book pins relative to your character's height.",
            min      = -5,
            max      = 10,
            step     = 1,
            getFunc  = function() return CW.SavedVars.loreBookPinHeight end,
            setFunc  = function(v) CW.SavedVars.loreBookPinHeight = v end,
            disabled = LoreBookPinsOff,
            default  = CW.defaults.loreBookPinHeight,
        },
        {
            type     = "dropdown",
            name     = "Pin style",
            tooltip  = "Choose a tinted book, a tinted diamond, or the book's original art. Color settings apply only to tinted styles.",
            choices       = { "Book (tinted)", "Diamond (tinted)", "Book icon (original art)" },
            choicesValues = { "book", "diamond", "icon" },
            getFunc  = function() return CW.SavedVars.loreBookPinStyle end,
            setFunc  = function(v)
                CW.SavedVars.loreBookPinStyle = v
                -- The texture is bound when an icon is created, so redraw to apply it.
                CW.QueueLoreBookPinRebuild()
            end,
            disabled = LoreBookPinsOff,
            default  = CW.defaults.loreBookPinStyle,
        },
        {
            type     = "colorpicker",
            name     = "Pin color",
            tooltip  = "Color of tinted book pins.",
            getFunc  = function() return unpack(CW.SavedVars.loreBookPinColor) end,
            setFunc  = function(r, g, b)
                CW.SavedVars.loreBookPinColor = { r, g, b }
            end,
            disabled = function()
                return CW.SavedVars.loreBookPins ~= true
                    or CW.SavedVars.loreBookPinStyle == "icon"
            end,
            default  = { r = 0.5, g = 0.4, b = 1 },
        },
        {
            type     = "colorpicker",
            name     = "Arrival color",
            tooltip  = "Color of tinted pins within 8 meters of a book. Pins also bounce when you get this close.",
            getFunc  = function() return unpack(CW.SavedVars.loreBookPinArriveColor) end,
            setFunc  = function(r, g, b)
                CW.SavedVars.loreBookPinArriveColor = { r, g, b }
            end,
            disabled = LoreBookPinsOff,
            default  = { r = 1, g = 1, b = 1 },
        },

        { type = "header", name = "LarvalTear" },
        {
            type = "description",
            text = function()
                if not CW.LarvalTearAvailable() then return CW.L.LT_MISSING end
                return "Hold the build wheel key, point to a build and release to apply it. The wheel shows LarvalTear's selected page, with 13 builds per wheel page."
            end,
        },
        {
            type     = "checkbox",
            name     = "Build wheel",
            tooltip  = "Set the build wheel and page keybinds in ESO's Controls menu.",
            getFunc  = function() return CW.SavedVars.ltWheel == true end,
            setFunc  = function(v) CW.SavedVars.ltWheel = v end,
            disabled = function() return not CW.LarvalTearAvailable() end,
            default  = CW.defaults.ltWheel,
        },
        {
            type     = "checkbox",
            name     = "Show current build",
            tooltip  = "Show your current build name on the HUD; drag the name to move it.",
            getFunc  = function() return CW.SavedVars.ltBuildDisplay == true end,
            setFunc  = function(v)
                CW.SavedVars.ltBuildDisplay = v
                CW.UpdateLarvalTear()
                -- Enabling creates the display after panel-open placement has already run.
                if v then CW.UI.SetLarvalTearBuildPlacementMode(true) end
            end,
            disabled = function() return not CW.LarvalTearAvailable() end,
            default  = CW.defaults.ltBuildDisplay,
        },
        {
            type     = "checkbox",
            name     = "Show equipped sets",
            tooltip  = "Show your mythic and equipped set counts under the build name, counting both weapon bars. Updates when you apply a build.",
            getFunc  = function() return CW.SavedVars.ltBuildSets ~= false end,
            setFunc  = function(v)
                CW.SavedVars.ltBuildSets = v
                CW.UI.ApplyLarvalTearBuildVisibility()
            end,
            disabled = function() return not CW.LarvalTearAvailable() or LtBuildOff() end,
            default  = CW.defaults.ltBuildSets,
        },
        FontSizeOption("Set list size", "ltBuildSets", LtBuildSetsOff, CW.UI.ApplyLarvalTearBuildStyle,
            nil, 8, 14),
        ColorOption("Set list color", "ltBuildSetsColor", LtBuildSetsOff, CW.UI.ApplyLarvalTearBuildStyle),
        FontFaceOption("Build name font", "ltBuild", LtBuildOff, CW.UI.ApplyLarvalTearBuildStyle),
        FontSizeOption("Build name size", "ltBuild", LtBuildOff, CW.UI.ApplyLarvalTearBuildStyle),
        ColorOption("Build name color", "ltBuildColor", LtBuildOff, CW.UI.ApplyLarvalTearBuildStyle),
        {
            type     = "checkbox",
            name     = "Poison bar alert",
            tooltip  = "Show which weapon bar has poison for two seconds after applying a build. Drag the warning to move it while this tab is open.",
            getFunc  = function() return CW.SavedVars.ltPoisonAlert == true end,
            setFunc  = function(v)
                CW.SavedVars.ltPoisonAlert = v
                CW.UpdateLarvalTear()
                CW.UI.ApplyPoisonAlertStyle()
                CW.UI.SetPoisonAlertPlacementMode(v == true and CW.UI.SettingsPanelOpen() == true)
            end,
            disabled = function() return not CW.LarvalTearAvailable() end,
            default  = CW.defaults.ltPoisonAlert,
        },
        FontFaceOption("Poison alert font", "ltPoisonAlert", PoisonAlertOff, CW.UI.ApplyPoisonAlertStyle),
        FontSizeOption("Poison alert size", "ltPoisonAlert", PoisonAlertOff, CW.UI.ApplyPoisonAlertStyle),
        ColorOption("Poison alert color", "ltPoisonAlertColor", PoisonAlertOff, CW.UI.ApplyPoisonAlertStyle),
    }
end

-- Tab: PvP -- warnings that only matter with other players on the other end.

local function PvpTab()
    return {
        {
            type = "description",
            text = "Drag the alerts to move them while this tab is open.",
        },
        { type = "header", name = "Incoming Damage Alert" },
        {
            type    = "description",
            text    = "Show the name and icon of the latest watched ability to damage you. Active only in Cyrodiil, Imperial City and Battlegrounds.",
        },
        {
            type    = "checkbox",
            name    = "Incoming damage alert",
            tooltip = "Warn when one of the abilities below damages you.",
            getFunc = function() return CW.SavedVars.incomingAlertEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.incomingAlertEnabled = v
                CW.UpdateIncomingAlertTracking()
                if not v then CW.ClearIncomingAlert() end
                CW.UI.ApplyIncomingAlertStyle()
                local open = CW.UI.SettingsPanelOpen()
                CW.UI.SetIncomingAlertPlacementMode(v == true and open == true)
            end,
            default = CW.defaults.incomingAlertEnabled,
        },
        IncomingAlertOption("Corrosive"),
        IncomingAlertOption("Onslaught"),
        IncomingAlertOption("Radiant"),
        IncomingAlertOption("RapidFire"),
        IncomingAlertOption("SoulAssault"),
        IncomingAlertOption("Fatecarver"),
        IncomingAlertOption("ArcanistUlt"),
        IncomingAlertOption("DestroUlt"),
        {
            type     = "checkbox",
            name     = "Overlapping warnings to chat",
            tooltip  = "Send the previous warning to chat when a different watched ability replaces it.",
            getFunc  = function() return CW.SavedVars.incomingAlertChat == true end,
            setFunc  = function(v) CW.SavedVars.incomingAlertChat = v end,
            disabled = IncomingAlertOff,
            default  = CW.defaults.incomingAlertChat,
        },
        FontFaceOption("Incoming alert font", "incomingAlert", IncomingAlertOff, CW.UI.ApplyIncomingAlertStyle),
        FontSizeOption("Incoming alert size", "incomingAlert", IncomingAlertOff, CW.UI.ApplyIncomingAlertStyle,
            "Size of the warning text and ability icon."),
        ColorOption("Incoming alert text color", "incomingAlertColor", IncomingAlertOff, CW.UI.ApplyIncomingAlertStyle),
        ColorOption("Incoming alert underline color", "incomingAlertUnderlineColor", IncomingAlertOff, CW.UI.ApplyIncomingAlertStyle,
            "Color of the flashing underline; set opacity to 0 to hide it."),
        SoundOption("Incoming alert sound", "incomingAlertSound", IncomingAlertOff, function() CW.PlayIncomingAlertSound() end,
            "Selecting a sound plays a preview."),
        VolumeOption("Incoming alert volume", "incomingAlertVolume", IncomingAlertOff, function() CW.PlayIncomingAlertSound() end),
        { type = "header", name = "CC Immunity Bar" },
        {
            type    = "description",
            text    = "Track hard and soft crowd-control immunity in all zones. Hard takes the text; soft still running under it gets a second bar.",
        },
        {
            type    = "checkbox",
            name    = "CC immunity bar",
            tooltip = "Show a bar that drains as your crowd-control immunity expires.",
            getFunc = function() return CW.SavedVars.ccImmunityEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.ccImmunityEnabled = v
                CW.UpdateCcImmunityTracking()
                CW.UI.ApplyCcImmunityStyle()
                CW.UI.SetCcImmunityPlacementMode(v == true and CW.UI.SettingsPanelOpen() == true)
            end,
            default = CW.defaults.ccImmunityEnabled,
        },
        {
            type        = "editbox",
            name        = "Hard CC immunity text",
            tooltip     = "Text for immunity to stuns, knockbacks and fears; leave blank to use CC IMMUNE.",
            getFunc     = function() return CW.SavedVars.ccImmunityText end,
            setFunc     = function(v)
                CW.SavedVars.ccImmunityText = zo_strtrim(v or "")
                CW.UI.ApplyCcImmunityText()
            end,
            isMultiline = false,
            disabled    = CcImmunityOff,
            default     = CW.defaults.ccImmunityText,
        },
        {
            type        = "editbox",
            name        = "Soft CC immunity text",
            tooltip     = "Text for immunity to roots and snares; leave blank to use ROOT IMMUNE.",
            getFunc     = function() return CW.SavedVars.ccImmunitySoftText end,
            setFunc     = function(v)
                CW.SavedVars.ccImmunitySoftText = zo_strtrim(v or "")
                CW.UI.ApplyCcImmunityText()
            end,
            isMultiline = false,
            disabled    = CcImmunityOff,
            default     = CW.defaults.ccImmunitySoftText,
        },
        {
            type     = "checkbox",
            name     = "Show remaining seconds",
            tooltip  = "Show remaining seconds beside the text.",
            getFunc  = function() return CW.SavedVars.ccImmunityShowSeconds == true end,
            setFunc  = function(v)
                CW.SavedVars.ccImmunityShowSeconds = v
                CW.UI.ApplyCcImmunityText()
            end,
            disabled = CcImmunityOff,
            default  = CW.defaults.ccImmunityShowSeconds,
        },
        FontFaceOption("CC immunity font", "ccImmunity", CcImmunityOff, CW.UI.ApplyCcImmunityStyle),
        FontSizeOption("CC immunity size", "ccImmunity", CcImmunityOff, CW.UI.ApplyCcImmunityStyle,
            "Size of the text and width of the bar."),
        ColorOption("Hard CC immunity color", "ccImmunityColor", CcImmunityOff, CW.UI.ApplyCcImmunityStyle,
            "Color for immunity to stuns, knockbacks and fears."),
        ColorOption("Soft CC immunity color", "ccImmunitySoftColor", CcImmunityOff, CW.UI.ApplyCcImmunityStyle,
            "Color for immunity to roots and snares."),
        {
            type     = "slider",
            name     = "CC immunity bar height",
            tooltip  = "Bar height in pixels; 0 hides the bar and keeps the text.",
            min      = 0, max = 20, step = 1,
            getFunc  = function() return CW.SavedVars.ccImmunityBarHeight end,
            setFunc  = function(v)
                CW.SavedVars.ccImmunityBarHeight = v
                CW.UI.ApplyCcImmunityStyle()
            end,
            disabled = CcImmunityOff,
            default  = CW.defaults.ccImmunityBarHeight,
        },

        { type = "header", name = "Negate Warning" },
        {
            type    = "description",
            text    = "Warn when Negate Magic affects you in Cyrodiil, Imperial City or Battlegrounds.",
        },
        {
            type    = "checkbox",
            name    = "Negate warning",
            tooltip = "Show a warning and play a sound when Negate Magic affects you.",
            getFunc = function() return CW.SavedVars.negateAlertEnabled == true end,
            setFunc = function(v)
                CW.SavedVars.negateAlertEnabled = v
                CW.UpdateNegateAlertTracking()
                CW.UI.ApplyNegateAlertStyle()
                CW.UI.SetNegateAlertPlacementMode(v == true and CW.UI.SettingsPanelOpen() == true)
            end,
            default = CW.defaults.negateAlertEnabled,
        },
        {
            type        = "editbox",
            name        = "Negate warning text",
            tooltip     = "Warning text; leave blank to use NEGATE.",
            getFunc     = function() return CW.SavedVars.negateAlertText end,
            setFunc     = function(v)
                CW.SavedVars.negateAlertText = zo_strtrim(v or "")
                CW.UI.ApplyNegateAlertText()
            end,
            isMultiline = false,
            disabled    = NegateAlertOff,
            default     = CW.defaults.negateAlertText,
        },
        FontFaceOption("Negate warning font", "negateAlert", NegateAlertOff, CW.UI.ApplyNegateAlertStyle),
        FontSizeOption("Negate warning size", "negateAlert", NegateAlertOff, CW.UI.ApplyNegateAlertStyle),
        ColorOption("Negate warning color", "negateAlertColor", NegateAlertOff, CW.UI.ApplyNegateAlertStyle),
        {
            type     = "slider",
            name     = "Negate warning timeout",
            tooltip  = "Maximum time the warning stays visible if the game doesn't report that Negate has ended.",
            min      = 2000, max = 20000, step = 500,
            getFunc  = function() return CW.SavedVars.negateAlertDuration end,
            setFunc  = function(v) CW.SavedVars.negateAlertDuration = v end,
            disabled = NegateAlertOff,
            default  = CW.defaults.negateAlertDuration,
        },
        SoundOption("Negate warning sound", "negateAlertSound", NegateAlertOff, function() CW.PlayNegateAlertSound() end,
            "Selecting a sound plays a preview."),
        VolumeOption("Negate warning volume", "negateAlertVolume", NegateAlertOff, function() CW.PlayNegateAlertSound() end),
    }
end

-- Tab: LA -- the light attack / weave tracker.

-- The value is the literal string dropped between the metrics, padding included.
local LA_SEPARATORS = {
    { " • ", "Bullet  •" },
    { " ▪ ", "Square  ▪" },
    { " ◆ ", "Diamond  ◆" },
    { " | ", "Pipe  |" },
    { " / ", "Slash  /" },
    { " - ", "Dash  -" },
    { "   ", "Spaces" },
}

local LA_SEPARATOR_NAMES, LA_SEPARATOR_VALUES = {}, {}
for i, entry in ipairs(LA_SEPARATORS) do
    LA_SEPARATOR_VALUES[i] = entry[1]
    LA_SEPARATOR_NAMES[i] = entry[2]
end

-- Seven checkboxes of identical shape, so they are generated.
local LA_METRICS = {
    { "laStatsAccuracy", "Show accuracy", "Percentage of skill casts with a light attack before them." },
    { "laStatsCount", "Show weave count", "Skill casts with a light attack, out of total attempts." },
    { "laStatsMissed", "Show missed weaves", "Skill casts with no light attack before them." },
    { "laStatsLate", "Show late weaves", "Weaves that included a light attack but exceeded the clean weave window." },
    { "laStatsAvgGap", "Show average gap", "Average idle time between skills, in milliseconds, excluding casts and cooldowns." },
    { "laStatsWasted", "Show wasted time", "Total idle time between skills, excluding casts, cooldowns and rotation breaks." },
    { "laStatsActive", "Show active time", "Total time in your rotation, including gaps shorter than the break cutoff." },
}

local function LaTab()
    local options = {
        {
            type = "description",
            text = function()
                if not CW.LightAttackAvailable() then return CW.L.LA_MISSING end
                return "Track missed and late light attack weaves and time lost between casts. Each fight resets the totals; drag the panel to move it while this tab is open."
            end,
        },
        {
            type = "checkbox",
            name = "Light attack tracker",
            tooltip = "Show your light attack weaving stats.",
            getFunc = function() return CW.SavedVars.laStats == true end,
            setFunc = function(v)
                CW.SavedVars.laStats = v
                CW.UpdateLaStatsTracking()
                CW.UI.ApplyLaStatsStyle()
                CW.UI.SetLaStatsPlacementMode(v == true and CW.UI.SettingsPanelOpen() == true)
            end,
            disabled = function() return not CW.LightAttackAvailable() end,
            default = CW.defaults.laStats,
        },
        FontFaceOption("Panel font", "laStats", LaStatsOff, CW.UI.ApplyLaStatsStyle),
        FontSizeOption("Panel size", "laStats", LaStatsOff, CW.UI.ApplyLaStatsStyle),
        ColorOption("Panel color", "laStatsColor", LaStatsOff, CW.UI.ApplyLaStatsStyle),
        {
            type = "dropdown",
            name = "Divider",
            tooltip = "Separator between the stats on the panel.",
            choices = LA_SEPARATOR_NAMES,
            choicesValues = LA_SEPARATOR_VALUES,
            getFunc = function() return CW.SavedVars.laStatsSeparator end,
            setFunc = function(v)
                CW.SavedVars.laStatsSeparator = v
                CW.UI.SetLaStatsText(CW.LaStatsText())
            end,
            disabled = LaStatsOff,
            default = CW.defaults.laStatsSeparator,
        },
        {
            type = "checkbox",
            name = "Keep visible out of combat",
            tooltip = "Keep the last fight's totals visible after combat ends.",
            getFunc = function() return CW.SavedVars.laStatsOutOfCombat ~= false end,
            setFunc = function(v)
                CW.SavedVars.laStatsOutOfCombat = v
                CW.UpdateLaStatsTracking()
            end,
            disabled = LaStatsOff,
            default = CW.defaults.laStatsOutOfCombat,
        },
        {
            type = "checkbox",
            name = "Flash on a clean weave",
            tooltip = "Flash the panel background when a light attack is followed by a skill within the clean weave window.",
            getFunc = function() return CW.SavedVars.laStatsFlash ~= false end,
            setFunc = function(v) CW.SavedVars.laStatsFlash = v end,
            disabled = LaStatsOff,
            default = CW.defaults.laStatsFlash,
        },
        ColorOption("Flash color", "laStatsFlashColor", LaFlashOff, function() CW.UI.ApplyLaStatsStyle(); CW.UI.FlashLaStats() end),
        {
            type = "slider",
            name = "Flash growth (%)",
            tooltip = "How much the flash expands beyond the panel.",
            min = 25, max = 100, step = 5,
            getFunc = function() return CW.SavedVars.laStatsFlashGrow end,
            setFunc = function(v)
                CW.SavedVars.laStatsFlashGrow = v
                CW.UI.ApplyLaStatsStyle()
                CW.UI.FlashLaStats()
            end,
            disabled = LaFlashOff,
            default = CW.defaults.laStatsFlashGrow,
        },
        { type = "header", name = "Metrics" },
    }

    for _, metric in ipairs(LA_METRICS) do
        local key = metric[1]
        options[#options + 1] = {
            type = "checkbox",
            name = metric[2],
            tooltip = metric[3],
            getFunc = function() return CW.SavedVars[key] == true end,
            setFunc = function(v)
                CW.SavedVars[key] = v
                CW.UI.SetLaStatsText(CW.LaStatsText())
            end,
            disabled = LaStatsOff,
            default = CW.defaults[key],
        }
    end

    options[#options + 1] = { type = "header", name = "Grading" }
    options[#options + 1] = {
        type = "slider",
        name = "Clean weave window (ms)",
        tooltip = "Extra milliseconds allowed after a cast or global cooldown ends for the next weave to count as clean.",
        min = 20, max = 400, step = 10,
        getFunc = function() return CW.SavedVars.laLateCutoff end,
        setFunc = function(v) CW.SavedVars.laLateCutoff = v end,
        disabled = LaStatsOff,
        default = CW.defaults.laLateCutoff,
    }
    options[#options + 1] = {
        type = "slider",
        name = "Rotation break cutoff (ms)",
        tooltip = "Ignore gaps longer than this when counting weaves and wasted time.",
        min = 500, max = 5000, step = 100,
        getFunc = function() return CW.SavedVars.laBreakCutoff end,
        setFunc = function(v) CW.SavedVars.laBreakCutoff = v end,
        disabled = LaStatsOff,
        default = CW.defaults.laBreakCutoff,
    }

    options[#options + 1] = { type = "header", name = "Hit Sound" }
    options[#options + 1] = {
        type = "description",
        text = "Weapon Draw entries use equip sounds; Weapon entries use outfit station sounds. Your choice plays for every weapon type.",
    }
    options[#options + 1] = {
        type = "checkbox",
        name = "Light attack hit sound",
        tooltip = "Play a sound when a light attack hits, even if the tracker is off.",
        getFunc = function() return CW.SavedVars.laHitSound == true end,
        setFunc = function(v)
            CW.SavedVars.laHitSound = v
            CW.UpdateLaHitSoundTracking()
        end,
        default = CW.defaults.laHitSound,
    }
    options[#options + 1] = {
        type = "dropdown",
        name = "Hit sound",
        tooltip = "Selecting a sound plays a preview.",
        choices = CW.SOUND_NAMES,
        choicesValues = CW.SOUND_KEYS,
        getFunc = function() return CW.SavedVars.laHitSoundKey end,
        setFunc = function(v)
            CW.SavedVars.laHitSoundKey = v
            CW.PlayLaHitSound()
        end,
        disabled = LaHitSoundOff,
        default = CW.defaults.laHitSoundKey,
    }
    options[#options + 1] = {
        type = "slider",
        name = "Hit sound volume",
        tooltip = ALERT_VOLUME_TIP,
        min = 0, max = 10, step = 1,
        getFunc = function() return CW.SavedVars.laHitSoundVolume end,
        setFunc = function(v)
            CW.SavedVars.laHitSoundVolume = v
            CW.PlayLaHitSound()
        end,
        disabled = LaHitSoundOff,
        default = CW.defaults.laHitSoundVolume,
    }

    return options
end

-- Tab: Chat Alerts — group and whisper messages mirrored onto the HUD.

local function ChatAlertTab()
    return {
        {
            type = "description",
            text = "Show incoming group messages and whispers on the HUD. While this tab is open, drag the display to move it or its edges to resize it.",
        },
        {
            type    = "checkbox",
            name    = "Enable chat pop-up",
            tooltip = "Show chat messages and play the selected sound.",
            getFunc = function() return CW.SavedVars.chatAlerts == true end,
            setFunc = function(v)
                CW.SavedVars.chatAlerts = v
                CW.UpdateChatAlerts()
                CW.UI.SetChatAlertPlacementMode(v == true)
            end,
            default = CW.defaults.chatAlerts,
        },
        {
            type    = "checkbox",
            name    = "In combat only",
            tooltip = "Only show messages during combat, unless Always alert whispers or Test mode is enabled.",
            getFunc = function() return CW.SavedVars.chatAlertsCombatOnly ~= false end,
            setFunc = function(v) CW.SavedVars.chatAlertsCombatOnly = v end,
            disabled = ChatAlertsOff,
            default = CW.defaults.chatAlertsCombatOnly,
        },
        {
            type    = "checkbox",
            name    = "Always alert whispers",
            tooltip = "Show whispers outside combat even when In combat only is enabled.",
            getFunc = function() return CW.SavedVars.chatAlertsWhisperAlways ~= false end,
            setFunc = function(v) CW.SavedVars.chatAlertsWhisperAlways = v end,
            disabled = ChatAlertsOff,
            default = CW.defaults.chatAlertsWhisperAlways,
        },
        {
            type     = "slider",
            name     = "Width",
            tooltip  = "Width of the message area before text wraps.",
            min      = 150, max = 1200, step = 10,
            getFunc  = function() return CW.SavedVars.chatAlertWidth end,
            setFunc  = function(v)
                CW.SavedVars.chatAlertWidth = v
                CW.UI.ApplyChatAlertWidth()
            end,
            disabled = ChatAlertsOff,
            default  = CW.defaults.chatAlertWidth,
        },
        {
            type    = "checkbox",
            name    = "Test mode (show every channel)",
            tooltip = "Show incoming messages from every chat channel, even outside combat.",
            getFunc = function() return CW.SavedVars.chatAlertTestMode == true end,
            setFunc = function(v) CW.SavedVars.chatAlertTestMode = v end,
            disabled = ChatAlertsOff,
            default = CW.defaults.chatAlertTestMode,
        },
        FontFaceOption("Font", "chatAlert", ChatAlertsOff, CW.UI.ApplyChatAlertStyle),
        FontSizeOption("Font size", "chatAlert", ChatAlertsOff, CW.UI.ApplyChatAlertStyle,
            nil, 12, 36),
        ColorOption("Name color", "chatAlertNameColor", ChatAlertsOff, CW.UI.ApplyChatAlertStyle),
        ColorOption("Message color", "chatAlertTextColor", ChatAlertsOff, CW.UI.ApplyChatAlertStyle),
        SoundOption("Sound", "chatAlertSound", ChatAlertsOff, function() CW.PreviewChatAlertSound() end,
            "Selecting a sound plays a preview."),
        VolumeOption("Volume", "chatAlertVolume", ChatAlertsOff, function() CW.PreviewChatAlertSound() end),
        {
            type     = "slider",
            name     = "On-screen time (s)",
            tooltip  = "How long each message stays visible before fading.",
            min      = 1, max = 10, step = 1,
            getFunc  = function() return CW.SavedVars.chatAlertDuration end,
            setFunc  = function(v) CW.SavedVars.chatAlertDuration = v end,
            disabled = ChatAlertsOff,
            default  = CW.defaults.chatAlertDuration,
        },
        {
            type    = "button",
            name    = "Preview",
            tooltip = "Show two sample messages with the selected timing and sound.",
            func    = function()
                -- Test lines expire above the pinned samples, leaving the display draggable.
                CW.TestChatAlert()
            end,
            disabled = ChatAlertsOff,
        },
    }
end
function CW.CreateSettings()
    local LAM = LibAddonMenu2

    CW.UI.RefreshFontChoices()
    -- Same by-reference deal for the two GCD-alert dropdowns.
    CW.RefreshGcdBarChoices()
    CW.RefreshGcdEntryChoices()

    local panel = {
        type                = "panel",
        name                = "Common Works",
        displayName         = CW.BRAND,
        version             = CW.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    -- Held onto so the panel's own gear button can open straight to here.
    CW.settingsPanel = LAM:RegisterAddonPanel("CW_SettingsPanel", panel)

    -- CW.CreateSettingsTabs builds a fixed nav bar and one scrollable page per tab.
    CW.settingsTabs = {
        { key = "questTracker", label = "Quest Tracker", options = QuestTrackerTab() },
        { key = "alerts",       label = "Alerts",        options = AlertTab()        },
        { key = "pvp",          label = "PvP",           options = PvpTab()          },
        { key = "gcdAlerts",    label = "Ability Alerts", options = GcdAlertTab()    },
        { key = "chatAlerts",   label = "Chat",          options = ChatAlertTab()    },
        { key = "qol",          label = "QOL",           options = QolTab()          },
        { key = "la",           label = "LA",            options = LaTab()           },
    }

    CW.CreateSettingsTabs(LAM)

    -- LAM also fires these when its window reopens with the same panel selected.
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel ~= CW.settingsPanel then return end
        CW.settingsOpen = true
        CW.SetHudPlacementMode(true, CW.SelectedSettingsTabKey())
        CW.UI.SetAboveMenus(true)
        CW.SyncVisibility()
        -- Slotted abilities may have changed since the last visit.
        CW.RefreshGcdSettings()
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel ~= CW.settingsPanel then return end
        CW.settingsOpen = false
        CW.SetHudPlacementMode(false)
        CW.UI.SetAboveMenus(false)
        CW.SyncVisibility()
    end)
end
