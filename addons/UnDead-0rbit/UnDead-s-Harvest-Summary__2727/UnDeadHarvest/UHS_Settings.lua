UHS_Settings = {}

local LAM = LibAddonMenu2

--Setting Menu
function UHS_Settings.CreateSettings(AI)
	local panelName = "UnDeadHarvestSettingsPanel"

	local panelData = {
	   type = "panel",
		name = "UnDead's Harvest Summary",
		displayName = "|c91a3b0UnDead's |c00CCFFHarvest Summary|r",
		author = "|c91a3b0UnDead0rbit|r",
		website = "https://www.esoui.com/downloads/info2727-UnDeadsHarvestSummary.html",
        feedback = "https://www.esoui.com/portal.php?uid=60193&a=listbugs",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local OD = {}
	OD[#OD + 1] = {
		type = "header",
		name = "|c03c03cUnDead's Harvest Settings|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Here you can adjust which items to show in your UHS Display.",
	}
	OD[#OD + 1] = {
			type = "description",
			width = "half",
			text = "|c1dacd6Settings Contents|r\n|c00cc991.|r Harvest Goals\n|c00cc992.|r Item Toggles\n|c00cc993.|r Contact Developer\n|c00cc994.|r Custom Items\n|c00cc995.|r Remove Items",
	}
	OD[#OD + 1] = {
			type = "description",
			width = "half",
			text = "|c1dacd6Slash Commands|r\n|c00cc99/uhsreset|r - Reset Values\n|c00cc99/uhsoptions|r - Settings\n|c00cc99/uhsdisableall|r - Turn Off All Items",
	}
	OD[#OD + 1] = {
            type = "button",
            name = "Close Settings",
			width = "full",
            func = function()
                SCENE_MANAGER:ShowBaseScene()
            end,
    }

	-- Harvest Goals Section
	OD[#OD + 1] = {
		type = "header",
		name = "|c1dacd6Harvest Goals|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Set a harvest goal for any active item. The goal will be set as a negative gain value. Newly Activated Items will require a UI Reload.",
	}
	-- Build static choices table for active items
	local activeItemNames = {}
	for k, v in pairs(UHS_Data.Active) do
		table.insert(activeItemNames, v[ITEM_NAME])
	end
	table.sort(activeItemNames)
	OD[#OD + 1] = {
		type = "dropdown",
		name = "Select Item",
		choices = activeItemNames,
		getFunc = function() return UHS_Settings.GoalSelectedItem or "" end,
		setFunc = function(val) UHS_Settings.GoalSelectedItem = val end,
		width = "half",
	}
	-- Numeric-only edit box
	OD[#OD + 1] = {
		type = "editbox",
		name = "Goal Amount",
		getFunc = function() return UHS_Settings.GoalAmount or "" end,
		setFunc = function(val)
			local num = tonumber(val)
			if num and num >= 0 and tostring(num) == val then
				UHS_Settings.GoalAmount = val
			else
				UHS_Settings.GoalAmount = nil
			end
		end,
		isMultiline = false,
		isExtraWide = false,
		width = "half",
		tooltip = "Enter a whole number (no decimals)",
	}
	-- Set button
	OD[#OD + 1] = {
		type = "button",
		name = "Set Goal",
		width = "half",
		func = function()
			local itemName = UHS_Settings.GoalSelectedItem
			local amount = tonumber(UHS_Settings.GoalAmount)
			if amount then
				amount = math.abs(amount)
				amount = math.ceil(amount)
			end
			if itemName and amount and amount >= 0 then
				for k, v in pairs(UHS_Data.Saved.Items) do
					if v[ITEM_NAME] == itemName then
						v[ITEM_GAIN] = -amount
						UnDeadHarvest.RefreshLabels()
						d("Harvest goal set for " .. itemName .. ": " .. amount)
						break
					end
				end
			else
				d("Please select an item and enter a valid number.")
			end
		end,
	}
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Raw Materials|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_RAW then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Enchanting Items|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_ENCHANTING then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Alchemy Items|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_ALCHEMY then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Currency Items|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_CURRENCY then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Fishing Items|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_BAIT then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c536878Misc Items|r",
	}
	for k,v in pairs(UHS_Data.Saved.Items) do
		if UHS_Data.Saved.Items[k][ITEM_CATEGORY] == CATEGORY_MISC then
			OD[#OD + 1] = {
				type = "checkbox",
				name = UHS_Data.Saved.Items[k][ITEM_NAME],
				default = false,
				width = "half",
				disabled = false,
				requiresReload = false,
				getFunc = function() return UHS_Data.Saved.Items[k][ITEM_ACTIVE] end,
				setFunc = function(value)
					UHS_Data.Saved.Items[k][ITEM_ACTIVE] = value
					UnDeadHarvest.CreateUI()
					UnDeadHarvest.RefreshLabels()
				end
			}
		end
	end
	OD[#OD + 1] = {
		type = "header",
		name = "|c00cc99Contact Mod Developer|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Feel free to contact me with any bugs, comments, or anything else.",
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Send Friend Request",
		width = "full",
		func = function()
			RequestFriend("@UnDead0rbit", "UnDead Harvest Mod Request")
		end,
	}
	OD[#OD + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}
	OD[#OD + 1] = {
		type = "dropdown",
		name = "|ce4717aSelect Mail Topic|r",
		choices = {"Bug Report","Comment","Give Idea","Other Reason"},
		choicesValues = {"Re: I Have a Bug in UnDead Utilities Mod","Re: Comment on UnDead Utilities Mod","Re: I have an idea for UnDead Utilities Mod","Re: I have something to tell you."}, -- if specified, these values will get passed to setFunc instead (optional)
		sort = "name-up",
		scrollable = true,
		default = "Bug Report",
		width = "full",
		requiresReload = false,
		getFunc = function() return UnDeadHarvest.MailTopic end,
		setFunc = function(value) UnDeadHarvest.MailTopic = value end
	}
	OD[#OD + 1] = {
		type = "editbox",
		name = "|ce4717aType Message To Send|r",
		sort = "name-up",
		isMultiline = true,
		isExtraWide = true,
		width = "full",
		requiresReload = false,
		getFunc = function() return nil end,
		setFunc = function(value) UnDeadHarvest.MailBody = value end
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Send Mail",
		width = "full",
		func = function()
			SCENE_MANAGER:ShowBaseScene()
			RequestOpenMailbox()
			SendMail("@UnDead0rbit", UnDeadHarvest.MailTopic, UnDeadHarvest.MailBody)
			d("Mail Sent to @UnDead0rbit")
		end,
	}
	OD[#OD + 1] = {
		type = "header",
		name = "|c1dacd6Add Custom Items|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Add your own desired items for tracking with Harvest Summary.  These items will save and remain in your options.",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "|c00cc99Step 1:|r Turn On the ID Log.",
	}
	OD[#OD + 1] = {
			type = "checkbox",
			name = "|ca3c1adItem ID Log|r",
			tooltip = "Gives the Item ID of harvested items in chat... mostly for developer use.",
			default = false,
			width = "half",
			requiresReload = false,
			getFunc = function() return UHS_Data.Saved.IDLog end,
			setFunc = function(value) UHS_Data.Saved.IDLog = value end
	}
	OD[#OD + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}
	OD[#OD + 1] = {
		type = "description",
		text = "|c00cc99Step 2:|r Collect your item and write down the Item ID from the chat log.\n\nIf there is no item name appearing and/or the number is only two digits or less, then the item may not work for this.",
	}
	OD[#OD + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}
	OD[#OD + 1] = {
		type = "description",
		text = "|c00cc99Step 3:|r Fill out this form with the Item ID you collected.",
	}
	OD[#OD + 1] = {
		type = "dropdown",
		name = "|c89cff0Pick a Category|r",
		choices = {"Alchemy","Fishing","Currency","Enchanting","Misc","Raw Material"},
		choicesValues = {CATEGORY_ALCHEMY, CATEGORY_BAIT, CATEGORY_CURRENCY, CATEGORY_ENCHANTING, CATEGORY_MISC, CATEGORY_RAW}, -- if specified, these values will get passed to setFunc instead (optional)
		sort = "name-up",
		scrollable = true,
		width = "full",
		requiresReload = false,
		getFunc = function() return UnDeadHarvest.ChosenCategory end,
		setFunc = function(value) UnDeadHarvest.ChosenCategory = value end
	}
	OD[#OD + 1] = {
		type = "editbox",
		name = "|c89cff0Item Name|r",
		sort = "name-up",
		isMultiline = false,
		isExtraWide = false,
		width = "full",
		requiresReload = false,
		getFunc = function() return UnDeadHarvest.ChosenName end,
		setFunc = function(value) UnDeadHarvest.ChosenName = value end
	}
	OD[#OD + 1] = {
		type = "description",
		text = "*Any name you desire, but no symbols, yet spaces are allowed.",
	}
	OD[#OD + 1] = {
		type = "dropdown",
		name = "|c89cff0Pick a Color|r",
		choices = {"|cffffffWhite|r", "|c00ced1Turquoise|r", "|ccc4e5cTerra Cotta|r", "|c9400d3Violet|r", "|cc154c1Fuchsia|r", "|c00bfffSky Blue|r", "|cd71868Rose|r", "|c50c878Emerald|r", "|c71bc78Fern|r", "|cf7e98eFlavescent|r", "|c86608eLilac|r", "|cffa500Orange|r"},
		choicesValues = {"ffffff", "00ced1", "cc4e5c", "9400d3", "c154c1", "00bfff", "d71868", "50c878", "71bc78", "f7e98e", "86608e", "ffa500"}, -- if specified, these values will get passed to setFunc instead (optional)
		scrollable = true,
		width = "full",
		requiresReload = false,
		getFunc = function() return UnDeadHarvest.ChosenColor end,
		setFunc = function(value) UnDeadHarvest.ChosenColor = value end
	}
	OD[#OD + 1] = {
		type = "description",
		text = "*This will be the color wherever the name appears.",
	}
	OD[#OD + 1] = {
		type = "editbox",
		name = "|c89cff0Item ID|r",
		sort = "name-up",
		isMultiline = false,
		isExtraWide = false,
		width = "full",
		requiresReload = false,
		getFunc = function() return UnDeadHarvest.ChosenItemId end,
		setFunc = function(value) UnDeadHarvest.ChosenItemId = value end
	}
	OD[#OD + 1] = {
		type = "description",
		text = "*Item ID must be accurate to work.",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "|cff2052Double Check That All Inputs Are Correct Before Adding Item!|r \n\n This will Reload your UI to apply the changes.",
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Add Item",
		width = "full",
		func = function()
			if UnDeadHarvest.ChosenColor == nil then UnDeadHarvest.ChosenColor = "ffffff" end
			local formattedChosenName = "|c" .. UnDeadHarvest.ChosenColor .. UnDeadHarvest.ChosenName .. "|r"

			if UnDeadHarvest.ChosenName ~= nil and UnDeadHarvest.ChosenItemId ~= nil and UnDeadHarvest.ChosenCategory ~= nil then
				if UHS_Data.Saved.Items[UnDeadHarvest.ChosenName] == nil then
					local itemIdNum = tonumber(UnDeadHarvest.ChosenItemId)
					UHS_Data.Saved.Items[UnDeadHarvest.ChosenName] = {formattedChosenName, itemIdNum, 0, UnDeadHarvest.ChosenCategory, true}
					ReloadUI()
				end
			end
		end,
	}
	OD[#OD + 1] = {
		type = "divider",
		width = "full", -- or "half" (optional)
		height = 8, -- (optional)
		alpha = 0.25, -- (optional)
	}

	-- Remove Item Section
	OD[#OD + 1] = {
		type = "header",
		name = "|cff2052Remove Item|r",
	}
	OD[#OD + 1] = {
		type = "description",
		text = "Select any item (active or inactive) to remove it from your list. This will reload your UI.",
	}
	-- Build static choices table for all items
	local allItemNames = {}
	for k, v in pairs(UHS_Data.Saved.Items) do
		table.insert(allItemNames, v[ITEM_NAME])
	end
	table.sort(allItemNames)
	OD[#OD + 1] = {
		type = "dropdown",
		name = "Select Item to Remove",
		choices = allItemNames,
		getFunc = function() return UHS_Settings.RemoveSelectedItem or "" end,
		setFunc = function(val) UHS_Settings.RemoveSelectedItem = val end,
		width = "half",
	}
	OD[#OD + 1] = {
		type = "button",
		name = "Remove Item",
		width = "half",
		func = function()
			local itemName = UHS_Settings.RemoveSelectedItem
			if itemName and itemName ~= "" then
				for k, v in pairs(UHS_Data.Saved.Items) do
					if v[ITEM_NAME] == itemName then
						UHS_Data.Saved.Items[k] = nil
						ReloadUI()
						return
					end
				end
			else
				d("Please select an item to remove.")
			end
		end,
	}

	LAM:RegisterOptionControls(panelName, OD)

end




