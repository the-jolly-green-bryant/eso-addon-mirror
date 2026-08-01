jb = jb or {}
local utils = jb.utils

jb.name          = "JunkBuster"
jb.fancyName     = "|c777777Junk|cffffffBuster|r"
jb.chatTag       = jb.fancyName .. ": "
jb.author        = "@ADH + @Atoom"
jb.version       = "1.92"
jb.saveVersion   = 2
jb.saveTabName   = "VarsV01"
jb.color         = {}
jb.color.ruleNr  = "|c66FF66"
jb.color.keep    = "|c00FF00"
jb.color.destroy = "|cFF0000"
jb.color.junk    = "|c777777"

jb.defaults = {
    showBank               = true,
    showSave               = true,
    showDestroy            = true,
    showJunk               = true,
    showLoot               = false,
    debugPrint             = false,
    doBank                 = true,
    doSave                 = true,
    doDestroy              = false,
    doJunk                 = true,
    sellAllJunk            = true,
	rulesInitialized       = false,
	autoSellJunk           = false,
	showSellSummary        = true,
	showDetailedSummary    = false,
	useAccountWideSettings = false,
	maxAutoSales           = 69
}

jb.defNewRule = {action="Keep and Unjunk", namePattern = "", minLevel = -1, maxLevel = -1,
			  quality = -1, itemType = -1, specType = -1, equipType = -1, minPrice = -1, maxPrice = -1, 
			  craft = -1, trait = -1, isCrafted = -1, isStolen = -1, hasSet = -1, 
			  minReqLevel = -1, maxReqLevel = -1, minReqCP = -1, maxReqCP = -1,
			  weaponType = -1, armorType = -1, actorType = -1, isKnown = -1}

jb.defRules = {
    saveRules = {
        {itemType = ITEMTYPE_TOOL},
        {quality = ITEM_FUNCTIONAL_QUALITY_LEGENDARY},
        {quality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT},
        {quality = ITEM_FUNCTIONAL_QUALITY_ARCANE}
    },
    destroyRules = {
        {itemType = ITEMTYPE_TRASH, maxPrice = 0}
    },
    junkRules = {
        {itemType = ITEMTYPE_TRASH}
    },
}
	

function jb.initialize(eventCode, addOnName)
    if (addOnName ~= jb.name) then return end

	utils.addNewApiConstants()
	utils.specTypeNames.initAllArray()

	-- Get this characters saved variables:
	jb.vars = ZO_SavedVars:NewCharacterIdSettings(jb.name, jb.saveVersion, jb.saveTabName, jb.defaults) 
	-- If this character has account wide settings turned on, load those instead:
	local isAccWide = false
	if jb.vars.useAccountWideSettings then 
		isAccWide = true
		jb.vars = ZO_SavedVars:NewAccountWide(jb.name, jb.saveVersion, jb.saveTabName, jb.defaults)
	end
	
	if not jb.vars.rulesInitialized then
		-- Seems like this settings profile (char- or acc-wide) is empty. Let's do something about that:
		local baseVars
		local usingLegacyVars = false
		if isAccWide then
			-- It's the acc wide profile, so copy current characters settings:
			baseVars = utils.deepcopy(JunkBuster.Default[GetDisplayName()][GetCurrentCharacterId()][jb.saveTabName])
			d(jb.chatTag .. "No accountwide settings found. Initialized with current characters settings")
		else
			-- no, seems it's a character profile. So first try to get some sweet legacy settings to import and copy them:
			baseVars = utils.deepcopy(JunkBuster.Default[GetDisplayName()][GetUnitName("player")])
			-- Check if we got something oldschool for importing:
			if baseVars ~= nil and baseVars.rulesInitialized then
				-- We got some old settings there!:
				usingLegacyVars = true
				d(jb.chatTag .. "Old saved settings (< V1.70) for this character found and converted")
				-- Also delete the old settings to avoid bloating the save file:
				JunkBuster.Default[GetDisplayName()][GetUnitName("player")] = nil
			else
				-- No legacy settings seem to be there :sad_face: Well, use default settings then...
				baseVars = utils.deepcopy(jb.defaults)
				baseVars.saveRules = utils.deepcopy(jb.defRules.saveRules)
				baseVars.destroyRules = utils.deepcopy(jb.defRules.destroyRules)
				baseVars.junkRules = utils.deepcopy(jb.defRules.junkRules)
				d(jb.chatTag .. "No saved settings for this character found. Initialized default settings")
			end
		end
		
		-- Copy settings that have always existed:
		jb.vars.showBank = baseVars.showBank
		jb.vars.showSave = baseVars.showSave
		jb.vars.showDestroy = baseVars.showDestroy
		jb.vars.showJunk = baseVars.showJunk
		jb.vars.showLoot = baseVars.showLoot
		jb.vars.debugPrint = baseVars.debugPrint
		jb.vars.doBank = baseVars.doBank
		jb.vars.doSave = baseVars.doSave
		jb.vars.doDestroy = baseVars.doDestroy
		jb.vars.doJunk = baseVars.doJunk
		jb.vars.sellAllJunk = baseVars.sellAllJunk
		jb.vars.autoSellJunk = baseVars.autoSellJunk
		jb.vars.showSellSummary = baseVars.showSellSummary
		jb.vars.showDetailedSummary = baseVars.showDetailedSummary
		jb.vars.saveRules = baseVars.saveRules
		jb.vars.destroyRules = baseVars.destroyRules
		jb.vars.junkRules = baseVars.junkRules
		-- And copy brand new, non-legacy settings:
		if not usingLegacyVars then
			if baseVars.ruleOrder ~= nil then
				jb.vars.ruleOrder = baseVars.ruleOrder
			end
		end
		baseVars = nil
		jb.vars.rulesInitialized = true
	end
	
	if jb.vars.ruleOrder == nil then
		jb.vars.ruleOrder = {}
		for k, v in ipairs(jb.vars.saveRules) do
			local rRef = {}
			rRef.Type = JB_RTYPE_SAVE
			rRef.Idx = k
			table.insert(jb.vars.ruleOrder, rRef)
		end
		for k, v in ipairs(jb.vars.destroyRules) do
			local rRef = {}
			rRef.Type = JB_RTYPE_DESTROY
			rRef.Idx = k
			table.insert(jb.vars.ruleOrder, rRef)
		end
		for k, v in ipairs(jb.vars.junkRules) do
			local rRef = {}
			rRef.Type = JB_RTYPE_JUNK
			rRef.Idx = k
			table.insert(jb.vars.ruleOrder, rRef)
		end
	end

    jb.settingsPanel()

    EVENT_MANAGER:RegisterForEvent(jb.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, jb.inventoryUpdate)
	EVENT_MANAGER:RegisterForEvent(jb.name, EVENT_OPEN_STORE, jb.openMerchant)
	EVENT_MANAGER:RegisterForEvent(jb.name, EVENT_OPEN_FENCE, jb.openFence)
	
	SLASH_COMMANDS["/jbil"] = jb.printItemInfo
end

EVENT_MANAGER:RegisterForEvent(jb.name, EVENT_ADD_ON_LOADED, jb.initialize)
