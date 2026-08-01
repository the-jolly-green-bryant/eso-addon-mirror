local localization_strings = {
    SI_NBUI_ADDON_NAME          = "Notebook",
    SI_NBUI_ADDONOPTIONS_NAME   = "Notebook Options",
    SI_NBUI_AUTHOR              = "phuein & Bloodspill",

    -- Settings Panel
    SI_NBUI_DESCRIPTION_INFO = "Виртуальная записная книга.",

    SI_NBUI_HEADER_BOOK         = "Книга",
    SI_NBUI_HEADER_THEME        = "Цвет",
    SI_NBUI_HEADER_INTERACTIVE  = "Интерактивный",
    SI_NBUI_HEADER_EDITMODE     = "Форматированный дисплей",

    SI_NBUI_SHOWTITLE_NAME      = "Показать заголовок",
    SI_NBUI_SHOWTITLE_TOOLTIP   = "Отображает заголовок в книге.",

    SI_NBUI_TITLE_NAME          = "Название заголовка",
    SI_NBUI_TITLE_TOOLTIP       = "Изменяет название заголовка в книге.",

    SI_NBUI_TEXTURE_NAME        = "Текстура книги",
    SI_NBUI_TEXTURE_TOOLTIP     = "Различный варианты текстур внешнего вида.",

    SI_NBUI_COLOR_NAME          = "Цвет книги",
    SI_NBUI_COLOR_TOOLTIP       = "Изменяет цвет книги.",

    SI_NBUI_NEWPAGETITLE_NAME       = "Заголовок новой страницы по умолчанию",
    SI_NBUI_NEWPAGETITLE_TOOLTIP    = "Устанавливает заголовок по умолчанию для новых страниц. Очистите его для значения по времени и дате.",

    SI_NBUI_ACCOUNTWIDE_NAME        = "Книга для всей учетной записи",
    SI_NBUI_ACCOUNTWIDE_MAINTEXT    = "Это немедленно перезагрузит интерфейс! Вы хотите продолжить?",
    SI_NBUI_ACCOUNTWIDE_TOOLTIP     = "Одна книга для всех персонажей на вашем аккаунте.",

    SI_NBUI_ACCOUNTDELETE           = "Перезаписать всю учетную запись",
    SI_NBUI_ACCOUNTDELETE_TOOLTIP   = "Перезаписывает книгу всей учетной записи, страницами текущего персонажа.",

    SI_NBUI_DIALOG          = "Диалоги подтверждения",
    SI_NBUI_DIALOG_TOOLTIP  = "Отключает всплывающие диалоги подтверждений.",

    SI_NBUI_LOCK_NAME       = "Закрепить позицию",
    SI_NBUI_LOCK_TOOLTIP    = "Это позволяет закрепить книгу на месте, чтобы его нельзя было перемещать.",

    SI_NBUI_ONTOP_NAME      = "Показать сверху",
    SI_NBUI_ONTOP_TOOLTIP   = "Показать книгу поверх других элементов пользовательского интерфейса, чтобы было проще делать записи.",

    SI_NBUI_BUTTON_NAME     = "Показать кнопку чата",
    SI_NBUI_BUTTON_TOOLTIP  = "Добавляет кнопку в окне чата, чтобы открыть / закрыть книгу.",

    SI_NBUI_OFFSETMAX_NAME      = "Кнопка развернутого развернутого чата",
    SI_NBUI_OFFSETMAX_TOOLTIP   = "Смещает кнопку в развернутом окне чата.",

    SI_NBUI_OFFSETMIN_NAME      = "Кнопка минимизированного смещения чата",
    SI_NBUI_OFFSETMIN_TOOLTIP   = "Смещает кнопку в свернутом окне чата.",

    SI_NBUI_FORMATTEDMODE_NAME      = "Режим форматированного текста",
    SI_NBUI_FORMATTEDMODE_TOOLTIP   = "Переключить, доступен ли вообще Форматированный режим (цвета, изображения).",

    SI_NBUI_EDITMODE_HOVER_NAME     = "Войдите в режим редактирования при наведении",
    SI_NBUI_EDITMODE_HOVER_TOOLTIP  = "Переключиться в режим редактирования страницы при наведении курсора мыши на страницу.",

    SI_NBUI_EDITMODE_CLICK_NAME     = "Войдите в режим редактирования при нажатии",
    SI_NBUI_EDITMODE_CLICK_TOOLTIP  = "Переключиться в режим редактирования страницы при нажатии на страницу.",

    SI_NBUI_LEAVEEDITMODE_FOCUS_NAME    = "Выйти из режима редактирования в фокусе",
    SI_NBUI_LEAVEEDITMODE_FOCUS_TOOLTIP = "Выйти из режима редактирования, когда страница теряет фокус (щелчок за пределами нее.)",

    SI_NBUI_LEAVEEDITMODE_EXIT_NAME     = "Выйти из режима редактирования при выходе",
    SI_NBUI_LEAVEEDITMODE_EXIT_TOOLTIP  = "Выйти из режима редактирования, когда мышь покидает (выходит из) страницу.",

    SI_NBUI_DBLCLICKPAGE_NAME       = "Двойной щелчок, чтобы выделить все",
    SI_NBUI_DBLCLICKPAGE_TOOLTIP    = "Выделяет весь текст страницы, а не слово, при двойном щелчке.",

    SI_NBUI_ACTIVELINKS_NAME        = "Активные ссылки",
    SI_NBUI_ACTIVELINKS_TOOLTIP     = "Являются ли ссылки кликабельными, например ссылки на элементы.",

    SI_NBUI_COPYMAIL_NAME       = "Записать в книгу",
    SI_NBUI_COPYMAIL_TOOLTIP    = "Показать привязку клавиш для копирования почты на новую страницу или обновления существующей.",

    SI_NBUI_MARKUP_NAME = "Переключить разметку",

    SI_NBUI_EMOTEREAD_NAME      = "Эмоция чтения при открытии",
    SI_NBUI_EMOTEREAD_TOOLTIP   = "Включает эмоцию чтения при открытии книги.",

    SI_NBUI_EMOTEIDLE_NAME      = "Эмоция чтения при закрытии",
    SI_NBUI_EMOTEIDLE_TOOLTIP   = "Отключает эмоцию чтения после закрытия книги.",

    SI_NBUI_SELECTLINE_NAME     = "Тройной щелчок, чтобы выделить все",
    SI_NBUI_SELECTLINE_TOOLTIP  = "Выделяет весь текст страницы, при тройном щелчке.",

    SI_NBUI_SELECTCOLOR_NAME    = "Цвет выделения текста",
    SI_NBUI_SELECTCOLOR_TOOLTIP = "Изменяет цвет при выделение текста.",

    SI_NBUI_TEXTCOLOR_NAME      = "Цвет текста",
    SI_NBUI_TEXTCOLOR_TOOLTIP   = "Изменяет цвет текста заголовка вашей записной книжки, заголовка страницы и содержимого.",

    SI_NBUI_WARNING = "Этот параметр должен быть применен и приведет к экрану загрузки.",

    -- UI Panel
    SI_NBUI_CLOSEBUTTON_TOOLTIP = "Закрыть книгу.",

    SI_NBUI_RUNBUTTON_TOOLTIP = "Запустить эту страницу как скрипт Lua.",

    SI_NBUI_DELETEBUTTON_TITLE      = "Удалить страницу",
    SI_NBUI_DELETEBUTTON_MAINTEXT   = "Вы хотите удалить страницу?",
    SI_NBUI_DELETEBUTTON_TOOLTIP    = "Удалить страницу.",

    SI_NBUI_NEWBUTTON_TITLE         = "Новая страница",
    SI_NBUI_NEWBUTTON_MAINTEXT      = "Хотите создать новую страницу?",
    SI_NBUI_NEWBUTTON_TOOLTIP       = "Создать новую страницу.",

    SI_NBUI_SAVEBUTTON_TITLE        = "Сохранить страницу",
    SI_NBUI_SAVEBUTTON_MAINTEXT     = "Хотите сохранить изменения, сделанные на странице?",
    SI_NBUI_SAVEBUTTON_TOOLTIP      = "Сохранить изменения, сделанные на этой странице.",

    SI_NBUI_UNDOPAGE_TITLE      = "Отменить страницу",
    SI_NBUI_UNDOPAGE_MAINTEXT   = "Хотите отменить все изменения, внесенные на этой странице? Она вернется к последнему сохранению.",
    SI_NBUI_UNDOBUTTON_TOOLTIP  = "Отменить изменения, сделанные на этой странице.",

    SI_NBUI_MOVEPAGEUPBUTTON_TOOLTIP = "Переместить страницу вверх.",

    SI_NBUI_MOVEPAGEDOWNBUTTON_TOOLTIP = "Переместить страницу вниз.",

    SI_NBUI_PREVIEWBUTTON_TOOLTIP = "Предварительный просмотр этой страницы путем рендеринга цветов, отступов и текстур.",

    SI_NBUI_CONTEXT_RANDOMLINE      = "Копировать случайную строку",
    SI_NBUI_CONTEXT_SENDASMAIL      = "Отправить как письмо",
    SI_NBUI_CONTEXT_COPYFROMMAIL    = "Копировать из почты",

    SI_NBUI_YES_LABEL   = "Да",
    SI_NBUI_NO_LABEL    = "Нет",

    SI_NBUI_NB1INFORMATION_TOOLTIP = "|c00FF00/nb|r открыть/закрыть книгу.\n|c00FF00/nbs|r открыть/закрыть настройки.\n\n|c00FF00Tip:|r Переключение страниц отменяют ваши изменения.",

    SI_NBUI_NB1KEYBIND_LABEL = "Записная книга",

    SI_NBUI_ERROR_INBOXSELECT = "|cFFFFFFNOTEBOOK:|r Пожалуйста, выберите почтовое сообщение.",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end