--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Addon Menu)
--------------------------------------------------------------------------------
local ZJH       = Zolan_JH
local AddonMenu = ZJH.AddonMenu
local ZL        = ZJH.ZL
AddonMenu.Vars  = {}

-- Localize as much as we can to avoid global lookups.
local LibStub   = LibStub

AddonMenu.Vars.titleColor   = ZL.colors.gold
AddonMenu.Vars.header1Color = ZL.colors.gold
AddonMenu.Vars.header2Color = ZL.colors.faded_gold
AddonMenu.Vars.header3Color = ZL.colors.faded_blue
AddonMenu.Vars.header4Color = ZL.colors.light_blue

AddonMenu.LAM         = LibStub("LibAddonMenu-2.0")

function AddonMenu:loadAudioAlertOptions()
    ZL:debug("+_ AddonMenu -> loadAudioAlertOptions")

    self.Vars.availableSoundNamesByID = {
        [SOUNDS.NONE]                          = "Disabled",
        [SOUNDS.BOOK_OPEN]                     = "Crumple",
        [SOUNDS.QUICKSLOT_SET]                 = "Fdung",
        [SOUNDS.BLACKSMITH_EXTRACTED_BOOSTER]  = "Kachunk",
        [SOUNDS.ENCHANTING_ASPECT_RUNE_PLACED] = "Thunk"
    }
    table.sort(self.Vars.availableSoundNamesByID)

    self.Vars.availableSoundIDsByName = {}
    for id,name in pairs(self.Vars.availableSoundNamesByID) do
        self.Vars.availableSoundIDsByName[name] = id
    end
    table.sort(self.Vars.availableSoundIDsByName)
end

function AddonMenu:listSoundOptions()
    ZL:debug("AddonMenu -> listSoundOptions")

    local retval = {}
    local names  = {}

    for _,name in pairs(self.Vars.availableSoundNamesByID) do
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

function AddonMenu:getSelectedSoundNameForSetting(settingName)
    ZL:debug("AddonMenu -> getSelectedSoundNameForSetting")

    return self.Vars.availableSoundNamesByID[
        ZJH.settings[settingName]
    ] or 'ERROR!'
end

function AddonMenu:setSoundIDForSettingFromSoundName(settingName, soundName)
    ZL:debug("AddonMenu -> setSoundIDForSettingFromSoundName")

    local soundID = self.Vars.availableSoundIDsByName[soundName]

    ZJH.settings[settingName] = soundID

    ZL:debug("Setting sound to [" .. soundName .. "] -> [" .. soundID .. "]")

    PlaySound(ZJH.settings[settingName])

    return soundName
end

function AddonMenu:getBooleanOption(optionName)
    ZL:debug("AddonMenu -> getBooleanOption [" .. optionName .. "]")
    return ZJH.settings[optionName]
end

function AddonMenu:toggleBooleanOption(optionName)
    ZL:debug("AddonMenu -> toggleBooleanOption [" .. optionName .. "]")
    local newValue = not ZJH.settings[optionName]
    ZJH.settings[optionName] = newValue
end

function AddonMenu:getDebugOption()
    ZL:debug("AddonMenu -> getDebugOption")

    local status = self:getBooleanOption('debug')
    ZL.settings.debugEnabled = status

    return status
end

function AddonMenu:toggleDebugOption()
    ZL:debug("AddonMenu -> toggleDebugOption")

    local newValue = not ZJH.settings.debug
    ZJH.settings.debug       = newValue
    ZL.settings.debugEnabled = newValue
end

function AddonMenu:getSliderValue(optionName, stringFormat)
    return ZJH.settings[optionName]
end

function AddonMenu:setSliderValue(optionName, value)
    ZJH.settings[optionName] = value
end

function AddonMenu:initializeAddonMenu()
    ZL:debug("AddonMenu -> initializeAddonMenu")

	AddonMenu.LAM:RegisterAddonPanel("Zolan_JunkHandler_ControlPanel", {type="panel", name="Junk Handler", version=ZJH.appVersion, author="Zolan", displayName=self.Vars.header1Color .. "ZOLAN'S JUNK HANDLER"})
	
    self:loadAudioAlertOptions()
	
	AddonMenu.LAM:RegisterOptionControls("Zolan_JunkHandler_ControlPanel", {
		[1] = {
			type = "checkbox",
			name = "Enable Junk Handler",
			tooltip = "Enable or disable ALL features of Junk Handler.",
			getFunc = function () return self:getBooleanOption('enabled') end,
			setFunc = function () self:toggleBooleanOption('enabled') end
		},
		[2] = {
			type = "checkbox",
			name = "Enable Debugging",
			tooltip = "You almost certainly want this disabled. Enabling it will "
			.. "cause a massive amount of text in your chat box.",
			getFunc = function () return self:getDebugOption() end,
			setFunc = function () self:toggleDebugOption() end
		},
		[3] = {
			type = "editbox",
			name = "Name Of Chat Tab For Output",
			tooltip = 'The name of the chat tab you want to send output to.  '
			..'This does not affect the "loaded" message and if it can\'t '
			..'find your tab, it will output to your current tab.',
			isMultiline  = false,
			getFunc = function()
				ZL.settings.outputChatTab = ZJH.settings.outputChatTab
				return ZJH.settings.outputChatTab
			end,
			setFunc = function(value)
				ZJH.settings.outputChatTab = value
				ZL.settings.outputChatTab  = ZJH.settings.outputChatTab
			end
		},
		[4] = {
			type = "submenu",
			name = self.Vars.header4Color..'Manage Junk Marking Settings',
			tooltip = 'Open for settings related to what you want marked as junk.',
			controls = {
				[1] = {
					type = "description",
					text = self.Vars.header2Color.."The following options allow you to decide what will be marked as junk or not.",
					title = self.Vars.header1Color.."- WHEN TO MARK AS JUNK -",
				},
				[2] = {
					type = "dropdown",
					name = "Sound For Junk Notification",
					tooltip = "Choose Sound to play when an item is marked as junk or 'Disable' for no sound.",
					choices = self:listSoundOptions(),
					getFunc = function()
						return self:getSelectedSoundNameForSetting('markAsJunkSound')
					end,
					setFunc = function(soundName)
						return self:setSoundIDForSettingFromSoundName('markAsJunkSound', soundName)
					end
				},
				[3] = {
					type = "checkbox",
					name = "Notifiy When Marking Item As Junk",
					tooltip = "Enable or disable chat notification that an item has been "
					.. "marked as junk by the addon.",
					getFunc = function () return self:getBooleanOption('markAsJunkNotify') end,
					setFunc = function () self:toggleBooleanOption('markAsJunkNotify') end
				},
				[4] = {
					type = "checkbox",
					name = "Mark Trash Items As Junk",
					tooltip = "Enable or disable marking trash items as junk.",
					getFunc = function () return self:getBooleanOption('markTrashAsJunk') end,
					setFunc = function () self:toggleBooleanOption('markTrashAsJunk') end
				},
				[5] = {
					type = "checkbox",
					name = "Mark Ornate Items As Junk",
					tooltip = "Enable or disable marking ornate items as junk.",
					getFunc = function () return self:getBooleanOption('markOrnateAsJunk') end,
					setFunc = function () self:toggleBooleanOption('markOrnateAsJunk') end
				},
				[6] = {
					type = "checkbox",
					name = "Mark Icky Food Items As Junk",
					tooltip = "Enable or disable marking Cloudy, Cold, Congealed, Flat, Murky, and Stale food items as junk.",
					getFunc = function () return self:getBooleanOption('markIckyFoodAsJunk') end,
					setFunc = function () self:toggleBooleanOption('markIckyFoodAsJunk') end
				},
				[7] = {
					type = "checkbox",
					name = "Mark Worthless Weapons And Armors As Junk",
					tooltip = "Enable or disable marking white quality armors and weapons worth 0 gold as junk.",
					getFunc = function () return self:getBooleanOption('markWeaponsArmorsAsJunk') end,
					setFunc = function () self:toggleBooleanOption('markWeaponsArmorsAsJunk') end
				},
				[8] = {
					type = "checkbox",
					name = "Periodically Scan Backpack For Junk",
					tooltip = "Enable or disable periodically scanning backpack for junk.",
					getFunc = function () return self:getBooleanOption('scanBackpackForJunk') end,
					setFunc = function () self:toggleBooleanOption('scanBackpackForJunk') end
				},
				[9] = {
					type = "description",
					text = self.Vars.header2Color.."This feature tracks what you mark as junk.  Once you do, it will automatically "
					.. "mark those items as junk until you go in and unmark them as junk.",
					title = self.Vars.header1Color.."- USER JUNK TRACKING -"
				},
				[10] = {
					type = "checkbox",
					name = "User Tracking Junk Marking",
					tooltip = "Enable or disable tracking of what users mark as junk and continue "
					.. "marking those as junk until they unmark them.",
					getFunc = function () return self:getBooleanOption('markUserMarkedAsJunk') end,
					setFunc = function () self:toggleBooleanOption('markUserMarkedAsJunk') end
				}
			}
		},
		[5] = {
			type = "submenu",
			name = self.Vars.header4Color..'Manage Junk Selling Settings',
			tooltip = 'Open for settings related to how to sell your junk.',
			controls = {
				[1] = {
					type = "description",
					text = self.Vars.header2Color.."This controls the behavior of what happens when you talk to a vendor.",
					title = self.Vars.header1Color.."- JUNK SELLING SETTINGS -"
				},
				[2] = {
					type = "checkbox",
					name = "Sell Junk Items Automatically",
					tooltip = "Enable or disable selling junk items automatically when you visit a store.",
					getFunc = function () return self:getBooleanOption('sellJunk') end,
					setFunc = function () self:toggleBooleanOption('sellJunk') end
				},
				[3] = {
					type = "checkbox",
					name = "Notification When Visiting A Store",
					tooltip = "Enable or disable notification that the addon is activating when visiting a store.",
					getFunc = function () return self:getBooleanOption('sellNotify') end,
					setFunc = function () self:toggleBooleanOption('sellNotify') end
				},
				[4] = {
					type = "checkbox",
					name = "Show Itemized List On Sell",
					tooltip = "Enable or disable displaying an itemized list of what was sold.",
					getFunc = function () return self:getBooleanOption('showItemized') end,
					setFunc = function () self:toggleBooleanOption('showItemized') end
				},
				[5] = {
					type = "checkbox",
					name = "Show Summary On Sell",
					tooltip = "Enable or disable displaying a summary of what was sold.",
					getFunc = function () return self:getBooleanOption('showSummary') end,
					setFunc = function () self:toggleBooleanOption('showSummary') end
				},
				[6] = {
					type = "checkbox",
					name = "Use Original Sell All Junk Method",
					tooltip = "This uses the function given to us by ZOS themselves.  It appears to lock up the game "
					.."and make it crash.  Yay... :( When this is turned off it sells each item individually which "
					.."will hopefully fix the problem.  You can alter the delay in ms using the slider below.",
					getFunc = function () return self:getBooleanOption('useOldSellAllItems') end,
					setFunc = function () self:toggleBooleanOption('useOldSellAllItems') end
				},
				[7] = {
					type = "slider",
					name = "Delay In ms Between Each Sell",
					tooltip = "Delay between each item of junk you are selling in ms.",
					min = 0,
					max = 250,
					step = 10,
					getFunc = function () return self:getSliderValue('msDelayBetweenSells', 'ms') end,
					setFunc = function (value) return self:setSliderValue('msDelayBetweenSells', value) end
				}
			}			
		},
		[6] = {
			type = "submenu",
			name = self.Vars.header4Color..'Manage Junk Destroying Settings',
			tooltip = 'Open for settings related to destroying junk.',
			controls = {
				[1] = {
					type = "description",
					text = "|cAA0000These following settings are for destroying junk.  This is very "
					.. "dangerous.  Any red settings are 'use at your own risk'. "
					.. "See the mouse-over tooltip for the 'acknowledge' setting for more "
					.. "information.",
					title = "|cFF0000- DESTROY JUNK SETTINGS -"
				},
				[2] = {
					type = "checkbox",
					name = "|cFF0000I Acknowledge This Is Dangerous",
					tooltip = "|cFF0000You must Acknowledge that this feature is dangerous before "
					.. "any of the destroy options will work.\n\n"
					.. "This section is EXTREMELY dangerous to use.  Once an item is "
					.. "destroyed, there is no getting it back.  The author has done his "
					.. "best to make sure that this will always do as it says it will, but "
					.. "mistakes can happen.  By enabling ANY red option in this section you are "
					.. "acknowledging that you are aware of the risks and are willing to "
					.. "take them.",
					getFunc = function () return self:getBooleanOption('destroyAcknowledge') end,
					setFunc = function () self:toggleBooleanOption('destroyAcknowledge') end
				},
				[3] = {
					type = "dropdown",
					name = "Sound For Destroy Notification",
					tooltip = "Choose Sound to play when an item is marked to be destroyed or 'Disable' for no sound.",
					choices = self:listSoundOptions(),
					getFunc = function()
						return self:getSelectedSoundNameForSetting('destroySound')
					end,
					setFunc = function(soundName)
						return self:setSoundIDForSettingFromSoundName('destroySound', soundName)
					end
				},
				[4] = {
					type = "checkbox",
					name = "Notify When Item Is Destroyed",
					tooltip = "This will display a message at the point when an item has been destroyed. "
					.. "Presently, you will ALWAYS get a message when an item is marked as junk "
					.. "and queued to be destroyed.  This is likely to always happen and I "
					.. "apologize to anyone who thinks this is a horrible decision.",
					getFunc = function () return self:getBooleanOption('destroyItemNotify') end,
					setFunc = function () self:toggleBooleanOption('destroyItemNotify') end
				},
				[5] = {
					type = "slider",
					name = "|cFF0000Amount of Seconds Before Destroy",
					tooltip = "|cFF0000If you have decided to have this addon destroy your junk, you can use "
					.. "this setting to set how many seconds from the time of loot that it will "
					.. "wait before it is destroyed.  This is overridden by the next option.",
					min = 1,
					max = 60,
					step = 1,
					getFunc = function () return self:getSliderValue('destroyDelayInSeconds', ZJH.Vars.currencyColor .. '%s seconds') end,
					setFunc = function (value) return self:setSliderValue('destroyDelayInSeconds', value) end
				},
				[6] = {
					type = "checkbox",
					name = "|cFF0000DO NOT NOTIFY ME AT ALL",
					tooltip = "|cFF0000THIS OPTION OVERRIDES ALL NOTIFICATIONS REGARDING DESTROYING ITEMS:\n"
					.. "You are possibly crazy if you use this option but it has been strongly requested. "
					.. "You will not receive a notification that an item is going to be destroyed or "
					.. "that an item HAS been destroyed.  It will just happen and you will be blissfully"
					.. "unaware of it.",
					getFunc = function () return self:getBooleanOption('destroyBlindTrust') end,
					setFunc = function () self:toggleBooleanOption('destroyBlindTrust') end
				},
				[7] = {
					type = "checkbox",
					name = "|cFF0000Destroy Junk Worth Zero Gold",
					tooltip = "|cFF0000Destroy anything marked as junk that has a 0 gold value.",
					getFunc = function () return self:getBooleanOption('destroyZeroGold') end,
					setFunc = function () self:toggleBooleanOption('destroyZeroGold') end
				},
				[8] = {
					type = "checkbox",
					name = "|cFF0000Destroy Junk That Is Cheap",
					tooltip = "|cFF0000Destroy junk less than or equal to the value in the slider below.",
					getFunc = function () return self:getBooleanOption('destroyCheap') end,
					setFunc = function () self:toggleBooleanOption('destroyCheap') end
				},
				[9] = {
					type = "checkbox",
					name = "|cFF0000Compare Using Item's Unit Price",
					tooltip = "|cFF0000When determining if an item is 'Cheap', should we use the unit price "
					.."(price for a single item) [ON] or the price of the entire stack [OFF].",
					getFunc = function () return self:getBooleanOption('destroyCheapUnitPrice') end,
					setFunc = function () self:toggleBooleanOption('destroyCheapUnitPrice') end
				},
				[10] = {
					type = "slider",
					name = "|cFF0000Amount of Gold You Consider Cheap",
					tooltip = "|cFF0000If 'Destroy Junk That Is Cheap' is enabled, this is the amount of "
					.. "gold considered cheap.  It is less than or equal to this number.",
					min = 0,
					max = 50,
					step = 1,
					getFunc = function () return self:getSliderValue('destroyCheapValue', ZJH.Vars.currencyColor .. '%s gold') end,
					setFunc = function (value) return self:setSliderValue('destroyCheapValue', value) end
				},
				[11] = {
					type = "checkbox",
					name = "|cFF0000Do Not Destroy Stacks.",
					tooltip = "|cFF0000 Do not destroy stacks less than or equal to the value in the slider below",
					getFunc = function () return self:getBooleanOption('noDestroyStackOver') end,
					setFunc = function () self:toggleBooleanOption('noDestroyStackOver') end
				},
				[12] = {
					type = "slider",
					name = "|cFF0000Size Of Stack Before We Do Not Destroy",
					tooltip = "|cFF0000If 'Do Not Destroy Stacks' is enabled, this is the minimum size of stack "
					.."that will be destroyed.  Any stack larger will be spared.",
					min = 0,
					max = 50,
					step = 1,
					getFunc = function () return self:getSliderValue('noDestroyStackOverCount', ZJH.Vars.currencyColor .. '%s items') end,
					setFunc = function (value) return self:setSliderValue('noDestroyStackOverCount', value) end
				}
			}
		}
	})
end
