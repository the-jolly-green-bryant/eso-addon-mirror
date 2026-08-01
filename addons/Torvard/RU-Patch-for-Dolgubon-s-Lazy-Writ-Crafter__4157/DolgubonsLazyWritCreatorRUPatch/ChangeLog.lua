--  bullet point: |t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t
local changelog = {
	{4030,
[[Окно списка изменений
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Вы смотрите на него! Оно будет использоваться для информирования о новых функциях и важных исправлениях.
Улучшенный множитель крафта.
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Теперь он будет создавать полный цикл заказов при взаимодействии со станцией (пока только для экипировки).
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Проверяет текущее содержимое вашей сумки и создает до Х единиц каждого предмета. Например, если у вас множитель 3 и в данный момент есть 1 меч, то будет создано 2 меча.
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Если вы хотите использовать старое поведение аддона, вы можете отключить умный множитель в меню настроек.
Небольшая оптимизация загрузки - функциональность окна статистики будет загружена только в том случае, если вы откроете это окно.
]],
console=[[
QR-коды для ссылок на настройки (только для консоли).
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Появится QR-код, который вы сможете отсканировать, например, если захотите перейти в раздел форума для публикации ошибок.
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Добавлена зависимость LibQRCode для реализации этого поведения.
]]

},
{4032,
[[Исправления ошибок.
- Исправлены ошибки, которые возникали при использовании помощников по разбору.
- Исправлена ошибка, из-за которой умный множитель неправильно определял предметы, созданные на 1-м уровне.
]]
},
{
	4036,
[[Добавлены фрагменты рецептов Псиджиков для поддержки обработки наград за заказы.
Добавлена возможность создавать предметы из набора для Золотого стремления «Ловкий ремесленник».
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t При взаимодействии со станцией создания предметов великого мастера вы увидите подсказку о необходимости их создания. 
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Создаст только те, которые вам еще нужны, и покажет только если вы не завершили получение награды за завершение этапа.
|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Обратите внимание, что это очень просто, поэтому будут создаваться только мантия/топоры/луки/кольца.
]]
},
{
	4038,
[[Добавлено золото для обработки наград за заказы. Вы можете настроить его так, чтобы всё золото, полученное за заказы, зачислялось в ваш банк. Будет зачислено только золото за выполнение заданий.
Исправлена ​​ошибка, из-за которой обработка наград за новые неизвестные исследования использовала настройки для неизвестных мастерских заказов.
]],pc="Добавлена ​​кнопка «посетить дом» в меню настроек (несколько версий назад) для перемещения в дом с ремесленными станциями."
},
{4039,
[[Умный множитель теперь поддерживает функцию зачаровывания.
Исправлена ошибка, из-за которой неизвестные исследования и неизвестные мастерские заказы объединялись в окне статистики добычи
Изменена текстура фона, чтобы использовать старую текстуру фона.
]]
},
{4041,
[[Добавлена ​​поддержка золотых материалов в обработку наград.
]]}

}-- ,pc =[[Добавлена ​​кнопка «посетить дом» в меню настроек для перемещения в дом с ремесленными станциями.]]

local welcomeMessage = "Спасибо, что установили Dolgubon's Lazy Writ Crafter! Пожалуйста, ознакомьтесь с настройками, чтобы настроить поведение дополнения."

local function displayText(text)
	WritCreater.initializeResetWarnerScene()
	DolgubonsLazyWritChangelogBackdropOutput:SetText(text)
	SCENE_MANAGER:Show("dlwcannouncer")
end

function WritCreater.displayChangelog()
	WritCreater.savedVarsAccountWide.initialInstall = false
	if WritCreater.savedVarsAccountWide.initialInstall then
		WritCreater.savedVarsAccountWide.initialInstall = false
		displayText(welcomeMessage)
		for i = 1, #changelog do
			WritCreater.savedVarsAccountWide.viewedChangelogs[changelog[i][1]] = true
		end
		return
	end
	
	for i = 1, #changelog do
		if not WritCreater.savedVarsAccountWide.viewedChangelogs[changelog[i][1]] then
			WritCreater.savedVarsAccountWide.viewedChangelogs[changelog[i][1]] = true
			local text = changelog[i][2]
			if IsConsoleUI() and changelog[i].console then
				text = text..changelog[i].console
			elseif not IsConsoleUI() and changelog[i].pc then
				text = text..changelog[i].pc
			end
			displayText(text)
			return
		end
	end
	-- WritCreater.expectedVersion
end

if GetDisplayName() == "@Dolgubon" then
	SLASH_COMMANDS['/resetchangelog'] = function() WritCreater.savedVarsAccountWide.viewedChangelogs = {} WritCreater.displayChangelog() end
	SLASH_COMMANDS['/resetwelcome'] = function() WritCreater.savedVarsAccountWide.initialInstall = true  WritCreater.displayChangelog() end
	-- SLASH_COMMANDS['/resetchangelog2'] = function() WritCreater.savedVarsAccountWide.viewedChangelogs = {} WritCreater.savedVarsAccountWide.initialInstall = true end
	SLASH_COMMANDS['/displaychangelog'] = function() WritCreater.displayChangelog() end
end

function WritCreater.initializeResetWarnerScene()
	if WritCreater.announcementScreen then return end
	local announcementScreen = ZO_Scene:New("dlwcannouncer", SCENE_MANAGER)
	WritCreater.announcementScreen = announcementScreen
	WritCreater.announcementScreen:AddFragment(ZO_SimpleSceneFragment:New(DolgubonsLazyWritChangelog))
end