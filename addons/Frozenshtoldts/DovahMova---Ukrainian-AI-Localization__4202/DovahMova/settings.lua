local DovahMovaSettings = ZO_Object:Subclass()
DOVAHMOVA_SETTINGS = DovahMovaSettings

-- Helper function to safely call postfix functions
local function SafeCallPostfixFunction(functionName, DovahMova)
	-- Try to access the function
	local func = _G[functionName]
	
	if type(func) == "function" then
		-- Use pcall to safely call the function
		local success, error = pcall(func, DovahMova)
		if not success then
			d("DovahMova: Error calling " .. functionName .. ": " .. tostring(error))
		end
		return success
	else
		-- Function not available, just skip it
		d("DovahMova: " .. functionName .. " function not available, skipping...")
		return false
	end
end

function DovahMovaSettings:New(...)
    local settings = ZO_Object.New(self)
    settings:Initialize(...)
    return settings
end

function DovahMovaSettings:Initialize(DovahMova)
	self.LAM = LibAddonMenu2
	self:InitSettings(DovahMova)
end

function DovahMovaSettings:InitSettings(DovahMova)

    local panelData = {
		type = "panel",
		name = DovahMova.Name,
		displayName = DovahMova.Name,
		author = "Frozenshtoldts and DovahMova Team",
		version = DovahMova.Version,
		slashCommand = "/dovahmova",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	self.LAM:RegisterAddonPanel(panelData.name, panelData)
	
	local optionsTable = {}
	
	table.insert(optionsTable, {
		type = "header",
		name = "Загальні",
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "label",
		text = "|cffcc00Увага:|r Зміна цього налаштування призведе до негайного перезавантаження інтерфейсу.",
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Увімкнути українську мову",
		tooltip = "Негайно вмикає/вимикає українську мову та перезавантажує UI.",
		getFunc = function() 
			return GetCVar("language.2") == "ua" 
		end,
		setFunc = function(value)
			if value then
				SetCVar("language.2", "ua")
			else
				SetCVar("language.2", "en")
			end
		end,
	})
	

	
	table.insert(optionsTable, {
		type = "button",
		name = "Оновити мовну базу",
		tooltip = "Виконує індексацію мовного файлу після оновлення гри чи аддона.",
		func = DovahMova_Dump,
	})
	
	table.insert(optionsTable, {
		type = "divider",
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Автозбір листів від найманців",
		tooltip = "Автоматично збирати матеріали з листів від найманців при відкритті поштової скриньки.",
		getFunc = function() return DovahMova.Settings.AutoCollectHirelingMail end,
		setFunc = function(value)
			DovahMova.Settings.AutoCollectHirelingMail = value
		end,
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Видаляти листи після збору",
		tooltip = "Автоматично видаляти листи від найманців після збору матеріалів.",
		disabled = function() return not DovahMova.Settings.AutoCollectHirelingMail end,
		getFunc = function() return DovahMova.Settings.AutoDeleteHirelingMail end,
		setFunc = function(value)
			DovahMova.Settings.AutoDeleteHirelingMail = value
		end,
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "label",
		text = "|cffcc00Увага:|r Генеруйте TTC кожен раз коли міняєте 'Предмети в інвентарі'.",
	})
	
	table.insert(optionsTable, {
		type = "button",
		name = "Згенерувати TTC",
		tooltip = "Створює українську таблицю пошуку для Tamriel Trade Centre, щоб ціни відображалися для українських назв предметів. Потрібно виконати після запуску скрипту інтеграції.",
		func = function()
			if DOVAHMOVA_GENERATE_TTC_UA then
				d("Generating Ukrainian TTC lookup table...")
				DOVAHMOVA_GENERATE_TTC_UA()
				d("TTC generation complete! The table should now persist after reload.")
				d("If prices don't show after reload, try /testttc to diagnose the issue.")
			else
				d("ERROR: TTC integration not loaded!")
				d("Make sure you have run the integration setup script first.")
			end
		end,
	})

	table.insert(optionsTable, {
		type = "checkbox",
		name = "Двомовний пошук сетів в меню колекцій",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		tooltip = "Дозволяє використовувати англійські назви сетів під час пошуку в меню колекцій.",
		getFunc = function() return DovahMova.Settings.EnglishSearch end,
		setFunc = (function(value)
			DovahMova.Settings.EnglishSearch = value
			
			if value and DovahMova_doubleNamesCollections then
				DovahMova_doubleNamesCollections(DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Інтерфейс",
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Предмети в інвентарі (reloadui)",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв предметів в інвентарі, банку та у торговців. |cffcc00Увага:|r Зміна цього налаштування призведе до перезавантаження інтерфейсу.",
		getFunc = function() return DovahMova.Settings.ShowItemsDisplay end,
		setFunc = (function(value)
			DovahMova.Settings.ShowItemsDisplay = value
			
			-- Force UI reload to apply changes
			ReloadUI()
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Гільдійський магазин (reloadui)",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв предметів в гільдійському магазині. Працює з Awesome Guild Store. |cffcc00Увага:|r Зміна цього налаштування призведе до перезавантаження інтерфейсу.",
		getFunc = function() return DovahMova.Settings.ShowGuildStoreDisplay end,
		setFunc = (function(value)
			DovahMova.Settings.ShowGuildStoreDisplay = value
			
			-- Force UI reload to apply changes
			ReloadUI()
		end),
	})

	table.insert(optionsTable, {
		type = "dropdown",
		name = "Назви підземель (reloadui)",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв підземель. |cffcc00Увага:|r Зміна цього налаштування призведе до перезавантаження інтерфейсу.",
		getFunc = function() return DovahMova.Settings.ShowLocations end,
		setFunc = (function(value)
			DovahMova.Settings.ShowLocations = value
			
			-- Force UI reload to apply changes
			ReloadUI()
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Здібності",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["en"]},
		choicesValues = {"ua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв умінь у відповідному розділі.",
		getFunc = function() return DovahMova.Settings.ShowAbilitiesMenu end,
		setFunc = (function(value)
			DovahMova.Settings.ShowAbilitiesMenu = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesAbilities", DovahMova)
			end
			
			SKILLS_WINDOW:RebuildSkillLineList()
			COMPANION_SKILLS_DATA_MANAGER:RebuildSkillsData()
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Система ЧП",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє налаштувати мову відображення назв умінь у розділі ЧП.",
		getFunc = function() return DovahMova.Settings.ShowChampionTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowChampionTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesChampion", DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Сети Обладунків",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв сетів обладунків у меню колекцій.",
		getFunc = function() return DovahMova.Settings.ShowCollectionsSetsMenu end,
		setFunc = (function(value)
			DovahMova.Settings.ShowCollectionsSetsMenu = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesCollections", DovahMova)
			end
			ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
			ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Скрипти скрайбінгу",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв скриптів скрайбінгу в меню скрайбінгу.",
		getFunc = function() return DovahMova.Settings.ShowScribing end,
		setFunc = (function(value)
			DovahMova.Settings.ShowScribing = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesScribing", DovahMova)
			end
		end),
	})
	
		table.insert(optionsTable, {
		type = "dropdown",
		name = "Назви комплектів у ремісничих верстатах",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		tooltip = "Дозволяє вибрати мову відображення назв комплектів при наведенні на ремісничі верстати.",
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		getFunc = function() return DovahMova.Settings.ShowCraft end,
		setFunc = (function(value)
			DovahMova.Settings.ShowCraft = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesBoth", DovahMova)
			end
		end),
		width = "full",
	})

	table.insert(optionsTable, {
		type = "dropdown",
		name = "Трейти",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв трейтів у спливаючих вікнах.",
		getFunc = function() return DovahMova.Settings.ShowItemsTraitsTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowItemsTraitsTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesItems", DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Спливаючі вікна",
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Уміння",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв умінь у спливаючих вікнах.",
		getFunc = function() return DovahMova.Settings.ShowAbilitiesTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowAbilitiesTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesAbilities", DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Предмети",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв предметів у спливаючих вікнах.",
		getFunc = function() return DovahMova.Settings.ShowItemsNamesTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowItemsNamesTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesItems", DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Зачарування",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв заклять у спливаючих вікнах.",
		getFunc = function() return DovahMova.Settings.ShowItemsEnchantsTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowItemsEnchantsTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesItems", DovahMova)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Сети Обладунків",
		warning = (function()
			if DovahMova:IsDBOld() then
				return "Необхідно оновити мовну базу."
			else
				return false
			end
		end),
		disabled = function() return DovahMova:IsDBOld() end,
		choices = {DovahMova.DropdownParameters["ua"], DovahMova.DropdownParameters["uaen"]},
		choicesValues = {"ua", "uaen"},
		tooltip = "Дозволяє вибрати мову відображення назв комплектів у спливаючих вікнах.",
		getFunc = function() return DovahMova.Settings.ShowItemsSetsTooltip end,
		setFunc = (function(value)
			DovahMova.Settings.ShowItemsSetsTooltip = value
			
			if value ~= "ua" then
				SafeCallPostfixFunction("DovahMova_doubleNamesItems", DovahMova)
			end
		end),
	})
	
	self.LAM:RegisterOptionControls(panelData.name, optionsTable)
end
