-- BASIC ADDON LOAD TEST

local DovahMova = {}
DovahMova.Flags = { "en", "ua"}
DovahMova.Version = "v1.4.0"
DovahMova.API = 101046
DovahMova.Name = "DovahMova"
DovahMova.DropdownParameters = {
	["ua"] = "Українська",
	["uaen"] = "Українська+Англійська",
	["en"] = "Англійська",
}
DovahMova.StringsBackup = {
	["SI_ABILITY_NAME_AND_RANK"] = GetString(SI_ABILITY_NAME_AND_RANK),
	["SI_ABILITY_TOOLTIP_NAME"] = GetString(SI_ABILITY_TOOLTIP_NAME),
	["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"] = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED),
	["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"] = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER),
	["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"] = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER),
	["SI_ITEM_FORMAT_STR_SET_NAME"] = GetString(SI_ITEM_FORMAT_STR_SET_NAME),
	["SI_TOOLTIP_ITEM_NAME"] = GetString(SI_TOOLTIP_ITEM_NAME),
	["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"] = GetString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT),
}

DovahMova.Defaults = {
	-- Misc
	ShowCraft = "uaen",
	-- Abilities
	ShowAbilitiesMenu = "ua",
	ShowAbilitiesTooltip = "uaen",
	-- Champion
	ShowChampionTooltip = "uaen",
	-- Items
	ShowItemsNamesTooltip = "uaen",
	ShowItemsEnchantsTooltip = "uaen",
	ShowItemsTraitsTooltip = "uaen",
	ShowItemsSetsTooltip = "uaen",
	ShowItemsDisplay = "uaen",
	ShowGuildStoreDisplay = "uaen",
	IsUpdateNeeded = true,
	-- Collections
	ShowCollectionsSetsMenu = "uaen",
	EnglishSearch = true,
	-- Locations
	ShowLocations = "uaen",
	-- Scribing
	ShowScribing = "uaen",
	--ShowTributeCards = "ua",
	-- Mail Handler
	AutoCollectHirelingMail = true,
	AutoDeleteHirelingMail = true,
	Data = {
		ApiVersion = 0,
		AddonVersion = "",
		Abilities = {},
		Items = {},
		Sets = {},
		SetsNames = {},
		Traits = {},
		Potions = {},
		Locations = {},
		CraftAbilities = {},
		ScribingScripts = {},
		Parts = {},
		Prefixes = {},
		Affixes = {},
		EnchantPrefixes = {},
		--TributeCards = {},
	}
}
DovahMova.DefaultsCharacter = {
	IsFirstLaunch = true
}
DovahMova.Settings = DovahMova.Defaults
DovahMova.SettingsCharacter = DovahMova.DefaultsCharacter



function DovahMova:GetLanguage()
	local lang = GetCVar("language.2")
	
	if lang == "ua" or lang == "de" or lang == "fr" or lang == "es" then return lang end
	return "en"
end

function DovahMova:StartupMessage()
	if self.Settings.IsUpdateNeeded and self:IsDBOld() then
		self:ShowMsgBox("Потрібно оновити мовну базу", "\n\n\n\nГра розпочне змінювати мови (текст на екрані переключатиметься з української на англійську). Це звичайний процес. Не закривай гру. Тривалість може становити від кількох секунд до 10 хвилин, залежно від продуктивності твого комп'ютера.", 1)
	end
	
	
	self:Check()
	
	EVENT_MANAGER:UnregisterForEvent("DovahMova_StartupMessage", EVENT_PLAYER_ACTIVATED)
end

function DovahMova:MapNameStyle()		
	if self.Settings.ShowLocations == "uaen" then
		ZO_WorldMapCornerTitle:SetFont("ZoFontWinH3")
	else
		ZO_WorldMapCornerTitle:SetFont("ZoFontWinH1")
	end
	
	local scrollData = ZO_ScrollList_GetDataList(ZO_WorldMapLocationsList)
    ZO_ClearNumericallyIndexedTable(scrollData)
	WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
	WORLD_MAP_LOCATIONS:BuildLocationList()
end

function DovahMova:OnInit(eventCode, addOnName)
	if zo_strlower(addOnName) ~= zo_strlower(self.Name) then
		return
	end

	EVENT_MANAGER:UnregisterForEvent("DovahMova_OnAddOnLoaded", EVENT_ADD_ON_LOADED)
	
	self.Settings = ZO_SavedVars:NewAccountWide("DovahMovaVariables", 1, nil, self.Defaults)
	self.SettingsCharacter = ZO_SavedVars:New("DovahMovaVariables", 1, nil, self.DefaultsCharacter)
	
	if self.SettingsCharacter.IsFirstLaunch == true then
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS, "true")
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_VIDEOS, "true")
		self.SettingsCharacter.IsFirstLaunch = false
	end
	
	for _, flagCode in pairs(self.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end
	
	self.LAM = DOVAHMOVA_SETTINGS:New(self)
	
	ZO_CreateStringId("SI_BINDING_NAME_DOVAHMOVA_EN", "English")
	ZO_CreateStringId("SI_BINDING_NAME_DOVAHMOVA_UA", "Українська")
	
	-- Initialize adjectives processing early, before DovahMova_init
	if self:GetLanguage() == "ua" then
		self:InitializeAdjectivesProcessing()
		DovahMova_init()
	end
	
	-- Initialize mail handler module
	self:InitializeMailHandler()
	
	-- Initialize AsylumTracker integration
	self:InitializeAsylumTrackerIntegration()
	
	-- Initialize QuestMap integration
	self:InitializeQuestMapIntegration()
	
	-- Initialize PotionMaker integration
	self:InitializePotionMakerIntegration()
	
	-- Initialize AsquartOsseinCageHelper integration
	self:InitializeAsquartOsseinCageHelperIntegration()

end

function DovahMova:IsDBOld()
	local rsv = self.Settings.Data
	if not rsv.ApiVersion or not rsv.AddonVersion or (rsv.ApiVersion ~= GetAPIVersion()) or (rsv.AddonVersion ~= self.Version) then
		return true
	else
		return false
	end
end

function DovahMova:CloseMsgBox()
	ZO_Dialogs_ReleaseDialog("DovahMovaDialog", false)
end

function DovahMova:ShowMsgBox(title, msg, typ)

	local callback = {}

	callback = {
		[1] = 
		{
			keybind = "DIALOG_PRIMARY",
			text = "Оновити мовну базу",
			callback =
				function ()
					DovahMova_Dump()
				end,
            clickSound = SOUNDS.DIALOG_ACCEPT,
		},
		[2] =
		{
			keybind = "DIALOG_NEGATIVE",
            text = "Скасувати", 
			callback =
				function ()
					self.Settings.IsUpdateNeeded = false
				end,
            clickSound = SOUNDS.DIALOG_DECLINE,
		},
	}
	
	local confirmDialog = 
	{
		canQueue = true,
		onlyQueueOnce = true,
		gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
		title = { text = title },
		mainText = { text = msg },
		buttons = callback
	}
	
	ZO_Dialogs_RegisterCustomDialog("DovahMovaDialog", confirmDialog)
	self:CloseMsgBox()
	ZO_Dialogs_ShowDialog("DovahMovaDialog")
end

-- Initialize adjectives processing
function DovahMova:InitializeAdjectivesProcessing()
    if not DovahMova_Adjectives then
        return
    end
    
    -- Store original GetString function
    local originalGetString = GetString
    
    -- Override GetString to process adjectives
    GetString = function(stringId, ...)
        local result = originalGetString(stringId, ...)
        
        -- Process the string if it contains ^a or ^а tags, or Ukrainian adjective patterns
        if result and (string.find(result, "%^[aа]") or string.find(result, "[иі]й%s+%S+%^[fmnp]")) then
            result = DovahMova_Adjectives.ProcessTaggedString(result)
        end
        
        return result
    end
    
    -- Also hook ZO_CachedStrFormat which is commonly used for formatted strings
    local originalCachedStrFormat = ZO_CachedStrFormat
    
    ZO_CachedStrFormat = function(pattern, ...)
        local args = {...}
        
        -- Process each argument that might contain tags or Ukrainian adjective patterns
        for i, arg in ipairs(args) do
            if type(arg) == "string" and (string.find(arg, "%^[afmnp]") or string.find(arg, "[иі]й%s+%S+%^[fmnp]")) then
                args[i] = DovahMova_Adjectives.ProcessTaggedString(arg)
            end
        end
        
        -- Process the pattern itself if it contains tags
        if string.find(pattern, "%^[afmnp]") then
            pattern = DovahMova_Adjectives.ProcessTaggedString(pattern)
        end
        
        return originalCachedStrFormat(pattern, unpack(args))
    end
    
    -- Also try to hook LocalizeString if it exists
    if LocalizeString then
        local originalLocalizeString = LocalizeString
        
        LocalizeString = function(formatString, ...)
            local args = {...}
            
            -- Process arguments that might have Ukrainian adjective patterns
            for i, arg in ipairs(args) do
                if type(arg) == "string" and (string.find(arg, "%^[afmnp]") or string.find(arg, "[иі]й%s+%S+%^[fmnp]") or string.find(arg, "ый%s+%S+%^[fmnp]")) then
                    args[i] = DovahMova_Adjectives.ProcessTaggedString(arg)
                end
            end
            
            return originalLocalizeString(formatString, unpack(args))
        end
    end
    
    -- Also try to hook zo_strformat if it exists
    if zo_strformat then
        local originalZoStrformat = zo_strformat
        
        zo_strformat = function(formatString, ...)
            local args = {...}
            
            -- Process arguments that might have Ukrainian adjective patterns
            for i, arg in ipairs(args) do
                if type(arg) == "string" and (string.find(arg, "%^[afmnp]") or string.find(arg, "[иі]й%s+%S+%^[fmnp]") or string.find(arg, "ый%s+%S+%^[fmnp]")) then
                    args[i] = DovahMova_Adjectives.ProcessTaggedString(arg)
                end
            end
            
            return originalZoStrformat(formatString, unpack(args))
        end
    end
end

function DovahMova_init()

	-- Check if data needs to be initialized
	local rsv = DovahMova.Settings.Data
	local partsCount = 0
	for _ in pairs(rsv.Parts) do partsCount = partsCount + 1 end
	
	if partsCount == 0 then
		-- Don't call DumpUA here as it causes infinite reload
		-- Instead, just use the fallback method
	end
	
	if not DovahMova:IsDBOld() then
		if DovahMova.Settings.ShowCraft ~= "ua" and DovahMova_doubleNamesBoth then
			DovahMova_doubleNamesBoth(DovahMova)
		end
		
		if (DovahMova.Settings.ShowAbilitiesMenu ~= "ua" or DovahMova.Settings.ShowAbilitiesTooltip ~= "ua") and DovahMova_doubleNamesAbilities then
			DovahMova_doubleNamesAbilities(DovahMova)
		end
		
		if DovahMova.Settings.ShowChampionTooltip ~= "ua" and DovahMova_doubleNamesChampion then
			DovahMova_doubleNamesChampion(DovahMova)
		end
		
		if (DovahMova.Settings.ShowItemsNamesTooltip ~= "ua" or DovahMova.Settings.ShowItemsEnchantsTooltip ~= "ua" or DovahMova.Settings.ShowItemsTraitsTooltip ~= "ua" or DovahMova.Settings.ShowItemsSetsTooltip ~= "ua") and DovahMova_doubleNamesItems then
			DovahMova_doubleNamesItems(DovahMova)
		end
		
		if DovahMova.Settings.ShowItemsDisplay ~= "ua" and type(DovahMova_doubleNamesItemsDisplay) == "function" then
			DovahMova_doubleNamesItemsDisplay(DovahMova)
		end
		
		if DovahMova.Settings.ShowGuildStoreDisplay ~= "ua" and type(DovahMova_doubleNamesGuildStore) == "function" then
			DovahMova_doubleNamesGuildStore(DovahMova)
		end
		
		if DovahMova.Settings.Show ~= "ua" and type(DovahMova_doubleNamesGuildStore) == "function" then
			DovahMova_doubleNamesGuildStore(DovahMova)
		end
		
		if DovahMova.Settings.ShowLocations ~= "ua" and DovahMova_doubleNamesLocations then
			DovahMova_doubleNamesLocations(DovahMova)
			LFGDoubleNames(DovahMova)
		end
		
		if DovahMova.Settings.ShowScribing ~= "ua" and DovahMova_doubleNamesScribing then
			DovahMova_doubleNamesScribing(DovahMova)
		end

		if (DovahMova.Settings.EnglishSearch or DovahMova.Settings.ShowCollectionsSetsMenu ~= "ua") and DovahMova_doubleNamesCollections then
			DovahMova_doubleNamesCollections(DovahMova)
			ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
			ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
		end
	end
end



function DovahMova:MagicReplace(str, what, with)
    what = zo_strgsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = zo_strgsub(with, "[%%]", "%%%%")
    return zo_strgsub(str, what, with)
end

function DovahMova:DumpUA()
	local rsv = DovahMova.Settings.Data
	
	-- CRITICAL FIX: Set flag to disable postfix logic during data generation
	DovahMova._isGeneratingData = true
	
	-- Items - collect item IDs for English translations (like RuESO)
	for i = 1, 300000 do
		local itemName = GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
		
		if itemName and itemName ~= "" and not string.match(itemName, "_") then
			-- Store item ID as placeholder (will be replaced with English name in DumpEn)
			rsv.Items[i] = i
		end
	end
	
	for i = 1, 300000 do

		local hasSet, setName = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i)) 
		
		if hasSet then
			rsv.SetsNames[ZO_CachedStrFormat("<<z:1>>", setName)] = i
		end
	end
	
	for i = 1, #uaesoLinks do
		rsv.Potions[zo_strlower(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", uaesoLinks[i])))] = uaesoLinks[i]
	end
	
	for i = 1, #uaesoParts do
		local itemName = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", uaesoParts[i])))
		rsv.Parts[itemName] = uaesoParts[i]
	end
	
	for i = 1, #uaesoEnchantPrefixes do
		rsv.EnchantPrefixes[DovahMova:MagicReplace(zo_strlower(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", uaesoEnchantPrefixes[i]))), " " .. GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), "")] = uaesoEnchantPrefixes[i]
	end
	
	for i = 1, #uaesoPrefixes do
		local str = DovahMova:MagicReplace(ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", uaesoPrefixes[i]))), " " .. ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:" .. string.match(uaesoPrefixes[i], "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")), "")
		-- FIXED: Use direct regex replacement instead of byte-based substring to avoid UTF-8 corruption
		local cleanStr = string.gsub(str, "%^[afmnp]$", "")
		-- WORKAROUND: Fix ESO localization bug where "руб" gets corrupted to "� уб"
		cleanStr = string.gsub(cleanStr, "^� уб", "руб")
		
		-- NORMALIZE: Convert all declensions to masculine root form for consistent lookup
		-- Convert plural endings to masculine
		cleanStr = string.gsub(cleanStr, "і$", "ий")        -- залізоткані → залізотканий
		cleanStr = string.gsub(cleanStr, "ії$", "ий")       -- тінешкірії → тінешкірний  
		-- Convert feminine endings to masculine
		cleanStr = string.gsub(cleanStr, "а$", "ий")        -- залізоткана → залізотканий
		cleanStr = string.gsub(cleanStr, "я$", "ий")        -- (if any -я endings)
		-- Convert neuter endings to masculine  
		cleanStr = string.gsub(cleanStr, "е$", "ий")        -- (if any -е endings)
		
		rsv.Prefixes[cleanStr] = uaesoPrefixes[i]
	end
	
	for i = 1, #uaesoAffixes do
		rsv.Affixes[DovahMova:MagicReplace(ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", uaesoAffixes[i]))), ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")) .. " ", "")] = uaesoAffixes[i]
	end
	
	-- Locations
	
	local backupLocations = DovahMova.Settings.ShowLocations
	DovahMova.Settings.ShowLocations = "ua"
	
	local zonesCount = GetNumZones()
	for i = 1, zonesCount do
		local locationName = ZO_CachedStrFormat("<<z:1>>", GetZoneNameByIndex(i))
		if locationName then
			rsv.Locations[locationName] = string.format("zone:%d:0", i)
		end
		
		local POIsCount = GetNumPOIs(i)
		for j = 1, POIsCount do
			local locationName = ZO_CachedStrFormat("<<z:1>>", GetPOIInfo(i, j))
			if locationName then
				rsv.Locations[locationName] = string.format("poi:%d:%d", i, j)
			end
		end
	end
	
	local fastTravelNodesCount = GetNumFastTravelNodes()
	for i = 1, fastTravelNodesCount do
		local _, locationName = GetFastTravelNodeInfo(i)
		if locationName then
			rsv.Locations[ZO_CachedStrFormat("<<z:1>>", locationName)] = string.format("ft:%d:0", i)
		end
	end
	
	for i = 1, 1000 do
		local locationName = ZO_CachedStrFormat("<<z:1>>", GetKeepName(i))
		if locationName then
			rsv.Locations[locationName] = string.format("keep:%d:0", i)
		end
	end
	
	-- Dungeons from Activity Finder data
	if ZO_ACTIVITY_FINDER_ROOT_MANAGER and ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData then
		-- Normal Dungeons
		local normalDungeons = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[2]
		if normalDungeons then
			for i = 1, #normalDungeons do
				local rawName = normalDungeons[i]["rawName"]
				if rawName and rawName ~= "" then
					local locationName = ZO_CachedStrFormat("<<z:1>>", rawName)
					if locationName and not rsv.Locations[locationName] then
						rsv.Locations[locationName] = string.format("activity_finder:%d:2", i)
					end
				end
			end
		end
		
		-- Veteran Dungeons
		local vetDungeons = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[3]
		if vetDungeons then
			for i = 1, #vetDungeons do
				local rawName = vetDungeons[i]["rawName"]
				if rawName and rawName ~= "" then
					local locationName = ZO_CachedStrFormat("<<z:1>>", rawName)
					if locationName and not rsv.Locations[locationName] then
						rsv.Locations[locationName] = string.format("activity_finder:%d:3", i)
					end
				end
			end
		end
	end
	
	DovahMova.Settings.ShowLocations = backupLocations
	
	-- Scribing Scripts
	local backupScribing = DovahMova.Settings.ShowScribing
	DovahMova.Settings.ShowScribing = "ua"
	
	-- Collect scribing script names using the available API
	if IsScribingEnabled() then
		local numCraftedAbilities = GetNumCraftedAbilities()
		for i = 1, numCraftedAbilities do
			local craftedAbilityId = GetCraftedAbilityIdAtIndex(i)
			if craftedAbilityId then
				-- Collect scripts for each slot type
				for slotType = SCRIBING_SLOT_PRIMARY, SCRIBING_SLOT_TERTIARY do
					local numScripts = GetNumScriptsInSlotForCraftedAbility(craftedAbilityId, slotType)
					for j = 1, numScripts do
						local scriptId = GetScriptIdAtSlotIndexForCraftedAbility(craftedAbilityId, slotType, j)
						if scriptId then
							local scriptName = GetCraftedAbilityScriptDisplayName(scriptId)
							if scriptName and scriptName ~= "" then
								rsv.ScribingScripts[scriptId] = string.format("script:%d:%d:%d", craftedAbilityId, slotType, j)
							end
						end
					end
				end
			end
		end
	end
	
	DovahMova.Settings.ShowScribing = backupScribing
	
	-- CRITICAL FIX: Clear data generation flag
	DovahMova._isGeneratingData = false
	
	DovahMova.Settings["enDump"] = true
	SetCVar("language.2", "en")
end

function DovahMova:DumpEn()
	local rsv = DovahMova.Settings.Data
	
	-- CRITICAL FIX: Set flag to disable postfix logic during data generation
	DovahMova._isGeneratingData = true
	
	-- Items - collect English names and create mapping
	
	for i = 1, 300000 do
		local itemName = GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
		
		if itemName and itemName ~= "" and not string.match(itemName, "_") then
			-- Store English name by item ID
			rsv.Items[i] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itemName)
		end

		local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
		
		if hasSet then
			rsv.Sets[setId] = setName
		end
	end
	
	-- Set Names
	
	for index,value in pairs(rsv.SetsNames) do
		-- Ensure value is a number
		local itemId = tonumber(value)
		if itemId then
			local hasSet, setName = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId))
			rsv.SetsNames[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, setName)
		end
	end
	
	-- Alchemy
	
	for index,value in pairs(rsv.Potions) do
		rsv.Potions[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)))
	end
	
	-- Item Parts
	
	for index,value in pairs(rsv.Parts) do
		-- Ensure value is a number
		local itemId = tonumber(value)
		if itemId then
			rsv.Parts[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)))
		else
		end
	end
	
	-- Enchantment Prefixes
	
	for index,value in pairs(rsv.EnchantPrefixes) do
		rsv.EnchantPrefixes[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, DovahMova:MagicReplace(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)), " " .. GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), ""))
	end
	
	-- Item Prefixes
	
	for index,value in pairs(rsv.Prefixes) do
		rsv.Prefixes[index] = DovahMova:MagicReplace(ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))), " " .. ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H1:item:" .. string.match(value, "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")), "")
	end
	
	-- Item Affixes
	
	for index,value in pairs(rsv.Affixes) do
		-- Ensure value is a number
		local itemId = tonumber(value)
		if itemId then
			rsv.Affixes[index] = DovahMova:MagicReplace(ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId))), ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")) .. " ", "")
		end
	end
	
	-- Locations
	
	for index,value in pairs(rsv.Locations) do
		local locType, locId, locSubId = string.match(value, "^(.*):(%d+):(%d+)$")
		local locTypeBase, locIdBase, locSubIdBase, postfix = string.match(value, "^(.*):(%d+):(%d+):(.+)$")
		
		if locType and locId and locSubId then
			if locType == "zone" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetZoneNameByIndex(locId))
			elseif locType == "poi" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetPOIInfo(locId, locSubId))
			elseif locType == "keep" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetKeepName(locId))
			elseif locType == "ft" then
				local _, locationName = GetFastTravelNodeInfo(locId)
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, locationName)
			elseif locType == "activity_finder" then
				-- For activity_finder entries, we need to get the English name from the same source
				if ZO_ACTIVITY_FINDER_ROOT_MANAGER and ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData then
					local category = tonumber(locSubId)
					local dungeonIndex = tonumber(locId)
					if category and dungeonIndex then
						local dungeons = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[category]
						if dungeons and dungeons[dungeonIndex] then
							local rawName = dungeons[dungeonIndex]["rawName"]
							if rawName then
								-- Switch to English language temporarily to get English name
								local currentLang = GetCVar("language.2")
								SetCVar("language.2", "en")
								local englishName = ZO_CachedStrFormat(SI_ZONE_NAME, rawName)
								SetCVar("language.2", currentLang)
								rsv.Locations[index] = englishName
							end
						end
					end
				end
			end
		end
	end
	
	-- Traits
	
	for i = 1, 100 do
		local traitName = GetString("SI_ITEMTRAITTYPE", i)
		
		if traitName and traitName ~= "" then
			rsv.Traits[i] = traitName
		end
	end
	
	-- Abilities
	
	local numSkillTypes = GetNumSkillTypes()
	
	for i = 1, numSkillTypes do
		local numSkillLines = GetNumSkillLines(i)
		
		for j = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(i, j)
			
			for k = 1, numSkillAbilities do
				
				local _, _, _, passive = GetSkillAbilityInfo(i, j, k)
				
				if passive then
					for l = 1,GetNumPassiveSkillRanks(i, j, k) do
						local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 0, l)
						rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					end
				else
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 0, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 1, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 2, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
				end
			end
		end
	end
	
	for key,value in pairs(uaesoCompanionAbilities) do
		rsv.Abilities[key] = GetAbilityName(key)
	end

	for i = 1, GetNumChampionDisciplines() do
		for j = 1, GetNumChampionDisciplineSkills(i) do
			rsv.Abilities[GetChampionAbilityId(GetChampionSkillId(i, j))] = GetChampionSkillName(GetChampionSkillId(i, j))
		end
	end
	
	-- Scribing Scripts
	for index, value in pairs(rsv.ScribingScripts) do
		local scriptType, craftedAbilityId, slotType, scriptIndex = string.match(value, "^(.*):(%d+):(%d+):(%d+)$")
		
		if scriptType and craftedAbilityId and slotType and scriptIndex then
			if scriptType == "script" then
				-- Get the script ID and then get its English name
				local scriptId = GetScriptIdAtSlotIndexForCraftedAbility(tonumber(craftedAbilityId), tonumber(slotType), tonumber(scriptIndex))
				if scriptId then
					rsv.ScribingScripts[index] = GetCraftedAbilityScriptDisplayName(scriptId)
				end
			end
		end
	end
	
	DovahMova.Settings["enDump"] = nil
	DovahMova.Settings["success"] = true
	
	rsv.ApiVersion = GetAPIVersion()
	rsv.AddonVersion = DovahMova.Version
	DovahMova.Settings.IsUpdateNeeded = true
	
	-- CRITICAL FIX: Clear data generation flag
	DovahMova._isGeneratingData = false
	
	SetCVar("language.2", "ua")
end

function DovahMova:Check()

	local rsv = DovahMova.Settings

	if GetCVar("language.2") == "en" and rsv["enDump"] ~= nil then
		DovahMova:DumpEn()
	end
	
	if GetCVar("language.2") == "ua" and rsv["uaDump"] ~= nil then
		rsv["uaDump"] = nil
		DovahMova:DumpUA()
	end
	
	if rsv["success"] ~= nil then
		rsv["success"] = nil
	end
end

function DovahMova:IsAddonRunning(addonName)
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, _, state = manager:GetAddOnInfo(i)
        if name == addonName and state == ADDON_STATE_ENABLED then
            return true
        end
    end
    return false
end

-- Система інтеграцій
DovahMova.integrations = DovahMova.integrations or {}

function DovahMova:RegisterIntegration(name, integrationObject)
    if not name or not integrationObject then
        return false
    end
    
    self.integrations[name] = integrationObject
    
    if d then
        d("DovahMova: Зареєстровано інтеграцію " .. name)
    end
    
    return true
end

function DovahMova:GetIntegration(name)
    return self.integrations[name]
end

function DovahMova:GetAllIntegrations()
    return self.integrations
end

function DovahMova:GetIntegrationInfo()
    local info = {}
    for name, integration in pairs(self.integrations) do
        if integration.GetInfo then
            info[name] = integration:GetInfo()
        else
            info[name] = {
                name = name,
                initialized = integration.isInitialized or false,
                compatible = true,
                message = "Базова інтеграція"
            }
        end
    end
    return info
end

function DovahMova_Dump()
	local rsd = DovahMova.Settings.Data
	rsd.Sets = {}
	rsd.SetsNames = {}
	rsd.Potions = {}
	rsd.Traits = {}
	rsd.Abilities = {}
	rsd.Items = {}
	rsd.Parts = {}
	rsd.Prefixes = {}
	rsd.Affixes = {}
	rsd.EnchantPrefixes = {}
	rsd.Locations = DovahMova_getLocations()
	rsd.CraftAbilities = {}
	rsd.ScribingScripts = {}

	if GetCVar("language.2") == "ua" then
		DovahMova:DumpUA()
	else
		DovahMova.Settings["uaDump"] = true
		SetCVar("language.2", "ua")
	end
end

function DovahMova:DebugItem(itemId)
	local rsv = self.Settings.Data
	local itemName = GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId))
	local storedTranslation = rsv.Items[itemId]
	
	d("=== DovahMova Debug ===")
	d("Item ID: " .. tostring(itemId))
	d("Current Item Name: " .. tostring(itemName))
	d("Stored Translation: " .. tostring(storedTranslation))
	d("Current Language: " .. GetCVar("language.2"))
	d("======================")
end

function DovahMova:DebugDatabase()
	local rsv = self.Settings.Data
	local count = 0
	
	d("=== DovahMova Database Debug ===")
	for k, v in pairs(rsv.Items) do
		count = count + 1
		if count <= 10 then
			d("Item " .. tostring(k) .. " = " .. tostring(v))
		else
			break
		end
	end
	d("Total items in database: " .. count)
	d("Current Language: " .. GetCVar("language.2"))
	d("================================")
end

-- Test adjectives functionality
function DovahMova:TestAdjectives()
	d("=== DovahMova Adjectives Test ===")
	
	if not DovahMova_Adjectives then
		d("ERROR: Adjectives module not loaded!")
		return
	end
	
	-- Test cases - focus on problematic examples mentioned by user
	local testCases = {
		-- Problematic cases reported by user
		{ input = "стальний поножі^p", expected = "стальні поножі" },
		{ input = "мідний намисто^n", expected = "мідне намисто" },
		
		-- Working cases for comparison
		{ input = "стальний булава^f", expected = "стальна булава" },
		{ input = "дубовий щит^m", expected = "дубовий щит" },
		
		-- Test other gender cases to make sure they work
		{ input = "залізний броня^f", expected = "залізна броня" },
		{ input = "синій плащ^f", expected = "синя плащ" },
		{ input = "синій море^n", expected = "синє море" },
		{ input = "синій очі^p", expected = "сині очі" },
	}
	
	-- Run tests
	for i, test in ipairs(testCases) do
		local result = DovahMova_Adjectives.ProcessTaggedString(test.input)
		local status = result == test.expected and "✓ PASS" or "✗ FAIL"
		d(string.format("%s Test %d: '%s' → '%s' (expected: '%s')", 
			status, i, test.input, result, test.expected))
		
		-- Debug failed cases
		if result ~= test.expected then
			d("--- DEBUG INFO ---")
			-- Test gender extraction 
			local beforeGender, gender, afterGender = string.match(test.input, "^(.-)%^([fmnp])(.*)$")
			d(string.format("Gender extraction: before='%s', gender='%s', after='%s'", 
				tostring(beforeGender), tostring(gender), tostring(afterGender)))
			
			-- Test individual adjective declension
			if beforeGender and gender then
				for word in string.gmatch(beforeGender, "[^%s]+") do
					if string.match(word, "ий$") then
						local declined = DovahMova_Adjectives.DeclineAdjective(word, gender)
						d(string.format("Adjective: '%s' → '%s' (gender: %s)", word, declined, gender))
					end
				end
			end
			d("--- END DEBUG ---")
		end
	end
	
	-- Test individual function
	d("\n--- Testing DeclineAdjective function ---")
	local adjectiveTests = {
		{ adj = "стальний", gender = "f", expected = "стальна" },
		{ adj = "стальний", gender = "n", expected = "стальне" },
		{ adj = "стальний", gender = "p", expected = "стальні" },
		{ adj = "синій", gender = "f", expected = "синя" },
		{ adj = "синій", gender = "n", expected = "синє" },
		{ adj = "синій", gender = "p", expected = "сині" },
	}
	
	for i, test in ipairs(adjectiveTests) do
		local result = DovahMova_Adjectives.DeclineAdjective(test.adj, test.gender)
		local status = result == test.expected and "✓ PASS" or "✗ FAIL"
		d(string.format("%s DeclineTest %d: '%s' + gender '%s' → '%s' (expected: '%s')", 
			status, i, test.adj, test.gender, result, test.expected))
	end
	
	d("=================================")
end

-- =================================================================================================
-- MAIL HANDLER MODULE / МОДУЛЬ АВТОЗБОРУ ПОШТИ
-- =================================================================================================

DovahMova.MailHandler = {}

-- Список тем листів від найманців для різних мов
DovahMova.MailHandler.hirelingMailSubjects = {
	-- Українська
	["Матеріали від коваля"] = true, 
	["Матеріали від кравця"] = true, 
	["Матеріали від тесляра"] = true, 
	["Матеріали від зачарувальника"] = true,
	["Інгредієнти від постачальника"] = true, 
	["Матеріали від ювеліра"] = true,
	-- English
	["Blacksmithing Hireling"] = true,
	["Clothier Hireling"] = true,
	["Woodworking Hireling"] = true,
	["Enchanting Hireling"] = true,
	["Provisioning Hireling"] = true,
	["Jewelry Crafting Hireling"] = true,
}

-- Перевірка чи це лист від найманця
function DovahMova.MailHandler:IsHirelingMail(subject)
	if not subject then return false end
	
	-- Перевіряємо точні назви
	if self.hirelingMailSubjects[subject] then
		return true
	end
	
	-- Додатково перевіряємо ключові слова для українських листів
	if string.find(subject, "Матеріали від") or string.find(subject, "Інгредієнти від") then
		return true
	end
	
	-- Перевіряємо англійські ключові слова
	if string.find(subject, "Hireling") then
		return true
	end
	
	return false
end

-- Основна функція обробки поштової скриньки
function DovahMova.MailHandler:ProcessMailbox()
	-- Перевіряємо чи увімкнена функція
	if not DovahMova.Settings.AutoCollectHirelingMail then
		return
	end
	
	local mailsToProcess = {}
	local nextMail = GetNextMailId(nil)
	
	-- Збираємо всі листи від найманців
	while nextMail do
		local _, _, subject, _, _, system, customer, _, numAtt, money = GetMailItemInfo(nextMail)
		
		-- Перевіряємо: системний лист, без грошей, з вкладеннями, від найманця
		if not customer and system and money == 0 and numAtt > 0 and self:IsHirelingMail(subject) then
			table.insert(mailsToProcess, {id = nextMail, subject = subject})
		end
		
		nextMail = GetNextMailId(nextMail)
	end
	
	if #mailsToProcess == 0 then
		return
	end
	
	-- Показуємо повідомлення про початок збору
	if #mailsToProcess > 0 then
		d(string.format("DovahMova: Знайдено %d листів від найманців. Починаю автозбір...", #mailsToProcess))
	end
	
	-- Обробляємо листи по черзі
	local i = 1
	local function processNextMail()
		if not mailsToProcess[i] then
			d("DovahMova: Автозбір листів завершено.")
			return
		end
		
		local mailData = mailsToProcess[i]
		
		-- Збираємо вкладення з опцією видалення
		TakeMailAttachments(mailData.id, DovahMova.Settings.AutoDeleteHirelingMail)
		
		-- Переходимо до наступного листа з затримкою
		zo_callLater(function()
			i = i + 1
			processNextMail()
		end, 300) -- 300 мс затримка між листами
	end
	
	processNextMail()
end

-- Обробник відкриття поштової скриньки
function DovahMova.MailHandler:OnMailboxOpen()
	-- Чекаємо 1 секунду для повного завантаження листів
	zo_callLater(function() self:ProcessMailbox() end, 1000)
end

-- Ініціалізація модуля пошти
function DovahMova:InitializeMailHandler()
	-- Реєструємо обробник події
	EVENT_MANAGER:RegisterForEvent(
		"DovahMova_MailHandler", 
		EVENT_MAIL_OPEN_MAILBOX, 
		function(...) 
			DovahMova.MailHandler:OnMailboxOpen(...) 
		end
	)
end

-- Ініціалізація інтеграції AsylumTracker
function DovahMova:InitializeAsylumTrackerIntegration()
	-- Файл інтеграції завантажується автоматично через DovahMova.txt маніфест
	-- Тут ми просто перевіряємо чи інтеграція була успішно завантажена
	if GetCVar("language.2") == "ua" then
		-- Створюємо fallback якщо інтеграція ще не завантажилась
		EVENT_MANAGER:RegisterForEvent("DovahMova_AsylumTrackerFallback", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
			if addonName == "AsylumTracker" then
				EVENT_MANAGER:UnregisterForEvent("DovahMova_AsylumTrackerFallback", EVENT_ADD_ON_LOADED)
				
				-- Перевіряємо чи інтеграція вже не була застосована
				if not _G["DovahMova_AsylumTrackerIntegration"] then
					-- Створюємо мінімальну фіктивну локалізацію
					if AsylumTracker and AsylumTracker.lang then
						AsylumTracker.lang.ua = AsylumTracker.lang.ua or {}
						AsylumTracker.lang.ua.LoadStrings = function()
							-- Використовуємо англійські рядки за замовчуванням
							return
						end
						
						if d then
							d("DovahMova: AsylumTracker fallback localization applied")
						end
					end
				end
			end
		end)
	end
end

-- Ініціалізація інтеграції QuestMap
function DovahMova:InitializeQuestMapIntegration()
	-- Файл інтеграції завантажується автоматично через DovahMova.txt маніфест
	-- Інтеграція автоматично реєструється при завантаженні
	if GetCVar("language.2") == "ua" then
		-- Логування про успішне завантаження модуля (якщо інтеграція вже завантажена)
		if _G["DovahMova_QuestMapIntegration"] then
			local integration = _G["DovahMova_QuestMapIntegration"]
			if integration.isInitialized then
				if d then
					d("DovahMova: QuestMap інтеграція ініціалізована успішно")
				end
			end
		end
	end
end

-- Ініціалізація інтеграції PotionMaker
function DovahMova:InitializePotionMakerIntegration()
	-- Файл інтеграції завантажується автоматично через DovahMova.txt маніфест
	-- Інтеграція автоматично реєструється при завантаженні
	if GetCVar("language.2") == "ua" then
		-- Створюємо fallback якщо інтеграція ще не завантажилась
		EVENT_MANAGER:RegisterForEvent("DovahMova_PotionMakerFallback", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
			if addonName == "PotionMaker" then
				EVENT_MANAGER:UnregisterForEvent("DovahMova_PotionMakerFallback", EVENT_ADD_ON_LOADED)
				
				-- Чекаємо трохи, щоб PotionMaker повністю ініціалізувався
				zo_callLater(function()
					if _G["DovahMova_PotionMakerIntegration"] then
						local integration = _G["DovahMova_PotionMakerIntegration"]
						if integration.isInitialized then
							if d then
								d("DovahMova: PotionMaker інтеграція ініціалізована успішно")
							end
						else
							-- Спробувати ініціалізувати ще раз
							if integration.Initialize then
								integration:Initialize()
							end
						end
					end
				end, 200)
			end
		end)
	end
end

-- Ініціалізація інтеграції AsquartOsseinCageHelper
function DovahMova:InitializeAsquartOsseinCageHelperIntegration()
	-- Файл інтеграції завантажується автоматично через DovahMova.txt маніфест
	-- Інтеграція автоматично реєструється при завантаженні
	if GetCVar("language.2") == "ua" then
		-- Створюємо fallback якщо інтеграція ще не завантажилась
		EVENT_MANAGER:RegisterForEvent("DovahMova_AsquartOsseinCageHelperFallback", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
			if addonName == "AsquartOsseinCageHelper" then
				EVENT_MANAGER:UnregisterForEvent("DovahMova_AsquartOsseinCageHelperFallback", EVENT_ADD_ON_LOADED)
				
				-- Чекаємо трохи, щоб AOCH повністю ініціалізувався
				zo_callLater(function()
					if _G["DovahMova_AsquartOsseinCageHelperIntegration"] then
						local integration = _G["DovahMova_AsquartOsseinCageHelperIntegration"]
						if integration.isInitialized then
							if d then
								d("DovahMova: AsquartOsseinCageHelper інтеграція ініціалізована успішно")
							end
						else
							-- Спробувати ініціалізувати ще раз
							if integration.Initialize then
								integration:Initialize()
							end
						end
					end
				end, 200)
			end
		end)
	end
end

function DovahMova_Change(lang)
	if GetCVar("language.2") ~= lang then
		SetCVar("language.2", lang)
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Ви вже переключені на цю мову.")
	end
end

EVENT_MANAGER:RegisterForEvent("DovahMova_OnAddOnLoaded", EVENT_ADD_ON_LOADED, function(_event, _name) DovahMova:OnInit(_event, _name) end)
EVENT_MANAGER:RegisterForEvent("DovahMova_StartupMessage", EVENT_PLAYER_ACTIVATED, function(...) DovahMova:StartupMessage() end)

-- Register slash commands for testing
SLASH_COMMANDS["/testadj"] = function() DovahMova:TestAdjectives() end
SLASH_COMMANDS["/debugadj"] = function() 
	if DovahMova_Adjectives and DovahMova_Adjectives.DebugSpecificCases then
		DovahMova_Adjectives.DebugSpecificCases()
	else
		d("ERROR: Debug function not available!")
	end
end

-- Command to toggle tooltip debug
DovahMova.tooltipDebugEnabled = false
SLASH_COMMANDS["/debugtooltip"] = function(args)
	if args == "on" then
		DovahMova.tooltipDebugEnabled = true
		d("Tooltip debug enabled. Hover over items to see debug info.")
	elseif args == "off" then
		DovahMova.tooltipDebugEnabled = false
		d("Tooltip debug disabled.")
	else
		DovahMova.tooltipDebugEnabled = not DovahMova.tooltipDebugEnabled
		local status = DovahMova.tooltipDebugEnabled and "enabled" or "disabled"
		d("Tooltip debug " .. status .. ". Use '/debugtooltip on' or '/debugtooltip off' to control.")
	end
end
SLASH_COMMANDS["/testadjective"] = function(args)
	if not DovahMova_Adjectives then
		d("ERROR: Adjectives module not loaded!")
		return
	end
	
	if args and args ~= "" then
		local result = DovahMova_Adjectives.ProcessTaggedString(args)
		d(string.format("Input: '%s' → Output: '%s'", args, result))
	else
		d("Usage: /testadjective <text with tags>")
		d("Example: /testadjective стальний^а булава^f")
	end
end

-- Quick test command for complex cases
SLASH_COMMANDS["/testcomplex"] = function()
	local tests = {
		"кленовий вогняний посох^n",
		"залізний важкий щит^m",
		"стальний булава^f",
		"синій плащ^m"
	}
	
	d("=== Testing complex adjective cases ===")
	for _, test in ipairs(tests) do
		local result = DovahMova_Adjectives and DovahMova_Adjectives.ProcessTaggedString(test) or test
		d(string.format("'%s' → '%s'", test, result))
	end
end

-- Test new auto-tagging functionality
SLASH_COMMANDS["/testautotag"] = function()
	local tests = {
		"мідний намисто",
		"золотий кільце",
		"срібний перстень",
		"стальний поножі", 
		"бавовняний сорочка",
		"залізний броня",
		"дубовий щит" -- should not get tag
	}
	
	d("=== Testing auto-tagging functionality ===")
	for _, test in ipairs(tests) do
		-- Simulate the auto-tagging logic
		local result = test
		if not string.find(result, "%^[fmnp]") then
			local patterns = {
				-- Jewelry
				{pattern = "%S*ий намисто", gender = "n"},
				{pattern = "%S*ий кільце", gender = "n"},
				{pattern = "%S*ий перстень", gender = "m"},
				{pattern = "%S*ій перстень", gender = "m"},
				{pattern = "%S*ий сережки", gender = "p"},
				{pattern = "%S*ій сережки", gender = "p"},
				-- Armor
				{pattern = "%S*ий поножі", gender = "p"},
				{pattern = "%S*ій поножі", gender = "p"},
				{pattern = "%S*ий сорочка", gender = "f"},
				{pattern = "%S*ій сорочка", gender = "f"},
				{pattern = "%S*ий броня", gender = "f"},
				{pattern = "%S*ій броня", gender = "f"},
			}
			
			for _, pat in ipairs(patterns) do
				if string.match(result, pat.pattern) then
					result = result .. "^" .. pat.gender
					break
				end
			end
		end
		
		-- Then apply adjective processing
		if string.find(result, "[иі]й%s+%S+%^[fmnp]") and DovahMova_Adjectives then
			result = DovahMova_Adjectives.ProcessTaggedString(result)
		end
		
		d(string.format("'%s' → '%s'", test, result))
	end
end

-- Test pattern matching directly
SLASH_COMMANDS["/testpattern"] = function(args)
	if not args or args == "" then
		d("Usage: /testpattern <text>")
		d("Example: /testpattern мідний намисто (Necklace)")
		return
	end
	
	d(string.format("=== Detailed Pattern Debug ==="))
	d(string.format("Input text: '%s' (length: %d)", args, string.len(args)))
	
	-- Test simple patterns first
	local simpleTests = {
		"мідний",
		"ий", -- ending that works 
		"ій", -- Ukrainian ending
		"[иі]й", -- character class that doesn't work
		"намисто",
		"мідний намисто"
	}
	
	d("Simple substring tests:")
	for _, test in ipairs(simpleTests) do
		if string.find(args, test) then
			d(string.format("  ✓ Found: '%s'", test))
		else
			d(string.format("  ✗ Not found: '%s'", test))
		end
	end
	
	-- Test our patterns
	local patterns = {
		{pattern = "%S*ий намисто", gender = "n"}, -- WORKING PATTERN
		{pattern = "%S*ій намисто", gender = "n"}, -- for синій  
		{pattern = "мідний намисто", gender = "n"}, -- literal test
		{pattern = "ий", gender = "test"}, -- just the ending
		{pattern = "ій", gender = "test"}, -- Ukrainian і ending
	}
	
	d("Pattern matching tests:")
	for i, pat in ipairs(patterns) do
		local match = string.match(args, pat.pattern)
		if match then
			d(string.format("  ✓ Pattern %d MATCHED: '%s' → found: '%s'", i, pat.pattern, match))
		else
			d(string.format("  ✗ Pattern %d failed: '%s'", i, pat.pattern))
		end
	end
	
	-- Character by character analysis of key part
	local testStr = "мідний"
	d(string.format("Character analysis of '%s':", testStr))
	for i = 1, string.len(testStr) do
		local char = string.sub(testStr, i, i)
		local byte = string.byte(char)
		d(string.format("  Pos %d: '%s' (byte: %d)", i, char, byte))
	end
end

-- Test GetItemLinkName hooks
SLASH_COMMANDS["/testhooks"] = function()
	d("=== Testing GetItemLinkName hooks ===")
	
	-- Test with known item
	local testLinks = {
		"|H1:item:43561:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- мідний намисто
		"|H1:item:43551:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- гарбовані полуботки 
	}
	
	for i, link in ipairs(testLinks) do
		local name = GetItemLinkName(link)
		d(string.format("Test %d: %s → '%s'", i, link, tostring(name)))
	end
	
	d("Enable debug with /debugtooltip on to see detailed processing")
end

-- Check what the user sees in inventory
SLASH_COMMANDS["/checkinv"] = function()
	d("=== Checking inventory display ===")
	
	-- Get player inventory
	local bagId = BAG_BACKPACK
	local numSlots = GetBagSize(bagId)
	
	d(string.format("Checking %d inventory slots...", numSlots))
	
	for slotIndex = 0, numSlots - 1 do
		local itemId = GetItemId(bagId, slotIndex)
		if itemId and itemId > 0 then
			local itemLink = GetItemLink(bagId, slotIndex)
			local name = GetItemName(bagId, slotIndex)
			local linkName = GetItemLinkName(itemLink)
			
			-- Only show items with adjectives
			if name and (string.find(name, "ий ") or string.find(name, "ій ")) then
				d(string.format("Slot %d - ID:%d", slotIndex, itemId))
				d(string.format("  GetItemName: '%s'", tostring(name)))
				d(string.format("  GetItemLinkName: '%s'", tostring(linkName)))
				break -- Show only first match to avoid spam
			end
		end
	end
end

-- Check guild store functions 
SLASH_COMMANDS["/checkguild"] = function()
	d("=== Guild Store Functions Test ===")
	
	if GetTradingHouseListingItemInfo then
		d("✓ GetTradingHouseListingItemInfo available")
	else
		d("✗ GetTradingHouseListingItemInfo NOT available")
	end
	
	if GetTradingHouseSearchResultItemInfo then
		d("✓ GetTradingHouseSearchResultItemInfo available")  
	else
		d("✗ GetTradingHouseSearchResultItemInfo NOT available")
	end
	
	d("Enable debug with /debugtooltip on and visit guild store to test")
end

-- Check specific item translations in database
SLASH_COMMANDS["/checkitem"] = function(args)
	if not args or args == "" then
		d("Usage: /checkitem <itemID>")
		d("Example: /checkitem 43561 (for мідне намисто)")
		d("Example: /checkitem 138796 (for платиновий перстень)")
		return
	end
	
	local itemId = tonumber(args)
	if not itemId then
		d("Invalid item ID: " .. args)
		return
	end
	
	d("=== Item Translation Check ===")
	d(string.format("Item ID: %d", itemId))
	
	-- Check if we have translation data
	if DovahMova and DovahMova.Settings and DovahMova.Settings.Data then
		local rsd = DovahMova.Settings.Data
		if rsd.Items and rsd.Items[itemId] then
			d(string.format("English translation: '%s'", rsd.Items[itemId]))
		else
			d("No direct English translation found in rsd.Items")
		end
		
		-- Check if it's in Parts table (for crafted items)
		if rsd.Parts then
			d("Checking Parts table for base components...")
			for partKey, partValue in pairs(rsd.Parts) do
				if string.find(partKey:lower(), "перстень") or string.find(partKey:lower(), "намисто") or string.find(partKey:lower(), "ring") or string.find(partKey:lower(), "necklace") then
					d(string.format("  '%s' → '%s'", partKey, partValue))
				end
			end
		end
	else
		d("Translation data not available")
	end
end

-- Test mail handler
SLASH_COMMANDS["/testmail"] = function()
	d("=== DovahMova Mail Handler Test ===")
	d("Auto-collect enabled: " .. tostring(DovahMova.Settings.AutoCollectHirelingMail))
	d("Auto-delete enabled: " .. tostring(DovahMova.Settings.AutoDeleteHirelingMail))
	
	-- Test subject detection
	local testSubjects = {
		"Матеріали від коваля",
		"Інгредієнти від постачальника",
		"Blacksmithing Hireling",
		"Random mail subject",
		"Матеріали від ювеліра"
	}
	
	d("\nTesting mail subject detection:")
	for _, subject in ipairs(testSubjects) do
		local isHireling = DovahMova.MailHandler:IsHirelingMail(subject)
		d(string.format("  '%s' - %s", subject, isHireling and "✓ Hireling mail" or "✗ Not hireling"))
	end
	
	d("\nTo test actual mail collection, open a mailbox with hireling mails.")
end

-- Manually trigger mail collection
SLASH_COMMANDS["/collectmail"] = function()
	if DovahMova.MailHandler then
		d("Manually triggering mail collection...")
		DovahMova.MailHandler:ProcessMailbox()
	else
		d("Mail handler not initialized!")
	end
end

-- NOTE: GetItemName processing is handled in itemsDisplay.lua
