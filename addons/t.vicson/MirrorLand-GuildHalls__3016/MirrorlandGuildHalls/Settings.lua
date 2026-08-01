--------------------------------------------------------------------------------
--	MirrorlandGuildHalls — настройки (SavedVariables + LibAddonMenu-2.0)
--------------------------------------------------------------------------------
		--Значения по умолчанию. Конкретный список опций согласуем позже —
		--добавляй сюда поле на каждую опцию и контрол в BuildSettingsPanel().
local SETTINGS_VERSION = 1
local defaults = {
		-- Поведение
	bagSpace = true,            -- индикатор места в почте
	skipDestroyConfirm = true,  -- пропуск подтверждения уничтожения предмета
	bankDeposit = true,         -- авто-вкладка «Вложить» в банке
		-- Тихий режим: true = молчать про категорию (по умолчанию всё показываем)
	silentAll = false,          -- мастер: глушить все сообщения (кроме приветствия)
	silentGuildhalls = false,   -- телепорт в дома/домой
	silentTpOk = false,         -- удачные телепорты (зона/город)
	silentTpFail = false,       -- неудачные телепорты (нет людей / нет вэйшрайна)
	silentGroup = false,        -- группа: создание, к лидеру, проверка готовности
	silentQuests = false,       -- шара заданий
}

		--Создаёт SavedVars и подключает нужный профиль (аккаунт/персонаж)
function MirrorlandGuildHalls:InitializeSettings()
		--Маленькое всегда-аккаунтное хранилище: тут лежит выбор профиля
	self.profile = ZO_SavedVars:NewAccountWide("MirrorlandGuildHallsSV", SETTINGS_VERSION, "Profile", { accountWide = true })

	if self.profile.accountWide then
		self.settings = ZO_SavedVars:NewAccountWide("MirrorlandGuildHallsSV", SETTINGS_VERSION, "Settings", defaults)
	else
		self.settings = ZO_SavedVars:NewCharacterIdSettings("MirrorlandGuildHallsSV", SETTINGS_VERSION, "Settings", defaults)
	end

	self:BuildSettingsPanel()
end

		--Панель в системных настройках аддонов (LibAddonMenu-2.0)
function MirrorlandGuildHalls:BuildSettingsPanel()
	local LAM = LibAddonMenu2
	if not LAM then return end

	self.settingsPanel = LAM:RegisterAddonPanel("MirrorlandGuildHalls_Panel", {
		type = "panel",
		name = "MirrorLand GuildHalls",
		displayName = "|c5c73edMirrorLand|r |cb8dbddGuildHalls|r",
		author = "t.vicson, Lost.Seeker, Kwibus",
		version = "1.5.2",
		website = "https://mlc-teso.ru/",
		registerForRefresh = true,
		registerForDefaults = true,
	})

	local options = {
		{
			type = "header",
			name = "Профиль настроек",
		},
		{
			type = "checkbox",
			name = "Настройки на весь аккаунт",
			tooltip = "Включено — общие настройки для всех персонажей. Выключено — у каждого персонажа свои. Применяется после перезагрузки интерфейса.",
			default = true,
			getFunc = function() return MirrorlandGuildHalls.profile.accountWide end,
			setFunc = function(value) MirrorlandGuildHalls.profile.accountWide = value end,
			requiresReload = true,
		},
		{
			type = "header",
			name = "Поведение",
		},
		{
			type = "checkbox",
			name = "Индикатор места в почте",
			tooltip = "Иконка и счётчик свободных слотов сумки в окне почты. Применяется после перезагрузки интерфейса.",
			default = defaults.bagSpace,
			getFunc = function() return MirrorlandGuildHalls.settings.bagSpace end,
			setFunc = function(value) MirrorlandGuildHalls.settings.bagSpace = value end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Без подтверждения уничтожения предмета",
			tooltip = "Пропускает диалог подтверждения при уничтожении предмета.",
			default = defaults.skipDestroyConfirm,
			getFunc = function() return MirrorlandGuildHalls.settings.skipDestroyConfirm end,
			setFunc = function(value) MirrorlandGuildHalls.settings.skipDestroyConfirm = value end,
		},
		{
			type = "checkbox",
			name = "Авто-вкладка «Вложить» в банке",
			tooltip = "При открытии банка автоматически переключаться на вкладку «Вложить».",
			default = defaults.bankDeposit,
			getFunc = function() return MirrorlandGuildHalls.settings.bankDeposit end,
			setFunc = function(value) MirrorlandGuildHalls.settings.bankDeposit = value end,
		},
		{
			type = "header",
			name = "Тихий режим",
		},
		{
			type = "checkbox",
			name = "Заглушить всё",
			tooltip = "Глушит все сообщения аддона разом (кроме приветствия при входе). Пока включено, настройки по типам ниже недоступны.",
			default = defaults.silentAll,
			getFunc = function() return MirrorlandGuildHalls.settings.silentAll end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentAll = value end,
		},
		{
			type = "checkbox",
			name = "Гильдхоллы",
			tooltip = "Сообщения при телепорте в гильдейские дома и домой («Уиии! Летим…», «Дом, милый дом.»).",
			default = defaults.silentGuildhalls,
			disabled = function() return MirrorlandGuildHalls.settings.silentAll end,
			getFunc = function() return MirrorlandGuildHalls.settings.silentGuildhalls end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentGuildhalls = value end,
		},
		{
			type = "checkbox",
			name = "Удачные телепорты",
			tooltip = "Сообщения при успешном прыжке в зону (к человеку) и удачном полёте в город.",
			default = defaults.silentTpOk,
			disabled = function() return MirrorlandGuildHalls.settings.silentAll end,
			getFunc = function() return MirrorlandGuildHalls.settings.silentTpOk end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentTpOk = value end,
		},
		{
			type = "checkbox",
			name = "Неудачные телепорты",
			tooltip = "Сообщения, когда в зоне никого нет или вэйшрайн города не открыт.",
			default = defaults.silentTpFail,
			disabled = function() return MirrorlandGuildHalls.settings.silentAll end,
			getFunc = function() return MirrorlandGuildHalls.settings.silentTpFail end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentTpFail = value end,
		},
		{
			type = "checkbox",
			name = "Группа",
			tooltip = "Сообщения при создании группы, прыжке к лидеру и проверке готовности.",
			default = defaults.silentGroup,
			disabled = function() return MirrorlandGuildHalls.settings.silentAll end,
			getFunc = function() return MirrorlandGuildHalls.settings.silentGroup end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentGroup = value end,
		},
		{
			type = "checkbox",
			name = "Задания",
			tooltip = "Сообщения при «Поделиться заданиями».",
			default = defaults.silentQuests,
			disabled = function() return MirrorlandGuildHalls.settings.silentAll end,
			getFunc = function() return MirrorlandGuildHalls.settings.silentQuests end,
			setFunc = function(value) MirrorlandGuildHalls.settings.silentQuests = value end,
		},
		{
			type = "description",
			text = "Если Вкл = НЕ выводить сообщения этой категории в чат.",
		},
	}
	LAM:RegisterOptionControls("MirrorlandGuildHalls_Panel", options)
end
