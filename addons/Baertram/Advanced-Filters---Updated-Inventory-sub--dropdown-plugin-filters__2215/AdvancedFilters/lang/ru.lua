local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings

local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " ОШИБКА")

local strings = {
    --SHARED
    All = "Все",

    --WEAPON
    OneHand = "Одноручное",
    TwoHand = "Двуручное",
    DestructionStaff = "Посох разрушения",

    TwoHandAxe = "2H "..util.Localize(SI_WEAPONTYPE1),
    TwoHandSword = "2H "..util.Localize(SI_WEAPONTYPE3),
    TwoHandHammer = "2H "..util.Localize(SI_WEAPONTYPE2),

    --Clothing = ,
    Shield = "Щит",
    Jewelry = "Бижутерия",
    Vanity = "Разное",

    Head = "Голова",
    Chest = "Торс",
    Shoulders = "Плечи",
    Hand = "Руки",
    Waist = "Пояс",
    Legs = "Ноги",
    Feet = "Ступни",
    Ring = "Кольцо",
    Neck = "Шея",

    Repair = "Ремонт",

    --MATERIALS
    Blacksmithing = "Кузнечество",
    Clothier = "Шитье",
    Woodworking = "Древообработка",
    Alchemy = "Алхимия",
    Enchanting = "Зачарование",
    Provisioning = "Кулинария",

    --MISCELLANEOUS
    Glyphs = "Глифы",
    Bait = "Наживка",

    --DROPDOWN CONTEXT MENU
    ResetToAll = "Сбросить все",
    InvertDropdownFilter = "Инвертировать фильтр: %s",

    --LAM settings menu
    lamDescription = "Показывать дополнительные фильтры в инвентаре, для разделения типов предметов",
    lamHideItemCount = "Скрыть количество предметов",
    lamHideItemCountTT = "Скрыть информацию о количестве предметов, показанных в \" (...) \", в нижней строке инвентаря",
    lamHideItemCountColor = "Цвет количество предметов",
    lamHideItemCountColorTT = "Установить цвет количество предметов в нижней строке инвентаря",
    lamHideSubFilterLabel = "Скрыть метку подфильтра",
    lamHideSubFilterLabelTT = "Скрыть метку описания подфильтра в верхней строке инвентаря (слева от кнопок подфильтров).",

    --Error messages
    errorCheckChatPlease = afPrefixError .. " Пожалуйста, прочитайте сообщение об ошибке чата!",
}
setmetatable(strings, {__index = enStrings})

local light = " (Легкий)"
local medium = " (средний)"
strings.Head_Light = strings.Head .. light
strings.Chest_Light = strings.Chest .. light
strings.Shoulders_Light = strings.Shoulders .. light
strings.Hand_Light = strings.Hand .. light
strings.Waist_Light = strings.Waist .. light
strings.Legs_Light = strings.Legs .. light
strings.Feet_Light = strings.Feet .. light
strings.Head_Light = strings.Head .. medium
strings.Chest_Medium = strings.Chest .. medium
strings.Shoulders_Medium = strings.Shoulders .. medium
strings.Hand_Medium = strings.Hand .. medium
strings.Waist_Medium = strings.Waist .. medium
strings.Legs_Medium = strings.Legs .. medium
strings.Feet_Medium = strings.Feet .. medium
local ringStr = " (" .. strings.Ring .. ")"
strings.Arcane_Ring = strings.Arcane .. ringStr
strings.Bloodthirsty_Ring = strings.Bloodthirsty .. ringStr
strings.Harmony_Ring = strings.Harmony .. ringStr
strings.Healthy_Ring = strings.Healthy .. ringStr
strings.Infused_Ring = strings.Infused .. ringStr
strings.Intricate_Ring = strings.Intricate .. ringStr
strings.Ornate_Ring = strings.Ornate .. ringStr
strings.Robust_Ring = strings.Robust .. ringStr
strings.Swift_Ring = strings.Swift .. ringStr
strings.Triune_Ring = strings.Triune .. ringStr
local neckStr = " (" .. strings.Neck .. ")"
strings.Arcane_Neck = strings.Arcane .. neckStr
strings.Bloodthirsty_Neck = strings.Bloodthirsty .. neckStr
strings.Harmony_Neck = strings.Harmony .. neckStr
strings.Healthy_Neck = strings.Healthy .. neckStr
strings.Infused_Neck = strings.Infused .. neckStr
strings.Intricate_Neck = strings.Intricate .. neckStr
strings.Ornate_Neck = strings.Ornate .. neckStr
strings.Robust_Neck = strings.Robust .. neckStr
strings.Swift_Neck = strings.Swift .. neckStr
strings.Triune_Neck = strings.Triune .. neckStr

setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings