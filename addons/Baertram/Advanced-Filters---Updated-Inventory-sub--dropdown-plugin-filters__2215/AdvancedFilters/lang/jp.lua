local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings

local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " エラー")

local strings = {
    --WEAPON
    OneHand = "片手武器",
    TwoHand = "両手武器",
    DestructionStaff = "攻撃の杖",

    TwoHandAxe = "両手"..util.Localize(SI_WEAPONTYPE1),
    TwoHandSword = "両手"..util.Localize(SI_WEAPONTYPE3),
    TwoHandHammer = "両手"..util.Localize(SI_WEAPONTYPE2),

    --ARMOR
    Clothing = "鎧",
    Shield = "盾",
    Jewelry = "宝飾品",
    Vanity = "ガラクタ",

    Head = "頭",
    Chest = "胴体",
    Shoulders = "ショルダー",
    Hand = "手",
    Waist = "腰",
    Legs = "脚",
    Feet = "足",
    Ring = "指輪",
    Neck = "首",

    Repair = "修理",

    --MATERIALS
    Blacksmithing = "鍛冶",
    Clothier = "裁縫",
    Woodworking = "木工",
    Alchemy = "錬金術",
    Enchanting = "付呪",
    Provisioning = "調理",

    --MISCELLANEOUS
    Glyphs = "グリフ",
    Bait = "餌",

    --DROPDOWN CONTEXT MENU
    ResetToAll = "全てリセット",
    InvertDropdownFilter = "フィルターを反転: %s",

    --Error messages
    errorCheckChatPlease = afPrefixError .. " チャットエラーメッセージをお読みください!",
}
setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings