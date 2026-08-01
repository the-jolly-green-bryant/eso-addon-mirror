--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP",			"Переключится на уровень плеч")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP_X",		"Переключится на уровень плеч (Быстро)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER",	"Обмен/Центрировать")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER_X",	"Обмен/Центрировать (Быстро)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER",		"Центрировать камеру")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER_X",		"Центрировать камеру (Быстро)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_ALL",		"Alt. camera values") -- TODO
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_DIST",		"Alt. distance") -- TODO
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_FOV",		"Alt. field of view") -- TODO
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SIEGE",		"Переключить осадную камеру")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC0",		"Переключиться на предпочитаемую камеру")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC1",		"Переключиться на статичную камеру #1")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC2",		"Переключиться на статичную камеру #2")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC3",		"Переключиться на статичную камеру #3")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CHAT",	"ON/OFF - Chat Camera")  -- TODO
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CRAFT",	"ON/OFF - Craft Camera") -- TODO
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_LOCKP",	"ON/OFF - Lockpicking Cam.") -- TODO


--	Options
NTCam_Texts = {
	cat0 = {
		title	= "Общие настройки для всех персонажей",
	},
	cat1 = {
		title	= "Предпочитаемая камера",
		desc1	= "Эти настройки переопределяют обычные настройки камеры.",
		opt1	= "Дистанция от персонажа (0 - вид от первого лица)",
    	opt1b	= "Поле зрения",
		opt2	= "На уровне плеч",
		choices = {
			"По-центру",
			"Слева",
			"Справа",
		},
		opt3	= "Горизонтальное положение",
		opt3b	= "Горизонтальное смещение (статичное)",
		warn3b	= "Значение этого параметра не будет менятся при взаимодействиях/событиях.",
		opt4	= "Вертикальное положение",
		opt5	= "Вертикальное смещение (при центрировании)",
		warn5	= "Этот параметр используется только в том случае, если вы переключаетесь в центр с помощью горячей клавиши.\nЕсли вы используете центрированную камеру, то обе настройки «Вертикальное…» должны иметь одинаковое значение.",
		--
		desc11	= "После “взаимодействия” или “события” восстанавливать предыдущее состояние камеры. За исключением случаев, когда вы решите восстановить предпочитаемую камеру:",
		opt11	= "Восстановить предпочитаемую камеру вместо предыдущей",
		--
	},
	cat2 = {
		title0	= "ALTERNATIVE CAMERAS",
		desc0	= "These can be toggled only by keybindings.",
		title1	= "ALTERNATIVE VALUES", -- TODO
		desc1	= "These alternative values can replace values of the preferred camera.", -- TODO
		title2	= "Статичные камеры",
		desc2	= "Переключение на эти камеры возможно только с использованием горячих клавиш.\nЭти камеры НЕ меняются при взаимодействиях и событиях\nи это подразумевает только временное их использование.", -- \nAlso, note that these cameras have an extended horizontal position range.",
		opt0	= "Выводить в чат сообщение при смене камер",
		msg0	= "Переключились на статичную камеру #",
		menuX	= "Статичная камера #",
		opt1	= "Расстояние",
		opt2	= "Поле зрения",
		opt3	= "Горизонтальное положение",
		opt3b	= "Горизонтальное смещение",
		opt4	= "Вертикальное смещение",
	},
	menuX = {
		opt0	= "Не переключать на камеру по умолчанию",
		warn1	= "Вам нужно использовать “Предотвращать смену камеры при взаимодействии”, чтобы это работало.",
		opt1	= "Поведение",
		choices = {
			"Ничего не делать",
			"Центрироовать, вид от третьего лица",
			"Переключится на вид от первого лица",
			"Переключится на вид от третьего лица",
			"Отдалить камеру",
			"Приблизить камеру",
			"Своё",
		},
		opt2	= "Изменить расстояние …",
		opt2b	= "Изменить поле зрения …",
		opt3	= "Изменить горизонтальное положение …",
		opt4	= "Изменть вертикальное положение …",
		opt5	= "Задержка перед возвратом камеры (х 100мс)",
		to		= "… на:",
		opt10	= "Никаких других изменений пока ", -- .. Menu title
	},
	cat3 = {
		title	= "При заимодействия", -- CHANGES",
		desc1	= "Управляет тем, как взаимодействия изменяют предпочтительную камеру.",
		menu1 = {
			title	= "В диалогах",
		},
		menu2 = {
			title	= "На ремесленных станках",
		},
		menu3 = {
			title	= "На покрасочной станции",
		},
		menu4 = {
			title	= "При взломе",
		},
	},
	cat4 = {
		title	= "При событиях", -- CHANGES",
		desc1	= "Управляет тем, как события изменяют предпочтительную камеру.",
		menu0 = {	-- TODO
			title	= "while moving",
			opt1	= "Output speed to chat",
			opt2	= "Move / Sprint threshold",
			desc1	= "When the movement speed is above the threshold (e.g. while sprinting), the below settings can override the above ones.",
		},
		menu1 = {
			title	= "верхом",
		},
		menu2 = {
			title	= "в режиме скрытности",
		},
		menu3 = {
			title	= "когда оружие достается/прячется",
			desc1	= "Событие достать/спрятать оружие вызывается только горячей клавишей.\n(К сожалению, использование умений не вызывает этого события.)\nНастройка ниже также позволяет вызвать событие “достать оружие” при вступлении в бой.",
			opt1	= "Вступление в бой вызывает событие “достать оружие”",
		},
		menu4 = {
			title	= "в бою",
			opt1	= "Auto-sheath weapon after combat", -- TODO
		},
		menu5 = {
			title	= "в облике оборотня",
			opt1	= "Минимальное расстояние в облике оборотня",
		},
	}
}