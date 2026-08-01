-- ***** Pawprints' PVP Tools - Menu *****



--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
local PT = PVPTools

--------------------------------------------------
-- CreateSettingsMenu - Create the in-game settings menu
--------------------------------------------------
function PT.CreateSettingsMenu()
	if PT.debug then PT.DebugEntry("PVPTools.CreateSettingsMenu start") end
	
	--/script local am = GetAddOnManager() for i = 1, am:GetNumAddOns() do local n = am:GetAddOnInfo(i) if (n:match( "LibAddonMenu")) then d(zo_strformat("<<1>> -- <<2>>", n, am:GetAddOnVersion(i))) end end
	
	--------------------------------------------------
	-- Initialize menu variables
	--------------------------------------------------
	local LAM = LibAddonMenu2
	local lamPanelName = "PVPToolsSettingsPanel"
	local lamOptionsTable = {}
	local tempTable = {}
	
	--------------------------------------------------
	-- Set up the menu panel information
	--------------------------------------------------
	local lamPanelData = {
		type = "panel",
		name = "PVPTools",
		registerForRefresh = true,
		displayName = PT.displayName,
		author = PT.author,
		website = PT.website,
		version = PT.version,
		donation = PT.donation
	}
	
	-- This addonmanager section is based on a script created by Kyzderp (https://kyzderp.notion.site/Add-on-Troubleshooting-2f5a9796dc154c8293ff66cb653a0788#823bb2a26f5c4bf0ba8bf0079546baf3) and enhanced by what I found on the wiki https://wiki.esoui.com/IsAddonRunning
	local am = GetAddOnManager()
	for i = 1, am:GetNumAddOns() do
		local name, _, _,_,_,status = am:GetAddOnInfo(i)
		
		if ((name == "LibAddonMenu-2.0") and (status == ADDON_STATE_ENABLED)) then
			if (am:GetAddOnVersion(i) < PT.requiredLAMVersion) then
				tempTable = { -- description
					type = "description",
					title = "|cEE4B2BWARNING: OUTDATED LIBADDONMENU2 VERSION DETECTED.\n\n  This may cause unexpected errors or results when using the settings menu. Reloadui may fix the problem.  Otherwise you will have to check your addon's directory on your computer to find where the outdated LibAddonMenu2 is being loaded.  See the ESOUI page on LibAddonMenu2 (https://www.esoui.com/downloads/info7-LibAddonMenu-2.0.html) for instructions. Or you can try the automated tool found here (https://www.esoui.com/downloads/info4197-DeleteLibStubandEmbeddedlibraries.html)|r",
					width = "full"
				}
				table.insert(lamOptionsTable, tempTable)

			end
		end
	end
	
	--------------------------------------------------
	-- Acount-Wide notification
	--------------------------------------------------	
	tempTable = { --description
		type = "description",
		--text = "All Settings Are Account-Wide unless otherwise indicated.",
		title = "|ce8284fAll Settings Are Account-Wide|r",
		width = "full"
	}
	table.insert(lamOptionsTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 1,
	}
	table.insert(lamOptionsTable, tempTable)
	
	--------------------------------------------------
	-- HIDDEN DEBUG SUBMENU
	--------------------------------------------------
	if PT.IsMe("@pawprints.shadow") or PT.IsMe("@salmon_dispenser") then
		local hiddenDebugTable = PT.SubmenuHiddenDebug()
		
		tempTable = { -- submenu
			type = "submenu",
			name = "|cfff00000 - Debug|r",
			icon = "/esoui/art/icons/crafting_fishing_torchbug.dds",
			tooltip = "Toggle the debug option",
			controls = hiddenDebugTable
		}
		table.insert(lamOptionsTable, tempTable)
	end
	
	
	--------------------------------------------------
	-- QUEST SHARE SUBMENU
	--------------------------------------------------
	local submenuQuestShareTable = PT.SubmenuQuestShare()

	-- insert QuestShare submenu into the settings table
	tempTable = { -- submenu
		type = "submenu",
		name = "|c00ffff01 - Quest Share|r",
		icon = "/esoui/art/compass/zonestoryquest_available_icon.dds",
		tooltip = "Settings for Automated Quest Sharing \n----------\nOn-Demand Quest Sharing\nAuto Accept Quests\nLocation-Based Automatic Quest Sharing\nCyrodiil Daily Quest Tracking\nImperial City Daily Quest Tracking",
		controls = submenuQuestShareTable
	}
	table.insert(lamOptionsTable, tempTable)
	
		
	--------------------------------------------------
	-- QUALITY OF LIFE SUBMENU
	--------------------------------------------------
	local submenuQOLTable = PT.SubmenuQOL()
		
	-- insert Quality of Life submenu into the settings table
	tempTable = { -- submenu
		type = "submenu",
		name = "|c62d27f02 - Quality of Life|r",
		icon = "/esoui/art/icons/crowncrate_sweetroll.dds",
		tooltip = "Settings for Quality of Life Improvements.  \n----------\nRandom Multimount\nEmergency Exit\nUse Recall Stones",
		controls = submenuQOLTable,
	}
	table.insert(lamOptionsTable, tempTable)	

	--------------------------------------------------
	-- MERCHANT AND BANKING SUBMENU
	--------------------------------------------------
	local submenuMBTable = PT.SubmenuMB()
		
	-- insert Merchant and Banking submenu into the settings table
	tempTable = { -- submenu
		type = "submenu",
		name = "|cD4AF3703 - Merchant & Banking|r",
		icon = "/esoui/art/icons/store_upgrade_bank.dds",
		tooltip = "Settings for automated Merchant and Banking",
		controls = submenuMBTable
	}
	table.insert(lamOptionsTable, tempTable)

	--------------------------------------------------
	-- AUTO INVITE SUBMENU
	--------------------------------------------------
	local submenuAITable = PT.SubmenuAI()
	
	tempTable = {
		type = "submenu",
		name = "|cAF54D104 - Auto Invite|r",
		icon = "/esoui/art/treeicons/collection_indexicon_weapons+armor_up.dds",
		tooltip = "Settings for Auto Invite",
		controls = submenuAITable,	
	}
	table.insert(lamOptionsTable, tempTable)

	--------------------------------------------------
	-- DIVIDER BETWEEN SETTINGS AND USER MANUAL
	--------------------------------------------------
	-- /esoui/art/miscellaneous/centerscreen_topdivider.dds
	-- /esoui/art/charactercreate/windowdivider.dds
	-- /esoui/art/miscellaneous/listitem_divider.dds
	tempTable = {
		type = "texture",
		image = "/esoui/art/miscellaneous/centerscreen_topdivider.dds",
		imageWidth = 510,
		imageHeight = 15,
		width = "full",
		
	}
	table.insert(lamOptionsTable, tempTable)
	
	
	
	--------------------------------------------------
	-- QUEST SHARE MANUAL
	--------------------------------------------------
	local submenuQuestShareManualTable = PT.SubmenuQuestShareManual()
		
	-- insert QuestShare Manual submenu into the settings table
	tempTable = {
		type = "submenu",
		name = "|c00ffffQuest Share Manual|r",
		icon = "/esoui/art/icons/divineslore_book2.dds",
		tooltip = "Instructions for using Quest Share Options",
		controls = submenuQuestShareManualTable
	}
	table.insert(lamOptionsTable, tempTable)
	
	
	--------------------------------------------------
	-- QUALITY OF LIFE MANUAL
	--------------------------------------------------
	local submenuQOLManualTable = PT.SubmenuQOLManual()
	
	-- insert Quality of Life Manual submenu into the settings table
	tempTable = {
		type = "submenu",
		name = "|c62d27fQuality of Life Manual|r",
		icon = "/esoui/art/icons/divineslore_book2.dds",
		tooltip = "Instructions for using Quality of Life Options",
		controls = submenuQOLManualTable
	}
	table.insert(lamOptionsTable, tempTable)
	
	
	-- --------------------------------------------------
	-- -- MERCHANT AND BANKING MANUAL
	-- --------------------------------------------------
	local submenuMBManualTable = PT.SubmenuMBManual()
	
	-- insert Merchant & Banking Manual submenu into the settings table
	tempTable = {
		type = "submenu",
		name = "|cD4AF37Merchant & Banking Manual|r",
		icon = "/esoui/art/icons/divineslore_book2.dds",
		tooltip = "Instructions for using Merchant & Banking Options",
		controls = submenuMBManualTable
	}
	table.insert(lamOptionsTable, tempTable)
	
	
	--------------------------------------------------
	-- Assemble the pieces to Create the Menu
	--------------------------------------------------
	PT.LAMpanel = LAM:RegisterAddonPanel(lamPanelName, lamPanelData)
	LAM:RegisterOptionControls(lamPanelName, lamOptionsTable)
	
	if PT.debug then PT.DebugEntry("PVPTools.CreateSettingsMenu loaded") end
end


--------------------------------------------------
-- SubmenuHiddenDebug - Menu option to turn the debug setting on or off without having to reloadui.  The menu option will only display for the author.
--------------------------------------------------
function PT.SubmenuHiddenDebug()
	if PT.debug then PT.DebugEntry("PT.MenuHiddenDebug") end
	
	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- description
		type = "description",
		title = "Debug Button for Developer",
		width = "full",
	}
	table.insert(returnTable, tempTable)
		
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)
		
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Turn on Debug Functions",
		getFunc = function() return PT.debug end,
		setFunc = function(value) PT.ToggleDebug() end
	}
	table.insert(returnTable, tempTable)
		
	tempTable = { -- button
		type = "button",
		name = "Reload UI",
		func = function() ReloadUI() end,
		width = "full",
		--isDangerous = true,
	}
	table.insert(returnTable, tempTable)
		
	return returnTable
end


--------------------------------------------------
-- SubmenuQuestShare - Generate the submenu for the Quest Share Module
--------------------------------------------------
function PT.SubmenuQuestShare()
	if PT.debug then PT.DebugEntry("PVPTools.SubmenuQuestShare") end
	
	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- description
		type = "description",
		title = "|c00ffffSee manual below for how to use this module.|r",
		width = "full"
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 1,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use QuestShare Module: ",
		getFunc = function() return PT.ASV.settingsQSModuleOn end,
		setFunc = function(value) PT.QuestShare.ToggleModule() end
	}
	table.insert(returnTable, tempTable)
	
	---------- A - Automation and Tracking
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|c00ffffA - Automation and Tracking|r",
	}
	table.insert(returnTable, tempTable)
		
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Auto Share Quests: ",
		getFunc = function() return PT.ASV.settingsQSAutoShare end,
		setFunc = function(value) PT.QuestShare.ToggleAutoShare() end,
		disabled = function() return not PT.ASV.settingsQSModuleOn end
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Auto Accept Quests: ",
		getFunc = function() return PT.ASV.settingsQSAutoAccept end,
		setFunc = function(value) PT.QuestShare.ToggleAutoAccept() end,
		disabled = function() return not PT.ASV.settingsQSModuleOn end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Track Daily Quests: ",
		tooltip = "Track each characters daily Cyrodiil and Imperial City Quests.",
		getFunc = function() return PT.ASV.settingsQSTrackDaily end,
		setFunc = function(value) PT.QuestShare.ToggleTrackDaily() end,
		disabled = function() return not PT.ASV.settingsQSModuleOn end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "A keybind called |cffb6c1\"Quick Share Quest\"|r is available to share the quest for your current location if you have the quest."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "A keybind called |cffb6c1\"Display Daily PVP Quest Timers\"|r is available to display the daily quest timers."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|c00ffffCommand line to ask a group member to share quest|r",
		text = "Used to check if anyone in your group has a specific quest to share.  The message must be in group chat and start with \"qs\".  The person with the quest to share must have PVPTools installed and auto quest sharing enabled.  A list of valid qs statements is provided in the manual section.  Anticipated shortcuts and misspellings are not listed.  \n\nExample: \nqs here - asks if a group member has the capture quest for the group's current location.  If the group is in Imperial City, it asks if anyone has the Imperial City quests.\nqs ic - ask if anyone has the Imperial City daily quests\nqs timers - show the PVP related daily quests with the finished quests in red and the available ones in green\nqs bb lumber - ask if someone has the black boot lumbermill capture quest\nqs altadoon - ask if someone has the capture altadoon scroll quest\nqs nimohk - ask if someone has the capture ni-mohk scroll quest\nqs bloodmayne - ask if someone has the capture castle bloodmayne quest\nqs gyl - ask if someone has the capture castle faregyl quest\nqs gut - ask if someone has the capture farragut keep quest",
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	---------- B - Announcements
	do -- Code Folding
	tempTable = { -- header
		type = "header",
		name = "|c00ffffB - Announcements|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Center Screen To Announce: ",
		tooltip = "Toggle if important quest share messages should be displayed in the Center Screen Announcement area",
		getFunc = function() return PT.ASV.settingsQSCenterAnnounce end,
		setFunc = function(value) PT.QuestShare.ToggleAnnounce() end,
		disabled = function() return not PT.ASV.settingsQSModuleOn end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Alert System: ",
		tooltip = "Toggle if important quest share messages should be displayed in the in-game alert area on the right hand side of the screen",
		getFunc = function() return PT.ASV.settingsQSAlert end,
		setFunc = function() PT.QuestShare.ToggleAlert() end,
		disabled = function() return not PT.ASV.settingsQSModuleOn end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "Note:",
		text = "A copy of the |c00ffffQuest Share|r announcements will always be placed in the chat window with the prefix |c00ffff[QS]|r",
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	return returnTable
end


--------------------------------------------------
-- SubmenuQOL - Generate the submenu for the Quality of Life Module
--------------------------------------------------
function PT.SubmenuQOL()
	if PT.debug then PT.DebugEntry("PVPTools.SubmenuQOL") end
	
	local tempTable = {}
	local returnTable = {}
	
	----------- A - Announcements
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|c62d27fA - Announcements|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Center Screen To Announce: ",
		tooltip = "Toggle if important quest share messages should be displayed in the Center Screen Announcement area",
		getFunc = function() return PT.ASV.settingsQOLCenterAnnounce end,
		setFunc = function(value) PT.QOL.ToggleCenterAnnounce() end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Alert System: ",
		tooltip = "Toggle if important quest share messages should be displayed in the in-game alert area on the right hand side of the screen",
		getFunc = function() return PT.ASV.settingsQOLAlert end,
		setFunc = function() PT.QOL.ToggleAlert() end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "Note:",
		text = "A copy of the |c62d27fQuality Of Life|r announcements will always be placed in the chat window with the prefix |c62d27f[QOL]|r",
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	----------- B - Emergency Exit
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|c62d27fB - PVP Queue|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Automatically Accept PVP Queue: ",
		tooltip = "Automatically accept when a pvp queue is ready",
		getFunc = function() return PVPTools.ASV.settingsQOLAutoAcceptQueue end,
		setFunc = function() PVPTools.QOL.ToggleAutoAcceptQueue() end,
	}
	table.insert(returnTable, tempTable)
		
	--[[
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Emergency Exit:",
		tooltip = " ",
		getFunc = function() return PVPTools.ASV.settingsQOLEmergencyExit end,
		setFunc = function() PVPTools.QOL.ToggleEmergencyExit() end,
	}
	table.insert(returnTable, tempTable)
	
	
	To get the campaign instance names and number
	
	/script for i=1,150 do d(string.format('%d: %s', i, GetCampaignName(i))) end
	
	
	The available campaigns will have to be hard coded because of limitations requiring the Campaign Manager to initialize. Using the below script will only work after the Alliance War window has been opened at least once.  There is currently no way to see which campaigns are active until opening the Alliance War window.
	
	/script 
		for _, campaignData in ipairs(CAMPAIGN_BROWSER_MANAGER.selectionCampaignList) do
			df("%d - %s", campaignData.id, campaignData.name)
		end
	
	
	--TODO
	tempTable = { -- description
		type = "description",
		title = "Emergency Exit Changes",
		text = "With update 49 the ability to queue out of Imperial City has been severely limited (can only queue if you have less than 100 telvar).\n\nAt this time you are still able to queue from one instance of Imperial City to the other regardless of how much Telvar you have.  This was reported in the ESO Forums in the Bug Reports section on March 11, 2026.  I specifically asked if this was an exploit, or if it was working as expected.  As of March 31st THERE WAS NO RESPONSE.  Since they have not stated it was an exploit, I am returning the Emergency Exit to the addon.\n\nIf at some point in the future, they choose to disable this then you still have the option of using the Sigil Keybind. The ability to |cffb6c1keybind a Sigil of Imperial Retreat|r has been added to this addon.  This is found in the in-game Controls (press escape and select controls)."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- dropdown
		type = "dropdown",
		name = "Preferred Instance of Cyrodiil: ",
		tooltip = "Choose which instance of Cyrodiil the addon will try jumping to first.  If the preferred instance is full it will try the other option.",
		choices = {"Ravenwatch", "Blackreach"},
		choicesValues = {103, 101},
		getFunc = function() return PVPTools.ASV.settingsQOLPreferredCyrodiil end,
		setFunc = function(selection) if PT.debug then PT.DebugEntry(selection) end PVPTools.ASV.settingsQOLPreferredCyrodiil = selection end,
		disabled = function() return not PVPTools.ASV.settingsQOLEmergencyExit end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- dropdown
		type = "dropdown",
		name = "Preferred Instance of Imperial City: ",
		tooltip = "Choose which instance of Cyrodiil the addon will try to jump to first.  if the preferred instance is full, it will try the other option.",
		choices = {"CP Imperial City", "No CP Imperial City"},
		choicesValues = {95, 96},
		getFunc = function() return PVPTools.ASV.settingsQOLPreferredImperialCity end,
		setFunc = function(selection) if PT.debug then PT.DebugEntry(selection) end PVPTools.ASV.settingsQOLPreferredImperialCity = selection end,
		disabled = function() return not PVPTools.ASV.settingsQOLEmergencyExit end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "This feature is triggered by a keybind called |cffb6c1\"Emergency Exit\"|r.  Set the keybind using the in-game CONTROLS."
	}
	--]]
	
	end -- Code Folding
	
	---------- C - Recall Stones
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|c62d27fC - Recall Stones|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "A keybind called |cffb6c1\"Use Recall Stone\"|r is available to use a Recall Stone at the press of a button.  If the player is in Cyrodiil it will attempt to use a Keep Recall Stone.  If the user is in Imperial City it will attempt to use a Sigil of Imperial Retreat."
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	----------- D - Multimount
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|c62d27fD - Use Random Multimount|r",
	}
	table.insert(returnTable, tempTable)
	
	if FavoriteMount then
		tempTable = { -- checkbox
			type = "checkbox",
			name = "Use only Multimounts: ",
			tooltip = "Multimounts option is being controlled by FavoriteMount",
			getFunc = function() return PVPTools.ASV.settingsQOLMultimountOn end,
			setFunc = function() PVPTools.QOL.ToggleMultiMountOnly() end,
			disabled = function() return true end,
		}
		table.insert(returnTable, tempTable)
	else
		PVPTools.QOL.PopulateMultiMountsList()
		if #PVPTools.QOL.multiMountsList > 0 then
			tempTable = {
				type = "checkbox",
				name = "Use only Multimounts: ",
				tooltip = "Use only a randomly selected multimount",
				getFunc = function() return PVPTools.ASV.settingsQOLMultimountOn end,
				setFunc = function() PVPTools.QOL.ToggleMultiMountOnly() end,
			}
			table.insert(returnTable, tempTable)
		else
			tempTable = {
				type = "checkbox",
				name = "Use only Multimounts: ",
				tooltip = "You do not own any multimounts",
				getFunc = function() return PVPTools.ASV.settingsQOLMultimountOn end,
				setFunc = function() end,
				disabled = function() return true end,
			}
		table.insert(returnTable, tempTable)
		end
	end
	
	tempTable = { --description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "A keybind called |cffb6c1\"Use Only Multimounts\"|r is available to toggle the Use only Multimounts option. This requires you have at least one multimount unlocked."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cffb6c1Keybind:|r",
		text = "A keybind called |cffb6c1\"Ride Friend\'s Multimount\"|r is available to simplify riding someone else\'s multimount.  Just target the person and press the keybind."
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	
	
	return returnTable
end


--------------------------------------------------
-- SubmenuMB - Generate the submenu for the Merchant and Banking Module
--------------------------------------------------
function PT.SubmenuMB()
	if PT.debug then PT.DebugEntry("PVPTools.SubmenuMB") end 
	
	local tempTable = {}
	local returnTable = {}
	
	---------- A - Automatic Banking
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|cD4AF37A - Automatic Banking |r|t64:64:/esoui/art/icons/housing_bre_lsb_signgeneral001.dds|t",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Automatic Banking: ",
		tooltip = "Use automatic banking to deposit or withdraw from the bank as needed.",
		getFunc = function() return PVPTools.ASV.settingsMBUseAutoBanking end,
		setFunc = function() PVPTools.MB.ToggleAutomaticBanking() end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)
		
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Automatically Bank Gold |t32:32:/esoui/art/currency/currency_gold_32.dds|t:",
		tooltip = "Allow Automatic Banking to withdraw or deposit gold.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Gold"][1] end,
		setFunc = function(value) PVPTools.ASV.settingsMBAutoBanking["Gold"][1] = value end,
		disabled = function() return not PVPTools.ASV.settingsMBUseAutoBanking end,
	}
	table.insert(returnTable, tempTable)
	
	-- PVPTools.ASV.settingsMBAutoBanking subtable structure
		-- ["currencyType"] = {[1]active, [2]minAmount, [3]maxAmount}
		
	tempTable = { -- editbox
		type = "editbox",
		name = "Minimum Gold in pocket: ",
		tooltip = "Select the minimum amount of gold you want on your character.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Gold"][2] end,
		setFunc = function(value) PVPTools.MB.SetMinimumAmount("Gold", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Gold"][1]) end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox	 
		type = "editbox",
		name = "Maximum Gold in pocket: ",
		tooltip = "Select the maximum amount of gold you want on your character (subject of funds availablity, some restrictions apply)",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Gold"][3] end,
		setFunc = function(value) PVPTools.MB.SetMaximumAmount("Gold", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Gold"][1]) end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)	 
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Automatically Bank Telvar |t32:32:/esoui/art/currency/currency_telvar_32.dds|t:",
		tooltip = "Allow Automatic Banking to withdraw or deposit telvar.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Telvar"][1] end,
		setFunc = function(value) PVPTools.ASV.settingsMBAutoBanking["Telvar"][1] = value end,
		disabled = function() return not PVPTools.ASV.settingsMBUseAutoBanking end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox
		type = "editbox",
		name = "Minimum Telvar in pocket: ",
		tooltip = "Select the minimum amount of Telvar you want on your character.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Telvar"][2] end,
		setFunc = function(value) PVPTools.MB.SetMinimumAmount("Telvar", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Telvar"][1]) end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox	 
		type = "editbox",
		name = "Maximum Telvar in pocket: ",
		tooltip = "Select the maximum amount of Telvar you want on your character (subject of funds availablity, some restrictions apply)",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Telvar"][3] end,
		setFunc = function(value) PVPTools.MB.SetMaximumAmount("Telvar", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Telvar"][1]) end,
	}
	table.insert(returnTable, tempTable)

	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)	 
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Automatically Bank Alliance Points |t32:32:/esoui/art/currency/alliancepoints_32.dds|t:",
		tooltip = "Allow Automatic Banking to withdraw or deposit Alliance Points.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][1] end,
		setFunc = function(value) PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][1] = value end,
		disabled = function() return not PVPTools.ASV.settingsMBUseAutoBanking end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox
		type = "editbox",
		name = "Minimum Alliance Points in pocket: ",
		tooltip = "Select the minimum amount of Alliance Points you want on your character.",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][2] end,
		setFunc = function(value) PVPTools.MB.SetMinimumAmount("Alliance Points", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][1]) end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox	 
		type = "editbox",
		name = "Maximum Alliance Points in pocket: ",
		tooltip = "Select the maximum amount of Alliance Points you want on your character (subject of funds availablity, some restrictions apply)",
		getFunc = function() return PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][3] end,
		setFunc = function(value) PVPTools.MB.SetMaximumAmount("Alliance Points", value) end,
		disabled = function() return (not PVPTools.ASV.settingsMBUseAutoBanking) or (not PVPTools.ASV.settingsMBAutoBanking["Alliance Points"][1]) end,
	}
	table.insert(returnTable, tempTable)
	
	end -- Code Folding
	
	
	---------- B - Imperial Fragments
	do -- Code Folding
		tempTable = { -- header
			type = "header",
			name = "|cD4AF37B - Imperial City Fragment Shopping|r |t80%:80%:/esoui/art/currency/currency_imperial_trophy_key_mipmap.dds|t "
		}
		table.insert(returnTable, tempTable)
		
		tempTable = {
			type = "checkbox", 
			name = "Use Imperial City Treasure Vaults Automation:",
			tooltip = "Automate opening resource bags in Imperial City Treasure Vaults",
			getFunc = function() return PVPTools.ASV.settingsMBUseFragmentMerchant end,
			setFunc = function() PVPTools.MB.ToggleFragmentMerchant()end,
		}
		table.insert(returnTable, tempTable)
		
		tempTable = { -- editbox (disabled)
			type = "editbox",
			name = "Amount of Imperial Fragments you own: ",
			getFunc = function() return ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT)) end,
			disabled = true,
		}
		table.insert(returnTable, tempTable)
		
		tempTable = { -- divider
			type = "divider",
			alpha = 1,
		}
		table.insert(returnTable, tempTable)
		
		-- Imperial Fragments Shopping Table
		local tableMBImperialFragments = {
			[1] 	= {"Arena", "Alchemical Sachet"},
			[2] 	= {"Arboretum", "Carpentry Crate"},
			[3] 	= {"Elven Gardens", "Chest of Runes"},
			[4] 	= {"Memorial", "Clothier Coffer"},
			[5] 	= {"Temple", "Sack of Provisions"},
			[6] 	= {"Nobles", "Smithy Case"},
		}
		
		tempTable = {
			type = "description",
			text = "Each one costs 20|t80%:80%:/esoui/art/currency/currency_imperial_trophy_key_mipmap.dds|t.",
		}
		table.insert(returnTable, tempTable)
		
		for key, data in ipairs(tableMBImperialFragments) do
			tempTable = { -- description
				type = "description",
				text = "Purchase Imperial "..data[2].." in "..data[1].." District." ,	
			}
			table.insert(returnTable, tempTable)
		end
	end -- Code Folding
	
	
	---------- C - Shopping
	do -- Code Folding
	
	tempTable = { -- header
		type = "header",
		name = "|cD4AF37C - Cyrodiil Siege Merchant Shopping |r|t64:64:/esoui/art/icons/housing_bre_lsb_smlsignbank001.dds|t",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Use Anotmatic Merchant: ",
		tooltip = "Automatically perform actions when accessing a merchant in Cyrodiil.",
		getFunc = function() return PVPTools.ASV.settingsMBUseAutoMerchant end,
		setFunc = function(value) PVPTools.MB.ToggleAutomaticMerchant() end,
	}
	table.insert(returnTable, tempTable)
	
	
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox
		type = "editbox",
		name = "Number of bag spaces to reserve: ",
		getFunc = function() return PVPTools.ASV.settingsMBReserveBagSpace end,
		setFunc = function(value) PVPTools.MB.SetReserveBankSpace(value) end,
		disabled = function() return not PVPTools.ASV.settingsMBUseAutoMerchant end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 10,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)
	
	local shoppingGeneralOrderTable = {
		-- [indexNumber]	=	{[1]itemName, [2]itemIcon, [3]apCost [4]goldPurchase, [5]goldCost(nillable) [6]stackSize}
		[1] = 	{	"Keep Recall Stone",
					"/esoui/art/icons/rune_a.dds",
					20000,
					false,
					0,
					10,
				},
		[2] = 	{	"Bound Tri-Restoration Potion",
					"/esoui/art/icons/crownpotion_trires.dds",
					1000,
					false,
					0,
					200,
				},
		[3] = 	{	"Alliance Battle Draught",
					"/esoui/art/icons/consumable_potion_010_type_003.dds",
					720,
					false,
					0,
					200,
				},
		[4] = 	{	"Alliance Health Draught",
					"/esoui/art/icons/consumable_potion_008_type_003.dds",
					720,
					false,
					0,
					200,
				},
		[5] = 	{	"Alliance Spell Draught",
					"/esoui/art/icons/consumable_potion_009_type_003.dds",
					720,
					false,
					0,
					200,
				},
		[6] = 	{	"Cyrodilic Field Bar",
					"/esoui/art/icons/crafting_bread_001.dds",
					2400,
					false,
					0,
					200,
				},
		[7] = 	{	"Cyrodilic Field Brew",
					"/esoui/art/icons/crafting_beer_001.dds", 
					2400,
					false,
					0,
					200,
				},
		[8] =	{	"Cyrodilic Field Tack",
					"/esoui/art/icons/crafting_bread_002.dds",
					2400,
					false,
					0,
					200,
				},
		[9] =	{	"Cyrodilic Field Tea",
					"/esoui/art/icons/crafting_tea_001.dds",
					2400,
					false,
					0,
					200,
				},
		[10] = 	{	"Cyrodilic Field Tonic",
					"/esoui/art/icons/crafting_spirits_001.dds",
					2400,
					false,
					0,
					200,
				},
		[11] =	{	"Cyrodilic Field Treat",
					"/esoui/art/icons/crafting_cake_005.dds",
					2400,
					false,
					0,
					200,
				},
		[12] =	{	"Soul Gem",
					"/esoui/art/icons/soulgem_006_filled.dds",
					750,
					false,
					0,
					200,
				},
		[13] =	{	"Soul Gem (Empty)",
					"/esoui/art/icons/soulgem_006_empty.dds",
					0,
					true,
					156,
					200,
				},
	}
	
	local shoppingCampTable = {
		["Dominion Forward Camp"]	=	"/esoui/art/icons/ava_siege_ui_006.dds",
		["Covenant Forward Camp"]	=	"/esoui/art/icons/ava_siege_ui_007.dds",
		["Pact Forward Camp"]		=	"/esoui/art/icons/ava_siege_ui_008.dds",
	}
	
	local shoppingSiegeOrder = {
		-- [indexNumber]	=	{[1]itemName, [2]itemIcon, [3]apCost [4]goldPurchase, [5]goldCost(nillable), [6]stackSize}
		[1] = 	{	"Cyrodiil Repair Kit",
					"/esoui/art/icons/u41_ava_unifiedrepairkit.dds", 
					250,
					true,
					90,
					200,
		},
		[2]	=	{	"Ballista",
					"/esoui/art/icons/ava_siege_weapon_001.dds",
					1800,
					false,
					0,
					20,
		},
		[3] = 	{	"Flaming Oil",
					"/esoui/art/icons/ava_siege_weapon_002.dds",
					800,
					false,
					0,
					20,
				},
		[4]	=	{	"Battering Ram",
					"/esoui/art/icons/ava_siege_weapon_004.dds",
					1800,
					false,
					0,
					20,
				},
		[5]	=	{	"Meatbag Catapult",
					"/esoui/art/icons/ava_siege_ui_003.dds",
					1200,
					false,
					0,
					20,
				},
		[6]	=	{	"Firebolt Ballista",
					"/esoui/art/icons/ava_siege_weapon_001.dds",
					1200,
					true,
					750,
					20,
				},
		[7]	=	{	"Lightning Ballista",
					"/esoui/art/icons/ava_siege_weapon_001.dds",
					1200,
					false,
					0,
					20,
				},
		[8]	=	{	"Oil Catapult",
					"/esoui/art/icons/ava_siege_ui_003.dds",
					1200,
					false,
					0,
					20,
				},
		[9]	=	{	"Scattershot Catapult",
					"/esoui/art/icons/ava_siege_ui_003.dds",
					1200,
					false,
					0,
					20,
				},
		[10]	=	{	"Firepot Trebuchet",
					"/esoui/art/icons/ava_siege_weapon_005.dds",
					1800,
					true,
					750,
					20,
				},
		[11]	=	{	"Iceball Trebuchet",
					"/esoui/art/icons/ava_siege_weapon_005.dds",
					1800,
					false,
					0,
					20,
				},
		[12]=	{	"Stone Trebuchet",
					"/esoui/art/icons/ava_siege_weapon_005.dds",
					1800,
					false,
					0,
					20,
				},
		[13]=	{	"Forward Camp",
					"/esoui/art/icons/ava_siege_ui_008.dds",
					20000,
					false,
					0,
					10,
				},
	}
	
	-- [indexNumber]	=	{[1]itemName, [2]itemIcon, [3]apCost [4]goldPurchase, [5]goldCost(nillable) [6]stackSize}
	for index, data in ipairs(shoppingSiegeOrder) do
		local itemName		= data[1]
		local itemIcon		= data[2]
		local apCost		= data[3]
		local goldPurchase 	= data[4]
		local goldCost		= data[5]
		local stackSize		= data[6]
		local maxPurchase 	= stackSize * 2
		local stepSize 		= math.floor(maxPurchase / 10)
		local tempName 	= "|t40:40:"..itemIcon.."|t - "..itemName .. " - (cost "..ZO_CommaDelimitNumber(apCost).." |t24:24:/esoui/art/currency/alliancepoints_32.dds|t each)"
		local tempTooltip	= "Purchase "..itemName.." automatically.  Stack size: "..stackSize
		
		if itemName == "Forward Camp" then
			tempName = ""
			for item, icon in pairs(shoppingCampTable) do
				tempName = tempName.."|t40:40:"..icon.."|t "
			end
			tempName = tempName.." - "..itemName .. " - (cost "..ZO_CommaDelimitNumber(apCost).." |t24:24:/esoui/art/currency/alliancepoints_32.dds|t each)"
		end
		
		tempTable = {
			type = "slider",
			name = tempName,
			tooltip = tempTooltip,
			min = 0,
			max = maxPurchase,
			autoSelect = true,
			step = stepSize,
			getFunc = function() return PVPTools.ASV.settingsMBAutoMerchant[itemName][1] end,
			setFunc = function(value) PVPTools.ASV.settingsMBAutoMerchant[itemName][1] = value end,
			disabled = function() return not PVPTools.ASV.settingsMBUseAutoMerchant end,
		}
		table.insert(returnTable, tempTable)
		
		if goldPurchase and apCost ~= 0 then
			tempTable = {
				type = "checkbox",
				name = "|t40:40:"..itemIcon.."|t - ".."Purchase using "..ZO_CommaDelimitNumber(goldCost).." |t32:32:/esoui/art/icons/housing_gen_inc_coinstack004.dds|t each instead: ",
				tooltip = "Purchase "..itemName.." using gold.",
				getFunc = function() return PVPTools.ASV.settingsMBAutoMerchant[itemName][2] end,
				setFunc = function(value) PVPTools.ASV.settingsMBAutoMerchant[itemName][2] = value end,
				disabled = function() return not PVPTools.ASV.settingsMBUseAutoMerchant end,
			}
			table.insert(returnTable, tempTable)
		end	
	end

	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 10,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)

	-- [indexNumber]	=	{[1]itemName, [2]itemIcon, [3]apCost [4]goldPurchase, [5]goldCost(nillable) [6]stackSize}
	for index, data in ipairs(shoppingGeneralOrderTable) do
		local itemName 		= data[1]
		local itemIcon 		= data[2]
		local apCost		= data[3]
		local goldPurchase	= data[4] --bool
		local goldCost		= data[5]
		local stackSize		= data[6]
		local maxPurchase 	= stackSize * 2
		local stepSize 		= math.floor(maxPurchase / 10)
		local tempName = "|t40:40:"..itemIcon.."|t - "..itemName .. " - (cost "..ZO_CommaDelimitNumber(apCost).." |t24:24:/esoui/art/currency/alliancepoints_32.dds|t each)"
		local tempTooltip = "Purchase "..itemName.." automatically.  Stack size: "..stackSize
		
		if goldPurchase then tempTooltip = tempTooltip.."  Can be purchased with "..ZO_CommaDelimitNumber(goldCost).." gold." end
		if apCost == 0 then	-- there is one item that can only be purchased with gold
			tempName = "|t40:40:"..itemIcon.."|t - "..itemName .. " - (cost "..ZO_CommaDelimitNumber(goldCost).." |t32:32:/esoui/art/icons/housing_gen_inc_coinstack004.dds|t each)"
			tempTooltip = "Purchase "..itemName.." automatically.  Can only be purchased with gold.  Stack size: "..stackSize
		end
		tempTable = {
			type = "slider",
			name = tempName,
			tooltip = tempTooltip,
			min = 0,
			max = maxPurchase,
			autoSelect = true,
			step = stepSize,
			getFunc = function() return PVPTools.ASV.settingsMBAutoMerchant[itemName][1] end,
			setFunc = function(value) PVPTools.ASV.settingsMBAutoMerchant[itemName][1] = value end,
			disabled = function() return not PVPTools.ASV.settingsMBUseAutoMerchant end,
		}
		table.insert(returnTable, tempTable)
		
		if goldPurchase and apCost ~= 0 then
			tempTable = {
				type = "checkbox",
				name = "|t40:40:"..itemIcon.."|t - ".."Purchase using "..ZO_CommaDelimitNumber(goldCost).." |t32:32:/esoui/art/icons/housing_gen_inc_coinstack004.dds|t each instead: ",
				tooltip = "Purchase "..itemName.." using gold.",
				getFunc = function() return PVPTools.ASV.settingsMBAutoMerchant[itemName][2] end,
				setFunc = function(value) PVPTools.ASV.settingsMBAutoMerchant[itemName][2] = value end,
				disabled = function() return not PVPTools.ASV.settingsMBUseAutoMerchant end,
			}
			table.insert(returnTable, tempTable)
		end	
	end
	
	end -- Code Folding
	
	
	return returnTable
end


--------------------------------------------------
-- SubmenuAI - Generate the submenu for the Auto Invite Module
--------------------------------------------------
function PT.SubmenuAI()
	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- checkbox
		type = "checkbox",
		name = "Enable Auto Invite Moduel: ",
		tooltip = "Turn on and off the Auto Invite Module.",
		getFunc = function() return PVPTools.ASV.settingsAIModuleOn end,
		setFunc = function(value) PVPTools.AutoInvite.ToggleAutoInviteModule() end,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		width = "full",
		text = "After you turn on the Auto Invite Module the rest of the Auto Invite is found in the Group & Activity Finder Menu.  Select the purple AutoInvite option and choose your settings for each individual listener.  You can use one, two or all three listeners at the same time.",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- divider
		type = "divider",
		width = "full",
		height = 15,
		alpha = 0.5,
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		width = "full",
		text = "The list of banned players is maintained here.  Selecting someone on the banned list dropdown will  |cFF0000remove|r them from the list and allow them to join group.\n\nAll other elements of the autoinvite feature are accessed through a new element in the in-game Group Finder menu.",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- header
		type = "header",
		name = "Ban List",
		tooltop = "List of people you have banned from joining group.",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- editbox
		type = "editbox",
		name = "Account to Add: ",
		tooltip = "The in-game @ name of the person to ban from joining group.",
		getFunc = function() end,
		setFunc = function(value) PVPTools.AutoInvite.AddToIgnoreList(value) end,
		disabled = function() return not PVPTools.ASV.settingsAIModuleOn end,
		default = "",
		reference = "AutoInviteBanPerson",
	}
	table.insert(returnTable, tempTable)
	
	local bannedKey = {}
	local bannedNames = {}
	
	if #PVPTools.ASV.settingsAIIgnoreList > 0 then
		for key, banned in ipairs(PVPTools.ASV.settingsAIIgnoreList) do
			table.insert(bannedKey, key)
			table.insert(bannedNames, banned)
		end
	end
	
	tempTable = {
		type = "dropdown",
		name = "Banned List: ",
		scrollable = true,
		sort = "name-up",
		reference = "AutoInviteBannedList",
		getFunc = function() return end,
		setFunc = function(key) PVPTools.AutoInvite.RemoveFromIgnoreList(key) end,
		choices = bannedNames,
		choicesValues = bannedKey,
	}
	table.insert(returnTable, tempTable)
	
	return returnTable
	
end


--------------------------------------------------
-- SubmenuQuestShareManual - Generate the submenu for the Quest Share Manual
--------------------------------------------------
function PT.SubmenuQuestShareManual()
	if PT.debug then PT.DebugEntry("PT.SubmenuQuestShareManual") end
	
	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- header
		type = "header",
		name = "|c00ffffQuestShare Manual|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|c00ffffGeneral Use|r",
		text = "Used to check if anyone in your group has a specific quest to share.  The message must be in group chat and start with \"qs\".  The person with the quest to share must have PVPTools installed and auto quest sharing enabled.  A list of valid qs statements is provided at the end of this manual.  Anticipated shortcuts and misspellings are not listed.  \n\nExample: \nqs ic - ask if anyone has the Imperial City daily quests\nqs bb lumber - ask if someone has the black boot lumbermill capture quest\nqs altadoon - ask if someone has the capture altadoon scroll quest\nqs nimohk - ask if someone has the capture ni-mohk scroll quest\nqs bloodmayne - ask if someone has the capture castle bloodmayne quest\nqs gyl - ask if someone has the capture castle faregyl quest\nqs gut - ask if someone has the capture farragut keep quest",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = {
		type = "description",
		title = "|c00ffffqs here|r",
		text = "A special request called \"qs here\" will trigger other addon users to check if they have a quest to share.  The quest search is based on the |l0:1:1:3:1:ffffff|lreceiver's|l current location.  If the receiving player is in Cyrodiil it will check if they have the capture quest for the current location and share it if they do.  If the receiving player is in Imperial City then it will try to share the Imperial City daily quests.\n\nThere is also a keybind called |cffb6c1Quick Share Quest|r (under in-game CONTROLS) that can be used as a quick share for the current location |l0:1:1:3:1:ffffff|lby the person who has the quest|l.  If the person is in Cyrodiil it will attempt to share the capture quest for the current location.  If the person is in Imperial City it will attempt to share all Imperial City daily quests."  
	}
	table.insert(returnTable, tempTable)
	
	tempTable = {
		type = "description",
		title = "|c00ffffQuest Timers|r",
		text = "If you have the track daily quests option turned on then \"qs timers\" will show available daily quests in green and completed daily quests in red.  There is also an otpion to keybind |cffb6c1Display Daily PVP Quest Timers|r (under in-game CONTROLS) to display daily PVP quest timers."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = {
		type = "description",
		title = "|c00ffffAnnouncements|r",
		text = "The Center Announce option will display important announcements in the center of the screen.  The alert option will use the alert system located on the right side of the screen.  All quest share related messages will show in the chat window.",
	}
	table.insert (returnTable, tempTable)
	
	local qsRequests = {
		" ----- ",
		"qs ic = all available Imperial City Daily Quests",
		"qs here = ask if anyone has the quest for the current location",
		"qs timer = display daily PVP quest timers", 
		" ----- ",
		"qs resources = Capture Any Nine Resources",
		"qs keeps = Capture Any Three Keeps",
		"qs towns = Capture All 3 Towns",
		"qs 150 = Kill 150 Enemy Players",
		" ----- ",
		"qs chim = The Elder Scroll of Chim",
		"qs gartok = The Elder Scroll of Ghartok",
		"qs ni-mohk = The Elder Scroll of Ni-Mohk" ,
		"qs alma-ruma = The Elder Scroll of Alma Ruma",
		"qs altadoon = The Elder Scroll of Altadoon",
		"qs mnem = The Elder Scroll of Mnem",
		" ----- ",
		"qs players = Kill Enemy Players",
		"qs templars = Kill Enemy Templars",
		"qs nightblades = Kill Enemy Nightblades",
		"qs sorcerers = Kill Enemy Sorcerers",
		"qs dragonknights = Kill Enemy Dragonknights",
		"qs wardens = Kill Enemy Wardens",
		"qs necromancers = Kill Enemy Necromancers",
		"qs arcanists = Kill Enemy Arcanists",
		" ----- ",
		"qs blackboot = Capture Castle Black Boot",
		"qs bloodmayne = Capture Castle Bloodmayne",
		"qs faregyl = Capture Castle Faregyl",
		"qs gyl = Capture Castle Faregyl",
		"qs alessia = Capture Castle Alessia",
		"qs roebeck = Capture Castle Roebeck",
		"qs brindle = Capture Castle Brindle",
		"qs drakelowe = Capture Drakelowe Keep",
		"qs blueroad = Capture Blue Road Keep",
		"qs farragut = Capture Farragut Keep",
		"qs gut = Capture Farragut Keep",
		"qs arrius = Capture Arrius Keep",
		"qs kingscrest = Capture Kingscrest Keep",
		"qs chalman = Capture Chalman Keep",
		"qs ash = Capture Fort Ash",
		"qs dragonclaw = Capture Fort Dragonclaw",
		"qs aleswell = Capture Fort Aleswell",
		"qs glademist = Capture Fort Glademist",
		"qs warden = Capture Fort Warden",
		"qs rayles = Capture Fort Rayles",
		" ----- ",
		"qs requests for resources are formatted as qs <location> <type of resource>.  Here are a few examples using some shortcuts\n",
		"qs roe lm = Capture Robeck Lumbermill",
		"qs dragon farm = Capture Dragonclaw Farm",
		"qs ales mine = Capture Aleswell Mine",
		"qs bb mine = Capture Black Boot Mine",
		"qs gyl lm = Capture Ferregyl Lumbermill",
		"qs brindle farm = Capture Brindle Farm",
		"qs king lm = Capture Kingscrest Lumbermill",
		"qs gut farm = Capture Farragut Farm",
	}
	tempTable = {
		type = "description",
		title = "|c00ffffAvailable qs Requests:|r",
		text = table.concat(qsRequests,"\n")
	}
	table.insert(returnTable, tempTable)

	return returnTable
end


--------------------------------------------------
-- SubmenuQOLManual - Generate the submenu for the Quality of Life Manual
--------------------------------------------------
function PT.SubmenuQOLManual()
	if PT.debug then PT.DebugEntry ("PT.SubmenuQOLManual") end

	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- header
		type = "header",
		name = "|c62d27fHow to Use Quality of Life Options|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = {
		type = "description",
		title = "|c62d27fA - Announcements|r",
		text = "The Center Announce option will display important announcements in the center of the screen.  The alert option will use the alert system located on the right side of the screen.  All Quality of Life related messages will show in the chat window."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = {
		type = "description",
		title = "|c62d27fB - PVP Queue|r",
		text = "|c62d27fAutomatically Accept PVP Queue|r does exactly what it says.  It will automatically accept Imperial City and Cyrodiil queues when you are asked to confirm entry."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|c62d27fC - Recall Stones|r",
		text = "|c62d27fUse Recall Stone|r may be assigned to a |cffb6c1keybind|r (under in-game CONTROLS).  If the user is in Cyrodiil it will bring up the map for the user to select their recall location if the conditions for using a Keep Recall Stone are met.  If the user is in Imperial City it will begin the teleport to your faction's home base if the conditions for using a Sigil of Imperial Retreat are met."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|c62d27fD - Multimounts|r",
		text = "|c62d27fUse Only Multimounts|r is available if you have one or more multimounts unlocked.  Chooseing this option will cause a random multimount to be used each time you mount until the option is turned off.  When the option is turned off, the mount settings will return to their previous settings.  This option is compatable with FavoriteMount.  There is an option to keybind |cffb6c1(under in-game CONTROLS)|r using only multimounts. \n\nIn addition, there is an option to keybind |cffb6c1(under in-game CONTROLS)|r |c62d27fusing someone else\'s multimount|r.  It is found in the keybinds section and called Ride Friend\'s Multimount.  This is helpful when you need to catch a ride with someone.",
	}
	table.insert(returnTable, tempTable)
	
	return returnTable
end


--------------------------------------------------
-- SubmenuMBManual - Generate the submenu for the Quality of Life Manual
--------------------------------------------------
function PT.SubmenuMBManual()
	if PT.debug then PT.DebugEntry("PVPTools.SubmenuMBManual") end
	
	local tempTable = {}
	local returnTable = {}
	
	tempTable = { -- header
		type = "header",
		name = "|cD4AF37How to Use Merchant & Banking Options|r",
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cD4AF37A - Banking|r",
		text = "The Banking module will automate depositing gold, telvar and alliance points into your bank for safekeeping.  You can enabling Use Automatic Banking by selecting the option.  You can then individually choose if the gold, telvar, or allience point options are enabled. \n\nEach of the currency types allow you to set the minimum and maximum amount of the currency to carry on your character.  The minimum and maximum are checked and equalized.  For example if you have a minimum of 10, but a maximum of 5, then banking module will equalize it to both minimum and maximum being 5. \n\nBanking is done with deposits first (maximum amount), then any withdrawls (minimum amount).  If you do not have enough of the currency in the bank, you will receive an Insufficient Funds error.  If the amount in your bags are within the min-max range, then no action will be taken."
	}
	table.insert(returnTable, tempTable)
	
	tempTable = { -- description
		type = "description",
		title = "|cD4AF37B - Imperial City Imperial Fragment Automation|r",
		text = "Imperial City Trophy Vault merchants allow you to purchase resource material bags using Imperial Fragments with a different resource avaiable in each zone.  You are allowed to hold only one resource bag per resource type in your inventory.\n\nWith this module active, when you open the Trophy Vault store it will purchase the available resource bag, automatically close the store, open the resource bag and loot all of its contents.  Your purchase progress will be shown in the chat windows as well as your remaining amount of Imperial Fragments.  To purchase another resource bag, you will have to manually open up the merchant again which will once again trigger the automated purchase and open process.\n\nTo purchase other items from the Trophy Room merchant you will have to turn off this automation.",
	}
	table.insert(returnTable, tempTable)
	
	
	tempTable = { -- description
		type = "description",
		title = "|cD4AF37C - Merchant|r",
		text = "The Merchant module will automatically make purchases at any Cyrodiil merchant.  In the settings each type of item that the merchant sells is listed.  You are able to specify the maximum amount of each item you wish to have in your bags.  Items will automatically be purchased to get you up to that maximum amount as long as you have sufficient currency and bag space.  For items that are sold using multiple types of currency, you can specify the currency to use.\n\nAfter all the purchases are done, the screen will display 'Shopping Complete.'  This message will display after all attempts to purchase items are completed.  Check your chat window for messages indicating insufficient funds or bag space.\n\nAt no time will the Merchant module try sell any items."
	}
	table.insert(returnTable, tempTable)
	
	return returnTable
	
end


--------------------------------------------------
-- SubmenuAIManual - Generate the submenu for the Auto Invite Manual
--------------------------------------------------
function PT.SubmenuAIManual()
	if PT.debug then PT.DebugEntry("PVPTools.SubmenuAIManual") end

	local tempTable = {}
	local returnTable = {}
	
	
end





