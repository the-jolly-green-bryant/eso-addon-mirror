TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "Справка"
L.INFO_TT = "Прячет строки зоны и /say, в которых есть гиперссылка на гильдию. Остальной чат не трогает. Системное окно приглашения не блокирует.\nЗолото / баги: почта @Tetsurion."

L.ENABLED = "Прятать рекламу гильдий"
L.ENABLED_TT = "Главный выключатель. Вкл = строки зоны/say со ссылкой на гильдию не появляются в твоём чате."

L.FILTER_ZONE = "Фильтровать чат зоны"
L.FILTER_ZONE_TT = "Все каналы зоны, включая языковые (область / zone / Zone / …). По умолчанию вкл."

L.FILTER_SAY = "Фильтровать /say"
L.FILTER_SAY_TT = "Локальный say. По умолчанию вкл."

L.FILTER_YELL = "Фильтровать /yell"
L.FILTER_YELL_TT = "По умолчанию выкл. Включи, если простыни идут ещё и в yell."

L.HIDDEN_LABEL = "Скрыто за сессию"
L.HIDDEN_TT = "Сколько строк отсечено с входа. Сбрасывается при ReloadUI."
