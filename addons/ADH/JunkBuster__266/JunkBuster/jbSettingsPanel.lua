jb = jb or {}
local utils = jb.utils

function jb.settingsPanel()
	local LAM2 = LibAddonMenu2
	local panelRef = "jb_SettingsPanel"
	
	local panelData = {
		type = "panel",
		name = jb.name,
		displayName = jb.fancyName,
		author = jb.author,
		version = jb.version,
		slashCommand = "/jb",
		registerForRefresh = true,
		registerForDefaults = false,
	}
	LAM2:RegisterAddonPanel(panelRef, panelData)
	
	local optionsData = {
		-------------------------------------------------------------------------------------------------
		{
			type = "header",
			name = jb.initRules,
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "Apply the first rule that matches the item:",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "description",
			text = jb.createRulesStr,
			title = "",
		},
		{
			type = "editbox",
			name = "Selected rule " .. jb.color.ruleNr .. "[#]",
			width = "half",
			tooltip = "",
			getFunc = function() return utils.numToStr(jb.editIdx) end,
			setFunc = function(value) jb.editIdx = utils.strToNum(value) end,
			isMultiline = false,
		},
		{
			type = "editbox",
			name = "Move target rule " .. jb.color.ruleNr .. "[#]",
			width = "half",
			tooltip = "",
			getFunc = function() return utils.numToStr(jb.moveIdx) end,
			setFunc = function(value) jb.moveIdx = utils.strToNum(value) end,
			isMultiline = false,
		},
		{
			type = "button",
			name = "Remove",
			width = "half",
			tooltip = "",
			func = jb.delRule,
		},
		{
			type = "button",
			name = "Move",
			width = "half",
			tooltip = "",
			func = jb.moveRule,
		},
		-------------------------------------------------------------------------------------------------
		{
			type = "submenu",
			name = "Add New Rule",
			controls = {
				{
					type = "description",
					text = "(Leave a field blank to disable that criterion)",
					title = "Apply the action to any item that has ALL of the following:",
				},
				{
					type = "button",
					name = "Add Rule",
		--			width = "half",
					tooltip = "",
					func = jb.addRule,
				},
				{
					type = "dropdown",
					name = "Action",
					width = "half",
					tooltip = "",
					choices = {"Keep and Unjunk", "Destroy", "Mark as Junk"},
					getFunc = function() return jb.newItem.action end,
					setFunc = function(value) jb.newItem.action = value end,
				},
				{
					type = "editbox",
					name = "Item name contains",
					width = "half",
					tooltip = "",
					getFunc = function() return jb.newItem.namePattern end,
					setFunc = function(value) jb.newItem.namePattern = value end,
					isMultiline = false,
				},
				{
					type = "dropdown",
					name = "Item type",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.typeNames),
					getFunc = function() return utils.typeNames[jb.newItem.itemType] end,
					setFunc = jb.itemTypesSet,
					sort = "name-up",
					scrollable = 20,
				},
				{
					type = "dropdown",
					name = "Specialized item type",
					width = "half",
					tooltip = "",
					warning = "Specialized type can only be selected if the item type has specialized sub types",
					choices = {""},
					getFunc = function() return utils.specTypeNames.all[jb.newItem.specType] end,
					setFunc = function(value) jb.newItem.specType = utils.findKey(utils.specTypeNames.setChoices, value) end,
					disabled = jb.isSpecTypeDisabled,
					sort = "name-up",
					reference = "SpecTypeDropdown",
				},
				{
					type = "dropdown",
					name = "Item quality",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.qualityNames),
					getFunc = function() return utils.qualityNames[jb.newItem.quality] end,
					setFunc = function(value) jb.newItem.quality = utils.findKey(utils.qualityNames, value) end,
				},
		--		{
		--			type = "dropdown",
		--			name = "Crafting type",
		--			tooltip = "",
		--			choices = jb.flattenTable(utils.craftNames),
		--			getFunc = function() return utils.craftNames[jb.newItem.craft] end,
		--			setFunc = function(value) jb.newItem.craft = utils.findKey(utils.craftNames, value) end,
		--		},
				{
					type = "dropdown",
					name = "Equipment slot",
					width = "half",
					tooltip = "",
					warning = "Equipment slot can be selected if the item type is Weapon or Armor",
					choices = jb.flattenTable(utils.equipTypeNames),
					getFunc = function() return utils.equipTypeNames[jb.newItem.equipType] end,
					setFunc = function(value) jb.newItem.equipType = utils.findKey(utils.equipTypeNames, value) end,
					disabled = jb.isEquipFilterDisabled,
					sort = "name-up",
				},
				{
					type = "dropdown",
					name = "Armor type",
					width = "half",
					tooltip = "",
					warning = "Armor type can be selected if the item type is Armor",
					choices = jb.flattenTable(utils.armorTypeNames),
					getFunc = function() return utils.armorTypeNames[jb.newItem.armorType] end,
					setFunc = function(value) jb.newItem.armorType = utils.findKey(utils.armorTypeNames, value) end,
					disabled = jb.isArmorFilterDisabled,
					sort = "name-up",
				},
				{
					type = "dropdown",
					name = "Weapon type",
					width = "half",
					tooltip = "",
					warning = "Weapon type can be selected if the item type is Weapon",
					choices = jb.flattenTable(utils.weaponTypeNames),
					getFunc = function() return utils.weaponTypeNames[jb.newItem.weaponType] end,
					setFunc = function(value) jb.newItem.weaponType = utils.findKey(utils.weaponTypeNames, value) end,
					disabled = jb.isWeaponFilterDisabled,
					sort = "name-up",
				},
				{
					type = "dropdown",
					name = "Item trait",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.traitNames),
					getFunc = function() return utils.traitNames[jb.newItem.trait] end,
					setFunc = function(value) jb.newItem.trait = utils.findKey(utils.traitNames, value) end,
					sort = "name-up",
					scrollable = 20,
				},
				{
					type = "dropdown",
					name = "Actor type",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.actorTypeNames),
					getFunc = function() return utils.actorTypeNames[jb.newItem.actorType] end,
					setFunc = function(value) jb.newItem.actorType = utils.findKey(utils.actorTypeNames, value) end,
					sort = "name-up",
				},
				{
					type = "dropdown",
					name = "Set bonus",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.setBonusFilter),
					getFunc = function() return utils.setBonusFilter[jb.newItem.hasSet] end,
					setFunc = function(value) jb.newItem.hasSet = utils.findKey(utils.setBonusFilter, value) end,
				},
				{
					type = "dropdown",
					name = "Crafted",
					width = "half",
					tooltip = "",
					warning = "Empty selection excludes crafted items from the rule",
					choices = jb.flattenTable(utils.craftFilter),
					getFunc = function() return utils.craftFilter[jb.newItem.isCrafted] end,
					setFunc = function(value) jb.newItem.isCrafted = utils.findKey(utils.craftFilter, value) end,
				},
				{
					type = "dropdown",
					name = "Stolen",
					width = "half",
					tooltip = "",
					choices = jb.flattenTable(utils.stolenFilter),
					getFunc = function() return utils.stolenFilter[jb.newItem.isStolen] end,
					setFunc = function(value) jb.newItem.isStolen = utils.findKey(utils.stolenFilter, value) end,
				},
				{
					type = "dropdown",
					name = "Recipe Known",
					width = "half",
					tooltip = "",
					warning = "Recipe Known can be selected if the item type is Recipe",
					choices = jb.flattenTable(utils.recKnownFilter),
					getFunc = function() return utils.recKnownFilter[jb.newItem.isKnown] end,
					setFunc = function(value) jb.newItem.isKnown = utils.findKey(utils.recKnownFilter, value) end,
					disabled = jb.isRecKnownFilterDisabled,
				},
				{
					type = "editbox",
					name = "Minimum required level",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.minReqLevel) end,
					setFunc = function(value) jb.newItem.minReqLevel = utils.strToNum(value) end,
					isMultiline = false,
					disabled = jb.isLvlFilterDisabled,
				},
				{
					type = "editbox",
					name = "Maximum required level",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.maxReqLevel) end,
					setFunc = function(value) jb.newItem.maxReqLevel = utils.strToNum(value) end,
					isMultiline = false,
					disabled = jb.isLvlFilterDisabled,
				},
				{
					type = "editbox",
					name = "Minimum required CP level",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.minReqCP) end,
					setFunc = function(value) jb.newItem.minReqCP = utils.strToNum(value) end,
					isMultiline = false,
					disabled = jb.isCpFilterDisabled,
				},
				{
					type = "editbox",
					name = "Maximum required CP level",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.maxReqCP) end,
					setFunc = function(value) jb.newItem.maxReqCP = utils.strToNum(value) end,
					isMultiline = false,
					disabled = jb.isCpFilterDisabled,
				},
				{
					type = "editbox",
					name = "Minimum price",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.minPrice) end,
					setFunc = function(value) jb.newItem.minPrice = utils.strToNum(value) end,
					isMultiline = false,
				},
				{
					type = "editbox",
					name = "Maximum price",
					width = "half",
					tooltip = "",
					getFunc = function() return utils.numToStr(jb.newItem.maxPrice) end,
					setFunc = function(value) jb.newItem.maxPrice = utils.strToNum(value) end,
					isMultiline = false,
				},
			}
		},
		-------------------------------------------------------------------------------------------------
		{
			type = "header",
			name = "Settings",
		},
		{
			type = "submenu",
			name = "Looting",
			controls = {
				{
					type = "checkbox",
					name = "Perform 'Keep and Unjunk'",
					width = "half",
					getFunc = function() return jb.vars.doSave end,
					setFunc = function(value) jb.vars.doSave = value end,
					tooltip = "Turns on or off all the rules marked for saving items",
				},
				{
					type = "checkbox",
					name = "Perform 'Destroy'",
					width = "half",
					getFunc = function() return jb.vars.doDestroy end,
					setFunc = function(value) jb.vars.doDestroy = value end,
					tooltip = "Turns on or off all the rules marked for destroying items",
				},
				{
					type = "checkbox",
					name = "Perform 'Mark as Junk'",
					width = "half",
					getFunc = function() return jb.vars.doJunk end,
					setFunc = function(value) jb.vars.doJunk = value end,
					tooltip = "Turns on or off all the rules marked for junking items",
				},
			}
		},
		-------------------------------------------------------------------------------------------------
		{
			type = "submenu",
			name = "Reporting",
			controls = {
				{
					type = "checkbox",
					name = "Show saved items in chat box",
					width = "half",
					getFunc = function() return jb.vars.showSave end,
					setFunc = function(value) jb.vars.showSave = value end,
					tooltip = "Adds a line in the chatbox for every item that is looted and is saved as NOT junk",
				},
				{
					type = "checkbox",
					name = "Show destroyed items in chat box",
					width = "half",
					getFunc = function() return jb.vars.showDestroy end,
					setFunc = function(value) jb.vars.showDestroy = value end,
					tooltip = "Adds a line in the chatbox for every item that is destroyed on loot",
				},
				{
					type = "checkbox",
					name = "Show junked items in chat box",
					width = "half",
					getFunc = function() return jb.vars.showJunk end,
					setFunc = function(value) jb.vars.showJunk = value end,
					tooltip = "Adds a line in the chatbox for every item that is looted and is detected under the junk rules",
				},
				{
					type = "checkbox",
					name = "Show looted items in chat box",
					width = "half",
					getFunc = function() return jb.vars.showLoot end,
					setFunc = function(value) jb.vars.showLoot = value end,
					tooltip = "Adds a line in the chatbox for every item that is looted and not detected by any rules",
				},
				{
					type = "checkbox",
					name = "Show detailed info about items",
					width = "half",
					getFunc = function() return jb.vars.debugPrint end,
					setFunc = function(value) jb.vars.debugPrint = value end,
					tooltip = "Shows detailed information about each printed item to help with creating rules",
				},
			}
		},
		-------------------------------------------------------------------------------------------------
		{
			type = "submenu",
			name = "Automatic junk sale",
			controls = {
				{
					type = "checkbox",
					name = "Auto sell junk",
					width = "half",
					getFunc = function() return jb.vars.autoSellJunk end,
					setFunc = function(value) jb.vars.autoSellJunk = value end,
					tooltip = "Automatically sells the content of your junk bag when opening a merchant or fence",
				},
				{
					type = "checkbox",
					name = "Show junk sale info",
					width = "half",
					getFunc = function() return jb.vars.showSellSummary end,
					setFunc = function(value) jb.vars.showSellSummary = value end,
					tooltip = "Show a summary of the sale when automatically selling junk in the chat window",
				},
				{
					type = "checkbox",
					name = "Detailed junk sale info",
					width = "half",
					getFunc = function() return jb.vars.showDetailedSummary end,
					setFunc = function(value) jb.vars.showDetailedSummary = value end,
					tooltip = "Show detailed information about all automatically sold junk",
				},
				{
					type = "editbox",
					name = "Max. junk sales",
					width = "half",
					tooltip = "Maximum amount of items simultaneously sold by the auto junk sell function. If you occasionally get kicked back to the login screen on selling junk you can try lowering this number",
					getFunc = function() return utils.numToStr(jb.vars.maxAutoSales) end,
					setFunc = function(value) jb.vars.maxAutoSales = utils.strToNum(value) end,
					isMultiline = false,
				},
			}
		},
		-------------------------------------------------------------------------------------------------
		{
			type = "submenu",
			name = "Account wide",
			controls = {
				{
					type = "checkbox",
					name = "Use account wide settings",
					tooltip = "Use account wide settings on this character, requires reload to take effect!",
					default = jb.defaults.useAccountWideSettings,
					getFunc = function() return JunkBuster.Default[GetDisplayName()][GetCurrentCharacterId()][jb.saveTabName]["useAccountWideSettings"] end,
					setFunc = function(value) JunkBuster.Default[GetDisplayName()][GetCurrentCharacterId()][jb.saveTabName]["useAccountWideSettings"] = value end,
					requiresReload = true,
				},	
			}
		},
		-------------------------------------------------------------------------------------------------
	}
	jb.rulesDrawOffs = 1
	LAM2:RegisterOptionControls(panelRef, optionsData)
	
	jb.editIdx = ""
	jb.moveIdx = ""
    jb.newItem = jb.defNewRule
end

function jb.itemTypesSet(value)
	local newType = utils.findKey(utils.typeNames, value)
	local choices = {""}
	if newType ~= jb.newItem.itemType then
		jb.newItem.specType = -1
	end
	if newType >= 0 and utils.specTypeNames.byItemType[newType] ~= nil then
		utils.specTypeNames.setChoices = utils.specTypeNames.byItemType[newType]
		choices = jb.flattenTable(utils.specTypeNames.setChoices)
	end
	jb.newItem.itemType = newType
	SpecTypeDropdown:UpdateChoices(choices)
end

function jb.isSpecTypeDisabled()
	if utils.specTypeNames.byItemType[jb.newItem.itemType] == nil then
		jb.newItem.specType = -1
		return true
	else
		return false
	end
end

function jb.isEquipFilterDisabled()
	if jb.newItem.itemType == ITEMTYPE_ARMOR or jb.newItem.itemType == ITEMTYPE_WEAPON then
		return false
	else
		jb.newItem.equipType = -1
		return true
	end
end

function jb.isArmorFilterDisabled()
	if jb.newItem.itemType == ITEMTYPE_ARMOR then
		return false
	else
		jb.newItem.armorType = -1
		return true
	end
end

function jb.isWeaponFilterDisabled()
	if jb.newItem.itemType == ITEMTYPE_WEAPON then
		return false
	else
		jb.newItem.weaponType = -1
		return true
	end
end

function jb.isRecKnownFilterDisabled()
	if jb.newItem.itemType == ITEMTYPE_RECIPE then
		return false
	else
		jb.newItem.isKnown = -1
		return true
	end
end

function jb.isLvlFilterDisabled()
	if jb.newItem.minReqCP == -1 and jb.newItem.maxReqCP == -1 then
		return false
	else
		jb.newItem.minReqLevel = -1
		jb.newItem.maxReqLevel = -1
		return true
	end
end

function jb.isCpFilterDisabled()
	if jb.newItem.minReqLevel == -1 and jb.newItem.maxReqLevel == -1 then
		return false
	else
		jb.newItem.minReqCP = -1
		jb.newItem.maxReqCP = -1
		return true
	end
end

function jb.initRules()
	jb.rulesDrawOffs = 1
	return "Rules"
end

function jb.createRulesStr()
	local ctrlStr = ""
	local looplen = #jb.vars.ruleOrder
	local newOffset

	if jb.rulesDrawOffs > looplen then
		return ctrlStr
	end
	for cnt = jb.rulesDrawOffs, looplen do
		local str = jb.color.ruleNr .. "[" .. cnt .. "] "
		local rRef = jb.vars.ruleOrder[cnt]
		if rRef.Type == JB_RTYPE_SAVE then
			str = str .. jb.color.keep .. "Keep " .. jb.getRuleString(jb.vars.saveRules[rRef.Idx])
		elseif rRef.Type == JB_RTYPE_DESTROY then
			str = str .. jb.color.destroy .. "Destroy " .. jb.getRuleString(jb.vars.destroyRules[rRef.Idx])
		else
			str = str .. jb.color.junk .. "Junk " .. jb.getRuleString(jb.vars.junkRules[rRef.Idx])
		end

		if string.len(ctrlStr) + string.len(str) < 2000 then
			if string.len(ctrlStr) ~= 0 then
				ctrlStr = ctrlStr .. "\n"
			end
			ctrlStr = ctrlStr .. str
			newOffset = cnt + 1
		else
			newOffset = cnt
			break
		end
	end
	jb.rulesDrawOffs = newOffset
	return ctrlStr
end

function jb.delRule()
	local delItem = tonumber(jb.editIdx) or -1 
	
	if delItem <= #jb.vars.ruleOrder and delItem > 0 then
		local rRef = jb.vars.ruleOrder[delItem]
		if rRef.Type == JB_RTYPE_SAVE then
			table.remove(jb.vars.saveRules, rRef.Idx)
		elseif rRef.Type == JB_RTYPE_DESTROY then
			table.remove(jb.vars.destroyRules, rRef.Idx)
		else
			table.remove(jb.vars.junkRules, rRef.Idx)
		end
		table.remove(jb.vars.ruleOrder, delItem)
		
		for k,v in ipairs(jb.vars.ruleOrder) do
			if v.Type == rRef.Type and v.Idx > rRef.Idx then
				v.Idx = v.Idx - 1
			end
		end
	end
	jb.editIdx = ""
	jb.moveIdx = ""
end

function jb.moveRule()
	local srcIdx = tonumber(jb.editIdx) or -1 
	local dstIdx = tonumber(jb.moveIdx) or -1 
	if srcIdx ~= dstIdx and srcIdx <= #jb.vars.ruleOrder and srcIdx > 0 and dstIdx <= #jb.vars.ruleOrder and dstIdx > 0 then
		table.insert(jb.vars.ruleOrder, dstIdx, jb.vars.ruleOrder[srcIdx])
		if dstIdx < srcIdx then
			table.remove(jb.vars.ruleOrder, srcIdx + 1)
		else
			table.remove(jb.vars.ruleOrder, srcIdx)
		end
	end
	jb.editIdx = ""
	jb.moveIdx = ""
end

function jb.addRule()
	local copy = {}
	for k,v in pairs(jb.newItem) do
		if (k == "action" or k == "namePattern" or v >= 0) and (v ~= "") then
			copy[k] = v
		end
	end

	if copy.action == "Keep and Unjunk" then
		table.insert(jb.vars.saveRules, copy)
		local rRef = {}
		rRef.Type = JB_RTYPE_SAVE
		rRef.Idx = #jb.vars.saveRules
		table.insert(jb.vars.ruleOrder, 1, rRef)
	elseif copy.action == "Destroy" then
		table.insert(jb.vars.destroyRules, copy)
		local rRef = {}
		rRef.Type = JB_RTYPE_DESTROY
		rRef.Idx = #jb.vars.destroyRules
		table.insert(jb.vars.ruleOrder, rRef)
	elseif copy.action == "Mark as Junk" then
		table.insert(jb.vars.junkRules, copy)
		local rRef = {}
		rRef.Type = JB_RTYPE_JUNK
		rRef.Idx = #jb.vars.junkRules
		table.insert(jb.vars.ruleOrder, rRef)
    end
end

function jb.getRuleString(rule)
	local sc = "|cBBBBFF"
	local nc = "|r"

	local str = nc .. "any "
	if rule.quality then
		local qcolor
		if rule.quality == ITEM_FUNCTIONAL_QUALITY_NORMAL then
			qcolor = sc
		else
			qcolor = utils.qualityColors[rule.quality]
		end
		str = str .. qcolor .. utils.qualityNames[rule.quality] .. nc .. " quality "
	end
	if rule.itemType then
		str = str .. sc 
		if rule.weaponType then
			str = str .. utils.weaponTypeNames[rule.weaponType]
		elseif rule.armorType then
			str = str .. utils.armorTypeNames[rule.armorType]
		else
			str = str .. utils.typeNames[rule.itemType]
			if rule.specType then
				str = str .. nc .. "/" .. sc .. utils.specTypeNames.all[rule.specType]
			end
		end
		if rule.equipType and (rule.itemType == ITEMTYPE_ARMOR or rule.itemType == ITEMTYPE_WEAPON) then
			str = str .. " (" .. utils.equipTypeNames[rule.equipType] .. ")"
		end
		str = str .. nc
	else
		str = str .. "item"
	end

	if rule.namePattern then
		str = str .. " that has '" .. sc .. rule.namePattern .. nc .. "' in its name"
	end
	if rule.craft then
		str = str .. " for " .. sc .. utils.craftNames[rule.craft] .. nc
	end
	if rule.trait then
		if rule.trait == ITEM_TRAIT_TYPE_NONE then
			str = str .. " with " .. sc .. utils.traitNames[rule.trait] .. nc
		else
			str = str .. " with trait " .. sc .. utils.traitNames[rule.trait] .. nc
		end
	end

	if rule.maxPrice then
		if rule.minPrice and (rule.minPrice <= rule.maxPrice) then
			if rule.maxPrice == rule.minPrice then
				str = str .. " with a price of " .. sc .. rule.maxPrice .. nc .. "g"
			else
				str = str .. " with a price between " .. sc .. rule.minPrice .. nc .. "g and " .. sc .. rule.maxPrice .. nc .. "g"
			end
		else
			str = str .. " with a max. price of " .. sc .. rule.maxPrice .. nc .. "g"
		end
	else
		if rule.minPrice then
			str = str .. " with a min. price of " .. sc .. rule.minPrice .. nc .. "g"
		end
	end

	if rule.maxLevel then
		if rule.minLevel and (rule.minLevel <= rule.maxLevel) then
			if rule.maxLevel == rule.minLevel then
				str = str .. " with item level " .. sc .. rule.maxLevel .. nc
			else
				str = str .. " with item level between " .. sc .. rule.minLevel .. nc .. " and " .. sc .. rule.maxLevel .. nc
			end
		else
			str = str .. " with max. item level " .. sc .. rule.maxLevel .. nc
		end
	else
		if rule.minLevel then
			str = str .. " with min. item level " .. sc .. rule.minLevel .. nc
		end
	end

	if rule.maxReqLevel then
		if rule.minReqLevel and (rule.minReqLevel <= rule.maxReqLevel) then
			if rule.maxReqLevel == rule.minReqLevel then
				str = str .. " with a level of " .. sc .. rule.maxReqLevel .. nc
			else
				str = str .. " with a level between " .. sc .. rule.minReqLevel .. nc .. " and " .. sc .. rule.maxReqLevel .. nc
			end
		else
			str = str .. " with a max. level of " .. sc .. rule.maxReqLevel .. nc
		end
	else
		if rule.minReqLevel then
			str = str .. " with a min. level of " .. sc .. rule.minReqLevel .. nc
		end
	end
	if rule.maxReqCP then
		if rule.minReqCP and (rule.minReqCP <= rule.maxReqCP) then
			if rule.maxReqCP == rule.minReqCP then
				str = str .. " with a CP level of " .. sc .. rule.maxReqCP .. nc
			else
				str = str .. " with a CP level between " .. sc .. rule.minReqCP .. nc .. " and " .. sc .. rule.maxReqCP .. nc
			end
		else
			str = str .. " with a max. CP level of " .. sc .. rule.maxReqCP .. nc
		end
	else
		if rule.minReqCP then
			str = str .. " with a min. CP level of " .. sc .. rule.minReqCP .. nc
		end
	end
	
	if rule.isCrafted then
		str = str .. " that " .. sc .. utils.craftFilter[rule.isCrafted] .. nc
	end
	
	if rule.isStolen then
		str = str .. " that " .. sc .. utils.stolenFilter[rule.isStolen] .. nc
	end
	
	if rule.hasSet then
		str = str .. " that " .. sc .. utils.setBonusFilter[rule.hasSet] .. nc
	end
	
	if rule.isKnown then
		str = str .. " that " .. sc .. utils.recKnownFilter[rule.isKnown] .. nc
	end
	
	if rule.actorType then
		str = str .. " for " .. sc .. utils.actorTypeNames[rule.actorType] .. nc
	end
	
	return str
end

function jb.flattenTable(t)
	local arr = {}
	table.insert(arr, " ")
	for k,v in pairs(t) do
		if v ~= nil and v ~= "" and (not jb.hiddenOptions[v]) then
			table.insert(arr, v)
		end
	end

	return arr
end

jb.hiddenOptions = {
	["Additive"] = true,
	["Armor Booster"] = true,
	["Costume"] = true,
	["Deprecated"] = true,
	["Deprecated_2"] = true,
	["Enchantment Booster"] = true,
	["Flavoring"] = true,
	["Invalid"] = true,
	["Jewelry Raw Plating"] = true,
	["Lockpick"] = true,
	["Main Hand"] = true,
	["Mount"] = true,
	["None"] = true,
	["Plug"] = true,
	["Poison (Slot)"] = true,
	["Rune"] = true,
	["Spice"] = true,
	["Weapon Booster"] = true,
}
