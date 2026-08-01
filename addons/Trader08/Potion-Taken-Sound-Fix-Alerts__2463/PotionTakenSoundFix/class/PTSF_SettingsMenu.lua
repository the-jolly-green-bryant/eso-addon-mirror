if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- LibAddonMenu (LAM) Settings panel
--=============================================================================================================
function PTSF.buildAddonMenu()
    if PTSF.addonMenu == nil then return nil end
    --Local "speed up arrays/tables" variables
    local addonVars =       PTSF.addonVars
    local settings =        PTSF.settingsVars.settings
    local defaults =        PTSF.settingsVars.defaults
    
    local lockSoundPlay_Potion 					= false
    local lockSoundPlay_BuffLost				= false
    local lockSoundPlay_Cooldown 				= false
    local lockSoundPlay_Health 					= false --new 1.08
    local lockSoundPlay_Stamina 				= false	 --new 1.08
    local lockSoundPlay_Magicka					= false --new 1.08

    PTSF.panelData    = {
        type                = "panel",
        name                = addonVars.settingsName.." & Alerts",
        displayName         = addonVars.settingsDisplayName,
        author              = addonVars.addonAuthor,
        version             = tostring(PTSF.addonVars.addonRealVersionPreText..addonVars.addonRealVersion),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/PTSF",
        website             = addonVars.addonWebsite,
        feedback			= addonVars.addonFeedback,
        donation			= addonVars.addonDonate
    }

    local savedVariablesOptions = {
        [1] = "Per character",
        [2] = "Account Wide",
    }
        
    --Create our buffs list options
    local PotionTakenSoundFix_Settings_Potionbufflostfilters_controls = {}
    if PTSF.buffs then
        for i, buff in pairs(PTSF.buffs) do
       		PotionTakenSoundFix_Settings_Potionbufflostfilters_controls[i] = 
       		{
       			type = "checkbox",
       			name = buff.name,
       			tooltip = buff.description,
       			getFunc = function() return settings.buffFilters[buff.name] end,
       			setFunc = function(value)	if(value) then settings.buffFilters[buff.name] = value else settings.buffFilters[buff.name] = nil end end,
       			default = false,
       			width = "half",
       		}
        end
    end
--=============================================================================================================
-- updateDisabledControl {{{
--=============================================================================================================
local function updateDisabledControl(control, soundEnded)
    if(soundEnded) then
    	lockSoundPlay_Potion 	= false
    	lockSoundPlay_BuffLost	= false
    	lockSoundPlay_Cooldown 	= false
		lockSoundPlay_Health 	= false --new 1.08
		lockSoundPlay_Stamina 	= false	 --new 1.08
		lockSoundPlay_Magicka	= false --new 1.08
    end
    if(not control) then
        PTSF.D("No control to update in function updateDisabledControl()!")
        return
    end
    local disable
    if type(control.data.disabled) == "function" then
        disable = control.data.disabled()
    else
        disable = control.data.disabled
    end

    control.slider:SetEnabled(not disable)
    control.slidervalue:SetEditEnabled(not disable)
    if disable then
        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.minText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.maxText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
    else
        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.minText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.maxText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
end --}}}

--=============================================================================================================
-- setControlValues {{{
--=============================================================================================================
local function setControlValues(control, value, doNotPlaySound)
    if(not control) then
        PTSF.D("No control to update in function updateDisabledControl()!")
        return
    end
--    if(control == PotionTakenSoundFix_Settings_potionTakenSound) then --If we're selecting default potion taken sound, volume boost has nothing to do with it so play our "selected" sound
--        control.data.setFunc(value, false)
--    else
        control.data.setFunc(value, doNotPlaySound)
--    end
    control.slider:SetValue(value)
    control.slidervalue:SetText(value)
    --PTSF.addonMenu.util.RequestRefreshIfNeeded(control)
end --}}}

    --=============================================================================================================
    -- Load our custom values into panel {{{
    --=============================================================================================================
    local function addonMenuOnLoadCallback(panel)
        if panel == PTSF.addonMenuPanel then
            --UnRegister the callback for the LAM2 panel created function
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
            --Set the text for the selected sounds
            PotionTakenSoundFix_Settings_potionTakenSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionTakenSound])
            PotionTakenSoundFix_Settings_potionLostBuffSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionLostBuffSound])
            PotionTakenSoundFix_Settings_potionCooldownEndedSound.label:SetText("Sound: " .. PTSF.sounds[settings.potionCooldownEndedSound])
            PotionTakenSoundFix_Settings_lowHealthSound.label:SetText("Sound: " .. PTSF.sounds[settings.lowHealthSound])
            PotionTakenSoundFix_Settings_lowStaminaSound.label:SetText("Sound: " .. PTSF.sounds[settings.lowStaminaSound])
            PotionTakenSoundFix_Settings_lowMagickaSound.label:SetText("Sound: " .. PTSF.sounds[settings.lowMagickaSound])
            --Set the color on dev's fav buttons
            PotionTakenSoundFix_Settings_devPotionTakenButton.button:SetNormalFontColor(0,0.75,0.61,1) --rgba(0, 191, 156, 255)
            PotionTakenSoundFix_Settings_devPotionLostBuffButton.button:SetNormalFontColor(0,0.75,0.61,1)
            PotionTakenSoundFix_Settings_devPotionCooldownEndedButton.button:SetNormalFontColor(0,0.75,0.61,1)
            PotionTakenSoundFix_Settings_devlowHealthButton.button:SetNormalFontColor(0,0.75,0.61,1)
            PotionTakenSoundFix_Settings_devlowStaminaButton.button:SetNormalFontColor(0,0.75,0.61,1)
            PotionTakenSoundFix_Settings_devlowMagickaButton.button:SetNormalFontColor(0,0.75,0.61,1)
            --Set the color on volume boost's warning icons
            PotionTakenSoundFix_Settings_potionTakenVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_lowHealthVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_lowStaminaVolumeBoost.warning:SetColor(1,0.65,0,1)
            PotionTakenSoundFix_Settings_lowMagickaVolumeBoost.warning:SetColor(1,0.65,0,1)
            --1.08 Special slider values
            --Health
            PotionTakenSoundFix_Settings_isOKHealthPercent.slider:SetMinMax(settings.lowHealthPercent, 100)
			PotionTakenSoundFix_Settings_isOKHealthPercent.minText:SetText(settings.lowHealthPercent)
			PotionTakenSoundFix_Settings_isOKHealthPercent:UpdateValue(false, settings.isOKHealthPercent < settings.lowHealthPercent and settings.lowHealthPercent or settings.isOKHealthPercent)
			--Stamina
			PotionTakenSoundFix_Settings_isOKStaminaPercent.slider:SetMinMax(settings.lowStaminaPercent, 100)
			PotionTakenSoundFix_Settings_isOKStaminaPercent.minText:SetText(settings.lowStaminaPercent)
			PotionTakenSoundFix_Settings_isOKStaminaPercent:UpdateValue(false, settings.isOKStaminaPercent < settings.lowStaminaPercent and settings.lowStaminaPercent or settings.isOKStaminaPercent)
			--Magicka
			PotionTakenSoundFix_Settings_isOKMagickaPercent.slider:SetMinMax(settings.lowMagickaPercent, 100)
			PotionTakenSoundFix_Settings_isOKMagickaPercent.minText:SetText(settings.lowMagickaPercent)
			PotionTakenSoundFix_Settings_isOKMagickaPercent:UpdateValue(false, settings.isOKMagickaPercent < settings.lowMagickaPercent and settings.lowMagickaPercent or settings.isOKMagickaPercent)
            --Open the buff filters submenu
            if(settings.enableBuffFilter) then --1.09 and settings.potionLostBuffSound > 2
            	PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               	PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
            end
            --Open the low resources submenu
            if(settings.lowHealthPercent > 0 or settings.lowStaminaPercent > 0 or settings.lowMagickaPercent > 0) then
            	PotionTakenSoundFix_Settings_LowResources_submenu.open = true
               	PotionTakenSoundFix_Settings_LowResources_submenu.animation:PlayFromEnd()
            end
            --Open the accessibility submenu
            if(settings.textToChatEnabled) then
            	PotionTakenSoundFix_Settings_Accessibility_submenu.open = true
               	PotionTakenSoundFix_Settings_Accessibility_submenu.animation:PlayFromEnd()
            end
        end
    end --}}}
    
    --Register the callback for the LAM panel created function
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)

    --=============================================================================================================
    -- Options Panel Data {{{
    --=============================================================================================================

    PTSF.optionsData  = {
    	{
			type = "header",
			name = "|c00FF00NEW FEATURE!|r",
			width = "full",	--or "half" (optional)
        },
        {
            type             = "description",
            text              = "|c00FF00-1.09: Text-to-chat options that can be read by ESO's Accessibility Narrate Chat setting\n-1.10: Performance optimizations + Liquid efficiency fix + Accessibility text color options|r\n\n"
            					.."|cFFFF00----\nFixes potion sound to ONLY play when successfully taken.\n"
           						.."\n"
            					.."Please mouse over \"Unknown Potion Buffs Finder\" under DEBUG for\n"
            					.."instructions if you're using \"Buff Lost Filters\" and are not getting sound"
            					--.."Markarth update (this addon v.1.05) Major re-write\n"
            					--.."-ZOS changed abilities so that most share ID's between potions\n"
            					--.."and skills for the same buff. Potion taken sound does not rely\n"
            					--.."on abilities ID anymore, but on my own logic of events\n"
            					--.."-It also means buff lost sound will not only play for potion buffs\n"
            					--.."like it used to, but also for buffs from any source\n"
            					--.."-If you encounter bugs, please click feedback\n"
            					--.."-If not, click donate mouahaha :P|r",
        },
        
        --=============================================================================================================
        -- Save mode {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Account-wide/per character",
        },
        {
            type = 'dropdown',
            name = "Save as:",
            tooltip = "Save the addon settings per account or for each character",
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[PTSF.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        PTSF.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
            end,
            warning = "CAUTION: Changing the saving mode will cause a reloadui!",
        },
        {
            type = 'description',
            text = "CAUTION: Changing the saving mode will cause a reloadui!",
        }, --}}}

        --=============================================================================================================
        -- Potion Taken {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound to play |l1:1:0:5%:8:FF0000|lONLY|l when a |cFFFF00potion|r is taken",
        },
        {
            type = 'description',
            text = "|cFFFF00You can use the mouse scroll wheel to slide!|r",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound to confirm your |cFFFF00potion|r has been taken successfully.\n\nSlide to 2 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds,
            getFunc = function()
                return settings.potionTakenSound
            end,
            setFunc = function(idx, doNotPlaySound)
                settings.potionTakenSound = idx
                PotionTakenSoundFix_Settings_potionTakenSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                 if SOUNDS ~= nil then
                    if(idx == 1 and SOUNDS[PTSF.sounds[idx]] == nil) then --Default ESO potion taken sound
                    	PTSF.D("Played: DEFAULT potion sound")
                    	PlayItemSound(ITEM_SOUND_CATEGORY_POTION, ITEM_SOUND_ACTION_USE, true)
                    elseif(idx ~= 2 and SOUNDS[PTSF.sounds[idx]] ~= nil and not doNotPlaySound) then
                    	PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                    	PlaySound(SOUNDS[PTSF.sounds[idx]])
                    end
                 end
            end,
            default = defaults.potionTakenSound,
            reference = "PotionTakenSoundFix_Settings_potionTakenSound",
        },

        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionTakenVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionTakenVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionTakenSound > 2 and SOUNDS[PTSF.sounds[settings.potionTakenSound]] ~= nil) then
                    for i = 1, idy do
                    	PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                        PlaySound(SOUNDS[PTSF.sounds[settings.potionTakenSound]])
                    end
                    lockSoundPlay_Potion = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, lockSoundPlay_Potion) end, 1000)
                end
            end,
            disabled = function() return settings.potionTakenSound <= 2 or lockSoundPlay_Potion end,
            default = defaults.potionTakenVolumeBoost,
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
            reference = "PotionTakenSoundFix_Settings_potionTakenVolumeBoost",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionTakenSound, PTSF.settingsVars.defaults.potionTakenSound, true) setControlValues(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, PTSF.settingsVars.defaults.potionTakenVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "|c00BF9CDev's Fav|r",
            tooltip = "Set "..addonVars.addonAuthor.."'s favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionTakenSound, 21, true) setControlValues(PotionTakenSoundFix_Settings_potionTakenVolumeBoost, 2) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionTakenButton",
        }, --}}}

        --=============================================================================================================
        -- Potion Buff Lost {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound when you lose a |cFFFF00potion|r buff",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound every time you lose a |cFFFF00potion|r buff (Major Intellect, Major Fortitude, Major Endurance, Immovable, etc.)\n\nSlide to 1 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds-1,
            getFunc = function()
                return settings.potionLostBuffSound - 1
            end,
            setFunc = function(idx, doNotPlaySound)
                idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
                settings.potionLostBuffSound = idx
                PotionTakenSoundFix_Settings_potionLostBuffSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                --Update our buff list submenu
                if(idx > 2 and settings.enableBuffFilter and not PotionTakenSoundFix_Settings_Potionbufflostfilters.open) then
               		PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               		PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
                end
                 if SOUNDS ~= nil and not doNotPlaySound then
                   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
                       PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                       PlaySound(SOUNDS[PTSF.sounds[idx]])
                   end
                 end
            end,
            default = defaults.potionLostBuffSound,
            reference = "PotionTakenSoundFix_Settings_potionLostBuffSound",
        },
        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionLostBuffVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionLostBuffVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionLostBuffSound > 2 and SOUNDS[PTSF.sounds[settings.potionLostBuffSound]] ~= nil) then
                    for i = 1, idy do
                       PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                       PlaySound(SOUNDS[PTSF.sounds[settings.potionLostBuffSound]])
                    end
                    lockSoundPlay_BuffLost = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, lockSoundPlay_BuffLost) end, 1000)
                end
            end,
            disabled = function() return settings.potionLostBuffSound <= 2 or lockSoundPlay_BuffLost end,
            default = defaults.potionLostBuffVolumeBoost,
            reference = "PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost",
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionLostBuffSound, PTSF.settingsVars.defaults.potionLostBuffSound, true) setControlValues(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, PTSF.settingsVars.defaults.potionLostBuffVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "|c00BF9CDev's Fav|r",
            tooltip = "Set "..addonVars.addonAuthor.."'s favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionLostBuffSound, 18, true) setControlValues(PotionTakenSoundFix_Settings_potionLostBuffVolumeBoost, 3) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionLostBuffButton",
        },
            {
            	type = "checkbox",
            	name = "Enable Buff Lost Sound and/or Text-to-chat",
            	tooltip = "Enabling this will play the buff lost sound ONLY for selected buffs, gained from any source\n\nI do not guarantee they all work and can't easily filter for buffs only gained by |cFFFF00potions|r anymore",
            	getFunc = function() return settings.enableBuffFilter end,
            	setFunc = function(value)
               		settings.enableBuffFilter = value
                	PTSF.toggle_buff_filters(value)
               		if(value) then --Open the buff filters submenu
               			PotionTakenSoundFix_Settings_Potionbufflostfilters.open = true
               			PotionTakenSoundFix_Settings_Potionbufflostfilters.animation:PlayFromEnd()
               		end
               	end,
               	disabled = function() return settings.potionLostBuffSound <= 2 and not settings.textToChatEnabled end,
               	default = defaults.enableBuffFilter,
               	width = "full",
            },
        {
            type = "submenu",
            name = "Buff lost filters",
            tooltip = "Allows filtering lost buff sound to play for specific buffs only. Applies to buffs gained from any source\n\nI do not guarantee they all work and can't easily filter for buffs only gained by |cFFFF00potions|r anymore",
            disabled = function() return not settings.enableBuffFilter or (settings.potionLostBuffSound <= 2 and not settings.textToChatEnabled) end,
            reference = "PotionTakenSoundFix_Settings_Potionbufflostfilters",
            controls = PotionTakenSoundFix_Settings_Potionbufflostfilters_controls,
        }, --submenu

        --=============================================================================================================
        -- Potion Cooldown Ended {{{
        --=============================================================================================================
        {
            type = 'header',
            name = "Sound when |cFFFF00potion|r cooldown is over",
        },
        {
            type = 'slider',
            name = "Sound:",
            tooltip = "Plays this sound when you can take another |cFFFF00potion|r.\n\nSlide to 1 (NONE) if you don't want to hear any sound!",
            min = 1,
            max = #PTSF.sounds-1,
            getFunc = function()
                return settings.potionCooldownEndedSound - 1
            end,
            setFunc = function(idx, doNotPlaySound)
                idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
                settings.potionCooldownEndedSound = idx
                PotionTakenSoundFix_Settings_potionCooldownEndedSound.label:SetText("Sound: " .. PTSF.sounds[idx])
                 if SOUNDS ~= nil and not doNotPlaySound then --Minor bug: "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
                   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
                    	PlaySound(SOUNDS[PTSF.sounds[idx]])
                    	PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                    end
                 end
            end,
            default = defaults.potionCooldownEndedSound,
            reference = "PotionTakenSoundFix_Settings_potionCooldownEndedSound",
        },
        {
            type = 'slider',
            name = "Volume Booster",
            tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
            min = 1,
            max = 10,
            getFunc = function()
                return settings.potionCooldownEndedVolumeBoost
            end,
            setFunc = function(idy)
            settings.potionCooldownEndedVolumeBoost = idy
                if(SOUNDS ~= nil and settings.potionCooldownEndedSound > 2 and SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]] ~= nil) then
                    for i = 1, idy do
                       PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                       PlaySound(SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]])
                    end
                    lockSoundPlay_Cooldown = true
                    zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, lockSoundPlay_Cooldown) end, 1000)
                end
            end,
            disabled = function() return settings.potionCooldownEndedSound <= 2 or lockSoundPlay_Cooldown end,
            default = defaults.potionCooldownEndedVolumeBoost,
            reference = "PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost",
            warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
        },
        {
            type = "button",
            name = "Addon's Default",
            tooltip = "Set this addon's default values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedSound, PTSF.settingsVars.defaults.potionCooldownEndedSound, true) setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, PTSF.settingsVars.defaults.potionCooldownEndedVolumeBoost) end,
            width = "half",
        },
        {
            type = "button",
            name = "|c00BF9CDev's Fav|r",
            tooltip = "Set "..addonVars.addonAuthor.."'s favorite values",
            func = function() setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedSound, 26, true) setControlValues(PotionTakenSoundFix_Settings_potionCooldownEndedVolumeBoost, 4) end,
            width = "half",
            reference = "PotionTakenSoundFix_Settings_devPotionCooldownEndedButton",
        }, --}}}
        
        --=============================================================================================================
        -- Low Resource(s) {{{
        --=============================================================================================================
        {
        	type = "divider",
        	width = "full",
        	height = 20,
        	alpha = 1,
        },
        {
            type = "submenu",
            name = "Low Resources",
            tooltip = "Sound and/or auto quickslot select when low on health/Stamina/Magicka",
            --disabled = function() return not settings.enableBuffFilter or settings.potionLostBuffSound <= 2 end,
            reference = "PotionTakenSoundFix_Settings_LowResources_submenu",
            --controls = PotionTakenSoundFix_Settings_LowResources_controls,
            controls = {
            	--In-Combat Only
            	{
					type = "checkbox",
					name = "In-Combat Only",
					tooltip = "Enable low resources functionalities only while in combat\n\nYou generally want this on",
					getFunc = function() return settings.lowRessoucesOnlyInCombat end,
					setFunc = function(value)
							settings.lowRessoucesOnlyInCombat = value
					end,
					default = true,
               	},
            	{
					type = 'header',
					name = "|cCC0000Low Health|r",
				},
				{
					type = 'slider',
					name = "Low |cCC0000Health|r Threshold:",
					tooltip = "Plays selected sound and/or auto-quickslot when your |cCC0000Health|r is at or below this %\n\nSlide to 0 to disable",
					min = 0,
					max = 99,
					getFunc = function()
						if(settings.lowHealthPercent == 0) then
							PotionTakenSoundFix_Settings_lowHealthPercent.label:SetText("Low |cCC0000Health|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowHealthPercent.label:SetText("Low |cCC0000Health|r Threshold: <=" .. settings.lowHealthPercent .. "%")
						end
						return settings.lowHealthPercent
					end,
					setFunc = function(idx)
						settings.lowHealthPercent = idx
						PTSF.register_or_unregister_low_resources_events()
						--if(settings.isOKHealthPercent < idx) then
						--	settings.isOKHealthPercent = idx
						--end
						PotionTakenSoundFix_Settings_isOKHealthPercent.slider:SetMinMax(idx, 100)
						PotionTakenSoundFix_Settings_isOKHealthPercent.minText:SetText(idx)
						PotionTakenSoundFix_Settings_isOKHealthPercent:UpdateValue(false, settings.isOKHealthPercent < idx and idx or settings.isOKHealthPercent)
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowHealthPercent.label:SetText("Low |cCC0000Health|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowHealthPercent.label:SetText("Low |cCC0000Health|r Threshold: <=" .. idx .. "%")
						end
					end,
					default = defaults.lowHealthPercent,
					reference = "PotionTakenSoundFix_Settings_lowHealthPercent",
				},
				{
					type = 'slider',
					name = "OK |cCC0000Health|r Threshold:",
					tooltip = "Will need this much |cCC0000Health|r % to get out of low |cCC0000Health|r condition. When |cCC0000Health|r varies up and down quickly, it helps minimizing repeated sound/auto-quickslot calls.\n\nToo high might prevent desired subsequent warnings and since |cCC0000Health|r is #1 priority, might also prevent desired stamina/magicka auto-quickslotting.\n\nSlide equal to Low |cCC0000Health|r Threshold to disable",
					min = 1, --settings.lowHealthPercent or 
					max = 100,
					getFunc = function()
						if(settings.isOKHealthPercent == settings.lowHealthPercent) then
							PotionTakenSoundFix_Settings_isOKHealthPercent.label:SetText("OK |cCC0000Health|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKHealthPercent.label:SetText("OK |cCC0000Health|r Threshold: >=" .. settings.isOKHealthPercent .. "%")
						end
						return settings.isOKHealthPercent
					end,
					setFunc = function(idx)
						settings.isOKHealthPercent = idx
						if(idx == settings.lowHealthPercent) then
							PotionTakenSoundFix_Settings_isOKHealthPercent.label:SetText("OK |cCC0000Health|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKHealthPercent.label:SetText("OK |cCC0000Health|r Threshold: >=" .. idx .. "%")
						end
					end,
					disabled = function() return settings.lowHealthPercent == 0 end,
					default = defaults.isOKHealthPercent,
					reference = "PotionTakenSoundFix_Settings_isOKHealthPercent",
				},
				{
					type = 'slider',
					name = "Anti-Repeat Delay:",
					tooltip = "When quickly switching from low to OK to low resource condition, delays repeating sound/auto-quickslot by this many seconds",
					min = 0, --settings.lowHealthPercent or 
					max = 30,
					getFunc = function()
						if(settings.isOKHealthRepeatDelay == 0) then
							PotionTakenSoundFix_Settings_isOKHealthRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKHealthRepeatDelay.label:SetText("Anti-Repeat Delay: " .. settings.isOKHealthRepeatDelay .. "s")
						end
						return settings.isOKHealthRepeatDelay
					end,
					setFunc = function(idx)
						settings.isOKHealthRepeatDelay = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_isOKHealthRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKHealthRepeatDelay.label:SetText("Anti-Repeat Delay: " .. idx .. "s")
						end
					end,
					disabled = function() return settings.lowHealthPercent == 0 end,
					default = defaults.isOKHealthRepeatDelay,
					reference = "PotionTakenSoundFix_Settings_isOKHealthRepeatDelay",
				},
				{
					type = 'slider',
					name = "Low |cCC0000Health|r Auto-Select Quickslot:",
					tooltip = "Will auto-select quickslot, 1 is topmost (noon) going clockwise up to 8\n\nIf more than 1 resource becomes low, priority order is:\n1-|cCC0000Health|r\n2-|c4F9A95Stamina|r\n3-|c5882B7Magicka|r\n\nIt will auto-select this quickslot every time you hear the low |cCC0000Health|r sound\n\nSlide to 0 to disable",
					min = 0,
					max = 8,
					getFunc = function()
						if(settings.lowHealthAutoSlot == 0) then
							PotionTakenSoundFix_Settings_lowHealthAutoSlot.label:SetText("Low |cCC0000Health|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowHealthAutoSlot.label:SetText("Low |cCC0000Health|r Auto-Select Quickslot: " .. settings.lowHealthAutoSlot)
						end
						return settings.lowHealthAutoSlot
					end,
					setFunc = function(idx)
						settings.lowHealthAutoSlot = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowHealthAutoSlot.label:SetText("Low |cCC0000Health|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowHealthAutoSlot.label:SetText("Low |cCC0000Health|r Auto-Select Quickslot: " .. idx)
						end
					end,
					disabled = function() return settings.lowHealthPercent == 0 end,
					default = defaults.lowHealthAutoSlot,
					reference = "PotionTakenSoundFix_Settings_lowHealthAutoSlot",
				},
				--Low Health sound
				{
					type = 'slider',
					name = "Sound:",
					tooltip = "Plays this sound when your |cCC0000Health|r reaches selected Low |cCC0000Health|r Threshold %\n\nSlide to 1 (NONE) to disable",
					min = 1,
					max = #PTSF.sounds-1,
					getFunc = function()
						return settings.lowHealthSound - 1
					end,
					setFunc = function(idx, doNotPlaySound)
						idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
						settings.lowHealthSound = idx
						PotionTakenSoundFix_Settings_lowHealthSound.label:SetText("Sound: " .. PTSF.sounds[idx])
						 if SOUNDS ~= nil and not doNotPlaySound then --Minor bug: "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
						   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
								PlaySound(SOUNDS[PTSF.sounds[idx]])
								PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.lowHealthSound]])
							end
						 end
					end,
					disabled = function() return settings.lowHealthPercent == 0 end,
					default = defaults.lowHealthSound,
					reference = "PotionTakenSoundFix_Settings_lowHealthSound",
				},
				{
					type = 'slider',
					name = "Volume Booster",
					tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
					min = 1,
					max = 10,
					getFunc = function()
						return settings.lowHealthVolumeBoost
					end,
					setFunc = function(idy)
					settings.lowHealthVolumeBoost = idy
						if(SOUNDS ~= nil and settings.lowHealthSound > 2 and SOUNDS[PTSF.sounds[settings.lowHealthSound]] ~= nil) then
							for i = 1, idy do
							   PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.lowHealthSound]])
							   PlaySound(SOUNDS[PTSF.sounds[settings.lowHealthSound]])
							end
							lockSoundPlay_Health = true
							zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_lowHealthVolumeBoost, lockSoundPlay_Health) end, 1000)
						end
					end,
					disabled = function() return settings.lowHealthSound <= 2 or lockSoundPlay_Health or settings.lowHealthPercent == 0 end,
					default = defaults.lowHealthVolumeBoost,
					reference = "PotionTakenSoundFix_Settings_lowHealthVolumeBoost",
					warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
				},
				{
					type = "button",
					name = "Addon's Default",
					tooltip = "Set this addon's default values",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowHealthPercent, PTSF.settingsVars.defaults.lowHealthPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKHealthPercent, PTSF.settingsVars.defaults.isOKHealthPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKHealthRepeatDelay, PTSF.settingsVars.defaults.isOKHealthRepeatDelay, true) setControlValues(PotionTakenSoundFix_Settings_lowHealthAutoSlot, PTSF.settingsVars.defaults.lowHealthAutoSlot, true) setControlValues(PotionTakenSoundFix_Settings_lowHealthSound, PTSF.settingsVars.defaults.lowHealthSound, true) setControlValues(PotionTakenSoundFix_Settings_lowHealthVolumeBoost, PTSF.settingsVars.defaults.lowHealthVolumeBoost) end,
					width = "half",
				},
				{
					type = "button",
					name = "|c00BF9CDev's Fav|r",
					tooltip = "Set "..addonVars.addonAuthor.."'s favorite values",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowHealthPercent, 40, true) setControlValues(PotionTakenSoundFix_Settings_isOKHealthPercent, 90, true) setControlValues(PotionTakenSoundFix_Settings_isOKHealthRepeatDelay, 3, true) setControlValues(PotionTakenSoundFix_Settings_lowHealthSound, 59, true) setControlValues(PotionTakenSoundFix_Settings_lowHealthVolumeBoost, 5) end,
					width = "half",
					reference = "PotionTakenSoundFix_Settings_devlowHealthButton",
				}, --}}}
				--Stamina
            	{
					type = 'header',
					name = "|c4F9A95Low Stamina|r",
				},
				{
					type = 'slider',
					name = "Low |c4F9A95Stamina|r Threshold:",
					tooltip = "Plays selected sound and/or auto-quickslot when your |c4F9A95Stamina|r is at or below this %\n\nA good starting point is to set this at a % where you can cast your last |c4F9A95Stamina|r skill. OK |c4F9A95Stamina|r Threshold to same % and Delay to 0. This way, every time you hear the sound you'll know you won't be able to cast until regen. But it's all up to you!\n\nSlide to 0 to disable",
					min = 0,
					max = 99,
					getFunc = function()
						if(settings.lowStaminaPercent == 0) then
							PotionTakenSoundFix_Settings_lowStaminaPercent.label:SetText("Low |c4F9A95Stamina|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowStaminaPercent.label:SetText("Low |c4F9A95Stamina|r Threshold: <=" .. settings.lowStaminaPercent .. "%")
						end
						return settings.lowStaminaPercent
					end,
					setFunc = function(idx)
						settings.lowStaminaPercent = idx
						PTSF.register_or_unregister_low_resources_events()
						--if(settings.isOKStaminaPercent < idx) then
						--	settings.isOKStaminaPercent = idx
						--end
						PotionTakenSoundFix_Settings_isOKStaminaPercent.slider:SetMinMax(idx, 100)
						PotionTakenSoundFix_Settings_isOKStaminaPercent.minText:SetText(idx)
						PotionTakenSoundFix_Settings_isOKStaminaPercent:UpdateValue(false, settings.isOKStaminaPercent < idx and idx or settings.isOKStaminaPercent)
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowStaminaPercent.label:SetText("Low |c4F9A95Stamina|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowStaminaPercent.label:SetText("Low |c4F9A95Stamina|r Threshold: <=" .. idx .. "%")
						end
					end,
					default = defaults.lowStaminaPercent,
					reference = "PotionTakenSoundFix_Settings_lowStaminaPercent",
				},
				{
					type = 'slider',
					name = "OK |c4F9A95Stamina|r Threshold:",
					tooltip = "Will need this much |c4F9A95Stamina|r % to get out of low |c4F9A95Stamina|r condition. When |c4F9A95Stamina|r varies up and down quickly, it helps minimizing repeated sound/auto-quickslot calls.\n\nToo high might prevent desired subsequent warnings and since |c4F9A95Stamina|r is #2 priority, might also prevent desired magicka auto-quickslotting.\n\nSlide equal to Low |c4F9A95Stamina|r Threshold to disable",
					min = 1, --settings.lowStaminaPercent or 
					max = 100,
					getFunc = function()
						if(settings.isOKStaminaPercent == settings.lowStaminaPercent) then
							PotionTakenSoundFix_Settings_isOKStaminaPercent.label:SetText("OK |c4F9A95Stamina|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKStaminaPercent.label:SetText("OK |c4F9A95Stamina|r Threshold: >=" .. settings.isOKStaminaPercent .. "%")
						end
						return settings.isOKStaminaPercent
					end,
					setFunc = function(idx)
						settings.isOKStaminaPercent = idx
						if(idx == settings.lowStaminaPercent) then
							PotionTakenSoundFix_Settings_isOKStaminaPercent.label:SetText("OK |c4F9A95Stamina|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKStaminaPercent.label:SetText("OK |c4F9A95Stamina|r Threshold: >=" .. idx .. "%")
						end
					end,
					disabled = function() return settings.lowStaminaPercent == 0 end,
					default = defaults.isOKStaminaPercent,
					reference = "PotionTakenSoundFix_Settings_isOKStaminaPercent",
				},
				{
					type = 'slider',
					name = "Anti-Repeat Delay:",
					tooltip = "When quickly switching from low to OK to low resource condition, delays repeating sound/auto-quickslot by this many seconds",
					min = 0, --settings.lowStaminaPercent or 
					max = 30,
					getFunc = function()
						if(settings.isOKStaminaRepeatDelay == 0) then
							PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay.label:SetText("Anti-Repeat Delay: " .. settings.isOKStaminaRepeatDelay .. "s")
						end
						return settings.isOKStaminaRepeatDelay
					end,
					setFunc = function(idx)
						settings.isOKStaminaRepeatDelay = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay.label:SetText("Anti-Repeat Delay: " .. idx .. "s")
						end
					end,
					disabled = function() return settings.lowStaminaPercent == 0 end,
					default = defaults.isOKStaminaRepeatDelay,
					reference = "PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay",
				},
				{
					type = 'slider',
					name = "Low |c4F9A95Stamina|r Auto-Select Quickslot:",
					tooltip = "Will auto-select quickslot, 1 is topmost (noon) going clockwise up to 8\n\nIf more than 1 resource becomes low, priority order is:\n1-|cCC0000Health|r\n2-|c4F9A95Stamina|r\n3-|c5882B7Magicka|r\n\nIt will auto-select this quickslot every time you hear the low |c4F9A95Stamina|r sound, unless there is already a low |cCC0000Health|r condition AND quickslotting is enabled on low |cCC0000Health|r\n\nSlide to 0 to disable",
					min = 0,
					max = 8,
					getFunc = function()
						if(settings.lowStaminaAutoSlot == 0) then
							PotionTakenSoundFix_Settings_lowStaminaAutoSlot.label:SetText("Low |c4F9A95Stamina|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowStaminaAutoSlot.label:SetText("Low |c4F9A95Stamina|r Auto-Select Quickslot: " .. settings.lowStaminaAutoSlot)
						end
						return settings.lowStaminaAutoSlot
					end,
					setFunc = function(idx)
						settings.lowStaminaAutoSlot = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowStaminaAutoSlot.label:SetText("Low |c4F9A95Stamina|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowStaminaAutoSlot.label:SetText("Low |c4F9A95Stamina|r Auto-Select Quickslot: " .. idx)
						end
					end,
					disabled = function() return settings.lowStaminaPercent == 0 end,
					default = defaults.lowStaminaAutoSlot,
					reference = "PotionTakenSoundFix_Settings_lowStaminaAutoSlot",
				},
				--Low Stamina sound
				{
					type = 'slider',
					name = "Sound:",
					tooltip = "Plays this sound when your |c4F9A95Stamina|r reaches selected Low |c4F9A95Stamina|r Threshold %\n\nSlide to 1 (NONE) to disable",
					min = 1,
					max = #PTSF.sounds-1,
					getFunc = function()
						return settings.lowStaminaSound - 1
					end,
					setFunc = function(idx, doNotPlaySound)
						idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
						settings.lowStaminaSound = idx
						PotionTakenSoundFix_Settings_lowStaminaSound.label:SetText("Sound: " .. PTSF.sounds[idx])
						 if SOUNDS ~= nil and not doNotPlaySound then --Minor bug: "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
						   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
								PlaySound(SOUNDS[PTSF.sounds[idx]])
								PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.lowStaminaSound]])
							end
						 end
					end,
					disabled = function() return settings.lowStaminaPercent == 0 end,
					default = defaults.lowStaminaSound,
					reference = "PotionTakenSoundFix_Settings_lowStaminaSound",
				},
				{
					type = 'slider',
					name = "Volume Booster",
					tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
					min = 1,
					max = 10,
					getFunc = function()
						return settings.lowStaminaVolumeBoost
					end,
					setFunc = function(idy)
					settings.lowStaminaVolumeBoost = idy
						if(SOUNDS ~= nil and settings.lowStaminaSound > 2 and SOUNDS[PTSF.sounds[settings.lowStaminaSound]] ~= nil) then
							for i = 1, idy do
							   PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.lowStaminaSound]])
							   PlaySound(SOUNDS[PTSF.sounds[settings.lowStaminaSound]])
							end
							lockSoundPlay_Stamina = true
							zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_lowStaminaVolumeBoost, lockSoundPlay_Stamina) end, 1000)
						end
					end,
					disabled = function() return settings.lowStaminaSound <= 2 or lockSoundPlay_Stamina or settings.lowStaminaPercent == 0 end,
					default = defaults.lowStaminaVolumeBoost,
					reference = "PotionTakenSoundFix_Settings_lowStaminaVolumeBoost",
					warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
				},
				{
					type = "button",
					name = "Addon's Default",
					tooltip = "Set this addon's default values",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowStaminaPercent, PTSF.settingsVars.defaults.lowStaminaPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKStaminaPercent, PTSF.settingsVars.defaults.isOKStaminaPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay, PTSF.settingsVars.defaults.isOKStaminaRepeatDelay, true) setControlValues(PotionTakenSoundFix_Settings_lowStaminaAutoSlot, PTSF.settingsVars.defaults.lowStaminaAutoSlot, true) setControlValues(PotionTakenSoundFix_Settings_lowStaminaSound, PTSF.settingsVars.defaults.lowStaminaSound, true) setControlValues(PotionTakenSoundFix_Settings_lowStaminaVolumeBoost, PTSF.settingsVars.defaults.lowStaminaVolumeBoost) end,
					width = "half",
				},
				{
					type = "button",
					name = "|c00BF9CDev's Fav|r",
					tooltip = "Set "..addonVars.addonAuthor.."'s favorite values\n\nThresholds based off a |c4F9A95stam|r build",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowStaminaPercent, 13, true) setControlValues(PotionTakenSoundFix_Settings_isOKStaminaPercent, 33, true) setControlValues(PotionTakenSoundFix_Settings_isOKStaminaRepeatDelay, 3, true) setControlValues(PotionTakenSoundFix_Settings_lowStaminaSound, 44, true) setControlValues(PotionTakenSoundFix_Settings_lowStaminaVolumeBoost, 2) end,
					width = "half",
					reference = "PotionTakenSoundFix_Settings_devlowStaminaButton",
				}, --}}}
				--Magicka
            	{
					type = 'header',
					name = "|c5882B7Low Magicka|r",
				},
				{
					type = 'slider',
					name = "Low |c5882B7Magicka|r Threshold:",
					tooltip = "Plays selected sound and/or auto-quickslot when your |c5882B7Magicka|r is at or below this %\n\nA good starting point is to set this at a % where you can cast your last |c5882B7Magicka|r skill. OK |c5882B7Magicka|r Threshold to same % and Delay to 0. This way, every time you hear the sound you'll know you won't be able to cast until regen. But it's all up to you!\n\nSlide to 0 to disable",
					min = 0,
					max = 99,
					getFunc = function()
						if(settings.lowMagickaPercent == 0) then
							PotionTakenSoundFix_Settings_lowMagickaPercent.label:SetText("Low |c5882B7Magicka|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowMagickaPercent.label:SetText("Low |c5882B7Magicka|r Threshold: <=" .. settings.lowMagickaPercent .. "%")
						end
						return settings.lowMagickaPercent
					end,
					setFunc = function(idx)
						settings.lowMagickaPercent = idx
						PTSF.register_or_unregister_low_resources_events()
						--if(settings.isOKMagickaPercent < idx) then
						--	settings.isOKMagickaPercent = idx
						--end
						PotionTakenSoundFix_Settings_isOKMagickaPercent.slider:SetMinMax(idx, 100)
						PotionTakenSoundFix_Settings_isOKMagickaPercent.minText:SetText(idx)
						PotionTakenSoundFix_Settings_isOKMagickaPercent:UpdateValue(false, settings.isOKMagickaPercent < idx and idx or settings.isOKMagickaPercent)
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowMagickaPercent.label:SetText("Low |c5882B7Magicka|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowMagickaPercent.label:SetText("Low |c5882B7Magicka|r Threshold: <=" .. idx .. "%")
						end
					end,
					default = defaults.lowMagickaPercent,
					reference = "PotionTakenSoundFix_Settings_lowMagickaPercent",
				},
				{
					type = 'slider',
					name = "OK |c5882B7Magicka|r Threshold:",
					tooltip = "Will need this much |c5882B7Magicka|r % to get out of low |c5882B7Magicka|r condition. When |c5882B7Magicka|r varies up and down quickly, it helps minimizing repeated sound/auto-quickslot calls.\n\nToo high might prevent desired subsequent warnings.\n\nSlide equal to Low |c5882B7Magicka|r Threshold to disable",
					min = 1, --settings.lowMagickaPercent or 
					max = 100,
					getFunc = function()
						if(settings.isOKMagickaPercent == settings.lowMagickaPercent) then
							PotionTakenSoundFix_Settings_isOKMagickaPercent.label:SetText("OK |c5882B7Magicka|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKMagickaPercent.label:SetText("OK |c5882B7Magicka|r Threshold: >=" .. settings.isOKMagickaPercent .. "%")
						end
						return settings.isOKMagickaPercent
					end,
					setFunc = function(idx)
						settings.isOKMagickaPercent = idx
						if(idx == settings.lowMagickaPercent) then
							PotionTakenSoundFix_Settings_isOKMagickaPercent.label:SetText("OK |c5882B7Magicka|r Threshold: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKMagickaPercent.label:SetText("OK |c5882B7Magicka|r Threshold: >=" .. idx .. "%")
						end
					end,
					disabled = function() return settings.lowMagickaPercent == 0 end,
					default = defaults.isOKMagickaPercent,
					reference = "PotionTakenSoundFix_Settings_isOKMagickaPercent",
				},
				{
					type = 'slider',
					name = "Anti-Repeat Delay:",
					tooltip = "When quickly switching from low to OK to low resource condition, delays repeating sound/auto-quickslot by this many seconds",
					min = 0, --settings.lowMagickaPercent or 
					max = 30,
					getFunc = function()
						if(settings.isOKMagickaRepeatDelay == 0) then
							PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay.label:SetText("Anti-Repeat Delay: " .. settings.isOKMagickaRepeatDelay .. "s")
						end
						return settings.isOKMagickaRepeatDelay
					end,
					setFunc = function(idx)
						settings.isOKMagickaRepeatDelay = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay.label:SetText("Anti-Repeat Delay: (Disabled)")
						else
							PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay.label:SetText("Anti-Repeat Delay: " .. idx .. "s")
						end
					end,
					disabled = function() return settings.lowMagickaPercent == 0 end,
					default = defaults.isOKMagickaRepeatDelay,
					reference = "PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay",
				},
				{
					type = 'slider',
					name = "Low |c5882B7Magicka|r Auto-Select Quickslot:",
					tooltip = "Will auto-select quickslot, 1 is topmost (noon) going clockwise up to 8\n\nIf more than 1 resource becomes low, priority order is:\n1-|cCC0000Health|r\n2-|c4F9A95Stamina|r\n3-|c5882B7Magicka|r\n\nIt will auto-select this quickslot every time you hear the low |c5882B7Magicka|r sound, unless there is already low |cCC0000Health|r and/or low |c4F9A95Stamina|r condition(s) AND they have their auto-quickslotting enabled\n\nEXAMPLE:\nIf you disable |c4F9A95Stamina|r auto-quickslotting, then auto-quickslot priority becomes:\n1-|cCC0000Health|r\n2-|c5882B7Magicka|r\n\nSlide to 0 to disable",
					min = 0,
					max = 8,
					getFunc = function()
						if(settings.lowMagickaAutoSlot == 0) then
							PotionTakenSoundFix_Settings_lowMagickaAutoSlot.label:SetText("Low |c5882B7Magicka|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowMagickaAutoSlot.label:SetText("Low |c5882B7Magicka|r Auto-Select Quickslot: " .. settings.lowMagickaAutoSlot)
						end
						return settings.lowMagickaAutoSlot
					end,
					setFunc = function(idx)
						settings.lowMagickaAutoSlot = idx
						if(idx == 0) then
							PotionTakenSoundFix_Settings_lowMagickaAutoSlot.label:SetText("Low |c5882B7Magicka|r Auto-Select Quickslot: (Disabled)")
						else
							PotionTakenSoundFix_Settings_lowMagickaAutoSlot.label:SetText("Low |c5882B7Magicka|r Auto-Select Quickslot: " .. idx)
						end
					end,
					disabled = function() return settings.lowMagickaPercent == 0 end,
					default = defaults.lowMagickaAutoSlot,
					reference = "PotionTakenSoundFix_Settings_lowMagickaAutoSlot",
				},
				--Low Magicka sound
				{
					type = 'slider',
					name = "Sound:",
					tooltip = "Plays this sound when your |c5882B7Magicka|r reaches selected Low |c5882B7Magicka|r Threshold %\n\nSlide to 1 (NONE) to disable",
					min = 1,
					max = #PTSF.sounds-1,
					getFunc = function()
						return settings.lowMagickaSound - 1
					end,
					setFunc = function(idx, doNotPlaySound)
						idx = idx + 1 --Tricking the system so we don't use sound #1 as it's default potion sound
						settings.lowMagickaSound = idx
						PotionTakenSoundFix_Settings_lowMagickaSound.label:SetText("Sound: " .. PTSF.sounds[idx])
						 if SOUNDS ~= nil and not doNotPlaySound then --Minor bug: "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
						   if(idx > 2 and SOUNDS[PTSF.sounds[idx]] ~= nil) then
								PlaySound(SOUNDS[PTSF.sounds[idx]])
								PTSF.D("Played: "..SOUNDS[PTSF.sounds[settings.lowMagickaSound]])
							end
						 end
					end,
					disabled = function() return settings.lowMagickaPercent == 0 end,
					default = defaults.lowMagickaSound,
					reference = "PotionTakenSoundFix_Settings_lowMagickaSound",
				},
				{
					type = 'slider',
					name = "Volume Booster",
					tooltip = "Boost this sound's volume by a factor of this slider value\n\n|cFFA500Please see WARNING (triangle)|r",
					min = 1,
					max = 10,
					getFunc = function()
						return settings.lowMagickaVolumeBoost
					end,
					setFunc = function(idy)
					settings.lowMagickaVolumeBoost = idy
						if(SOUNDS ~= nil and settings.lowMagickaSound > 2 and SOUNDS[PTSF.sounds[settings.lowMagickaSound]] ~= nil) then
							for i = 1, idy do
							   PTSF.D(i.."-LoopPlayed: "..SOUNDS[PTSF.sounds[settings.lowMagickaSound]])
							   PlaySound(SOUNDS[PTSF.sounds[settings.lowMagickaSound]])
							end
							lockSoundPlay_Magicka = true
							zo_callLater(function() updateDisabledControl(PotionTakenSoundFix_Settings_lowMagickaVolumeBoost, lockSoundPlay_Magicka) end, 1000)
						end
					end,
					disabled = function() return settings.lowMagickaSound <= 2 or lockSoundPlay_Magicka or settings.lowMagickaPercent == 0 end,
					default = defaults.lowMagickaVolumeBoost,
					reference = "PotionTakenSoundFix_Settings_lowMagickaVolumeBoost",
					warning = "|cFFA500WARNING:|r This is meant to help boost up the volume of softer sounds, but seriously watch your speakers cranking it up on an already loud sound\n\nGenerally speaking, a boost of up to 6 is a lot, please be cautious!",
				},
				{
					type = "button",
					name = "Addon's Default",
					tooltip = "Set this addon's default values",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowMagickaPercent, PTSF.settingsVars.defaults.lowMagickaPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKMagickaPercent, PTSF.settingsVars.defaults.isOKMagickaPercent, true) setControlValues(PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay, PTSF.settingsVars.defaults.isOKMagickaRepeatDelay, true) setControlValues(PotionTakenSoundFix_Settings_lowMagickaAutoSlot, PTSF.settingsVars.defaults.lowMagickaAutoSlot, true) setControlValues(PotionTakenSoundFix_Settings_lowMagickaSound, PTSF.settingsVars.defaults.lowMagickaSound, true) setControlValues(PotionTakenSoundFix_Settings_lowMagickaVolumeBoost, PTSF.settingsVars.defaults.lowMagickaVolumeBoost) end,
					width = "half",
				},
				{
					type = "button",
					name = "|c00BF9CDev's Fav|r",
					tooltip = "Set "..addonVars.addonAuthor.."'s favorite values\n\nThresholds based off a |c4F9A95stam|r build",
					func = function() setControlValues(PotionTakenSoundFix_Settings_lowMagickaPercent, 30, true) setControlValues(PotionTakenSoundFix_Settings_isOKMagickaPercent, 60, true) setControlValues(PotionTakenSoundFix_Settings_isOKMagickaRepeatDelay, 3, true) setControlValues(PotionTakenSoundFix_Settings_lowMagickaSound, 56, true) setControlValues(PotionTakenSoundFix_Settings_lowMagickaVolumeBoost, 5) end,
					width = "half",
					reference = "PotionTakenSoundFix_Settings_devlowMagickaButton",
				}, --}}}
			}, --controls
        }, --submenu
        --=============================================================================================================
        -- Accessibility {{{
        --=============================================================================================================
        {
        	type = "divider",
        	width = "full",
        	height = 40,
        	alpha = 1,
        },
		{
			type = "checkbox",
			name = "Text-to-chat Master Switch",
			tooltip = "Enable Text-to-chat that can be read by ESO's accessibility settings",
			getFunc = function() return settings.textToChatEnabled end,
			setFunc = function(idx)
				settings.textToChatEnabled = idx
				if(idx) then
					--open Accessibility submenu
			    	PotionTakenSoundFix_Settings_Accessibility_submenu.open = true
			    	PotionTakenSoundFix_Settings_Accessibility_submenu.animation:PlayFromEnd()
				end
			end,
			default = false,
			width = "full",
		},
        {
            type = "submenu",
            name = "|c00FF00NEW!|r Accessibility (Text-to-chat)",
            tooltip = "Text-to-chat that can be read by ESO's accessibility settings",
            reference = "PotionTakenSoundFix_Settings_Accessibility_submenu",
            disabled = function() return not settings.textToChatEnabled end,
            controls = {
            {
                type = "editbox",
                name = "|c"..settings.textToChatPrefixGoodColor.."Prefix when good|r",
                tooltip = "Prefix that will be read for every text-to-chat output from this addon when it's a good thing, like \"Potion Taken\" or \"HP recovered\". Can be empty for none",
                getFunc = function() return settings.textToChatPrefixGood end,
                setFunc = function(idy) settings.textToChatPrefixGood = idy end,
                isMultiline = false,	--boolean
                maxChars = 30,
                width = "half",	--or "full" (optional)
                reference = "PotionTakenSoundFix_Settings_PrefixWhenGood",
                default = defaults.textToChatPrefixGood,	--(optional)
            },
            {
                type = "editbox",
                name = "|c"..settings.textToChatPrefixBadColor.."Prefix when bad|r",
                tooltip = "Prefix that will be read for every text-to-chat output from this addon when it's a bad thing, like \"Low HP\" or \"Buff lost\". Can be empty for none",
                getFunc = function() return settings.textToChatPrefixBad end,
                setFunc = function(idz) settings.textToChatPrefixBad = idz end,
                isMultiline = false,	--boolean
                maxChars = 30,
                width = "half",	--or "full" (optional)
                default = defaults.textToChatPrefixBad,	--(optional)
            },
			{
				type = "colorpicker",
				name = "Color when good", -- or string id or function returning a string
                getFunc = function() return ZO_ColorDef.HexToFloats(settings.textToChatPrefixGoodColor) end,	--(alpha is optional)
                setFunc = function(r,g,b,a) ZO_ColorDef:SetRGB(r, g, b) settings.textToChatPrefixGoodColor = ZO_ColorDef:ToHex() PotionTakenSoundFix_Settings_PrefixWhenGood.label:SetText("|c"..settings.textToChatPrefixGoodColor.."Prefix when good|r") end,	--(alpha is optional)
				tooltip = "Prefix's text color when it's a good thing", -- or string id or function returning a string (optional)
				width = "half", -- or "half" (optional)
				--disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
				--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
				--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
				default = ZO_ColorDef.HexToFloats(defaults.textToChatPrefixGoodColor), -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
				--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
				--reference = "PotionTakenSoundFix_Settings_Accessibility_PrefixGoodColorpicker", -- unique global reference to control (optional)
				--resetFunc = function(colorpickerControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
			},
			{
				type = "colorpicker",
				name = "Color when bad", -- or string id or function returning a string
                getFunc = function() return ZO_ColorDef.HexToFloats(settings.textToChatPrefixBadColor) end,	--(alpha is optional)
                setFunc = function(r,g,b,a) ZO_ColorDef:SetRGB(r, g, b) settings.textToChatPrefixBadColor = ZO_ColorDef:ToHex() PotionTakenSoundFix_Settings_PrefixWhenGood.label:SetText("|c"..settings.textToChatPrefixBadColor.."Prefix when bad|r") end,	--(alpha is optional)
				tooltip = "Prefix's text color when it's a bad thing", -- or string id or function returning a string (optional)
				width = "half", -- or "half" (optional)
				--disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
				--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
				--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
				default = ZO_ColorDef.HexToFloats(defaults.textToChatPrefixBadColor), -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
				--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
				--reference = "PotionTakenSoundFix_Settings_Accessibility_PrefixGoodColorpicker", -- unique global reference to control (optional)
				--resetFunc = function(colorpickerControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
			},
			{
				type = "colorpicker",
				name = "Event Text |c"..settings.textToChatColor.."Color".."|r", -- or string id or function returning a string
                getFunc = function() return ZO_ColorDef.HexToFloats(settings.textToChatColor) end,	--(alpha is optional)
                setFunc = function(r,g,b,a) ZO_ColorDef:SetRGB(r, g, b) settings.textToChatColor = ZO_ColorDef:ToHex() PotionTakenSoundFix_Settings_Accessibility_textToChatColorpicker.label:SetText("Event Text |c"..settings.textToChatColor.."Color".."|r") end,	--(alpha is optional)
				tooltip = "Text color that appears after the prefix, like 'Potion Taken'", -- or string id or function returning a string (optional)
				width = "full", -- or "half" (optional)
				--disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
				--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
				--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
				default = ZO_ColorDef.HexToFloats(defaults.textToChatColor), -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
				--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
				reference = "PotionTakenSoundFix_Settings_Accessibility_textToChatColorpicker", -- unique global reference to control (optional)
				--resetFunc = function(colorpickerControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
			},
			{
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.4,
			},
			{
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.0,
			},
            {
            	type = "checkbox",
            	name = "|cFFFF00Potion|r Taken Enable",
            	tooltip = "Enables text-to-chat when a |cFFFF00potion|r is taken",
            	getFunc = function() return settings.TTC_potionTakenEnable end,
            	setFunc = function(value) settings.TTC_potionTakenEnable = value end,
               	default = defaults.TTC_potionTakenEnable,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "|cFFFF00Potion|r Taken Text",
            	tooltip = "Text for when a |cFFFF00potion|r is taken",
            	getFunc = function() return settings.TTC_potionTakenText end,
            	setFunc = function(value) settings.TTC_potionTakenText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_potionTakenText,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "|cFFFF00Potion|r Ready Enable",
            	tooltip = "Enables text-to-chat when a |cFFFF00potion|r is ready (cooldown over)",
            	getFunc = function() return settings.TTC_potionReadyEnable end,
            	setFunc = function(value) settings.TTC_potionReadyEnable = value end,
               	default = defaults.TTC_potionReadyEnable,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "|cFFFF00Potion|r Ready Text",
            	tooltip = "Text for when a |cFFFF00potion|r is ready (cooldown over)",
            	getFunc = function() return settings.TTC_potionReadyText end,
            	setFunc = function(value) settings.TTC_potionReadyText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_potionReadyText,
               	width = "half",
            },
            {
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.2,
			},
			{
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.0,
			},
            {
            	type = "checkbox",
            	name = "Buff Lost Enable",
            	tooltip = "Enables text-to-chat when a selected buff is lost\n\nEnable Buff Lost HAS to be activated above Bull Lost Filters",
            	getFunc = function() return settings.TTC_buffLostEnable end,
            	setFunc = function(value) settings.TTC_buffLostEnable = value end,
               	default = defaults.TTC_buffLostEnable,
               	disabled = function() return not settings.enableBuffFilter end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "Buff Lost Text",
            	tooltip = "Text-to-chat when a selected buff is lost\n\nEnable Buff Lost HAS to be activated above Bull Lost Filters",
            	getFunc = function() return settings.TTC_buffLostText end,
            	setFunc = function(value) settings.TTC_buffLostText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_buffLostText,
                disabled = function() return not settings.enableBuffFilter end,
               	width = "half",
            },
            {
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.2,
			},
			{
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.0,
			},
            {
            	type = "checkbox",
            	name = "Low |cCC0000Health|r Enable",
            	tooltip = "Enables text-to-chat when your |cCC0000health|r is low.\n\nLow |cCC0000health|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowHPEnable end,
            	setFunc = function(value) settings.TTC_lowHPEnable = value end,
               	default = defaults.TTC_lowHPEnable,
               	disabled = function() return settings.lowHealthPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "Low |cCC0000Health|r Text",
            	tooltip = "Text-to-chat when your |cCC0000health|r is low.\n\nLow |cCC0000health|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowHPText end,
            	setFunc = function(value) settings.TTC_lowHPText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_lowHPText,
                disabled = function() return settings.lowHealthPercent == 0 end,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "|cCC0000Health|r Recovered Enable",
            	tooltip = "Enables text-to-chat when your |cCC0000health|r is recovered to its 'OK' threshold.\n\nLow |cCC0000health|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_HPRecoveredEnable end,
            	setFunc = function(value) settings.TTC_HPRecoveredEnable = value end,
               	default = defaults.TTC_HPRecoveredEnable,
               	disabled = function() return settings.lowHealthPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "|cCC0000Health|r Recovered Text",
            	tooltip = "Text-to-chat when your |cCC0000health|r is recovered to its 'OK' threshold.\n\nLow |cCC0000health|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_HPRecoveredText end,
            	setFunc = function(value) settings.TTC_HPRecoveredText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_HPRecoveredText,
                disabled = function() return settings.lowHealthPercent == 0 end,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "Low |c4F9A95Stamina|r Enable",
            	tooltip = "Enables text-to-chat when your |c4F9A95stamina|r is low.\n\nLow |c4F9A95stamina|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowStamEnable end,
            	setFunc = function(value) settings.TTC_lowStamEnable = value end,
               	default = defaults.TTC_lowStamEnable,
               	disabled = function() return settings.lowStaminaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "Low |c4F9A95Stamina|r Text",
            	tooltip = "Text-to-chat when your |c4F9A95stamina|r is low.\n\nLow |c4F9A95stamina|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowStamText end,
            	setFunc = function(value) settings.TTC_lowStamText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_lowStamText,
                disabled = function() return settings.lowStaminaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "|c4F9A95Stamina|r Recovered Enable",
            	tooltip = "Enables text-to-chat when your |c4F9A95stamina|r is recovered to its 'OK' threshold.\n\nLow |c4F9A95stamina|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_StamRecoveredEnable end,
            	setFunc = function(value) settings.TTC_StamRecoveredEnable = value end,
               	default = defaults.TTC_StamRecoveredEnable,
               	disabled = function() return settings.lowStaminaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "|c4F9A95Stamina|r Recovered Text",
            	tooltip = "Text-to-chat when your |c4F9A95stamina|r is recovered to its 'OK' threshold.\n\nLow |c4F9A95stamina|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_StamRecoveredText end,
            	setFunc = function(value) settings.TTC_StamRecoveredText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_StamRecoveredText,
                disabled = function() return settings.lowStaminaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "Low |c5882B7Magicka|r Enable",
            	tooltip = "Enables text-to-chat when your |c5882B7magicka|r is low.\n\nLow |c5882B7magicka|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowMagEnable end,
            	setFunc = function(value) settings.TTC_lowMagEnable = value end,
               	default = defaults.TTC_lowMagEnable,
               	disabled = function() return settings.lowMagickaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "Low |c5882B7Magicka|r Text",
            	tooltip = "Text-to-chat when your |c5882B7magicka|r is low.\n\nLow |c5882B7magicka|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_lowMagText end,
            	setFunc = function(value) settings.TTC_lowMagText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_lowMagText,
                disabled = function() return settings.lowMagickaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "|c5882B7Magicka|r Recovered Enable",
            	tooltip = "Enables text-to-chat when your |c5882B7magicka|r is recovered to its 'OK' threshold.\n\nLow |c5882B7magicka|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_MagRecoveredEnable end,
            	setFunc = function(value) settings.TTC_MagRecoveredEnable = value end,
               	default = defaults.TTC_MagRecoveredEnable,
               	disabled = function() return settings.lowMagickaPercent == 0 end,
               	width = "half",
            },
            {
            	type = "editbox",
            	name = "|c5882B7Magicka|r Recovered Text",
            	tooltip = "Text-to-chat when your |c5882B7magicka|r is recovered to its 'OK' threshold.\n\nLow |c5882B7magicka|r threshold HAS to be enabled under Low Resources settings (to more than 0)",
            	getFunc = function() return settings.TTC_MagRecoveredText end,
            	setFunc = function(value) settings.TTC_MagRecoveredText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_MagRecoveredText,
                disabled = function() return settings.lowMagickaPercent == 0 end,
               	width = "half",
            },
            {
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.2,
			},
			{
				type = "divider",
				width = "half",
				height = 15,
				alpha = 0.0,
			},
            {
            	type = "checkbox",
            	name = "Auto-Quickslotted Enable",
            	tooltip = "Enables text-to-chat when this addon auto-quickslots on any low resource.\n\nEither auto-quickslotting on any 3 resources HAS to be enabled under Low Resources settings",
            	getFunc = function() return settings.TTC_AutoQuickslottedPotionEnable end,
            	setFunc = function(value) settings.TTC_AutoQuickslottedPotionEnable = value end,
               	default = defaults.TTC_AutoQuickslottedPotionEnable,
               	disabled = function() return settings.lowHealthAutoSlot == 0 and settings.lowStaminaAutoSlot == 0 and settings.lowMagickaAutoSlot == 0 end,
               	width = "full",
            },
            {
            	type = "editbox",
            	name = "Quickslotted and |cFFFF00potion|r is ready Text",
            	tooltip = "Text-to-chat when a low resource condition triggered an auto-quickslot and your |cFFFF00potion|r is ready.\n\nUses your low resource's custom text followed by this one. For example:\nLow Health quickslotted, potion ready\n\nEither auto-quickslotting for any 3 resources HAS to be enabled under Low Resources settings",
            	getFunc = function() return settings.TTC_AutoQuickslottedPotionRdyText end,
            	setFunc = function(value) settings.TTC_AutoQuickslottedPotionRdyText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_AutoQuickslottedPotionRdyText,
                disabled = function() return not settings.TTC_AutoQuickslottedPotionEnable or settings.lowHealthAutoSlot == 0 and settings.lowStaminaAutoSlot == 0 and settings.lowMagickaAutoSlot == 0 end,
               	width = "full",
            },
            {
            	type = "editbox",
            	name = "Quickslotted, but |cFFFF00potion|r is on cooldown Text",
            	tooltip = "Text-to-chat when a low resource condition triggered an auto-quickslot, but |cFFFF00potion|r is on cooldown.\n\nUses your low resource's custom text followed by this one. For example:\nLow Stamina quickslotted, but potion is on cooldown\n\nEither auto-quickslotting for any 3 resources HAS to be enabled under Low Resources settings",
            	getFunc = function() return settings.TTC_AutoQuickslottedPotionNotRdyText end,
            	setFunc = function(value) settings.TTC_AutoQuickslottedPotionNotRdyText = value end,
                isMultiline = false,	--boolean
                maxChars = 60,
                default = defaults.TTC_AutoQuickslottedPotionNotRdyText,
                disabled = function() return not settings.TTC_AutoQuickslottedPotionEnable or settings.lowHealthAutoSlot == 0 and settings.lowStaminaAutoSlot == 0 and settings.lowMagickaAutoSlot == 0 end,
               	width = "full",
            },
            }, --controls
        }, --submenu
        --}}}
        --=============================================================================================================
        -- Debug {{{
        --=============================================================================================================
        {
        	type = "divider",
        	width = "full",
        	height = 40,
        	alpha = 1,
        },
        {
            type = "submenu",
            name = "Debug",
            tooltip = "Debug options, use if requested. None of those options are permanent (They don't save when reloading the game or between reloadui)",
            controls = {
            {
            	type = "checkbox",
            	name = "Master switch",
            	tooltip = "Turn off this addon's functionalities (sound fix along with custom sounds etc).",
            	getFunc = function() return PTSF.masterSwitch end,
            	setFunc = function(value)
               		PTSF.masterSwitch = value
               		PTSF.register_potion_taken_events(value)
               		PTSF.register_or_unregister_low_resources_events()  --1.08
               		PTSF.toggle_buff_filters(value)  		 --events for RegisterAbilityIdsFilterOnEventEffectChanged
               		if (value) then --only preHook is kept
               			PTSF.DG("Master Switch is |c00FF00ON|r")
               		else
               			PTSF.D("Master Switch is |cFF0000OFF|r (default sound without fix will play)", true)
               		end
               	end,
               	default = true,
               	width = "half",
            },
            {
            	type = "checkbox",
            	name = "Unknown Potion Buffs Finder",
            	tooltip = "Debug option. Activating this will display |cFFFF00potion|r buffs in chat by using an alternative way of tracking |cFFFF00potion|r buffs.\n\n"
            			.."INSTRUCTIONS:\n"
            			.."If you have no lost buff sound for a specific |cFFFF00potion|r,\n"
            			.."1- Enable this option and please let your buffs run out and don't re-buff yourself with any ability\n"
            			.."2- Use that specific |cFFFF00potion|r, you'll see debug lines in chat\n"
            			.."3- Write down the buffs (ability ID's) in red, those are the missing ones\n"
            			.."OR 3- Click on the |cFFFF00potion|r link to show which |cFFFF00potion|r it is and ideally take a screenshot of the chat lines along with the |cFFFF00potion|r tooltip\n"
            			.."4- Post the ability ID's OR screen shot on ESOUI, you can use the 'feedback' button up top of this options' menu\n"
            			.."5- You can now disable this option and wait for a fix\n\n"
            			.."Thank you!",
            	getFunc = function() return PTSF.toggle_potion_buffs_check_enabled end,
            	setFunc = function(value)
                	PTSF.toggle_potion_buffs_check_enabled = value
                	PTSF.toggle_potion_buffs_check(value)
                end,
                default = PTSF.toggle_potion_buffs_check_enabled,
                width = "half",
            },
            }, --controls
        }, --submenu
    } --}}}
    PTSF.addonMenuPanel = PTSF.addonMenu:RegisterAddonPanel("PotionTakenSoundFix_SettingsMenu", PTSF.panelData)
    PTSF.addonMenu:RegisterOptionControls("PotionTakenSoundFix_SettingsMenu", PTSF.optionsData)

    PTSF.addonMenu.isBuilt = true
end

