local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Категории внешнего вида
m.CATEGORY_TYPE_COSTUME = 'Костюм'
m.CATEGORY_TYPE_POLYMORPH = 'Превращение'
m.CATEGORY_TYPE_SKIN = 'Облик'
m.CATEGORY_TYPE_PERSONALITY = 'Манеры'
m.CATEGORY_TYPE_HAT = 'Головной убор'
m.CATEGORY_TYPE_HAIR = 'Прическа'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Растительность на лице'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Крупные украшения'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Мелкие украшения'
m.CATEGORY_TYPE_HEAD_MARKING = 'Отметина на голове'
m.CATEGORY_TYPE_BODY_MARKING = 'Отметина на теле'
m.CATEGORY_TYPE_VANITY_PET = 'Питомец'
m.CATEGORY_TYPE_MOUNT = 'Скакун'
m.GEAR_APPEARANCE = 'Облик (оружие)'

-- Подписи
m.STYLE = 'Стиль'
m.OUTFIT = 'Наряд'
m.TITLE = 'Титул'
m.HOTKEY = 'Клавиша'
m.MEMENTO = 'Сувенир'
m.REVEAL = 'Задержка'
m.COMPANION = 'Компаньон'
m.COMPANION_NONE = '- Нет -'
m.COMPANION_KEEP = '- Не трогать -'
m.WEAPONS = 'Оружие'
m.APPLY_SECTION = 'ПРИ ПРИМЕНЕНИИ'
m.OPTIONS = 'Настройки'

-- Выпадающие списки
m.SLOT = 'Слот'
m.HOTKEY_NONE = '- Нет -'
m.MEMENTO_NONE = '- Нет -'
m.NO_OUTFIT = '- Без наряда -'
m.NO_TITLE = '- Без титула -'
m.WEAPON_UNEQUIP = 'Пустой слот (снимется)'
m.WEAPON_NONE = 'Оставить текущее оружие (этот слот не меняется)'

-- Настройки
m.OPT_SHOW_BUTTON = 'Показывать плавающую кнопку'
m.OPT_SHOW_DROPDOWN = 'Показывать список быстрого выбора'
m.OPT_LOCK_BUTTON = 'Зафиксировать положение кнопки'
m.OPT_PLAY_MEMENTOS = 'Проигрывать сувенир при применении стиля'
m.OPT_HIDE_ON_MENUS = 'Скрывать Stylich, когда открыто меню'
m.OPT_CLOSE_COMBAT = 'Закрывать окно при входе в бой'
m.OPT_HELP =
	"|cFFAA33Создание стиля|r\n"..
	"- Настройте облик в игре, затем нажмите «Обновить», чтобы сохранить его.\n"..
	"- Или перетащите оружие из инвентаря на слот оружия.\n"..
	"- Правый клик по слоту оружия переключает: пусто (снять) или оставить (не трогать оружие).\n"..
	"- Выберите Наряд, Титул и Сувенир входа из списков.\n\n"..
	"|cFFAA33Сувенир входа|r\n"..
	"При применении стиля проигрывается его сувенир, скрывающий изменение - новый облик появляется в конце анимации. Если сувенир ещё на перезарядке, стиль не меняется (чтобы эффект всегда срабатывал)."

-- Диалоги подтверждения
m.CONFIRM_UPDATE_TITLE = 'Обновить стиль'
m.CONFIRM_UPDATE_TEXT = "Перезаписать «<<1>>» текущим обликом?"
m.CONFIRM_DELETE_TITLE = 'Удалить стиль'
m.CONFIRM_DELETE_TEXT = "Удалить стиль «<<1>>»?"

-- Подсказки кнопок
m.TT_NEW = 'Новый стиль'
m.TT_RENAME = 'Переименовать / свойства'
m.TT_UPDATE = 'Обновить из текущего облика'
m.TT_APPLY = 'Применить стиль'
m.TT_DELETE = 'Удалить стиль'
m.TT_OPTIONS = 'Настройки'
m.TT_REVEAL = 'Задержка перед появлением нового облика под сувениром входа. Короче = быстрее раскрытие; дольше — сувенир дольше скрывает смену. Подберите под длительность сувенира.'

-- Назначения клавиш
m.BIND_SHOW = 'Открыть/закрыть окно'
m.BIND_SLOT = 'Применить стиль слота'

-- Сообщения в чате
m.MSG_NO_STYLE_SLOT = "Stylich: слоту <<1>> не назначен стиль."
m.MSG_CREATED = "Stylich: «<<1>>» создан."
m.MSG_MEMENTO_COOLDOWN = "Stylich: сувенир входа не готов (<<1>>с) - стиль не применён."
m.MSG_WEAPON_NOT_FOUND = "Stylich: оружие не найдено: <<1>>."
m.MSG_WEAPON_DUP = "Stylich: это оружие уже назначено другому слоту."
m.MSG_WEAPON_ONLY = "Stylich: сюда можно поместить только оружие."
m.MSG_NO_SPACE = "Stylich: недостаточно места в сумке, чтобы снять <<1>>."
m.MSG_COMBAT_WEAPONS = "Stylich: нельзя менять оружие в бою."
