local LMP = LibMediaProvider
STFU = {}
STFU.name = "STFUElementalWeapon"
STFU.displayName = "|cffaaaaSTFUElementalWeapon|r"
STFU.muted = false
STFU.refire = "Refire"
STFU.max = 1
STFU.decreasing = false
STFU.stacks = 0
STFU.hidden = true
STFU.registering = false
STFU.unregistering = false

STFU.addOnPanel = {}
STFU.account = {}
STFU.settingsDefaults = {
    ["imbue"] = false,
    ["ele"] = false,
    ["crush"] =  false,
    ["cover"] = false,
    ["lerpInSpeed"] = 10,
    ["lerpBeforeSpeed"] = 800,
    ["lerpOutSpeed"] = 50,
    ["min"] = .1,
    ["showSpellOrbs"] = true,
    ["spellOrbFont"] = "Univers 57",
    ["spellOrbFontSize"] = 32,
    ["spellOrbFontStyle"] = "soft-shadow-thick",
    ["spellOrbColor"] =  { 1.0, 0.98, 0.65, 1.0 },
    ["spellOrbLeft"] = 0,
    ["spellOrbTop"] =  0,
    ["custom"] = {},
    ["customCount"] = 0,
}


function STFU.OnInitialized(eventCode, addOnName)
    if (STFU.name ~= addOnName) then return end

    EVENT_MANAGER:RegisterForEvent("STFUElementalWeapon", EVENT_ACTION_SLOT_ABILITY_USED, STFU.toggleSound)
    EVENT_MANAGER:RegisterForEvent("STFUElementalWeapon", EVENT_EFFECT_CHANGED, STFU.effectChanged)

    STFU.audioVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME) + 0

    STFU.createSettingsPage()

    STFU.account = ZO_SavedVars:NewAccountWide('STFU_Account', 1, nil, STFU.settingsDefaults, nil)


end

SLASH_COMMANDS["/stfuregister"] = function (extra)
    STFU.registering = true
    STFU.unregistering = false
    d ( "|t20:20:esoui/art/buttons/info_over.dds|t The next main skill you use will be muffled henceforth" )
end

SLASH_COMMANDS["/stfuunregister"] = function (extra)
    STFU.unregistering = true
    STFU.registering = false

    d ( "|t20:20:esoui/art/buttons/info_over.dds|t The next main skill you use will be unmuffled henceforth IF it's already registered, otherwise nothing will happen." )
end

function STFU.find(skill)
    pos = -1

    for i, x in ipairs(STFU.account.custom) do
        if skill == x then
            pos = i
            break
        end
    end

    return pos
end

function STFU.toggleSound(eventCode, slotNum)
    IMB = 103483
    ELE = 103571
    CRS = 103623

    -- we only want main abilities
    if ( slotNum < 3 or slotNum > 8 ) then return end

    skill = (GetSlotBoundId(slotNum))

    muffle = ((skill == ELE and not STFU.account.ele) or (skill == CRS and not STFU.account.crush) or (skill == IMB and not STFU.account.imbue))

    if not muffle then
        if STFU.registering then
            if STFU.find(skill) == -1 then
                STFU.account.customCount = STFU.account.customCount + 1
                STFU.account.custom[STFU.account.customCount] = skill
                STFU.registering = false
                muffle = true

                d ("|t20:20:esoui/art/buttons/info_over.dds|t Registered " ..  "|t20:20:".. GetAbilityIcon(skill) .. "|t" .. (GetAbilityName(skill)))
            end
        elseif STFU.unregistering then
            pos = STFU.find(skill)
            if pos ~= -1 then
                table.remove(STFU.account.custom, pos)
                STFU.account.customCount = STFU.account.customCount - 1
                d ("|t20:20:esoui/art/buttons/info_over.dds|t UnRegistered " ..  "|t20:20:".. GetAbilityIcon(skill) .. "|t" .. (GetAbilityName(skill)))
            end
            STFU.unregistering = false
        else
            for _, x in ipairs(STFU.account.custom) do
                if skill == x then
                    muffle = true
                    break
                end
            end
        end
    end

    if muffle then
        STFU.level = 1
        STFU.decreasing = true
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, STFU.audioVolume * STFU.level)
        EVENT_MANAGER:UnregisterForUpdate(STFU.refire)
        EVENT_MANAGER:RegisterForUpdate(STFU.refire, 10, STFU.gimmeSoundBack)
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, STFU.audioVolume * STFU.level)
        STFU.i = 0
    end
end

function STFU.waiting()
    EVENT_MANAGER:UnregisterForUpdate(STFU.refire)
    if (STFU.i < 6) then
        PlaySound(SOUNDS.GAMEPAD_OPEN_WINDOW)
        EVENT_MANAGER:RegisterForUpdate(STFU.refire, STFU.account.lerpBeforeSpeed / 7, STFU.waiting)
        STFU.i = STFU.i + 1
    else
        STFU.gimmeSoundBack()
    end
end

function STFU.gimmeSoundBack()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, STFU.audioVolume * STFU.level)
    EVENT_MANAGER:UnregisterForUpdate(STFU.refire)


    if STFU.decreasing and STFU.level > STFU.account.min + .1 then
        EVENT_MANAGER:RegisterForUpdate(STFU.refire, STFU.account.lerpInSpeed, STFU.gimmeSoundBack)
        STFU.level = STFU.level - .1
    elseif STFU.level < STFU.max then
        if STFU.decreasing then
            if ( not STFU.account.cover ) then
                -- PlaySound(SOUNDS.CHAMPION_ZOOM_OUT)
                STFU.waiting()
            end
            STFU.decreasing = false
            EVENT_MANAGER:RegisterForUpdate(STFU.refire, STFU.account.lerpBeforeSpeed, STFU.gimmeSoundBack)
        else
            EVENT_MANAGER:RegisterForUpdate(STFU.refire, STFU.account.lerpOutSpeed, STFU.gimmeSoundBack)
            STFU.level = .1 + STFU.level
        end
    else
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, STFU.audioVolume)
    end
end

EVENT_MANAGER:RegisterForEvent("STFUElementalWeapon", EVENT_ADD_ON_LOADED, STFU.OnInitialized)


function STFU.syncSoundEffect()
    STFU.audioVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME) + 0
end

function STFU.ShowSettings()
    local LAM = LibAddonMenu

    LAM:OpenToPanel(STFU.addOnPanel)
end

function STFU.effectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if ( not unitTag == "player" ) then return end

    local spell = "Spell Orb"

    if ( effectName == spell ) then
        if ( changeType == EFFECT_RESULT_FADED ) then
            STFU.stacks = 0
        else
            STFU.stacks = stackCount
        end
        STFU.hidden = STFU.stacks < 1 or not STFU.account.showSpellOrbs
        STFU.updateLabels()
    end
end

function STFU.updateLabels()
    SpellOrbIndicator:SetHidden(STFU.hidden)
    SpellOrbIndicatorLabel:SetText(string.format("%d", STFU.stacks))
end

function STFU.toggleLabels()
    STFU.hidden = not STFU.hidden
    STFU.updateLabels()
end

function STFU.OnSpellOrbIndicatorMoveStop()
    STFU.account.spellOrbLeft = SpellOrbIndicator:GetLeft()
    STFU.account.spellOrbTop = SpellOrbIndicator:GetTop()
end

function STFU.OnSpellOrbIndicatorShow()
    SpellOrbIndicatorLabel:SetColor( unpack(STFU.account.spellOrbColor) )
    SpellOrbIndicatorLabel:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', STFU.account.spellOrbFont), STFU.account.spellOrbFontSize, STFU.account.spellOrbFontStyle))
end

function STFU.createSettingsPage()
    local LAM = LibAddonMenu
    local dropFontStyle = {'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick'}

    local panelData =
    {
        type = "panel",
        name = STFU.displayName,
        author = "|c99ffffJodynn|r",
        version = "1.7" ,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable =
    {
        {
            type = "description",
            text = "Fades sound effects out when casting imbue weapons, then fades in after a certain period.",
        },

        {
            type = "header",
            name = "|cff99ccIgnore|r : we won't fade these",
        },

        {
            type = "checkbox",
            name = "Ignore imbue weapons",
            getFunc = function() return STFU.account.imbue end,
            setFunc = function(value) STFU.account.imbue = value end,
        },

        {
            type = "checkbox",
            name = "Ignore Elemental weapons",
            getFunc = function() return STFU.account.ele end,
            setFunc = function(value) STFU.account.ele = value end,
        },

        {
            type = "checkbox",
            name = "Ignore Crushing weapons",
            getFunc = function() return STFU.account.crush end,
            setFunc = function(value) STFU.account.crush = value end,
        },

        {
            type = "checkbox",
            name = "Ignore covering up sounds",
            getFunc = function() return STFU.account.cover end,
            setFunc = function(value) STFU.account.cover = value end,
        },

        {
            type = "header",
            name = "|cff00ffSpeed|r in milliseconds ( 1000 ms == 1 second )",
        },

        {
            type = "description",
            text = "The lower the faster. Just keep in mind, the skill takes 1 second.",
        },

        {
            type = "description",
            text = "There are 10 iterations for fading out and in, so 10ms is 100ms total.",
        },

        {
            type = "slider",
            name = "Fade-Out speed",
            min = 0, max = 100, step = 1,
            getFunc = function() return STFU.account.lerpInSpeed end,
            setFunc = function(value) STFU.account.lerpInSpeed = value end,
        },

        {
            type = "slider",
            name = "Time before fading in",
            min = 0, max = 1000, step = 10,
            getFunc = function() return STFU.account.lerpBeforeSpeed end,
            setFunc = function(value) STFU.account.lerpBeforeSpeed = value end,
        },

        {
            type = "slider",
            name = "Fade-In speed",
            min = 0, max = 100, step = 1,
            getFunc = function() return STFU.account.lerpOutSpeed end,
            setFunc = function(value) STFU.account.lerpOutSpeed = value end,
        },

        {
            type = "header",
            name = "|c0000ffVolume|r",
        },

        {
            type = "description",
            text = "The lower the less audio you'll get when it is faded out.",
        },

        {
            type = "slider",
            name = "Min Volume",
            min = 0, max = 100, step = 10,
            getFunc = function() return STFU.account.min / 100 end,
            setFunc = function(value) STFU.account.min = 100 * value end,
        },

        {
            type = "header",
            name = "|c00ff00Sync|r sound effects volume",
        },

        {
            type = "description",
            text = "If you change sound effects after you load your UI you'll need to sync the settings, alternatively you could change the setting then just reloadUI, but this is quicker.",
        },

        {
            type = "button",
            name = "Sync sound effects",
            func = STFU.syncSoundEffect,
            width = "half"
        },

        {
            type = "header",
            name = "|cffffa0 Spell Orbs|r",
        },

        {
            type = "description",
            text = "Change if you show how many spell orbs, the font and color of the label",
        },

        {
            type = "checkbox",
            name = "Show Spell Orb Label",
            getFunc = function() return STFU.account.showSpellOrbs end,
            setFunc = function(value) STFU.account.showSpellOrbs = value end,
        },

        {
            type = 'dropdown',
            name = "Spell Orb Font",
            choices = LMP:List('font'),
            getFunc = function()
                return STFU.account.spellOrbFont
            end,
            setFunc = function(v)
                STFU.account.spellOrbFont = v
                SpellOrbIndicatorLabel:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', STFU.account.spellOrbFont), STFU.account.spellOrbFontSize, STFU.account.spellOrbFontStyle))
            end,
            scrollable = 7,
        },

        {
            type = 'dropdown',
            name = "Spell Orb Font-Style",
            choices = dropFontStyle,
            getFunc = function()
                return STFU.account.spellOrbFontStyle
            end,
            setFunc = function(v)
                STFU.account.spellOrbFontStyle = v
                SpellOrbIndicatorLabel:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', STFU.account.spellOrbFont), STFU.account.spellOrbFontSize, STFU.account.spellOrbFontStyle))
            end,
            scrollable = 7,
        },

        {
            type = "slider",
            name = "Spell Orb Font-Size",
            min = 8,
            max = 100,
            step = 1,
            getFunc = function() return STFU.account.spellOrbFontSize end,
            setFunc = function(v)
                STFU.account.spellOrbFontSize = v
                SpellOrbIndicatorLabel:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', STFU.account.spellOrbFont), STFU.account.spellOrbFontSize, STFU.account.spellOrbFontStyle))
            end
        },

        {
            type = "colorpicker",
            name = "Spell Orb Color",
            getFunc = function() return unpack(STFU.account.spellOrbColor) end,
            setFunc = function(r, g, b, a)
                STFU.account.spellOrbColor = { r, g, b, a }
                SpellOrbIndicatorLabel:SetColor( r, g, b, a )
            end,
        },

        {
            type = "description",
            text = "Unhide the labels or hide them, this is so you can drag them whereever your heart desires or change the color to whatever you want.",
        },

        {
            type = "button",
            name = "Toggle Labels",
            func = STFU.toggleLabels,
            width = "half"
        },
    }

    STFU.addOnPanel = LAM:RegisterAddonPanel(STFU.name.."_LAM", panelData)
    LAM:RegisterOptionControls(STFU.name.."_LAM", optionsTable)
end
