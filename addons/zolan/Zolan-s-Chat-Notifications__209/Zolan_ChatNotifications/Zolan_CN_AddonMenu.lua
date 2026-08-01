--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Addon Menu)                   --
--------------------------------------------------------------------------------
local ZCN       = Zolan_CN
local AddonMenu = ZCN.AddonMenu

local LibStub = LibStub

-- ZO
local PlaySound = PlaySound
local SOUNDS    = SOUNDS
-- Lua
local pairs     = pairs
local table     = table

AddonMenu.Vars.colors = {
    ["gold"]       = "|cFFD700", -- Gold
    ["faded_gold"] = "|c998100", -- Faded Gold
    ["light_blue"] = "|c88DDDD", -- Light Blue
    ["faded_blue"] = "|c44AAAA"  -- Faded Blue
}

AddonMenu.Vars.titleColor   = AddonMenu.Vars.colors.gold
AddonMenu.Vars.header1Color = AddonMenu.Vars.colors.gold
AddonMenu.Vars.header2Color = AddonMenu.Vars.colors.faded_gold
AddonMenu.Vars.header3Color = AddonMenu.Vars.colors.faded_blue
AddonMenu.Vars.header4Color = AddonMenu.Vars.colors.light_blue

AddonMenu.LAM          = LibStub("LibAddonMenu-2.0")

function AddonMenu.loadAudioAlertOptions()
    ZCN.debug("+_ AddonMenu -> loadAudioAlertOptions")

    AddonMenu.Vars.availableSoundNamesByID = {
        [SOUNDS.NONE]                          = "Disabled",
        [SOUNDS.ABILITY_PICKED_UP]             = "ChicUpp (Ability Picked Up)",
        [SOUNDS.SCRIPTED_EVENT_COMPLETION]     = "Chiiing (Event Completion)",
        [SOUNDS.LOCKPICKING_BREAK]             = "Chink (Lockpick Break)",
        [SOUNDS.SKILL_POINT_GAINED]            = "Chooong (Gained Skill)",
        [SOUNDS.LOCKPICKING_UNLOCKED]          = "CliClack  (Chest Unlocked)",
        [SOUNDS.ACHIEVEMENT_AWARDED]           = "Choom (Achievement Awarded)",
        [SOUNDS.BOOK_ACQUIRED]                 = "Ding (Book Acquired)",
        [SOUNDS.BANK_WINDOW_OPEN]              = "Fbwoooo (Bank Window Open)",
        [SOUNDS.TREASURE_MAP_OPEN]             = "Fwoom (Treasure Map Open)",
        [SOUNDS.LOCKPICKING_CHAMBER_STRESS]    = "Rattle (Lockpick Chamber Stress)",
        [SOUNDS.SKILL_PURCHASED]       		   = "ShhhhChing (Ability Skill Purchased)",
        [SOUNDS.ENCHANTING_ASPECT_RUNE_PLACED] = "Thunk (Place Aspect Rune)",
        [SOUNDS.DIALOG_ACCEPT]                 = "Tink (Dialog Accept)",
        [SOUNDS.ABILITY_SLOT_CLEARED]          = "Quiet Thwoom (Ability Slot Cleared)",
        [SOUNDS.EDIT_CLICK]                    = "Quiet Tick (Edit Click)"
    }
    table.sort(AddonMenu.Vars.availableSoundNamesByID)

    AddonMenu.Vars.availableSoundIDsByName = {}
    for id,name in pairs(AddonMenu.Vars.availableSoundNamesByID) do
        AddonMenu.Vars.availableSoundIDsByName[name] = id
    end
    table.sort(AddonMenu.Vars.availableSoundIDsByName)
end

function AddonMenu.listSoundOptions()
    ZCN.debug("AddonMenu -> listSoundOptions")

    local retval = {}
    local names  = {}

    for _,name in pairs(AddonMenu.Vars.availableSoundNamesByID) do
        if name ~= 'Disabled' then
            table.insert(names, name)
        end
    end
    table.sort(names)

    table.insert(retval, 'Disabled')
    for cnt = 1, #names do
        table.insert(retval, names[cnt])
    end

    return retval
end

function AddonMenu.getSelectedSoundNameForSetting(settingName)
    ZCN.debug("AddonMenu -> getSelectedSoundNameForSetting")

    return AddonMenu.Vars.availableSoundNamesByID[
        ZCN.savedVars.audio[settingName]['sound']
    ] or 'ERROR!'
end

function AddonMenu.setSoundIDForSettingFromSoundName(settingName, soundName)
    ZCN.debug("AddonMenu -> setSoundIDForSettingFromSoundName")

    local soundID = AddonMenu.Vars.availableSoundIDsByName[soundName]

    ZCN.savedVars.audio[settingName]['sound'] = soundID

    if soundID == SOUNDS.NONE then
        ZCN.debug("Disabling sounds for " .. settingName)
        ZCN.savedVars.audio[settingName]['enabled'] = false
    else
        ZCN.debug("Enabling sounds for " .. settingName)
        ZCN.savedVars.audio[settingName]['enabled'] = true
    end

    ZCN.debug("Setting sound to [" .. soundName .. "] -> [" .. soundID .. "]")

    PlaySound(ZCN.savedVars.audio[settingName]['sound'])

    return soundName
end

function AddonMenu.getBooleanGlobalOption(optionName)
    ZCN.debug("AddonMenu -> getBooleanGlobalOption [" .. optionName .. "]")
    return ZCN.savedVars[optionName]
end

function AddonMenu.toggleBooleanGlobalOption(optionName)
    ZCN.debug("AddonMenu -> toggleBooleanGlobalOption [" .. optionName .. "]")
    local newValue = not ZCN.savedVars[optionName]
    ZCN.savedVars[optionName] = newValue
end

function AddonMenu.getBooleanAudioOption(optionName)
    ZCN.debug("AddonMenu -> getBooleanAudioOption [" .. optionName .. "]")
    return ZCN.savedVars.audio[optionName]
end

function AddonMenu.toggleBooleanAudioOption(optionName)
    ZCN.debug("AddonMenu -> toggleBooleanAudioOption [" .. optionName .. "]")
    local newValue = not ZCN.savedVars.audio[optionName]
    ZCN.savedVars.audio[optionName] = newValue
end

function AddonMenu.getBooleanAudioSubOption(categoryName, optionName)
    ZCN.debug("AddonMenu -> getBooleanAudioSubOption [" .. categoryName .. ", " .. optionName .. "]")
    return ZCN.savedVars.audio[categoryName][optionName]
end

function AddonMenu.toggleBooleanAudioSubOption(categoryName, optionName)
    ZCN.debug("AddonMenu -> toggleBooleanAudioSubOption [" .. categoryName .. ", " .. optionName .. "]")
    local newValue = not ZCN.savedVars.audio[categoryName][optionName]
    ZCN.savedVars.audio[categoryName][optionName] = newValue
end

-- FUN STUFF TO PLAY AROUND WITH LATER
-- function AddonMenu.setFont(objWithText)
--     fontSize = objWithText:GetFontHeight() or 16
--     fontSize = fontSize - 4
--     objWithText:SetFont("EsoUI/Common/Fonts/fontin_sans_sc.otf|"..fontSize)
-- end
-- 
-- function AddonMenu.prettifyUI(UIObj)
--     if UIObj == nil then return end
--     if type(UIObj.GetType) ~= 'function' then return end
-- 
--     if UIObj:GetType() == CT_LABEL then AddonMenu.setFont(UIObj) end
-- 
--     local childrenCount = UIObj:GetNumChildren()
-- 
--     if childrenCount == 0 then return end
-- 
--     for i = 1, childrenCount do
--         AddonMenu.prettifyUI(UIObj:GetChild(i))
--     end
-- end

function AddonMenu.initializeControlPanel()
    ZCN.debug("AddonMenu -> initializeControlPanel")
    AddonMenu.loadAudioAlertOptions()

	AddonMenu.LAM:RegisterAddonPanel("Zolan_ChatNotifications_ControlPanel", {
		type = "panel",
		name = "Chat Notifications",
		displayName = AddonMenu.Vars.header1Color .. "Zolan's Chat Notifications",
		version = ZCN.appVersion,
		author = "Zolan"
	})
	
	AddonMenu.LAM:RegisterOptionControls("Zolan_ChatNotifications_ControlPanel", {
		[1] = {
			type = "checkbox",
			name = "Enable Audio Notifications",
			tooltip = "Enable or disable all audio notifications for this addon.",
			getFunc = function () return AddonMenu.getBooleanAudioOption('enabled') end,
			setFunc = function () AddonMenu.toggleBooleanAudioOption('enabled') end
		},
		[2] = {
			type = "checkbox",
			name = "Enable Debug",
			tooltip = "This will spam your chat box with debug info.  You probably do NOT want to turn it on.",
			getFunc = function () return AddonMenu.getBooleanGlobalOption('debug') end,
			setFunc = function () AddonMenu.toggleBooleanGlobalOption('debug') end
		},
		[3] = {
			type = "submenu",
			name = AddonMenu.Vars.header4Color..'Manage Special Notification Settings',
			tooltip = 'Open window for special settings regarding when to notify.',
			controls = {						
				-------------------
				-- MISC
				-------------------
				[1] = {
					type = "description",
					text = AddonMenu.Vars.header2Color.."These are special settings to augment when you are alerted.",
					title = AddonMenu.Vars.header1Color.."- NOTIFICATION SETTINGS -"
				},
				[2] = {
					type = "checkbox",
					name = "On My Chats",
					tooltip = "This will play or not play a sound if the chat is coming from you.",
					getFunc = function () return AddonMenu.getBooleanAudioSubOption('onMyChat', 'enabled') end,
					setFunc = function () AddonMenu.toggleBooleanAudioSubOption('onMyChat', 'enabled') end
				},
				-------------------
				-- LISTS
				-------------------
				[3] = {
					type = "description",
					text = AddonMenu.Vars.header2Color.."The following lists expect one entry per line.  They are case incensitive and "
					.. "do not accept Lua patterns at this time.",
					title = AddonMenu.Vars.header1Color.."- USER SPECIFIED LISTS -"
				},
				-------------------
				-- KEY WORDS LIST
				-------------------
				[4] = {
					type = "editbox",
					name = "Key words or phrases",
					tooltip = 'Key words or phrases that, if seen in any channel, will make a notification.',
					isMultiline = true,
					getFunc = function()
						return ZCN.savedVars.keyWords
					end,
					setFunc = function(value)
						ZCN.savedVars.keyWords = value
					end
				},
				-------------------
				-- PLAYER BLACKLIST
				-------------------
				[5] = {
					type = "editbox",
					name = "Account names to ignore",
					tooltip = 'Any account that is in this list will not make a notification, period. '
					.. 'You do not need to use the @ symbol.',
					isMultiline = true,
					getFunc = function()
						return ZCN.savedVars.playerBlacklist
					end,
					setFunc = function(value)
						ZCN.savedVars.playerBlacklist = value
					end
				}
			}
		},
		[4] = {
			type = "submenu",
			name = AddonMenu.Vars.header4Color..'Manage Audio Notification Settings',
			tooltip = 'Open Audio Notification Settings Window',
			controls = {
				[1] = {
					type = "description",
					text = AddonMenu.Vars.header2Color.."Set the sound you want to hear for each of the following.  "
					.. "If you do not want to hear a sound, select 'Disabled'.",
					title = AddonMenu.Vars.header1Color.."- SELECT SOUNDS -"
				},
				-------------------
				-- MY NAME
				-------------------
				[2] = {
					type = "dropdown",
					name = "Sound for when your name is mentioned",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onMyName')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onMyName', soundName)
					end
				},
				-------------------
				-- FRIEND
				-------------------
				[3] = {
					type = "dropdown",
					name = "Sound for when a friend sends a chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onFriend')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onFriend', soundName)
					end
				},
				-------------------
				-- KEY WORDS
				-------------------
				[4] = {
					type = "dropdown",
					name = "Sound for a key word is used in chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onKeyWords')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onKeyWords', soundName)
					end
				},
				-------------------
				-- WHISPER
				-------------------
				[5] = {
					type = "dropdown",
					name = "|cFF00FFSound for whispers",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onWhisper')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onWhisper', soundName)
					end
				},
				-------------------
				-- PARTY
				-------------------
				[6] = {
					type = "dropdown",
					name = "|cFFAA00Sound for party chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onParty')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onParty', soundName)
					end
				},
				-------------------
				-- GUILD1
				-------------------
				[7] = {
					type = "dropdown",
					name = "|c00FF00Sound for Guild 1 chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onGuild1')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onGuild1', soundName)
					end
				},
				-------------------
				-- GUILD2
				-------------------
				[8] = {
					type = "dropdown",
					name = "|c00FF00Sound for Guild 2 chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onGuild2')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onGuild2', soundName)
					end
				},
				-------------------
				-- GUILD3
				-------------------
				[9] = {
					type = "dropdown",
					name = "|c00FF00Sound for Guild 3 chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onGuild3')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onGuild3', soundName)
					end
				},
				-------------------
				-- GUILD4
				-------------------
				[10] = {
					type = "dropdown",
					name = "|c00FF00Sound for Guild 4 chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onGuild4')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onGuild4', soundName)
					end
				},
				-------------------
				-- GUILD5
				-------------------
				[11] = {
					type = "dropdown",
					name = "|c00FF00Sound for Guild 5 chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onGuild5')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onGuild5', soundName)
					end
				},
				-------------------
				-- SAY
				-------------------
				[12] = {
					type = "dropdown",
					name = "|cAAAAAASound for say chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onSay')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onSay', soundName)
					end
				},
				-------------------
				-- ZONE
				-------------------
				[13] = {
					type = "dropdown",
					name = "|cAA6600Sound for zone chat",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onZone')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onZone', soundName)
					end
				},
				-------------------
				-- YELL
				-------------------
				[14] = {
					type = "dropdown",
					name = "|cFF0000Sound for yells",
					tooltip = "Choose Sound or 'Disable' for no sound.",
					choices = AddonMenu.listSoundOptions(),
					getFunc = function()
						return AddonMenu.getSelectedSoundNameForSetting('onYell')
					end,
					setFunc = function(soundName)
						return AddonMenu.setSoundIDForSettingFromSoundName('onYell', soundName)
					end
				}
			}
		}
	})
end
