-- Ukrainian localization for HarvestMap
-- by GoA (UA patch)

GoA_HarvestMapUA = GoA_HarvestMapUA or {}
GoA_HarvestMapUA.strings = {
	-- top level description
	esouidescription = "Опис аддону та відповіді на часті питання - на сторінці esoui.com",
	openesoui = "Відкрити ESOUI",
	exchangedescription2 = "Ви можете завантажити найсвіжіші дані HarvestMap (розташування ресурсів), встановивши аддон HarvestMap-Data. Детальніше - в описі аддону на ESOUI.",

	notifications = "Сповіщення та попередження",
	notificationstooltip = "Показує сповіщення та попередження у верхньому правому куті екрана.",
	moduleerrorload = "Аддон <<1>> вимкнено.\nДля цієї місцевості немає даних.",
	moduleerrorsave = "Аддон <<1>> вимкнено.\nРозташування ресурсу не було збережено.",

	-- outdated data settings
	outdateddata = "Налаштування застарілих даних",
	outdateddatainfo = "Ці налаштування спільні для всіх акаунтів і персонажів на цьому комп'ютері.",
	timedifference = "Зберігати лише останні дані",
	timedifferencetooltip = "HarvestMap зберігатиме дані лише за останні X днів.\nЦе запобігає показу старих даних, які вже можуть бути неактуальними.\nВстановіть 0, щоб зберігати всі дані незалежно від їхнього віку.",
	applywarning = "Після видалення старих даних їх не можна відновити!",

	-- account wide settings
	account = "Загальні налаштування акаунта",
	accounttooltip = "Усі налаштування нижче будуть однаковими для всіх ваших персонажів.",
	accountwarning = "Зміна цього налаштування перезавантажить інтерфейс користувача.",

	-- map pin settings
	mapheader = "Налаштування міток на карті",
	mappins = "Показувати мітки на основній карті",
	minimappins = "Показувати мітки на міні-карті",
	minimappinstooltip = "Підтримувані міні-карти: Votan, Fyrakin та AUI.",
	level = "Показувати мітки карти поверх міток цікавих місць.",
	hasdrawdistance = "Показувати лише найближчі мітки карти",
	hasdrawdistancetooltip = "Якщо увімкнено, HarvestMap створюватиме мітки на карті лише для тих місць збору ресурсів, що поруч із гравцем.\nЦе налаштування стосується лише основної карти. На міні-картах ця опція вмикається автоматично!",
	hasdrawdistancewarning = "Це налаштування стосується лише ігрової карти. На міні-картах ця опція вмикається автоматично!",
	drawdistance = "Відстань показу міток карти",
	drawdistancetooltip = "Порогова відстань, на якій відображаються мітки карти. Це налаштування також впливає на міні-карти!",
	drawdistancewarning = "Це налаштування також впливає на міні-карти!",

	visiblepintypes = "Видимі типи міток",
	custom_profile = "Власний",
	same_as_map = "Як на карті",

	-- compass settings
	compassheader = "Налаштування компаса",
	compass = "Показувати мітки на компасі",
	compassdistance = "Макс. відстань міток",
	compassdistancetooltip = "Максимальна відстань у метрах, на якій мітки з'являються на компасі.",

	-- 3d pin settings
	worldpinsheader = "Налаштування об'ємних (3D) міток",
	worldpins = "Показувати мітки в 3D-світі",
	worlddistance = "Макс. відстань 3D-міток",
	worlddistancetooltip = "Максимальна відстань у метрах до місця збору ресурсу. Якщо місце розташоване далі, 3D-мітка не відображається.",
	worldpinwidth = "Ширина 3D-мітки",
	worldpinwidthtooltip = "Ширина 3D-міток у сантиметрах.",
	worldpinheight = "Висота 3D-мітки",
	worldpinheighttooltip = "Висота 3D-міток у сантиметрах.",
	worldpinsdepth = "Бачити крізь стіни",
	worldpinsdepthtooltip = "Якщо увімкнено, 3D-мітки будуть видимі крізь стіни та інші об'єкти.",
	worldpinsdepthtext = "Вимкнення \"бачити крізь стіни\" працює лише якщо\n1) роздільна здатність гри збігається з роздільною здатністю монітора (у налаштуваннях гри або відеодрайвера), і\n2) якість субдискретизації (sub-sampling) встановлена на високу в налаштуваннях відео гри.",

	-- respawn timer settings
	visitednodes = "Відвідані вузли та помічник фармінгу",
	rangemultiplier = "Радіус врахування відвіданого вузла",
	rangemultipliertooltip = "Вузли в межах X метрів вважаються відвіданими помічником фармінгу та таймером приховування.",
	usehiddentime = "Приховувати нещодавно відвідані вузли",
	usehiddentimetooltip = "Мітки будуть приховані, якщо ви нещодавно відвідували це місце.",
	hiddentime = "Тривалість приховування",
	hiddentimetooltip = "Нещодавно відвідані вузли будуть приховані на X хвилин.",
	hiddenonharvest = "Приховувати вузли лише після збору ресурсу",
	hiddenonharvesttooltip = "Увімкніть цю опцію, щоб приховувати мітки лише після того, як ви зібрали ресурс. Якщо опцію вимкнено, мітки приховуватимуться просто після відвідування.",

	-- spawn filter
	spawnfilter = "Фільтри наявних ресурсів",
	nodedetectionmissing = "Ці опції можна увімкнути, лише якщо активна бібліотека 'NodeDetection'.",
	spawnfilterdescription = "Якщо увімкнено, HarvestMap приховуватиме мітки ресурсів, які ще не відродилися. Наприклад, якщо інший гравець вже зібрав ресурс, мітка буде прихована, доки ресурс знову не стане доступним.\n- Ця опція працює лише для ремісничих ресурсів, які можна зібрати.\n- Вона не працює для контейнерів на кшталт скринь, важких мішків чи порталів псиджиків.\n- Фільтр не працює, якщо інший аддон приховує або змінює масштаб компаса.\n- Аддон не може знати, чи відродився ресурс в іншій частині карти. Тому на карті показуватимуться лише найближчі ресурси.",
	spawnfilter_map = "Використовувати фільтр на основній карті",
	spawnfilter_minimap = "Використовувати фільтр на міні-карті",
	spawnfilter_compass = "Використовувати фільтр для міток компаса",
	spawnfilter_world = "Використовувати фільтр для 3D-міток",
	spawnfilter_pintype = "Увімкнути фільтр для типів міток:",

	-- pin type options
	styleoptions = "Налаштування іконок і кольорів",
	restoredefaultlayout = "Застосувати набір іконок і кольорів",
	selectpreset = "Виберіть набір",
	white = "Білий",
	worldBaseTexture = "Основа 3D-міток",
	pinsize = "Розмір мітки",
	pinsizetooltip = "Встановити розмір міток на карті.",
	pincolor = "Колір мітки",
	pincolortooltip = "Встановити колір міток на карті та компасі.",
	savepin = "Зберігати розташування",
	savetooltip = "Увімкніть, щоб зберігати розташування цього ресурсу, коли ви його знаходите.",
	pintexture = "Іконка мітки",

	-- pin type names
	pintype1 = "Кування та ювелірна справа",
	pintype2 = "Кравецтво",
	pintype3 = "Руни та портали псиджиків",
	pintype4 = "Гриби",
	pintype13 = "Трави/Квіти",
	pintype14 = "Водні трави",
	pintype5 = "Деревина",
	pintype6 = "Скрині",
	pintype7 = "Розчинники",
	pintype8 = "Місця риболовлі",
	pintype9 = "Важкі мішки",
	pintype10 = "Скарби злодіїв",
	pintype11 = "Контейнери правосуддя",
	pintype12 = "Приховані сховки",
	pintype15 = "Гігантські молюски",
	pintype18 = "Невідомий вузол",
	pintype19 = "Багряний нірнрут",
	pintype20 = "Торба травника",

	-- extra map filter buttons
	deletepinfilter = "Видалити мітки HarvestMap",
	filterheatmap = "Режим теплової карти",

	-- localization for the farming helper
	goldperminute = "Золота за хвилину:",
	farmresult = "Результат HarvestFarm",
	farmnotour = "HarvestFarm не зміг розрахувати гарний маршрут фармінгу із заданою мінімальною довжиною маршруту.",
	farmerror = "Помилка HarvestFarm",
	farmnoresources = "Ресурсів не знайдено.\nНа цій карті немає ресурсів, або у вас не вибрано жодного типу ресурсів.",
	farmsuccess = "HarvestFarm розрахував маршрут фармінгу з <<1>> вузлами на кілометр.\n\nНатисніть на одну з міток маршруту, щоб встановити початкову точку.",
	farmdescription = "HarvestFarm розрахує маршрут із дуже високим співвідношенням ресурсів до часу.\nПісля створення маршруту натисніть на один із вибраних ресурсів, щоб встановити початкову точку маршруту.",
	farmminlength = "Мінімальна довжина",
	farmminlengthdescription = "Що довший маршрут, то вища ймовірність, що ресурси встигнуть відродитися до початку наступного циклу.\nОднак коротший маршрут матиме краще співвідношення ресурсів до часу.\n(Мінімальна довжина вказується в кілометрах.)",
	tourpin = "Наступна ціль вашого маршруту",
	calculatetour = "Розрахувати маршрут",
	showtourinterface = "Показати інтерфейс маршруту",
	canceltour = "Скасувати маршрут",
	reverttour = "Змінити напрямок маршруту",
	resourcetypes = "Типи ресурсів",
	skiptarget = "Пропустити поточну ціль",
	removetarget = "Прибрати поточну ціль",
	nodesperminute = "Вузлів за хвилину",
	distancetotarget = "Відстань до наступного ресурсу",
	showarrow = "Показувати напрямок",
	removetour = "Видалити маршрут",
	undo = "Скасувати останню зміну",
	tourname = "Назва маршруту: ",
	defaultname = "Маршрут без назви",
	savedtours = "Збережені маршрути для цієї карти:",
	notourformap = "Для цієї карти немає збереженого маршруту.",
	load = "Завантажити",
	delete = "Видалити",
	saveexiststitle = "Підтвердіть дію",
	saveexists = "Маршрут з назвою <<1>> для цієї карти вже існує. Бажаєте перезаписати його?",
	savenotour = "Немає маршруту, який можна було б зберегти.",
	loaderror = "Не вдалося завантажити маршрут.",
	removepintype = "Бажаєте прибрати <<1>> з маршруту?",
	removepintypetitle = "Підтвердження видалення",

	-- extra harvestmap menu
	farmmenu = "Редактор маршрутів фармінгу",
	editordescription = "У цьому меню ви можете створювати та редагувати маршрути.\nЯкщо наразі немає активного маршруту, ви можете створити його, натискаючи на мітки карти.\nЯкщо маршрут активний, ви можете редагувати його, замінюючи окремі ділянки:\n- Спочатку натисніть на мітку вашого (червоного) маршруту.\n- Потім натискайте на мітки, які хочете додати до маршруту. (З'явиться зелений маршрут)\n- Наостанок знову натисніть на мітку вашого червоного маршруту.\nЗелений маршрут буде вставлено в червоний.",
	editorstats = "Кількість вузлів: <<1>>\nДовжина: <<2>> м\nВузлів на кілометр: <<3>>",

	-- filter profiles
	filterprofilebutton = "Відкрити меню профілів фільтрів",
	filtertitle = "Меню профілів фільтрів",
	filtermap = "Профіль фільтра для міток карти",
	filtercompass = "Профіль фільтра для міток компаса",
	filterworld = "Профіль фільтра для 3D-міток",
	unnamedfilterprofile = "Профіль без назви",
	defaultprofilename = "Стандартний профіль фільтра",

	-- SI names to fit with ZOS api
	SI_BINDING_NAME_SKIP_TARGET = "Пропустити ціль",
	SI_BINDING_NAME_TOGGLE_WORLDPINS = "Перемкнути 3D-мітки",
	SI_BINDING_NAME_TOGGLE_MAPPINS = "Перемкнути мітки карти",
	SI_BINDING_NAME_TOGGLE_MINIMAPPINS = "Перемкнути мітки міні-карти",
	SI_BINDING_NAME_HARVEST_SHOW_PANEL = "Відкрити редактор маршрутів HarvestMap",
	SI_BINDING_NAME_HARVEST_SHOW_FILTER = "Відкрити меню фільтрів HarvestMap",
	HARVESTFARM_GENERATOR = "Створити новий маршрут",
	HARVESTFARM_EDITOR = "Редагувати маршрут",
	HARVESTFARM_SAVE = "Зберегти/завантажити маршрут",
}

-- Extra Ukrainian names for container-type interactables (chests, heavy
-- sacks, etc). These are only ever consulted as a *fallback* on top of the
-- English names HarvestMap itself always keeps loaded (see default.lua),
-- so this is safe to ship even before the Ukrainizer translates these
-- specific object names in-game - it simply won't match anything until then.
GoA_HarvestMapUA.interactableNames = {
	["важкий мішок"] = "HEAVYSACK",
	["важкий ящик"] = "HEAVYSACK",
	["скарб злодіїв"] = "TROVE",
	["хитка панель"] = "STASH",
	["хитка плитка"] = "STASH",
	["хиткий камінь"] = "STASH",
	["портал псиджиків"] = "PSIJIC",
	["гігантський молюск"] = "CLAM",
	["торба травника"] = "HERBALIST",
}
