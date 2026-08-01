local RuESOSettings = ZO_Object:Subclass()
RUESO_SETTINGS = RuESOSettings

function RuESOSettings:New(...)
    local settings = ZO_Object.New(self)
    settings:Initialize(...)
    return settings
end

function RuESOSettings:Initialize(RuESO)
	self.LAM = LibAddonMenu2
	self:InitSettings(RuESO)
end

function RuESOSettings:InitSettings(RuESO)

    local panelData = {
		type = "panel",
		name = RuESO.Name,
		displayName = RuESO.Name,
		author = "TERAB1T",
		version = RuESO.Version,
		slashCommand = "/rueso",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://elderscrolls.net/tes-online/rueso/"
	}
	
	self.LAM:RegisterAddonPanel(panelData.name, panelData)
	
	local optionsTable = {}
	
	table.insert(optionsTable, {
		type = "header",
		name = "Обновление базы названий",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "button",
		name = "Обновить базу",
		tooltip = "Позволяет обновить базу названий.",
		func = RuESO_Dump,
	})

	table.insert(optionsTable, {
		type = "header",
		name = "Оригинальные названия (разное)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Имена персонажей",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		tooltip = "Позволяет настроить язык отображения имен неигровых персонажей.",
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		getFunc = function() return RuESO.Settings.ShowNPC end,
		setFunc = (function(value)
			RuESO.Settings.ShowNPC = value
			
			if value ~= "ru" and RuESO_doubleNamesNPC then
				RuESO_doubleNamesNPC(RuESO)
			end
		end),
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Названия локаций",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		tooltip = "Позволяет настроить язык отображения названий локаций.",
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},			
		getFunc = function() return RuESO.Settings.ShowLocations end,
		setFunc = (function(value)
			RuESO.Settings.ShowLocations = value
			
			if value ~= "ru" and RuESO_doubleNamesLocations then
				RuESO_doubleNamesLocations(RuESO)
			end
			
			FRIENDS_LIST_MANAGER:BuildMasterList()
			FRIENDS_LIST_MANAGER:OnSocialDataLoaded()
			GUILD_ROSTER_MANAGER:BuildMasterList()
			GUILD_ROSTER_MANAGER:OnGuildDataLoaded()
			
			LFGDoubleNames(RuESO)
			
			CADWELLS_ALMANAC:RefreshList()
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			RuESO:MapNameStyle()
		end),
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Названия наборов в ремесленных станках",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		tooltip = "Позволяет настроить язык отображения названий наборов при наведении на ремесленные станки.",
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		getFunc = function() return RuESO.Settings.ShowCraft end,
		setFunc = (function(value)
			RuESO.Settings.ShowCraft = value
			
			if value ~= "ru" and RuESO_doubleNamesBoth then
				RuESO_doubleNamesBoth(RuESO)
			end
		end),
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригинальные названия (способности)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Способности (меню)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "en"},
		tooltip = "Позволяет настроить язык отображения названий способностей в соответствующем разделе.",
		getFunc = function() return RuESO.Settings.ShowAbilitiesMenu end,
		setFunc = (function(value)
			RuESO.Settings.ShowAbilitiesMenu = value
			
			if value ~= "ru" and RuESO_doubleNamesAbilities then
				RuESO_doubleNamesAbilities(RuESO)
			end
			
			SKILLS_WINDOW:RebuildSkillLineList()
			COMPANION_SKILLS_DATA_MANAGER:RebuildSkillsData()
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Способности (всплывающие окна)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий способностей во всплывающих окнах.",
		getFunc = function() return RuESO.Settings.ShowAbilitiesTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowAbilitiesTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesAbilities then
				RuESO_doubleNamesAbilities(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Система героя",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий способностей в разделе системы героя.",
		getFunc = function() return RuESO.Settings.ShowChampionTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowChampionTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesChampion then
				RuESO_doubleNamesChampion(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригинальные названия (предметы)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Предметы (всплывающие окна)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий предметов во всплывающих окнах.",
		getFunc = function() return RuESO.Settings.ShowItemsNamesTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowItemsNamesTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesItems then
				RuESO_doubleNamesItems(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Зачарования (всплывающие окна)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий зачарований во всплывающих окнах.",
		getFunc = function() return RuESO.Settings.ShowItemsEnchantsTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowItemsEnchantsTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesItems then
				RuESO_doubleNamesItems(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Особенности (всплывающие окна)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий особенностей во всплывающих окнах.",
		getFunc = function() return RuESO.Settings.ShowItemsTraitsTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowItemsTraitsTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesItems then
				RuESO_doubleNamesItems(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Наборы (всплывающие окна)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий наборов во всплывающих окнах.",
		getFunc = function() return RuESO.Settings.ShowItemsSetsTooltip end,
		setFunc = (function(value)
			RuESO.Settings.ShowItemsSetsTooltip = value
			
			if value ~= "ru" and RuESO_doubleNamesItems then
				RuESO_doubleNamesItems(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригинальные названия (коллекция наборов)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Двуязычный поиск",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		tooltip = "Позволяет использовать английские названия наборов во время поиска в меню коллекций.",
		getFunc = function() return RuESO.Settings.EnglishSearch end,
		setFunc = (function(value)
			RuESO.Settings.EnglishSearch = value
			
			if value and RuESO_doubleNamesCollections then
				RuESO_doubleNamesCollections(RuESO)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Наборы (меню)",
		warning = (function()
			if RuESO:IsDBOld() then
				return "Требуется обновление базы."
			else
				return false
			end
		end),
		disabled = function() return RuESO:IsDBOld() end,
		choices = {RuESO.DropdownParameters["ru"], RuESO.DropdownParameters["ruen"], RuESO.DropdownParameters["enru"], RuESO.DropdownParameters["en"]},
		choicesValues = {"ru", "ruen", "enru", "en"},
		tooltip = "Позволяет настроить язык отображения названий наборов в меню коллекций.",
		getFunc = function() return RuESO.Settings.ShowCollectionsSetsMenu end,
		setFunc = (function(value)
			RuESO.Settings.ShowCollectionsSetsMenu = value
			
			if value ~= "ru" and RuESO_doubleNamesCollections then
				RuESO_doubleNamesCollections(RuESO)
			end
			ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
			ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
		end),
	})
		
	self.LAM:RegisterOptionControls(panelData.name, optionsTable)
end