CraftingDailyNotificationSavedVariables = {}



              -- *** Инициализируем флаг, если он ещё не существует *** --

    if not CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp then
    CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp = os.time(os.date("!*t")) - 3600 * 24 * 7 
    end



    CraftingDailyNotification = {}
    local CraftingDailyNotification = CraftingDailyNotification



                   -- *** ГЛОБАЛЬНЫЙ ФЛАГ ЧИСТКИ *** --

    if not CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp then
    local oneWeekAgo = os.time(os.date("!*t")) - (86400 * 7)
    CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp = oneWeekAgo
    end



    local LAM = LibAddonMenu2 

local COLOR_YELLOW = "|cFFD700"
local COLOR_GREEN  = "|c00FF00"
local COLOR_WHITE  = "|cFFFFFF"
local COLOR_RED    = "|cFF0000"



-- *** All Supported Languages *** --

local gameLanguage = GetCVar("language.2")
local languageMap = {
    ["en"] = "en",
    ["ru"] = "ru", 
    ["fr"] = "fr",
    ["es"] = "es",
    ["jp"] = "jp",
    ["de"] = "de",
}
local LANGUAGE = languageMap[gameLanguage] or "en" 



-- *** Translation block start *** --

local L = {
    ["ru"] = { -- Русский
        SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00Алхимия|r",
        SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbbКузнечное дело|r",
        SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276Зачарование|r",
        SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddcaПортняжное дело|r",
        SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFFСнабжение|r",
        SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691EСтолярное дело|r",
        SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FFЮвелирное дело|r",
        SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000Данная настройка только на текущего персонажа!!! Всех остальных персонажей настройте отдельно каждого!!!|r",
        SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98Настройки|r",
        SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6Активные Ремёсла|r",
        SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98Отключите ремёсла, которых нет у персонажа.\nЛимит ежедневных заданий изменится автоматически.\nПо умолчанию все настройки включены, лимит составляет 7/7|r",
        SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6Отправка сообщений в чат|r",
        SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6Включить или выключить сообщения в чат.|r\n|c00FF00Данная настройка на весь аккаунт|r",
        SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6Период автоудаления истории|r",
        SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6Через сколько дней неактивности записи будут удаляться.|r\n|c00FF00Данная настройка на весь аккаунт|r\n|cFF0000ВНИМАНИЕ|r\n|cFFFFFFЕсли вы удалили одного или более персонажей - прокрутите ползунок максимально влево на цифру 2, через два дня записи старых (удалённых) персонажей будут удалены из истории, аддон не имеет доступа к вашим персонажам, аддон только читает историю!|r\nТакова игровая условность",
        SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00ИСТОРИЯ ПЕРСОНАЖЕЙ:|r",
        SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000ВНИМАНИЕ!!!|r\nЗайдите хотя бы один раз на каждого вашего персонажа для получения полной истории всех ваших персонажей!",
        SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r Автоматическая чистка: удалено %d устаревших записей.",
        SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFПрогресс персонажей:|r |c00FF00%d/%d|r Всё выполнили!",
        SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFПрогресс персонажей: |r%s%d|r/|r%s%d|r: |r%s",
    },



    ["en"] = { -- Английский
        SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00Alchemy|r",
        SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbbBlacksmithing|r",
        SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276Enchanting|r",
        SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddcaClothing|r",
        SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFFProvisioning|r",
        SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691EWoodworking|r",
        SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FFJewelry Crafting|r",
        SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000This setting is for the current character only!!! Set up all other characters separately!!!|r",
        SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98Settings|r",
        SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6Active Crafts|r",
        SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98Disable crafts that your character does not have.\nThe daily quest limit will change automatically.\nBy default, all settings are enabled, the limit is 7/7|r",
        SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6Sending messages to chat|r",
        SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6Enable or disable messages in chat.|r\n|c00FF00This setting is for the entire account|r",
        SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6History auto-delete period|r",
        SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6After how many days of inactivity records will be deleted.|r\n|c00FF00This setting is for the entire account|r\n|cFF0000WARNING|r\n|cFFFFFFIf you have deleted one or more characters - scroll the slider all the way to the left to the number 2, after two days the records of old (deleted) characters will be deleted from history, the addon does not have access to your characters, the addon only reads the history!|r\nSuch a game convention",
        SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00CHARACTER HISTORY:|r",
        SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000WARNING!!!|r\nLog in at least once for each of your characters to get the complete history of all your characters!",
        SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r Auto-cleanup: deleted %d old records.",
        SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFCharacter progress:|r |c00FF00%d/%d|r All completed!",
        SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFCharacter progress: |r%s%d|r/|r%s%d|r: |r%s",
    },



    ["fr"] = { -- Французский
        SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00Alchimie|r",
        SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbbForge|r",
        SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276Enchantement|r",
        SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddcaCouture|r",
        SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFFApprovisionnement|r",
        SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691EMenuiserie|r",
        SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FFJoaillerie|r",
        SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000Ce réglage s'applique uniquement au personnage actuel !!! Configurez tous les autres personnages séparément, chacun individuellement !!!|r",
        SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98Réglages|r",
        SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6Métiers Actifs|r",
        SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98Désactivez les métiers que le personnage n'a pas.\nLa limite des quêtes journalières changera automatiquement.\nPar défaut, tous les réglages sont activés, la limite est de 7/7|r",
        SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6Envoi de messages dans le chat|r",
        SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6Activer ou désactiver les messages dans le chat.|r\n|c00FF00Ce réglage s'applique à tout le compte|r",
        SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6Période d'auto-suppression de l'historique|r",
        SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6Après combien de jours d'inactivité les enregistrements seront supprimés.|r\n|c00FF00Ce réglage s'applique à tout le compte|r\n|cFF0000ATTENTION|r\n|cFFFFFFSi vous avez supprimé un ou plusieurs personnages - faites glisser le curseur complètement vers la gauche sur le chiffre 2, après deux jours les enregistrements des anciens personnages (supprimés) seront supprimés de l'historique, l'addon n'a pas accès à vos personnages, l'addon lit seulement l'historique !|r\nC'est une convention du jeu",
        SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00HISTORIQUE DES PERSONNAGES:|r",
        SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000ATTENTION!!!|r\nConnectez-vous au moins une fois avec chacun de vos personnages pour obtenir l'historique complet de tous vos personnages!",
        SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r Nettoyage automatique : supprimé %d enregistrements obsolètes.",
        SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFProgression des personnages :|r |c00FF00%d/%d|r Tous ont terminé !",
        SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFProgression des personnages : |r%s%d|r/|r%s%d|r: |r%s",
    },



    ["es"] = { -- Испанский
        SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00Alquimia|r",
        SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbbHerrería|r",
        SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276Encantamiento|r",
        SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddcaSastrería|r",
        SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFFAbastecimiento|r",
        SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691ECarpintería|r",
        SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FFArtículos de Joyería|r",
        SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000¡Esta configuración es solo para el personaje actual!!! ¡Configure todos los demás personajes por separado, cada uno individualmente!!!|r",
        SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98Configuraciones|r",
        SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6Oficios Activos|r",
        SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98Desactive los oficios que el personaje no tiene.\nEl límite de misiones diarias cambiará automáticamente.\nPor defecto, todas las configuraciones están activadas, el límite es 7/7|r",
        SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6Envío de mensajes al chat|r",
        SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6Activar o desactivar mensajes en el chat.|r\n|c00FF00Esta configuración es para toda la cuenta|r",
        SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6Período de autoborrado del historial|r",
        SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6Después de cuántos días de inactividad se eliminarán los registros.|r\n|c00FF00Esta configuración es para toda la cuenta|r\n|cFF0000ATENCIÓN|r\n|cFFFFFFSi ha eliminado uno o más personajes - deslice el control deslizante completamente a la izquierda hasta el número 2, después de dos días los registros de los viejos personajes (eliminados) serán borrados del historial, el addon no tiene acceso a sus personajes, el addon solo lee el historial!|r\nAsí son las convenciones del juego",
        SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00HISTORIAL DE PERSONAJES:|r",
        SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000¡ATENCIÓN!!!|r\nInicie sesión al menos una vez con cada uno de sus personajes para obtener el historial completo de todos sus personajes!",
        SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r Limpiado automático: eliminados %d registros antiguos.",
        SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFProgreso de personajes:|r |c00FF00%d/%d|r ¡Todos completaron!",
        SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFProgreso de personajes: |r%s%d|r/|r%s%d|r: |r%s",
    },



    ["jp"] = { -- Японский
        SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00錬金術|r",
        SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbb鍛冶|r",
        SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276付呪|r",
        SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddca裁縫|r",
        SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFF調理|r",
        SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691E木工|r",
        SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FF宝飾|r",
        SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000この設定は現在のキャラクターにのみ適用されます！！！他のキャラクターはそれぞれ別個に設定してください！！！|r",
        SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98設定|r",
        SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6アクティブなクラフト|r",
        SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98キャラクターが持っていないクラフトを無効にしてください。\nデイリークエストの上限は自動的に変更されます。\nデフォルトでは全ての設定が有効で、上限は 7/7 です|r",
        SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6チャットへのメッセージ送信|r",
        SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6チャット内のメッセージを有効または無効にします。|r\n|c00FF00この設定はアカウント全体に適用されます|r",
        SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6履歴の自動削除期間|r",
        SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6非アクティブになってから何日後に記録が削除されるか。|r\n|c00FF00この設定はアカウント全体に適用されます|r\n|cFF0000注意|r\n|cFFFFFFもしキャラクターを一人以上削除した場合 - スライダーを最大左の数字 2 に合わせてください、二日後に古い（削除された）キャラクターの記録が履歴から削除されます、アドオンはあなたのキャラクターにはアクセスできません、アドオンは履歴を読むだけです！|r\nゲームの仕様です",
        SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00キャラクター履歴:|r",
        SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000注意!!!|r\n全てのキャラクターの完全な履歴を取得するために、各キャラクターに少なくとも一度ログインしてください！|r",
        SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r |r自動クリーンアップ：古い記録を%d件削除しました。",
        SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFキャラクターの進捗状況:|r |c00FF00%d/%d|r 全員完了！",
        SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFキャラクターの進捗状況: |r%s%d|r/|r%s%d|r: |r%s",
    },



    ["de"] = { -- Немецкий
      SI_CRAFTINGDAILYNOTIF_ALCHEMY = "|t60:60:/esoui/art/icons/skilllinexp_alchemy.dds|t         |c00FF00Alchemie|r",
      SI_CRAFTINGDAILYNOTIF_BLACKSMITHING = "|t60:60:/esoui/art/icons/antiquities_ayleid_blacksmithing_station_anvil.dds|t         |cb5bfbbSchmiedekunst|r",
      SI_CRAFTINGDAILYNOTIF_ENCHANTING = "|t60:60:/esoui/art/icons/housing_sys_str_drufsrune002.dds|t         |cFF7276Verzauberung|r",
      SI_CRAFTINGDAILYNOTIF_CLOTHING = "|t60:60:/esoui/art/icons/justice_stolen_clothing_001.dds|t         |cffddcaSchneiderei|r",
      SI_CRAFTINGDAILYNOTIF_PROVISIONING = "|t60:60:/esoui/art/icons/justice_stolen_food_001.dds|t         |cFFFFFFVersorgung|r",
      SI_CRAFTINGDAILYNOTIF_WOODWORKING = "|t60:60:/esoui/art/icons/crafting_woodworking_rough_ruby_ash.dds|t         |cD2691ETischlerei|r",
      SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING = "|t60:60:/esoui/art/icons/antiquities_ornate_necklace_5.dds|t         |c1E90FFJuwelierkunst|r",
      SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP = "|cff0000Diese Einstellung gilt nur für den aktuellen Charakter!!! Richten Sie alle anderen Charaktere separat ein!!!|r",
      SI_CRAFTINGDAILYNOTIF_SETTINGS = "|c98fb98Einstellungen|r",
SI_CRAFTINGDAILYNOTIF_CRAFTINGS = "|cADD8E6Aktive Handwerke|r",
      SI_CRAFTINGDAILYNOTIF_NOTE = "|c98fb98Deaktivieren Sie Handwerke, die der Charakter nicht hat.\nDas Limit für tägliche Aufgaben ändert sich automatisch.\nStandardmäßig sind alle Einstellungen aktiviert, das Limit beträgt 7/7|r",
      SI_CRAFTINGDAILYNOTIF_CHAT = "|cADD8E6Nachrichten senden im Chat|r",
      SI_CRAFTINGDAILYNOTIF_CHAT_N = "|cADD8E6Nachrichten im Chat ein- oder ausschalten.|r\n|c00FF00Diese Einstellung gilt für das gesamte Konto|r",
      SI_CRAFTINGDAILYNOTIF_DELETE = "|cADD8E6Zeitraum für Auto-Löschung der Historie|r",
      SI_CRAFTINGDAILYNOTIF_DELETE_N = "|cADD8E6Nach wie vielen Tagen Inaktivität werden Einträge gelöscht.|r\n|c00FF00Diese Einstellung gilt für das gesamte Konto|r\n|cFF0000ACHTUNG|r\n|cFFFFFFWenn Sie einen oder mehrere Charaktere gelöscht haben - stellen Sie den Schieberegler ganz nach links auf die Zahl 2, nach zwei Tagen werden die Einträge alter (gelöschter) Charaktere aus der Historie gelöscht, das Addon hat keinen Zugriff auf Ihre Charaktere, das Addon liest nur die Historie!|r\nSo ist es spieltechnisch bedingt",
      SI_CRAFTINGDAILYNOTIF_HISTORY = "|c00FF00CHARAKTER-HISTORIE:|r",
      SI_CRAFTINGDAILYNOTIF_INFO = "|cFF0000ACHTUNG!!!|r\nLoggen Sie sich mindestens einmal mit jedem Ihrer Charaktere ein, um die vollständige Historie aller Ihrer Charaktere zu erhalten!",
      SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP = "|cFFD700[Crafting Daily]|r Automatische Bereinigung: Es wurden %d alte Einträge gelöscht.",
      SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED = "|cFFFFFFFortschritt der Charaktere:|r |c00FF00%d/%d|r Alle haben es geschafft!",
      SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT = "|cFFFFFFFortschritt der Charaktere: |r%s%d|r/|r%s%d|r: |r%s",
    }

}

-- *** Translation block end *** --



CraftingDailyNotification.lastProgressMessage = nil 
CraftingDailyNotification.allCompletedReported = false



-- *** Skill block *** --

CraftingDailyNotification.CRAFTING_SKILLS = {
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_ALCHEMY, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_ENCHANTING, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_BLACKSMITHING, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_CLOTHING, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_PROVISIONING, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_WOODWORKING, enabled = true },
    { name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_JEWELRYCRAFTING, enabled = true }
}


-- *** Item id block *** --

local TRACKED_ITEM_IDS = {
    57851, 58131, 58503, 58504, 58505, 58506, 58507, 58508, 58509, 71234, 121298,
    58519, 58520, 58521, 58522, 58523, 58524, 58525, 58526, 58527, 71233, 121297,
    147607, 147608, 147609, 147610, 147611, 147612, 147613, 147614, 147615, 147616,
    58528, 58529, 58530, 58531, 58532, 58533, 58534, 59735, 59736, 71236, 121300,
    59705, 59706, 59707, 59708, 59709, 59710, 71238, 121302, 59714, 59715, 59716,
    59717, 59718, 59719, 59720, 59721, 59723, 59724, 59725, 71237, 121301, 58510,
    58511, 58512, 58513, 58514, 58515, 58516, 58517, 58518, 71235, 121299, 138801,
    138802, 138803, 138804, 138805
}



-- *** Автоматическая чистка ВСЕХ игровых аккаунтов согласно их настройкам. UTC time *** --

    function CraftingDailyNotification:CraftingDaily_CheckAllAccounts()
    local todayTimestamp = os.time(os.date("!*t"))
    CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp = todayTimestamp
    for accountKey, accountData in pairs(CraftingDailyNotificationSavedVariables) do
        if not string.find(accountKey, "^@") then 
            do break end 
        end
        local cleanupDays = accountData.settings.accountCleanupDays or 300
        local thresholdTimestamp = todayTimestamp - cleanupDays * 86400

        local removedCount = 0
        for charName, charData in pairs(accountData) do
            if charName == "settings" or type(charData) ~= "table" or not charData.lastActivityDateTS then 
                do break end 
            end

            if charData.lastActivityDateTS < CraftingDailyNotificationSavedVariables._globalLastCleanupTimestamp then
                if charData.lastActivityDateTS < thresholdTimestamp then
                    CraftingDailyNotificationSavedVariables[accountKey][charName] = nil
                    removedCount = removedCount + 1
                end
            end
        end

        if accountData.settings.enableChatMessages and removedCount > 0 then
            d(string.format(L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP, removedCount))
        end
    end
end



-- *** Сначала полностью инициализируем данные *** --

    function CraftingDailyNotification:Initialize()
    self:InitializeSavedVariables()
    self:CreateSettings()
    self:RegisterEvents()
    self:CraftingDaily_CheckAllAccounts()
    end



-- *** Инициализация данных С РАЗДЕЛЕНИЕМ ПО АККАУНТАМ *** --
    function CraftingDailyNotification:InitializeSavedVariables()
    local currentCharName = GetUnitName("player")
    local currentAccount = "@" .. GetDisplayName()
    local today = GetDateStringFromTimestamp(GetTimeStamp())
    if not CraftingDailyNotificationSavedVariables[currentAccount] then
    CraftingDailyNotificationSavedVariables[currentAccount] = {}
    end



-- *** Создаем общие настройки аккаунта (единоразово) *** --
    local accSettings = CraftingDailyNotificationSavedVariables[currentAccount].settings
    if not accSettings then
    CraftingDailyNotificationSavedVariables[currentAccount].settings = {
    enableChatMessages = true,
    accountCleanupDays = 300, 
    }
    end



-- *** Инициализируем таблицу для текущего персонажа ВНУТРИ аккаунта *** --
    local charTable = CraftingDailyNotificationSavedVariables[currentAccount][currentCharName]
    if not charTable then
    CraftingDailyNotificationSavedVariables[currentAccount][currentCharName] = {
    lastActivityDateTS = GetTimeStamp(),
    todayCount = 0,
    isCompletedForToday = false,
    craftingSkills = {},
    }
    else
    if not charTable.lastActivityDateTS then
    charTable.lastActivityDateTS = GetTimeStamp()
    end
end



-- *** Гарантируем наличие таблицы навыков
    if not CraftingDailyNotificationSavedVariables[currentAccount][currentCharName].craftingSkills then
    CraftingDailyNotificationSavedVariables[currentAccount][currentCharName].craftingSkills = {}
    end



-- *** Синхронизируем включенные навыки со списком констант
    for _, skill in ipairs(self.CRAFTING_SKILLS) do
    local charSkills = CraftingDailyNotificationSavedVariables[currentAccount][currentCharName].craftingSkills
    if charSkills[skill.name] == nil then
    charSkills[skill.name] = skill.enabled
    end
end



-- *** Сбрасываем прогресс текущего дня ТОЛЬКО для этого аккаунта
    self:ResetAllCharactersForNewDay(currentAccount)

-- *** Обновляем дату входа конкретно для текущего персонажа
    local data = CraftingDailyNotificationSavedVariables[currentAccount][currentCharName]
    local lastDateStr = GetDateStringFromTimestamp(data.lastActivityDateTS)
    if lastDateStr ~= today then
    data.lastActivityDateTS = GetTimeStamp()
    data.todayCount = 0
    data.isCompletedForToday = false
    end

    zo_callLater(function() self:SendAccountProgressReport(currentAccount) end, 500)
    self:SaveData()
    end

-- *** Функция принудительного сброса прогресса у всех чаров КОНКРЕТНОГО аккаунта --
    function CraftingDailyNotification:ResetAllCharactersForNewDay(accountKey)
    local today = GetDateStringFromTimestamp(GetTimeStamp()) 
    for charName, charData in pairs(CraftingDailyNotificationSavedVariables[accountKey]) do
        if type(charData) == "table" and charName ~= "settings" then
            if charData.lastActivityDateTS then
                local charLastDate = GetDateStringFromTimestamp(charData.lastActivityDateTS)
                if charLastDate ~= today then
                    charData.todayCount = 0
                    charData.isCompletedForToday = false
                end
            end
        end
    end
    if CraftingDailyNotificationSavedVariables._globalNotifyDate ~= today then
        CraftingDailyNotification.allCompletedReported = false
        CraftingDailyNotificationSavedVariables._globalNotifyDate = today
        self:SaveData()
    end
end



    function CraftingDailyNotification:ScanInventoryForInitialCount(_, dateKey)
    local currentCount = 0
    for slotIndex = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local itemId = GetItemId(BAG_BACKPACK, slotIndex)
        if TRACKED_ITEM_IDS[itemId] then
            currentCount = currentCount + GetSlotStackSize(BAG_BACKPACK, slotIndex)
        end
    end
    for slotIndex = 0, GetBagSize(BAG_BANK) - 1 do
        local itemId = GetItemId(BAG_BANK, slotIndex)
        if TRACKED_ITEM_IDS[itemId] then
            currentCount = currentCount + GetSlotStackSize(BAG_BANK, slotIndex)
        end
    end
    return currentCount
end



    function CraftingDailyNotification:OnItemAdded(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    local charName = GetUnitName("player")
    local accountName = "@" .. GetDisplayName()
    local data = CraftingDailyNotificationSavedVariables[accountName][charName]

    if not data or not data.todayCount then return end

    local itemId = GetItemId(bagId, slotIndex)
    local found = false
    for _, trackedId in ipairs(TRACKED_ITEM_IDS) do
        if itemId == trackedId then
            found = true
            break
        end
    end
    if not found then return end
    local newCount = data.todayCount + stackCountChange
    data.todayCount = newCount
    zo_callLater(function() self:CheckAndSendCompletionStatus(data.todayCount, accountName) end, 200)
    self:SaveData()
    zo_callLater(function() self:SendAccountProgressReport(accountName) end, 500)
end



    function CraftingDailyNotification:GetActiveSkillLimit()
    local count = 0
    local charName = GetUnitName("player")
    local accountName = "@" .. GetDisplayName()
    local charSkills = CraftingDailyNotificationSavedVariables[accountName][charName].craftingSkills
    for i = 1, #self.CRAFTING_SKILLS do
        if charSkills[self.CRAFTING_SKILLS[i].name] == true then
            count = count + 1
        end
    end
    return count
end



    function CraftingDailyNotification:CheckAndSendCompletionStatus(currentCount, accountName)
    local charName = GetUnitName("player")
    local data = CraftingDailyNotificationSavedVariables[accountName][charName]
    if not data then return end
    local limit = self:GetActiveSkillLimit()
    if currentCount >= limit and not data.isCompletedForToday then
        data.isCompletedForToday = true
        local accountKey = "@" .. GetDisplayName()
        local totalChars = 0
        local completedChars = 0
        local activeDaysThreshold = CraftingDailyNotificationSavedVariables[accountKey].settings.accountCleanupDays
        for charName, charData in pairs(CraftingDailyNotificationSavedVariables[accountKey]) do
            if type(charData) == "table" and charName ~= "settings" and charData.lastActivityDateTS then
                local daysInactive = (GetTimeStamp() - charData.lastActivityDateTS) / (24 * 60 * 60)
                if daysInactive <= activeDaysThreshold then
                    totalChars = totalChars + 1
                    local personalLimit = 0
                    for _, skill in ipairs(self.CRAFTING_SKILLS) do
                        if charData.craftingSkills[skill.name] == true then
                            personalLimit = personalLimit + 1
                        end
                    end
                    if personalLimit > 0 and charData.todayCount >= personalLimit then
                        completedChars = completedChars + 1
                    end
                end
            end
        end
    CHAT_SYSTEM:AddMessage(string.format(
    "%s[Crafting Daily]: %d/%d (%d%%) " .. L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_ALL_COMPLETED,
    COLOR_GREEN,
    currentCount,
    limit,
    math.floor((currentCount / limit) * 100),
    completedChars,
    totalChars))
        zo_callLater(function() self:SendAccountProgressReport(accountKey) end, 500)
    end
end



    function CraftingDailyNotification:SendAccountProgressReport(accountKey)
    if CraftingDailyNotification.allCompletedReported then return end
    local today = GetDateStringFromTimestamp(GetTimeStamp()) 
    local totalChars = 0          
    local incompleteChars = {}    
    local completedChars = 0      
    local activeDaysThreshold = CraftingDailyNotificationSavedVariables[accountKey].settings.accountCleanupDays
    for charName, data in pairs(CraftingDailyNotificationSavedVariables[accountKey]) do
        if type(data) == "table" and charName ~= "settings" and data.lastActivityDateTS then
            local daysInactive = (GetTimeStamp() - data.lastActivityDateTS) / (24 * 60 * 60)
            if daysInactive <= activeDaysThreshold then
                totalChars = totalChars + 1
                local personalLimit = 0
                for _, skill in ipairs(self.CRAFTING_SKILLS) do
                    if data.craftingSkills[skill.name] == true then
                        personalLimit = personalLimit + 1
                    end
                end
                if personalLimit > 0 then
                    if data.todayCount < personalLimit then
                        table.insert(incompleteChars, string.format("%s%s|r (%d/%d)", COLOR_RED, charName, data.todayCount, personalLimit))
                    else
                        completedChars = completedChars + 1   
                    end
                end
            end
        end
    end
    if totalChars == 0 then return end
    if #incompleteChars > 0 then
        local incompleteList = table.concat(incompleteChars, ", ")
    local message = string.format(
    L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_PROGRESS_REPORT,
    COLOR_GREEN, completedChars,
    COLOR_YELLOW, totalChars,
    incompleteList)
local currentStatus = string.format("%d/%d", completedChars, totalChars)
if CraftingDailyNotification.lastProgressMessage ~= currentStatus then
    if CraftingDailyNotificationSavedVariables[accountKey].settings.enableChatMessages then
        CHAT_SYSTEM:AddMessage(message)
    end
    CraftingDailyNotification.lastProgressMessage = currentStatus
end
    else
        CraftingDailyNotification.allCompletedReported = true
        CraftingDailyNotification.lastProgressMessage = nil
        self:SaveData()
    end
end



    function CraftingDailyNotification:GetCharacterHistorySummary()
    local lines = {""}
    local sortableData = {}
    local accountName = "@" .. GetDisplayName()
    if not CraftingDailyNotificationSavedVariables[accountName] then return "" end
    local cleanupDays = CraftingDailyNotificationSavedVariables[accountName].settings.accountCleanupDays or 300
    local todayTimestamp = os.time(os.date("!*t")) -- Текущее время обрезается до полуночи UTC
    local thresholdTimestamp = todayTimestamp - cleanupDays * 86400 -- Порог в секундах от начала суток
    for charName, data in pairs(CraftingDailyNotificationSavedVariables[accountName]) do
        if charName ~= "settings"
           and type(data) == "table"
           and data.lastActivityDateTS                      
           and data.lastActivityDateTS >= thresholdTimestamp 
        then
            local limit = 0
            for _, skill in ipairs(self.CRAFTING_SKILLS) do
                if data.craftingSkills[skill.name] == true then
                    limit = limit + 1
                end
            end
            if limit > 0 then
                local color = COLOR_GREEN
                if data.todayCount < limit then
                    color = COLOR_RED
                elseif data.todayCount == 0 then
                    color = COLOR_WHITE
                end
                local day, month, year = string.match(GetDateStringFromTimestamp(data.lastActivityDateTS), "(%d+)%.(%d+)%.(%d+)")
                table.insert(sortableData, {
                    text = string.format("%s [%s.%s/%s] - %s%d/%d|r", 
                                        charName, day, month, year, color, data.todayCount, limit),
                    timestamp = data.lastActivityDateTS
                })
            end
        end
    end
    table.sort(sortableData, function(a, b)
        return a.timestamp > b.timestamp
    end)
    for i = 1, #sortableData do
        table.insert(lines, sortableData[i].text)
    end
    return #lines > 1 and table.concat(lines, "\n") or "\nНет данных."
end




    function CraftingDailyNotification:CreateSettings()
    local panelData = {
        type = "panel",
        name = "|c98fb98Crafting Daily Notification|r",
        author = "|c00FF00@Eswagrom|r",
        version = "|cff80801.0|r",
        registerForRefresh = true,
    }



    LAM:RegisterAddonPanel("CraftingDailyNotification_Panel", panelData)
    local mainControls = {
        {
            type = "header",
            name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_CRAFTINGS,
            width = "full",
        },



        {
            type = "description",
            text = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_NOTE,
        },
    }



    table.insert(mainControls, {
            type = "header",
            width = "full",
    })   



    for _, skill in ipairs(self.CRAFTING_SKILLS) do
        table.insert(mainControls, {
            type = "checkbox",
            name = skill.name,
            tooltip = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_SKILL_TOOLTIP,
            getFunc = function() 
                local charName = GetUnitName("player") 
                local accountName = "@" .. GetDisplayName()
                return CraftingDailyNotificationSavedVariables[accountName][charName].craftingSkills[skill.name]
            end,
            setFunc = function(value) 
                local charName = GetUnitName("player") 
                local accountName = "@" .. GetDisplayName()
                if not CraftingDailyNotificationSavedVariables[accountName][charName].craftingSkills then
                    CraftingDailyNotificationSavedVariables[accountName][charName].craftingSkills = {}
                end
                CraftingDailyNotificationSavedVariables[accountName][charName].craftingSkills[skill.name] = value
                self:SendAccountProgressReport(accountName)
            end,
            default = true,
            width = "half",
        })
    end



    table.insert(mainControls, {
            type = "header",
            width = "full",
    })   



    table.insert(mainControls, {
        type = "checkbox",
        name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_CHAT,
        tooltip = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_CHAT_N,
        getFunc = function() 
            local accountName = "@" .. GetDisplayName()
            return CraftingDailyNotificationSavedVariables[accountName].settings.enableChatMessages 
        end,
        setFunc = function(value) 
            local accountName = "@" .. GetDisplayName()
            CraftingDailyNotificationSavedVariables[accountName].settings.enableChatMessages = value 
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", "CraftingDailyNotification_Panel")
        end,
        default = true,
        width = "full",
    })



    table.insert(mainControls, {
        type = "slider",
        name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_DELETE,
        tooltip = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_DELETE_N,
        min = 2,
        max = 360,
        step = 1,
        decimals = 0,
        getFunc = function() 
            local accountName = "@" .. GetDisplayName()
            return CraftingDailyNotificationSavedVariables[accountName].settings.accountCleanupDays 
        end,
        setFunc = function(value) 
            local accountName = "@" .. GetDisplayName()
            CraftingDailyNotificationSavedVariables[accountName].settings.accountCleanupDays = value
            -- Логика очистки старых записей осталась прежней
            local cleanupThreshold = GetTimeStamp() - (value * 24 * 60 * 60)
            local removedCount = 0
            for savedCharName, data in pairs(CraftingDailyNotificationSavedVariables[accountName]) do
                if savedCharName ~= "settings" and type(data) == "table" and data.lastActivityDateTS then
                  if data.lastActivityDateTS < cleanupThreshold then
                        CraftingDailyNotificationSavedVariables[accountName][savedCharName] = nil
                        removedCount = removedCount + 1
                    end
                end
            end
            if CraftingDailyNotificationSavedVariables[accountName].settings.enableChatMessages and removedCount > 0 then
                d(string.format(L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_AUTOCLEANUP, removedCount))
            end
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", "CraftingDailyNotification_Panel")
        end,
        default = 300, -- Дефолт стоит на 300
        width = "full",
    })




    local optionsData = {
        {
            type = "submenu",
            name = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_SETTINGS,
            controls = mainControls
        },



        {
            type = "description",
            title = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_HISTORY,
        },   


    
        {
            type = "description",
            text = self:GetCharacterHistorySummary(),
        },



        {
            type = "header",
            color = COLOR_WHITE,
            width = "full",
        },



        {
            type = "description",
            title = L[LANGUAGE].SI_CRAFTINGDAILYNOTIF_INFO,
        },   


    
    }

    LAM:RegisterOptionControls("CraftingDailyNotification_Panel", optionsData)
    end

    function CraftingDailyNotification:RegisterEvents()

    EVENT_MANAGER:UnregisterForEvent("CraftingDailyNotification", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:OnItemAdded(...) end)
    EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_GAMEPLAY_DAY_TIME_CHANGED, function() 
        self:CraftingDaily_CheckAllAccounts() 
    end)
    EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_PLAYER_ACTIVATED, function(...) self:InitializeSavedVariables(...) end)
    EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_LOGOUT_REQUESTED, function(...) self:SaveData() end)
    EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_ADD_ON_RELOADED, function(name) if name == "CraftingDailyNotification" then self:SaveData() end end)
    end

    function CraftingDailyNotification:SaveData()
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", "CraftingDailyNotification_Panel")
    end

    local function OnAddonLoaded(event, addonName)
    if addonName == "CraftingDailyNotification" then
        CraftingDailyNotification:Initialize()
        CraftingDailyNotification:CraftingDaily_CheckAllAccounts()
    end
end
EVENT_MANAGER:RegisterForEvent("CraftingDailyNotification", EVENT_ADD_ON_LOADED, OnAddonLoaded)