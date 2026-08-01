--[[
  This file is part of Awesome Events.

  Author: Memoraike
  Filename: ru.lua

  Copyright (c) 2018-2024 by Martin Unkel and Memoraike
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  Пожалуйста, прочтите README файл для дополнительной информации.
  ]]

---
--- Translated by: Memoraike <http://www.esoui.com/forums/member.php?u=32546>
---

--main
SafeAddString(SI_AWEVS_ALL_MODS_DISABLED, "Нет активных модулей", 1)
SafeAddString(SI_AWEVS_DESCRIPTION, "Оставайся в курсе событий с Awesome Events! Получай уведомления о различных игровых событиях прямо во время игры. Исследуй различные модули и настройки, чтобы настроить игровой процесс под себя. Не забудь заглянуть во все доступные опции на странице настроек. Твои отзывы очень важны! Если у тебя есть предложения, вклад в переводы или сообщения об ошибках, не стесняйся обращаться. Связаться со мной можно через страницу дополнений на https://esoui.com.", 1)

--debug
SafeAddString(SI_AWEVS_DEBUG_NO_EVENT_CALLBACKS, "Нет обратных вызовов, прослушиватель событий удален!", 1)
SafeAddString(SI_AWEVS_DEBUG_ENABLED, "|c82D482Включено", 1)
SafeAddString(SI_AWEVS_DEBUG_DISABLED, "|cD49682Отключено", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_EVENT_INVALID, "Ошибочный объект события!\nОжидалось: event={eventCode=EVENT_...,callback=function() ... end}!\nЭти ключи обязательны!\nКлючи:", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_OPTION_INVALID, "Ошибочный объект опций!\nОжидалось: option={type='',name='',tooltip='',default=...}!\nЭти ключи обязательны!\nКлючи:", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_NOT_FOUND, "Модуль не найден!", 1)
SafeAddString(SI_AWEVS_DEBUG_MODULE_NO_TIMER, "Этот модуль не прослушивает событие EVENT_TIMER или Вы пытаетесь вызвать функцию таймера в Enable функции, извините, это не возможно. Таймер не может быть использован.", 1)
SafeAddString(SI_AWEVS_DEBUG_COMMAND_USAGE, "Используйте: /aedebug mod_id (on\off)", 1)

--appearance
SafeAddString(SI_AWEVS_APPEARANCE, "Внешний вид", 1)
SafeAddString(SI_AWEVS_APPEARANCE_MOVABLE, "Динамическое окно", 1)
SafeAddString(SI_AWEVS_APPEARANCE_MOVABLE_HINT, "Позволяет перетаскивать окно.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN, "Выравнивание текста", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_HINT, "Расположение всего текста в окне аддона.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT, "По левому краю", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER,"По центру", 1)
SafeAddString(SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT, "По правому краю", 1)
SafeAddString(SI_AWEVS_APPEARANCE_UISCALE, "Масштаб окна", 1)
SafeAddString(SI_AWEVS_APPEARANCE_UISCALE_HINT, "Масшатабирует окно и его содержимое.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA, "Прозрачность фона", 1)
SafeAddString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA_HINT, "Задайте степень прозрачности фона.",1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE,"Цвет доступности", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE_HINT, "Изменить цвет текста сообщений о доступности(?).", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_HINT,"Цвет уведомлений", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_HINT_HINT, "Изменить цвет текста уведомлений.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_WARNING,"Цвет предупреждений", 1)
SafeAddString(SI_AWEVS_APPEARANCE_COLOR_WARNING_HINT, "Изменить цвет текста предупреждений.", 1)
SafeAddString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT, "Hint: No module enabled", 1)
SafeAddString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT_HINT, "Show a message in the awesome events window if all modules are disabled.", 1)

--import
SafeAddString(SI_AWEVS_IMPORT, "Импорт настроек", 1)
SafeAddString(SI_AWEVS_IMPORT_DESCRIPTION, "Заменить Ваши настройки настройками другого персонажа.", 1)
SafeAddString(SI_AWEVS_IMPORT_CHARACTER_LABEL, "Импорт из", 1)
SafeAddString(SI_AWEVS_IMPORT_CHARACTER_SELECT, " - Выбрать персонажа -", 1)
SafeAddString(SI_AWEVS_IMPORT_BUTTON, "Импорт", 1)

--module-all
SafeAddString(SI_AWEMOD_SHOW, "Отображать", 1)
SafeAddString(SI_AWEMOD_SHOW_HINT, "Показывать или скрывать все уведомления этого молуля", 1)
SafeAddString(SI_AWEMOD_SPACING_POSITION, "Расположение отступа", 1)
SafeAddString(SI_AWEMOD_SPACING_POSITION_HINT, "Установить расположение отступа между уведомлением модуля и другими уведомлениями.", 1)
SafeAddString(SI_AWEMOD_SPACING_BOTTOM, "Снизу", 1)
SafeAddString(SI_AWEMOD_SPACING_BOTH, "Сверху и снизу", 1)
SafeAddString(SI_AWEMOD_SPACING_TOP, "Сверху", 1)
SafeAddString(SI_AWEMOD_SPACING, "Отступ", 1)
SafeAddString(SI_AWEMOD_SPACING_HINT, "Установить отступ между уведомлением модуля и другими уведомлениями.", 1)
SafeAddString(SI_AWEMOD_FONTSIZE, "Размер шрифта", 1)
SafeAddString(SI_AWEMOD_FONTSIZE_HINT, "Установить размер шрифта для уведомления.", 1)

--module-bufffood
SafeAddString(SI_AWEMOD_BUFFFOOD, "Бафф еды", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HINT, "Получение обратного отчета окончания баффа или предупреждение о его отсутствии.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER_LABEL, "Эффект <<C:1>> закончится через ", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_READY_LABEL, "Бафф от еды отсутствует!", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER, "Запустить тамер баффа еды (минуты)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_TIMER_HINT, "Показать обратный отчет, если бафф от еды заканчивается через установленное время.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT, "Бафф еды (варн)", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT_HINT, "Если в бою у вас не будет баффа от еды, появится мигающее предупреждение.", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT, "Скрыть вне боя", 1)
SafeAddString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT_HINT, "Если у Вас не активного баффа от еды и Вы не вне боя более 5 минут, то предупреждение (Бафф от еды отсутствует!) будет скрыто пока Вы снова не окажетесь в бою или не поедите.", 1)

--module-clock
SafeAddString(SI_AWEMOD_CLOCK, "Время и дата", 1)
SafeAddString(SI_AWEMOD_CLOCK_HINT, "Отображать текущее системное время.", 1)
--SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT, "Date format", 1)
--SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_HINT, "Choose your prefered date format.", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_DAY, "день", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_MONTH, "месяц", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_YEAR, "год", 1)
SafeAddString(SI_AWEMOD_CLOCK_DATEFORMAT_DEFAULT, "day.month.year", 1) -- do not translate the words, just change the order or the seperator chars between
SafeAddString(SI_AWEMOD_CLOCK_STYLE, "Appearance", 1)
--SafeAddString(SI_AWEMOD_CLOCK_STYLE_HINT, "Choose your preferred appearance.", 1)
--SafeAddString(SI_AWEMOD_CLOCK_STYLE_TIME, "Time only", 1)
--SafeAddString(SI_AWEMOD_CLOCK_STYLE_DATETIME_SHORT, "Date & Time (1-line)", 1)
--SafeAddString(SI_AWEMOD_CLOCK_STYLE_DATETIME_LONG, "Date & Time (2-lines)", 1)
SafeAddString(SI_AWEMOD_CLOCK_FORMAT, "24 формат времени", 1)
SafeAddString(SI_AWEMOD_CLOCK_FORMAT_HINT, "Отображать время в 24 формате или в 12 формате.", 1)

--module-crafting
SafeAddString(SI_AWEMOD_CRAFTING, "Исследования", 1)
SafeAddString(SI_AWEMOD_CRAFTING_HINT, "Отображать таймер исследования или же уведомление о кол-ве возможных исследований.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_AVAILABLE_LABEL, "возможно исследовать", 1)
SafeAddString(SI_AWEMOD_CRAFTING_BLACKSMITHING, "Таймер для кузнечного дела", 1)
SafeAddString(SI_AWEMOD_CRAFTING_BLACKSMITHING_HINT, "Отображать таймер, когда исследования кузнечного дела почти завершены или есть возможность исследовать, отрегулируйте значение ниже.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_CLOTHING, "Таймер для портняжного дела", 1)
SafeAddString(SI_AWEMOD_CRAFTING_CLOTHING_HINT, "Отображать таймер, когда исследования портняжного дела почти завершены или есть возможность исследовать, отрегулируйте значение ниже.", 1)
--SafeAddString(SI_AWEMOD_CRAFTING_JEWELRY, "Show timer for Jewelry Crafting", 1)
--SafeAddString(SI_AWEMOD_CRAFTING_JEWELRY_HINT, "Display a countdown timer when your Jewelry Crafting research is nearly complete. Adjust the threshold below.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_WOODWORKING, "Таймер для столярного дела", 1)
SafeAddString(SI_AWEMOD_CRAFTING_WOODWORKING_HINT, "Отображать таймер, когда исследования столярного дела почти завершены или есть возможность исследовать, отрегулируйте значение ниже.", 1)
SafeAddString(SI_AWEMOD_CRAFTING_TIMER, "Предупреждающий таймер исследования", 1)
SafeAddString(SI_AWEMOD_CRAFTING_TIMER_HINT, "Отображать таймер, предупреждающий о скором окончании исследования.", 1)

--module-durability
SafeAddString(SI_AWEMOD_DURABILITY, "Прочность доспехов", 1)
SafeAddString(SI_AWEMOD_DURABILITY_LABEL, "Прочность доспехов", 1)
SafeAddString(SI_AWEMOD_DURABILITY_HINT, "Отображать уведомление, прежде чем доспехи будут сломаны.", 1)
SafeAddString(SI_AWEMOD_DURABILITY_INFO, "Прочность доспехов(|cFFFF60Инфо|r) %", 1)
SafeAddString(SI_AWEMOD_DURABILITY_INFO_HINT, "Когда прочность доспехов будет меньше или равна указаному значению, то появится уведомление.", 1)
SafeAddString(SI_AWEMOD_DURABILITY_WARNING, "Прочность доспехов(|cFF6060Внимание|r) %", 1)
SafeAddString(SI_AWEMOD_DURABILITY_WARNING_HINT, "Когда прочность доспехов будет меньше или равна указаному значению, то появится предупреждение.", 1)

--module-fencing
SafeAddString(SI_AWEMOD_FENCING, "Воровство", 1)
SafeAddString(SI_AWEMOD_FENCING_HINT, "Отображать уведомление, если количество продаж у скупщика превысит указанные значения или же отображать время до перезарядки скупщика.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_LABEL, "Еще можно продать", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_LABEL, "Еще можно отмыть", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS, "Продано вещей", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_HINT, "Отображать уведомление, когда количество доступных продаж будет ниже установленного значения.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_INFO, "Продано вещей(|cFFFF60Инфо|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_INFO_HINT,"Когда доступное кол-во проданных товаров станет меньше или равно указаному значению, то появится уведомление.", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_WARNING, "Продано вещей(|cFF6060Внимание|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_SELLS_WARNING_HINT,"Когда доступное кол-во проданных товаров станет меньше или равно указаному значению, то появится предупреждение.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS, "Отмыто вещей", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_HINT, "Отображать уведомление, когда доступное количество отмытых вещей окажется ниже установленных значений.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_INFO,"Отмыто вещей(|cFFFF60Инфо|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_INFO_HINT,"Когда доступное кол-во отмытых вещей станет меньше или равно указаному значению, то появится уведомление.", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_WARNING,"Отмыто вещей(|cFF6060Внимание|r)", 1)
SafeAddString(SI_AWEMOD_FENCING_LAUNDERS_WARNING_HINT,"Когда доступное кол-во отмытых вещей станет меньше или равно указаному значению, то появится предупреждение.", 1)

--module-inventory
SafeAddString(SI_AWEMOD_INVENTORY, "Инвентарь", 1)
SafeAddString(SI_AWEMOD_INVENTORY_HINT, "Показывать информацию о текущей заполненности инвентаря, количестве Вашего золота и/или получение уведомления об отсутствии места в инвентаре.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW, "Показать предупреждение о нехватке места", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_HINT, "Получить уведомление прежде, чем место в инвентаре кончится.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_INFO, "Доступно места в инвентаре(|cFFFF60Инфо|r)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_INFO_HINT, "Если в инвентаре доступно места меньше или равное указанному значению, появится уведомление.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_WARNING, "Доступно места в инвентаре(|cFF6060Внимание|r)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_WARNING_HINT,"Если в инвентаре доступно места меньше или равное указанному значению, появится предупреждение.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_LOW_LABEL, "Инвентарь (доступно)", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS, "Доп. инфо об инвентаре", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS_HINT, "Показать информацию о текущей заполненности инвентаря и банка.", 1)
SafeAddString(SI_AWEMOD_INVENTORY_DETAILS_LABEL, "<<1>>Инвентарь|r: <<2>>/<<3>> <<1>>|| Банк|r: <<4>>/<<5>>", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY, "Показать золото", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY_HINT, "Отобразить Ваше золото (банк и инвентарь).", 1)
SafeAddString(SI_AWEMOD_INVENTORY_MONEY_LABEL, "Золото|r: <<1>>k |t16:16:EsoUI/Art/currency/currency_gold.dds|t<<2[/ (+1k в банке)/ (+$dk в банке)]>>", 1)
--SafeAddString(SI_AWEMOD_INVENTORY_ADVCURRENCIES, "Show special currencies", 1)
--SafeAddString(SI_AWEMOD_INVENTORY_ADVCURRENCIES_HINT, "Show the amount of telvar stones or writ vouchers you own.", 1)
--SafeAddString(SI_AWEMOD_INVENTORY_TELVARSTONES_LABEL, "Telvar|r: <<1>> |t16:16:EsoUI/Art/currency/currency_telvar.dds|t", 1)
--SafeAddString(SI_AWEMOD_INVENTORY_WRITVOUCHER_LABEL, "Writs:|r <<1>> |t16:16:EsoUI/Art/currency/currency_writvoucher.dds|t", 1)

--module-mails
SafeAddString(SI_AWEMOD_MAILS, "Почта", 1)
SafeAddString(SI_AWEMOD_MAILS_HINT, "Отображать уведомление, если есть непрочитанные письма.", 1)
SafeAddString(SI_AWEMOD_MAILS_LABEL, "Непрочитанные письма", 1)

--module-mount
SafeAddString(SI_AWEMOD_MOUNT, "Ездовой питомец", 1)
SafeAddString(SI_AWEMOD_MOUNT_HINT, "Отображение таймера с обратным отчетом тренировки ездового питомца или отображение о возможности его тренировки.", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER_LABEL, "Тренировка окончится через", 1)
SafeAddString(SI_AWEMOD_MOUNT_READY_LABEL, "Ездовой питомец готов к тренировке", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER, "Запустить таймер тренировки (минуты)", 1)
SafeAddString(SI_AWEMOD_MOUNT_TIMER_HINT, "Отображение таймера обратного отчета, если ездовой питомец может быть тренирован в течение указаного времени.", 1)

--module-repairkits
--SafeAddString(SI_AWEMOD_REPAIRKITS, "Repair Kits", 1)
--SafeAddString(SI_AWEMOD_REPAIRKITS_HINT, "See how many repair kits you have in your inventory.", 1)
--SafeAddString(SI_AWEMOD_REPAIRKITS_LABEL, "Repair Kits|r: |t16:16:EsoUI/Art/icons/store_repairkit_002.dds|t <<1[None/1 kit/$d kits]>>", 1)

--module-shadowysupplier
--SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER, "Shadowy Supplier (Passive Skill)", 1)
--SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_HINT, "The shadowy supplier is a passive skill from the dark brotherhoods skill line. Get an information and timer about availability of Dark Brotherhood`s Shadowy Supplier (passive ability).", 1)
--SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER, "Supplier cooldown timer (minutes)", 1)
--SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER_HINT, "Will show the cooldown timer if Shadowy Supplier is available within the number of minutes below.", 1)
--SafeAddString(SI_AWEMOD_SHADOWYSUPPLIER_AVAILABLE_LABEL, "Available", 1)

--module-skills
SafeAddString(SI_AWEMOD_SKILLS, "Атрибуты и очки умений", 1)
SafeAddString(SI_AWEMOD_SKILLS_HINT, "Отображение уведомления, когда у Вас есть неиспользованные атрибуты или очки умений.", 1)
SafeAddString(SI_AWEMOD_SKILLS_ATTRIBUTES_LABEL, "Атрибуты", 1)
SafeAddString(SI_AWEMOD_SKILLS_CHAMPIONPOINTS_LABEL, "Очки чемпиона", 1)
SafeAddString(SI_AWEMOD_SKILLS_SKILLS_LABEL, "Умения", 1)

--module-skyshards
SafeAddString(SI_AWEMOD_SKYSHARDS, "Небесные осколки", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_HINT, "Отображать уведомление о том, как много осколков Вам нужно собрать для получения очка умения.", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING_LABEL, "Осталось осколков", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING, "Кол-во нехватающих осколков", 1)
SafeAddString(SI_AWEMOD_SKYSHARDS_REMAINING_HINT, "Отображать уведомление, если указанное значение равно кол-ву нехватающих осколков.", 1)

--module-soulgems
SafeAddString(SI_AWEMOD_SOULGEMS, "Камни душ", 1)
SafeAddString(SI_AWEMOD_SOULGEMS_HINT, "Показывает, как много камней душ, заполненных и пустых, есть у Вас.", 1)
SafeAddString(SI_AWEMOD_SOULGEMS_LABEL, "Камни душ|r: <<1>> |t16:16:EsoUI/Art/icons/soulgem_006_filled.dds|t <<2[/(1 не заполнено)/($d не заполнено)]>>", 1)

--module-weaponchrage
SafeAddString(SI_AWEMOD_WEAPONCHARGE, "Заряд оружия", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_HINT, "Отображать уведомление, прежде чем заряд оружия будет исчерпан", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_INFO, "Заряд оружия (|cFFFF60Инфо|r) %", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_INFO_HINT, "Если заряд экипированного оружия меньше или равен этому значению, то появится уведомление.", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_WARNING, "Заряд оружия (|cFF6060Внимание|r) %", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_WARNING_HINT, "Если заряд экипированного оружия меньше или равен этому значению, то появится предупреждение.", 1)
SafeAddString(SI_AWEMOD_WEAPONCHARGE_SET_LABEL, "Панель навыков", 1)