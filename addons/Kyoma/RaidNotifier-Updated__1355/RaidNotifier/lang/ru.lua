local L = {}

L.Description                           			= "Выводит на экран предупреждения о разаличных событиях в Испытаниях. Только на ветеранской сложности!"

--------------------------------
----     General Stuff      ----
--------------------------------
L.Settings_General_Header                       	= "Общие"
-- Settings
L.Settings_General_Notifications_Showcase           = "Notifications showcase"
L.Settings_General_Bufffood_Reminder            	= "Напоминание о еде"
L.Settings_General_Bufffood_Reminder_TT         	= "Напоминает вам, когда вы начинаете испытание без баффа еды \nИЛИ\n ваш бафф еды истекает во время прохождения Испытания (см. интервал)"
L.Settings_General_Bufffood_Reminder_Interval		= "Интервал напоминания о еде"
L.Settings_General_Bufffood_Reminder_Interval_TT	= "Здесь вы можете задать интервал частоты, с которой RaidNotifier будет сообщать вам о вашем баффе еды.\n\nКаждые X секунд. \n\nНачиная с момента, когда до истечения текущего баффа еды остаётся 10 минут или менее."
L.Settings_General_Vanity_Pets						= "Отключить пэтов во время Испытания"
L.Settings_General_Vanity_Pets_TT					= "Отключает ваших пэтов при начале Испытания. Как только вы закончите или выйдете из Испытания, пэты включатся снова."
L.Settings_General_No_Assistants					= "Отключить помощников при начале битвы"
L.Settings_General_No_Assistants_TT					= "Работает только в Испытаниях и НЕ запрещает их призыв."
L.Settings_General_Center_Screen_Announce    		= "Предупреждения по центру экрана"
L.Settings_General_Center_Screen_Announce_TT		= "Использует игровую систему предупреждений на экране. Альтернативынй и более простой способ отображения предупреждений Raid Notifier."
L.Settings_General_NotificationsScale               = "Notifications Scale"
L.Settings_General_NotificationsScale_TT            = "The scale of the notifications and minor countdowns display"
L.Settings_General_UseDisplayName                   = "Использовать UserID"
L.Settings_General_UseDisplayName_TT                = "Использовать UserID в оповещениях вместо имени персонажа."
L.Settings_General_Unlock_Status_Icon               = "Разблокировать статус-значок"
L.Settings_General_Unlock_Status_Icon_TT            = "Когда включено, показывает на экране статус-значок, который может быть перемещён."
L.Settings_General_Default_Sound                	= "Звук по умолчанию"
L.Settings_General_Default_Sound_TT             	= "Звук по умолчанию для этого предупреждения."
-- Choices
L.Settings_General_Choices_Off       				= "Выкл."
L.Settings_General_Choices_Full      				= "Полный"
L.Settings_General_Choices_Normal    				= "Нормальный"
L.Settings_General_Choices_Minimal   				= "Минимальный"
L.Settings_General_Choices_Self      				= "На себе"
L.Settings_General_Choices_Near      				= "По близости"
L.Settings_General_Choices_All       				= "Все"
L.Settings_General_Choices_Always    				= "Всегда"
L.Settings_General_Choices_Other     				= "Другое"
L.Settings_General_Choices_Others                   = "Others"
L.Settings_General_Choices_Inverted             	= "Инвертированно"
L.Settings_General_Choices_Small_Announcement       = "Маленький (obsolete)"
L.Settings_General_Choices_Large_Announcement       = "Большой (obsolete)"
L.Settings_General_Choices_Major_Announcement       = "Огромный (obsolete)"
L.Settings_General_Choices_1s                       = "1.0s"
L.Settings_General_Choices_500ms                    = "0.5s"
L.Settings_General_Choices_200ms                    = "0.2s"
L.Settings_General_Choices_Custom                   = "Custom"
L.Settings_General_Choices_Custom_Announcement      = "Настраиваемый"
L.Settings_General_Choices_SelfAndTanks             = "Self and tanks"
L.Settings_General_Choices_OnlyChaurusTotem         = "Only Chaurus" -- Specific for Kyne's Aegis
L.Settings_DreadsailReef_Choices_OnlyFireDome       = "Only Fire Dome"
L.Settings_DreadsailReef_Choices_OnlyIceDome        = "Only Ice Dome"
-- Alerts
L.Alerts_General_No_Bufffood        				= "У вас нет БАФФА ЕДЫ!"
L.Alerts_General_Bufffood_Minutes   				= "Ваш бафф еды '<<1>>' истекает через |cbd0000<<2>>|r мин.!"
-- Bindings
L.Binding_ToggleUltimateExchange                    = "Вкл. обмен данными абсолютной способности"


--------------------------------
----    Ultimate Exchange   ----
--------------------------------
L.Settings_Ultimate_Header                           = "Абсолютная способность (бета)"
L.Settings_Ultimate_Description                      = "Эта функция позволяет вам рассылать данные о вашей абсолютной способности вашим товарища, так они смогут увидеть, как скоро вы сможете применить её. Используется стоимость с учётом всех ваших снижений стоимости, откуда бы они ни шли, от комплектов или пассивных способностей."
-- Settings
L.Settings_Ultimate_Enabled                          = "Включено"
L.Settings_Ultimate_Enabled_TT                       = "Включение раздаёт и принимает значение заряда абсолютной способности. Всегда отключено за пределами испытаний."
L.Settings_Ultimate_Hidden                           = "Скрыто"
L.Settings_Ultimate_Hidden_TT                        = "Скрывает окно абсолютной способности, но не отключает сам функционал."
L.Settings_Ultimate_UseColor                         = "Использовать цвета"
L.Settings_Ultimate_UseColor_TT                      = "Придаёт абсолютной способности один из цветов в зависимости от порога на 80 и 100 процентах заряда."
L.Settings_Ultimate_UseDisplayName                   = "Показывать имя игрока"
L.Settings_Ultimate_UseDisplayName_TT                = "Показывает имя игрока в окне абсолютной способности вместо имени персонажа."
L.Settings_Ultimate_ShowHealers                      = "Целители"
L.Settings_Ultimate_ShowHealers_TT                   = "Показывает абсолютную способность членов группы с ролью Целителя."
L.Settings_Ultimate_ShowTanks                        = "Танки"
L.Settings_Ultimate_ShowTanks_TT                     = "Показывает абсолютную способность членов группы с ролью Танка."
L.Settings_Ultimate_ShowDps                          = "DD"
L.Settings_Ultimate_ShowDps_TT                       = "Показывает абсолютную способность членов группы с ролью DD."
L.Settings_Ultimate_TargetUlti                       = "Абсолютная способность"
L.Settings_Ultimate_TargetUlti_TT                    = "Какую абсолютную способность использовать для показа процена заряда другим игрокам."
L.Settings_Ultimate_OverrideCost                     = "Переписать стоимость"
L.Settings_Ultimate_OverrideCost_TT                  = "Использовать это значение при отправке значения стоимости другим игрокам. Значение 0 отключает перезапись."


--------------------------------
----        Profiles        ----
--------------------------------
L.Settings_Profile_Header                            = "Профили"
L.Settings_Profile_Description                       = "Настройками профилей можно управлять отсюда, включая настройку на весь аккаунт, которая применит одинаковые настройки ко ВСЕМ персонажам на этом аккаунте. Из-за постоянно характера данной настройки, управление должно быть сначала включено галочкой ниже этой панели."
L.Settings_Profile_UseGlobal                         = "Использовать профиль на аккаунт"
L.Settings_Profile_UseGlobal_Warning                 = "Переключение между локальным и глобальным профилями вызовет перезагрузку интерфейса."
L.Settings_Profile_Copy                              = "Выберите профиль для копирования"
L.Settings_Profile_Copy_TT                           = "Выберите профиль для копирования его настроек в активный профиль. Активный профиль - профиль персонажа, которым вы вошли или глобальный профиль на весь аккаунт, если включено. Существующий настройки профиля буду навсегда перезаписано.\n\nЭто действие невозможно отменить!"
L.Settings_Profile_CopyButton                        = "Копировать профиль"
L.Settings_Profile_CopyButton_Warning                = "Копирование профиля перезагрузит интерфейс."
L.Settings_Profile_CopyCannotCopy                    = "Невозможно скопировать данный профиль. Пожалуйста, попробуйте снова или выберите другой профиль."
L.Settings_Profile_Delete                            = "Выберите профиль для удаления"
L.Settings_Profile_Delete_TT                         = "Выберите профиль для удаления его настроек из базы данных. Если вы зайдёте этим персонажем позже и вы не используете профиль на аккаунт, будет создан новый профиль с настройками по умолчанию.\n\nУдаление профиля невозможно отменить!"
L.Settings_Profile_DeleteButton                      = "Удалить профиль"
L.Settings_Profile_Guard                             = "Включить управление профилями"


--------------------------------
----       Countdowns       ----
--------------------------------
L.Settings_Countdown_Header                          = "Отсчёты"
L.Settings_Countdown_Description                     = "Изменяет вид и поведение наших счётчиков."
L.Settings_Countdown_TimerScale                      = "Размер таймера"
L.Settings_Countdown_TimerScale_TT                   = "Размер отображаемого таймера"
L.Settings_Countdown_TextScale                       = "Размер текста"
L.Settings_Countdown_TextScale_TT                    = "Размер отображаемого текста"
L.Settings_Countdown_TimerPrecise                    = "Timer precise"
L.Settings_Countdown_TimerPrecise_TT                    = "Set timer precise for countdown"
L.Settings_Countdown_UseColors                       = "Цвета"
L.Settings_Countdown_UseColors_TT                    = "Когда включено, будут использоваться желтый/оранжевый/красный цвета в счётчике по мере его приближения к нулю."


--------------------------------
----          Trials        ----
--------------------------------
L.Settings_Trials_Header                            = "Испытания (Trials)"
L.Settings_Trials_Description                       = "Здесь вы можете настроить оповещения для каждого испытания. От простого включения и выключения до специфического звука или показа оповещения вашим товарищам."


--------------------------------
----     Hel Ra Citadel     ----
--------------------------------
L.Settings_HelRa_Header                   			= "Цитадель Хель Ра (HRC)"
-- Settings
L.Settings_HelRa_Yokeda_Meteor                      = "Йокеда: Meteor"
L.Settings_HelRa_Yokeda_Meteor_TT                   = "Предупреждает вас, когда йокеда выбирает вас своей целью атаки Meteor."
L.Settings_HelRa_Warrior_StoneForm        			= "Воин: Каменная форма"
L.Settings_HelRa_Warrior_StoneForm_TT     			= "Предупреждает вас, когда вы и/или другие будут обращены Воином в камень."
L.Settings_HelRa_Warrior_ShieldThrow      			= "Воин: Бросок щита"
L.Settings_HelRa_Warrior_ShieldThrow_TT   			= "Предупреждает вас, когда Воин готовится бросить свой щит."
--Alerts
L.Alerts_HelRa_Yokeda_Meteor                        = "|cFF0000Meteor|r нацелен на тебя. БЛОКИРУЙ!"
L.Alerts_HelRa_Yokeda_Meteor_Other                  = "|cFF0000Meteor|r нацелен на игрока |c595959<<!aC:1>>|r"
L.Alerts_HelRa_Warrior_StoneForm        			= "|c595959Каменная форма|r начинает действовать на тебя. Не используй синергии!"
L.Alerts_HelRa_Warrior_StoneForm_Other 				= "|c595959Каменная форма|r начинает действовать на |cFF0000<<!aC:1>>|r"
L.Alerts_HelRa_Warrior_ShieldThrow      			= "Начинается |cFF0000Бросок Щита|r. "


--------------------------------
----   Aetherian Archives   ----
--------------------------------
L.Settings_Archive_Header                       	= "Этерианский Архив (AA)"
-- Settings
L.Settings_Archive_StormAtro_ImpendingStorm     	= "Грозовой Атронах: Impending Storm"
L.Settings_Archive_StormAtro_ImpendingStorm_TT  	= "Предупреждает вас, когда Грозовой Атронах готовится применить AoE молниями."
L.Settings_Archive_StormAtro_LightningStorm     	= "Грозовой Атронах: Lightning Storm"
L.Settings_Archive_StormAtro_LightningStorm_TT  	= "Предупреждает вас, когда Грозовой Атронах призывает молнию с небес и вы должны укрыться от неё."
L.Settings_Archive_StoneAtro_BoulderStorm       	= "Каменный Атронах: Boulder Storm"
L.Settings_Archive_StoneAtro_BoulderStorm_TT    	= "Предупреждает вас, когда Каменный Атронах начинает швырять камни в игроков."
L.Settings_Archive_StoneAtro_BigQuake           	= "Каменный Атронах: Big Quake"
L.Settings_Archive_StoneAtro_BigQuake_TT        	= "Предупреждает вас, когда Каменный Атронах начинает бить о землю, вызывая землетрясение, наносящее урон."
L.Settings_Archive_Overcharge            			= "Мобы: Разрядник"
L.Settings_Archive_Overcharge_TT         			= "Предупреждает вас, когда Разрядник выбирает вас своей целью атаки Overcharge."
L.Settings_Archive_Call_Lightning        			= "Мобы: Call Lightning"
L.Settings_Archive_Call_Lightning_TT     			= "Предупреждает вас, когда Разрядник выбирает вас своей целью атаки Call Lightning."
-- Alerts
L.Alerts_Archive_StormAtro_ImpendingStorm 			= "Начинается |cFF0000Impending Storm|r!"
L.Alerts_Archive_StormAtro_LightningStorm 			= "Начинается |cfef92eLightning Storm|r! ИДИ В КРУГ СВЕТА!"
L.Alerts_Archive_StoneAtro_BoulderStorm 			= "Начинается |cFF0000Boulder Storm|r! Блокируй, чтобы не сбило с ног!"
L.Alerts_Archive_StoneAtro_BigQuake 				= "Начинается |cFF0000Big Quake|r!"
L.Alerts_Archive_Overcharge 						= "|c46edffOvercharge|r нацелена на тебя."
L.Alerts_Archive_Overcharge_Other 					= "|c46edffOvercharge|r нацелена на |cFF0000<<!aC:1>>|r."
L.Alerts_Archive_Call_Lightning 					= "|c46edffCall Lightning|r надвигается на тебя. ДВИГАЙСЯ!"
L.Alerts_Archive_Call_Lightning_Other 				= "|c46edffCall Lightning|r надвигается на |cFF0000<<!aC:1>>|r."


--------------------------------
----    Sanctum Ophidia     ----
--------------------------------
L.Settings_Sanctum_Header                 			= "Святилище Офидии (SO)"
-- Settings
L.Settings_Sanctum_Magicka_Detonation     			= "Змей: Magicka Detonation"
L.Settings_Sanctum_Magicka_Detonation_TT  			= "Предупреждает, когда вы получаете дебафф магической детонации во время битвы со Змеем."
L.Settings_Sanctum_Serpent_Poison         			= "Змей: Poison Phase"
L.Settings_Sanctum_Serpent_Poison_TT      			= "Предупреждает о начале ядовитой фазы во время битвы со Змеем."
L.Settings_Sanctum_Serpent_World_Shaper             = "Змей: World Shaper (Hard Mode)"
L.Settings_Sanctum_Serpent_World_Shaper_TT          = "Предупреждает, когда Змей начинает свою атаку World Shaper, запуская обратный отсчёт до её завершения."
L.Settings_Sanctum_Mantikora_Spear        			= "Мантикора: Spear"
L.Settings_Sanctum_Mantikora_Spear_TT     			= "Предупреждает вас, когда вы получаете копьё Мантикоры."
L.Settings_Sanctum_Mantikora_Quake        			= "Мантикора: Quake"
L.Settings_Sanctum_Mantikora_Quake_TT     			= "Предупреждает, когда вы набираете три землетрясения или руны на Мантикоре."
L.Settings_Sanctum_Troll_Boulder         			= "Мобы: Troll Boulder Toss"
L.Settings_Sanctum_Troll_Boulder_TT      			= "Предупреждает вас, когда тролль готовится бросить булыжник в вас."
L.Settings_Sanctum_Troll_Poison          			= "Мобы: Troll Poison"
L.Settings_Sanctum_Troll_Poison_TT       			= "Предупреждает вас, когда тролль готовится бросить в вас распространяющийся яд."
L.Settings_Sanctum_Overcharge            			= "Мобы: Разрядник"
L.Settings_Sanctum_Overcharge_TT         			= "Предупреждает вас, когда Разрядник выбирает вас своей целью атаки Overcharge."
L.Settings_Sanctum_Call_Lightning        			= "Мобы: Call Lightning"
L.Settings_Sanctum_Call_Lightning_TT     			= "Предупреждает вас, когда Разрядник выбирает вас своей целью атаки Call Lightning."
-- Alerts
L.Alerts_Sanctum_Serpent_Poison0        			= "Наступает |c39942eЯдовитая фаза|r! Соберитесь вместе!"
L.Alerts_Sanctum_Serpent_Poison1        			= "Наступает |c39942eЯдовитая фаза|r! Потом будут |ccc0000Ламии|r."
L.Alerts_Sanctum_Serpent_Poison2        			= "Наступает |c39942eЯдовитая фаза|r! Потом будет |c009933Мантикора (Л)|r." --left
L.Alerts_Sanctum_Serpent_Poison3        			= "Наступает |c39942eЯдовитая фаза|r! Потом будет |c009933Мантикора (П)|r." --right
L.Alerts_Sanctum_Serpent_Poison4        			= "Наступает |c39942eЯдовитая фаза|r! Потом будут |cff33ccЩиты|r."
L.Alerts_Sanctum_Serpent_Poison5        			= "Финальная |c39942eЯдовитая фаза|r!"
L.Alerts_Sanctum_Serpent_World_Shaper               = "|c00c832World Shaper|r через"
L.Alerts_Sanctum_Magicka_Detonation     			= "|c234afaMagicka Detonation|r! СЛЕЙ ВСЮ СВОЮ МАНУ!"
L.Alerts_Sanctum_Mantikora_Spear        			= "|ccde846Spear|r Мантикоры на тебе! УХОДИ!"
L.Alerts_Sanctum_Mantikora_Spear_Other 				= "|ccde846Spear|r Мантикоры на <<!aC:1>>! УХОДИ!"
L.Alerts_Sanctum_Mantikora_Quake        			= "|ccde846Quake|r под тобой! УБИРАЙСЯ!"
L.Alerts_Sanctum_Troll_Poison           			= "|c66ff33Troll Poison|r начинает действовать. НЕ ЗАРАЖАЙ ИМ ДРУГИХ!"
L.Alerts_Sanctum_Troll_Poison_Other    				= "|c66ff33Troll Poison|r на игроке |cFF0000<<!aC:1>>|r."
L.Alerts_Sanctum_Troll_Boulder          			= "Тролль кидает |c595959Boulder Toss|r. УВЕРНИСЬ!"
L.Alerts_Sanctum_Troll_Boulder_Other   				= "Тролль кидает |c595959Boulder Toss|r в игрока |cFF0000<<!aC:1>>|r."
L.Alerts_Sanctum_Overcharge             			= "|c46edffOvercharge|r нацелена на тебя."
L.Alerts_Sanctum_Overcharge_Other     			 	= "|c46edffOvercharge|r нацелена на игрока |cFF0000<<!aC:1>>|r."
L.Alerts_Sanctum_Call_Lightning         			= "|c46edffCall Lightning|r надвигается на тебя. ДВИГАЙСЯ!"
L.Alerts_Sanctum_Call_Lightning_Other  				= "|c46edffCall Lightning|r надвигается на |cFF0000<<!aC:1>>|r."


--------------------------------
----    Maelstrom Arena     ----
--------------------------------
L.Settings_Maelstrom_Header              			= "Вихревая Арена (MSA)"
-- Settings
L.Settings_Maelstrom_Stage7_Poison       			= "Уровень 7: Яд"
L.Settings_Maelstrom_Stage7_Poison_TT    			= "Предупреждает вас, когда вы получаете яд на уровне 7 (Vault of Umbrage)."
L.Settings_Maelstrom_Stage9_Synergy      			= "Уровень 9: Spectral Explosion (Синергия)"
L.Settings_Maelstrom_Stage9_Synergy_TT   			= "Предупреждает вас, когда вы получаете Синергию на уровне 9 (Theater of Despair) после того, как соберёте 3 (золотых) Призрака."
-- Alerts
L.Alerts_Maelstrom_Stage7_Poison 					= "|c39942eЗаражён ядом|r! Используй одну из двух областей, чтобы очиститься!"
L.Alerts_Maelstrom_Stage9_Synergy 					= "|c23afe7Spectral Explosion|r готова! Используй синергию!"


--------------------------------
----     Maw of Lorkhaj     ----
--------------------------------
L.Settings_MawLorkhaj_Header                 		= "Пасть Лорхаджа (MoL)"
-- Settings
L.Settings_MawLorkhaj_Zhaj_GripOfLorkhaj     		= "Жай'хасса: Grip of Lorkhaj"
L.Settings_MawLorkhaj_Zhaj_GripOfLorkhaj_TT  		= "Предупреждает, когда дебафф Grip of Lorkhaj начинает действовать на вас."
L.Settings_MawLorkhaj_Zhaj_Glyphs        			= "Жай'хасса: Очищающие платформы (бета)"
L.Settings_MawLorkhaj_Zhaj_Glyphs_TT     			= "Показывает окно со всеми очищающими платформами, с их статусом и временем перезарядки."
L.Settings_MawLorkhaj_Zhaj_Glyphs_Invert            = "       - Инвертированый вид"
L.Settings_MawLorkhaj_Zhaj_Glyphs_Invert_TT         = "Обращает очищающие платформы."
L.Settings_MawLorkhaj_Twin_Aspects           		= "Ложные лунные близнецы: Аспект"
L.Settings_MawLorkhaj_Twin_Aspects_TT        		= "Предупреждает, когда вы получаете лунный или теневой аспекты от Ложных Братьев.\n\n|cFFA500Полный:|r Предупреждает вас, когда вы получаете аспект, когда вы начинаете менять аспект и когда смена завершается.\n|cFFA500Нормальный:|r Предупреждает вас, когда вы получаете аспект и когда вы меняете его.\n|cFFA500Минимальный:|r Предупреждает вас, когда вы меняете аспект."
L.Settings_MawLorkhaj_Twin_Aspects_Status           = "       - Показать статус"
L.Settings_MawLorkhaj_Twin_Aspects_Status_TT        = "Показывает ваш текущий аспект в отображении статуса во время битвы с боссом."
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void   	  	= "Ракхат: Unstable Void"
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_TT 	 	= "Предупреждает, когда на вас есть эффект Unstable Void в битве с Ракхатом."
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_Countdown 		= "       - Отсчёт"
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_Countdown_TT 	= "Когда включено, показывает обратный отсчёт вместо простого предупреждения об Unstable Void."
L.Settings_MawLorkhaj_Rakkhat_ThreshingWings   		= "Ракхат: Threshing Wings"
L.Settings_MawLorkhaj_Rakkhat_ThreshingWings_TT	 	= "Предупреждает, когда Ракхат использует свою способность Threshing Wings, сбивающую вас с ног."
L.Settings_MawLorkhaj_Rakkhat_DarknessFalls    	 	= "Ракхат: Darkness Falls"
L.Settings_MawLorkhaj_Rakkhat_DarknessFalls_TT 	 	= "Предупреждает, когда Ракхат использует свою способность Darkness Falls, при которой рушится потолок."
L.Settings_MawLorkhaj_Rakkhat_DarkBarrage     	 	= "Ракхат: Dark Barrage"
L.Settings_MawLorkhaj_Rakkhat_DarkBarrage_TT  		= "Предупреждает, когда Ракхат использует свою туннельную способность Dark Barrage на танка."
L.Settings_MawLorkhaj_Rakkhat_LunarBastion1     	= "Ракхат: Получение Lunar Bastion"
L.Settings_MawLorkhaj_Rakkhat_LunarBastion1_TT  	= "Показывает, когда игрок ПОЛУЧАЕТ благословение со светящейся платформы."
L.Settings_MawLorkhaj_Rakkhat_LunarBastion2     	= "Ракхат: Потеря Lunar Bastion"
L.Settings_MawLorkhaj_Rakkhat_LunarBastion2_TT  	= "Показывает, когда игрок ТЕРЯЕТ благословение со светящейся платформы."
L.Settings_MawLorkhaj_Hulk_ArmorWeakened            = "Hulk: Armor Weakened"
L.Settings_MawLorkhaj_Hulk_ArmorWeakened_TT         = "Alerts when Hulk applies stack of Armor Weakened debuff by his Thunderous Smash attack. You should not have more than two stacks or incoming damage will be too high to handle."
L.Settings_MawLorkhaj_ShatteringStrike		    	= "Мобы: Shattering Strike"
L.Settings_MawLorkhaj_ShatteringStrike_TT           = "Предупреждает, когда Дикарь дро-м'Атра готовится применить атаку Shattering Strike."
L.Settings_MawLorkhaj_Shattered   		 			= "Мобы: Armor Shattered"
L.Settings_MawLorkhaj_Shattered_TT		 			= "Предупреждает, когда ваша броня разбита."
L.Settings_MawLorkhaj_MarkedForDeath      			= "Мобы: Marked for death (Пантеры)"
L.Settings_MawLorkhaj_MarkedForDeath_TT  			= "Предупреждает, если вы помечены для смерти пантерами Грозного ловчего дро-м'Атра"
L.Settings_MawLorkhaj_Suneater_Eclipse    			= "Мобы: Sun-Eater Eclipse Field (негейт)"
L.Settings_MawLorkhaj_Suneater_Eclipse_TT 			= "Предупреждает, если вы попадаете под действие негейта Eclipse Field."
-- Alerts
L.Alerts_MawLorkhaj_Zhaj_GripOfLorkhaj 				= "Внимание! |c000055Grip of Lorkhaj!|r ОЧИСТИСЬ!"
L.Alerts_MawLorkhaj_Lunar_Aspect 					= "Ты под |cFEFF7FЛунным|r Аспектом!"
L.Alerts_MawLorkhaj_Shadow_Aspect 					= "Ты под Аспектом |c000055Тени|r!"
L.Alerts_MawLorkhaj_Lunar_Conversion 				= "Смена на |cFEFF7FЛунный|r Аспект!"
L.Alerts_MawLorkhaj_Shadow_Conversion 				= "Смена на Аспект |c000055Тени|r!"
L.Alerts_MawLorkhaj_Rakkhat_Unstable_Void 			= "Внимание! |c000055Unstable Void|r под тобой!"
L.Alerts_MawLorkhaj_Rakkhat_Unstable_Void_Other		= "Внимание! |c000055Unstable Void|r под |cFF0000<<!aC:1>>|r!"
L.Alerts_MawLorkhaj_Rakkhat_ThreshingWings 			= "Приближается |cFF0000Threshing Wings|r! Блокируй!"
L.Alerts_MawLorkhaj_Rakkhat_DarknessFalls 			= "Приближается |cFF0000Darkness Falls|r!"
L.Alerts_MawLorkhaj_Rakkhat_DarkBarrage 			= "Приближается |cFF0000Dark Barrage|r!"
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion1 			= "Ты получил |cFEFF7FLunar Bastion|r"
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion1_Other 	= "|cFF0000<<!aC:1>>|r получил |cFEFF7FLunar Bastion|r"
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion2 			= "Ты потерял |cFEFF7FLunar Bastion|r"
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion2_Other 	= "|cFF0000<<!aC:1>>|r потерял |cFEFF7FLunar Bastion|r"
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened1             = "You got 1 stack of |c000055Armor Weakened|r debuff."
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened1_Other       = "|cFF0000<<!aC:1>>|r got 1 stack of |c000055Armor Weakened|r debuff."
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened2             = "You got |cFF00002 stacks|r of |c000055Armor Weakened|r debuff!"
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened2_Other       = "|cFF0000<<!aC:1>>|r got |cFF00002 stacks|r of |c000055Armor Weakened|r debuff!"
L.Alerts_MawLorkhaj_Suneater_Eclipse 				= "Внимание! |cFF0000Eclipse Field|r действует на тебя!"
L.Alerts_MawLorkhaj_Suneater_Eclipse_Other 			= "Внимание! |cFF0000Eclipse Field|r действует на |cFF0000<<!aC:1>>|r!"
L.Alerts_MawLorkhaj_ShatteringStrike		    	= "|c000055Shattering Strike|r надвигается на тебя."
L.Alerts_MawLorkhaj_ShatteringStrike_Other          = "|c000055Shattering Strike|r надвигается на игрока |cFF0000<<!aC:1>>|r!"
L.Alerts_MawLorkhaj_Shattered 						= "Твоя |c595959Броня|r была |cff0000Разбита|r."
L.Alerts_MawLorkhaj_MarkedForDeath 					= "Внимание! |c000055Пантеры|r преследуют тебя!"


--------------------------------
----    Dragonstar Arena    ----
--------------------------------
L.Settings_Dragonstar_Header              			= "Драгонстарская Арена (DSA)"
-- Settings
L.Settings_Dragonstar_General_Taking_Aim        	= "Общее: Taking Aim"
L.Settings_Dragonstar_General_Taking_Aim_TT     	= "Предупреждает, когда вы становитесь целью способности Taking Aim."
L.Settings_Dragonstar_General_Crystal_Blast     	= "Общее: Crystal Blast"
L.Settings_Dragonstar_General_Crystal_Blast_TT  	= "Предупреждает, когда вы становитесь целью способности Crystal Blast."
L.Settings_Dragonstar_Arena2_Crushing_Shock     	= "Арена 2: Crushing Shock"
L.Settings_Dragonstar_Arena2_Crushing_Shock_TT  	= "Предупреждает, когда вы становитесь целью способности Crushing Shock на Ледяной арене."
L.Settings_Dragonstar_Arena6_Drain_Resource    		= "Арена 6: Drain Resource"
L.Settings_Dragonstar_Arena6_Drain_Resource_TT 		= "Предупреждает, когда вы становитесь целью способности Draining Resource на Босмерской арене."
L.Settings_Dragonstar_Arena7_Unstable_Core      	= "Арена 7: Unstable Core (Eclipse)"
L.Settings_Dragonstar_Arena7_Unstable_Core_TT   	= "Предупреждает, когда на вас накладывается Unstable Core (Eclipse) боссом Храмовником на Жертвенной арене."
L.Settings_Dragonstar_Arena8_Ice_Charge         	= "Арена 8: Ice Charge"
L.Settings_Dragonstar_Arena8_Ice_Charge_TT      	= "Предупреждает, когда Ледяной центурион готов применить свою ледяную атаку."
L.Settings_Dragonstar_Arena8_Fire_Charge        	= "Арена 8: Fire Charge"
L.Settings_Dragonstar_Arena8_Fire_Charge_TT     	= "Предупреждает, когда Огненный центурион готов применить свою огненную атаку."
-- Alerts
L.Alerts_Dragonstar_General_Taking_Aim          	= "Ты стал целью |cFF6600Taking Aim|r!"
L.Alerts_Dragonstar_General_Crystal_Blast       	= "Ты стал целью |c990099Crystal Blast|r!"
L.Alerts_Dragonstar_Arena2_Crushing_Shock       	= "Приближается |c3366EECrushing Shock|r! БЛОКИРУЙ!"
L.Alerts_Dragonstar_Arena6_Drain_Resource       	= "Приближается |c00ff99Draining Resource|r! УВЕРНИСЬ!"
L.Alerts_Dragonstar_Arena6_Drain_Resource_Other		= "|c00ff99Draining Resource|r надвигается на игрока |cFF0000<<!aC:1>>|r."
L.Alerts_Dragonstar_Arena7_Unstable_Core        	= "На тебе |cDDDD33Unstable Core|r! ВЫСВОБОДИСЬ!"
L.Alerts_Dragonstar_Arena8_Ice_Charge           	= "Приближается |c6699FFIce Charge|r на тебя! ПРЕРВИ или УВЕРНИСЬ!"
L.Alerts_Dragonstar_Arena8_Ice_Charge_Other     	= "|c6699FFIce Charge|r применяется на |cFF0000<<!aC:1>>|r. ПРЕРВИ!"
L.Alerts_Dragonstar_Arena8_Fire_Charge          	= "Приближается |cFF3113Fire Charge|r на тебя! ПРЕРВИ или УВЕРНИСЬ!"
L.Alerts_Dragonstar_Arena8_Fire_Charge_Other    	= "|c6699FFire Charge|r применяется на |cFF0000<<!aC:1>>|r. ПРЕРВИ!"



--------------------------------
---- Halls Of Fabrication   ----
--------------------------------
L.Settings_HallsFab_Header                          = "Залы фабрикации (HoF)"
-- Settings
L.Settings_HallsFab_Taking_Aim                      = "Общее: Taking Aim"
L.Settings_HallsFab_Taking_Aim_TT                   = "Предупреждает, когда вы становитесь целью способности Taking Aim."
L.Settings_HallsFab_Taking_Aim_Dynamic              = "       - Отсчёт"
L.Settings_HallsFab_Taking_Aim_Dynamic_TT           = "Когда включено, отображается обратный отсчёт вместо простого предупреждения перед атакой Taking Aim."
L.Settings_HallsFab_Taking_Aim_Duration             = "       - Длительность отсчёта"
L.Settings_HallsFab_Taking_Aim_Duration_TT          = "Длительность отсчёта в миллисекундах."
L.Settings_HallsFab_Draining_Ballista               = "Общее: Draining Ballista"
L.Settings_HallsFab_Draining_Ballista_TT            = "Предупреждает, когда Сферу необходимо сбить."
L.Settings_HallsFab_Conduit_Strike                  = "Общее: Conduit Strike"
L.Settings_HallsFab_Conduit_Strike_TT               = "Предупреждает, когда приближается Conduit Strike."
L.Settings_HallsFab_Power_Leech                     = "Общее: Power Leech"
L.Settings_HallsFab_Power_Leech_TT                  = "Предупреждает, когда вы обездвижены способностью Conduit Strike и необходимо вырваться."
L.Settings_HallsFab_Venom_Injection                 = "Охотники: Venom Injection"
L.Settings_HallsFab_Venom_Injection_TT              = "Показывает статус, когда на вас действует Venom Injection во время битвы с боссом Охотником."
L.Settings_HallsFab_Conduit_Spawn                   = "Вершина: Появление"
L.Settings_HallsFab_Conduit_Spawn_TT                = "Предупреждает, когда трубопровод готов извергнуть босса Вершинный фактотум."
L.Settings_HallsFab_Conduit_Drain                   = "Вершина: Засасывание"
L.Settings_HallsFab_Conduit_Drain_TT                = "Предупреждает, когда трубопровод засасывает тебя к боссу Вершинный фактотум."
L.Settings_HallsFab_Scalded_Debuff                  = "Вершина: Scalded Debuff"
L.Settings_HallsFab_Scalded_Debuff_TT               = "Отображает небольшую иконку статуса, показывающую время до исчезновения и насколько силён дебафф исцеления."
L.Settings_HallsFab_Overcharge_Aura                 = "Комитет: Аура перегрузки"
L.Settings_HallsFab_Overcharge_Aura_TT              = "Предупреждает, когда Регенератор запускает ауру перегрузки."
L.Settings_HallsFab_Overpower_Auras                 = "Комитет: Аура перезаряда"
L.Settings_HallsFab_Overpower_Auras_TT              = "Предупреждает, когда танк должен переключаться между боссами."
L.Settings_HallsFab_Overpower_Auras_Duration        = "       - Длительность отсчёта"
L.Settings_HallsFab_Overpower_Auras_Duration_TT     = "Длительность отсчёта в миллисекундах."
L.Settings_HallsFab_Overpower_Auras_Dynamic         = "       - Динамический отсчёт"
L.Settings_HallsFab_Overpower_Auras_Dynamic_TT      = "Когда включено, аддон попытается остановить отсчёт, как только переключится на другого босса."
L.Settings_HallsFab_Fabricant_Spawn                 = "Комитет: Появление Разрушенного фактотума"
L.Settings_HallsFab_Fabricant_Spawn_TT              = "Предупреждает о появлении Разрушенного фактотума."
L.Settings_HallsFab_Catastrophic_Discharge          = "Комитет: Catastrophic Discharge"
L.Settings_HallsFab_Catastrophic_Discharge_TT       = "Предупреждает, когда Разрушенный фактотум нацеливается на тебя."
L.Settings_HallsFab_Reclaim_Achieve                 = "Комитет: Регенератор Разрушенных архивов"
L.Settings_HallsFab_Reclaim_Achieve_TT              = "Предупреждает, когда бомбер достигает Рагенератора."
-- Alerts
L.Alerts_HallsFab_Taking_Aim                        = "Ты стал целью |cFF6600Taking Aim|r!"
L.Alerts_HallsFab_Taking_Aim_Other                  = "|cFF6600Taking Aim|r нацелен на игрока |cFF0000<<!aC:1>>|r!"
L.Alerts_HallsFab_Taking_Aim_Simple                 = "|cFF6600Taking Aim|r!"
L.Alerts_HallsFab_Conduit_Spawn                     = "Трубопровод готов извергнуть босса"
L.Alerts_HallsFab_Conduit_Drain                     = "Трубопровод засасывает тебя!"
L.Alerts_HallsFab_Conduit_Drain_Other               = "Трубопровод засасывает игрока |cFF0000<<!aC:1>>|r!"
L.Alerts_HallsFab_Conduit_Strike                    = "Приближается |cFF0000Conduit Strike|r. БЛОКИРУЙ!"
L.Alerts_HallsFab_Draining_Ballista                 = "Ты стал целью |cFFC000Draining Ballista|r! БЛОКИРУЙ или ПРЕРВИ!"
L.Alerts_HallsFab_Draining_Ballista_Other           = "|cFFC000Draining Ballista|r нацелен на игрока |cFF0000<<!aC:1>>|r! ПРЕРВИ!"
L.Alerts_HallsFab_Power_Leech                       = "|c6600FFPower Leech|r! ВЫСВОБОДИСЬ!"
L.Alerts_HallsFab_Overcharge_Aura                   = "Аура |c3366EEOvercharging|r на Регенераторе."
L.Alerts_HallsFab_Overpower_Auras                   = "|cFF0000Отсчёт ауры!|r"
L.Alerts_HallsFab_Catastrophic_Discharge            = "Ты стал целью |cFF0000Catastrophic Discharge|r! БЛОКИРУЙ!"
L.Alerts_HallsFab_Fabricant_Spawn                   = "|cFFC000Появление Разрушенного фактотума|r"
L.Alerts_HallsFab_Reclaim_Achieve                   = "Достижение |cDCD822[Планируемое устаревание]|r |cFF0000провалено|r"



--------------------------------
----   Asylum Sanctorium    ----
--------------------------------
L.Settings_Asylum_Header                         = "Изоляционный санктуарий (AS)"
-- Settings
L.Settings_Asylum_Defiling_Blast                 = "Святой Ллотис: Defiling Dye Blast"
L.Settings_Asylum_Defiling_Blast_TT              = "Предупреждает вас, когда Святой Ллотис выбирает вас или других целью своей конусной атаки."
L.Settings_Asylum_Soul_Stained_Corruption        = "Святой Ллотис: Soul Stained Corruption"
L.Settings_Asylum_Soul_Stained_Corruption_TT     = "Предупреждает вас, когда Святой Ллотис выбирает игрока целью своей атаки, которую нужно прервать."
L.Settings_Asylum_Teleport_Strike                = "Святой Фелмс: Teleport Strike"
L.Settings_Asylum_Teleport_Strike_TT             = "Предупреждает вас, когда Святой Фелмс собирается телепортироваться к вам."
L.Settings_Asylum_Exhaustive_Charges             = "Святой Олмс: Exhaustive Charges"
L.Settings_Asylum_Exhaustive_Charges_TT          = "Предупреждает вас, когда Святой Олмс готов начать свою атаку, которая бросает три больших круга молний."
L.Settings_Asylum_Storm_The_Heavens              = "Святой Олмс: Storm the Heavens"
L.Settings_Asylum_Storm_The_Heavens_TT           = "Предупреждает вас, когда Святой Олмс готов подняться в воздух и выпустить большое количество маленьких кружков молний."
L.Settings_Asylum_Gusts_Of_Steam                 = "Святой Олмс: Gusts Of Steam"
L.Settings_Asylum_Gusts_Of_Steam_TT              = "Предупреждает вас, когда Святой Олмс готов прыгнуть взад-вперёд, сигнализируя о следующей фазе битвы."
L.Settings_Asylum_Gusts_Of_Steam_Slider          = "       - Percentage before jump"
L.Settings_Asylum_Gusts_Of_Steam_Slider_TT       = "Show notification couple percent of boss health faster before he jump."
L.Settings_Asylum_Protector_Spawn                = "Святой Олмс: Protector Spawn"
L.Settings_Asylum_Protector_Spawn_TT             = "Предупреждает вас, когда готова появиться сфера."
L.Settings_Asylum_Trial_By_Fire                  = "Святой Олмс: Trial By Fire"
L.Settings_Asylum_Trial_By_Fire_TT               = "Предупреждает вас, когда Святой Олмс собирается использовать огонь на добивающей фазе."
-- Alerts
L.Alerts_Asylum_Defiling_Blast                   = "Внимание! |c00cc00Defiling Blast|r нацелена на вас!"
L.Alerts_Asylum_Defiling_Blast_Other             = "Внимание! |c00cc00Defiling Blast|r нацелена на игрока |cFF0000<<!aC:1>>|r!"
L.Alerts_Asylum_Soul_Stained_Corruption          = "Приближается |c3366EESoul Stained Corruption|r. ПРЕРВИ!"
L.Alerts_Asylum_Teleport_Strike                  = "|cFFC000Teleport Strike|r нацелен на тебя!"
L.Alerts_Asylum_Teleport_Strike_Other            = "|cFFC000Teleport Strike|r нацелен на игрока |cFF0000<<!aC:1>>|r!"
L.Alerts_Asylum_Exhaustive_Charges               = "Приближается |cFF0000Exhaustive Charges|r!"
L.Alerts_Asylum_Storm_The_Heavens                = "Приближается |cFF0000Storm The Heavens|r! ПЕТЛЯЙ!"
L.Alerts_Asylum_Eruption                         = "|c595959Eruption|r нацелена на тебя!"
L.Alerts_Asylum_Eruption_Other                   = "|c595959Eruption|r нацелена на игрока |cFC0000<<!aC:1>>|r!"
L.Alerts_Asylum_Gusts_Of_Steam                   = "Приближается |cFF9900Gusts Of Steam|r! СПРЯЧЬСЯ!"
L.Alerts_Asylum_Pre_Gusts_Of_Steam               = "|cFF0000<<1>>%|r до |cFF9900прыжка|r! ГОТОВЬСЯ прятаться!"
L.Alerts_Asylum_Trial_By_Fire                    = "Приближается |cFF5500Fire|r!"
L.Alerts_Asylum_Protector_Spawn                  = "Появляется |c0000FFЗащитник|r!"
L.Alerts_Asylum_Protector_Active                 = "|c0000FFЗащитник|r активирован!"



--------------------------------
------   CLOUDREST         -----
--------------------------------
L.Settings_Cloudrest_Header			            = "Cloudrest"
-- Settings
L.Settings_Cloudrest_Olorime_Spears             = "General: Olorime Spear"
L.Settings_Cloudrest_Olorime_Spears_TT          = "Alerts you when spears are up and someone has to pick it up."
L.Settings_Cloudrest_Shadow_Realm_Cast          = "General: Portal Spawn"
L.Settings_Cloudrest_Shadow_Realm_Cast_TT       = "Alerts you when portal is spawned for group to go in Shadow Real."
L.Settings_Cloudrest_Hoarfrost                  = "Faralielle: Hoarfrost"
L.Settings_Cloudrest_Hoarfrost_TT               = "Alerts you when you have the Hoarfrost debuff on you that needs to be synergised to remove."
L.Settings_Cloudrest_Hoarfrost_Countdown        = "       - Use Countdown"
L.Settings_Cloudrest_Hoarfrost_Countdown_TT     = "Use a countdown to show when you will be able to drop it."
L.Settings_Cloudrest_Hoarfrost_Shed             = "Faralielle: Hoarfrost Drop"
L.Settings_Cloudrest_Hoarfrost_Shed_TT          = "Alerts you when Hoarfrost debuff has been dropped from another player and needs to be picked up."
L.Settings_Cloudrest_Heavy_Attack               = "Mini Boss: Heavy Attack"
L.Settings_Cloudrest_Heavy_Attack_TT            = "Alerts you when Lightening(Shocking Smash), Fire(Scalding Sunder) or Frost(Ravaging Blow) mini boss is casting heavy attack."
L.Settings_Cloudrest_Chilling_Comet             = "Faralielle: Chilling Comet"
L.Settings_Cloudrest_Chilling_Comet_TT          = "Alerts you when Chilling Comet debuff is applied to you that needs to be blocked and not overlapped with another player who has the same debuff before explosion."
L.Settings_Cloudrest_Roaring_Flare              = "Siroria: Roaring Flame"
L.Settings_Cloudrest_Roaring_Flare_TT           = "Alerts when you or any of your team members have the Roaring Flare debuff that requires a minimum of 3 team members in total to stack to negate this debuff."
L.Settings_Cloudrest_Track_Roaring_Flare        = "       - Track Roaring Flare"
L.Settings_Cloudrest_Track_Roaring_Flare_TT     = ""
L.Settings_Cloudrest_Voltaic_Overload           = "Belanaril: Voltaic Overload"
L.Settings_Cloudrest_Voltaic_Overload_TT        = "Alerts you that you are about to get the Voltaic Overload debuff where after you get the debuff, you cannot bar swap for 10 seconds."
L.Settings_Cloudrest_Nocturnals_Favor	        = "Z'Maja: Nocturnal's Favor"
L.Settings_Cloudrest_Nocturnals_Favor_TT        = "Alerts you when Z'Maja has targeted you and will do her Heavy Attack."
L.Settings_Cloudrest_Baneful_Barb               = "Yaghra Monstrosity: Baneful Barb"
L.Settings_Cloudrest_Baneful_Barb_TT            = "Alerts you when Yaghra Monstrisity has targeted you and will do Baneful Barb attack."
L.Settings_Cloudrest_Break_Amulet               = "Z'Maja: Only important mechanics on execute"
L.Settings_Cloudrest_Break_Amulet_TT            = "Disable spheres, tentacle notifications on execute phase"
L.Settings_Cloudrest_Sum_Shadow_Beads           = "Z'Maja: Spheres"
L.Settings_Cloudrest_Sum_Shadow_Beads_TT        = "Alerts when Spheres are about to spawn."
L.Settings_Cloudrest_Tentacle_Spawn             = "Z'Maja: Creeper Spawn"
L.Settings_Cloudrest_Tentacle_Spawn_TT          = "Alerts when Nocturnal Creeper is about to spawn."
L.Settings_Cloudrest_Crushing_Darkness          = "Z'Maja: Crushing Darkness"
L.Settings_Cloudrest_Crushing_Darkness_TT       = "Alerts you when Tether AoE is following you and needs to be kited."
L.Settings_Cloudrest_Malicious_Strike           = "Z'Maja: Malicious Strike"
L.Settings_Cloudrest_Malicious_Strike_TT        = "Alerts when spheres are destroyed and need to block or rolldodge."
L.Settings_Cloudrest_Shadow_Splash              = "Z'Maja: Shadow Splash"
L.Settings_Cloudrest_Shadow_Splash_TT           = "Alerts you when Z'Maja starts channeling this spell. If not interrupted in time, some players will be teleported into the sky and take fall damage."

-- Alerts
L.Alerts_Cloudrest_Olorime_Spears               = "|cffd000Spear|r is up! (<<1>>)"
L.Alerts_Cloudrest_Hoarfrost0                   = "|c00ddffHoarfrost|r on you!"
L.Alerts_Cloudrest_Hoarfrost1                   = "|cff0000Last|r |c00ddffHoarfrost|r on you!"
L.Alerts_Cloudrest_Hoarfrost_Other0             = "|c00ddffHoarfrost|r on |cff0000<<!aC:1>>|r"
L.Alerts_Cloudrest_Hoarfrost_Other1             = "|cff0000Last|r |c00ddffHoarfrost|r on |cff0000<<!aC:1>>|r"
L.Alerts_Cloudrest_Hoarfrost_Countdown0         = "Drop |c00ddffHoarfrost|r in..."
L.Alerts_Cloudrest_Hoarfrost_Countdown1         = "Drop |cff0000Last|r |c00ddffHoarfrost|r in..."
L.Alerts_Cloudrest_Hoarfrost_Syn                = "|cff0000Use synergy|r to drop hoarfrost!"
L.Alerts_Cloudrest_Hoarfrost_Shed               = "|c00ddffHoarfrost|r dropped."
L.Alerts_Cloudrest_Hoarfrost_Shed_Other         = "|c00ddffHoarfrost|r dropped by |cff0000<<!aC:1>>|r"
L.Alerts_Cloudrest_Heavy_Attack                 = "|c0bf29eHeavy Attack|r on you!"
L.Alerts_Cloudrest_Heavy_Attack_Other           = "|c0bf29eHeavy Attack!|r on |cff0000<<!aC:1>>|r"
L.Alerts_Cloudrest_Baneful_Barb                 = "|cff0000Baneful Barb|r. Rolldodge!"
L.Alerts_Cloudrest_Baneful_Barb_Other           = "|cff0000Baneful Barb|r on |cff0000<<!aC:1>>|r"
L.Alerts_Cloudrest_Chilling_Comet               = "|cff0000Chilling Comet|r at you. Block!"
L.Alerts_Cloudrest_Roaring_Flare                = "|cff7700Roaring Flare|r at you"
L.Alerts_Cloudrest_Roaring_Flare_2              = "|cff0000<<!aC:1>>|r |t100%:100%:Esoui/Art/Buttons/large_leftarrow_up.dds|t |cff7700Roaring Flare|r |t100%:100%:Esoui/Art/Buttons/large_rightarrow_up.dds|t |cff0000<<!aC:2>>|r"
L.Alerts_Cloudrest_Roaring_Flare_Other          = "|cff7700Roaring Flare|r at |cff0000<<!aC:1>>|r. Stack on"
L.Alerts_Cloudrest_Voltaic_Current              = "Incoming |c55b4d4Voltaic Overload|r at you in"
L.Alerts_Cloudrest_Voltaic_Overload             = "|c4d61c1Voltaic Overload|r at you! Swap Bar!"
L.Alerts_Cloudrest_Voltaic_Overload_Cd          = "|c4d61c1Voltaic Overload|r. Don't swap!"
L.Alerts_Cloudrest_Shadow_Realm_Cast            = "|cab82ffPortal|r Spawn (<<1>>)"
L.Alerts_Cloudrest_Tentacle_Spawn               = "|c00a86bCreeper|r Spawn"
L.Alerts_Cloudrest_Sum_Shadow_Beads             = "|cab82ffSpheres|r are about to spawn"
L.Alerts_Cloudrest_Nocturnals_Favor             = "|cff0000Nocturnal's Favor|r at you!"
L.Alerts_Cloudrest_Crushing_Darkness            = "|cfc0c66Crushing Darkness|r at you. Kite!"
L.Alerts_Cloudrest_Malicious_Strike             = "|cff0000Malicious Strike|r at you. Block!"
L.Alerts_Cloudrest_Shadow_Splash                = "Z'Maja is casting. |cFF0000Interrupt|r!"

--------------------------------
------   SUNSPIRE          -----
--------------------------------
L.Settings_Sunspire_Header			= "Sunspire"
-- Settings
L.Settings_Sunspire_Chilling_Comet        = "General: Chilling Comet"
L.Settings_Sunspire_Chilling_Comet_TT     = "Alerts you when the Chilling Comet is targeted on you. Move out of the group, block and do not overlap with another player who also has a Chilling Comet. Chilling Comet Targets 2 players at once."
L.Settings_Sunspire_Sweeping_Breath	      = "Nahviintaas: Sweeping Breath"
L.Settings_Sunspire_Sweeping_Breath_TT    = "Alerts you of Nahviintass fire breath. The breath starts from one side of the arena and crosses to the other side while damaging every player inside. Every player must block or dodge roll this attack."
L.Settings_Sunspire_Molten_Meteor         = "Nahviintaas: Molten Meteor"
L.Settings_Sunspire_Molten_Meteor_TT      = "Alerts you when the Molten Meteor is targeted on you. Move to the edge of the arena, block, and do not overlap with another player who also has Molten meteor. Molten Meteor Targets 3 players at once."
L.Settings_Sunspire_Focus_Fire            = "Yolnahkriin: Focus Fire"
L.Settings_Sunspire_Focus_Fire_TT         = "Alerts when a group member is targeted with Focus Fire. Focus Fire requires group members to stack to share the damage. There will be a lingering debuff afterwards, increasing your damage taken by the next focus fire. Due to this debuff, you should stack in two separate groups."
L.Settings_Sunspire_Breath                = "General: Fire/Frost/Searing Breath"
L.Settings_Sunspire_Breath_TT             = "Alerts you when the channelled cone from each boss is on you, dealing heavy damage. "
L.Settings_Sunspire_Cataclism             = "Yolnahkriin: Cataclism"
L.Settings_Sunspire_Cataclism_TT          = "Alerts you when the boss will breathe fire in the middle of the arena. Everyone must move to the edge, and kill the adds."
L.Settings_Sunspire_Frozen_Tomb           = "Lokkestiiz: Frozen Tomb"
L.Settings_Sunspire_Frozen_Tomb_TT        = "Alerts you when Frozen Tomb spawns. A player must walk into the tomb, which will freeze them and deal damage over time. You must then be healed to be released. Requires 3 players to take the tombs due to a debuff, a different person each time."
L.Settings_Sunspire_Thrash                = "Nahviintaas: Thrash"
L.Settings_Sunspire_Thrash_TT             = "Alerts you when boss is about swing his head through the group, knocking everyone back. This must be blocked or dodge rolled."
L.Settings_Sunspire_Mark_For_Death        = "Nahviintaas: Mark For Death"
L.Settings_Sunspire_Mark_For_Death_TT     = "Alerts you when you are marked for death. Dealing heavy damage over time, and completely removing all your resisstances."
L.Settings_Sunspire_Time_Breach           = "Nahviintaas: Time Breach"
L.Settings_Sunspire_Time_Breach_TT        = "Alerts you when portal for time shift is open."
L.Settings_Sunspire_Negate_Field          = "Eternal Servant: Negate Field"
L.Settings_Sunspire_Negate_Field_TT       = "Get a warning if the Negate Field targets you in time shift."
L.Settings_Sunspire_Shock_Bolt            = "Eternal Servant: Shock Bolt"
L.Settings_Sunspire_Shock_Bolt_TT         = "Shock Bolt countdown that inform the group when to stack to unpin another player."
L.Settings_Sunspire_Apocalypse            = "Eternal Servant: Translation Apocalypse"
L.Settings_Sunspire_Apocalypse_TT         = "Alerts you when the eternal servant is channeling his attack to the upstairs group. It gives you a countdown until you can bash the channeling and it shows you a countdown until he completes the channeling attack"


-- Alerts
L.Alerts_Sunspire_Chilling_Comet          = "|c00ddffChilling Comet|r at you. Block!"
L.Alerts_Sunspire_Chilling_Comet_Other    = "|c00ddffChilling Comet|r at |cff0000<<!aC:1>>|r"
L.Alerts_Sunspire_Sweeping_Breath         = "|cff0000Sweeping Breath|r! Block!"
L.Alerts_Sunspire_Molten_Meteor           = "|c00ddffMolten Meteor|r at you! Go out!"
L.Alerts_Sunspire_Molten_Meteor_Other     = "|c00ddffMolten Meteor|r at <<!aC:1>>|r"
L.Alerts_Sunspire_Focus_Fire              = "|cff7700Focus Fire|r at you in"
L.Alerts_Sunspire_Focus_Fire_Other        = "|cff7700Focus Fire|r at |cff0000<<!aC:1>>|r in"
L.Alerts_Sunspire_Atronach_Zap            = "|cff7700Atronach|r spawn in"
L.Alerts_Sunspire_Frost_Atronach          = "|cff7700Frost Atronach|r is up!"
L.Alerts_Sunspire_Breath                  = "|cffff00<<1>>|r at you!"
L.Alerts_Sunspire_Breath_Other            = "|cffff00<<1>>|r at |cff0000<<!aC:2>>|r"
L.Alerts_Sunspire_Cataclism               = "|cff3300Cataclism|r ends in"
L.Alerts_Sunspire_Frozen_Tomb             = "|c00ddffFrozen Tomb|r (<<1>>)"
L.Alerts_Sunspire_Thrash                  = "Incoming |cff0000Thrash|r! Block!"
L.Alerts_Sunspire_Mark_For_Death          = "Mark for Death at you"
L.Alerts_Sunspire_Mark_For_Death_Other    = "Mark for Death at |cff0000<<!aC:1>>|r"
L.Alerts_Sunspire_Time_Breach_Countdown   = "|c81cc00Time Breach|r in "
L.Alerts_Sunspire_Negate_Field            = "|c53c4c9Negate Field|r at you!"
L.Alerts_Sunspire_Negate_Field_Others     = "|c53c4c9Negate Field|r at <<!aC:1>>!"
L.Alerts_Sunspire_Shock_Bolt              = "Incoming |c00ddffShock Bolt|r! Stack to unpin in"
L.Alerts_Sunspire_Apocalypse              = "Incoming |cffff00Translation Apocalypse|r! Bash in"
L.Alerts_Sunspire_Apocalypse_Ends         = "|cffff00Translation Apocalypse|r ends in"


--------------------------------
------   KYNE'S AEGIS      -----
--------------------------------
L.Settings_KynesAegis_Header                        = "Kyne's Aegis"
-- Settings
L.Settings_KynesAegis_Crashing_Wall                 = "General: Crashing Wall"
L.Settings_KynesAegis_Crashing_Wall_TT              = "Alerts you when the Half-Giant Tidebreaker starts his Crashing Wall attack, counting down until it is unleashed. Block or roll dodge it."
L.Settings_KynesAegis_Sanguine_Prison               = "General: Sanguine Prison"
L.Settings_KynesAegis_Sanguine_Prison_TT            = "Alerts you when your ally is trapped in Sanguine Prison casted by Bitter Knight. You need to free your ally by focusing down his prison."
L.Settings_KynesAegis_Blood_Fountain                = "General: Blood Fountain"
L.Settings_KynesAegis_Blood_Fountain_TT             = "Alerts you when Bloodknight starts his Blood Fountain attack, counting down until it is unleashed. It looks like cross-shaped AoE, and need to be avoided as it deals heavy damage."
L.Settings_KynesAegis_Totem                         = "Yandir: Totems spawn"
L.Settings_KynesAegis_Totem_TT                      = "Alerts you when certain totem appeared during the battle with Yandir the Butcher boss.\n\nDragon Totems: always two appears at the same time; each one blows out fire along a straight line in two opposite directions.\nHarpy Totem: spawns a lightning aura that will radiate out.\nGargoyle totem: encases random players into stone.\nChaurus Totem: poisons several people, and this poison should not be spread to others, that's why you should not stack at this phase."
L.Settings_KynesAegis_Yandir_FireShaman_Meteor      = "Yandir HM: Meteors"
L.Settings_KynesAegis_Yandir_FireShaman_Meteor_TT   = "Alerts you when Butcher's Fire Shamans will cast meteors on players."
L.Settings_KynesAegis_Vrol_FireMage_Meteor          = "Vrol: Meteors"
L.Settings_KynesAegis_Vrol_FireMage_Meteor_TT       = "Alerts you when Vrolsworn Fire Mages from the boat will cast meteors on players."
L.Settings_KynesAegis_Ichor_Eruption                = "Falgravn: Ichor Eruption"
L.Settings_KynesAegis_Ichor_Eruption_TT             = "Shows countdown until Falgravn will release his Ichor Eruption."
L.Settings_KynesAegis_Ichor_Eruption_CD_Time        = "       - Countdown time"
L.Settings_KynesAegis_Ichor_Eruption_CD_Time_TT     = "Time before Ichor Eruption when countdown should pop up."

-- Alerts
L.Alerts_KynesAegis_Crashing_Wall                   = "|cd2a100Crashing Wall|r in"
L.Alerts_KynesAegis_Sanguine_Prison_Other           = "|cff0000<<!aC:1>>|r trapped in |cb00000Sanguine Prison|r. Free them!"
L.Alerts_KynesAegis_Blood_Fountain                  = "|cb00000Blood Fountain|r in"
L.Alerts_KynesAegis_Dragon_Totem                    = "Two |cffa500Dragon Totems|r spawned. Avoid the fire!"
L.Alerts_KynesAegis_Harpy_Totem                     = "|c00bfffHarpy Totem|r spawned."
L.Alerts_KynesAegis_Gargoyle_Totem                  = "|cf5f5dcGargoyle Totem|r spawned."
L.Alerts_KynesAegis_Chaurus_Totem                   = "|c39942eChaurus Totem|r spawned. Don't stack!"
L.Alerts_KynesAegis_FireMage_Meteor                 = "|cffa500Meteor|r on you in"
L.Alerts_KynesAegis_FireMage_Meteor_Other           = "Meteors in"
L.Alerts_KynesAegis_Ichor_Eruption                  = "|cb00000Ichor Eruption|r in"


--------------------------------
------   ROCKGROVE         -----
--------------------------------
L.Settings_Rockgrove_Header                        = "Rockgrove"
-- Settings
L.Settings_Rockgrove_Sundering_Strike              = "General: Sundering Strike"
L.Settings_Rockgrove_Sundering_Strike_TT           = "Alerts you when the Sul-Xan Reaper makes Sundering Strike attack. Roll dodge it."
L.Settings_Rockgrove_Astral_Shield                 = "General: Astral Shield"
L.Settings_Rockgrove_Astral_Shield_TT              = "Alerts you when the Sul-Xan Soulweaver casts his Astral Shield."
L.Settings_Rockgrove_Soul_Remnant                  = "General: Soul Remnant (Soulweaver)"
L.Settings_Rockgrove_Soul_Remnant_TT               = "Alerts you when Soul Remnants targets you (as result of breaking Sul-Xan Soulweaver's Astral Shield)."
L.Settings_Rockgrove_Prime_Meteor                  = "General: Prime Meteor"
L.Settings_Rockgrove_Prime_Meteor_TT               = "Shows countdown when meteor appears indicating the time before it explodes. Make sure to kill the meteor in time."
L.Settings_Rockgrove_Hasted_Assault                = "General: Hasted Assault"
L.Settings_Rockgrove_Hasted_Assault_TT             = "Alerts you when the Havocrel Barbarian makes Hasted Assault attack. He teleports from player to player in random order and attacks them. This should be blocked."
L.Settings_Rockgrove_Savage_Blitz                  = "Oaxiltso: Savage Blitz"
L.Settings_Rockgrove_Savage_Blitz_TT               = "Alerts you when the Oaxiltso charges at the furthest player."
L.Settings_Rockgrove_Noxious_Sludge                = "Oaxiltso: Noxious Sludge"
L.Settings_Rockgrove_Noxious_Sludge_TT             = "Alerts you when someone is poisoned by Oaxiltso and has to go cleanse in the pool."
L.Settings_Rockgrove_Cinder_Cleave                 = "Oaxiltso's mini-boss: Cinder Cleave"
L.Settings_Rockgrove_Cinder_Cleave_TT              = "Alerts you when Havocrel Annihilator casts his Cinder Cleave ability on someone during the fight with Oaxiltso."
L.Settings_Rockgrove_Embrace_Of_Death              = "Flame-Herald Bahsei: Embrace of Death"
L.Settings_Rockgrove_Embrace_Of_Death_TT           = "Alerts you when someone got cursed by Flame-Herald Bahsei. That person will explode after 8 seconds, spreading the curse. It's important to keep cursed player separated from the group."
L.Settings_Rockgrove_Embrace_Of_Death_TT_All       = "|cFF0000WARNING!|r If your group will get too much curses your screen may be fully covered in countdowns for a duration of those curses! We're working on ways to improve this notification."
L.Settings_Rockgrove_Bahsei_Cone_Direction         = "Flame-Herald Bahsei HM: Cone direction"
L.Settings_Rockgrove_Bahsei_Cone_Direction_TT      = "Alerts you of the cone direction if the portal opened."
L.Settings_Rockgrove_Bahsei_Portal_Number          = "Flame-Herald Bahsei HM: Portal number (beta)"
L.Settings_Rockgrove_Bahsei_Portal_Number_TT       = "Tells you the number of portal being opened."
L.Settings_Rockgrove_Xalvakka_Unstable_Charge      = "Xalvakka HM: Unstable charge (staying on blob)"
L.Settings_Rockgrove_Xalvakka_Unstable_Charge_TT   = "Alerts you when you're staying on blob. It's not healthy!"

-- Alerts
L.Alerts_Rockgrove_Sundering_Strike                = "Incoming |cCDCDCDSundering Strike|r on you!"
L.Alerts_Rockgrove_Sundering_Strike_Other          = "Incoming |cCDCDCDSundering Strike|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_Rockgrove_Astral_Shield_Cast              = "|cFFFF8FAstral Shield|r has been casted. Prepare to dodge or block!"
L.Alerts_Rockgrove_Soul_Remnant                    = "Incoming |c8FF2FFSoul Remnant|r!"
L.Alerts_Rockgrove_Prime_Meteor                    = "|cFFD600Prime Meteor|r will explode in"
L.Alerts_Rockgrove_Hasted_Assault                  = "Incoming |cFF0000Hasted Assault|r! Block!"
L.Alerts_Rockgrove_Savage_Blitz                    = "Oaxiltso charges at |cFF0000<<!aC:1>>|r!"
L.Alerts_Rockgrove_Noxious_Sludge_Self             = "You're poisoned by |c008C22Noxious Sludge|r! Cleanse in the pool!"
L.Alerts_Rockgrove_Noxious_Sludge_Other1           = "|cFF0000<<!aC:1>>|r is poisoned by |c008C22Noxious Sludge|r."
L.Alerts_Rockgrove_Noxious_Sludge_Other2           = "|cFF0000<<!aC:1>>|r and |cFF0000<<!aC:2>>|r are poisoned by |c008C22Noxious Sludge|r."
L.Alerts_Rockgrove_Cinder_Cleave                   = "|cD74700Cinder Cleave|r on you!"
L.Alerts_Rockgrove_Cinder_Cleave_Other             = "|cD74700Cinder Cleave|r on |cFF0000<<!aC:1>>|r."
L.Alerts_Rockgrove_Embrace_Of_Death                = "You're cursed by |c0A929BEmbrace of Death|r! Stay away! Explosion in"
L.Alerts_Rockgrove_Embrace_Of_Death_Other          = "|cFF0000<<!aC:1>>|r cursed by |c0A929BEmbrace of Death|r! Explosion in"
L.Alerts_Rockgrove_Bahsei_Cone_Direction_Clockwise = "-> Move |cF48020clockwise|r ->"
L.Alerts_Rockgrove_Bahsei_Cone_Direction_CounterCW = "<- Move |c15FFC2counterclockwise|r <-"
L.Alerts_Rockgrove_Bahsei_Portal_Number            = "Portal #<<1>>"
L.Alerts_Rockgrove_Xalvakka_Unstable_Charge        = "Move away from |c008C22blob|r!"


--------------------------------
------   DREADSAIL REEF    -----
--------------------------------
L.Settings_DreadsailReef_Header                    = "Dreadsail Reef"
-- Settings
L.Settings_DreadsailReef_Dome_Type                 = "Lylanar & Turlassil: Fire/Ice Dome filter"
L.Settings_DreadsailReef_Dome_Type_TT              = "You can restrict notifications to some specific Dome."
L.Settings_DreadsailReef_Dome_Activation           = "Lylanar & Turlassil: Fire/Ice Dome activation"
L.Settings_DreadsailReef_Dome_Activation_TT        = "Alerts you when someone gets Fire or Ice Dome."
L.Settings_DreadsailReef_Dome_Stack_Alert          = "Lylanar & Turlassil: Fire/Ice Dome stacks alert"
L.Settings_DreadsailReef_Dome_Stack_Alert_TT       = "Alerts you when someone gets too many stacks from Fire or Ice Dome."
L.Settings_DreadsailReef_Dome_Stack_Threshold      = "Lylanar & Turlassil: Fire/Ice Dome stack threshold"
L.Settings_DreadsailReef_Dome_Stack_Threshold_TT   = "Specify how many stacks should be received by the player to fire the alert."
L.Settings_DreadsailReef_Imminent_Debuffs          = "Lylanar & Turlassil: Imminent Blister/Chill"
L.Settings_DreadsailReef_Imminent_Debuffs_TT       = "Alerts you when tank receives Imminent Blister debuff from Lylanar or Imminent Chill debuff from Turlassil. Tanks should swap in 10 seconds."
L.Settings_DreadsailReef_Brothers_Heavy_Attack     = "Lylanar & Turlassil: Heavy attack"
L.Settings_DreadsailReef_Brothers_Heavy_Attack_TT  = "Alerts you when Lylanar or Turlassil makes their heavy attack (Broiling Hew / Stinging Shear)."
L.Settings_DreadsailReef_ReefGuardian_ReefHeart    = "Reef Guardian: Reef Heart spawn"
L.Settings_DreadsailReef_ReefGuardian_ReefHeart_TT = "Alerts you when Reef Heart appears. You have 60 seconds to kill it or it's a group wipe. There can be several Hearts active at the same time."
L.Settings_DreadsailReef_ReefHeart_Result          = "Reef Guardian: Reef Heart success/failure"
L.Settings_DreadsailReef_ReefHeart_Result_TT       = "Alerts you if you have executed Reef Heart or not."
L.Settings_DreadsailReef_Rapid_Deluge              = "Taleria: Rapid Deluge"
L.Settings_DreadsailReef_Rapid_Deluge_TT           = "Alerts you when you or someone got Rapid Deluge debuff. They'll explode in 6 seconds, and the best option to handle the damage is to be swimming at that time."

-- Alerts
L.Alerts_DreadsailReef_Destructive_Ember           = "<<!aC:1>> activated |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Piercing_Hailstone          = "<<!aC:1>> activated |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_Imminent_Blister            = "You're afflicted by |cF27D0CImminent Blister|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Blister_Other      = "|cFF0000<<!aC:1>>|r afflicted by |cF27D0CImminent Blister|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Chill              = "You're afflicted by |cB4CFFAImminent Chill|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Chill_Other        = "|cFF0000<<!aC:1>>|r afflicted by |cB4CFFAImminent Chill|r! Swap tanks until"
L.Alerts_DreadsailReef_Broiling_Hew                = "Incoming |cCDCDCDBroiling Hew|r on you!"
L.Alerts_DreadsailReef_Broiling_Hew_Other          = "Incoming |cCDCDCDBroiling Hew|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_DreadsailReef_Stinging_Shear              = "Incoming |cCDCDCDStinging Shear|r on you!"
L.Alerts_DreadsailReef_Stinging_Shear_Other        = "Incoming |cCDCDCDStinging Shear|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_DreadsailReef_Fire_Dome_Stack_Alert       = "You have |cFF0000<<1>>|r stacks from |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Fire_Dome_Stack_Alert_Other = "<<!aC:1>> have |cFF0000<<2>>|r stacks from |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Ice_Dome_Stack_Alert        = "You have |cFF0000<<1>>|r stacks from |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_Ice_Dome_Stack_Alert_Other  = "<<!aC:1>> have |cFF0000<<2>>|r stacks from |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_ReefGuardian_ReefHeart      = "Reef Heart #|cFF0000<<1>>|r spawned!"
L.Alerts_DreadsailReef_ReefHeart_Success           = "Reef Heart #|cFF0000<<1>>|r |c7CFC00destroyed|r!"
L.Alerts_DreadsailReef_ReefHeart_Success_Unknown   = "Reef Heart |c7CFC00destroyed|r!"
L.Alerts_DreadsailReef_ReefHeart_Failure           = "Reef Heart #|cFF0000<<1>>|r |cFF0000empowered|r. You're doomed!"
L.Alerts_DreadsailReef_ReefHeart_Failure_Unknown   = "Reef Heart |cFF0000empowered|r. You're doomed!"
L.Alerts_DreadsailReef_Rapid_Deluge                = "You got |c1CA3ECRapid Deluge|r! You should be swimming in"
L.Alerts_DreadsailReef_Rapid_Deluge_Other          = "|cFF0000<<!aC:1>>|r got |c1CA3ECRapid Deluge|r! Swim in"


--------------------------------
------   SANITY'S EDGE     -----
--------------------------------
L.Settings_SanityEdge_Header                       = "Sanity's Edge"
-- Settings
L.Settings_SanityEdge_Chimera_Sunburst             = "Chimera: Sunburst"
L.Settings_SanityEdge_Chimera_Sunburst_TT          = "Alerts you Chimera casts Sunburst on the group during its Inferno attack. Move away from the boss, and block or dodge it."
L.Settings_SanityEdge_Ansuul_Sunburst              = "Ansuul: Sunburst"
L.Settings_SanityEdge_Ansuul_Sunburst_TT           = "Alerts you when Ansuul casts Sunburst on player. Target player should move away from the group. Keep moving, don't block or dodge it."
L.Settings_SanityEdge_Ansuul_Poisoned_Mind         = "Ansuul: Poisoned Mind"
L.Settings_SanityEdge_Ansuul_Poisoned_Mind_TT      = "Alerts you when Ansuul casts Poisoned Mind. Stay in group. HM: don't stack with other player who has this mechanic."

-- Alerts
L.Alerts_SanityEdge_Chimera_Sunburst               = "|cff9500Meteor|r at you!"
L.Alerts_SanityEdge_Ansuul_Sunburst                = "|c00ddffSunburst|r at you!"
L.Alerts_SanityEdge_Ansuul_Sunburst_Other          = "|c00ddffSunburst|r at <<!aC:1>>|r"
L.Alerts_SanityEdge_Ansuul_Poisoned_Mind           = "|c008C22Poison|r at you!"
L.Alerts_SanityEdge_Ansuul_Poisoned_Mind_Other     = "|c008C22Poison|r at <<!aC:1>>|r"


--------------------------------
----       Debugging        ----
--------------------------------
L.Settings_Debug_Header                  = "Отладка"
L.Settings_Debug                         = "Включить отладку"
L.Settings_Debug_TT                      = "Выключает вывод отладочной информации в окно чата"
L.Settings_Debug_DevMode                 = "Dev Mode"
L.Settings_Debug_DevMode_TT              = "Когда включено, срабатывают специальные предупреждения, которые могут функционировать не полностью, иметь неверные тайминги или ещё не полностью оттестированы. Обычно, они не должны вызывать ошибок интерфейса, но всё-таки рекомендуется использовать аддон, который 'ловит ошибки'."
L.Settings_Debug_DevMode_Warning         = "Требуется DevMode"

L.Settings_Debug_Tracker_Header          = "Debug Tracker"
L.Settings_Debug_Tracker_Description     = "Этот функционал отладки отслеживает и выводит потенциальные механики во время прохождения испытания путём вывод информации в информации о боевых событиях и эффектах. Из-за потенциально большого объёма выводимой информации, есть несколько настроек, которые могут помочь вам избежать загромождения окна чата."
L.Settings_Debug_Tracker_Enabled         = "Включено"
L.Settings_Debug_Tracker_SpamControl     = "Контроль спама"
L.Settings_Debug_Tracker_SpamControl_TT  = "С включением этого, каждая способность/эффект выводятся лишь один раз для действия каждого типа. Список всех известных способностей текущей сессии может быть очищен командой \"/rndebug clear\"."
L.Settings_Debug_Tracker_MyEnemyOnly     = "Только мои противники"
L.Settings_Debug_Tracker_MyEnemyOnly_TT  = "КОгда включено, ограничивает вывод информации о способностях/эффектах только теми, которые нацелены на игрока и НЕ исходят от других игроков или группы. Полезно, когда вы ищете определённые вещи и не хотите включать Контроль спама."



--TODO: get rid of this ugly, bulky localization method
for k, v in pairs(L) do
    local string = "RAIDNOTIFIER_" .. string.upper(k)
    ZO_CreateStringId(string, v)
end

if (GetCVar('language.2') == 'ru') then
	local MissingL = {}
	for k, v in pairs(RaidNotifier:GetLocale()) do
		if (not L[k]) then
			table.insert(MissingL, k)
			L[k] = v
		end
	end
	function RaidNotifier:GetLocale()
		return L
	end
	-- for debugging
	function RaidNotifier:MissingLocale()
		df("Missing strings for '%s'", GetCVar('language.2'))
		d(MissingL)
	end
end
