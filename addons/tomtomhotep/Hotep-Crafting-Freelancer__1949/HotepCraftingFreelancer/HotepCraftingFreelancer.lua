-- ****************************************************************************
--                                  namespace
-- ****************************************************************************




local COLOR_HOTEP = "|c3366ff"
local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"
local COLOR_GREEN = "|c00ff00"
local COLOR_BLUE = "|c0066ff"
local COLOR_PURPLE = "|cff00ff"
local COLOR_YELLOW = "|cffff00"
local COLOR_GRAY = "|c7f7f7f"
local COLOR_WHITE = "|cffffff"


local ROWCOLOR_RED = ZO_ColorDef:New(1, 0, 0, 1)
local ROWCOLOR_GREEN = ZO_ColorDef:New(0, 1, 0, 1)
local ROWCOLOR_YELLOW = ZO_ColorDef:New(1, 1, 0, 1)
local ROWCOLOR_YELLOWDIM = ZO_ColorDef:New(0.6, 0.6, 0, 1)
local ROWCOLOR_CYAN = ZO_ColorDef:New(0, 1, 1, 1)
local ROWCOLOR_PURPLE = ZO_ColorDef:New(1, 0, 1, 1)
local ROWCOLOR_PURPLEDIM = ZO_ColorDef:New(0.6, 0, 0.6, 1)
local ROWCOLOR_WHITE = ZO_ColorDef:New(1, 1, 1, 1)
local ROWCOLOR_GRAY = ZO_ColorDef:New(0.5, 0.5, 0.5, 1)
local ROWCOLOR_BLACK = ZO_ColorDef:New(0, 0, 0, 1)



--[[
FCOIS_CON_ICON_GEAR_1				= 2
FCOIS_CON_ICON_GEAR_2  				= 4
FCOIS_CON_ICON_GEAR_3				= 6
FCOIS_CON_ICON_GEAR_4				= 7
FCOIS_CON_ICON_GEAR_5				= 8
FCOIS_CON_ICON_DYNAMIC_1			= 13
FCOIS_CON_ICON_DYNAMIC_2			= 14
FCOIS_CON_ICON_DYNAMIC_3			= 15
FCOIS_CON_ICON_DYNAMIC_4			= 16
FCOIS_CON_ICON_DYNAMIC_5			= 17
FCOIS_CON_ICON_DYNAMIC_6			= 18
FCOIS_CON_ICON_DYNAMIC_7			= 19
FCOIS_CON_ICON_DYNAMIC_8			= 20
FCOIS_CON_ICON_DYNAMIC_9			= 21
FCOIS_CON_ICON_DYNAMIC_10			= 22
--]]



local MAIL_MAX_BODY = MAIL_MAX_BODY_CHARACTERS

if (not MAIL_MAX_BODY) then
  MAIL_MAX_BODY = 700
end


local MAX_ITEMS_PER_ORDER_CONFIRM = 4

local CHAT_ORDERING_TIMEOUT = 3    -- minutes


--[[ * TODO *
  
  add /hotep forceextra
  reminders for over-due orders
  make selecting a mat easier in the "Add New Purchase" window
  make mule window work for withdrawing from Housing Storage
  support in-person trading window for order delivery & payment
  recognizing glyphs for the enchantments needed for the items
  auto-crafting using LibLazyCrafting
  create companion addon for faster customer ordering
--]]

--[[ ** 2.0
- automatic price-setting using LibPrice integration
--]]




HotepCraft = {
  name = "HotepCraftingFreelancer",
  title = "Hotep Crafting Freelancer",
  chattitle = "Hotep\194\174 Crafting Freelancer",
  fancytitle = zo_strformat("<<1>>Hotep\194\174|r <<2>>Crafting Freelancer|r", COLOR_HOTEP, COLOR_MSG),
  displayVersion = "2.03",
  version = 1,
  savedVars = "HotepCraftVars",
  svNamespaces = {"Settings","OrderDB","Prices","Claim","Skills","Books","TradeIn","AutoPricing","ManPriced","ChatLog"},
  
  me = GetUnitDisplayName("player"),
  mycharacter = GetUnitName("player"),
  
  onlinesince = GetTimeStamp(),
  setupgood = false,
  sleeping = false,
  busy = false,
  lastGuildAdvert = {0, 0, 0, 0, 0},
  
  neworder = {
    params = {
      item = {},
      stage = nil,
      response = "",
      checkingout = false,
      itemnum = 1,
      validator = {},
      editingitem = false,
      T = {
        chat = {},
        val = {},
      },
    },
    order = {},
    free = false,
  },
  
  mailfails = {},
  mailoops = function (reason, mailer) HotepCraft:MailFailed(reason, mailer) end,
  
  OrderTimer = 0,
  
  SavedRequests = {},
  
  MAILITEMSTAKEN = false,
  BOUGHTSOMETHING = false,
  LOOTED = false,
  KIOSKOPEN = false,
  KIOSKSUCCESS = false,
  SAVEDENTRY = nil,
  
  Debugger_am_I = (GetUnitDisplayName("player") == "@tomtomhotep"),
  
  ScannedMailIDs = {},
  
  IIfA = {
    items = {},
    traits = {},
    styles = {},
    improves = {},
    potents = {},
    essances = {},
  }
}



local disturbme = true



local HotepToolsLib = LibStub("HotepToolsLib", false)

local clone = HotepToolsLib.HotepCommonFuncs.clone
local explode = HotepToolsLib.HotepCommonFuncs.explode
local in_array = HotepToolsLib.HotepCommonFuncs.in_array
local array_key_exists = HotepToolsLib.HotepCommonFuncs.array_key_exists
local array_indexof = HotepToolsLib.HotepCommonFuncs.array_indexof
local array_without = HotepToolsLib.HotepCommonFuncs.array_without
local array_glob = HotepToolsLib.HotepCommonFuncs.array_glob
local array_find = HotepToolsLib.HotepCommonFuncs.array_find
local uuid = HotepToolsLib.HotepCommonFuncs.uuid
local array_keys = HotepToolsLib.HotepCommonFuncs.array_keys
local array_append = HotepToolsLib.HotepCommonFuncs.array_append
local empty = HotepToolsLib.HotepCommonFuncs.empty
---@local spairs @class iterator
local spairs = HotepToolsLib.HotepCommonFuncs.spairs
local eyesort = HotepToolsLib.HotepCommonFuncs.eyesort
local badscene = HotepToolsLib.HotepCommonFuncs.badscene

local EVENT_MAILSEND_DEFERRED = HotepToolsLib.EVENT_MAILSEND_DEFERRED
local EVENT_MAILSEND_ATTEMPTED = HotepToolsLib.EVENT_MAILSEND_ATTEMPTED
local EVENT_MAILREAD_STARTED = HotepToolsLib.EVENT_MAILREAD_STARTED
local EVENT_MAILREAD_ENDED = HotepToolsLib.EVENT_MAILREAD_ENDED



---@local OT @class OT
local OT = LibStub("HotepOrderTaker", false)

local LAM = LibStub("LibAddonMenu-2.0", false)

---@local STD @class LibSaveToDisk
local STD = LibStub("LibSaveToDisk", false)

---@local LL @class LL
local LL = LibStub("LibItemLinks", false)

local LP = LibStub("LibPrice", true) or LibPrice




local PROFESSION_SMITH = 1
local PROFESSION_CLOTH = 2
local PROFESSION_WOOD = 3

local PROFESSIONS = {PROFESSION_SMITH, PROFESSION_CLOTH, PROFESSION_WOOD}


local SKILL_INDEX = {}

local function initSKILLINDEX()
  local _
  _, SKILL_INDEX[PROFESSION_SMITH] = GetCraftingSkillLineIndices(CRAFTING_TYPE_BLACKSMITHING)
  _, SKILL_INDEX[PROFESSION_CLOTH] = GetCraftingSkillLineIndices(CRAFTING_TYPE_CLOTHIER)
  _, SKILL_INDEX[PROFESSION_WOOD] = GetCraftingSkillLineIndices(CRAFTING_TYPE_WOODWORKING)
end


local ORDER_STATUS_WAITING = "waiting"
local ORDER_STATUS_CLAIMED = "claimed"
local ORDER_STATUS_DELIVERED = "delivered"


local CLAIM_TOO_LONG = (3600 * 48)     -- 48 hours in seconds

local CLAIM_TOO_LONG_HOURS = math.floor(CLAIM_TOO_LONG / 3600)

local CHAR_TYPE_CRAFTER = "Crafter"
local CHAR_TYPE_MULE = "Mule"
local CHAR_TYPE_NONE = "Neither"
local CHAR_TYPE_OT = "Order Taker"


local CHARTYPES = {
  CHAR_TYPE_NONE, CHAR_TYPE_CRAFTER, CHAR_TYPE_MULE, CHAR_TYPE_OT,
}


-- pricing engines

local PRICES_OFF = 0
local PRICES_MM = 1
local PRICES_TTC = 2
local PRICES_ATT = 3

local PRICECHOICES_OFF = 'Set All Prices Manually'
local PRICECHOICES_MM = 'Use Master Merchant (MM)'
local PRICECHOICES_TTC = 'Use Tamriel Trade Center (TTC)'
local PRICECHOICES_ATT = "Use Arkadius' Trade Tools (ATT)"

local PRICE_ENGINE_NAMES = {
  [PRICES_MM] = 'Master Merchant (MM)', 
  [PRICES_TTC] = 'Tamriel Trade Center (TTC)', 
  [PRICES_ATT] = "Arkadius' Trade Tools (ATT)",
}


-- pricing engine options

local PRICES_MM_AVG = 1
local PRICES_MM_LOW = 2
local PRICES_MM_HIGH = 3
local PRICES_TTC_AVG = 4
local PRICES_TTC_MIN = 5
local PRICES_TTC_MAX = 6
local PRICES_TTC_SUGGLOW = 7
local PRICES_TTC_SUGGHIGH = 8
local PRICES_TTC_SUGGMID = 9
local PRICES_ATT_AVG = 10

local PRICECHOICES_MM_AVG = 'Use Averaged Price'
local PRICECHOICES_MM_LOW = 'Use Lowest Graph Price'
local PRICECHOICES_MM_HIGH = 'Use Highest Graph Price'
local PRICECHOICES_TTC_AVG = 'Use "Average"'
local PRICECHOICES_TTC_MIN = 'Use "Minimum" (lowest listing)'
local PRICECHOICES_TTC_MAX = 'Use "Maximum" (highest listing)'
local PRICECHOICES_TTC_SUGGLOW = 'Use the low of the "Suggested Price" range.'
local PRICECHOICES_TTC_SUGGHIGH = 'Use the high of the "Suggested Price" range.'
local PRICECHOICES_TTC_SUGGMID = 'Use a custom percent between the low and high of the "Suggested Price" range.'
local PRICECHOICES_ATT_AVG = 'Use ATT Average Price.'


local PRICES_ENGINES = {PRICES_OFF, PRICES_MM, PRICES_TTC, PRICES_ATT}

local PRICES_ENGINES_CHOICES = {PRICECHOICES_OFF, PRICECHOICES_MM, PRICECHOICES_TTC, PRICECHOICES_ATT}

local PRICES_OPTIONS = {
  [PRICES_OFF] = {PRICES_OFF},
  [PRICES_MM] = {PRICES_MM_AVG, PRICES_MM_LOW, PRICES_MM_HIGH},
  [PRICES_TTC] = {PRICES_TTC_AVG, PRICES_TTC_MIN, PRICES_TTC_MAX, 
                  PRICES_TTC_SUGGLOW, PRICES_TTC_SUGGHIGH, PRICES_TTC_SUGGMID},
  [PRICES_ATT] = {PRICES_ATT_AVG},
}

local PRICES_OPTIONS_CHOICES = {
  [PRICES_OFF] = {PRICECHOICES_OFF},
  [PRICES_MM] = {PRICECHOICES_MM_AVG, PRICECHOICES_MM_LOW, PRICECHOICES_MM_HIGH},
  [PRICES_TTC] = {PRICECHOICES_TTC_AVG, PRICECHOICES_TTC_MIN, PRICECHOICES_TTC_MAX, 
                  PRICECHOICES_TTC_SUGGLOW, PRICECHOICES_TTC_SUGGHIGH, PRICECHOICES_TTC_SUGGMID},
  [PRICES_ATT] = {PRICECHOICES_ATT_AVG},
}



-- ****************************************************************************
--                                  templates
-- ****************************************************************************

---@local ORDER @class ORDER
local ORDER = {
  asof = 0,
  ordernumber = 0,
  uuid = "",
  customer = "",
  guildie = false,
  comments = "",
  Status = ORDER_STATUS_WAITING,
  ordertime = 0,
  claimtime = 0,
  shiptime = 0,
  itemtotal = 0,
  feetotal = 0,
  adjustment = 0,
  reason = "",
  grandtotal = 0,
  level = 1,
  traits = 0,
  sets = 0,
  enchants = 0,
  items = {},
  items_delivered = 0,
  paidInFull = false,
  RETURNED = nil,
  deposit_reqd = 0,
  deposit_taken = 0,
  TRADINGMATS = false,
  MatTrades = {},
}

local CLAIMITEM = {
  itemindex = 0,
  crafted = false,
  uniqueid = false,
  improveDone = false,
  enchantDone = false,
}


---@local WAITINGCLAIM @classdef WAITINGCLAIM
local WAITINGCLAIM = {
  orderuuid = "",
  grandtotal = 0,              -- not used for waiting-deposit records
  halfPayment = false,         -- not used for waiting-deposit records
  partialCharge1 = 0,          -- not used for waiting-deposit records
  partialCharge2 = 0,          -- not used for waiting-deposit records
  paymentDue = 0,           -- deposit due for waiting-deposit records
  customer = "",
  paid = false,                -- not used for waiting-deposit records
}


---@local WAITINGTRADES @class WAITINGTRADES
local WAITINGTRADES = {
  orderuuid = "",
  customer = "",
}


local NEWORDER_INIT = {
  params = {
    item = {},
    stage = nil,
    response = "",
    checkingout = false,
    itemnum = 1,
    validator = {},
    editingitem = false,
    T = {
      chat = {},
      val = {},
    },
  },
  order = {},
  free = false,
}

---@local SAVEDREQUEST @class SAVEDREQUEST
local SAVEDREQUEST = {
  handle = "",
  request = "",
}


---@local MatPROFITS @class MatPROFITS
local MatPROFITS = {
  items = {},         -- array of @class PROFITREC
  traits = {},
  styles = {},
  improves = {},
  potents = {},
  essances = {},
}


---@local MatTRADES @class MatTrades
local MatTRADES = {
  items = {},         -- array of @class MatTradeRec
  traits = {},
  styles = {},
  improves = {},
  potents = {},
  essances = {},
  MatDiscount = 0,
}


---@local AUTOPRICESETTINGS @classdef AUTOPRICESETTINGS
local AUTOPRICESETTINGS = {
  base = {
    engine = PRICES_OFF,
    option = PRICES_OFF,
    ttc_sugg_pct = 50,
    addfixed = true,        -- false = add a percent
    addvalue = 0,           -- value to add in gold or percent
    allow_edit = false,     -- allow individual prices to be overridden manually
    pricesUpdated = false,
    tradeins = {
      same = true,            -- true = engine, option, & ttc_sugg_pct are same as selling pricing
      engine = PRICES_OFF,
      option = PRICES_OFF,
      ttc_sugg_pct = 50,
      addfixed = true,        -- false = add a percent
      addvalue = 0,           -- value to add in gold or percent
      allow_edit = false,     -- allow individual prices to be overridden manually
    },
  },
  fees = {
    engine = PRICES_OFF,
    option = PRICES_OFF,
    ttc_sugg_pct = 50,
    addfixed = true,        -- false = add a percent
    addvalue = 0,           -- value to add in gold or percent
    allow_edit = false,     -- allow individual prices to be overridden manually
    pricesUpdated = false,
    tradeins = {
      same = true,            -- true = engine, option, & ttc_sugg_pct are same as selling pricing
      engine = PRICES_OFF,
      option = PRICES_OFF,
      ttc_sugg_pct = 50,
      addfixed = true,        -- false = add a percent
      addvalue = 0,           -- value to add in gold or percent
      allow_edit = false,     -- allow individual prices to be overridden manually
    },
  },
}


---@local MANUALLYSET @classdef MANUALLYSET
local MANUALLYSET = {
  base = {
    mats = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},     -- table: key is ItemName, value is manually-set-price
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
    tradeins = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
  },
  fees = {
    mats = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
    tradeins = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
  },
}


local function MANUALLYSETable()
  return {
    mats = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},     -- table: key is ItemName, value is manually-set-price
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
    tradeins = {
      [ITEMTYPE_BLACKSMITHING_MATERIAL] = {},
      [ITEMTYPE_BLACKSMITHING_BOOSTER] = {},
      [ITEMTYPE_CLOTHIER_MATERIAL] = {},
      [ITEMTYPE_CLOTHIER_BOOSTER] = {},
      [ITEMTYPE_WOODWORKING_MATERIAL] = {},
      [ITEMTYPE_WOODWORKING_BOOSTER] = {},
      [ITEMTYPE_ARMOR_TRAIT] = {},
      [ITEMTYPE_WEAPON_TRAIT] = {},
      [ITEMTYPE_STYLE_MATERIAL] = {},
      [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {},
      [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {},
    },
  }
end



-- ****************************************************************************
--                                  data
-- ****************************************************************************


local IMPROVES = {
  [1] = { 5, 4, 3, 2 },
  [2] = { 7, 5, 4, 3 },
  [3] = { 10, 7, 5, 4 },
  [4] = { 20, 14, 10, 8 },
}


local RESINS = {
  [PROFESSION_SMITH] = {
    [1] = "Honing Stone",
    [2] = "Dwarven Oil",
    [3] = "Grain Solvent",
    [4] = "Tempering Alloy",
  },
  [PROFESSION_CLOTH] = {
    [1] = "Hemming",
    [2] = "Embroidery",
    [3] = "Elegant Lining",
    [4] = "Dreugh Wax",
  },
  [PROFESSION_WOOD] = {
    [1] = "Pitch",
    [2] = "Turpen",
    [3] = "Mastic",
    [4] = "Rosin",
  },
}



local ARM_TRAITS = {
  ["Sturdy"] = {
    jewel = "Quartz",
    Type = ITEM_TRAIT_TYPE_ARMOR_STURDY,
    __i = 1,
  },
  ["Impenetrable"] = {
    jewel = "Diamond",
    Type = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
    __i = 2,
  },
  ["Reinforced"] = {
    jewel = "Sardonyx",
    Type = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
    __i = 3,
  },
  ["Well-Fitted"] = {
    jewel = "Almandine",
    Type = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
    __i = 4,
  },
  ["Training"] = {
    jewel = "Emerald",
    Type = ITEM_TRAIT_TYPE_ARMOR_TRAINING,
    __i = 5,
  },
  ["Infused"] = {
    jewel = "Bloodstone",
    Type = ITEM_TRAIT_TYPE_ARMOR_INFUSED,
    __i = 6,
  },
  ["Invigorating"] = {
    jewel = "Garnet",
    Type = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
    __i = 7,
  },
  ["Divines"] = {
    jewel = "Sapphire",
    Type = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
    __i = 8,
  },
  ["Nirnhoned"] = {
    jewel = "Fortified Nirncrux",
    Type = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
    __i = 9,
  },
}

local WEP_TRAITS = {
  ["Powered"] = {
    jewel = "Chysolite",
    Type = ITEM_TRAIT_TYPE_WEAPON_POWERED,
    __i = 1,
  },
  ["Charged"] = {
    jewel = "Amethyst",
    Type = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
    __i = 2,
  },
  ["Precise"] = {
    jewel = "Ruby",
    Type = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
    __i = 3,
  },
  ["Infused"] = {
    jewel = "Jade",
    Type = ITEM_TRAIT_TYPE_WEAPON_INFUSED,
    __i = 4,
  },
  ["Defending"] = {
    jewel = "Turquoise",
    Type = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
    __i = 5,
  },
  ["Training"] = {
    jewel = "Carnelian",
    Type = ITEM_TRAIT_TYPE_WEAPON_TRAINING,
    __i = 6,
  },
  ["Sharpened"] = {
    jewel = "Fire Opal",
    Type = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
    __i = 7,
  },
  ["Decisive"] = {
    jewel = "Citrine",
    Type = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
    __i = 8,
  },
  ["Nirnhoned"] = {
    jewel = "Potent Nirncrux",
    Type = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
    __i = 9,
  },
}

local POTENCY = {
  [1] = {
    glyph = "Trifling",
    ['+'] = "Jora",
    ['-'] = "Jode",
  },
  [10] = {
    glyph = "Petty",
    ['+'] = "Jera",
    ['-'] = "Ode",
  },
  [20] = {
    glyph = "Minor",
    ['+'] = "Odra",
    ['-'] = "Jayde",
  },
  [30] = {
    glyph = "Moderate",
    ['+'] = "Edora",
    ['-'] = "Pojode",
  },
  [40] = {
    glyph = "Strong",
    ['+'] = "Pora",
    ['-'] = "Hade",
  },
  [51] = {
    glyph = "Major",
    ['+'] = "Denara",
    ['-'] = "Idode",
  },
  [53] = {
    glyph = "Greater",
    ['+'] = "Rera",
    ['-'] = "Pode",
  },
  [55] = {
    glyph = "Grand",
    ['+'] = "Derado",
    ['-'] = "Kedeko",
  },
  [57] = {
    glyph = "Splendid",
    ['+'] = "Rekura",
    ['-'] = "Rede",
  },
  [60] = {
    glyph = "Monumental",
    ['+'] = "Kura",
    ['-'] = "Kude",
  },
  [65] = {
    glyph = "Superb",
    ['+'] = "Rejera",
    ['-'] = "Jehade",
  },
  [66] = {
    glyph = "Truly Superb",
    ['+'] = "Repora",
    ['-'] = "Itade",
  },
}



---
-- @param t @class table
-- @return @class table
local function priceclone(t)
  local c = {}
  
  if (type(t) == "number") then
    for i = 1,t do
      table.insert(c, 0)
    end
    return c
  end
  
  for k,_ in pairs(t) do
    c[k] = 0
  end
  
  return c
end




-- ****************************************************************************
--                                  saved vars
-- ****************************************************************************


---@local Settings @class SETTINGS
local Settings
---@local OrderDatabase @class OrderDatabase
local OrderDatabase
---@local PriceList @class PriceList
local PriceList
---@local CurrentClaim @class CURRENTCLAIM
local CurrentClaim
---@local Bookkeeping @class BOOKKEEPING
local Bookkeeping
---@local TradePrices @class TradePriceList
local TradePrices
---@local AutoPricing @class AUTOPRICESETTINGS
local AutoPricing
---@local ManuallyPricedItems @class MANUALLYSET
local ManuallyPricedItems




local SV_SETTINGS = 1
local SV_ORDERS = 2
local SV_PRICES = 3
local SV_CLAIM = 4
local SV_SKILLS = 5
local SV_BOOKKEEPING = 6
local SV_TRADEIN = 7
local SV_AUTOPRICE = 8
local SV_MANUALS = 9
local SV_CHATLOG = 10



local defaultVariables = {
  {
    Settings = {
      noadverts = false,
      advertper = 20,
      guildlimit = 10,
      advert = "",
      moreinfo = "",
      maxorders = 200,
      informFees = false,
      UISmithingWindowX = false,
      UISmithingWindowY = false,
      UIMuleWindowX = false,
      UIMuleWindowY = false,
      UIMuleWindowW = false,
      UIMuleWindowH = false,
      UIMuleWindowX_crafter = false,
      UIMuleWindowY_crafter = false,
      UseFCOis = false,
      busyWhisperAll = false,
      dndWhisper = false,
      characters = {},
      dep1_thresh = 0,
      dep1_amt = 0,
      dep2_thresh = 0,
      dep2_amt = 0,
      dep3_thresh = 0,
      dep3_amt = 0,
      allowTradeIns = false,
    }
  },
  
  {
    OrderDatabase = {
      asof = 0,
      modified = 0,
      total = {
        [ORDER_STATUS_WAITING] = 0,
        [ORDER_STATUS_CLAIMED] = 0,
        [ORDER_STATUS_DELIVERED] = 0,
      },
      everdone = 0,
      totalsales = 0,
      waittime = 0,
      crafttime = 0,
      adjusted = 0,
      everadjust = 0,
      lastordernumber = 1000,
      uuids = {},
      orders = {
        [ORDER_STATUS_WAITING] = {},
        [ORDER_STATUS_CLAIMED] = {},
        [ORDER_STATUS_DELIVERED] = {},
      },
    }
  },
  
  {
    PriceList = {
      fixedfee = 100,
      itemfee = 10,
      discount = 50,
      traitfee = {
        armor = priceclone(ARM_TRAITS),
        weapon = priceclone(WEP_TRAITS),
      },
      setfees = priceclone(OT.ARM_SETS()),
      stylefees = priceclone(OT.MOTIFS()),
      improvefees = {
        [PROFESSION_SMITH] = {0, 0, 0, 0},
        [PROFESSION_CLOTH] = {0, 0, 0, 0},
        [PROFESSION_WOOD] = {0, 0, 0, 0},
      },
      enchant = {
        pot = priceclone(POTENCY),
        ess = {
          armor = priceclone(OT.GLYPHS("armor")),
          weapon = priceclone(OT.GLYPHS("weapon")),
        },
      },
      price = {
        metals = priceclone(OT.METALS()),
        medarm = priceclone(OT.MCLOTHS()),
        lightarm = priceclone(OT.LCLOTHS()),
        woods = priceclone(OT.WOODS()),
      },
    }
  },
  
  {
    CurrentClaim = {
      orderindex = 0,
      orderuuid = "",
      orderitems = {},
      craftingtypes = {},
      numcrafted = 0,
      finished = false,
      items_delivered = 0,
      halfpayment = false,
      partialPay1 = 0,
      partialPay2 = 0,
      WaitingForMoney = {},
      WaitingForDeposit = {},
      WaitingForMats = {},
    }
  },
  
  {
    Skills = {
      improvQty = {
        [PROFESSION_SMITH] = {0, 0, 0, 0},
        [PROFESSION_CLOTH] = {0, 0, 0, 0},
        [PROFESSION_WOOD] = {0, 0, 0, 0},
      },
      crafterHas = {},
    }
  },
  
  {
    Bookkeeping = {
      paidorders = 0,   -- # of paid orders (excludes free gifts)
      GrossSales = 0,
      GrossReceipts = 0,
      outstandingOrders = 0,
      outstandingAmt = 0,
      cogs = 0,
      motifCosts = 0,
      postage = 0,
      ProfitPer = 0,       -- average gross profit amt per paid ordr
      profit = 0,          -- total net profit
      summary = false,              -- display summary or details
      purchases = {
        items = {},             -- arrays of @class COSTREC
        traits = {},
        styles = {},
        improves = {},
        potents = {},
        essances = {},
        motifs = {},
      },
      purchaseIndex = {},    -- keys are matnames, values are arrays of indexes into proper sub-table of purchases
    }
  },
  
  {
    TradeIn = {
      traitfee = {
        armor = priceclone(ARM_TRAITS),
        weapon = priceclone(WEP_TRAITS),
      },
      stylefees = priceclone(OT.MOTIFS()),
      improvefees = {
        [PROFESSION_SMITH] = {0, 0, 0, 0},
        [PROFESSION_CLOTH] = {0, 0, 0, 0},
        [PROFESSION_WOOD] = {0, 0, 0, 0},
      },
      enchant = {
        pot = priceclone(POTENCY),
        ess = {
          armor = priceclone(OT.GLYPHS("armor")),
          weapon = priceclone(OT.GLYPHS("weapon")),
        },
      },
      price = {
        metals = priceclone(OT.METALS()),
        medarm = priceclone(OT.MCLOTHS()),
        lightarm = priceclone(OT.LCLOTHS()),
        woods = priceclone(OT.WOODS()),
      },
    }
  },
  
  {
    AutoPricing = clone(AUTOPRICESETTINGS),
  },
  
  {
    ManuallyPricedItems = clone(MANUALLYSET),
  },
  
  {
    ChatLog = {}
  },
  
}

local savedVariables = {
  vars = {}, 
  skills = {
    improvQty = {[PROFESSION_SMITH] = {},[PROFESSION_CLOTH] = {},[PROFESSION_WOOD] = {}},
    crafterHas = {},
  },
  chatlog = {},
}

function savedVariables:Load(space)
  local ns = HotepCraft.svNamespaces[space]
  
  self.vars[space] = ZO_SavedVars:NewAccountWide(HotepCraft.savedVars, HotepCraft.version, ns, defaultVariables[space])
  
  if (space == SV_SETTINGS) then
    Settings = self.vars[space].Settings
    
    if (type(Settings.busyWhisperAll) == "nil") then
      Settings.busyWhisperAll = false
    end
    
    if (type(Settings.characters) == "nil") then
      Settings.characters = {}
    end
    
    if (not Settings.informFees) then
      Settings.informFees = false
    end
    
    if (not Settings.allowTradeIns) then
      Settings.allowTradeIns = false
    end
    
    if (not Settings.noadverts) then
      Settings.noadverts = false
    end
    
    if (not Settings.dep1_amt) then
      Settings.dep1_amt = 0
      Settings.dep1_thresh = 0
      Settings.dep2_amt = 0
      Settings.dep2_thresh = 0
      Settings.dep3_amt = 0
      Settings.dep3_thresh = 0
    end
    
  elseif (space == SV_ORDERS) then
    OrderDatabase = self.vars[space].OrderDatabase
  elseif (space == SV_PRICES) then
    PriceList = self.vars[space].PriceList
  elseif (space == SV_CLAIM) then
    CurrentClaim = self.vars[space].CurrentClaim
  elseif (space == SV_SKILLS) then
    self.skills = self.vars[space].Skills
    
    if (not self.skills.crafterHas) then
      self.skills.crafterHas = {}
    end
  elseif (space == SV_BOOKKEEPING) then
    Bookkeeping = self.vars[space].Bookkeeping
    if (not Bookkeeping.paidorders) then Bookkeeping.paidorders = 0 end
    if (not Bookkeeping.postage) then Bookkeeping.postage = 0 end
    if (not Bookkeeping.GrossReceipts) then Bookkeeping.GrossReceipts = 0 end
    if (not Bookkeeping.outstandingOrders) then Bookkeeping.outstandingOrders = 0 end
    if (not Bookkeeping.outstandingAmt) then Bookkeeping.outstandingAmt = 0 end
  elseif (space == SV_TRADEIN) then
    TradePrices = self.vars[space].TradeIn
  elseif (space == SV_AUTOPRICE) then
    AutoPricing = self.vars[space].AutoPricing
  elseif (space == SV_MANUALS) then
    ManuallyPricedItems = self.vars[space].ManuallyPricedItems
  elseif (space == SV_CHATLOG) then
    self.vars[space].ChatLog = {}
    self.chatlog = self.vars[space].ChatLog
  end
end

function savedVariables:AppendChatLog(t)
  if (not HotepCraft.Debugger_am_I) then return end
  
  self.vars[SV_CHATLOG].ChatLog = array_append(self.vars[SV_CHATLOG].ChatLog, t)
  self.chatlog = self.vars[SV_CHATLOG].ChatLog
end



local msgWithName = function (msg, color)
                      local x = zo_strformat("[<<1>>] <<2>>", HotepCraft.name, msg)
                      savedVariables:AppendChatLog({x})
                      HotepToolsLib.HotepCommonFuncs.msgWithName(msg, color, HotepCraft.name) 
                    end



-- ****************************************************************************
--                                  utilities
-- ****************************************************************************



local function TableToString(t, indent, tableHistory)
  indent = indent or "."
  tableHistory = tableHistory or {}
  
  local out = ""
  
  for k, v in pairs(t) do
    local vType = type(v)
    out = out .. indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v) .. "\n"
    
    if (vType == "table") then
      if (tableHistory[v]) then
        out = out .. indent .. "Avoiding cycle on table...\n"
      else
        tableHistory[v] = true
        out = out .. TableToString(v, indent .. " ", tableHistory)
      end
    end
  end
  
  return out
end




local function commas(n, fmt)   -- format a number with commas
  
  if (type(n) ~= "number") then return n end
  
  local neg = ""
  if (n < 0) then
    n = - n
    neg = "-"
  end
  
  if (not fmt) then fmt = "%.2f" end
  
  if ((n == math.floor(n)) and (n == math.ceil(n))) then
    return neg .. FormatIntegerWithDigitGrouping(n, ",", 3)
  else
    local s = string.format(fmt, n)
    local parts = explode(".", s)
    local i = FormatIntegerWithDigitGrouping(tonumber(parts[1]), ",", 3)
    return neg .. i .. "." .. parts[2]
  end
end


local function msgDebug(msg, color)
  if (HotepCraft.me ~= "@tomtomhotep") then return end
  
  if (not color) then
    color = COLOR_YELLOW
  end
    
  if (type(msg) == "table") then
    if (type(color) == "boolean") then
      color = COLOR_PURPLE
    end
    
    local t = explode("\n", TableToString(msg))
    for _,s in ipairs(t) do
      msgWithName("DBG: " .. s, color);
    end
  else
    if (type(color) == "boolean") then
      color = COLOR_PURPLE
      msg = "*** " .. msg .. " ***"
    end
    
    msg = "DBG: " .. msg
    
    msgWithName(msg, color);
  end
end

function HotepCraft.msgDebug(msg, color)
  msgDebug(msg, color)
end


function HotepCraft.GetItemUniqueId(bag, slot)
  
  local x = function (z)
    if (type(z) == 'nil') then
      return 'nil'
    else
      return z
    end
  end
  
  local _, _, _, _, _, et, is, _ = GetItemInfo(bag, slot)
  
  local it, sit = GetItemType(bag, slot)
  
  local u = Id64ToString(GetItemUniqueId(bag, slot))
  local a = GetItemArmorType(bag, slot)
  local w = GetItemWeaponType(bag, slot)
  local t = GetItemTrait(bag, slot)
  local rl = GetItemRequiredLevel(bag, slot)
  local rc = GetItemRequiredChampionPoints(bag, slot)
  local cn = GetItemCreatorName(bag, slot)
  
  local v = {x(u), x(et), x(is), x(it), x(sit), x(a), x(w), x(t), x(rl), x(rc), x(cn)}
  
  return table.concat(v, '#')
end



local function newOrderUUID()
  local a = tostring(GetTimeStamp())
  local b = uuid()
  math.randomseed(math.random(GetFrameTimeMilliseconds()) + GetGameTimeMilliseconds())
  return zo_strformat("<<1>>-<<2>>", a, b)
end




local Timer = HotepToolsLib.HotepUtilities.Timer
local MailQueue = HotepToolsLib.HotepUtilities.MailQueue
local Iterator = HotepToolsLib.HotepUtilities.Iterator
---@local ChatQueue @class ChatQueue
local ChatQueue = HotepToolsLib.HotepUtilities.ChatQueue





---@local timer_Advert @class Timer
local timer_Advert = Timer:New(3, function () HotepCraft.Advertise() end, nil, true)





local MustSaveToDisk = {
  one = false,
  two = false,
  three = false,
}

function MustSaveToDisk:One()
  self.one = true
  self:Prompt()
end

function MustSaveToDisk:Two()
  self.two = true
  self:Prompt()
end

function MustSaveToDisk:Three()
  self.three = true
  self:Prompt()
end

function MustSaveToDisk:Prompt(now)
  if ((self.one and self.two and self.three) or now) then
    STD.CriticalChange(HotepCraft.name)
  end
end







-- ****************************************************************************
--                                  main code
-- ****************************************************************************


local function isFCOalive()
  return (FCOIS and FCOIS.addonVars.gPlayerActivated and (FCOMarkItem or FCOIS.MarkItem))
end

function HotepCraft.FCOMarkItem(...)
  local fun = FCOMarkItem or FCOIS.MarkItem
  
  fun(...)
end


local function BuildIIfA(xmats, mats)
  HotepCraft.IIfA = clone(MatPROFITS)
  
  if (not IIfA) then return end
  
  local itypes = {
    items = {
      [PROFESSION_SMITH] = ITEMTYPE_BLACKSMITHING_MATERIAL,
      [PROFESSION_CLOTH] = ITEMTYPE_CLOTHIER_MATERIAL,
      [PROFESSION_WOOD] = ITEMTYPE_WOODWORKING_MATERIAL,
    },
    traits = {
      armor = ITEMTYPE_ARMOR_TRAIT,
      weapon = ITEMTYPE_WEAPON_TRAIT,
    },
    styles = {ITEMTYPE_STYLE_MATERIAL},
    improves = {
      [PROFESSION_SMITH] = ITEMTYPE_BLACKSMITHING_BOOSTER,
      [PROFESSION_CLOTH] = ITEMTYPE_CLOTHIER_BOOSTER,
      [PROFESSION_WOOD] = ITEMTYPE_WOODWORKING_BOOSTER,
    },
    potents = {ITEMTYPE_ENCHANTING_RUNE_POTENCY},
    essances = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE},
  }
  
  local ix = function(mattype, prof, aw)
    if (in_array(mattype, {"items","improves"})) then
      return prof
    elseif (mattype == "traits") then
      return aw
    else
      return 1
    end
  end
  -- end local function ix
  
  
  
  
  for mattype,mattable in pairs(xmats) do
    for matname,v in pairs(mattable) do
      local itemType = itypes[mattype][ix(mattype, v.prof, v.aw)]
      
      local need = mats[mattype][matname]
      
      if (itemType == ITEMTYPE_BLACKSMITHING_MATERIAL) then
        matname = matname .. " Ingot"
      elseif (itemType == ITEMTYPE_WOODWORKING_MATERIAL) then
        matname = "Sanded " .. matname
      end
      
      if (not array_key_exists(matname, HotepCraft.IIfA[mattype])) then
        HotepCraft.IIfA[mattype][matname] = {total = 0, needed = need, locs = {}}
      end
      
      local itemLink = LL.GetItemLink(itemType, matname)
      
      if (itemLink) then
        local t = IIfA:QueryAccountInventory(itemLink)
        if (t and t.locations) then
          for _,x in ipairs(t.locations) do
            table.insert(HotepCraft.IIfA[mattype][matname].locs, 
                              {
                                name = x.name,
                                qty = x.itemsFound,
                                bagid = x.bagLoc,
                              })
            HotepCraft.IIfA[mattype][matname].total = HotepCraft.IIfA[mattype][matname].total + x.itemsFound
          end
        end
      else
        HotepCraft.IIfA[mattype][matname].nolink = true
      end
    end
  end
end
-- end local function BuildIIfA(mats)


---
-- @param matlist @class table
-- @param mattype @class table
-- @return @class string
local function IIfAString(mattype, ...)
  
  if (not IIfA) then return "IIfA Not Installed" end
  
  
  local out = ""
  
  for matname,mattable in pairs(HotepCraft.IIfA[mattype]) do
    out = out .. zo_strformat("<<1>><<2>>: |r", COLOR_YELLOW, matname)
    out = out .. zo_strformat("Need: <<1>>; ", mattable.needed)
    
    local loccolor = false
    
    if (mattable.nolink) then
      out = out .. zo_strformat("<<1>>Have: ?|r\n", COLOR_PURPLE)
    else
      if (mattable.needed > mattable.total) then
        out = out .. zo_strformat("<<1>>Have: <<2>>|r\n", COLOR_RED, mattable.total)
      else
        out = out .. zo_strformat("<<1>>Have: <<2>>|r\n", COLOR_GREEN, mattable.total)
        loccolor = true
      end
      
      local colorfunc = function(t)
        if (not loccolor) then return COLOR_MSG end
        if ((t.bagid == BAG_BANK) or (t.bagid == BAG_SUBSCRIBER_BANK)) then
          return COLOR_GREEN
        elseif (((t.bagid == BAG_BACKPACK) or (t.bagid == BAG_VIRTUAL))
                and (t.name == HotepCraft.me)) then
          return COLOR_GREEN
        else
          return COLOR_MSG
        end
      end
      
      for i,t in ipairs(mattable.locs) do
        out = out .. zo_strformat("\226\128\148   <<1>><<2>>|r: <<3>>\n", colorfunc(t), t.name, t.qty)
      end
    end
    
--    out = out .. "\n"
  end
  
  if (select("#", ...) > 0) then
    return out .. IIfAString(...)
  end
  
  return out
end



---
-- @return @class table
local function GetPlayerGuilds()
  local n = GetNumGuilds()
  if (n < 1) then return false end
  
  local names = {}
  
  for i = 1, n do
    local id = GetGuildId(i)
    table.insert(names, GetGuildName(id))
  end
  
  return names
end

---
-- @param handle @class string
-- @return boolean
local function IsAGuildie(handle)
  local n = GetNumGuilds()
  if (n < 1) then return false end
  
  for i = 1, n do
    local id = GetGuildId(i)
    if (GetGuildMemberIndexFromDisplayName(id, handle)) then
      return true
    end
  end
  
  return false
end




--local function hotep(s)
--  return ("hotepcgs " .. s)
--end

local function HOTEP(s)
  if (type(s) == "nil") then return "HOTEPCF" end
  return ("#HOTEPCF#" .. s)
end


local function orderAsOf(order)
  if (order.Status == ORDER_STATUS_WAITING) then
    return order.ordertime
  elseif (order.Status == ORDER_STATUS_CLAIMED) then
    return order.claimtime
  elseif (order.Status == ORDER_STATUS_DELIVERED) then
    return order.shiptime
  end
end




function HotepCraft:MailFailed(reason, mailer)
  local handle = mailer.mailout.to
  
  local msg = zo_strformat("Failed to send mail to <<1>>", handle)
  
  ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, msg)
  
--    if (not array_key_exists(handle, self.mailfails)) then
--      self.mailfails[handle] = {
--        q = {},
--        t = Timer(2, HotepCraft.AskNotifyGotMail, handle, true)
--      }
--    end
--
--    table.insert(self.mailfails[handle].q, mailer)
--
--    self.mailfails[handle].t:Start()
end


--function HotepCraft:ResendFailMail(handle)
--  
--  if (not array_key_exists(handle, self.mailfails)) then return end
--  
--  if (not disturbme) then return false end
--  
--  local q = clone(self.mailfails[handle].q)
--  local n = #q
--  
--  self.mailfails[handle].t:Destroy()
--  self.mailfails[handle] = nil
--  
--  if (n < 1) then return end
--  
--  local ss = "Please be patient while <<1>> mails are re-sent to <<2>>, which previously failed to send."
--  msgWithName(zo_strformat(ss, n, handle))
--  
--  for i = 1, n do
--    MailQueue:Requeue(q[i])
--  end
--  
--  collectgarbage()
--end



function HotepCraft.UpdateOrderStatus(Status, uuid)
  ---@local order @class ORDER
  local order = HotepCraft.ReturnOrderByUUID(uuid)
  
  if (not order) then return false end
  
  local oldstatus = order.Status
  
  
  if (oldstatus ~= Status) then
    order.Status = Status
    HotepCraft.MoveOrder(uuid, oldstatus, Status)
    HotepCraft.ToggleUIMain(false)
    HotepCraft.ToggleUIOrderDetail(false)
    
    msgWithName("Order Database has been updated.", COLOR_RED)
  end
end


function HotepCraft:OnGotChat(handle, msg)
  msg = string.lower(string.gsub(msg, '"', ''))
  msg = string.gsub(msg, "^%s*", '', 1)
  
  if (string.sub(handle, 1, 1) ~= "@") then
    handle = zo_strformat(SI_UNIT_NAME, handle)
  end
  
  if ((not disturbme or self.busy) and in_array(msg, {"price", "order", "info", "extra"}) and HotepCraft.setupgood) then
    ---@local saveit @class SAVEDREQUEST
    local saveit = clone(SAVEDREQUEST)
    saveit.handle = handle
    saveit.request = msg
    table.insert(HotepCraft.SavedRequests, saveit)
    msgWithName("Request Saved.  Respond later with: /hotep respond", COLOR_PURPLE)
  end
  
  if ((msg == "info") and disturbme and not self.sleeping and HotepCraft.setupgood) then
    local t = {}
    if (string.len(Settings.moreinfo) > 0) then table.insert(t, Settings.moreinfo) end
    if (IsAGuildie(handle)) then 
      table.insert(t, zo_strformat("As a fellow guildie, you get a <<1>>% discount!", PriceList.discount)) 
    end
    if (not self.busy) then table.insert(t, 'whisper "price" for a price-list, '..
                                            '"extra" for the list of Sets and Styles, or "order" to place an order') end
    if (#t > 0) then
      ChatQueue(10, "wisp", handle, nil, nil, t)
    end
  elseif ((msg == "price") and not self.sleeping and not self.busy and disturbme and HotepCraft.setupgood) then
    HotepCraft.SendPriceList(handle, msg)
  elseif ((msg == "extra") and not self.sleeping and not self.busy and disturbme and HotepCraft.setupgood) then
    HotepCraft.SendExtraPrices(handle)
  elseif ((msg == "order") and not self.sleeping and not self.busy and disturbme and HotepCraft.setupgood) then
    
    if ((string.sub(handle, 1, 1) ~= "@") and (PriceList.discount > 0)) then
      local t = {
        zo_strformat('Your whisper is coming to me "from <<1>>"', handle),
        'I need you to whisper from your @accountname, not your Character Name.',
        zo_strformat('Please type /tell <<1>> into the chat box, then whisper "order" again.', HotepCraft.me),
      }
      ChatQueue(10, "wisp", handle, nil, nil, t)
      return
    end
    
    self.busy = true
    self.neworder = clone(NEWORDER_INIT)
    self.neworder.order = clone(ORDER)
    self.neworder.order.customer = handle
    self.neworder.params.stage = nil
    self.TakeAnOrder()
  else
    self:OnGotOrderingResponse(handle, msg)
  end
end
-- end HotepCraft:OnGotChat


---@local timer_sendingpricing @class Timer
local timer_sendingpricing
---@local timer_mailingprices @class Timer
local timer_mailingprices


local function prices_mailsending(to, subject, body)
  timer_mailingprices:Start()
end

local function prices_maildeferred(to, subject, body)
  timer_mailingprices:Stop()
end


function HotepCraft.SendPriceList(handle, msg, invalid)
  if ((msg == "price") and not HotepCraft.sleeping and not HotepCraft.busy and disturbme and HotepCraft.setupgood) then
    
    if (timer_sendingpricing) then
      timer_sendingpricing:Start(2)
    else
      timer_sendingpricing = Timer:New(2, HotepCraft.NotSendingPricing, handle)
    end
    
    local x = {
      "What level equipment do you want a price list for? ",
      'Say a number between 1 and 50, --OR-- say "cp" followed by a number between 10 and 160.',
    }
    
    if (invalid) then
      table.insert(x, 1, "Invalid Response. Please remember you are communicating Directly with my Add-on.")
    end
    
    local foo = function()
      HotepCraft.TakingPriceRequest = true
    end
    
    ChatQueue:New(3, "wisp", handle, foo, nil, x)
    return
  elseif (HotepCraft.TakingPriceRequest) then
    msg = string.lower(string.gsub(msg, ' ', ''))
    
    if (tonumber(msg)) then
      local level = tonumber(msg)
      
      if ((1 <= level) and (level <= 50)) then
        local lev,_ = OT.LEVELS(level, "level", true)
        HotepCraft.SendPriceListForLevel(handle, lev)
        return
      else
        return HotepCraft.SendPriceList(handle, "price", true)
      end
    else   -- msg is not numeric
      msg = string.gsub(msg, 'cp', '')
      
      if (tonumber(msg)) then             -- cp rank
        local cp = tonumber(msg)
        
        if ((10 <= cp) and (cp <= 160)) then
          local level = 50 + math.floor(cp / 10)
          local lev,_ = OT.LEVELS(level, "level", true)
          HotepCraft.SendPriceListForLevel(handle, lev)
          return
        else
          return HotepCraft.SendPriceList(handle, "price", true)
        end
      else
        return HotepCraft.SendPriceList(handle, "price", true)
      end
    end
  end
end
-- end function HotepCraft.SendPriceList(handle)


function HotepCraft.NotSendingPricing(handle)
  HotepCraft.TakingPriceRequest = nil
  
  local x = false
  if (timer_sendingpricing and timer_sendingpricing.triggered) then
    x = "Price Request Timed Out."
    msgWithName(x, COLOR_PURPLE)
  end
  
  if (timer_sendingpricing) then
    timer_sendingpricing:Stop()
    timer_sendingpricing:Destroy()
    timer_sendingpricing = nil
  end
  
  if (x and handle) then
    HotepCraft.busy = false
    ChatQueue:New(3, "wisp", handle, nil, nil, {x})
  end
end
-- end HotepCraft.NotSendingPricing(handle)


function HotepCraft.SendPriceListForLevel(handle, lev, step)
  
  if (not step) then
    step = 1
    HotepCraft.busy = true
    HotepCraft.NotSendingPricing()
    
    HotepToolsLib.HotepMailReader.abort = true
    
    local x = {
      "Mailing Price Lists to you now...",
    }
    
    local foo = function()
      HotepCraft.SendPriceListForLevel(handle, lev, 1)
    end
    
    ChatQueue:New(3, "wisp", handle, foo, foo, x)
    return
  end
  
  local funcs = {
    HotepCraft.SendPriceListForMetalWeap,
    HotepCraft.SendPriceListForHeavyArm,
    HotepCraft.SendPriceListForMedArm,
    HotepCraft.SendPriceListForLightArm,
    HotepCraft.SendPriceListForWood,
    HotepCraft.SendPriceListForTraitFees,
    HotepCraft.SendPriceListForImprovFees,
    HotepCraft.SendPriceListForGlyphFees,
    HotepCraft.SendPriceListDone,
  }
  
  local foo = function()
    if (funcs[step]) then
      HotepToolsLib.HotepMailReader.abort = true
      timer_mailingprices.params = {handle = handle, lev = lev, step = step}
      funcs[step](handle, lev, step)
    end
  end
  
  CALLBACK_MANAGER:RegisterCallback(EVENT_MAILSEND_ATTEMPTED, prices_mailsending)
  CALLBACK_MANAGER:RegisterCallback(EVENT_MAILSEND_DEFERRED, prices_maildeferred)
  
  zo_callLater(foo, 1000)
end
-- end function HotepCraft.SendPriceListForLevel(handle, lev, step)


function HotepCraft.SendPriceListForMetalWeap(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local p1,_ = OT.PIECES("1h")
  local p2,_ = OT.PIECES("2h")
  
  local line = {"Impovements, Traits, and Enchantments cost extra.", ""}
  
  for k,v in ipairs(p1) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.metals, lev, "1h", k)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  for k,v in ipairs(p2) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.metals, lev, "2h", k)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Base Prices for <<1>> Metal Weapons", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Metal Weapon Pricelist to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForMetalWeap(handle, lev, step)


function HotepCraft.SendPriceListForHeavyArm(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local pieces,_ = OT.PIECES("heavy", true)
  
  local line = {"Impovements, Traits, and Enchantments cost extra.", ""}
  
  for k,v in ipairs(pieces) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.metals, lev, "heavy", k)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Base Prices for <<1>> Heavy Armor", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Heavy Armor Pricelist to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForHeavyArm(handle, lev, step)


function HotepCraft.SendPriceListForMedArm(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local pieces,_ = OT.PIECES("med", true)
  
  local line = {"Impovements, Traits, and Enchantments cost extra.", ""}
  
  for k,v in ipairs(pieces) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.medarm, lev, "med", k)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Base Prices for <<1>> Medium Armor", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Medium Armor Pricelist to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForMedArm(handle, lev, step)


function HotepCraft.SendPriceListForLightArm(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local pieces,_ = OT.PIECES("light", true)
  
  local line = {"Impovements, Traits, and Enchantments cost extra.", ""}
  
  for k,v in ipairs(pieces) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.lightarm, lev, "light", k)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Base Prices for <<1>> Light Armor", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Light Armor Pricelist to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForLightArm(handle, lev, step)


function HotepCraft.SendPriceListForWood(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local pieces = {
    ['dstaff'] = "Destruction Staves (any)",
    ['rstaff'] = "Resto Staff",
    ['bow'] = "Bow",
    ['shield'] = "Shield",
  }
  
  local line = {"Impovements, Traits, and Enchantments cost extra.", ""}
  
  for k,v in pairs(pieces) do
    local cost = OT.GetTotalUnitsPrice(PriceList.price.woods, lev, k, 1)
    local x = zo_strformat("<<1>>: <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Base Prices for <<1>> Woodwork", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Woodwork Pricelist to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForWood(handle, lev, step)


function HotepCraft.SendPriceListForTraitFees(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local line = {"ARMOR TRAITS:"}
  
  for trait,cost in pairs(PriceList.traitfee.armor) do
    local x = zo_strformat("<<1>>: add <<2>>g", trait, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  table.insert(line, "WEAPON TRAITS:")
  
  for trait,cost in pairs(PriceList.traitfee.weapon) do
    local x = zo_strformat("<<1>>: add <<2>>g", trait, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  local subj = "Trait Fees (any level)"
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Trait Fee List to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForTraitFees(handle, lev, step)


function HotepCraft.SendPriceListForImprovFees(handle, lev, step)
  
  local pieces,_ = OT.PIECES("improve")
  
  local order = {guildie = IsAGuildie(handle)}
  local line = {"(Prices listed are NOT additive. Each price is the total fee for that Quality.)", "Metal Items:"}
  
  local y = {}
  local costs = OT.GetImproveFeesPerQual(PriceList, order, PROFESSION_SMITH, HotepCraft.improvQty)
  
  for k,v in pairs(pieces) do
    local x = zo_strformat("<<1>>: add <<2>>g", v, costs[k])
    table.insert(y, x)
  end
  
  table.insert(line, table.concat(y, ', '))
  
  table.insert(line, "Light/Medium Armor:")
  
  y = {}
  costs = OT.GetImproveFeesPerQual(PriceList, order, PROFESSION_CLOTH, HotepCraft.improvQty)
  
  for k,v in pairs(pieces) do
    local x = zo_strformat("<<1>>: add <<2>>g", v, costs[k])
    table.insert(y, x)
  end
  
  table.insert(line, table.concat(y, ', '))
  
  table.insert(line, "Woodwork:")
  
  y = {}
  costs = OT.GetImproveFeesPerQual(PriceList, order, PROFESSION_WOOD, HotepCraft.improvQty)
  
  for k,v in pairs(pieces) do
    local x = zo_strformat("<<1>>: add <<2>>g", v, costs[k])
    table.insert(y, x)
  end
  
  table.insert(line, table.concat(y, ', '))
  
  
  local subj = "Improvement Fees (any level)"
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Improvement Fee List to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForImprovFees(handle, lev, step)


function HotepCraft.SendPriceListForGlyphFees(handle, lev, step)
  
  local order = {guildie = IsAGuildie(handle)}
  local line = {"FOR ARMOR:"}
  
  local glyphs = OT.GLYPHS("armor")
  
  for k,v in pairs(glyphs) do
    local cost = OT.GetEnchantFee(PriceList, "heavy", lev, k)
    local x = zo_strformat("<<1>>: add <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  table.insert(line, "FOR WEAPONS:")
  
  glyphs = OT.GLYPHS("weapon")
  
  for k,v in pairs(glyphs) do
    local cost = OT.GetEnchantFee(PriceList, "1h", lev, k)
    local x = zo_strformat("<<1>>: add <<2>>g", v, OT.GDP(PriceList, order, cost))
    table.insert(line, x)
  end
  
  
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local subj = zo_strformat("Fees for <<1>> Enchantments", theLevel)
  
  local body = table.concat(line, "\n")
  
  msgWithName(zo_strformat("Sending Enchantment Fee List to <<1>>", handle))
  
  
  local foo = function()
    if (not timer_mailingprices.triggered) then
      HotepCraft.SendPriceListForLevel(handle, lev, step + 1)
    end
  end
  
  MailQueue:Enqueue(handle, subj, body, foo, HotepCraft.SendPriceListError)
end
-- end function HotepCraft.SendPriceListForGlyphFees(handle, lev, step)


function HotepCraft.SendPriceListDone(handle, lev, step)
  HotepCraft.busy = false
  
  timer_mailingprices:Stop()
  timer_mailingprices.RETRYINGMAIL = nil
  CALLBACK_MANAGER:UnregisterCallback(EVENT_MAILSEND_ATTEMPTED, prices_mailsending)
  CALLBACK_MANAGER:UnregisterCallback(EVENT_MAILSEND_DEFERRED, prices_maildeferred)
  
  HotepToolsLib.HotepMailReader.abort = false
  
  step = step - 1
  
  local guildie = IsAGuildie(handle)
  local theLevel = OT.LEVELS(lev, "level", "short")
  
  local x = {zo_strformat("The <<1>> Price lists have been mailed to you. (<<2>> total messages.)", theLevel, step)}
  table.insert(x, "NOTE That it may take up to 30 minutes for the game to deliver the mail to you.")
  
  if (guildie and (PriceList.discount > 0)) then
    table.insert(x, zo_strformat("As a fellow guildie, the price lists sent to you reflect a <<1>>% discount!", PriceList.discount))
  end
  
  ChatQueue:New(5, "wisp", handle, nil, nil, x)
end
-- end function HotepCraft.SendPriceListDone(handle)


function HotepCraft.SendPriceListError(reason, mailer)
  HotepCraft.busy = false
  
  timer_mailingprices:Stop()
  
  CALLBACK_MANAGER:UnregisterCallback(EVENT_MAILSEND_ATTEMPTED, prices_mailsending)
  CALLBACK_MANAGER:UnregisterCallback(EVENT_MAILSEND_DEFERRED, prices_maildeferred)
  
  HotepToolsLib.HotepMailReader.abort = false
  
  local handle
  if (mailer) then
    handle = mailer.mailout.to
  end
  
  if (type(reason) == "table") then
    reason = nil
  end
  
  
  if (reason and (reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL)) then
    timer_mailingprices.RETRYINGMAIL = nil
    local x = {
      "Your inbox is full.  The price lists could not be sent.",
      "Please make more room in your inbox, then request the prices again.",
    }
    ChatQueue:New(5, "wisp", handle, nil, nil, x)
  elseif (reason) then
    timer_mailingprices.RETRYINGMAIL = nil
    msgWithName(zo_strformat("Mail failed with unknown reason: <<1>>", reason), COLOR_RED)
  elseif (timer_mailingprices.RETRYINGMAIL) then
    timer_mailingprices.RETRYINGMAIL = nil
    msgWithName("MailSend timed out.", COLOR_RED)
  else
    msgWithName("MailSend timed out. Retrying...", COLOR_PURPLE)
    timer_mailingprices.RETRYINGMAIL = true
    local p = timer_mailingprices.params
    HotepCraft.SendPriceListForLevel(p.handle, p.lev, p.step)
  end
end
-- end function HotepCraft.SendPriceListError(reason, mailer)


timer_mailingprices = Timer:New(0.75, HotepCraft.SendPriceListError, nil, true)



function HotepCraft.SendExtraPrices(handle, step, n)
  -- mail lists of sets and styles
  
  if (not step) then
    local foo = function()
      HotepCraft.SendExtraPrices(handle, 1)
    end
    HotepCraft.busy = true
    local msgs = {"Mailing Set and Style Lists to you now..."}
    ChatQueue:New(5, "wisp", handle, foo, foo, msgs)
  elseif (step == 1) then
    HotepToolsLib.HotepMailReader.abort = true
    HotepCraft.SendSetList(handle)
  elseif (step == 2) then
    HotepCraft.SendStyleList(handle, n)
  elseif (step == 3) then
    local x = {zo_strformat("The Set and Style Lists have been mailed to you. (<<1>> total messages.)", n)}
    table.insert(x, "NOTE That it may take up to 30 minutes for the game to deliver the mail to you.")
    local guildie = IsAGuildie(handle)
    if (guildie and (PriceList.discount > 0)) then
      table.insert(x, zo_strformat("As a fellow guildie, the price lists sent to you reflect a <<1>>% discount!", PriceList.discount))
    end
    ChatQueue:New(5, "wisp", handle, nil, nil, x)
    HotepCraft.busy = false
    HotepToolsLib.HotepMailReader.abort = false
  elseif (step == 9) then
    local x = {"Your Inbox is Full.  The Set and Style Lists could not be mailed to you."}
    ChatQueue:New(5, "wisp", handle, nil, nil, x)
    HotepCraft.busy = false
    HotepToolsLib.HotepMailReader.abort = false
  end
end
-- end HotepCraft.SendExtraPrices(handle)


function HotepCraft.SendSetList(handle)
  local guildie = IsAGuildie(handle)
  local t = {}
  
  for k,p in ipairs(PriceList.setfees) do
    if (p > -1) then
      local set = OT.ARM_SETS(k)
      local x = zo_strformat("<<1>> (add <<2>>g)", set.name, OT.GDP(PriceList, {guildie = guildie}, p))
      table.insert(t, x)
    end
  end
  
  local delaysend = function(p)
    local handle = p[1]
    local body = p[2]
    local i = p[3]
    local n = p[4]
    local subj = "Available Crafted Sets"
    
    local foo = function(success)
      if (success) then
        HotepCraft.SendExtraPrices(handle, 2, n)
      else
        HotepCraft.SendExtraPrices(handle, 9)
      end
    end
    
    local done = function(reason)
      local x
      local color
      if (reason) then
        x = "FAILED TO SEND!"
        color = COLOR_RED
      else
        x = "sent successfully."
        color = COLOR_GREEN
      end
      
      msgWithName(zo_strformat("Set List Mail <<1>> of <<2>> <<3>>", i, n, x), color)
      
      if (reason) then
        if (reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL) then
          foo(false)
        end
      elseif (i == n) then
        foo(true)
      end
    end
    
    msgWithName(zo_strformat("Sending Set List Mail <<1>> of <<2>> to <<3>>", i, n, handle))
    MailQueue:Enqueue(handle, subj, body, done, done)
  end
  
  
  local globs = array_glob(t, 14)
  local n = #globs
  local tt = 0
  
  for k,glob in ipairs(globs) do
    local body = table.concat(glob, "\n")
    Timer:Once(tt, delaysend, {handle, body, k, n})
    tt = tt + 0.1
  end
end
-- end HotepCraft.SendSetList(handle)


function HotepCraft.SendStyleList(handle, n)
  local guildie = IsAGuildie(handle)
  local tt = 0
  
  local delaysend = function(p)
    local handle = p[1]
    local body = p[2]
    local i = p[3]
    local m = p[4]
    local subj = "Available Styles"
    
    local foo = function(success)
      if (success) then
        HotepCraft.SendExtraPrices(handle, 3, (n + m))
      else
        HotepCraft.SendExtraPrices(handle, 9)
      end
    end
    
    local done = function(reason)
      local x
      local color
      if (reason) then
        x = "FAILED TO SEND!"
        color = COLOR_RED
      else
        x = "sent successfully."
        color = COLOR_GREEN
      end
      
      msgWithName(zo_strformat("Style List Mail <<1>> of <<2>> <<3>>", i, m, x), color)
      
      if (reason) then
        if (reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL) then
          foo(false)
        end
      elseif (i == m) then
        foo(true)
      end
    end
    
    msgWithName(zo_strformat("Sending Style List Mail <<1>> of <<2>> to <<3>>", i, m, handle))
    MailQueue:Enqueue(handle, subj, body, done, done)
  end
  
  
  local t = {}
  
  for k,p in ipairs(PriceList.stylefees) do
    if (p > -1) then
      local style = OT.MOTIFS(k)
      local x = zo_strformat("<<1>> (add <<2>>g)", style.name, OT.GDP(PriceList, {guildie = guildie}, p))
      table.insert(t, x)
    end
  end
  
  
  local globs = array_glob(t, 14)
  local m = #globs
  
  for k,glob in ipairs(globs) do
    local body = table.concat(glob, "\n")
    Timer:Once(tt, delaysend, {handle, body, k, m})
    tt = tt + 0.1
  end
end
-- end HotepCraft.SendStyleList(handle)






function HotepCraft.LoadSavedSetup()
  savedVariables:Load(SV_SETTINGS)
  savedVariables:Load(SV_ORDERS)
  savedVariables:Load(SV_PRICES)
  savedVariables:Load(SV_CLAIM)
  savedVariables:Load(SV_SKILLS)
  savedVariables:Load(SV_BOOKKEEPING)
  savedVariables:Load(SV_TRADEIN)
  savedVariables:Load(SV_AUTOPRICE)
  savedVariables:Load(SV_MANUALS)
  
  
  if (not LP or not LP.CanMMPrice()) then
    array_without(PRICES_ENGINES, PRICES_MM)
    array_without(PRICES_ENGINES_CHOICES, PRICECHOICES_MM)
  end
  
  if (not LP or not LP.CanTTCPrice()) then
    array_without(PRICES_ENGINES, PRICES_TTC)
    array_without(PRICES_ENGINES_CHOICES, PRICECHOICES_TTC)
  end
  
  if (not LP or not LP.CanATTPrice()) then
    array_without(PRICES_ENGINES, PRICES_ATT)
    array_without(PRICES_ENGINES_CHOICES, PRICECHOICES_ATT)
  end
  
  
  if (HotepCraft.Debugger_am_I) then
    savedVariables:Load(SV_CHATLOG)
  end
end
-- end HotepCraft.LoadSavedSetup()



HotepCraft_LAM_ImproveMetal_ = nil
HotepCraft_LAM_ImproveCloth_ = nil
HotepCraft_LAM_ImproveWood_ = nil
HotepCraft_LAM_TImproveMetal_ = nil
HotepCraft_LAM_TImproveCloth_ = nil
HotepCraft_LAM_TImproveWood_ = nil
HotepCraft_LAM_DND_Checkbox = nil
HotepCraft_LAM_DEPOSIT_T1 = nil
HotepCraft_LAM_DEPOSIT_T2 = nil
HotepCraft_LAM_DEPOSIT_T3 = nil
HotepCraft_LAM_DEPOSIT_A1 = nil
HotepCraft_LAM_DEPOSIT_A2 = nil
HotepCraft_LAM_DEPOSIT_A3 = nil
HotepCraft_UI_NOUNDO = zo_strformat("<<1>>THIS IS NOT UNDO-ABLE!!!|r", COLOR_PURPLE)
HotepCraft_LAM_BASEPRICES = nil



---
-- @param pot @class table  -- ['glyph'],['+'],['-']
-- @param lvl @class number
-- @return @class string
local function LvlName(pot, lvl)
  local lev
  if (lvl < 51) then
    lev = zo_strformat("lvl <<1>>", lvl)
  else
    lev = (lvl - 50) * 10
    lev = zo_strformat("CP <<1>>", lev)
  end
  
  return zo_strformat('<<1>> "<<2>>" (<<3>>/<<4>>)', lev, pot.glyph, pot['+'], pot['-'])
end


local function MatLvlName(st, lvl)
  local lev
  if (lvl < 51) then
    lev = zo_strformat("lvl <<1>>", lvl)
  else
    lev = (lvl - 50) * 10
    lev = zo_strformat("CP <<1>>", lev)
  end
  
  return zo_strformat("<<1>> (<<2>>)", st, lev)
end




---
-- @param itemType @class string
-- @param itemName @class string
-- @param fees @class boolean
-- @param tradein @class boolean
-- @return @class number   -- Price or FALSE if no price
function HotepCraft.GetPricePerSettings(itemType, itemName, fees, tradein)
  local link = LL.GetItemLink(itemType, itemName)
  
  if (not link) then return false end
  
  local key = "base"
  if (fees) then
    key = "fees"
  end
  
  ---@local settings @class AUTOPRICESECTION
  local settings
  ---@local x @class AUTOPRICESECTION
  local x = AutoPricing[key]
  
  if (tradein) then
    settings = AutoPricing[key].tradeins
--d("---------------------")
--d("settings.same: " .. (settings.same and "yes" or "no"))
--d("settings.engine: " .. settings.engine)
--d("settings.option: " .. settings.option)
--d("x.engine: " .. x.engine)
--d("x.option: " .. x.option)
--d("=====================")
    if (settings.same) then
      settings.engine = x.engine
      settings.option = x.option
      settings.ttc_sugg_pct = x.ttc_sugg_pct
    end
  else
    settings = x
  end
--d("=====================")
--d("settings.engine: " .. settings.engine)
--d("settings.option: " .. settings.option)
--d("=====================")
  
  
  if (settings.engine == PRICES_OFF) then return false end
  
  
  local pricedata = LP.ItemLinkToPriceData(link)
  
  if (not pricedata) then return false end
  
  
  local engineKeys = {
    [PRICES_MM] = 'mm',
    [PRICES_TTC] = 'ttc',
    [PRICES_ATT] = 'att',
  }
  
  local optionKeys = {
    [PRICES_MM_AVG] = 'avgPrice',
    [PRICES_MM_LOW] = {'graphInfo','low'},
    [PRICES_MM_HIGH] = {'graphInfo','high'},
    [PRICES_TTC_AVG] = 'Avg',
    [PRICES_TTC_MIN] = 'Min',
    [PRICES_TTC_MAX] = 'Max',
    [PRICES_TTC_SUGGLOW] = 'SuggestedPrice',
    [PRICES_TTC_SUGGHIGH] = 'SuggestedPrice',
    [PRICES_TTC_SUGGMID] = 'SuggestedPrice',
    [PRICES_ATT_AVG] = 'avgPrice',
  }
  
  
  local ThePrice
  
  local key1 = engineKeys[settings.engine]
  local key2 = optionKeys[settings.option]
  
  if (not pricedata[key1]) then return false end
  
  if (type(key2) == "table") then
    if (not pricedata[key1][key2[1]]) then return false end
    ThePrice =  math.floor(pricedata[key1][key2[1]][key2[2]])
  else
    if (not pricedata[key1][key2]) then return false end
    ThePrice =  math.floor(pricedata[key1][key2])
  end
    
  if (key2 == 'SuggestedPrice') then
    if (settings.option == PRICES_TTC_SUGGHIGH) then
      ThePrice = ThePrice * 1.25
    elseif (settings.option == PRICES_TTC_SUGGMID) then
      local dif = (ThePrice * 0.25)
      local plus = (dif * settings.ttc_sugg_pct / 100)
      ThePrice =  math.floor(ThePrice + plus)
    end
  end
  
  
  if (settings.addvalue ~= 0) then
    if (settings.addfixed) then
      ThePrice = ThePrice + settings.addvalue
    else
      ThePrice = ThePrice + (ThePrice * (settings.addvalue / 100))
    end
  end
  
  ThePrice = math.floor(ThePrice)
  
  return ThePrice
end
-- end HotepCraft.GetPricePerSettings(itemType, itemName, fees, tradein)


local function WAIT()
  SCENE_MANAGER:ShowBaseScene()
end


function HotepCraft.ResetAllAutoPrices(key, manual)
  
  if ((AutoPricing.base.engine == PRICES_OFF) and AutoPricing.base.tradeins.same
      and (AutoPricing.fees.engine == PRICES_OFF) and AutoPricing.fees.tradeins.same) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    AutoPricing.base.pricesUpdated = false
    AutoPricing.fees.pricesUpdated = false
    return false
  end
  
  if ((AutoPricing.base.engine == PRICES_OFF) and (AutoPricing.base.tradeins.engine == PRICES_OFF)
      and (AutoPricing.fees.engine == PRICES_OFF) and (AutoPricing.fees.tradeins.engine == PRICES_OFF)) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    AutoPricing.base.pricesUpdated = false
    AutoPricing.fees.pricesUpdated = false
    return false
  end
  
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", WAIT)
  SCENE_MANAGER:ShowBaseScene()
  
  for _,control in ipairs(HotepCraft.TheLAMAddonPanel.controlsToRefresh) do
    if (control.data and control.data.PricesData) then
      local k = "base"
      if (control.data.PricesData.fee) then
        k = "fees"
      end
      local eng
      if (control.data.PricesData.tradein) then
        eng = AutoPricing[k].tradeins.engine
      else
        eng = AutoPricing[k].engine
      end
      
      if (eng ~= PRICES_OFF) then
        if ((k == key) or (key == "both")) then
          if ((manual == "both") 
                or (manual and HotepCraft.GetManualPriceFlag(control.data)) 
                or (not manual and not HotepCraft.GetManualPriceFlag(control.data))) then
            HotepCraft.SetAutoPriceForMat(control)
          end
        end
      end
    end
  end
  
  if (key == "both") then
    AutoPricing.base.pricesUpdated = (AutoPricing.base.engine ~= PRICES_OFF)
    AutoPricing.fees.pricesUpdated = (AutoPricing.fees.engine ~= PRICES_OFF)
  else
    AutoPricing[key].pricesUpdated = (AutoPricing[key].engine ~= PRICES_OFF)
  end
  
  CALLBACK_MANAGER:UnregisterCallback("LAM-PanelOpened", WAIT)
  
  STD.CriticalChange(HotepCraft.name)
end
-- end HotepCraft.ResetAllAutoPrices(key, manual)



function HotepCraft.GetAutoPriceForMat(widgetData)
  local tradein = widgetData.PricesData.tradein
  local fees = widgetData.PricesData.fee
  local itemType = widgetData.itemtype
  local itemName = widgetData.matname
  
  
  local price
  
  if (type(itemName) == "table") then
    local p1 = HotepCraft.GetPricePerSettings(itemType, itemName[1], fees, tradein)
    if (not p1) then p1 = -1 end
    local p2 = HotepCraft.GetPricePerSettings(itemType, itemName[2], fees, tradein)
    if (not p2) then p2 = -1 end
    price = math.max(p1, p2)
    if (price == -1) then return false end
  else
    price = HotepCraft.GetPricePerSettings(itemType, itemName, fees, tradein)
  end
  
  return price
end


function HotepCraft.SetAutoPriceForMat(control)
  local tradein = control.data.PricesData.tradein
  local fees = control.data.PricesData.fee
  local itemType = control.data.itemtype
  local itemName = control.data.matname
  
  local price
  
  if (type(itemName) == "table") then
    local p1 = HotepCraft.GetPricePerSettings(itemType, itemName[1], fees, tradein)
    if (not p1) then p1 = -1 end
    local p2 = HotepCraft.GetPricePerSettings(itemType, itemName[2], fees, tradein)
    if (not p2) then p2 = -1 end
    price = math.max(p1, p2)
    if (price == -1) then return false end
  else
    price = HotepCraft.GetPricePerSettings(itemType, itemName, fees, tradein)
  end
  
  if (price == false) then
    return false
  end
  
  control:UpdateValue(nil, price)
  control.data.wasSetManually = false
  HotepCraft.SetManualPriceFlag(control.data, false)
  
  return true
end



function HotepCraft.LAMAutoPriceOptions(key)
  return {
    {
      type = "divider",
      alpha = 1,
    },
    {
      type = "dropdown",
      name = "When you make changes to any option here: ",
      longer = 510,
      choices = {'Recalculate ALL prices',
                 'Recalculate only prices that have already been set Automatically',
                 "DON'T Recalculate ANY prices"},
      choicesValues = {'all', 'auto', 'none'},
      getFunc = function()
        if (HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO) then
          if (HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN) then
            return 'all'
          else
            return 'auto'
          end
        else
          return 'none'
        end
      end,
      setFunc = function(n)
        if (n == 'all') then
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = true
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = true
        elseif (n == 'auto') then
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = true
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = false
        else
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = false
          HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = false
        end
      end,
      customInit = function (control)
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = true
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = true
        control:UpdateValue()
      end,
      width = "half",
      disabled = function() return ((#PRICES_ENGINES < 2) or (AutoPricing[key].engine == PRICES_OFF)) end
    },
    {
      type = "divider",
      alpha = 1,
    },
    {
      type = "header",
      name = zo_strformat("<<1>>Charges (for what you craft)|r", COLOR_YELLOW),
    },
    {
      type = "divider",
      alpha = 1,
    },
    {
      type = "dropdown",
      name = "Pricing Addon to Use:",
      longer = 280,
      choices = PRICES_ENGINES_CHOICES,
      choicesValues = PRICES_ENGINES,
      getFunc = function() return AutoPricing[key].engine end,
      setFunc = function(n)
        if (HotepCraft.TheLAMAddonPanel) then
          local a = AutoPricing[key].engine
          if (a ~= n) then
            HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= PRICES_OFF)
            AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
          end
        end
        AutoPricing[key].engine = n
        if (AutoPricing[key].tradeins.same) then
          AutoPricing[key].tradeins.engine = AutoPricing[key].engine
        end
      end,
      tooltip = function()
        if (#PRICES_ENGINES < 2) then
          return "You don't have MM, TTC, or ATT installed."
        else
          return nil
        end
      end,
      disabled = function() return (#PRICES_ENGINES < 2) end
    },
    {
      type = "dropdown",
      name = "Price to Use from Addon:",
      longer = 510,
      width = "half",
      choices = PRICES_OPTIONS_CHOICES[AutoPricing[key].engine],
      choicesValues = PRICES_OPTIONS[AutoPricing[key].engine],
      getFunc = function()
        if (in_array(AutoPricing[key].option, PRICES_OPTIONS[AutoPricing[key].engine])) then
          return AutoPricing[key].option
        else
          AutoPricing[key].option = PRICES_OPTIONS[AutoPricing[key].engine][1]
          return PRICES_OPTIONS[AutoPricing[key].engine][1]
        end
      end,
      setFunc = function(n)
        local x = AutoPricing[key].option
        if (in_array(n, PRICES_OPTIONS[AutoPricing[key].engine])) then
          AutoPricing[key].option = n
        else
          AutoPricing[key].option = PRICES_OPTIONS[AutoPricing[key].engine][1]
        end
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= x)
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
        if (AutoPricing[key].tradeins.same) then
          AutoPricing[key].tradeins.option = AutoPricing[key].option
        end
      end,
      customUpdate = function (control)
        control:UpdateChoices(PRICES_OPTIONS_CHOICES[AutoPricing[key].engine], PRICES_OPTIONS[AutoPricing[key].engine])
        control.dropdown:SetSelectedItem(control.choices[control.data.getFunc()])
      end,
      disabled = function() return (AutoPricing[key].engine == PRICES_OFF) end,
    },
    {
      type = "slider",
      name = "Custom Percentage:",
      min = 1,
      max = 99,
      clampInput = true,
      autoSelect = true,
      tooltip = 'Custom % between TTC\'s low and high "Suggested Price"',
      getFunc = function()
        return AutoPricing[key].ttc_sugg_pct
      end,
      setFunc = function(n)
        local x = AutoPricing[key].ttc_sugg_pct
        AutoPricing[key].ttc_sugg_pct = n
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= x)
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
        if (AutoPricing[key].tradeins.same) then
          AutoPricing[key].tradeins.ttc_sugg_pct = AutoPricing[key].ttc_sugg_pct
        end
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function()
        return ((AutoPricing[key].engine ~= PRICES_TTC) 
                  or (AutoPricing[key].option ~= PRICES_TTC_SUGGMID))
      end
    },
    {
      type = "dropdown",
      name = "Adjustment Option:",
      longer = 380,
      choices = {'Addon Prices as-is','A fixed gold amt above/below Addon Prices','A fixed percentage above/below Addon Prices'},
      choicesValues = {1,2,3},
      getFunc = function()
        if (AutoPricing[key].addvalue == 0) then
          return 1
        elseif (AutoPricing[key].addfixed) then
          return 2
        else
          return 3
        end
      end,
      setFunc = function(n)
        local x = AutoPricing[key].addfixed
        local xx = AutoPricing[key].addvalue
        if (n == 1) then
          AutoPricing[key].addvalue = 0
        elseif (n == 2) then
          AutoPricing[key].addfixed = true
          if (AutoPricing[key].addvalue == 0) then
            AutoPricing[key].addvalue = 1
          end
        else
          AutoPricing[key].addfixed = false
          if (AutoPricing[key].addvalue == 0) then
            AutoPricing[key].addvalue = 1
          end
        end
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = ((x ~= AutoPricing[key].addfixed) or (xx ~= AutoPricing[key].addvalue))
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function() return (AutoPricing[key].engine == PRICES_OFF) end,
    },
    {
      type = "editbox",
      name = "Adjustment Value:",
      tooltip = function()
        if (AutoPricing[key].addfixed) then
          return "Fixed gold amt to add to Addon Prices (can be negative)."
        else
          return "Fixed percentage to add to Addon Prices (can be negative)."
        end
      end,
      getFunc = function()
        return AutoPricing[key].addvalue
      end,
      setFunc = function(x)
        local z = AutoPricing[key].addvalue
        local n = tonumber(x)
        if (not n) then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You Must Enter A Number", COLOR_RED))
        elseif (n == 0) then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You Can't Enter Zero", COLOR_RED))
        else
          AutoPricing[key].addvalue = n
          HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= z)
          AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
        end
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function()
        return ((AutoPricing[key].engine == PRICES_OFF) or (AutoPricing[key].addvalue == 0))
      end,
    },
    {
      type = "checkbox",
      name = "Allow Editing individual prices manually?",
      tooltip = "Turn OFF to disable all of the pricing sliders.",
      getFunc = function()
        return AutoPricing[key].allow_edit
      end,
      setFunc = function(n)
        AutoPricing[key].allow_edit = n
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function() return (AutoPricing[key].engine == PRICES_OFF) end,      
    },
    
    
    -- ********************************************************************
    
    
    {
      type = "header",
      name = zo_strformat("<<1>>Discounts (for mats provided by customers)|r", COLOR_PURPLE),
    },
    {
      type = "divider",
      alpha = 1,
    },
    {
      type = "checkbox",
      name = "Same Main Options as Above?",
      tooltip = function()
        if ((AutoPricing[key].engine == PRICES_TTC) 
                  and (AutoPricing[key].option == PRICES_TTC_SUGGMID)) then
          return "(use same choices for first 3 options)"
        else
          return "(use same choices for first 2 options)"
        end
      end,
      getFunc = function()
        return AutoPricing[key].tradeins.same
      end,
      setFunc = function(n)
        local z = AutoPricing[key].tradeins.same
        AutoPricing[key].tradeins.same = n
        if (n) then
          AutoPricing[key].tradeins.engine = AutoPricing[key].engine
          AutoPricing[key].tradeins.option = AutoPricing[key].option
          AutoPricing[key].tradeins.ttc_sugg_pct = AutoPricing[key].ttc_sugg_pct
        end
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= z)
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
      end,
      disabled = function() return (#PRICES_ENGINES < 2) end
    },
    {
      type = "dropdown",
      name = "Pricing Addon to Use:",
      longer = 280,
      choices = PRICES_ENGINES_CHOICES,
      choicesValues = PRICES_ENGINES,
      getFunc = function() return AutoPricing[key].tradeins.engine end,
      setFunc = function(n)
        if (HotepCraft.TheLAMAddonPanel) then
          local a = AutoPricing[key].tradeins.engine
          if (a ~= n) then
            HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= PRICES_OFF)
            AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
          end
        end
        AutoPricing[key].tradeins.engine = n
      end,
      tooltip = function()
        if (#PRICES_ENGINES < 2) then
          return "You don't have MM, TTC, or ATT installed."
        else
          return nil
        end
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function() return ((#PRICES_ENGINES < 2) or AutoPricing[key].tradeins.same) end
    },
    {
      type = "dropdown",
      name = "Price to Use from Addon:",
      longer = 510,
      width = "half",
      choices = PRICES_OPTIONS_CHOICES[AutoPricing[key].tradeins.engine],
      choicesValues = PRICES_OPTIONS[AutoPricing[key].tradeins.engine],
      getFunc = function()
        if (in_array(AutoPricing[key].tradeins.option, PRICES_OPTIONS[AutoPricing[key].tradeins.engine])) then
          return AutoPricing[key].tradeins.option
        else
          return PRICES_OPTIONS[AutoPricing[key].tradeins.engine][1]
        end
      end,
      setFunc = function(n)
        local z = AutoPricing[key].tradeins.option
        if (in_array(n, PRICES_OPTIONS[AutoPricing[key].tradeins.engine])) then
          AutoPricing[key].tradeins.option = n
        else
          AutoPricing[key].tradeins.option = PRICES_OPTIONS[AutoPricing[key].tradeins.engine][1]
        end
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= z)
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
      end,
      customUpdate = function (control)
        control:UpdateChoices(PRICES_OPTIONS_CHOICES[AutoPricing[key].tradeins.engine], PRICES_OPTIONS[AutoPricing[key].tradeins.engine])
        control.dropdown:SetSelectedItem(control.choices[control.data.getFunc()])
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function()
         return ((AutoPricing[key].tradeins.engine == PRICES_OFF) or
                      AutoPricing[key].tradeins.same)
      end,
    },
    {
      type = "slider",
      name = "Custom Percentage:",
      min = 1,
      max = 99,
      clampInput = true,
      autoSelect = true,
      tooltip = 'Custom % between TTC\'s low and high "Suggested Price"',
      getFunc = function()
        return AutoPricing[key].tradeins.ttc_sugg_pct
      end,
      setFunc = function(n)
        local z = AutoPricing[key].tradeins.ttc_sugg_pct
        AutoPricing[key].tradeins.ttc_sugg_pct = n
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= z)
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function()
        return ((AutoPricing[key].tradeins.engine ~= PRICES_TTC) 
                  or (AutoPricing[key].tradeins.option ~= PRICES_TTC_SUGGMID)
                  or AutoPricing[key].tradeins.same)
      end
    },
    {
      type = "dropdown",
      name = "Adjustment Option:",
      longer = 380,
      choices = {'Addon Prices as-is','A fixed gold amt above/below Addon Prices','A fixed percentage above/below Addon Prices'},
      choicesValues = {1,2,3},
      getFunc = function()
        if (AutoPricing[key].tradeins.addvalue == 0) then
          return 1
        elseif (AutoPricing[key].tradeins.addfixed) then
          return 2
        else
          return 3
        end
      end,
      setFunc = function(n)
        local x = AutoPricing[key].tradeins.addfixed
        local xx = AutoPricing[key].tradeins.addvalue
        if (n == 1) then
          AutoPricing[key].tradeins.addvalue = 0
        elseif (n == 2) then
          AutoPricing[key].tradeins.addfixed = true
          if (AutoPricing[key].tradeins.addvalue == 0) then
            AutoPricing[key].tradeins.addvalue = 1
          end
        else
          AutoPricing[key].tradeins.addfixed = false
          if (AutoPricing[key].tradeins.addvalue == 0) then
            AutoPricing[key].tradeins.addvalue = 1
          end
        end
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = 
                  ((x ~= AutoPricing[key].tradeins.addfixed) or (xx ~= AutoPricing[key].tradeins.addvalue))
        AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function() return (AutoPricing[key].tradeins.engine == PRICES_OFF) end,
    },
    {
      type = "editbox",
      name = "Adjustment Value:",
      tooltip = function()
        if (AutoPricing[key].tradeins.addfixed) then
          return "Fixed gold amt to add to Addon Prices (can be negative)."
        else
          return "Fixed percentage to add to Addon Prices (can be negative)."
        end
      end,
      getFunc = function()
        return AutoPricing[key].tradeins.addvalue
      end,
      setFunc = function(x)
        local z = AutoPricing[key].tradeins.addvalue
        local n = tonumber(x)
        if (not n) then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You Must Enter A Number", COLOR_RED))
        elseif (n == 0) then
          ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You Can't Enter Zero", COLOR_RED))
        else
          AutoPricing[key].tradeins.addvalue = n
          HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = (n ~= z)
          AutoPricing[key].pricesUpdated = not HotepCraft.TheLAMAddonPanel.DOAUTOPRICING
        end
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function()
        return ((AutoPricing[key].tradeins.engine == PRICES_OFF) or (AutoPricing[key].tradeins.addvalue == 0))
      end,
    },
    {
      type = "checkbox",
      name = "Allow Editing individual prices manually?",
      tooltip = "Turn OFF to disable all of the pricing sliders.",
      getFunc = function()
        return AutoPricing[key].tradeins.allow_edit
      end,
      setFunc = function(n)
        AutoPricing[key].tradeins.allow_edit = n
      end,
      customUpdate = function (control)
        control:SetHidden(control.data.disabled())
        control.label:SetHidden(control.data.disabled())
      end,
      disabled = function() return (AutoPricing[key].tradeins.engine == PRICES_OFF) end,      
    },
    
    
    -- ********************************************************************
    
    
    {
      type = "header",
      name = zo_strformat("<<1>> --- PRICING RESET --- |r", COLOR_RED),
    },
    {
      type = "divider",
      alpha = 1,
    },
    {
      type = "button",
      longer = 520,
      name = zo_strformat("Refresh All Automatcally Set <<1>> Pricing Right Now?", key),
      func = function()
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = true
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = false
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = true
        AutoPricing[key].pricesUpdated = false
        SCENE_MANAGER:ShowBaseScene()
      end,
      isDangerous = true,
      disabled = function() return ((#PRICES_ENGINES < 2) 
                or ((AutoPricing[key].engine == PRICES_OFF) and (AutoPricing[key].tradeins.engine == PRICES_OFF))) end,
    },
    {
      type = "divider",
      alpha = 0.1,
    },
    {
      type = "button",
      longer = 520,
      name = zo_strformat("Reset All Manually Set <<1>> Pricing to Automatic Right Now?", key),
      func = function()
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO = false
        HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN = true
        HotepCraft.TheLAMAddonPanel.DOAUTOPRICING = true
        AutoPricing[key].pricesUpdated = false
        SCENE_MANAGER:ShowBaseScene()
      end,
      isDangerous = true,
      disabled = function() return ((#PRICES_ENGINES < 2) 
                or ((AutoPricing[key].engine == PRICES_OFF) and (AutoPricing[key].tradeins.engine == PRICES_OFF))) end,
    },
  }
end
-- end HotepCraft.LAMAutoPriceOptions(key)


local function ShowItemToolTip(control)
  local itemType = control.data.itemtype
  local itemName = control.data.matname
  
  local link = LL.GetItemLink(itemType, itemName)
  
  if (not link) then return false end
  
  ZO_LinkHandler_OnLinkClicked(link, MOUSE_BUTTON_INDEX_LEFT, control)
end


function HotepCraft.CreateLAMPriceOptions()
  
  local optn = {
    type = "slider",
    name = "",
    min = 5,
    max = 15000,
    step = 1,
    decimals = 0,
    tooltip = "<<4>>Price|r <<1>>PER UNIT|r <<4>>of|r <<2>><<3>>|r <<4>>used to craft the item.|r",
    width = "half",
    autoSelect = true,
    PricesData = {tradein = false, fee = false},
    colorfunc = function (control)
      local v = control.data.getFunc()
      if (v < 5) then
        control.data.setFunc(5)
      end
      local C = ROWCOLOR_YELLOW
      if (control.data.disabled()) then
        C = ROWCOLOR_YELLOWDIM
      end
      control.label:SetColor(C:UnpackRGBA())
      control.slider.bg:SetEdgeColor(C:UnpackRGBA())
      control.slider:SetColor(C:UnpackRGBA())
      control.slidervalue:SetColor(C:UnpackRGBA())
      control.slidervalueBG:SetEdgeColor(C:UnpackRGBA())
      control.minText:SetColor(C:UnpackRGBA())
      control.maxText:SetColor(C:UnpackRGBA())
    end,
    customWarning = function(control)
      if (AutoPricing.base.engine == PRICES_OFF) then return end
      if (not AutoPricing.base.pricesUpdated) then return end
      
      local text = zo_strformat("<<1>>Price set by <<2>>|r", COLOR_GREEN, PRICE_ENGINE_NAMES[AutoPricing.base.engine])
      
      return text
    end,
    superSetFunc = function(control, n)
      control.data.wasSetManually = true
      HotepCraft.SetManualPriceFlag(control.data, true)
      return control.data.customUpdate(control)
    end,
    customInit = function (control)
      control.InfoButton = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
      control.InfoButton:SetDimensions(24,24)
      control.InfoButton:SetTexture("/esoui/art/miscellaneous/keyboard/tooltiphintarrow.dds")
      control.InfoButton:SetAnchor(RIGHT, control.slider, LEFT, -25, 0)
      control.InfoButton:SetMouseEnabled(true)
      local fooo1 = function(control)
        ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, control.data.customWarning())
      end
      control.InfoButton:SetHandler("OnMouseEnter", function() fooo1(control) end)
      control.InfoButton:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
      if (not HotepCraft.GetAutoPriceForMat(control.data)) then
        control.data.NOPRICE = true
        control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
        control.InfoButton:SetDimensions(32,32)
        local fooo2 = function(control)
          local tt = "No Price Data For This Material"
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, tt)
        end
        control.InfoButton:SetHandler("OnMouseEnter", function() fooo2(control) end)
      end
    end,
    customUpdate = function (control)
      
      control.data.colorfunc(control)
      
      if (AutoPricing.base.engine == PRICES_OFF) then
        control.InfoButton:SetHidden(true)
        return
      end
      
      control.InfoButton:SetHidden(not AutoPricing.base.pricesUpdated)
      
      if (not AutoPricing.base.pricesUpdated) then
        return
      end
      
      if (control.data.NOPRICE) then return end
      
      local text
      
      if (control.data.wasSetManually) then
        text = "<<1>>This price was set Manually.|r\n\n<<2>>Click to to reset this price to Automatic.|r"
        text = zo_strformat(text, COLOR_RED, COLOR_YELLOW)
        
        local fooo = function()
          HotepCraft.SetAutoPriceForMat(control)
          ZO_Tooltips_HideTextTooltip()
          control.SHOWTOOLTIP = true
          return control.data.customUpdate(control)
        end
        control.InfoButton:SetHandler("OnMouseUp", function() return fooo(control) end)
        control.InfoButton:SetDimensions(30,30)
        control.InfoButton:SetColor(ROWCOLOR_RED:UnpackRGBA())
      end
      
      if (not control.data.wasSetManually) then
        text = control.data.customWarning(control)
        control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
        control.InfoButton:SetDimensions(24,24)
        control.InfoButton:SetColor(ROWCOLOR_GREEN:UnpackRGBA())
      end
      
      local fooo1 = function()
        ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, text)
      end
      control.InfoButton:SetHandler("OnMouseEnter", fooo1)
      if (control.SHOWTOOLTIP) then
        control.SHOWTOOLTIP = nil
        fooo1()
      end
    end,
    disabled = function()
      return ((AutoPricing.base.engine ~= PRICES_OFF) and not AutoPricing.base.allow_edit)
    end,
  }
  
  local toptn = {
    type = "slider",
    name = "",
    min = 0,
    max = 15000,
    step = 1,
    decimals = 0,
    tooltip = "<<4>>Discount|r <<1>>PER UNIT|r <<4>>of|r <<2>><<3>>|r <<4>>to give customer for providing their own mats.|r",
    width = "half",
    autoSelect = true,
    PricesData = {tradein = true, fee = false},
    colorfunc = function (control)
      local v = control.data.getFunc()
      if (v < 1) then
        control.data.setFunc(1)
      end
      local C = ROWCOLOR_PURPLE
      if (control.data.disabled()) then
        C = ROWCOLOR_PURPLEDIM
      end
      control.label:SetColor(C:UnpackRGBA())
      control.slider.bg:SetEdgeColor(C:UnpackRGBA())
      control.slider:SetColor(C:UnpackRGBA())
      control.slidervalue:SetColor(C:UnpackRGBA())
      control.slidervalueBG:SetEdgeColor(C:UnpackRGBA())
      control.minText:SetColor(C:UnpackRGBA())
      control.maxText:SetColor(C:UnpackRGBA())
    end,
    customWarning = function(control)
      if (AutoPricing.base.tradeins.engine == PRICES_OFF) then return end
      if (not AutoPricing.base.pricesUpdated) then return end
      
      local text = zo_strformat("<<1>>Price set by <<2>>|r", COLOR_GREEN, PRICE_ENGINE_NAMES[AutoPricing.base.tradeins.engine])
      
      return text
    end,
    superSetFunc = function(control, n)
      control.data.wasSetManually = true
      HotepCraft.SetManualPriceFlag(control.data, true)
      return control.data.customUpdate(control)
    end,
    customInit = function (control)
      control.InfoButton = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
      control.InfoButton:SetDimensions(24,24)
      control.InfoButton:SetTexture("/esoui/art/miscellaneous/keyboard/tooltiphintarrow.dds")
      control.InfoButton:SetAnchor(RIGHT, control.slider, LEFT, -25, 0)
      control.InfoButton:SetMouseEnabled(true)
      local fooo1 = function(control)
        ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, control.data.customWarning())
      end
      control.InfoButton:SetHandler("OnMouseEnter", function() fooo1(control) end)
      control.InfoButton:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
      if (not HotepCraft.GetAutoPriceForMat(control.data)) then
        control.data.NOPRICE = true
        control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
        control.InfoButton:SetDimensions(32,32)
        local fooo2 = function(control)
          local tt = "No Price Data For This Material"
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, tt)
        end
        control.InfoButton:SetHandler("OnMouseEnter", function() fooo2(control) end)
      end
    end,
    customUpdate = function (control)
      
      control.data.colorfunc(control)
      
      if (AutoPricing.base.tradeins.engine == PRICES_OFF) then
        control.InfoButton:SetHidden(true)
        return
      end
      
      control.InfoButton:SetHidden(not AutoPricing.base.pricesUpdated)
      
      if (not AutoPricing.base.pricesUpdated) then
        return
      end
      
      if (control.data.NOPRICE) then return end
      
      local text
      
      if (control.data.wasSetManually) then
        text = "<<1>>This price was set Manually.|r\n\n<<2>>Click to to reset this price to Automatic.|r"
        text = zo_strformat(text, COLOR_RED, COLOR_YELLOW)
        
        local fooo = function()
          HotepCraft.SetAutoPriceForMat(control)
          ZO_Tooltips_HideTextTooltip()
          control.SHOWTOOLTIP = true
          return control.data.customUpdate(control)
        end
        control.InfoButton:SetHandler("OnMouseUp", function() return fooo(control) end)
        control.InfoButton:SetDimensions(30,30)
        control.InfoButton:SetColor(ROWCOLOR_RED:UnpackRGBA())
      end
      
      if (not control.data.wasSetManually) then
        text = control.data.customWarning(control)
        control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
        control.InfoButton:SetDimensions(24,24)
        control.InfoButton:SetColor(ROWCOLOR_GREEN:UnpackRGBA())
      end
      
      local fooo1 = function()
        ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, text)
      end
      control.InfoButton:SetHandler("OnMouseEnter", fooo1)
      if (control.SHOWTOOLTIP) then
        control.SHOWTOOLTIP = nil
        fooo1()
      end
    end,
    disabled = function()
      return ((AutoPricing.base.tradeins.engine ~= PRICES_OFF) and not AutoPricing.base.tradeins.allow_edit)
    end,
  }
  
  
  
  local header = function (name, width)
    if (not width) then
      width = "full"
    end
    
    return {
      type = "header",
      name = name,
      width = width,
    }
  end
  
  
  local submenu = function(name, controls, tooltip)
    return {
      type = "submenu",
      name = name,
      tooltip = tooltip,
      controls = controls,
    }
  end
  
  
  local priceOptions = {}
  
  
  
  local subm = HotepCraft.LAMAutoPriceOptions('base')
  
  local headertext = zo_strformat("<<1>>Automatic Base Pricing|r", COLOR_GREEN)
  table.insert(priceOptions, submenu(headertext, subm))
  
  
  
  local getname = function (lvl, mattype)
    local mat
    
    if (mattype == "metals") then
      mat = OT.METALS(lvl)
    elseif (mattype == "woods") then
      mat = OT.WOODS(lvl)
    elseif (mattype == "medarm") then
      mat = OT.MCLOTHS(lvl)
    elseif (mattype == "lightarm") then
      mat = OT.LCLOTHS(lvl)
    else
      return ""
    end
    
    return mat.matname
  end
  
  local getprice = function (lvl, plist)
    return plist[lvl]
  end
  
  local setprice = function (lvl, plist, price)
    plist[lvl] = price
  end
  
  
  local headers = {
    {"metals", "Blacksmithing (Heavy Armor & Weapons)", ITEMTYPE_BLACKSMITHING_MATERIAL},
    {"medarm", "Medium Armor", ITEMTYPE_CLOTHIER_MATERIAL},
    {"lightarm", "Light Armor", ITEMTYPE_CLOTHIER_MATERIAL},
    {"woods", "Woodworking (Bows, Staves, & Shields)", ITEMTYPE_WOODWORKING_MATERIAL},
  }
  
  
  for _, headerrec in ipairs(headers) do
    
    local mattype = headerrec[1]
    local headertext = headerrec[2]
    local itemtype = headerrec[3]
    
    local subm = {}
    
--    table.insert(priceOptions, header(headertext))
    table.insert(subm, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
    table.insert(subm, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
    
    local plist = PriceList.price[mattype]
    local tplist = TradePrices.price[mattype]
    
    
    for lvl, price in spairs(plist) do
      local matname = getname(lvl, mattype)
      local nam = MatLvlName(matname, lvl)
      
      local opt = clone(optn)
      opt.name = zo_strformat("<<1>><<2>>|r", COLOR_YELLOW, nam)
      opt.getFunc = function () return getprice(lvl, plist) end
      opt.setFunc = function (n) return setprice(lvl, plist, n) end
      opt.tooltip = zo_strformat(opt.tooltip, COLOR_RED, COLOR_MSG, matname, COLOR_YELLOW)
      opt.itemtype = itemtype
      opt.matname = HotepCraft.RealMatName(itemtype, matname)
      table.insert(subm, opt)
      
      local opt = clone(toptn)
      opt.name = zo_strformat("<<1>><<2>>|r", COLOR_PURPLE, nam)
      opt.getFunc = function () return getprice(lvl, tplist) end
      opt.setFunc = function (n) return setprice(lvl, tplist, n) end
      opt.tooltip = zo_strformat(opt.tooltip, COLOR_RED, COLOR_MSG, matname, COLOR_PURPLE)
      opt.itemtype = itemtype
      opt.matname = HotepCraft.RealMatName(itemtype, matname)
      table.insert(subm, opt)
    end
    
    table.insert(priceOptions, submenu(headertext, subm))
  end
  
  
  return priceOptions
end
-- end HotepCraft.CreateLAMPriceOptions()


---
-- @param set @class SETREC
-- @return @class string
function HotepCraft.SetDescr(set)
  local nam = set.name
  local traits = set.traits
  
  if (set.loc.special.craft and set.loc.special.dlc and (set.loc.special.dlc ~= "")) then
    return zo_strformat("<<1>> (<<2>> traits) <<3>><<4>> DLC|r", nam, traits, COLOR_RED, set.loc.special.dlc)
  elseif (set.loc.special.craft and (set.loc.special.zone ~= "")) then
    return zo_strformat("<<1>> (<<2>> traits) <<3>>(<<4>>)|r", nam, traits, COLOR_MSG, set.loc.special.zone)
  else
    return zo_strformat("<<1>> (<<2>> traits)", nam, traits)
  end
  
end


---
-- @param i @class number
-- @param improvs @class table
-- @param prof @class string
-- @return @class string
function HotepCraft.ImprovDescr(i, improvs, prof)
  local imp = improvs[i]
  local mat = RESINS[prof][i]
  
  local colors = {COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE, COLOR_YELLOW}
  
  local x = "Fee <<1>>PER UNIT|r of <<2>><<3>>|r used to improve an item to <<4>><<5>>|r."
  
  return zo_strformat(x, COLOR_RED, COLOR_MSG, mat, colors[i], imp)
end



function HotepCraft.CreateLAMFeeOptions(feesOptions)
  
  local option = function (name, warn)
    return {
      type = "slider",
      name = name,
      tooltip = "This is a Per-Item Fee",
      warning = warn,
      min = 0,
      max = 125000,
      step = 50,
      decimals = 0,
      autoSelect = true,
    }
  end
  
  local choption = function (name, warn, width)
    local nam = name
    
    if (not string.find(name, "|c", 1, true)) then
      nam = zo_strformat("<<1>><<2>>|r", COLOR_YELLOW, name)
    end
    
    if (not width) then
      width = "half"
    end
    
    return {
      type = "slider",
      name = nam,
      tooltip = zo_strformat("<<1>>This is a Per-Item Fee|r", COLOR_YELLOW),
      warning = warn,
      min = 0,
      max = 125000,
      step = 50,
      decimals = 0,
      width = width,
      autoSelect = true,
      PricesData = {tradein = false, fee = true},
      colorfunc = function (control)
        local C = ROWCOLOR_YELLOW
        if (control.data.disabled()) then
          C = ROWCOLOR_YELLOWDIM
        end
        control.label:SetColor(C:UnpackRGBA())
        control.slider.bg:SetEdgeColor(C:UnpackRGBA())
        control.slider:SetColor(C:UnpackRGBA())
        control.slidervalue:SetColor(C:UnpackRGBA())
        control.slidervalueBG:SetEdgeColor(C:UnpackRGBA())
        control.minText:SetColor(C:UnpackRGBA())
        control.maxText:SetColor(C:UnpackRGBA())
      end,
      customWarning = function(control)
        if (AutoPricing.fees.engine == PRICES_OFF) then return end
        if (not AutoPricing.fees.pricesUpdated) then return end

        local text = zo_strformat("<<1>>Price set by <<2>>|r", COLOR_GREEN, PRICE_ENGINE_NAMES[AutoPricing.fees.engine])

        return text
      end,
      superSetFunc = function(control, n)
        control.data.wasSetManually = true
        HotepCraft.SetManualPriceFlag(control.data, true)
        return control.data.customUpdate(control)
      end,
      customInit = function (control)
        control.InfoButton = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
        control.InfoButton:SetDimensions(24,24)
        control.InfoButton:SetTexture("/esoui/art/miscellaneous/keyboard/tooltiphintarrow.dds")
        control.InfoButton:SetAnchor(RIGHT, control.slider, LEFT, -25, 0)
        control.InfoButton:SetMouseEnabled(true)
        local fooo1 = function(control)
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, control.data.customWarning())
        end
        control.InfoButton:SetHandler("OnMouseEnter", function() fooo1(control) end)
        control.InfoButton:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
        if ((AutoPricing.fees.engine ~= PRICES_OFF) and AutoPricing.fees.pricesUpdated) then
          if (control.data.getFunc() == -1) then
            control.data.wasSetManually = true
            HotepCraft.SetManualPriceFlag(control.data, true)
          end
          if (not HotepCraft.GetAutoPriceForMat(control.data)) then
            control.data.NOPRICE = true
            control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
            control.InfoButton:SetDimensions(32,32)
            local fooo2 = function(control)
              local tt = "No Price Data For This Material"
              ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, tt)
            end
            control.InfoButton:SetHandler("OnMouseEnter", function() fooo2(control) end)
          end
          control.data.customUpdate(control)
        end
        if (control.data.customHeight) then
          control:SetHeight(control.data.customHeight)
          control.label:SetHeight(control.data.customHeight)
        end
      end,
      customUpdate = function (control)
        
        control.data.colorfunc(control)
        
        if (AutoPricing.fees.engine == PRICES_OFF) then
          control.InfoButton:SetHidden(true)
          return
        end

        control.InfoButton:SetHidden(not AutoPricing.fees.pricesUpdated)

        if (not AutoPricing.fees.pricesUpdated) then
          return
        end
        
        if (control.data.NOPRICE) then return end

        local text

        if (control.data.wasSetManually) then
          text = "<<1>>This price was set Manually.|r\n\n<<2>>Click to to reset this price to Automatic.|r"
          text = zo_strformat(text, COLOR_RED, COLOR_YELLOW)

          local fooo = function()
            HotepCraft.SetAutoPriceForMat(control)
            ZO_Tooltips_HideTextTooltip()
            control.SHOWTOOLTIP = true
            return control.data.customUpdate(control)
          end
          control.InfoButton:SetHandler("OnMouseUp", function() return fooo(control) end)
          control.InfoButton:SetDimensions(30,30)
          control.InfoButton:SetColor(ROWCOLOR_RED:UnpackRGBA())
        end

        if (not control.data.wasSetManually) then
          text = control.data.customWarning(control)
          control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
          control.InfoButton:SetDimensions(24,24)
          control.InfoButton:SetColor(ROWCOLOR_GREEN:UnpackRGBA())
        end

        local fooo1 = function()
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, text)
        end
        control.InfoButton:SetHandler("OnMouseEnter", fooo1)
        if (control.SHOWTOOLTIP) then
          control.SHOWTOOLTIP = nil
          fooo1()
        end
      end,
      disabled = function()
        return ((AutoPricing.fees.engine ~= PRICES_OFF) and not AutoPricing.fees.allow_edit)
      end,
    }
  end
  
  local toption = function (name, warn, width)
    local nam = name
    
    nam = string.gsub(nam, "^Fee", "Discount", 1)
    
    if (not string.find(name, "|c", 1, true)) then
      nam = zo_strformat("<<1>><<2>>|r", COLOR_PURPLE, name)
    end
    
    if (not width) then
      width = "half"
    end
    
    return {
      type = "slider",
      name = nam,
      tooltip = zo_strformat("<<1>>This is a Per-Item Discount to give customer for providing their own mat|r", COLOR_PURPLE),
      warning = warn,
      min = 0,
      max = 125000,
      step = 50,
      decimals = 0,
      width = width,
      autoSelect = true,
      PricesData = {tradein = true, fee = true},
      colorfunc = function (control)
        local C = ROWCOLOR_PURPLE
        if (control.data.disabled()) then
          C = ROWCOLOR_PURPLEDIM
        end
        control.label:SetColor(C:UnpackRGBA())
        control.slider.bg:SetEdgeColor(C:UnpackRGBA())
        control.slider:SetColor(C:UnpackRGBA())
        control.slidervalue:SetColor(C:UnpackRGBA())
        control.slidervalueBG:SetEdgeColor(C:UnpackRGBA())
        control.minText:SetColor(C:UnpackRGBA())
        control.maxText:SetColor(C:UnpackRGBA())
      end,
      customWarning = function(control)
        if (AutoPricing.fees.tradeins.engine == PRICES_OFF) then return end
        if (not AutoPricing.fees.pricesUpdated) then return end

        local text = zo_strformat("<<1>>Price set by <<2>>|r", COLOR_GREEN, PRICE_ENGINE_NAMES[AutoPricing.fees.tradeins.engine])

        return text
      end,
      superSetFunc = function(control, n)
        control.data.wasSetManually = true
        HotepCraft.SetManualPriceFlag(control.data, true)
        return control.data.customUpdate(control)
      end,
      customInit = function (control)
        control.InfoButton = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
        control.InfoButton:SetDimensions(24,24)
        control.InfoButton:SetTexture("/esoui/art/miscellaneous/keyboard/tooltiphintarrow.dds")
        control.InfoButton:SetAnchor(RIGHT, control.slider, LEFT, -25, 0)
        control.InfoButton:SetMouseEnabled(true)
        local fooo1 = function(control)
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, control.data.customWarning())
        end
        control.InfoButton:SetHandler("OnMouseEnter", function() fooo1(control) end)
        control.InfoButton:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
        if ((AutoPricing.fees.tradeins.engine ~= PRICES_OFF) and AutoPricing.fees.pricesUpdated) then
          if (control.data.getFunc() == -1) then
            control.data.wasSetManually = true
            HotepCraft.SetManualPriceFlag(control.data, true)
          end
          if (not HotepCraft.GetAutoPriceForMat(control.data)) then
            control.data.NOPRICE = true
            control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
            control.InfoButton:SetDimensions(32,32)
            local fooo2 = function(control)
              local tt = "No Price Data For This Material"
              ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, tt)
            end
            control.InfoButton:SetHandler("OnMouseEnter", function() fooo2(control) end)
          end
          control.data.customUpdate(control)
        end
        if (control.data.customHeight) then
          control:SetHeight(control.data.customHeight)
          control.label:SetHeight(control.data.customHeight)
        end
      end,
      customUpdate = function (control)
        
        control.data.colorfunc(control)
        
        if (AutoPricing.fees.tradeins.engine == PRICES_OFF) then
          control.InfoButton:SetHidden(true)
          return
        end

        control.InfoButton:SetHidden(not AutoPricing.fees.pricesUpdated)

        if (not AutoPricing.fees.pricesUpdated) then
          return
        end
        
        if (control.data.NOPRICE) then return end

        local text

        if (control.data.wasSetManually) then
          text = "<<1>>This price was set Manually.|r\n\n<<2>>Click to to reset this price to Automatic.|r"
          text = zo_strformat(text, COLOR_RED, COLOR_YELLOW)

          local fooo = function()
            HotepCraft.SetAutoPriceForMat(control)
            ZO_Tooltips_HideTextTooltip()
            control.SHOWTOOLTIP = true
            return control.data.customUpdate(control)
          end
          control.InfoButton:SetHandler("OnMouseUp", function() return fooo(control) end)
          control.InfoButton:SetDimensions(30,30)
          control.InfoButton:SetColor(ROWCOLOR_RED:UnpackRGBA())
        end

        if (not control.data.wasSetManually) then
          text = control.data.customWarning(control)
          control.InfoButton:SetHandler("OnMouseUp", function() ShowItemToolTip(control) end)
          control.InfoButton:SetDimensions(24,24)
          control.InfoButton:SetColor(ROWCOLOR_GREEN:UnpackRGBA())
        end

        local fooo1 = function()
          ZO_Tooltips_ShowTextTooltip(control.InfoButton, TOP, text)
        end
        control.InfoButton:SetHandler("OnMouseEnter", fooo1)
        if (control.SHOWTOOLTIP) then
          control.SHOWTOOLTIP = nil
          fooo1()
        end
      end,
      disabled = function()
        return ((AutoPricing.fees.tradeins.engine ~= PRICES_OFF) and not AutoPricing.fees.tradeins.allow_edit)
      end,
    }
  end
  
  local header = function (name, width)
    if (not width) then
      width = "full"
    end
    
    return {
      type = "header",
      name = name,
      width = width,
    }
  end
  
  local descr = function (text, color)
    return {
      type = "description",
      text = zo_strformat("<<1>><<2>>|r", color, text)
    }
  end
  
  
  local submenu = function(name, controls, tooltip, color)
    if (not color) then
      color = COLOR_WHITE
    end
    
    return {
      type = "submenu",
      name = zo_strformat("<<1>><<2>>|r", color, name),
      tooltip = tooltip,
      controls = controls,
    }
  end
  
  
  
  local subm = HotepCraft.LAMAutoPriceOptions('fees')
  table.insert(feesOptions, submenu('Automatic Fee Pricing', subm, nil, COLOR_GREEN))
  
  
  
  
--  table.insert(feesOptions, header("Additional Fee for adding a Trait"))
  
  local subm = {}
  
--  table.insert(subm, descr(" ---- (Weapon Traits) ---- ", COLOR_MSG))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for trait, trec in spairs(WEP_TRAITS, eyesort) do
    local nam = zo_strformat("<<1>> (<<2>>)", trait, trec.jewel)
    local opt = choption(nam)
    opt.getFunc = function () return PriceList.traitfee.weapon[trait] end
    opt.setFunc = function (n) PriceList.traitfee.weapon[trait] = n end
    opt.itemtype = ITEMTYPE_WEAPON_TRAIT
    opt.matname = trec.jewel
    table.insert(subsub, opt)
    local opt = toption(nam)
    opt.getFunc = function () return TradePrices.traitfee.weapon[trait] end
    opt.setFunc = function (n) TradePrices.traitfee.weapon[trait] = n end
    opt.itemtype = ITEMTYPE_WEAPON_TRAIT
    opt.matname = trec.jewel
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Weapon Traits", subsub, nil, COLOR_MSG))
  
--  table.insert(subm, descr(" ---- (Armor Traits) ---- ", COLOR_MSG))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for trait, trec in spairs(ARM_TRAITS, eyesort) do
    local nam = zo_strformat("<<1>> (<<2>>)", trait, trec.jewel)
    local opt = choption(nam)
    opt.getFunc = function () return PriceList.traitfee.armor[trait] end
    opt.setFunc = function (n) PriceList.traitfee.armor[trait] = n end
    opt.itemtype = ITEMTYPE_ARMOR_TRAIT
    opt.matname = trec.jewel
    table.insert(subsub, opt)
    local opt = toption(nam)
    opt.getFunc = function () return TradePrices.traitfee.armor[trait] end
    opt.setFunc = function (n) TradePrices.traitfee.armor[trait] = n end
    opt.itemtype = ITEMTYPE_ARMOR_TRAIT
    opt.matname = trec.jewel
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Armor Traits", subsub, nil, COLOR_MSG))
  
  
  table.insert(feesOptions, submenu("Additional Fee for adding a Trait", subm))
  
  
  
--  table.insert(feesOptions, header("Additional Fee for creating a Set Item"))

  local subm = {}
  
  table.insert(subm, descr("(Set fee to -1 to prevent offering a Set for sale.)", COLOR_RED))
  
  for i = 1,OT.ARM_SETS() do
    local set = OT.ARM_SETS(i)
    local opt = option(HotepCraft.SetDescr(set))
    opt.min = -1
    opt.getFunc = function () return PriceList.setfees[i] end
    opt.setFunc = function (n) PriceList.setfees[i] = n end
    table.insert(subm, opt)
  end
  
  table.insert(feesOptions, submenu("Additional Fee for creating a Set Item", subm))
  
  
--  table.insert(feesOptions, header("Additional Fee for Improving an Item"))

  local subm = {}
  
  local improvs,_ = OT.PIECES("improve")
  
  
--  table.insert(subm, descr(" ---- (Blacksmithing Items) ---- ", COLOR_MSG))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for i = 1,#improvs do
    local opt = choption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_SMITH))
    opt.getFunc = function () return PriceList.improvefees[PROFESSION_SMITH][i] end
    opt.setFunc = function (n) PriceList.improvefees[PROFESSION_SMITH][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_ImproveMetal_<<1>>", i)
    opt.itemtype = ITEMTYPE_BLACKSMITHING_BOOSTER
    opt.matname = RESINS[PROFESSION_SMITH][i]
    table.insert(subsub, opt)
    
    local opt = toption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_SMITH))
    opt.getFunc = function () return TradePrices.improvefees[PROFESSION_SMITH][i] end
    opt.setFunc = function (n) TradePrices.improvefees[PROFESSION_SMITH][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_TImproveMetal_<<1>>", i)
    opt.itemtype = ITEMTYPE_BLACKSMITHING_BOOSTER
    opt.matname = RESINS[PROFESSION_SMITH][i]
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Blacksmithing Improvement", subsub, nil, COLOR_MSG))
  
  
--  table.insert(subm, descr(" ---- (Clothier Items) ---- ", COLOR_MSG))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for i = 1,#improvs do
    local opt = choption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_CLOTH))
    opt.getFunc = function () return PriceList.improvefees[PROFESSION_CLOTH][i] end
    opt.setFunc = function (n) PriceList.improvefees[PROFESSION_CLOTH][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_ImproveCloth_<<1>>", i)
    opt.itemtype = ITEMTYPE_CLOTHIER_BOOSTER
    opt.matname = RESINS[PROFESSION_CLOTH][i]
    table.insert(subsub, opt)
    
    local opt = toption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_CLOTH))
    opt.getFunc = function () return TradePrices.improvefees[PROFESSION_CLOTH][i] end
    opt.setFunc = function (n) TradePrices.improvefees[PROFESSION_CLOTH][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_TImproveCloth_<<1>>", i)
    opt.itemtype = ITEMTYPE_CLOTHIER_BOOSTER
    opt.matname = RESINS[PROFESSION_CLOTH][i]
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Clothier Improvement", subsub, nil, COLOR_MSG))
  
  
--  table.insert(subm, descr(" ---- (Woodworking Items) ---- ", COLOR_MSG))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for i = 1,#improvs do
    local opt = choption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_WOOD))
    opt.getFunc = function () return PriceList.improvefees[PROFESSION_WOOD][i] end
    opt.setFunc = function (n) PriceList.improvefees[PROFESSION_WOOD][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_ImproveWood_<<1>>", i)
    opt.itemtype = ITEMTYPE_WOODWORKING_BOOSTER
    opt.matname = RESINS[PROFESSION_WOOD][i]
    table.insert(subsub, opt)
    
    local opt = toption(HotepCraft.ImprovDescr(i, improvs, PROFESSION_WOOD))
    opt.getFunc = function () return TradePrices.improvefees[PROFESSION_WOOD][i] end
    opt.setFunc = function (n) TradePrices.improvefees[PROFESSION_WOOD][i] = n end
    opt.customHeight = 78
    opt.reference = zo_strformat("HotepCraft_LAM_TImproveWood_<<1>>", i)
    opt.itemtype = ITEMTYPE_WOODWORKING_BOOSTER
    opt.matname = RESINS[PROFESSION_WOOD][i]
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Woodworking Improvement", subsub, nil, COLOR_MSG))
  
  
  table.insert(feesOptions, submenu("Additional Fee for Improving an Item", subm))
  
  
  
--  table.insert(feesOptions, header("Enchantment Fees"))

  local subm = {}
  
  
--  table.insert(subm, header(zo_strformat("<<1>>Potency Rune Fees|r", COLOR_MSG)))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for lvl,_ in spairs(PriceList.enchant.pot) do
    local opt = choption(LvlName(POTENCY[lvl], lvl))
    opt.getFunc = function () return PriceList.enchant.pot[lvl] end
    opt.setFunc = function (n) PriceList.enchant.pot[lvl] = n end
    opt.customHeight = 52
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_POTENCY
    opt.matname = {POTENCY[lvl]['+'], POTENCY[lvl]['-']}
    table.insert(subsub, opt)
    local opt = toption(LvlName(POTENCY[lvl], lvl))
    opt.getFunc = function () return TradePrices.enchant.pot[lvl] end
    opt.setFunc = function (n) TradePrices.enchant.pot[lvl] = n end
    opt.customHeight = 52
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_POTENCY
    opt.matname = {POTENCY[lvl]['+'], POTENCY[lvl]['-']}
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Potency Rune Fees", subsub, nil, COLOR_MSG))
  
--  table.insert(subm, header(zo_strformat("<<1>>Essence Rune Fees|r", COLOR_MSG)))
  
  local subsub = {}
  
  table.insert(subsub, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subsub, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for e,_ in ipairs(PriceList.enchant.ess.armor) do
    local es = OT.ESSENCE("armor", e)
    local opt = choption(zo_strformat("<<1>> (<<2>>)", es.glyph, es.rune))
    opt.getFunc = function () return PriceList.enchant.ess.armor[e] end
    opt.setFunc = function (n) PriceList.enchant.ess.armor[e] = n end
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_ESSENCE
    opt.matname = es.rune
    table.insert(subsub, opt)
    local opt = toption(zo_strformat("<<1>> (<<2>>)", es.glyph, es.rune))
    opt.getFunc = function () return TradePrices.enchant.ess.armor[e] end
    opt.setFunc = function (n) TradePrices.enchant.ess.armor[e] = n end
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_ESSENCE
    opt.matname = es.rune
    table.insert(subsub, opt)
  end
  
  for e,_ in ipairs(PriceList.enchant.ess.weapon) do
    local es = OT.ESSENCE("weapon", e)
    local opt = choption(zo_strformat("<<1>> (<<2>>)", es.glyph, es.rune))
    opt.getFunc = function () return PriceList.enchant.ess.weapon[e] end
    opt.setFunc = function (n) PriceList.enchant.ess.weapon[e] = n end
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_ESSENCE
    opt.matname = es.rune
    table.insert(subsub, opt)
    local opt = toption(zo_strformat("<<1>> (<<2>>)", es.glyph, es.rune))
    opt.getFunc = function () return TradePrices.enchant.ess.weapon[e] end
    opt.setFunc = function (n) TradePrices.enchant.ess.weapon[e] = n end
    opt.itemtype = ITEMTYPE_ENCHANTING_RUNE_ESSENCE
    opt.matname = es.rune
    table.insert(subsub, opt)
  end
  
  table.insert(subm, submenu("Essence Rune Fees", subsub, nil, COLOR_MSG))
  
  table.insert(subm, descr(""))
  local xx = "(Customers don't get to choose the quality of their enchantments, "
  xx = xx .. "so you can make up the cost of Aspect Runes with your Flat Per Item Labor Fee.)"
  table.insert(subm, descr(xx, COLOR_GREEN))
  
  
  table.insert(feesOptions, submenu("Enchantment Fees", subm))
  
  
  
  
--  table.insert(feesOptions, header("Style Fees"))

  local subm = {}
  
  
  table.insert(subm, descr("(Set fee to -1 to prevent offering a Style for sale.)", COLOR_RED))
  
  table.insert(subm, header(zo_strformat("<<1>>Charges|r", COLOR_YELLOW), "half"))
  table.insert(subm, header(zo_strformat("<<1>>Discounts|r", COLOR_RED), "half"))
  
  for i = 1,OT.MOTIFS() do
    local style = OT.MOTIFS(i)
    local warn = nil
    
    if (style.crown) then
      warn = zo_strformat("<<1>>THIS IS A CROWN-STORE-ONLY STYLE|r", COLOR_RED);
    end
    
    local descr = zo_strformat("<<1>> (<<2>>)", style.name, style.mat)
    
    if (style.crown) then
      descr = zo_strformat("<<1>><<2>>|r", COLOR_RED, descr)
    end
    
    local opt = choption(descr, warn)
    opt.min = -1
    opt.getFunc = function () return PriceList.stylefees[i] end
    opt.setFunc = function (n) PriceList.stylefees[i] = n end
    opt.customHeight = 52
    opt.itemtype = ITEMTYPE_STYLE_MATERIAL
    opt.matname = style.mat
    table.insert(subm, opt)
    local opt = toption(descr, warn)
    opt.getFunc = function () return TradePrices.stylefees[i] end
    opt.setFunc = function (n) TradePrices.stylefees[i] = n end
    opt.customHeight = 52
    opt.itemtype = ITEMTYPE_STYLE_MATERIAL
    opt.matname = style.mat
    table.insert(subm, opt)
  end
  
  
  table.insert(feesOptions, submenu("Style Fees", subm))
  
end
-- end HotepCraft.CreateLAMFeeOptions(feesOptions)


function HotepCraft.CreateLAMCharOptions()
  
  local option = function (name)
    return {
      type = "dropdown",
      name = name,
      choices = CHARTYPES,
      warning = 'An "order-taker" is an alt-character who does not craft, but you want it to be able to advertise and take orders.',
      tooltip = "Is this character a crafter, a mule, an order-taker, or neither?",
      getFunc = function() return Settings.characters[name] end,
      setFunc = function(x) Settings.characters[name] = x end,
      requiresReload = true,
    }
  end
  
  local t = {}
  
  for name,_ in spairs(Settings.characters) do
    table.insert(t, option(name))
  end
  
  return t
end
-- end HotepCraft.CreateLAMCharOptions()


function HotepCraft.CreateLAMSlashHelp()
  
  local option = function(text)
    return {
      type = "description",
      text = text,
    }
  end
  
  local t = {}
  table.insert(t, option(zo_strformat("<<1>>/hotep cancel|r <<2>>= cancel the current chat order|r", COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat("<<1>>/hotep dnd|r <<2>>= toggle Do Not Disturb mode|r", COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat("<<1>>/hotep repeat|r <<2>>= repeat last prompt during chat ordering|r", COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat('<<1>>/hotep respond|r <<2>>= respond to the last ignored "price" or "order" request|r', COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat('<<1>>/hotep forceprice|r <<2>>= act as if player you are currently whispering to said "price"|r', COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat('<<1>>/hotep forceorder|r <<2>>= act as if player you are currently whispering to said "order"|r', COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat('<<1>>/hotep forceinfo|r <<2>>= act as if player you are currently whispering to said "info"|r', COLOR_GREEN, COLOR_MSG)))
  table.insert(t, option(zo_strformat("<<1>>/hotep|r <<2>>= get slash-command help for ALL Hotep\194\174 Add-ons|r", COLOR_GREEN, COLOR_YELLOW)))
  
  return t
end
-- end HotepCraft.CreateLAMSlashHelp()


function HotepCraft.CreateAddonSettingsPanel()
  local paneldata = {
    type = "panel",
    name = HotepCraft.title,
    displayName = HotepCraft.fancytitle,
    author = "|cff6633@tomtom|r|c3366ffhotep|r",
    version = HotepCraft.displayVersion,
    registerForRefresh = true,
  }
  
  
  local foodept = function(v, setting)
    local foo = function()
      HotepCraft_LAM_DEPOSIT_T1:UpdateValue()
      HotepCraft_LAM_DEPOSIT_T2:UpdateValue()
      HotepCraft_LAM_DEPOSIT_T3:UpdateValue()
      HotepCraft_LAM_DEPOSIT_A1:UpdateValue()
      HotepCraft_LAM_DEPOSIT_A2:UpdateValue()
      HotepCraft_LAM_DEPOSIT_A3:UpdateValue()
    end
    
    local one, two, three = 0, 0, 0
    
    if (v > 0) then
      if (Settings.dep1_thresh > 0) then
        one = (Settings.dep1_thresh + 1)
        three = (Settings.dep1_thresh + 2)
      end
      
      if (Settings.dep2_thresh > 0) then
        two = (Settings.dep2_thresh + 1)
      end
    end
    
    
    if (setting == 1) then
      Settings.dep1_thresh = v
      if (v == 0) then
        Settings.dep1_amt = 0
      end
    elseif (setting == 2) then
      Settings.dep2_thresh = math.max(v, one)
      if (v == 0) then
        Settings.dep2_amt = 0
      end
    elseif (setting == 3) then
      Settings.dep3_thresh = math.max(v, two, three)
      if (v == 0) then
        Settings.dep3_amt = 0
      end
    end
    
    zo_callLater(foo, 250)
  end
  -- end local function foodept
  
  
  local mainOptions = {
    {
      type = "checkbox",
      name = "Do Not Disturb",
      tooltip = "Temporarily suspend this addon's functions.",
      getFunc = function () return not disturbme end,
      setFunc = function (n) disturbme = (not n) end,
      warning = "This option is not saved when you log off or reloadui.",
      reference = "HotepCraft_LAM_DND_Checkbox",
    },
    
    {
      type = "checkbox",
      name = "Disable Automatic Adverts",
      tooltip = "Do not advertise on Zone Chat automatically.",
      getFunc = function () return Settings.noadverts end,
      setFunc = function (n) Settings.noadverts = n end,
      reference = "HotepCraft_LAM_DNA_Checkbox",
    },
    
    {
      type = "slider",
      name = "advert period",
      tooltip = "minutes between advertising on Zone Chat",
      min = 20,
      max = 120,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.advertper end,
      setFunc = function (n) Settings.advertper = n end,
      disabled = function () return Settings.noadverts end,
    },
    
    {
      type = "slider",
      name = "guild-chat spam protection",
      tooltip = "Prevent me from advertising more than once every x minutes on the same guild's chat channel.",
      min = 10,
      max = 60,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.guildlimit end,
      setFunc = function (n) Settings.guildlimit = n end,
    },
    
    {
      type = "slider",
      name = "max orders",
      tooltip = "max # of delivered orders to store in your memory",
      min = 50,
      max = 5000,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.maxorders end,
      setFunc = function (n) Settings.maxorders = n end,
    },
    
    
    {
      type = "editbox",
      name = "advertising text",
      tooltip = "text you will post to Zone Chat periodically",
      getFunc = function () return Settings.advert end,
      setFunc = function (n) Settings.advert = n end,
      isMultiline = true,
      isExtraWide = true,
    },
    
    {
      type = "editbox",
      name = "more info text",
      tooltip = 'text that you will whisper back when someone whispers "info"',
      getFunc = function () return Settings.moreinfo end,
      setFunc = function (n) Settings.moreinfo = n end,
      isMultiline = true,
      isExtraWide = true,
    },
    
    {
      type = "slider",
      name = "Guildie Discount (percent)",
      tooltip = 'Choose a percentage by which to reduce prices for your fellow Guild Members, or 0 for no discounts.',
      min = 0,
      max = 100,
      step = 1,
      decimals = 0,
      getFunc = function () return PriceList.discount end,
      setFunc = function (n) PriceList.discount = n end,
    },
    
    {
      type = "checkbox",
      name = "Allow Mat Trading",
      tooltip = "Allow customers to provide their own crafting materials for discounts.",
      getFunc = function () return Settings.allowTradeIns end,
      setFunc = function (n) Settings.allowTradeIns = n end,
    },
    
    {
      type = "checkbox",
      name = "Auto-Respond to all Whispers when busy",
      tooltip = "When you're taking an order, the addon will tell anyone else who whispers to you that you are busy.",
      getFunc = function () return Settings.busyWhisperAll end,
      setFunc = function (n) Settings.busyWhisperAll = n end,
    },
    
    {
      type = "header",
      name = "Deposit Requirements",
    },
    
    {
      type = "slider",
      name = "Require Deposit if over: ",
      tooltip = "If order grandtotal is more than this, then require a deposit. (0 to disable)",
      width = "half",
      min = 0,
      max = 50000,
      step = 100,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep1_thresh end,
      setFunc = function(v) foodept(v, 1) end,
      reference = "HotepCraft_LAM_DEPOSIT_T1",
    },
    
    {
      type = "slider",
      name = "Deposit %: ",
      tooltip = "Percentage of order grandtotal to charge as a deposit.",
      width = "half",
      min = 0,
      max = 100,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep1_amt end,
      setFunc = function(v) Settings.dep1_amt = v end,
      disabled = function() return (Settings.dep1_thresh == 0) end,
      reference = "HotepCraft_LAM_DEPOSIT_A1",
    },
    
    {
      type = "divider",
    },
    
    {
      type = "slider",
      name = "Require Deposit if over: ",
      tooltip = "If order grandtotal is more than this, then require a deposit. (0 to disable)",
      width = "half",
      min = 0,
      max = 200000,
      step = 200,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep2_thresh end,
      setFunc = function(v) foodept(v, 2) end,
      reference = "HotepCraft_LAM_DEPOSIT_T2",
    },
    
    {
      type = "slider",
      name = "Deposit %: ",
      tooltip = "Percentage of order grandtotal to charge as a deposit.",
      width = "half",
      min = 0,
      max = 100,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep2_amt end,
      setFunc = function(v) Settings.dep2_amt = v end,
      disabled = function() return (Settings.dep2_thresh == 0) end,
      reference = "HotepCraft_LAM_DEPOSIT_A2",
    },
    
    {
      type = "divider",
    },
    
    {
      type = "slider",
      name = "Require Deposit if over: ",
      tooltip = "If order grandtotal is more than this, then require a deposit. (0 to disable)",
      width = "half",
      min = 0,
      max = 500000,
      step = 500,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep3_thresh end,
      setFunc = function(v) foodept(v, 3) end,
      reference = "HotepCraft_LAM_DEPOSIT_T3",
    },
    
    {
      type = "slider",
      name = "Deposit %: ",
      tooltip = "Percentage of order grandtotal to charge as a deposit.",
      width = "half",
      min = 0,
      max = 100,
      clampInput = true,
      autoSelect = true,
      getFunc = function() return Settings.dep3_amt end,
      setFunc = function(v) Settings.dep3_amt = v end,
      disabled = function() return (Settings.dep3_thresh == 0) end,
      reference = "HotepCraft_LAM_DEPOSIT_A3",
    },
    
  }
  
  
  
  local fcoChoices = {
    ["none"] = false,
    ["Gear Set 1"] = FCOIS_CON_ICON_GEAR_1,
    ["Gear Set 2"] = FCOIS_CON_ICON_GEAR_2,
    ["Gear Set 3"] = FCOIS_CON_ICON_GEAR_3,
    ["Gear Set 4"] = FCOIS_CON_ICON_GEAR_4,
    ["Gear Set 5"] = FCOIS_CON_ICON_GEAR_5,
    ["Dynamic 1"] = FCOIS_CON_ICON_DYNAMIC_1,
    ["Dynamic 2"] = FCOIS_CON_ICON_DYNAMIC_2,
    ["Dynamic 3"] = FCOIS_CON_ICON_DYNAMIC_3,
    ["Dynamic 4"] = FCOIS_CON_ICON_DYNAMIC_4,
    ["Dynamic 5"] = FCOIS_CON_ICON_DYNAMIC_5,
    ["Dynamic 6"] = FCOIS_CON_ICON_DYNAMIC_6,
    ["Dynamic 7"] = FCOIS_CON_ICON_DYNAMIC_7,
    ["Dynamic 8"] = FCOIS_CON_ICON_DYNAMIC_8,
    ["Dynamic 9"] = FCOIS_CON_ICON_DYNAMIC_9,
    ["Dynamic 10"] = FCOIS_CON_ICON_DYNAMIC_10,
    ["Dynamic 11"] = FCOIS_CON_ICON_DYNAMIC_11,
    ["Dynamic 12"] = FCOIS_CON_ICON_DYNAMIC_12,
    ["Dynamic 13"] = FCOIS_CON_ICON_DYNAMIC_13,
    ["Dynamic 14"] = FCOIS_CON_ICON_DYNAMIC_14,
    ["Dynamic 15"] = FCOIS_CON_ICON_DYNAMIC_15,
    ["Dynamic 16"] = FCOIS_CON_ICON_DYNAMIC_16,
    ["Dynamic 17"] = FCOIS_CON_ICON_DYNAMIC_17,
    ["Dynamic 18"] = FCOIS_CON_ICON_DYNAMIC_18,
    ["Dynamic 19"] = FCOIS_CON_ICON_DYNAMIC_19,
    ["Dynamic 20"] = FCOIS_CON_ICON_DYNAMIC_20,
    ["Dynamic 21"] = FCOIS_CON_ICON_DYNAMIC_21,
    ["Dynamic 22"] = FCOIS_CON_ICON_DYNAMIC_22,
    ["Dynamic 23"] = FCOIS_CON_ICON_DYNAMIC_23,
    ["Dynamic 24"] = FCOIS_CON_ICON_DYNAMIC_24,
    ["Dynamic 25"] = FCOIS_CON_ICON_DYNAMIC_25,
    ["Dynamic 26"] = FCOIS_CON_ICON_DYNAMIC_26,
    ["Dynamic 27"] = FCOIS_CON_ICON_DYNAMIC_27,
    ["Dynamic 28"] = FCOIS_CON_ICON_DYNAMIC_28,
    ["Dynamic 29"] = FCOIS_CON_ICON_DYNAMIC_29,
    ["Dynamic 30"] = FCOIS_CON_ICON_DYNAMIC_30,
  }
  
  local fcoNames = {}
  local fcoIndex = {}
  
  local fcosort = function(a, b)
    return (a.sortOrder < b.sortOrder)
  end
  
  if (FCOIS) then
    for k,v in pairs(fcoChoices) do
      if (v and FCOIS.settingsVars.settings.icon[v].name) then
        local obj = FCOIS.settingsVars.settings.icon[v]
        local name = obj.name
        local color = obj.color
        local cdef = ZO_ColorDef:New(color.r, color.g, color.b, color.a)
        name = cdef:Colorize(name)
        fcoNames[name] = v
        table.insert(fcoIndex, {key = name, sortOrder = obj.sortOrder})
      else
        fcoNames[k] = v
        if (v) then
          local obj = FCOIS.settingsVars.settings.icon[v]
          table.insert(fcoIndex, {key = k, sortOrder = obj.sortOrder})
        else
          table.insert(fcoIndex, {key = k, sortOrder = -99})
        end
      end
    end
  end
  
  table.sort(fcoIndex, fcosort)
  
  local fcoKeys = {}
  
  for _,i in ipairs(fcoIndex) do
    table.insert(fcoKeys, i.key)
  end
  
  
  local getFCO = function ()
    if (not Settings.UseFCOis) then
      return "none"
    else
      local k,_ = array_find(Settings.UseFCOis, fcoNames)
      return k
    end
  end
  
  local setFCO = function (n)
    Settings.UseFCOis = fcoNames[n]
  end
  
  local FCOisOption = {
    type = "dropdown",
    name = "FCO ItemSaver Icon for order items",
    tooltip = "When you craft an item for an order, it will automatically be marked with this FCOIS Icon",
    choices = fcoKeys,
    getFunc = getFCO,
    setFunc = setFCO,
  }
  
  if (FCOIS) then
    table.insert(mainOptions, FCOisOption)
  end
  
  
  local characterOptions = HotepCraft.CreateLAMCharOptions()
  
  
  local pricesOptions = HotepCraft.CreateLAMPriceOptions()
  
  
  local feesOptions = {
    [1] = {
      type = "slider",
      name = "Per Order Fee",
      tooltip = "A Flat Labor Fee added to each order.",
      min = 0,
      max = 5000,
      step = 1,
      decimals = 0,
      getFunc = function () return PriceList.fixedfee end,
      setFunc = function (n) PriceList.fixedfee = n end,
    },
    
    [2] = {
      type = "slider",
      name = "Per Item Fee",
      tooltip = "A Flat Labor Fee added for each item in the order.",
      min = 0,
      max = 5000,
      step = 1,
      decimals = 0,
      getFunc = function () return PriceList.itemfee end,
      setFunc = function (n) PriceList.itemfee = n end,
    },
    
    [3] = {
      type = "checkbox",
      name = "Tell customers about the Labor Fees?",
      tooltip = 'When someone whispers "order", they will be told the Per-Order and Per-Item fees up front.',
      getFunc = function () return Settings.informFees end,
      setFunc = function (n) Settings.informFees = n end,
    },
    
  }
  
  
  HotepCraft.CreateLAMFeeOptions(feesOptions)
  
  
  table.insert(mainOptions, {
      type = "submenu",
      name = "Characters",
      controls = characterOptions,
    })
  
  
  table.insert(mainOptions, {
      type = "submenu",
      name = "Base Pricing",
      controls = pricesOptions,
      reference = "HotepCraft_LAM_BASEPRICES",
    })
  
  
  table.insert(mainOptions, {
      type = "submenu",
      name = "Fees",
      controls = feesOptions,
    })
  
  
  table.insert(mainOptions, {
      type = "submenu",
      name = "Slash-Command List",
      controls = HotepCraft.CreateLAMSlashHelp(),
    })
  
  
  table.insert(mainOptions, {
      type = "description",
      text = "Hotep\194\174 is a registered trademark of Simple Designs Software LLC. All Rights Reserved.",
      reference = "HotepCraft_MyLamRegNote",
    })
  
  
  
  HotepCraft.TheLAMAddonPanel = LAM:RegisterAddonPanel(HotepCraft.name, paneldata)
  LAM:RegisterOptionControls(HotepCraft.name, mainOptions)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", HotepCraft.MyLAMInit)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", HotepCraft.UpdateMyLAM)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", HotepCraft.VerifySettings)
end
-- end HotepCraft.CreateAddonSettingsPanel()



function HotepCraft.MyLAMInit(panel)
  
  if (not panel or (panel ~= HotepCraft.TheLAMAddonPanel)) then return end
  
  CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", HotepCraft.MyLAMInit)
  
  for _,control in ipairs(HotepCraft.TheLAMAddonPanel.controlsToRefresh) do
    if (control.data and control.data.colorfunc) then
      control.data.colorfunc(control)
      if (control.UpdateDisabled) then
        local orig = control.UpdateDisabled
        control.UpdateDisabled = function(control)
          orig(control)
          control.data.colorfunc(control)
        end
      end
    end
    
    if (control.data and control.data.customInit) then
      control.data.customInit(control)
      if (control.UpdateWarning) then control:UpdateWarning() end
    end
    
    if (control.data and control.UpdateValue and control.data.customUpdate) then
      local orig = control.UpdateValue
      control.UpdateValue = function (control, forceDefault, value)
        if (type(control.data.tooltip) == "function") then
          control.data.tooltipText = control.data.tooltip()
        end
        control.data.customUpdate(control, forceDefault, value)
        orig(control, forceDefault, value)
      end
    end
    
    if (control.data and control.data.setFunc and control.data.superSetFunc) then
      local orig = control.data.setFunc
      control.data.setFunc = function(n)
        control.data.superSetFunc(control, n)
        orig(n)
      end
      control.data.bypassSetFunc = function(n)
        orig(n)
      end
      
      if (HotepCraft.GetManualPriceFlag(control.data)) then
        control.data.wasSetManually = true
      end
    end
    
    if (control.data and (control.data.type == "dropdown")) then
      if (control.data.longer) then
        local width = 250
        if (type(control.data.longer) == "number") then
          width = control.data.longer
        end
        control.container:SetWidth(width)
        control.combobox:SetWidth(width)
        if (control.isHalfWidth) then
          control.container:SetAnchor(TOPLEFT, control.label, BOTTOMLEFT, 5, 2)
          if (type(control.data.longerlabel) == "number") then
            width = control.data.longerlabel
          end
          control:SetWidth(width)
          control.label:SetWidth(width)
        end
      end
    end
    
    if (control.data and (control.data.type == "button")) then
      if (type(control.data.longer) == "number") then
        local width = control.data.longer
        control:SetWidth(width)
        control.button:SetWidth(width)
      end
    end
  end     -- end loop controlsToRefresh
  
  
--  if (#PRICES_ENGINES > 1) then
--    if (not AutoPricing.base.pricesUpdated and not AutoPricing.fees.pricesUpdated) then
--      HotepCraft.ResetAllAutoPrices('both', 'both')
--    elseif (not AutoPricing.base.pricesUpdated) then
--      HotepCraft.ResetAllAutoPrices('base', 'both')
--    elseif (not AutoPricing.fees.pricesUpdated) then
--      HotepCraft.ResetAllAutoPrices('fees', 'both')
--    end
--  end
  
  
  HotepCraft.TheLAMAddonPanel:RefreshPanel()
end
-- end HotepCraft.MyLAMInit(panel)


function HotepCraft.GetManualPriceFlag(widgetData)
  local tradein = widgetData.PricesData.tradein
  local fees = widgetData.PricesData.fee
  local itemType = widgetData.itemtype
  local itemName = widgetData.matname
  
  local key1 = "base"
  if (fees) then
    key1 = "fees"
  end
  
  local key2 = "mats"
  if (tradein) then
    key2 = "tradeins"
  end
  
  
  if ((AutoPricing.base.engine == PRICES_OFF) and AutoPricing.base.tradeins.same
      and (AutoPricing.fees.engine == PRICES_OFF) and AutoPricing.fees.tradeins.same) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    return false
  end
  
  if ((AutoPricing.base.engine == PRICES_OFF) and (AutoPricing.base.tradeins.engine == PRICES_OFF)
      and (AutoPricing.fees.engine == PRICES_OFF) and (AutoPricing.fees.tradeins.engine == PRICES_OFF)) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    return false
  end
  
  return ManuallyPricedItems[key1][key2][itemType][itemName]
end
-- end HotepCraft.GetManualPriceFlag(widgetData)


function HotepCraft.SetManualPriceFlag(widgetData, yes)
  
  local tradein = widgetData.PricesData.tradein
  local fees = widgetData.PricesData.fee
  local itemType = widgetData.itemtype
  local itemName = widgetData.matname
  
  local key1 = "base"
  if (fees) then
    key1 = "fees"
  end
  
  local key2 = "mats"
  if (tradein) then
    key2 = "tradeins"
  end
  
  if ((AutoPricing.base.engine == PRICES_OFF) and AutoPricing.base.tradeins.same
      and (AutoPricing.fees.engine == PRICES_OFF) and AutoPricing.fees.tradeins.same) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    return
  end
  
  if ((AutoPricing.base.engine == PRICES_OFF) and (AutoPricing.base.tradeins.engine == PRICES_OFF)
      and (AutoPricing.fees.engine == PRICES_OFF) and (AutoPricing.fees.tradeins.engine == PRICES_OFF)) then
    savedVariables.vars[SV_MANUALS].ManuallyPricedItems = clone(MANUALLYSET)
    ManuallyPricedItems = savedVariables.vars[SV_MANUALS].ManuallyPricedItems
    return
  end
  
  
  
  if (yes) then
    ManuallyPricedItems[key1][key2][itemType][itemName] = 1
  else
    ManuallyPricedItems[key1][key2][itemType][itemName] = nil
  end
end
-- end HotepCraft.SetManualPriceFlag(widgetData, yes)


function HotepCraft.UpdateMyLAM(panel)
  
  if (not panel or (panel ~= HotepCraft.TheLAMAddonPanel)) then return end
  
  HotepCraft.TheLAMAddonPanel:RefreshPanel()
  
end
-- end HotepCraft.UpdateMyLAM(panel)


function HotepCraft.CheckForAutoPricing()
  
  local manual = false
  
  if (HotepCraft.TheLAMAddonPanel.AUTOPRICINGAUTO) then
    if (HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN) then
      manual = 'both'
    end
  elseif (HotepCraft.TheLAMAddonPanel.AUTOPRICINGMAN) then
    manual = true
  else
    return
  end
  
  if (HotepCraft.TheLAMAddonPanel.DOAUTOPRICING) then
    if (#PRICES_ENGINES > 1) then
      msgWithName("Recalculating Pricing...", COLOR_GREEN)
      if (not AutoPricing.base.pricesUpdated and not AutoPricing.fees.pricesUpdated) then
        HotepCraft.ResetAllAutoPrices('both', manual)
      elseif (not AutoPricing.base.pricesUpdated) then
        HotepCraft.ResetAllAutoPrices('base', manual)
      elseif (not AutoPricing.fees.pricesUpdated) then
        HotepCraft.ResetAllAutoPrices('fees', manual)
      end
      msgWithName("Pricing Recalculation Complete!", COLOR_GREEN)
    end
  end
  
end
-- end HotepCraft.CheckForAutoPricing()


function HotepCraft.VerifySettings(panel)
  
  if (not panel or (panel ~= HotepCraft.TheLAMAddonPanel)) then return end
  
  msgDebug(" **** VerifySettings ****")
  HotepCraft.CheckForAutoPricing()
  
  local good = true
  
  if (Settings.advert == "") then
    msgWithName('"advertising text" cannot be blank.', COLOR_PURPLE);
    msgWithName("Please Set Up Addon.", COLOR_RED)
    HotepCraft.setupgood = false
    return false
  end
  
  if ((Settings.dep1_thresh + Settings.dep2_thresh + Settings.dep3_thresh) > 0) then
    if ((Settings.dep2_thresh > 0) and (Settings.dep2_thresh <= Settings.dep1_thresh)) then
      good = false
    elseif ((Settings.dep3_thresh > 0) 
          and ((Settings.dep3_thresh <= Settings.dep2_thresh) or (Settings.dep3_thresh <= Settings.dep1_thresh))) then
      good = false
    end
    
    if (not good) then
      msgWithName("Deposit Requirements set up incorrectly.", COLOR_PURPLE)
      msgWithName("Please Set Up Addon.", COLOR_RED)
      HotepCraft.setupgood = false
      return false
    end
  end
  
  
  for _,p in pairs(PriceList.price.metals) do
    if (p < 1) then
      good = false
      break
    end
  end
  
  if (good) then
    for _,p in pairs(PriceList.price.medarm) do
      if (p < 1) then
        good = false
        break
      end
    end
  end
  
  if (good) then
    for _,p in pairs(PriceList.price.lightarm) do
      if (p < 1) then
        good = false
        break
      end
    end
  end
  
  if (good) then
    for _,p in pairs(PriceList.price.woods) do
      if (p < 1) then
        good = false
        break
      end
    end
  end
  
  
  HotepCraft.setupgood = good
  if (not good) then
    msgWithName('Some of your Base Prices are set to zero.', COLOR_PURPLE);
    msgWithName("That's not a good way to run a business!", COLOR_PURPLE)
    msgWithName("Please Set Up Addon.", COLOR_RED)
    return false
  end
  
  local illogical = false
  
  if ((Settings.dep1_thresh + Settings.dep2_thresh + Settings.dep3_thresh) > 0) then
    if ((Settings.dep1_thresh > 0) and (Settings.dep2_thresh > 0) and (Settings.dep2_amt <= Settings.dep1_amt)) then
      illogical = true
    end
    if ((Settings.dep1_thresh > 0) and (Settings.dep3_thresh > 0) and (Settings.dep3_amt <= Settings.dep1_amt)) then
      illogical = true
    end
    if ((Settings.dep2_thresh > 0) and (Settings.dep3_thresh > 0) and (Settings.dep3_amt <= Settings.dep2_amt)) then
      illogical = true
    end
    
    if (illogical) then
      msgWithName("Your Deposit Requirements seem illogical.  Please double-check them!", COLOR_PURPLE)
    end
  end
  
  
  HotepCraft.CheckTradeIns()
  
  
  return good
end
-- end HotepCraft.VerifySettings()


function HotepCraft.CheckTradeIns()
  
  if (not Settings.allowTradeIns) then return end
  
  local good = false
  
  
  for _,p in pairs(TradePrices.price.metals) do
    if (p > 0) then
      good = true
      break
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.price.medarm) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.price.lightarm) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.price.woods) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  
  if (not good) then
    for _,p in pairs(TradePrices.traitfee.armor) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.traitfee.weapon) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.stylefees) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  
  if (not good) then
    for _,p in pairs(TradePrices.improvefees[PROFESSION_SMITH]) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.improvefees[PROFESSION_CLOTH]) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.improvefees[PROFESSION_WOOD]) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  
  if (not good) then
    for _,p in pairs(TradePrices.enchant.pot) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.enchant.ess.armor) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  if (not good) then
    for _,p in pairs(TradePrices.enchant.ess.weapon) do
      if (p > 0) then
        good = true
        break
      end
    end
  end
  
  
  
  Settings.allowTradeIns = good
end
-- end HotepCraft.CheckTradeIns()


function HotepCraft.Advertise(channel)
  
  if (not HotepCraft.VerifySettings(HotepCraft.TheLAMAddonPanel)) then
    msgDebug("VerifySettings Failed")
    if (not channel) then timer_Advert:Start(10) end
    return
  end
  
  if (HotepCraft.busy) then
    msgDebug("BUSY!")
    if (not channel) then timer_Advert:Start(10) end
    return
  end
  
  if (not channel and not disturbme) then
    msgDebug("DoNotDisturb is ON.")
    timer_Advert:Start(10)
    return
  end
  
  if (not channel and Settings.noadverts) then
    msgDebug("Advertising is DISABLED.")
    timer_Advert:Start(10)
    return
  end
  
  
  local guilds = {
    [CHAT_CHANNEL_GUILD_1] = 1,
    [CHAT_CHANNEL_GUILD_2] = 2,
    [CHAT_CHANNEL_GUILD_3] = 3,
    [CHAT_CHANNEL_GUILD_4] = 4,
    [CHAT_CHANNEL_GUILD_5] = 5,
  }
  
  
  
  local t = {Settings.advert}
  
  if (channel and guilds[channel] and (PriceList.discount > 0)) then
    table.insert(t, zo_strformat('Guild Members get <<1>>% discount!', PriceList.discount))
  end
  
  
  table.insert(t, 'Whisper "info" for more info, "price" for a price-list, '..
                  '"extra" for the list of Sets and Styles, or "order" to place an order.')
  
  local delay = 0.3
  if (not channel) then
    channel = "/zone"
    delay = 1.5
  end
  
  ChatQueue(delay, channel, nil, nil, nil, t)
  
  if (channel == "/zone") then
    timer_Advert:Start(Settings.advertper)
  end
end
-- end HotepCraft.Advertise()



function HotepCraft.AdvertToCurrentChat()
  local channel = CHAT_SYSTEM.currentChannel
  
  if ((channel == CHAT_CHANNEL_ZONE) and not Settings.noadverts) then
    msgWithName("Zone Adverts are automatic.  You can change the period in the add-on settings.", COLOR_RED)
    return
  end
  
  local guilds = {
    [CHAT_CHANNEL_GUILD_1] = 1,
    [CHAT_CHANNEL_GUILD_2] = 2,
    [CHAT_CHANNEL_GUILD_3] = 3,
    [CHAT_CHANNEL_GUILD_4] = 4,
    [CHAT_CHANNEL_GUILD_5] = 5,
  }
  
  if (guilds[channel]) then
    if (GetDiffBetweenTimeStamps(GetTimeStamp(), HotepCraft.lastGuildAdvert[guilds[channel]]) < (Settings.guildlimit * 60)) then
      msgWithName("Too Soon.", COLOR_RED)
      return
    else
      HotepCraft.lastGuildAdvert[guilds[channel]] = GetTimeStamp()
    end
  end
  
  
  HotepCraft.Advertise(channel)
end




---@local timer_ordertimeout @class Timer
local timer_ordertimeout


function HotepCraft.CancelReviewCheckout(handle)
  if (type(handle) == "string") then
    msgWithName("Order-Review Timeout", COLOR_PURPLE)
    HotepCraft:OnGotOrderingResponse(handle, "back")
  end
end

---@local timer_reviewcheckout @class Timer
local timer_reviewcheckout = Timer:New(2, HotepCraft.CancelReviewCheckout, nil, true)


function HotepCraft.TakeAnOrder()
  
  local handle = HotepCraft.neworder.order.customer
  local params = HotepCraft.neworder.params
  ---@local order @class ORDER
  local order = HotepCraft.neworder.order
  local item = HotepCraft.neworder.params.item
  local validator = HotepCraft.neworder.params.validator
  local resp = HotepCraft.neworder.params.response
  
  if (type(params.stage) == "nil") then
    order.guildie = IsAGuildie(handle)
    params.stage = "whatlevel"
  end
  
  if (not timer_ordertimeout) then
    timer_ordertimeout = Timer:New(CHAT_ORDERING_TIMEOUT, HotepCraft.OrderTimeOut)
  else
    timer_ordertimeout:Start(CHAT_ORDERING_TIMEOUT)
  end
  
  local notvalid = function ()
    HotepCraft.neworder.params.stage = validator[1]
--    local stage = validator[1]
    local t = {"Invalid Response.", unpack(validator[2])}
--    HotepCraft.neworder.params.validator = OT.Validator(OT.theOT[stage], stage)
    savedVariables:AppendChatLog(t)
    ChatQueue(10, "wisp", handle, nil, nil, t)
  end
  
  
  local validate = function ()
    local valid = false
    
--    msgDebug("----")
--    msgDebug(HotepCraft.neworder.params.validator)
--    msgDebug("----")
--    msgDebug(validator)
--    msgDebug("----")
    
    for k, v in pairs(validator[3]) do
      if ((k == "intrange") and (type(tonumber(resp)) == "number")) then
        local i = tonumber(resp)
        if ((v[1] <= i) and (i <= v[2])) then
          valid = true
          break
        end
      elseif ((k == "number") and (tonumber(resp) == v)) then
        valid = true
        break
      elseif ((k == "string") and (resp == v)) then
        valid = true
        break
      elseif ((k == "crange") and (string.len(resp) == 1)) then
        if ((v[1] <= resp) and (resp <= v[2])) then
          valid = true
          break
        end
      elseif ((k == "list") and in_array(resp, v)) then
        valid = true
        break
      elseif ((k == "numlist") and in_array(tonumber(resp), v)) then
        valid = true
        break
      elseif (string.find(string.lower(resp), k, 1, true) 
                and not in_array(k, {"intrange","number","string","crange","list","numlist"})) then
          HotepCraft.neworder.params.response = v
          resp = HotepCraft.neworder.params.response
          valid = true
          break
      end
    end
    
    if (not valid) then notvalid() end
    return valid
  end
  -- end local validate()
  
  
  ---
-- @param chat @class table
-- @return @class table
  local choppy = function(chat)
    local t = {}
    
    for _,s in ipairs(chat) do
      OT.insert_chop(t, s)
    end
    
    return t
  end
  -- end local choppy(chat)
  
  
  
  local looping = true
  
  while (looping) do
    local T = OT.theOT[params.stage]
    
    params.T.chat = clone(T.chat)
    params.T.val = clone(T.val)
    
--    msgDebug(params.stage)
--    msgDebug("---")
--    msgDebug({T = T})
    
    if (T.check) then
      if (not validate()) then return end
    end
    
    if (T.fun) then T.fun(HotepCraft, PriceList) end
    
--    msgDebug("---")
--    msgDebug({paramsT = params.T})
    
    if (params.T.chat) then
      HotepCraft.neworder.params.validator = OT.Validator(params.T, params.stage)
--      msgDebug("===>")
--      msgDebug(validator)
--      msgDebug("---")
--      msgDebug(HotepCraft.neworder.params.validator)
--      msgDebug("<===")
      
      if (in_array(params.stage, {"reviewcheckout", "wantedititem"})) then
        timer_reviewcheckout:Start(10)
        timer_reviewcheckout.params = handle
      else
        timer_reviewcheckout:Stop()
      end
      
      local reviewFoo = function()
        if (not timer_reviewcheckout.stopped) then
          timer_reviewcheckout:Start(2)
        end
        if (HotepCraft.neworder.params.AUTOLOOP) then
          HotepCraft.neworder.params.AUTOLOOP = nil
          HotepCraft.TakeAnOrder()
        end
      end
      
      if (params.stage == "whatlevel") then
        if (order.guildie and (PriceList.discount > 0)) then
          local gdm = zo_strformat("As a fellow guildie, you will receive a <<1>>% discount!", PriceList.discount)
          table.insert(params.T.chat, 1, gdm)
        end
        if (Settings.informFees and ((PriceList.fixedfee > 0) or (PriceList.itemfee > 0))) then
          local mm = zo_strformat("Labor fees: <<1>>g for the order + <<2>>g per item.", PriceList.fixedfee, PriceList.itemfee)
          table.insert(params.T.chat, 1, mm)
        end
        local xx = zo_strformat("Hello. You are now chatting Directly with my <<1>> Add-On.", HotepCraft.chattitle)
        table.insert(params.T.chat, 1, xx)
      end
      
      
      HotepCraft.ChatWithErrorChecking(10, "wisp", handle, reviewFoo, nil, choppy(params.T.chat))
      return
    end
    
    if (T.stage) then params.stage = T.stage end
    
    looping = T.tail
  end
  
  if (params.stage == "placeorder") then
    HotepCraft.FinalizeOrder()
    return
  end
  
  if (params.stage == "AUTOCANCEL") then
    HotepCraft:OnGotOrderingResponse(handle, "AUTOCANCEL")
    local xx = {'You have no items in your cart. Order canceled. Whisper "order" to place another order.'}
    ChatQueue:New(10, "wisp", handle, nil, nil, xx)
    return
  end
  
end
-- end HotepCraft.TakeAnOrder()


function HotepCraft.ChatWithErrorChecking(timeout, channel, handle, callback, failback, msgs)
  HotepCraft.CurrentChatError = {
    timeout = timeout,
    channel = channel,
    handle = handle,
    callback = callback,
    failback = failback,
    msgs = clone(msgs),
  }
  
  savedVariables:AppendChatLog(msgs)
  
  ChatQueue:New(timeout, channel, handle, HotepCraft.NoChatError, HotepCraft.ChatErrorHappened, msgs)
end


function HotepCraft.ChatErrorHappened()
  
  if (not HotepCraft.CurrentChatError) then return end
  
  local fail = HotepCraft.CurrentChatError.failback
  
  if (type(fail) == "function") then fail() end
  
  if (not HotepCraft.CurrentChatError) then return end
  
  SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_ChatError)
  
  HotepCraft.ChatWithErrorChecking(HotepCraft.CurrentChatError.timeout, HotepCraft.CurrentChatError.channel, 
                                  HotepCraft.CurrentChatError.handle, HotepCraft.CurrentChatError.callback, 
                                  HotepCraft.CurrentChatError.failback, HotepCraft.CurrentChatError.msgs)
end


function HotepCraft.NoChatError()
  
  if (not HotepCraft.CurrentChatError) then return end
  
  local fun = HotepCraft.CurrentChatError.callback
  
  SCENE_MANAGER:HideTopLevel(HotepCraft_UI_ChatError)
  HotepCraft.SavedChat = clone(HotepCraft.CurrentChatError)
  HotepCraft.CurrentChatError = nil
  
  if (type(fun) == "function") then fun() end
end


function HotepCraft.ChatErrorStopRetry()
  HotepToolsLib.shutup()
  HotepCraft.CurrentChatError = nil
  SCENE_MANAGER:HideTopLevel(HotepCraft_UI_ChatError)
end


function HotepCraft.OrderTimeOut()
  
  if (not HotepCraft.busy) then
    if (timer_ordertimeout) then
      timer_ordertimeout:Stop()
      timer_ordertimeout:Destroy()
    end
    timer_ordertimeout = nil
    
    if (timer_sendingpricing) then
      timer_sendingpricing:Stop()
      timer_sendingpricing:Destroy()
      timer_sendingpricing = nil
      return false
    else
      return true
    end
  end
  
  SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_Timeout)  
end



function HotepCraft.FinalizeOrder(UIEntry, OrderStatus)
  ---@local order @class ORDER
  local order = HotepCraft.neworder.order
  local handle = HotepCraft.neworder.order.customer
  
  local n = OrderDatabase.lastordernumber
  n = n + 1
  OrderDatabase.lastordernumber = n
  order.ordernumber = n
  if (string.len(order.uuid) < 1) then
    order.uuid = newOrderUUID()
  end
  order.asof = GetTimeStamp()
  
  if (not OrderStatus) then
    OrderStatus = ORDER_STATUS_WAITING
  end
  
  order.Status = OrderStatus
  
  local sets = {}
  ---@local item @class ITEM
  for i,item in pairs(order.items) do
    if (item.trait) then
      order.traits = order.traits + 1
    end
    if (item.enchant > 0) then
      order.enchants = order.enchants + 1
    end
    if (item.set > 0) then
      sets[item.set] = true
    end
  end
  
  for _,_ in pairs(sets) do
    order.sets = order.sets + 1
  end
  
  table.insert(OrderDatabase.orders[OrderStatus], clone(order))
  
  OrderDatabase.modified = GetTimeStamp()
  OrderDatabase.total[OrderStatus] = OrderDatabase.total[OrderStatus] + 1
  table.insert(OrderDatabase.uuids, order.uuid)
  
  
  local foomail = function()
    HotepCraft.MailOrderReceipt()
  end
  
  
  if (not UIEntry) then
    local msgs = {"Thank you for your order. A summary will be mailed to you."}
    
    ChatQueue:New(10, "wisp", handle, foomail, foomail, msgs)
  else
    HotepCraft.MailOrderReceipt()
  end
end
-- end HotepCraft.FinalizeOrder(UIEntry, OrderStatus)


---
-- @param modified @class boolean
-- @param order @class ORDER
function HotepCraft.MailOrderReceipt(modified, order)
  ---@local order @class ORDER
  
  if (not order) then
    local uu = HotepCraft.neworder.order.uuid
    order = HotepCraft.ReturnOrderByUUID(uu)
  end
  
  local handle = order.customer
  
  if (handle == HotepCraft.me) then
    STD.CriticalChange(HotepCraft.name)
    return false
  end
  
  local line = {}
  local itemline = {}
  
  local zz = "COD'd"
  if (order.grandtotal == 0) then
    zz = "mailed"
  end
  
  local num = #order.items
  local globing = false
  local subj = ''
  
  if (num > MAX_ITEMS_PER_ORDER_CONFIRM) then
    globing = true
    subj = " (mail <<1>> of <<2>>)"
  end
  
  
  local nummails = math.ceil(num / MAX_ITEMS_PER_ORDER_CONFIRM)
  
  
  local subject = "Thank you for your order"
  
  if ((order.uuid == "00") or (order.uuid == "XX")) then
    local uu = order.uuid
    order.uuid = newOrderUUID()
--    local i,_ = array_find(uu, OrderDatabase.orders[order.Status], function(ele) return ele.uuid end)
--    OrderDatabase.orders[order.Status][i].uuid = order.uuid
    if (uu == "XX") then
      order.THISISTESTORDER = true
--      OrderDatabase.orders[order.Status][i].THISISTESTORDER = true
    end
    if (CurrentClaim.orderuuid and (CurrentClaim.orderuuid == uu)) then
      CurrentClaim.orderuuid = order.uuid
    end
  else
    if (modified == "adjusted") then
      subject = "Your Order Total has been adjusted"
    elseif (modified) then
      subject = "Your Order has been modified"
    end
  end
  
  
  
  table.insert(line, zo_strformat("Order#: <<1>>", order.ordernumber))
  table.insert(line, zo_strformat("Order ID: <<1>>", order.uuid))
  table.insert(line, zo_strformat("Order Total: <<1>>g.", order.grandtotal))
  table.insert(line, zo_strformat("Your order will be <<1>> when completed.", zz))
  
  ---@local item @class ITEM
  for i,item in pairs(order.items) do
    local nam = OT.GetName(item, order.level, true)
    local des = OT.GetDescr(item)
    local msg = zo_strformat("<<1>> <<2>>: <<3>>g.", nam, des, (item.price + item.fee))
    
    if (globing) then
      table.insert(itemline, msg)
    else
      table.insert(line, msg)
    end
  end
  
  
  
  local saymailsent = function(params, success)
    local x, y
    if (success) then
      x = "sent successfully."
      y = COLOR_GREEN
    else
      x = "failed to send."
      y = COLOR_RED
    end
    
    if (params.i) then
      msgWithName(zo_strformat("Receipt part <<1>> <<2>>", params.i, x), y)
      if (params.i == "Deposit Note") then
        MustSaveToDisk:Two()
      elseif (params.i == params.n) then
        MustSaveToDisk:One()
      end
    else
      msgWithName(zo_strformat("Receipt <<1>>", x), y)
      MustSaveToDisk:One()
    end
  end
  
  
  local delaysend = function(params)
    msgWithName(zo_strformat("Mailing Order Receipt part <<1>> of <<2>> to <<3>>", params.i, params.n, params.handle))
    MailQueue:Enqueue(params.handle, params.subject, params.body, 
                      function() saymailsent(params, true) end, function() saymailsent(params, false) end)
  end
  
  
  local tt = 0
  
  if (globing) then
    local globs = array_glob(itemline, MAX_ITEMS_PER_ORDER_CONFIRM);
    
    for i,ilines in ipairs(globs) do
      local body = table.concat(array_append(line, ilines), "\n")
      local s = subject .. zo_strformat(subj, i, nummails)
      tt = (i * 0.1)
      Timer:Once(tt, delaysend, {i = i, n = nummails, handle = handle, subject = s, body = body})
    end
    
  else
    local body = table.concat(line, "\n")
    msgWithName(zo_strformat("Mailing Order Receipt to <<1>>", handle))
    local qq = {i = false}
    MailQueue:Enqueue(handle, subject, body, function() saymailsent(qq, true) end, function() saymailsent(qq, false) end)
  end
  
  local dpct, dmin = HotepCraft.SetDepositAmt(order)
  local dpt = order.deposit_reqd - order.deposit_taken
  if (dpct and (dpt > 0)) then
    local subject = zo_strformat("Order# <<1>>: Deposit Required", order.ordernumber)
    local body = {}
    table.insert(body, zo_strformat("Your Grand Total is: <<1>>g", order.grandtotal))
    table.insert(body, zo_strformat("Orders above <<1>>g require a <<2>>% Deposit.", dmin, dpct))
    table.insert(body, zo_strformat("<<1>>Please send <<2>>g|r and I will begin working on your order.", COLOR_PURPLE, dpt))
    table.insert(body, "")
    table.insert(body, "Thank You again for your Order.")
    
    body = table.concat(body, "\n")
    
    tt = tt + 0.2
    Timer:Once(tt, delaysend, {i = "Deposit Note", n = 1, handle = handle, subject = subject, body = body})
    
    if (not CurrentClaim.WaitingForDeposit) then
      CurrentClaim.WaitingForDeposit = {}
    end
    
    ---@local WaitRec @class WAITINGCLAIM
    local WaitRec = clone(WAITINGCLAIM)
    WaitRec.orderuuid = order.uuid
    WaitRec.paymentDue = dpt
    WaitRec.customer = handle
    table.insert(CurrentClaim.WaitingForDeposit, WaitRec)
  else
    MustSaveToDisk:Two()
  end
  
  
  if (order.TRADINGMATS) then
    local count = HotepCraft.SetupMatTrades(order, handle)
    
    local tradefoo = function(p)
      HotepCraft.MailTradeOffers(p.order, p.handle, p.count)
    end
    
    if (count > 0) then
--      local i,_ = array_find(order.uuid, OrderDatabase.orders[order.Status], function(ele) return ele.uuid end)
--      OrderDatabase.orders[order.Status][i].MatTrades = order.MatTrades
      Timer:Once(tt, tradefoo, {order = order, handle = handle, count = count})
    else
      MustSaveToDisk:Three()
    end
  else
    MustSaveToDisk:Three()
  end
  
  HotepCraft.SAVEDENTRY = nil
  
  HotepCraft.busy = false
end
-- end HotepCraft.MailOrderReceipt(modified)


---
-- @param order @class ORDER
-- @return @class boolean
function HotepCraft.SetDepositAmt(order)
  if (order.NODEPOSIT) then
    order.deposit_reqd = 0
    return false, false
  elseif ((Settings.dep3_thresh > 0) and (order.grandtotal > Settings.dep3_thresh)) then
    order.deposit_reqd = math.floor(order.grandtotal * (Settings.dep3_amt / 100))
    return Settings.dep3_amt, Settings.dep3_thresh
  elseif ((Settings.dep2_thresh > 0) and (order.grandtotal > Settings.dep2_thresh)) then
    order.deposit_reqd = math.floor(order.grandtotal * (Settings.dep2_amt / 100))
    return Settings.dep2_amt, Settings.dep2_thresh
  elseif ((Settings.dep1_thresh > 0) and (order.grandtotal > Settings.dep1_thresh)) then
    order.deposit_reqd = math.floor(order.grandtotal * (Settings.dep1_amt / 100))
    return Settings.dep1_amt, Settings.dep1_thresh
  else
    order.deposit_reqd = 0
    return false, false
  end
end
-- end HotepCraft.SetDepositAmt(order)


function HotepCraft.RealMatName(itemType, matname)
  if (itemType == ITEMTYPE_BLACKSMITHING_MATERIAL) then
    return matname .. " Ingot"
  elseif (itemType == ITEMTYPE_WOODWORKING_MATERIAL) then
    return "Sanded " .. matname
  else
    return matname
  end
end



---
-- @param order @class ORDER
function HotepCraft.SetupMatTrades(order, handle)
  
--/script d(GetItemLinkItemType(""))
--/script d(GetItemLinkTraitInfo(""))
--/script d(GetItemLinkName(""))
  
  
  ---
  -- @param order @class ORDER
  -- @param mattype @class string
  -- @param matname @class string
  -- @param itemindex @class number
  -- @return @class number
  local tamt = function(order, mattype, matname, itemindex)
    
    ---@local item @class ITEM
    local item = order.items[itemindex]
    local aw = OT.ARM_WEAP(item.itemtype)
    local key = OT.GetPriceTable(item.itemtype)
    local lev = OT.NormalizeLevel(TradePrices.price[key], order.level)
    local prof = OT.PROF(item.itemtype)
    local imp = array_indexof(matname, RESINS[prof])
    local plev = OT.NormalizeLevel(TradePrices.enchant.pot, order.level)
    
    
    if (mattype == "items") then
      return TradePrices.price[key][lev], prof, aw
    elseif ((mattype == "traits") and item.trait) then
      return TradePrices.traitfee[aw][item.trait], prof, aw
    elseif ((mattype == "styles") and (item.style > 0)) then
      return TradePrices.stylefees[item.style], prof, aw
    elseif ((mattype == "improves") and (imp > 0)) then
      return TradePrices.improvefees[prof][imp], prof, aw
    elseif (mattype == "potents") then
      return TradePrices.enchant.pot[plev], prof, aw
    elseif ((mattype == "essances") and (item.enchant > 0)) then
      return TradePrices.enchant.ess[aw][item.enchant], prof, aw
    end
  end
  -- end local function tamt
  
  
  local itypes = {
    items = {
      [PROFESSION_SMITH] = ITEMTYPE_BLACKSMITHING_MATERIAL,
      [PROFESSION_CLOTH] = ITEMTYPE_CLOTHIER_MATERIAL,
      [PROFESSION_WOOD] = ITEMTYPE_WOODWORKING_MATERIAL,
    },
    traits = {
      armor = ITEMTYPE_ARMOR_TRAIT,
      weapon = ITEMTYPE_WEAPON_TRAIT,
    },
    styles = {ITEMTYPE_STYLE_MATERIAL},
    improves = {
      [PROFESSION_SMITH] = ITEMTYPE_BLACKSMITHING_BOOSTER,
      [PROFESSION_CLOTH] = ITEMTYPE_CLOTHIER_BOOSTER,
      [PROFESSION_WOOD] = ITEMTYPE_WOODWORKING_BOOSTER,
    },
    potents = {ITEMTYPE_ENCHANTING_RUNE_POTENCY},
    essances = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE},
  }
  
  local ix = function(mattype, prof, aw)
    if (in_array(mattype, {"items","improves"})) then
      return prof
    elseif (mattype == "traits") then
      return aw
    else
      return 1
    end
  end
  -- end local function ix
  
  
  ---@local mats @class ORDERMATS
  local mats = HotepCraft.GetAllMats(order, nil, true)
  
  order.MatTrades = clone(MatTRADES)
  
  local count = 0
  
  for mattype,t in pairs(mats) do
    for matname,qty in pairs(t) do
      ---@local trade @class MatTradeRec
      local trade = {}
      
      local prof, aw, x
      
      trade.mat = matname
      trade.needed = qty[1]
      trade.got = 0
      trade.discPer, prof, aw = tamt(order, mattype, matname, qty[2])
      
      trade.itemType = itypes[mattype][ix(mattype, prof, aw)]
      
      
      if (mattype == "traits") then
        if (aw == "armor") then
          x = ARM_TRAITS
        else
          x = WEP_TRAITS
        end
        
        local _,trec = array_find(matname, x, function(ele) return ele.jewel end)
        
        trade.itemTrait = trec.Type
      end
      
      
      trade.mat = HotepCraft.RealMatName(trade.itemType, matname)
      
      
      if (trade.discPer) then
        trade.discPer = OT.GDP(PriceList, order, trade.discPer)
        if (trade.discPer > 0) then
          table.insert(order.MatTrades[mattype], trade)
          count = count + 1
        end
      end
    end
  end
  
  if (count > 0) then
    if (not CurrentClaim.WaitingForMats) then
      CurrentClaim.WaitingForMats = {}
    end
    ---@local matwait @class WAITINGTRADES
    local matwait = clone(WAITINGTRADES)
    matwait.customer = handle
    matwait.orderuuid = order.uuid
    
    local i = array_indexof(order.uuid, CurrentClaim.WaitingForMats, function (ele) return ele.orderuuid end)
    
    if (i > 0) then
      table.remove(CurrentClaim.WaitingForMats, i)
    end
    
    table.insert(CurrentClaim.WaitingForMats, matwait)
  end
  
  return count
end
-- end HotepCraft.SetupMatTrades(order, handle)


---
-- @param order @class ORDER
function HotepCraft.MailTradeOffers(order, handle, count)
  
  local globbing = false
  
  if (count > 5) then globbing = true end
  
  local subject = zo_strformat("Order# <<1>>: Materials", order.ordernumber)
  
  local body = [[
You have requested to provide your own mats in exchange for a discount on your order.
Below are the mats I need. Please mail me as many or as few as you wish:
%s
NOTE: You may attach LESS quantity of any item, but if you attach MORE quantity than listed above of any item,
your mail will be automatically regarded as an error and RETURNED TO SENDER.
]]
  
  local line = {}
  
  for mattype,trades in pairs(order.MatTrades) do
    if (type(trades) == "table") then
      ---@local trade @class MatTradeRec
      for _,trade in ipairs(trades) do
        local d = trade.discPer
        local link = LL.GetItemLink(trade.itemType, trade.mat)
        local m = trade.mat
        if (link) then
          m = link
        end
        local s = zo_strformat("<<1>>x <<2>> (-<<3>>g Each)", trade.needed, m, d)
        table.insert(line, s)
      end
    end
  end
  
  
  local saymailsent = function(params, success)
    local x, y
    if (success) then
      x = "sent successfully."
      y = COLOR_GREEN
    else
      x = "failed to send."
      y = COLOR_RED
    end
    
    if (params.i) then
      msgWithName(zo_strformat("Mat List part <<1>> <<2>>", params.i, x), y)
      if (params.i == params.n) then
        MustSaveToDisk:Three()
      end
    else
      msgWithName(zo_strformat("Mat List <<1>>", x), y)
      MustSaveToDisk:Three()
    end
  end
  
  
  local delaysend = function(params)
    if (params.i) then
      msgWithName(zo_strformat("Mailing Mat List part <<1>> of <<2>> to <<3>>", params.i, params.n, params.handle))
    else
      msgWithName(zo_strformat("Mailing Mat List to <<1>>", params.handle))
    end
    
    MailQueue:Enqueue(params.handle, params.subject, params.body, 
                      function() saymailsent(params, true) end, function() saymailsent(params, false) end)
  end
  
  
  if (globbing) then
    local tt = 0
    local subj = " (mail <<1>> of <<2>>)"
    local globs = array_glob(line, 5)
    local n = #globs
    
    for i,glob in ipairs(globs) do
      tt = (i * 0.1)
      local s = subject .. zo_strformat(subj, i, n)
      local list = table.concat(glob, "\n")
      local b = string.format(body, list)
      Timer:Once(tt, delaysend, {i = i, n = n, handle = handle, subject = s, body = b})
    end
  else
    local list = table.concat(line, "\n")
    local b = string.format(body, list)
    Timer:Once(0.1, delaysend, {handle = handle, subject = subject, body = b})
  end
end
-- end HotepCraft.MailTradeOffers(order, handle, count)



function HotepCraft.WaiveDeposit()
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  local orderstatus = HotepCraft.UI_OrdersList.SHOWING_TYPE
  
  if (not uuid or not orderstatus) then return end
  
  if (orderstatus == ORDER_STATUS_DELIVERED) then return end
  
  ---@local order @class ORDER
  local order = HotepCraft.ReturnOrderByUUID(uuid)
  
  if (not order) then return end
  
  if (order.deposit_taken >= order.deposit_reqd) then return end
  
  ---@local WaitRec @class WAITINGCLAIM
  local k, WaitRec = array_find(uuid, CurrentClaim.WaitingForDeposit, function(ele) return ele.orderuuid end)
  
  if (WaitRec.customer == order.customer) then
    order.deposit_reqd = 0
    table.remove(CurrentClaim.WaitingForDeposit, k)
    
    local subject = zo_strformat("Order# <<1>>: Deposit Waived!", order.ordernumber)
    
    local body = [[
As a good customer, I have waived the deposit requirement for your order.

%sYou do NOT owe a deposit.  Please do NOT send one!|r

Thank you for being a valued customer.
]]
    
    body = string.format(body, COLOR_PURPLE)
    
    local cb = function()
      msgWithName("Mail Sent Successfully.", COLOR_GREEN)
    end
    
    local fb = function()
      msgWithName("Mail Faild To Send.", COLOR_RED)
    end
    
    MailQueue:Enqueue(order.customer, subject, body, cb, fb)
    
    HotepCraft.ToggleUIOrderDetail(false)
  end
end
-- end HotepCraft.WaiveDeposit()


function HotepCraft:OnGotOrderingResponse(handle, msg)
  local xxx = zo_strformat("[<<1>> says] <<2>>", handle, msg)
  savedVariables:AppendChatLog({xxx})
  
  if (not self.busy) then
    HotepCraft.SendPriceList(handle, msg)
    return
  elseif (not self.neworder) then
    return
  end
  
  local customer = self.neworder.order.customer
  local params = self.neworder.params
  
  if (handle ~= customer) then
    if ((msg == "order") or (msg == "price") or Settings.busyWhisperAll) then
      local x = "Sorry, I'm busy taking an order right now."
      msgDebug(handle)
      savedVariables:AppendChatLog({x})
      ChatQueue:New(1, "wisp", handle, nil, nil, {x})
    end
    return
  end
  
  local Answer = {
    done = {
      [true] = "tradematprompt",
    },
    back = {
      [true] = "begincheckout",
      [false] = "itemwhatkind",
    },
    checkout = {
      [false] = "begincheckout",
    }
  }
  
  if (not Settings.allowTradeIns) then
    Answer.done[true] = "donecheckout"
  end
  
  
  if (not in_array(params.stage, {"donecheckout","whatlevel","whatrank"})) then
    local parts = explode(" ", msg)
    msg = parts[1]
  end
  
  
  
  params.response = msg
  
  timer_reviewcheckout:Stop()
  
  ChatQueue:Stop()
  
  
  if ((msg == "cancel") or (msg == "AUTOCANCEL")) then
    self.busy = false
    HotepCraft.OrderTimeOut()
    if (msg == "cancel") then
      local msgs = {'Ordering Session Canceled by customer. To start another order, whisper "order".'}
      savedVariables:AppendChatLog(msgs)
      ChatQueue:New(7, "wisp", HotepCraft.neworder.order.customer, nil, nil, msgs)
    end
    return
  end
  
  
  local T = OT.theOT[params.stage]
  
  if ((T and T.Answer and T.Answer[msg]) and (T.Answer[msg][params.checkingout])) then
    params.stage = T.Answer[msg][params.checkingout]
  elseif ((Answer[msg]) and (Answer[msg][params.checkingout])) then
    params.stage = Answer[msg][params.checkingout]
  elseif (T and T.Answer) then
    params.stage = T.Answer[1]
  else
    return
  end
  
  HotepCraft.TakeAnOrder()
end
-- end HotepCraft:OnGotOrderingResponse(handle, msg)


function HotepCraft.improvQty(profession, quality)
  
  local ct = Settings.characters[HotepCraft.mycharacter]
  
  if ((ct == CHAR_TYPE_MULE) or (ct == CHAR_TYPE_OT)) then
    return HotepCraft.improvQty_Mule(profession, quality)
  end
  
  local n,_ = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, SKILL_INDEX[profession], 6)
  local qty = IMPROVES[quality][n+1]
  
  savedVariables.skills.improvQty[profession][quality] = qty
  
  return qty
end


function HotepCraft.improvQty_Mule(profession, quality)
  return savedVariables.skills.improvQty[profession][quality]
end




---
-- @param order @class ORDER
-- @param myclaim @class boolean
-- @param withindexes @class boolean
-- @return @class ORDERMATS
function HotepCraft.GetAllMats(order, myclaim, withindexes)
  
  local plus = function (mattable, matname, n, index)
    if (not n) then
      n = 1
    end
    
    if (not mattable[matname]) then
      if (index) then
        mattable[matname] = {n, index}
      else
        mattable[matname] = n
      end
    else
      if (index) then
        local x = mattable[matname][1] + n
        local y = mattable[matname][2]
        mattable[matname] = {x, y}
      else
        mattable[matname] = mattable[matname] + n
      end
    end
  end
  -- end local plus()
  
  ---
  -- @param xmattable @class table
  -- @param matname @class string
  -- @param item @class ITEM
  -- @return @class nil
  local xplus = function(xmattable, matname, item)
    xmattable[matname] = {
      prof = item.profession,
      aw = OT.ARM_WEAP(item.itemtype),
    }
  end
  
  
  ---
-- @param aw @class string
-- @param item @class ITEM
-- @return @class table
  local traitrec = function (aw, item)
    if (aw == "armor") then
      return ARM_TRAITS[item.trait]
    else
      return WEP_TRAITS[item.trait]
    end
  end
  -- end local traitrec()
  
  
  local potrune = function (level, polarity)
    local lev = 0
    
    if (level == OT.RESEARCH_LEVEL) then
      lev = OT.RESEARCH_LEVEL_EQUIV
      return POTENCY[lev][polarity]
    end
    
    
    for k,_ in spairs(POTENCY) do
      if (k > level) then
        break
      else
        lev = k
      end
    end
    
    return POTENCY[lev][polarity]
  end
  -- end local potrune()
  
  
  
  ---@local mats @class ORDERMATS
  local mats = {
    items = {},      -- key = matname, value = how many
    traits = {},
    styles = {},
    improves = {},
    potents = {},
    essances = {},
  }
  
  
  local xmats = {
    items = {},      -- key = matname, value = {prof, aw}
    traits = {},
    styles = {},
    improves = {},
    potents = {},
    essances = {},
  }
  
  
  local itemindex = nil
  
  ---@local item @class ITEM
  for k,item in ipairs(order.items) do
    ---@local clitem @class CLAIMITEM
    local clitem, _
    
    if (withindexes) then
      itemindex = k
    end
    
    if (myclaim and not item.ISFEE) then
      _,clitem = array_find(k, CurrentClaim.orderitems, function (ele) return ele.itemindex end)
    end
    
    local aw = OT.ARM_WEAP(item.itemtype)
    
    if (not item.ISFEE and (not clitem or not clitem.uniqueid)) then
      local matname = OT.GetMat(item, order.level)
      local _,n = OT.LEVELS(order.level, item.itemtype, item.item)
      plus(mats.items, matname, n, itemindex)
      xplus(xmats.items, matname, item)
      
      if (item.trait) then
        local trait = traitrec(aw, item)
        plus(mats.traits, trait.jewel, 1, itemindex)
        xplus(xmats.traits, trait.jewel, item)
      end
      
      if (item.style > 0) then
        local style = OT.MOTIFS(item.style)
        plus(mats.styles, style.mat, 1, itemindex)
        xplus(xmats.styles, style.mat, item)
      end
    end
    
    if (not item.ISFEE and (item.enchant > 0) and (not clitem or not clitem.enchantDone)) then
      ---@local ess @class ESSENCE
      local ess = OT.ESSENCE(aw, item.enchant)
      plus(mats.essances, ess.rune, 1, itemindex)
      xplus(xmats.essances, ess.rune, item)
      local pr = potrune(order.level, ess.potency)
      plus(mats.potents, pr, 1, itemindex)
      xplus(xmats.potents, pr, item)
    end
    
    if (not item.ISFEE and (item.improvement > 0) and (not clitem or not clitem.improveDone)) then
      for i = 1,item.improvement do
        local matname = RESINS[item.profession][i]
        local n = HotepCraft.improvQty(item.profession, i)
        plus(mats.improves, matname, n, itemindex)
        xplus(xmats.improves, matname, item)
      end
    end
  end
  
  BuildIIfA(xmats, mats)
  return mats
end
-- end HotepCraft.GetAllMats(order, myclaim)


---
-- @param order @class ORDER
-- @return @class table
function HotepCraft.GetAllSetLocs(order)
  
  local setlocs = {}    -- keys are set # (item.set), values are locations (string)
  
  local myclaim = false
  
  if ((CurrentClaim.orderindex > 0) and (CurrentClaim.orderuuid == order.uuid) and (order.Status == ORDER_STATUS_CLAIMED)) then
    myclaim = CurrentClaim.orderitems
  end
  
  ---@local item @class ITEM
  for k,item in ipairs(order.items) do
    if ((item.set > 0) and not array_key_exists(item.set, setlocs)) then
      ---@local setrec @class SETREC
      local setrec = OT.ARM_SETS(item.set)
      local ali = HotepCraft.GetAlliance()
      
      ---@local loc @class SETLOC
      local loc = setrec.loc[ali]
      
      ---@local clitem @class CLAIMITEM
      local clitem, _ = nil, nil
      if (myclaim) then
        _,clitem = array_find(k, myclaim, function (ele) return ele.itemindex end)
      end
      
      if (not clitem or not clitem.uniqueid) then
        if (loc.craft) then
          setlocs[item.set] = zo_strformat("<<1>><<2>> (<<3>>)|r", COLOR_GREEN, loc.craft, loc.zone)
        else
          loc = setrec.loc.special
          if (loc.dlc) then
            setlocs[item.set] = zo_strformat("<<1>><<2>> (<<3>>) [DLC: <<4>>]|r", COLOR_RED, loc.craft, loc.zone, loc.dlc)
          else
            setlocs[item.set] = zo_strformat("<<1>><<2>> (<<3>>)|r", COLOR_MSG, loc.craft, loc.zone)
          end
        end
      end
      
    end
  end
  
  local ret = {}
  
  for _,v in spairs(setlocs) do
    table.insert(ret, v)
  end
  
  return ret
end
-- end HotepCraft.GetAllSetLocs(order)


---
-- @return @class string
function HotepCraft.GetAlliance()
  
  local charid = GetCurrentCharacterId()
  
  local alli = {
    [ALLIANCE_ALDMERI_DOMINION] = "ad",
    [ALLIANCE_DAGGERFALL_COVENANT] = "dc",
    [ALLIANCE_EBONHEART_PACT] = "ep",
  }
  
  for i = 1, GetNumCharacters() do
    local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
    
    if (id == charid) then
      return alli[alliance]
    end
  end
end

---
-- @param index @class boolean
-- @return @class ORDER
function HotepCraft.ReturnClaimedOrder(index)
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  local uuid = CurrentClaim.orderuuid
  local i = array_indexof(uuid, OrderDatabase.orders[ORDER_STATUS_CLAIMED], function (ele) return ele.uuid end)
  
  if (i == 0) then return false end
  
  CurrentClaim.orderindex = i
  
  if (index) then
    return i
  end
  
  return OrderDatabase.orders[ORDER_STATUS_CLAIMED][i]
end

---
-- @param uuid @class string
-- @param index @class boolean
-- @return @class ORDER
function HotepCraft.ReturnOrderByUUID(uuid, index)
  
  if (not in_array(uuid, OrderDatabase.uuids)) then return false end
  
  
  local i
  
  i = array_indexof(uuid, OrderDatabase.orders[ORDER_STATUS_WAITING], function (ele) return ele.uuid end)
  
  if (i > 0) then
    
    if (index) then
      return i, ORDER_STATUS_WAITING
    end
    
    return OrderDatabase.orders[ORDER_STATUS_WAITING][i]
  end
  
  
  i = array_indexof(uuid, OrderDatabase.orders[ORDER_STATUS_CLAIMED], function (ele) return ele.uuid end)
  
  if (i > 0) then
    
    if (index) then
      return i, ORDER_STATUS_CLAIMED
    end
    
    return OrderDatabase.orders[ORDER_STATUS_CLAIMED][i]
  end
  
  
  i = array_indexof(uuid, OrderDatabase.orders[ORDER_STATUS_DELIVERED], function (ele) return ele.uuid end)
  
  if (i > 0) then
    
    if (index) then
      return i, ORDER_STATUS_DELIVERED
    end
    
    return OrderDatabase.orders[ORDER_STATUS_DELIVERED][i]
  end
  
  
  return false
end
-- end HotepCraft.ReturnOrderByUUID(uuid, index)


function HotepCraft.MoveOrder(uuid, oldstatus, newstatus)
  local i = array_indexof(uuid, OrderDatabase.orders[oldstatus], function (ele) return ele.uuid end)
  ---@local order @class ORDER
  local order = table.remove(OrderDatabase.orders[oldstatus], i)
  order.Status = newstatus
  table.insert(OrderDatabase.orders[newstatus], order)
  
  return array_indexof(uuid, OrderDatabase.orders[newstatus], function (ele) return ele.uuid end)
end


function HotepCraft.UpdateClaimCraftingTypes()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  local CTYPES = {
    [PROFESSION_SMITH] = CRAFTING_TYPE_BLACKSMITHING,
    [PROFESSION_CLOTH] = CRAFTING_TYPE_CLOTHIER,
    [PROFESSION_WOOD] = CRAFTING_TYPE_WOODWORKING,
  }
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  CurrentClaim.craftingtypes = {}
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if (not clitem.crafted) then
      ---@local item @class ITEM
      local item = order.items[clitem.itemindex]
      
      if ((not clitem.uniqueid) or (not clitem.improveDone)) then
        if (not in_array(CTYPES[item.profession], CurrentClaim.craftingtypes)) then
          table.insert(CurrentClaim.craftingtypes, CTYPES[item.profession])
        end
      end
      
      if ((not clitem.uniqueid) or (not clitem.enchantDone)) then
        if ((item.enchant > 0) and not in_array(CRAFTING_TYPE_ENCHANTING, CurrentClaim.craftingtypes)) then
          table.insert(CurrentClaim.craftingtypes, CRAFTING_TYPE_ENCHANTING)
        end
      end
    end
  end
end
-- end HotepCraft.UpdateClaimCraftingTypes()


function HotepCraft.UpdateOrderTotals()
  OrderDatabase.total[ORDER_STATUS_WAITING] = #OrderDatabase.orders[ORDER_STATUS_WAITING]
  OrderDatabase.total[ORDER_STATUS_CLAIMED] = #OrderDatabase.orders[ORDER_STATUS_CLAIMED]
  OrderDatabase.total[ORDER_STATUS_DELIVERED] = #OrderDatabase.orders[ORDER_STATUS_DELIVERED]
end


function HotepCraft.ClaimOrder(uuid, oldstatus)
  
  if (CurrentClaim.orderindex > 0) then return false end
  
  local i
  
  if (oldstatus ~= ORDER_STATUS_CLAIMED) then
    i = HotepCraft.MoveOrder(uuid, oldstatus, ORDER_STATUS_CLAIMED)
  else
    i = array_indexof(uuid, OrderDatabase.orders[oldstatus], function (ele) return ele.uuid end)
  end
  
  CurrentClaim.orderindex = i
  CurrentClaim.orderuuid = uuid
  CurrentClaim.numcrafted = 0
  CurrentClaim.finished = false
  CurrentClaim.halfpayment = false
  CurrentClaim.items_delivered = 0
  CurrentClaim.craftingtypes = {}
  CurrentClaim.orderitems = {}
  Settings.DeliveredOrderIndexes = nil
  Settings.DeliveryPOSTAGE = nil
  
  
  ---@local order @class ORDER
  local order = OrderDatabase.orders[ORDER_STATUS_CLAIMED][i]
  
  order.Status = ORDER_STATUS_CLAIMED
  order.claimtime = GetTimeStamp()
  order.asof = GetTimeStamp()
  
  
  ---@local item @class ITEM
  for k,item in ipairs(order.items) do
    if (not item.ISFEE) then
      ---@local clitem @class CLAIMITEM
      local clitem = clone(CLAIMITEM)
      clitem.itemindex = k
      table.insert(CurrentClaim.orderitems, clitem)
    end
  end
  
  HotepCraft.UpdateClaimCraftingTypes()
  
  HotepCraft.UpdateOrderTotals()
  
  return true
end
-- end HotepCraft.ClaimOrder(uuid, oldstatus)


function HotepCraft.ReClaimOrder(notdone, minus)
  ---@local order @class ORDER
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then return false end
  
  order.asof = GetTimeStamp()
  
  local done = false
  
  
  if (not notdone) then
    CurrentClaim.orderitems = {}
    
    minus = 0
    
    for k,item in ipairs(order.items) do
      if (not item.ISFEE) then
        ---@local clitem @class CLAIMITEM
        local clitem = clone(CLAIMITEM)
        clitem.itemindex = k
        table.insert(CurrentClaim.orderitems, clitem)
      else
        minus = minus + 1
      end
    end
  end
  
  
  local count = 0
  local j = 0
  
  local n = GetBagSize(BAG_BACKPACK)
  
  for i = 1,n do
    if (HasItemInSlot(BAG_BACKPACK, i)) then
      
      local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT)
      
      local k = HotepCraft:OnCraftedItemInBag(i, itemLink)
      
      if (k) then
        
        count = count + 1
        
        ---@local clitem @class CLAIMITEM
        local clitem = CurrentClaim.orderitems[k]
        
        ---@local item @class ITEM
        local item = order.items[clitem.itemindex]
        
        if (not clitem.improveDone) then
          local IMPROVES = {
            [ITEM_QUALITY_NORMAL] = 0,
            [ITEM_QUALITY_MAGIC] = 1,
            [ITEM_QUALITY_ARCANE] = 2,
            [ITEM_QUALITY_ARTIFACT] = 3,
            [ITEM_QUALITY_LEGENDARY] = 4,
          }
          
          local qual = IMPROVES[GetItemLinkQuality(itemLink)]
          
          if (item.improvement == qual) then
            clitem.improveDone = true
          end
        end
        
        if (not clitem.enchantDone) then
          local _, enchantHeader, _ = GetItemLinkEnchantInfo(itemLink)
          
          local itype, _ = GetItemType(BAG_BACKPACK, i)
          local enchants
          
          if (itype == ITEMTYPE_ARMOR) then
            enchants = OT.ENCHANTS("armor")
          elseif (itype == ITEMTYPE_WEAPON) then
            local wt = GetItemLinkWeaponType(itemLink)
            
            if (wt == WEAPONTYPE_SHIELD) then
              enchants = OT.ENCHANTS("armor")
            else
              enchants = OT.ENCHANTS("weapon")
            end
          end
          
          if (enchants) then
            local ench, _ = array_find(enchantHeader, enchants, function (ele) return ele.Header end)
            
            if (ench) then
              if (item.enchant == ench) then
                clitem.enchantDone = true
              end
            end
          end
        end
        
        
        if (clitem.improveDone and clitem.enchantDone) then
          clitem.crafted = true
          j = j + 1
          done = HotepCraft.FinishedOneItem(itemLink)
          
          if ((CurrentClaim.orderindex == 0) or CurrentClaim.finished) then
            return done
          end
        elseif (not notdone) then
          clitem.uniqueid = false
        else
          j = j + 1
        end
        
      end
    end
    
    if (j == (#order.items - minus)) then
      return done
    end
  end
  
  if (not notdone) then
    return HotepCraft.ReClaimOrder(true, minus)
  end
  
  return done
end
-- end HotepCraft.ReClaimOrder()


function HotepCraft.UnClaimOrder()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  order.crafter = ""
  order.asof = GetTimeStamp()
  
  HotepCraft.UpdateOrderTotals()
  
  CurrentClaim.orderindex = 0
  CurrentClaim.orderuuid = ""
  CurrentClaim.numcrafted = 0
  CurrentClaim.finished = false
  CurrentClaim.halfpayment = false
  CurrentClaim.items_delivered = 0
  CurrentClaim.craftingtypes = {}
  CurrentClaim.orderitems = {}
  Settings.DeliveredOrderIndexes = nil
  Settings.DeliveryPOSTAGE = nil
  
  return true
end
-- end HotepCraft.UnClaimOrder()


function HotepCraft.DeleteOrder()
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  
  local i, orderstatus = HotepCraft.ReturnOrderByUUID(uuid, true)
  
  if (uuid == CurrentClaim.orderuuid) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You can't delete the order you're working on|r", COLOR_RED))
    return false
  end
  
  table.remove(OrderDatabase.orders[orderstatus], i)
  
  HotepCraft.UpdateOrderTotals()
  
  HotepCraft.ToggleUIOrderDetail(false);
  
  HotepCraft.CleanUpOnAisleD()
  HotepCraft.CleanUpOnAisleM()
end


---
-- @param set @class number
-- @return @class table
function HotepCraft.GetCraftingWayshrines(set)
  ---@local setrec @class SETREC
  local setrec = OT.ARM_SETS(set)
  local ali = HotepCraft.GetAlliance()
  
  ---@local loc @class SETLOC
  local loc = setrec.loc[ali]
  
  if (loc.craft) then
    local list = explode(",", loc.way)
    if (ali ~= "ad") then
      list = array_append(list, explode(",", setrec.loc["ad"].way))
    end
    if (ali ~= "ep") then
      list = array_append(list, explode(",", setrec.loc["ep"].way))
    end
    if (ali ~= "dc") then
      list = array_append(list, explode(",", setrec.loc["dc"].way))
    end
    return list
  else
    loc = setrec.loc.special
    return explode(",", loc.way)
  end
end


function HotepCraft.GetBestCraftingWayshrineNodeIndex(set, prioritize)
  
  local list = HotepCraft.GetCraftingWayshrines(set)
  
  local ftn = GetNumFastTravelNodes()
  
  local listindex = #list + 1000
  local nodeIndex = false
  
  for i = 1,ftn do
    local known, name, _, _, _, _, poiType,_,_ = GetFastTravelNodeInfo(i)
    local isOutboundOnly, _ = GetFastTravelNodeOutboundOnlyInfo(i) 
    
    if ((poiType == POI_TYPE_WAYSHRINE) and in_array(name, list)) then
      if (known and not isOutboundOnly) then
        if (not prioritize) then
          return i
        else
          local k = array_indexof(name, list)
          if (k < listindex) then
            listindex = k
            nodeIndex = i
          end
        end
      end
    end
  end
  
  if (nodeIndex) then return nodeIndex end
  
  return false
end
-- end HotepCraft.GetBestCraftingWayshrineNodeIndex(set, prioritize)


---
-- @return @class number
function HotepCraft.CanJumpToCraftingWayshrine()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if (not clitem.uniqueid) then
      
      ---@local item @class ITEM
      local item = order.items[clitem.itemindex]
      
      if (item.set > 0) then
        if (HotepCraft.GetBestCraftingWayshrineNodeIndex(item.set)) then
          return item.set
        end
      end
    end
  end
  
  return false
end


function HotepCraft.JumpToCraftingWayshrine()
  
  if (Settings.characters[HotepCraft.mycharacter] ~= CHAR_TYPE_CRAFTER) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>This Character is not a Crafter|r", COLOR_RED))
    return
  end
  
  if (not HotepCraft.WayshrineKeybind.active) then return false end
  
  local set = HotepCraft.CanJumpToCraftingWayshrine()
  
  if (not set) then return false end
  
  local nodeIndex = HotepCraft.GetBestCraftingWayshrineNodeIndex(set, true)
  
  FastTravelToNode(nodeIndex)
end






function HotepCraft.compareSetNames(mySetName, zosSetName)
  mySetName = zo_strlower(mySetName)
  zosSetName = zo_strlower(zosSetName)
  if (string.find(zosSetName, mySetName, 1, true)) then   -- haystack, needle
    return true
  else
    return false
  end
end


function HotepCraft.getSetIndex(zosSetName)
  local itemset = 0
  for i = 1,OT.ARM_SETS() do
    ---@local setrec @class SETREC
    local setrec = OT.ARM_SETS(i)
    if (HotepCraft.compareSetNames(setrec.name, zosSetName)) then
      itemset = i
      break
    end
  end
  
  return itemset
end




function HotepCraft:OnCraftingOpen(craftingtype)
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  if (not in_array(craftingtype, CurrentClaim.craftingtypes)) then return false end
  
  local CTYPES = {
    [CRAFTING_TYPE_BLACKSMITHING] = PROFESSION_SMITH,
    [CRAFTING_TYPE_CLOTHIER] = PROFESSION_CLOTH,
    [CRAFTING_TYPE_WOODWORKING] = PROFESSION_WOOD,
    [CRAFTING_TYPE_ENCHANTING] = "enchants",
  }
  
  local pro = CTYPES[craftingtype]
  
  if (not pro) then return false end
  
  if (craftingtype ~= CRAFTING_TYPE_ENCHANTING) then
    EVENT_MANAGER:RegisterForUpdate(self.name, 500, self.CraftingSceneStillOpen)
  end
  
  HotepCraft.InitSmithingWindow(pro)
  
  HotepCraft.ToggleUISmithing(true)
  
  return true
end
-- end HotepCraft:OnCraftingOpen(craftingtype)


function HotepCraft.CraftingSceneStillOpen()
  
  if (CurrentClaim.orderindex == 0) then
    HotepCraft:OnCraftingClose()
    return false
  end
  
  if (SMITHING.mode == SMITHING_MODE_CREATION) then
    local patternIndex, materialIndex, materialQuantity, styleIndex, 
          traitIndex, isUsingUniversalStyle = SMITHING.creationPanel:GetAllCraftingParameters()
    local link = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, LINK_STYLE_DEFAULT)
    
    local hasSet, setName, _, _, _ = GetItemLinkSetInfo(link, false)
    
    local itemset
    if (not hasSet) then
      itemset = 0
    else
      itemset = HotepCraft.getSetIndex(setName)
    end
    
    HotepCraft.UI_ItemsList.STATIONSET = itemset
    HotepCraft.UI_ItemsList:RefreshData()
    HotepCraft.UI_ItemsList:SortScrollList()
    HotepCraft.UI_ItemsList:RefreshVisible()
  end
end
-- end HotepCraft.CraftingSceneStillOpen()


function HotepCraft:OnCraftingClose()
  EVENT_MANAGER:UnregisterForUpdate(self.name)
  if (HotepCraft.UI_ItemsList) then
    HotepCraft.UI_ItemsList.STATIONSET = nil
    HotepCraft.UI_ItemsList.PROFESSION = nil
  end
  HotepCraft.ToggleUISmithing(false)
  HotepCraft.ScanCrafterBackpack()
end


function HotepCraft.MakeLinkCrafted(itemLink)
  local link = { ZO_LinkHandler_ParseLink(itemLink) }
  -- link[1] = ""
  link[2] = "|H0"
  link[20] = 1
  
  table.remove(link, 1)
  
  return table.concat(link, ":") .. "|h|h"
end


function HotepCraft:OnCraftingItem(craftingtype)
  if (SMITHING.mode == SMITHING_MODE_CREATION) then
    local patternIndex, materialIndex, materialQuantity, styleIndex, 
          traitIndex, isUsingUniversalStyle = SMITHING.creationPanel:GetAllCraftingParameters()
    local link = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, LINK_STYLE_DEFAULT)
    
    HotepCraft.LinkJustCrafted = HotepCraft.MakeLinkCrafted(link)
    
  elseif (SMITHING.mode == SMITHING_MODE_IMPROVEMENT) then
    local bagId, slotIndex, _ = SMITHING.improvementPanel:GetCurrentImprovementParams()
    if (bagId ~= BAG_BACKPACK) then return false end
    
    HotepCraft.UniqueIdImproving = HotepCraft.GetItemUniqueId(BAG_BACKPACK, slotIndex)
    
  end
end


function HotepCraft:OnCraftedItemInBag(slotId, itemLink, searching)
  
  local silent = false
  
  if (not itemLink) then
    itemLink = HotepCraft.LinkJustCrafted
  else
    silent = true
  end
  
  local _, aw, itemtype, itemnum, itemtrait, itemstyle, itemset, itemlevel, orderLev
  
  local ARMTYPE = {
    [ARMORTYPE_HEAVY] = "heavy",
    [ARMORTYPE_MEDIUM] = "med",
    [ARMORTYPE_LIGHT] = "light",
  }
  
  local WEPTYPE = {
    [WEAPONTYPE_AXE] = "1h",
    [WEAPONTYPE_HAMMER] = "1h",
    [WEAPONTYPE_SWORD] = "1h",
    [WEAPONTYPE_DAGGER] = "1h",
    [WEAPONTYPE_TWO_HANDED_AXE] = "2h",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "2h",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "2h",
    [WEAPONTYPE_FIRE_STAFF] = "dstaff",
    [WEAPONTYPE_FROST_STAFF] = "dstaff",
    [WEAPONTYPE_LIGHTNING_STAFF] = "dstaff",
    [WEAPONTYPE_HEALING_STAFF] = "rstaff",
    [WEAPONTYPE_BOW] = "bow",
    [WEAPONTYPE_SHIELD] = "shield",
  }
  
  local WEPITEM = {
    [WEAPONTYPE_AXE] = 1,
    [WEAPONTYPE_HAMMER] = 2,
    [WEAPONTYPE_SWORD] = 3,
    [WEAPONTYPE_DAGGER] = 4,
    [WEAPONTYPE_TWO_HANDED_AXE] = 1,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = 2,
    [WEAPONTYPE_TWO_HANDED_SWORD] = 3,
    [WEAPONTYPE_FIRE_STAFF] = 1,
    [WEAPONTYPE_FROST_STAFF] = 2,
    [WEAPONTYPE_LIGHTNING_STAFF] = 3,
    [WEAPONTYPE_HEALING_STAFF] = 1,
    [WEAPONTYPE_BOW] = 1,
    [WEAPONTYPE_SHIELD] = 1,
  }
  
  local ARMITEM = {
    [EQUIP_TYPE_CHEST] = 1,
    [EQUIP_TYPE_FEET] = 2,
    [EQUIP_TYPE_HAND] = 3,
    [EQUIP_TYPE_HEAD] = 4,
    [EQUIP_TYPE_LEGS] = 5,
    [EQUIP_TYPE_SHOULDERS] = 6,
    [EQUIP_TYPE_WAIST] = 7,
  }
  
  
  
  local reqL = GetItemLinkRequiredLevel(itemLink)
  local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
  
  
  if (reqL < 50) then
    itemlevel = reqL
  else
    itemlevel = 50 + math.floor(reqCP / 10)
  end
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then return false end
  
  orderLev, _ = OT.LEVELS(order.level)
  
  
  if ((itemlevel ~= orderLev) and (order.level ~= OT.RESEARCH_LEVEL)) then return false end
  
  
  
  
  
  local awt = ARMTYPE[GetItemLinkArmorType(itemLink)]
  
  if (awt) then
    itemtype = awt
    aw = "armor"
    local _, _, _, equipType, _ = GetItemLinkInfo(itemLink)
    itemnum = ARMITEM[equipType]
    if (not itemnum) then return false end
  else
    local wt = GetItemLinkWeaponType(itemLink)
    awt = WEPTYPE[wt]
    if (awt) then
      aw = "weapon"
      itemtype = awt
      itemnum = WEPITEM[wt]
    else
      return false
    end
  end
  
  
  
  
  local tr = GetItemTrait(BAG_BACKPACK, slotId)
  if ((aw == "armor") or (itemtype == "shield")) then
    itemtrait, _ = array_find(tr, ARM_TRAITS, function (ele) return ele.Type end)
  else
    itemtrait, _ = array_find(tr, WEP_TRAITS, function (ele) return ele.Type end)
  end
  
  if (not itemtrait) then itemtrait = false end
  
  
  
  
  local STYLES = OT.MOTIFS("all")
  local _, _, _, _, itemStyleId = GetItemLinkInfo(itemLink)
  local styleName = zo_strlower(GetItemStyleName(itemStyleId))
  
  itemstyle, _ = array_find(styleName, STYLES, function (ele) return zo_strlower(ele.name) end)
  
  if (not itemstyle) then
    local matlink = GetItemStyleMaterialLink(itemStyleId, LINK_STYLE_DEFAULT)
    local matname = zo_strlower(GetItemLinkName(matlink))
    
    itemstyle, _ = array_find(matname, STYLES, function (ele) return zo_strlower(ele.mat) end)
  end
  
  if (not itemstyle) then itemstyle = 0 end
  
  
  
  
  
  
  local hasSet, setName, _, _, _ = GetItemLinkSetInfo(itemLink, false)
  
  if (not hasSet) then
    itemset = 0
  else
    itemset = HotepCraft.getSetIndex(setName)
  end
  
  
  
  
  local IMPROVES = {
    [ITEM_QUALITY_NORMAL] = 0,
    [ITEM_QUALITY_MAGIC] = 1,
    [ITEM_QUALITY_ARCANE] = 2,
    [ITEM_QUALITY_ARTIFACT] = 3,
    [ITEM_QUALITY_LEGENDARY] = 4,
  }
  
  local qual = IMPROVES[GetItemLinkQuality(itemLink)]
  
  
  
  
  
  
  local _, enchantHeader, _ = GetItemLinkEnchantInfo(itemLink)

  local enchants, ench

  if ((aw == "armor") or (itemtype == "shield")) then
    enchants = OT.ENCHANTS("armor")
  else
    enchants = OT.ENCHANTS("weapon")
  end

  if (enchants) then
    ench, _ = array_find(enchantHeader, enchants, function (ele) return ele.Header end)
  end
  
  if (not ench) then
    ench = 0
  end
  
  
  
  
  
  
--  msgDebug({level = itemlevel, aw = aw, itemtype = itemtype, itemnum = itemnum, 
--        itemtrait = itemtrait, style = itemstyle, setName = setName, itemset = itemset})
--  msgDebug("-----------------------")
  
  ---
  -- @param item @class ITEM
  -- @return @class boolean
  local isTheItem = function (item, z)
    local same = (item.itemtype == itemtype) and 
           ((item.item == itemnum) or ((item.item == 8) and (itemnum == 1))) and
           (item.trait == itemtrait) and (item.set == itemset) and
           ((item.style == 0) or (item.style == itemstyle))
    
    if (z == 0) then
      return same
    elseif (z == 1) then
      return (same and ((item.improvement == qual) or (item.enchant == ench)))
    elseif (z == 2) then
      return (same and ((item.improvement == qual) and (item.enchant == ench)))
    end
  end
  -- end local isTheItem()
  
  
  
  
  
  for z = 2,0,-1 do
    
    ---@local clitem @class CLAIMITEM
    for k,clitem in ipairs(CurrentClaim.orderitems) do
      ---@local item @class ITEM
      local item = order.items[clitem.itemindex]
      
      if (isTheItem(item, z) and not clitem.uniqueid and not searching) then
        clitem.uniqueid = HotepCraft.GetItemUniqueId(BAG_BACKPACK, slotId)
        clitem.improveDone = (item.improvement == qual)
        clitem.enchantDone = (item.enchant == ench)
        
        
        if (Settings.UseFCOis and isFCOalive()) then
          HotepCraft.FCOMarkItem(BAG_BACKPACK, slotId, Settings.UseFCOis, true, true)
        end
        
        if (not silent) then
          msgWithName("You just crafted an item for your order: ".. itemLink)
          
          HotepCraft.Books_CraftedAnItem(order, item, itemLink)
        end
        
        if (not clitem.improveDone and not silent) then
          msgWithName("It still needs to be improved.")
        end
        
        if (not clitem.enchantDone and not silent) then
          msgWithName("It still needs to be enchanted.")
        end
        
        if (clitem.improveDone and clitem.enchantDone and not silent) then
          clitem.crafted = true
          HotepCraft.FinishedOneItem(itemLink)
        else
          HotepCraft.RefreshItemListUI()
        end
        return k
      elseif (isTheItem(item, z) and silent and searching) then
        if (not array_key_exists(HotepCraft.GetItemUniqueId(BAG_BACKPACK, slotId), searching)) then
          return k
        end
      end
    end
    
  end
  
  
  
  return false
end
-- end HotepCraft:OnCraftedItemInBag(slotId, itemLink)

---
-- @param order @class ORDER
-- @param item @class ITEM
-- @param itemLink @class string
-- @return @class nil
function HotepCraft.Books_CraftedAnItem(order, item, itemLink)
  
  if (order.grandtotal == 0) then return end
  
  if (not item.mats) then
    item.mats = clone(MatPROFITS)
  end
  
  local mats = item.mats
  
  local lev, _ = OT.LEVELS(order.level)
  
  if (order.level == OT.RESEARCH_LEVEL) then
    local reqL = GetItemLinkRequiredLevel(itemLink)
    local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
    
    if (reqL < 50) then
      lev = reqL
    else
      lev = 50 + math.floor(reqCP / 10)
    end
  end
  
  
  -- fill mats.items, mats.traits, and mats.styles
  
  if (not mats.items) then mats.items = {} end
  if (not mats.traits) then mats.traits = {} end
  if (not mats.styles) then mats.styles = {} end
  
  
  local matname = OT.GetMat(item, lev)
  local _,n = OT.LEVELS(lev, item.itemtype, item.item)
  
  ---@local p @class PROFITREC
  local p = {}
  p.mat = matname
  p.qty = n
  p.costPer = HotepCraft.Books_FindCost(p, "items")
  p.sellPer = OT.GetUnitPrice(PriceList.price[OT.GetPriceTable(item.itemtype)], lev)
  p.sellPer = OT.GDP(PriceList, order, p.sellPer)
  table.insert(mats.items, p)
  
  
  if (item.trait) then
    local aw = OT.ARM_WEAP(item.itemtype)
    local jewel
    if (aw == "armor") then
      jewel = ARM_TRAITS[item.trait].jewel
    else
      jewel = WEP_TRAITS[item.trait].jewel
    end
    
    ---@local p @class PROFITREC
    local p = {}
    p.mat = jewel
    p.qty = 1
    p.costPer = HotepCraft.Books_FindCost(p, "traits")
    p.sellPer = PriceList.traitfee[aw][item.trait]
    p.sellPer = OT.GDP(PriceList, order, p.sellPer)
    table.insert(mats.traits, p)
  end
  
  
  local style, styleIndex
  if (item.style > 0) then
    style = OT.MOTIFS(item.style)
    styleIndex = item.style
  else
    local _, _, _, _, itemStyleId = GetItemLinkInfo(itemLink)
    local styleName = GetItemStyleName(itemStyleId)
    styleIndex, style = array_find(styleName, OT.MOTIFS("all"), function (ele) return ele.name end)
  end
  
  if (style) then
    ---@local p @class PROFITREC
    local p = {}
    
    p.mat = style.mat
    p.qty = 1
    p.costPer = HotepCraft.Books_FindCost(p, "styles")
    p.sellPer = PriceList.stylefees[styleIndex]
    p.sellPer = OT.GDP(PriceList, order, p.sellPer)
    table.insert(mats.styles, p)
  end
end
-- end HotepCraft.Books_CraftedAnItem(item)


function HotepCraft:OnImprovedItemInBag(slotId)
  
  local IMPROVES = {
    [ITEM_QUALITY_NORMAL] = 0,
    [ITEM_QUALITY_MAGIC] = 1,
    [ITEM_QUALITY_ARCANE] = 2,
    [ITEM_QUALITY_ARTIFACT] = 3,
    [ITEM_QUALITY_LEGENDARY] = 4,
  }
  
  local link = GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_DEFAULT)
  local qual = IMPROVES[GetItemLinkQuality(link)]
  
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  
  if (not order) then return false end
  
  
  local n = #CurrentClaim.orderitems
  local searching = {}
  
  for i = 1,n do
    local k = HotepCraft:OnCraftedItemInBag(slotId, link, searching)
    
    if (not k) then
      break
    end
    
    ---@local clitem @class CLAIMITEM
    
    local clitem = CurrentClaim.orderitems[k]
    local item = order.items[clitem.itemindex]
    
    if ((item.improvement == qual) and not clitem.improveDone) then
      clitem.improveDone = true
      HotepCraft.SwapIDs(k, slotId)
      
      msgWithName("You have completed the improvement of an item for your order: " .. link)
      
      HotepCraft.Books_ImprovedAnItem(order, item, link)
      
      if (clitem.enchantDone) then
        clitem.crafted = true
        HotepCraft.FinishedOneItem(link)
      else
        msgWithName("It must still be enchanted.")
        HotepCraft.RefreshItemListUI()
      end
      return true
    else
      table.insert(searching, clitem.uniqueid)
    end
  end
  
  
  
  
  
  ---@local clitem @class CLAIMITEM
--  for _,clitem in ipairs(CurrentClaim.orderitems) do
--    if (clitem.uniqueid == HotepCraft.UniqueIdImproving) then
--      ---@local item @class ITEM
--      local item = order.items[clitem.itemindex]
--      
--      if (item.improvement == qual) then
--        clitem.improveDone = true
--        
--        msgWithName("You have completed the improvement of an item for your order: " .. link)
--        
--        HotepCraft.Books_ImprovedAnItem(order, item, link)
--        
--        if (clitem.enchantDone) then
--          clitem.crafted = true
--          HotepCraft.FinishedOneItem(link)
--        else
--          msgWithName("It must still be enchanted.")
--          HotepCraft.RefreshItemListUI()
--        end
--      end
--      
--      break
--    end
--  end
  
  
  return false
end
-- end HotepCraft:OnImprovedItemInBag(slotId)



function HotepCraft.SwapIDs(k, slotId)
  
  ---@local c @class CLAIMITEM
  local c = CurrentClaim.orderitems[k]
  
  local thisuid = c.uniqueid
  
  
  local u = HotepCraft.GetItemUniqueId(BAG_BACKPACK, slotId)
  
  if (thisuid == u) then
    return
  end
  
  
  local z
  
  ---@local clitem @class CLAIMITEM
  for x,clitem in ipairs(CurrentClaim.orderitems) do
    if (clitem.uniqueid == u) then
      z = x
      break
    end
  end
  
  
  if (z) then
    CurrentClaim.orderitems[k].uniqueid = u
    CurrentClaim.orderitems[z].uniqueid = thisuid
  end
end
-- end HotepCraft.SwapIDs(k, slotId)





---
-- @param order @class ORDER
-- @param item @class ITEM
-- @param itemLink @class string
-- @return @class nil
function HotepCraft.Books_ImprovedAnItem(order, item, itemLink)
  
  if (order.grandtotal == 0) then return end
  
  ---@local mats @class MatPROFITS
  local mats = item.mats
  
  if (not mats.improves) then mats.improves = {} end
  
  for i = 1,item.improvement do
    local matname = RESINS[item.profession][i]
    local n = HotepCraft.improvQty(item.profession, i)
    
    ---@local p @class PROFITREC
    local p = {}
    p.mat = matname
    p.qty = n
    p.costPer = HotepCraft.Books_FindCost(p, "improves")
    p.sellPer = PriceList.improvefees[item.profession][i]
    p.sellPer = OT.GDP(PriceList, order, p.sellPer)
    table.insert(mats.improves, p)
  end
end
-- end HotepCraft.Books_ImprovedAnItem(order, item, itemLink)







function HotepCraft.OnAboutToEnchant(instanceObject, bag, index)
  -- THIS IS A PREHOOK function, it must return false
  
  local uniq = HotepCraft.GetItemUniqueId(bag, index)
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if ((clitem.uniqueid == uniq) and not clitem.enchantDone) then
      HotepCraft.InitSmithingWindow("enchants", clitem.itemindex)
      HotepCraft.ToggleUISmithing(true)
      EVENT_MANAGER:RegisterForUpdate(HotepCraft.name, 500, HotepCraft.EnchantingStillOpen)
      break
    end
  end
  
  return false
end


function HotepCraft.EnchantingStillOpen()
  
  local foo = function ()
    HotepCraft.ToggleUISmithing(false)
    HotepCraft.UI_ItemsList.PROFESSION = nil
    HotepCraft.ItemBeingEnchanted = nil
  end
  
  if (APPLY_ENCHANT.control:IsHidden()) then
    EVENT_MANAGER:UnregisterForUpdate(HotepCraft.name)
    Timer:Once(0.02, foo)
  end
end


function HotepCraft.OnEnchantingAnItem(instanceObject, itemBagId, itemSlotIndex, enchantmentBagId, enchantmentSlotIndex)
  -- THIS IS A PREHOOK function, it must return false
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  
  HotepCraft.ItemBeingEnchanted = HotepCraft.GetItemUniqueId(itemBagId, itemSlotIndex)
  
  local found = false
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if ((clitem.uniqueid == HotepCraft.ItemBeingEnchanted) and not clitem.enchantDone) then
      HotepCraft.InitSmithingWindow("enchants", clitem.itemindex)
      HotepCraft.ToggleUISmithing(true)
      found = true
      break
    end
  end
  
  if (not found) then return false end
  
  EVENT_MANAGER:RegisterForEvent(HotepCraft.name .. "enchant", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.OnSingleSlotUpdateEnchant)
  
  return false
end
-- end HotepCraft.OnEnchantingAnItem(instanceObject, itemBagId, itemSlotIndex, enchantmentBagId, enchantmentSlotIndex)


function HotepCraft:OnEnchantedItemInBag(bagId, slotId)
  
  local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
  
  local _, enchantHeader, _ = GetItemLinkEnchantInfo(itemLink)
  
  local itype, _ = GetItemType(bagId, slotId)
  local enchants
  
  if (itype == ITEMTYPE_ARMOR) then
    enchants = OT.ENCHANTS("armor")
  elseif (itype == ITEMTYPE_WEAPON) then
    local wt = GetItemLinkWeaponType(itemLink)
    
    if (wt == WEAPONTYPE_SHIELD) then
      enchants = OT.ENCHANTS("armor")
    else
      enchants = OT.ENCHANTS("weapon")
    end
  else
    HotepCraft.ItemBeingEnchanted = nil
    HotepCraft.UI_ItemsList.PROFESSION = nil
    return false
  end
  
  local ench, _ = array_find(enchantHeader, enchants, function (ele) return ele.Header end)
  
  if (not ench) then
    HotepCraft.ItemBeingEnchanted = nil
    HotepCraft.UI_ItemsList.PROFESSION = nil
    return false
  end
  
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then
    HotepCraft.ItemBeingEnchanted = nil
    HotepCraft.UI_ItemsList.PROFESSION = nil
    return false
  end
  
  
  local n = #CurrentClaim.orderitems
  local searching = {}
  
  for i = 1,n do
    local k = HotepCraft:OnCraftedItemInBag(slotId, itemLink, searching)
    
    if (not k) then
      break
    end
    
    ---@local clitem @class CLAIMITEM
    
    local clitem = CurrentClaim.orderitems[k]
    local item = order.items[clitem.itemindex]
    
    if ((item.enchant == ench) and not clitem.enchantDone) then
      clitem.enchantDone = true
      HotepCraft.SwapIDs(k, slotId)
      
      if (Settings.UseFCOis and isFCOalive()) then
        HotepCraft.FCOMarkItem(bagId, slotId, Settings.UseFCOis, true, true)
      end
      
      msgWithName("You have completed enchanting an item for your order: " .. itemLink)
      
      HotepCraft.Books_EnchantedAnItem(order, item, itemLink)
      
      if (clitem.improveDone) then
        clitem.crafted = true
        HotepCraft.FinishedOneItem(itemLink)
      else
        msgWithName("It must still be improved.")
        HotepCraft.RefreshItemListUI()
      end
    else
      table.insert(searching, clitem.uniqueid)
    end
  end
  
  
  
  ---@local clitem @class CLAIMITEM
--  for _,clitem in ipairs(CurrentClaim.orderitems) do
--    if (clitem.uniqueid == HotepCraft.ItemBeingEnchanted) then
--      ---@local item @class ITEM
--      local item = order.items[clitem.itemindex]
--      
--      if (item.enchant == ench) then
--        clitem.enchantDone = true
--        
--        
--        if (Settings.UseFCOis and isFCOalive()) then
--          HotepCraft.FCOMarkItem(bagId, slotId, Settings.UseFCOis, true, true)
--        end
--        
--        
--        msgWithName("You have completed enchanting an item for your order: " .. itemLink)
--        
--        HotepCraft.Books_EnchantedAnItem(order, item, itemLink)
--        
--        if (clitem.improveDone) then
--          clitem.crafted = true
--          HotepCraft.FinishedOneItem(itemLink)
--        else
--          msgWithName("It must still be improved.")
--          HotepCraft.RefreshItemListUI()
--        end
--      end
--      
--      break
--    end
--  end
  
  HotepCraft.ToggleUISmithing(false)
  HotepCraft.UI_ItemsList.PROFESSION = nil
  HotepCraft.ItemBeingEnchanted = nil
end
-- end HotepCraft:OnEnchantedItemInBag(bagId, slotId)



---
-- @param order @class ORDER
-- @param item @class ITEM
-- @param itemLink @class string
-- @return @class nil
function HotepCraft.Books_EnchantedAnItem(order, item, itemLink)
  
  if (order.grandtotal == 0) then return end
  
  ---@local mats @class MatPROFITS
  local mats = item.mats
  
  if (not mats.potents) then mats.potents = {} end
  if (not mats.essances) then mats.essances = {} end
  
  local lev, _ = OT.LEVELS(order.level)
  
  if (order.level == OT.RESEARCH_LEVEL) then
    local reqL = GetItemLinkRequiredLevel(itemLink)
    local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
    
    if (reqL < 50) then
      lev = reqL
    else
      lev = 50 + math.floor(reqCP / 10)
    end
  end
  
  local aw = OT.ARM_WEAP(item.itemtype)
  local ess = OT.ESSENCE(aw, item.enchant)
  
  local nLev = OT.NormalizeLevel(POTENCY, lev)
  
  ---@local p @class PROFITREC
  local p = {}
  p.mat = POTENCY[nLev][ess.potency]
  p.qty = 1
  p.costPer = HotepCraft.Books_FindCost(p, "potents")
  p.sellPer = PriceList.enchant.pot[nLev]
  p.sellPer = OT.GDP(PriceList, order, p.sellPer)
  table.insert(mats.potents, p)
  
  
  ---@local p @class PROFITREC
  local p = {}
  p.mat = ess.rune
  p.qty = 1
  p.costPer = HotepCraft.Books_FindCost(p, "essances")
  p.sellPer = PriceList.enchant.ess[aw][item.enchant]
  p.sellPer = OT.GDP(PriceList, order, p.sellPer)
  table.insert(mats.essances, p)
end
-- end HotepCraft.Books_EnchantedAnItem(order, item, itemLink)






function HotepCraft.RefreshItemListUI()
  HotepCraft.UpdateClaimCraftingTypes()
  
  if (HotepCraft.UI_ItemsList and HotepCraft.UI_ItemsList.PROFESSION) then
    HotepCraft.InitSmithingWindow(HotepCraft.UI_ItemsList.PROFESSION)
    HotepCraft.ToggleUISmithing(true)
  else
    HotepCraft.InitUIOrderDetails()
  end
end



function HotepCraft.FinishedOneItem(itemLink)
  
  msgWithName("You have completed this item for your order: " .. itemLink)
  
  HotepCraft.RefreshItemListUI()
  
  local done = true
  local k = 0
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if (clitem.crafted) then
      k = k + 1
    else
      done = false
    end
  end
  
  CurrentClaim.numcrafted = k
  CurrentClaim.finished = done
  CurrentClaim.halfpayment = false
  CurrentClaim.partialPay1 = 0
  CurrentClaim.partialPay2 = 0
  
  if (done) then
    msgWithName("You have completed your order.  It must now be delivered.")
    
    ---@local order @class ORDER
    local order = HotepCraft.ReturnClaimedOrder()
    
    order.paidInFull = false
    
    if (order.customer == HotepCraft.me) then
      HotepCraft.OrderWasDelivered()
    elseif (k > 6) then
      local due = order.grandtotal - order.deposit_taken
      
      if (due > 0) then
        CurrentClaim.halfpayment = true
        CurrentClaim.partialPay1 = (math.floor(due / k) * 6)
        CurrentClaim.partialPay2 = due - CurrentClaim.partialPay1
      end
    end
  end
  
  return done
end
-- end HotepCraft.FinishedOneItem(itemLink)


function HotepCraft.MyDogAteIt(control)
  local itemindex = control.DATA.itemindex
  
  ---@local clitem @class CLAIMITEM
  local i = select(1, array_find(itemindex, CurrentClaim.orderitems, function (ele) return ele.itemindex end))
  
  if (CurrentClaim.orderitems[i].crafted) then
    CurrentClaim.numcrafted = CurrentClaim.numcrafted - 1
  end
  
  if (CurrentClaim.items_delivered) then
    HotepCraft.DeliveringOrderIndexes = nil
    HotepCraft.DeliveringOrderCount = nil
    
    if (Settings.DeliveredOrderIndexes) then
      CurrentClaim.items_delivered = #Settings.DeliveredOrderIndexes
    else
      CurrentClaim.items_delivered = 0
    end
  end
  
  CurrentClaim.orderitems[i].uniqueid = nil
  CurrentClaim.orderitems[i].crafted = false
  CurrentClaim.orderitems[i].enchantDone = false
  CurrentClaim.orderitems[i].improveDone = false
  CurrentClaim.finished = false
  
  
  HotepCraft.UpdateClaimCraftingTypes()
  HotepCraft.ToggleUIOrderDetail(false)
  HotepCraft.ShowMyOrderUI()
end


function HotepCraft.OfferDeliverOrder()
  
  if (HotepCraft.DeliveringOrderNow) then
    HotepCraft.DeliveringOrderNow = nil
    return false
  end
  
  if (HotepToolsLib.HotepMailReader.processingMail) then return false end
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  if (not CurrentClaim.finished) then return false end
  
  if (not HotepCraft.FindBackpackSlots()) then return false end
  
  HotepCraft.ToggleUISmithing(false)
  HotepCraft.ShowMyOrderUI()
end


---
-- @param indicies @class boolean @optional
-- @param maximum @class number @optional max # of slotIDs to return
-- @param ReturnBoth @class boolean @optional return both slotIDs and itemindexes
-- @return @class table table of itemindexes or slotIDs
-- @return @class table @optional table of itemindexes if ReturnBoth is true
function HotepCraft.FindBackpackSlots(indicies, maximum, ReturnBoth)
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  local uniq = {}
  local indexes = {}
  
  ---@local clitem @class CLAIMITEM
  for _,clitem in ipairs(CurrentClaim.orderitems) do
    if (clitem.uniqueid) then
      table.insert(uniq, clitem)
    else
      table.insert(indexes, clitem.itemindex)
    end
  end
  
  local n = GetBagSize(BAG_BACKPACK)
  
  local slots = {}
  
  local z = #CurrentClaim.orderitems - CurrentClaim.items_delivered
  
  if (maximum and not indicies) then
    z = math.min(z, maximum)
  end
  
  
  for i = 1,n do
    if (HasItemInSlot(BAG_BACKPACK, i)) then
      ---@local clitem @class CLAIMITEM
      for _,clitem in ipairs(uniq) do
        if (HotepCraft.GetItemUniqueId(BAG_BACKPACK, i) == clitem.uniqueid) then
          table.insert(slots, i)
          table.insert(indexes, clitem.itemindex)
          break
        end
      end
    end
    
    if (#slots == z) then
      if (ReturnBoth) then
        return slots, indexes
      elseif (indicies) then
        return indexes
      else
        return slots
      end
    end
  end
  
  if (indicies) then
    return indexes
  else
    return false
  end
end
-- end HotepCraft.FindBackpackSlots(indicies)


function HotepCraft.AnyItemsInBackpack()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  local n = GetBagSize(BAG_BACKPACK)
  
  for i = 1,n do
    if (HasItemInSlot(BAG_BACKPACK, i)) then
      ---@local clitem @class CLAIMITEM
      for _,clitem in ipairs(CurrentClaim.orderitems) do
        if (HotepCraft.GetItemUniqueId(BAG_BACKPACK, i) == clitem.uniqueid) then
          return true
        end
      end
    end
  end
  
  return false
end
-- end HotepCraft.AnyItemsInBackpack()


local ScanningMail = false


function HotepCraft.ShowMailWait(ready)
  if (type(ready) == "nil") then
    HotepCraft_UI_mule:SetHidden(true)
    HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>Scanning your backpack. Please don't log off!|r", COLOR_YELLOW))
    HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Progress: 0%|r", COLOR_YELLOW))
  elseif (ready) then
    HotepCraft_UI_mule:SetHidden(false)
    HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>You may Send the Mail Now!|r", COLOR_GREEN))
    HotepCraft_UI_mule_Progress:SetText("")
  else
    HotepCraft_UI_mule:SetHidden(false)
    HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>Setting up the Mail Message.|r", COLOR_PURPLE))
    HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Please Wait!|r", COLOR_PURPLE))
  end
end


function HotepCraft.DeliverOrder()
  
  HotepCraft.ToggleUIOrderDetail(false)
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  if (not CurrentClaim.finished) then return false end
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then return false end
  
  
  local slots, itemindexes = HotepCraft.FindBackpackSlots(false, 6, true)
  
  if (not slots or (#slots < 1)) then return false end
  
  
  HotepCraft.DeliveringOrderNow = true
  HotepCraft.DeliveringOrderCount = #slots
  HotepCraft.DeliveringOrderIndexes = itemindexes
  
  if (not HotepCraft.DeliveryPOSTAGE) then
    HotepCraft.DeliveryPOSTAGE = 0
    Settings.DeliveryPOSTAGE = 0
  end
  
  
  ScanningMail = "no"
  HotepCraft.ShowMailWait(false)
  
  
  local itemsleft = CurrentClaim.numcrafted - CurrentClaim.items_delivered - #slots
  
  local codpay = math.max(order.grandtotal - order.deposit_taken, 0)
  local subj = ""
  
  if (itemsleft > 0) then
    codpay = CurrentClaim.partialPay1
    subj = " mail 1 of 2"
  elseif (CurrentClaim.numcrafted > #slots) then
    codpay = CurrentClaim.partialPay2
    subj = " mail 2 of 2"
  end
  
  
  zo_callLater(function () HotepCraft.DeliveringOrderNow = nil end, 3000)
  
  
  local subject = zo_strformat("Order Delivery<<1>>: Order# <<2>>", subj, order.ordernumber)
  
  
  SCENE_MANAGER:Show("mailSend")
  MAIL_SEND:SetReply(order.customer, subject)
  
  if (codpay > 0) then
    MAIL_SEND:SetCoDMode()
    zo_callLater(function () MAIL_SEND:AttachMoney(nil, codpay) end, 1000)
  end
  
  
  for k,slot in ipairs(slots) do
    QueueItemAttachment(BAG_BACKPACK, slot, k)
  end
  
  
  
  
  local foo = function ()
    local body = [[
Thank you for your order.

<<1>>
]]
    
    local line2 = zo_strformat("Here are <<1>> of your <<2>> items.\n\nThis completes your transaction.", #slots, CurrentClaim.numcrafted)
    if (itemsleft > 0) then
      line2 = zo_strformat("Here are <<1>> of your <<2>> items.\n\nThe rest will be in the next mailing.", #slots, CurrentClaim.numcrafted)
    end
    
    MAIL_SEND.body:InsertText(zo_strformat(body, line2))
    
    zo_callLater(function() HotepCraft.ShowMailWait(true) end, 600)
  end
  
  zo_callLater(foo, 1500)
  
  
--  HotepCraft.AttemptingToDeliverOrder = true
  
  EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_MAIL_SEND_SUCCESS, HotepCraft.OnSomeMailWasSent)
  
  Timer:Once(5, HotepCraft.NevermindSentMail)
end
-- end HotepCraft.DeliverOrder()


function HotepCraft.NevermindSentMail()
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_MAIL_SEND_SUCCESS)
  HotepCraft.ShowMailWait()
  ScanningMail = false
  HotepCraft.DeliveringOrderIndexes = nil
  HotepCraft.DeliveringOrderCount = nil
  HotepCraft.DeliveryPOSTAGE = nil
--  HotepCraft.AttemptingToDeliverOrder = false
end


function HotepCraft.OnSomeMailWasSent(eventCode)
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_MAIL_SEND_SUCCESS)
  HotepCraft.ShowMailWait()
  
  if (HotepCraft.FindBackpackSlots()) then
    HotepCraft.NevermindSentMail()
    return false
  end
  
  if (HotepCraft.DeliveringOrderCount) then
    local m = #CurrentClaim.orderitems - CurrentClaim.items_delivered - HotepCraft.DeliveringOrderCount
    
    CurrentClaim.items_delivered = CurrentClaim.items_delivered + HotepCraft.DeliveringOrderCount
    
    local uuid = CurrentClaim.orderuuid
    
    if (not Settings.DeliveredOrderIndexes) then
      Settings.DeliveredOrderIndexes = HotepCraft.DeliveringOrderIndexes
    else
      Settings.DeliveredOrderIndexes = array_append(Settings.DeliveredOrderIndexes, HotepCraft.DeliveringOrderIndexes)
    end
    
    Settings.DeliveryPOSTAGE = Settings.DeliveryPOSTAGE + HotepCraft.DeliveryPOSTAGE
    
    HotepCraft.DeliveringOrderIndexes = nil
    
    if (m > 0) then
      Timer:Once(0.05, HotepCraft.DeliverOrder)
      return
    elseif (HotepCraft.CheckDelivered()) then
      HotepCraft.ToggleUISmithing(false)
      HotepCraft.OrderWasDelivered()
      
      if (SCENE_MANAGER.currentScene.name == "mailSend") then
        SCENE_MANAGER:ShowBaseScene()
      end
      
      HotepCraft.UI_OrdersList.SHOWING_TYPE = ORDER_STATUS_DELIVERED
      HotepCraft.UI_OrdersList.SHOWING_UUID = uuid
      
      HotepCraft.InitUIOrderDetails()
      HotepCraft.ToggleUIMain(false)
      HotepCraft.ToggleUIOrderDetail(true)
      ScanningMail = false
      return
    end
  end
  
  HotepCraft.NevermindSentMail()
  
  HotepCraft.ToggleUISmithing(false)
  HotepCraft.ShowMyOrderUI()
end
-- end HotepCraft.OnSomeMailWasSent(eventCode)


function HotepCraft.CheckDelivered()
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then return false end
  
  
  local num = #CurrentClaim.orderitems
  
  if (CurrentClaim.items_delivered ~= num) then return false end
  
  if (HotepCraft.AnyItemsInBackpack()) then return false end
  
  for i,item in ipairs(order.items) do
    if (not in_array(i, Settings.DeliveredOrderIndexes) and not item.ISFEE) then return false end
  end
  
  return true
end


function HotepCraft.ClearClaimDone()
  HotepCraft.DeliveringOrderCount = nil
  HotepCraft.DeliveringOrderIndexes = nil
  HotepCraft.DeliveryPOSTAGE = nil
  Settings.DeliveredOrderIndexes = nil
  Settings.DeliveryPOSTAGE = nil
  
  CurrentClaim.orderindex = 0
  CurrentClaim.orderuuid = ""
  CurrentClaim.numcrafted = 0
  CurrentClaim.finished = false
  CurrentClaim.halfpayment = false
  CurrentClaim.items_delivered = 0
  CurrentClaim.craftingtypes = {}
  CurrentClaim.orderitems = {}
end


function HotepCraft.OrderWasDelivered()
  HotepCraft.ToggleUIOrderDetail(false)
  
  local i = HotepCraft.MoveOrder(CurrentClaim.orderuuid, ORDER_STATUS_CLAIMED, ORDER_STATUS_DELIVERED)
  
  ---@local order @class ORDER
  local order = OrderDatabase.orders[ORDER_STATUS_DELIVERED][i]
  
  order.shiptime = GetTimeStamp()
  order.Status = ORDER_STATUS_DELIVERED
  order.asof = GetTimeStamp()
  
  HotepCraft.UpdateOrderTotals()
  
  
  ---@local WaitRec @class WAITINGCLAIM
  local WaitRec = clone(WAITINGCLAIM)
  
  WaitRec.customer = order.customer
  WaitRec.grandtotal = order.grandtotal - order.deposit_taken
  WaitRec.paymentDue = order.grandtotal - order.deposit_taken
  if (WaitRec.paymentDue < 0) then WaitRec.paymentDue = 0 end
  WaitRec.orderuuid = order.uuid
  WaitRec.paid = (WaitRec.paymentDue == 0)
  
  if (order.customer == HotepCraft.me) then
    WaitRec.paid = true
    order.paidInFull = true
    msgWithName("You have delivered your order to yourself!", COLOR_GREEN)
    HotepCraft.ClearClaimDone()
    return
  else
    msgWithName(zo_strformat("Order #<<1>> has been delivered to <<2>>!", order.ordernumber, order.customer), COLOR_GREEN)
  end
  
  if (order.grandtotal == 0) then
    WaitRec.paid = true
    order.paidInFull = true
    if (order.adjustment == 0) then
      HotepCraft.ClearClaimDone()
      return
    end
  end
  
  -- assert: order was not for me, and was not a FREE GIFT
  
  
  if (Settings.DeliveryPOSTAGE and not order.THISISTESTORDER) then
    Bookkeeping.postage = Bookkeeping.postage + Settings.DeliveryPOSTAGE
    msgWithName(zo_strformat("Order #<<1>> total postage: <<2>>g", order.ordernumber, Settings.DeliveryPOSTAGE), COLOR_BLUE)
  end
  
  
  if (CurrentClaim.halfpayment) then
    WaitRec.halfPayment = CurrentClaim.halfpayment
    WaitRec.partialCharge1 = CurrentClaim.partialPay1
    WaitRec.partialCharge2 = CurrentClaim.partialPay2
  end
  
  if (not CurrentClaim.WaitingForMoney) then
    CurrentClaim.WaitingForMoney = {}
  end
  
  if (WaitRec.paid) then
    order.paidInFull = true
    msgWithName(zo_strformat("Order #<<1>> Paid In Full!", order.ordernumber), COLOR_GREEN)
  else
    table.insert(CurrentClaim.WaitingForMoney, WaitRec)
  end
  
  HotepCraft.ClearClaimDone()
  
  if (order.THISISTESTORDER) then return end
  
  HotepCraft.Books_DeliveredOrder(order)
  
  local ThisWait = GetDiffBetweenTimeStamps(order.claimtime, order.ordertime)
  local ThisCraft = GetDiffBetweenTimeStamps(order.shiptime, order.claimtime)
  local done = OrderDatabase.everdone
  
  OrderDatabase.everdone = OrderDatabase.everdone + 1
  OrderDatabase.waittime = ((OrderDatabase.waittime * done) + ThisWait) / OrderDatabase.everdone
  OrderDatabase.crafttime = ((OrderDatabase.crafttime * done) + ThisCraft) / OrderDatabase.everdone
  
  if (order.adjustment ~= 0) then
    local adj = OrderDatabase.everadjust
    OrderDatabase.everadjust = OrderDatabase.everadjust + 1
    OrderDatabase.adjusted = ((OrderDatabase.adjusted * adj) + order.adjustment) / OrderDatabase.everadjust
  end
end
-- end HotepCraft.OrderWasDelivered()


---
-- @param order @class ORDER
-- @return @class nil
function HotepCraft.Books_DeliveredOrder(order)
  
  Bookkeeping.paidorders = Bookkeeping.paidorders + 1
  Bookkeeping.GrossSales = Bookkeeping.GrossSales + order.grandtotal
  
  if (not order.paidInFull) then
    Bookkeeping.outstandingOrders = Bookkeeping.outstandingOrders + 1
    Bookkeeping.outstandingAmt = Bookkeeping.outstandingAmt + order.grandtotal
  end
  
  local cogs = 0
  
  for _,item in ipairs(order.items) do
    if (not item.ISFEE and (type(item.mats) == "table")) then
      for mattype,profrecs in pairs(item.mats) do
        ---@local p @class PROFITREC
        for _,p in ipairs(profrecs) do
          cogs = cogs + math.ceil(p.qty * p.costPer)
        end
      end
    end
  end
  
  Bookkeeping.cogs = Bookkeeping.cogs + cogs
  HotepCraft.Books_Profits()
end
-- end HotepCraft.Books_DeliveredOrder(order)


function HotepCraft.Books_Profits()
  
  if (Bookkeeping.paidorders == 0) then
    Bookkeeping.ProfitPer = 0
  else
    Bookkeeping.ProfitPer = math.floor(((Bookkeeping.GrossReceipts 
                                            - Bookkeeping.cogs 
                                            - Bookkeeping.postage) / Bookkeeping.paidorders) * 100) / 100    -- round to 2 decimals
  end
  
  Bookkeeping.profit = math.floor(Bookkeeping.GrossReceipts - Bookkeeping.cogs - Bookkeeping.postage - Bookkeeping.motifCosts)
end


function HotepCraft.OnTakeAttachedMoneySuccess(instanceObject, mailId)
  -- THIS IS A PREHOOK function, it must return false
  
  
  local data = MAIL_INBOX:GetMailData(mailId)
  
  if (data.fromSystem or data.fromCS) then return false end
  
  
  local sender = data.senderDisplayName
  local money = data.attachedMoney
  
  
  ---
-- @param WaitRec @class WAITINGCLAIM
-- @param money @class number
-- @return @class boolean
  local moneymatches = function (WaitRec, money)
    if (WaitRec.halfPayment) then
      local h1 = WaitRec.partialCharge1
      local h2 = WaitRec.partialCharge2
      
      if (WaitRec.paymentDue == WaitRec.grandtotal) then
        if (money == h1) then
          WaitRec.paymentDue = h2
          WaitRec.breakflag = true
        elseif (money == h2) then
          WaitRec.paymentDue = h1
          WaitRec.breakflag = true
        else
          return false
        end
      elseif (WaitRec.paymentDue == money) then
        WaitRec.paymentDue = 0
        WaitRec.breakflag = nil
      else
        return false
      end
      
    else
      return (WaitRec.grandtotal == money)
    end
    
    msgWithName(zo_strformat("Received Partial Payment of <<1>>g from customer: <<2>>).", money, WaitRec.customer))
    return true
  end
  -- end local moneymatches()
  
  
  
  ---@local WaitRec @class WAITINGCLAIM
  for k,WaitRec in ipairs(CurrentClaim.WaitingForMoney) do
    if (not WaitRec.paid and (WaitRec.customer == sender) and moneymatches(WaitRec, money)) then
      
      if (WaitRec.breakflag) then
        WaitRec.breakflag = nil
        break
      end
      
      WaitRec.paid = true
      
      local i = array_indexof(WaitRec.orderuuid, OrderDatabase.orders[ORDER_STATUS_DELIVERED], function (ele) return ele.uuid end)
      
      ---@local order @class ORDER
      local order = OrderDatabase.orders[ORDER_STATUS_DELIVERED][i]
      
      order.paidInFull = true
      order.asof = GetTimeStamp()
      
      if (not order.THISISTESTORDER) then
        OrderDatabase.totalsales = OrderDatabase.totalsales + order.grandtotal
        Bookkeeping.GrossReceipts = Bookkeeping.GrossReceipts + order.grandtotal
        Bookkeeping.outstandingOrders = Bookkeeping.outstandingOrders - 1
        Bookkeeping.outstandingAmt = Bookkeeping.outstandingAmt - order.grandtotal
      end
      HotepCraft.Books_Profits()
      
      msgWithName(zo_strformat("Order#<<1>> Paid In Full by Customer: <<2>>.", order.ordernumber, order.customer), COLOR_GREEN)
      
      table.remove(CurrentClaim.WaitingForMoney, k)
      return false
    end
  end
  
  HotepCraft.CleanUpOnAisleD()
  
  ---@local WaitRec @class WAITINGCLAIM
  for k,WaitRec in ipairs(CurrentClaim.WaitingForDeposit) do
    if ((WaitRec.paymentDue > 0) and (WaitRec.customer == sender)) then
      
      local uuid = WaitRec.orderuuid
      ---@local order @class ORDER
      local order = HotepCraft.ReturnOrderByUUID(uuid)
      
      if (not order or (order.Status == ORDER_STATUS_DELIVERED)) then break end
      
      local partial = (money < WaitRec.paymentDue)
      
      WaitRec.paymentDue = WaitRec.paymentDue - money
      order.deposit_taken = order.deposit_taken + money
      
      local xx = ""
      if (partial) then xx = "partial " end
      
      msgWithName(zo_strformat("Order#<<1>>: <<2>>Deposit of <<3>> received from Customer: <<4>>.", 
                          order.ordernumber, xx, money, order.customer), COLOR_GREEN)
      
      if (not partial) then
        table.remove(CurrentClaim.WaitingForDeposit, k)
      end
      
      return false
    end
  end
  
  return false
end
-- end HotepCraft.OnTakeAttachedMoneySuccess(instanceObject, mailId)


function HotepCraft.OnSendingAMail(instanceObject)
  -- THIS IS A PREHOOK function, it must return false
  
  if (HotepCraft.DeliveringOrderCount) then
    HotepCraft.DeliveryPOSTAGE = GetQueuedMailPostage()
    msgWithName(zo_strformat("Postage Recorded: <<1>>g", HotepCraft.DeliveryPOSTAGE), COLOR_GRAY)
  end
  
  return false
end



function HotepCraft.CSRAdjustOrder(button)
  if (button == "ok") then
    local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
    local orderstatus = HotepCraft.UI_OrdersList.SHOWING_TYPE
    
    local i = array_indexof(uuid, OrderDatabase.orders[orderstatus], function (ele) return ele.uuid end)
    
    ---@local order @class ORDER
    local order = OrderDatabase.orders[orderstatus][i]
    
    local adj = tonumber(HotepCraft_UI_order_CSRAjustment:GetText())
    
    if (adj) then adj = math.floor(adj) end
    
    if (not order.originalgrandtotal) then
      order.originalgrandtotal = order.grandtotal
    end
    
    if (adj and ((order.originalgrandtotal + adj) >= 0)) then
      local reason = HotepCraft_UI_order_CSRReason:GetText()
      
      order.grandtotal = order.originalgrandtotal + adj
      order.adjustment = adj
      order.reason = reason
      order.asof = GetTimeStamp()
      
      msgWithName(zo_strformat("Order#<<1>>'s Grand Total has been adjusted.", order.ordernumber))
      HotepCraft.MailOrderReceipt("adjusted", order)
    end
  end
  
  HotepCraft.InitUIOrderDetails()
end
-- end HotepCraft.CSRAdjustOrder(button)


function HotepCraft.OrderWasReturned()
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  ---@local order @class ORDER
  local order = HotepCraft.ReturnOrderByUUID(uuid)
  
  if ((uuid == CurrentClaim.orderuuid) or not order or (order.Status ~= ORDER_STATUS_DELIVERED)) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  
  
  if ((Bookkeeping.outstandingOrders > 0) and (Bookkeeping.outstandingAmt >= order.grandtotal)) then
    Bookkeeping.outstandingOrders = Bookkeeping.outstandingOrders - 1
    Bookkeeping.outstandingAmt = Bookkeeping.outstandingAmt - order.grandtotal
  end
  
  if (Bookkeeping.GrossSales and (Bookkeeping.GrossSales >= order.grandtotal)) then
    Bookkeeping.GrossSales = Bookkeeping.GrossSales - order.grandtotal
  end
  
  if (type(CurrentClaim.WaitingForMoney) == "table") then
    ---@local WaitRec @class WAITINGCLAIM
    local w, WaitRec = array_find(uuid, CurrentClaim.WaitingForMoney, function (ele) return ele.orderuuid end)
    
    if (WaitRec and (WaitRec.paymentDue > 0)) then
      table.remove(CurrentClaim.WaitingForMoney, w)
    end
  end
  
  order.RETURNED = true
  order.claimtime = 0
  order.shiptime = 0
  HotepCraft.MoveOrder(uuid, ORDER_STATUS_DELIVERED, ORDER_STATUS_WAITING)
  
  HotepCraft.ToggleUIOrderDetail(false)
end
-- end HotepCraft.OrderWasReturned()


function HotepCraft.PaidInPerson()
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  ---@local order @class ORDER
  local order = HotepCraft.ReturnOrderByUUID(uuid)
  
  if (uuid == CurrentClaim.orderuuid) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  elseif (not order) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Cannot Find Order|r", COLOR_RED))
    return
  elseif (order.Status ~= ORDER_STATUS_DELIVERED) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Not a Delivered Order|r", COLOR_RED))
    return
  end
  
  
  order.paidInFull = true
  order.asof = GetTimeStamp()
  
  msgWithName(zo_strformat("Order#<<1>> Paid In Full by Customer: <<2>>.", order.ordernumber, order.customer), COLOR_GREEN)
  
  if ((Bookkeeping.outstandingOrders > 0) and (Bookkeeping.outstandingAmt >= order.grandtotal)) then
    OrderDatabase.totalsales = OrderDatabase.totalsales + order.grandtotal
    Bookkeeping.GrossReceipts = Bookkeeping.GrossReceipts + order.grandtotal
    Bookkeeping.outstandingOrders = Bookkeeping.outstandingOrders - 1
    Bookkeeping.outstandingAmt = Bookkeeping.outstandingAmt - order.grandtotal
    HotepCraft.Books_Profits()
  end
  
  
  if (type(CurrentClaim.WaitingForMoney) == "table") then
    ---@local WaitRec @class WAITINGCLAIM
    local w, WaitRec = array_find(uuid, CurrentClaim.WaitingForMoney, function (ele) return ele.orderuuid end)
    
    if (WaitRec and (WaitRec.paymentDue > 0)) then
      table.remove(CurrentClaim.WaitingForMoney, w)
    end
  end
  
  HotepCraft.ToggleUIOrderDetail(false)
end
-- end HotepCraft.PaidInPerson()




-- ****************************************************************************
--                                   UI
-- ****************************************************************************



local UI_OrdersList = ZO_SortFilterList:Subclass()

UI_OrdersList.defaults = {}

UI_OrdersList.SORT_KEYS = {
  ["ordernumber"] = {},
  ["customer"] = {},
  ["items"] = {},
  ["ordertime"] = {},
  ["claimtime"] = {},
  ["shiptime"] = {},
  ["grandtotal"] = {},
  ["adjustment"] = {},
  ["sets"] = {},
}

function UI_OrdersList:New(control)
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  self.masterList = {}
  
  ZO_ScrollList_AddDataType(self.list, 1, "HotepCraft_UI_main_OrdersList_Row", 64, function(control, data) self:SetupOrderRow(control, data) end)
  
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.currentSortKey = "ordernumber" -- default sort
  self.currentSortOrder = ZO_SORT_ORDER_DOWN
  
  self.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
    end
  
--  self:SetAlternateRowBackgrounds(true)
  
  return self
end

---
-- @param rowControl @class table
-- @param data @class UIORDERDATA
-- @return @class nil
function UI_OrdersList:SetupOrderRow(rowControl, data)
  
  local orderstatus = self.SHOWING_TYPE
  local rowcolor = ROWCOLOR_CYAN
  
  if (orderstatus == ORDER_STATUS_WAITING) then
    if (data.RETURNED) then
      rowcolor = ROWCOLOR_PURPLE
    elseif (GetDiffBetweenTimeStamps(GetTimeStamp(), data.ordertimestamp) > (CLAIM_TOO_LONG)) then
      rowcolor = ROWCOLOR_RED
    end
  elseif (orderstatus == ORDER_STATUS_CLAIMED) then
    if (GetDiffBetweenTimeStamps(GetTimeStamp(), data.claimtimestamp) > CLAIM_TOO_LONG) then
      if (data.uuid == CurrentClaim.orderuuid) then
        rowcolor = ROWCOLOR_PURPLE
      else
        rowcolor = ROWCOLOR_RED
      end
    elseif (GetDiffBetweenTimeStamps(GetTimeStamp(), data.claimtimestamp) > (CLAIM_TOO_LONG / 2)) then
      if (data.uuid == CurrentClaim.orderuuid) then
        rowcolor = ROWCOLOR_GREEN
      else
        rowcolor = ROWCOLOR_YELLOW
      end
    elseif (data.uuid == CurrentClaim.orderuuid) then
      rowcolor = ROWCOLOR_GREEN
    end
  elseif (orderstatus == ORDER_STATUS_DELIVERED) then
    if (not data.paidInFull) then
      rowcolor = ROWCOLOR_RED
    elseif (data.adjustment ~= 0) then
      rowcolor = ROWCOLOR_WHITE
    elseif (data.grandtotal == 0) then
      rowcolor = ROWCOLOR_GRAY
    end
  end
  
  
  rowControl.data = data
  rowControl.ordernumber = GetControl(rowControl, "ordernumber")
  rowControl.customer = GetControl(rowControl, "customer")
  rowControl.items = GetControl(rowControl, "items")
  rowControl.ordertime = GetControl(rowControl, "ordertime")
  rowControl.claimtime = GetControl(rowControl, "claimtime")
  rowControl.shiptime = GetControl(rowControl, "shiptime")
  rowControl.grandtotal = GetControl(rowControl, "grandtotal")
  rowControl.adjustment = GetControl(rowControl, "adjustment")
  rowControl.sets = GetControl(rowControl, "sets")
  rowControl.adjustment.data = data
  
  rowControl.ordernumber:SetText(data.ordernumber)
  rowControl.customer:SetText(data.customer)
  rowControl.items:SetText(data.items)
  rowControl.ordertime:SetText(data.ordertime)
  rowControl.claimtime:SetText(data.claimtime)
  rowControl.shiptime:SetText(data.shiptime)
  rowControl.grandtotal:SetText(data.grandtotal)
  rowControl.adjustment:SetText(data.adjustment)
  rowControl.sets:SetText(data.sets)
  
  
  rowControl.ordernumber.normalColor = rowcolor
  rowControl.customer.normalColor = rowcolor
  rowControl.items.normalColor = rowcolor
  rowControl.ordertime.normalColor = rowcolor
  rowControl.claimtime.normalColor = rowcolor
  rowControl.shiptime.normalColor = rowcolor
  rowControl.grandtotal.normalColor = rowcolor
  rowControl.adjustment.normalColor = rowcolor
  rowControl.sets.normalColor = rowcolor
  
  
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_OrdersList:SetupOrderRow(rowControl, data)


function UI_OrdersList:BuildMasterList()
  self.masterList = HotepCraft.GetOrdersList(self.SHOWING_TYPE)
end


function UI_OrdersList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end    
end


function UI_OrdersList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end


---
-- @return @class number
local function CountReturnedOrders()
  local c = 0
  
  ---@local order @class ORDER
  for _,order in pairs(OrderDatabase.orders[ORDER_STATUS_DELIVERED]) do
    if (order.RETURNED) then
      c = c + 1
    end
  end
  
  return c
end



function HotepCraft.MainMenuSwitch(orderstatus)
  local headings = {
    [ORDER_STATUS_WAITING] = "Viewing all Waiting orders",
    [ORDER_STATUS_CLAIMED] = "Viewing all Started orders",
    [ORDER_STATUS_DELIVERED] = "Viewing all Delivered orders",
  }
  
  
  if (orderstatus == "stats") then
    HotepCraft_UI_main_OrdersHeading:SetHidden(true)
    HotepCraft_UI_mainHeaders:SetHidden(true)
    HotepCraft_UI_mainList:SetHidden(true)
    HotepCraft_UI_main_Stats:SetHidden(false)
    
    HotepCraft.Books_Profits()
    
    local wait, _ = FormatTimeSeconds(OrderDatabase.waittime, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT,TIME_FORMAT_PRECISION_SECONDS,TIME_FORMAT_DIRECTION_NONE)
    local craft, _ = FormatTimeSeconds(OrderDatabase.crafttime, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT,TIME_FORMAT_PRECISION_SECONDS,TIME_FORMAT_DIRECTION_NONE)
    
    local stats = [[
%sCurrent Database Totals: Waiting: %s, Started: %s, Delivered: %s|r
Total non-free orders Delivered: %s / %sReturned: %s|r
%sOutstanding Orders: %s / Outstanding Amt: %sg|r
Total Gross Sales: %sg / Cost of Goods Sold: %sg
Total postage paid: %sg / Other Costs: %sg
%sAverage Gross Profit Per Order: %sg|r
%sTotal Gross Profit: %sg / Total Net Profit: %sg|r
Average Time Orders Spent Waiting: %s
Average Time Orders Spent Crafting: %s
Total number of orders with Grand Total Adjustments: %s
Average Grand Total Adjustment: %sg
]]
    
    local outstandingColor = COLOR_RED
    if (Bookkeeping.outstandingOrders == 0) then
      outstandingColor = COLOR_GRAY
    end
    
    local grossProf = math.floor(Bookkeeping.GrossReceipts - Bookkeeping.cogs - Bookkeeping.postage)
    
    local retOrds = CountReturnedOrders()
    local retColor = COLOR_RED
    if (retOrds == 0) then
      retColor = COLOR_GRAY
    end
    
    local ff = function(x)
      return commas(x)
    end
    
    local ff2 = function(x)
      return commas(x)
    end
    
    local vars = {
      COLOR_BLUE,
      OrderDatabase.total[ORDER_STATUS_WAITING],
      OrderDatabase.total[ORDER_STATUS_CLAIMED],
      OrderDatabase.total[ORDER_STATUS_DELIVERED],
      ff(Bookkeeping.paidorders), retColor, ff(retOrds),
      outstandingColor, Bookkeeping.outstandingOrders, ff(Bookkeeping.outstandingAmt),
      ff(Bookkeeping.GrossSales), ff(Bookkeeping.cogs),
      ff(Bookkeeping.postage), ff(Bookkeeping.motifCosts),
      COLOR_YELLOW, ff2(Bookkeeping.ProfitPer), 
      COLOR_YELLOW, ff(grossProf), ff(Bookkeeping.profit),
      wait,
      craft,
      OrderDatabase.everadjust,
      ff2(OrderDatabase.adjusted),
    }
    
    stats = string.format(stats, unpack(vars))
    
    HotepCraft_UI_main_Stats:SetText(stats)
    HotepCraft_UI_main_OrderListHelp:SetHidden(true)
  else
    HotepCraft_UI_main_OrdersHeading:SetHidden(false)
    HotepCraft_UI_mainHeaders:SetHidden(false)
    HotepCraft_UI_mainList:SetHidden(false)
    HotepCraft_UI_main_Stats:SetHidden(true)
    HotepCraft_UI_main_OrderListHelp:SetHidden(false)
    
    HotepCraft_UI_main_OrdersHeading:SetText(headings[orderstatus])
    
    if (orderstatus == ORDER_STATUS_WAITING) then
      local x = [[
This is your list of Orders you have not yet Started.
Orders in |cff0000Red|r have been waiting over %s hours.
Orders in |cff00ffPurple|r have had the merchandise returned.
]]
      HotepCraft_UI_main_OrderListHelp.tooltipText = string.format(x, CLAIM_TOO_LONG_HOURS)
    elseif (orderstatus == ORDER_STATUS_CLAIMED) then
      local x = [[
This is your list of Orders you have Started.
The order you are currently working on will be in |c00ff00Green|r, (or |cff00ffPurple|r if it has been waiting over %s hours).
Orders in |cff0000Red|r have been waiting over %s hours (and are on hold).
Orders in |cffff00Yellow|r have been waiting over %s hours (and are on hold).
]]
      HotepCraft_UI_main_OrderListHelp.tooltipText = string.format(x, CLAIM_TOO_LONG_HOURS, 
                                                                      CLAIM_TOO_LONG_HOURS, math.floor(CLAIM_TOO_LONG_HOURS / 2))
    elseif (orderstatus == ORDER_STATUS_DELIVERED) then
      HotepCraft_UI_main_OrderListHelp.tooltipText = [[
This is your list of Delivered Orders.
Orders in |cff0000Red|r are unpaid.
Orders in |cffffffWhite|r have a manual grand total adjustment.
Orders in |c7f7f7fGray|r are free gifts.
]]
    end
    
    
    if (HotepCraft.UI_OrdersList) then
      HotepCraft.UI_OrdersList.SHOWING_TYPE = orderstatus
      HotepCraft.UI_OrdersList:RefreshData()
    end
  end
  
end
-- end HotepCraft.MainMenuSwitch(orderstatus)


function HotepCraft.GetOrdersList(orderstatus)
  
  local dataItems = {}
  
  if (not orderstatus) then
    return dataItems
  end
  
  ---@local v @class ORDER
  for _,v in pairs(OrderDatabase.orders[orderstatus]) do
    
    local od, ot = FormatAchievementLinkTimestamp(v.ordertime)
    local cd, ct = FormatAchievementLinkTimestamp(v.claimtime)
    local sd, st = FormatAchievementLinkTimestamp(v.shiptime)
    
    ---@local data @classdef UIORDERDATA
    local data = {
      ordernumber = v.ordernumber,
      customer = v.customer,
      items = #v.items,
      ordertime = zo_strformat("<<1>>\n<<2>>", od, ot),
      claimtime = "--",
      shiptime = "--",
      comments = v.comments,
      grandtotal = v.grandtotal,
      adjustment = v.adjustment,
      sets = v.sets,
      uuid = v.uuid,
      ordertimestamp = v.ordertime,
      claimtimestamp = v.claimtime,
      shiptimestamp = v.shiptime,
      paidInFull = v.paidInFull,
      RETURNED = v.RETURNED,
      reason = v.reason,
    }
    
    if (orderstatus == ORDER_STATUS_CLAIMED) then
      data.claimtime = zo_strformat("<<1>>\n<<2>>", cd, ct)
    elseif (orderstatus == ORDER_STATUS_DELIVERED) then
      data.claimtime = zo_strformat("<<1>>\n<<2>>", cd, ct)
      data.shiptime = zo_strformat("<<1>>\n<<2>>", sd, st)
    end
    
    table.insert(dataItems, data)
  end
  
  return dataItems
end
-- end HotepCraft.GetOrdersList(orderstatus)


function HotepCraft.OnOrderSelect(control, button, upInside)
  
  if (Settings.characters[HotepCraft.mycharacter] ~= CHAR_TYPE_CRAFTER) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>This Character is not a Crafter|r", COLOR_RED))
    return
  end
  
  if (HotepCraft.UI_ItemsList and HotepCraft.UI_ItemsList.PROFESSION) then return false end
  
  HotepCraft.UI_OrdersList.SHOWING_UUID = control.data.uuid
  
  HotepCraft.InitUIOrderDetails()
  HotepCraft.ToggleUIMain(false)
  HotepCraft.ToggleUIOrderDetail(true)
end




function HotepCraft.ToggleUIMain(show, OrderStatus)
  
  if (OrderStatus and show) then
    HotepCraft.MainMenuSwitch(OrderStatus)
  elseif (HotepCraft.UI_OrdersList and HotepCraft.UI_OrdersList.SHOWING_TYPE) then
    HotepCraft.MainMenuSwitch(HotepCraft.UI_OrdersList.SHOWING_TYPE)
  else
    HotepCraft.MainMenuSwitch(ORDER_STATUS_WAITING)
  end
  
  
  if (type(show) == "nil") then
    HotepCraft.ToggleUIOrderDetail(false)
    HotepCraft.ToggleUICosts(false)
    SCENE_MANAGER:ToggleTopLevel(HotepCraft_UI_main)
  elseif (show) then
    HotepCraft.ToggleUIOrderDetail(false)
    HotepCraft.ToggleUICosts(false)
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_main)
  else
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_main)
  end
end


function HotepCraft.ToggleUIEnterOrder(show, editing)
  
  if (Settings.characters[HotepCraft.mycharacter] ~= CHAR_TYPE_CRAFTER) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>This Character is not a Crafter|r", COLOR_RED))
    return
  end
  
  if (type(show) == "nil") then
    return
  elseif (show) then
    HotepCraft.ToggleUIMain(false)
    HotepCraft.ToggleUIOrderDetail(false)
    HotepCraft.InitUIEnterOrder(editing)
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_entry)
  else
    if (HotepCraft.UI_ItemsList) then
      HotepCraft.UI_ItemsList.ENTERORDER = nil
    end
    HotepCraft.busy = false
    if (HotepCraft.neworder and HotepCraft.neworder.order and (#HotepCraft.neworder.order.items > 0)) then
      HotepCraft.SAVEDENTRY = clone(HotepCraft.neworder.order)
    end
    HotepCraft.neworder = nil
    if (not HotepCraft_UI_entry:IsHidden()) then
      SCENE_MANAGER:HideTopLevel(HotepCraft_UI_entry)
    end
  end
end








local UI_ItemsList = ZO_SortFilterList:Subclass()

UI_ItemsList.defaults = {}

UI_ItemsList.SORT_KEYS = {
  ["itemindex"] = {}
}

function UI_ItemsList:New(control, smallWindow, neworder)
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  if (not neworder) then
    neworder = false
  end
  
  self.masterList = {}
  
  local template = "HotepCraft_UI_order_ItemsList_Row"
  local height = 32
  
  if (neworder) then
    template = "HotepCraft_UI_entry_ItemsList_Row"
  elseif (smallWindow) then
    template = "HotepCraft_UI_Smithing_ItemsList_Row"
    height = 96
  end
  
  
  ZO_ScrollList_AddDataType(self.list, 1, template, height, function(control, data) self:SetupItemRow(control, data) end)
  
  ZO_ScrollList_SetTypeSelectable(self.list, 1, neworder)
  
  if (neworder) then
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  end
  
  self.currentSortKey = "itemindex" -- default sort
  self.currentSortOrder = ZO_SORT_ORDER_UP
  
  self.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
    end
  
--  self:SetAlternateRowBackgrounds(true)
  
  return self
end


function UI_ItemsList:SetupItemRow(rowControl, data)
  
  rowControl.data = data
  rowControl.itemname = GetControl(rowControl, "itemname")
  rowControl.details = GetControl(rowControl, "details")
  rowControl.itemname.data = data
  
  rowControl.itemname:SetText(data.itemname)
  rowControl.details:SetText(data.details)
  
  if (data.smallWindow) then
    rowControl.itemname.normalColor = ROWCOLOR_YELLOW
  else
    rowControl.itemname.normalColor = ROWCOLOR_CYAN
  end
  
  rowControl.details.normalColor = ROWCOLOR_CYAN
  
  if ((CurrentClaim.orderindex > 0) and not data.neworderWindow) then
    ---@local clitem @class CLAIMITEM
    local clitem = select(2, array_find(data.itemindex, CurrentClaim.orderitems, function (ele) return ele.itemindex end))
    
    if (clitem and clitem.uniqueid) then
      if (clitem.crafted) then
        rowControl.itemname.normalColor = ROWCOLOR_WHITE
      else
        rowControl.itemname.normalColor = ROWCOLOR_GREEN
      end
    elseif (clitem and not clitem.uniqueid and self.PROFESSION and (self.PROFESSION ~= "enchants")) then
      if ((data.itemset > 0) and (self.STATIONSET ~= data.itemset)) then
        rowControl.details.normalColor = ROWCOLOR_RED
      end
    end
  end
  
  
  if (not data.smallWindow and not data.neworderWindow) then
    rowControl.professionSmith = GetControl(rowControl, "professionSmith")
    rowControl.professionCloth = GetControl(rowControl, "professionCloth")
    rowControl.professionWood = GetControl(rowControl, "professionWood")
    rowControl.numtraits = GetControl(rowControl, "numtraits")
    
    rowControl.numtraits:SetText("")
    
    rowControl.professionSmith:SetHidden(true)
    rowControl.professionCloth:SetHidden(true)
    rowControl.professionWood:SetHidden(true)
    
    if (data.profession == PROFESSION_SMITH) then
      rowControl.professionSmith:SetHidden(false)
    elseif (data.profession == PROFESSION_CLOTH) then
      rowControl.professionCloth:SetHidden(false)
    elseif (data.profession == PROFESSION_WOOD) then
      rowControl.professionWood:SetHidden(false)
    end
    
    if (data.numtraits > 0) then
      local x = zo_strformat("<<1>><<2>> Traits|r", COLOR_MSG, data.numtraits)
      rowControl.numtraits:SetText(x)
    end
    
    rowControl.missing = GetControl(rowControl, "missing")
    rowControl.DogAte = GetControl(rowControl, "DogAte")
    
    if (data.missing) then
      rowControl.details:SetHidden(true)
      rowControl.missing:SetHidden(false)
      rowControl.DogAte:SetHidden(false)
      rowControl.DogAte.DATA = data
    elseif (data.delivered) then
      rowControl.details:SetText(zo_strformat("<<1>>DELIVERED|r", COLOR_YELLOW))
      rowControl.details:SetHidden(false)
      rowControl.missing:SetHidden(true)
      rowControl.DogAte:SetHidden(true)
    else
      rowControl.details:SetHidden(false)
      rowControl.missing:SetHidden(true)
      rowControl.DogAte:SetHidden(true)
    end
  end
  
  
  if (data.neworderWindow) then
    rowControl.price = GetControl(rowControl, "price")
    rowControl.price.normalColor = ROWCOLOR_YELLOW
    rowControl.price:SetText(data.price)
  end
  
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_ItemsList:SetupItemRow(rowControl, data)


function UI_ItemsList:BuildMasterList()
  self.masterList = HotepCraft.GetSelectedOrderData(self.PROFESSION, self.ITEMINDEX, self.ENTERORDER)
end


function UI_ItemsList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end    
end


function UI_ItemsList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end





function HotepCraft.GetSelectedOrderData(profession, itemindex, neworder)
  
  if ((CurrentClaim.orderindex == 0) or neworder) then
    profession = nil
  end
  
  
  local dataItems = {}
  
  local uuid
  local orderstatus
  local indicies = {}
  
  if (profession) then
    uuid = CurrentClaim.orderuuid
    orderstatus = ORDER_STATUS_CLAIMED
  elseif (not neworder) then
    uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
    orderstatus = HotepCraft.UI_OrdersList.SHOWING_TYPE
  end
  
  
  local order
  
  if (neworder) then
    order = HotepCraft.neworder.order
  else
    local i = array_indexof(uuid, OrderDatabase.orders[orderstatus], function (ele) return ele.uuid end)
    
    ---@local order @class ORDER
    order = OrderDatabase.orders[orderstatus][i]
  end
  
  
  local CLAIM = ((CurrentClaim.orderindex > 0) and (CurrentClaim.orderuuid == order.uuid))
  
  ---
  -- @param i @class number itemindex
  -- @return @class CLAIMITEM
  local getCLItem = function(i)
    local k = array_indexof(i, CurrentClaim.orderitems, function(clitem) return clitem.itemindex end)
    
    if (k > 0) then
      return CurrentClaim.orderitems[k]
    else
      return false
    end
  end
  
  
  if (profession) then
    ---@local clitem @class CLAIMITEM
    for _,clitem in ipairs(CurrentClaim.orderitems) do
      if (not clitem.crafted) then
        if (profession == "enchants") then
          if ((order.items[clitem.itemindex].enchant > 0) and not clitem.enchantDone) then
            if (not itemindex or (clitem.itemindex == itemindex)) then
              table.insert(indicies, clitem.itemindex)
            end
          end
        elseif ((order.items[clitem.itemindex].profession == profession) and not clitem.improveDone) then
          table.insert(indicies, clitem.itemindex)
        end
      end
    end
  end
  
  
  local indexes = false
  
  if (not profession and not itemindex and not neworder and (CurrentClaim.orderuuid == uuid)) then
    indexes = HotepCraft.FindBackpackSlots(true)
  end
  
  
  ---@local item @class ITEM
  for k,item in ipairs(order.items) do
    if (not profession or (in_array(k, indicies))) then
      local data = {
        itemname = OT.GetName(item, order.level),
        details = OT.GetDescr(item),
        profession = item.profession,
        numtraits = 0,
        itemindex = k,
        itemset = item.set,
        missing = false,
        delivered = false,
        tooltipText = false,
      }
      
      local setrec = OT.ARM_SETS(item.set)
      
      if (setrec) then
        data.numtraits = setrec.traits
      end
      
      if (profession) then
        data.smallWindow = true
      end
      
      if (neworder) then
        data.neworderWindow = true
        data.price = item.price + item.fee
      end
      
      if (not profession and not itemindex and not neworder and indexes and not item.ISFEE) then
        data.missing = (not in_array(k, indexes))
        
        if (Settings.DeliveredOrderIndexes) then
          local isD = in_array(k, Settings.DeliveredOrderIndexes)
          data.missing = data.missing and (not isD)
          data.delivered = isD
        end
      end
      
      if (CLAIM) then
        local clitem = getCLItem(k)
        
        if (not clitem) then
          data.tooltipText = false
        elseif (not clitem.uniqueid) then
          data.tooltipText = "Not yet created"
        elseif (not clitem.improveDone and not clitem.enchantDone) then
          data.tooltipText = "Not yet improved or enchanted"
        elseif (clitem.improveDone and not clitem.enchantDone) then
          data.tooltipText = "Improved but not yet enchanted"
        elseif (not clitem.improveDone and clitem.enchantDone) then
          data.tooltipText = "Enchanted but not yet improved"
        elseif (clitem.crafted) then
          data.tooltipText = "Item Finished!"
        end
      end
      
      
      table.insert(dataItems, data)
    end
    
  end
  
  
  return dataItems
end
-- end HotepCraft.GetSelectedOrderData(profession, itemindex, neworder)






local UI_MuleList = ZO_SortFilterList:Subclass()

UI_MuleList.defaults = {}

UI_MuleList.SORT_KEYS = {
}

function UI_MuleList:New(control)
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  self.masterList = {}
  
  local template = "HotepCraft_UI_mule_List_Row"
  local height = 32
  
  ZO_ScrollList_AddDataType(self.list, 1, template, height, function(control, data) self:SetupItemRow(control, data) end)
  
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
    end
  
--  self:SetAlternateRowBackgrounds(true)
  
  return self
end


---
-- @param rowControl @class userdata
-- @param data @class MULEDATA
-- @return @class nil
function UI_MuleList:SetupItemRow(rowControl, data)
  
  rowControl.data = data
  rowControl.button = GetControl(rowControl, "_Button_Deposit")
  rowControl.mat = GetControl(rowControl, "mat")
  
  rowControl.mat:SetText(data.mat)
  
  if (data.needed == 0) then
    rowControl.button:SetHidden(true)
  else
    rowControl.button:SetHidden(false)
  end
  
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_MuleList:SetupItemRow(rowControl, data)


function UI_MuleList:BuildMasterList()
  self.masterList = HotepCraft.GetMuleListData()
end


function UI_MuleList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end    
end


function UI_MuleList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end




local UI_CostsList = ZO_SortFilterList:Subclass()

local COSTLIST_ITEMROW = 1
local COSTLIST_HEADINGROW = 2

local COSTLIST_matname1 = {caseInsensitive = true}
local COSTLIST_matname2 = {caseInsensitive = true, tiebreaker = "when", tieBreakerSortOrder = ZO_SORT_ORDER_UP}
local COSTLIST_costPer1 = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP}
local COSTLIST_costPer2 = {isNumeric = true}
local COSTLIST_when1 = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP}
local COSTLIST_when2 = {isNumeric = true, tiebreaker = "costPer", tieBreakerSortOrder = ZO_SORT_ORDER_UP}


UI_CostsList.defaults = {}

UI_CostsList.SORT_KEYS = {
  ["mattype"] = {isNumeric = true, tiebreaker = "rowtype", tieBreakerSortOrder = ZO_SORT_ORDER_DOWN},
  ["rowtype"] = {isNumeric = true, tiebreaker = "matname", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["matname"] = {caseInsensitive = true},
  ["qty"] = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["costPer"] = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["total"] = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["when"] = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["qtyUsedint"] = {isNumeric = true, tiebreaker = "mattype", tieBreakerSortOrder = ZO_SORT_ORDER_UP},
}

function UI_CostsList:New(control)
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  self.masterList = {}
  
  local template = "HotepCraft_UI_costs_ListRow"
  local template2 = "HotepCraft_UI_costs_ListHeading"
  local height = 32
  
  local setupItem = function(control, data)
    self:SetupItemRow(control, data)
  end
  
  local setupHeading = function(control, data)
    self:SetupHeadingRow(control, data)
  end
  
  ZO_ScrollList_AddDataType(self.list, COSTLIST_ITEMROW, template, height, setupItem)
  ZO_ScrollList_AddDataType(self.list, COSTLIST_HEADINGROW, template2, height, setupHeading)
  
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.currentSortKey = "mattype"
  self.currentSortOrder = ZO_SORT_ORDER_UP
  
  self.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
    end
  
--  self:SetAlternateRowBackgrounds(true)
  
  return self
end
-- end UI_CostsList:New(control)


---
-- @param rowControl @class userdata
-- @param data @class COSTLISTDATA
-- @return @class nil
function UI_CostsList:SetupItemRow(rowControl, data)
  
  rowControl.data = data
  rowControl.matname = GetControl(rowControl, "matname")
  rowControl.qty = GetControl(rowControl, "qty")
  rowControl.costPer = GetControl(rowControl, "costPer")
  rowControl.total = GetControl(rowControl, "total")
  rowControl.when = GetControl(rowControl, "when")
  rowControl.qtyUsed = GetControl(rowControl, "qtyUsed")
  
  rowControl.matname:SetText(data.matname)
  rowControl.qty:SetText(data.qty)
  rowControl.costPer:SetText(data.costPer)
  rowControl.total:SetText(data.total)
  rowControl.when:SetText(data.formattedWhen)
  rowControl.qtyUsed:SetText(data.qtyUsed)
  
  local color = ROWCOLOR_GREEN
  
  if (data.qtyUsed == "n/a") then
    color = ROWCOLOR_CYAN
  elseif (data.qtyUsed == data.qty) then
    color = ROWCOLOR_GRAY
  elseif (data.qtyUsed > 0) then
    color = ROWCOLOR_PURPLE
  end
  
  rowControl.matname.normalColor = color
  rowControl.qty.normalColor = color
  rowControl.costPer.normalColor = color
  rowControl.total.normalColor = color
  rowControl.when.normalColor = color
  rowControl.qtyUsed.normalColor = color
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_CostsList:SetupItemRow(rowControl, data)


function UI_CostsList:SetupHeadingRow(rowControl, data)
  
  rowControl.data = data
  rowControl.subheading = GetControl(rowControl, "subheading")
  
  rowControl.subheading:SetText(data.subheading)
  rowControl.subheading.normalColor = ROWCOLOR_YELLOW
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_CostsList:SetupHeadingRow(rowControl, data)


function UI_CostsList:BuildMasterList()
  self.masterList = HotepCraft.GetCostListData()
end


function UI_CostsList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  local headings = (self.currentSortKey == "mattype")
  
  if (headings) then
    self.SORT_KEYS.matname = COSTLIST_matname2
    self.SORT_KEYS.costPer = COSTLIST_costPer2
    self.SORT_KEYS.when = COSTLIST_when2
  else
    self.SORT_KEYS.matname = COSTLIST_matname1
    self.SORT_KEYS.costPer = COSTLIST_costPer1
    self.SORT_KEYS.when = COSTLIST_when1
  end
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    if ((data.rowtype ~= COSTLIST_HEADINGROW) or headings) then
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(data.rowtype, data))
    end
  end
end


function UI_CostsList:SortScrollList()
  self:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end









---
-- @param bag @class number  BAG_xxx
-- @param matname @class string
-- @param mattype @class string
-- @return @class number  Amount in bag
-- @return @class number  BagID
-- @return @class number  SlotID
function HotepCraft.FindInBag(bag, matname, mattype)
  
  local MatTypes = {
    items = {ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL},
    traits = {ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_WEAPON_TRAIT},
    styles = {ITEMTYPE_STYLE_MATERIAL},
    improves = {ITEMTYPE_BLACKSMITHING_BOOSTER, ITEMTYPE_CLOTHIER_BOOSTER, ITEMTYPE_WOODWORKING_BOOSTER},
    potents = {ITEMTYPE_ENCHANTING_RUNE_POTENCY},
    essances = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE},
  }
  
--local debugg = {
--  [ITEMTYPE_BLACKSMITHING_MATERIAL] = "ITEMTYPE_BLACKSMITHING_MATERIAL",
--  [ITEMTYPE_CLOTHIER_MATERIAL] = "ITEMTYPE_CLOTHIER_MATERIAL",
--  [ITEMTYPE_WOODWORKING_MATERIAL] = "ITEMTYPE_WOODWORKING_MATERIAL",
--  [ITEMTYPE_ARMOR_TRAIT] = "ITEMTYPE_ARMOR_TRAIT",
--  [ITEMTYPE_WEAPON_TRAIT] = "ITEMTYPE_WEAPON_TRAIT",
--  [ITEMTYPE_STYLE_MATERIAL] = "ITEMTYPE_STYLE_MATERIAL",
--  [ITEMTYPE_BLACKSMITHING_BOOSTER] = "ITEMTYPE_BLACKSMITHING_BOOSTER",
--  [ITEMTYPE_CLOTHIER_BOOSTER] = "ITEMTYPE_CLOTHIER_BOOSTER",
--  [ITEMTYPE_WOODWORKING_BOOSTER] = "ITEMTYPE_WOODWORKING_BOOSTER",
--  [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "ITEMTYPE_ENCHANTING_RUNE_POTENCY",
--  [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
--}
  
  
  local strstr = function (str)
    str = string.gsub(str,"-"," ")
    str = string.gsub(str,"ä","a")
    str = string.gsub(str,"ü","u")
    str = string.gsub(str,"ö","o")
    str = string.gsub(str," ", " ")
    return str
  end
  
  local bagCache
  if (bag == BAG_BACKPACK) then
    bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK, BAG_VIRTUAL)
  else
    bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BANK, BAG_SUBSCRIBER_BANK)
  end
  
  local count = 0
  local TheBag = nil
  local TheSlot = nil
  local SmallestCount = 99999
  
  for slotId, data in pairs(bagCache) do
    local i = data.slotIndex
    local b = data.bagId
    
    if (i) then
      local itemType = data.itemType     -- GetItemType(bag, i)
      if (in_array(itemType, MatTypes[mattype])) then
        local name = zo_strlower(data.name)
        local myName = matname
        
        if (mattype == "items") then
          if (itemType == ITEMTYPE_BLACKSMITHING_MATERIAL) then
            myName = myName .. " ingot"
          elseif (itemType == ITEMTYPE_WOODWORKING_MATERIAL) then
            myName = "sanded " .. myName
          end
        end
        
        myName = zo_strlower(myName)
        
        if (strstr(name) == strstr(myName)) then
          if (bag == BAG_BANK) then
          --  local item = PLAYER_INVENTORY:GetBankItem(i)
            count = count + data.stackCount
            if (not TheSlot or (data.stackCount < SmallestCount)) then
               TheSlot = i
               TheBag = b
               SmallestCount = data.stackCount
            end
          else
            count = GetItemTotalCount(b, i)
            return count, b, i
          end
        end
      end
    end
  end
  
  return count, TheBag, TheSlot
end
-- end HotepCraft.FindInBag(bag, matname, mattype)


HotepCraft.MULEListData = {
  allmats = {},
  dataItems = {},
  mutex = false,
}


function HotepCraft.GetMuleListData()
  return HotepCraft.MULEListData.dataItems
end
-- end HotepCraft.GetMuleListData()


function HotepCraft.CompileMuleListData(index)
  
  
  if (not HotepCraft.BANKISOPEN) then
    HotepCraft.MULEListData.dataItems = {}
    HotepCraft.ToggleUIMule(false)
    return
  end
  
  
  if (not index) then                                 -- before first iteration
    
    if (HotepCraft.MULEListData.mutex) then return end
    
    HotepCraft.MULEListData.mutex = true
    
    ---@local order @class ORDER
    local order = HotepCraft.ReturnClaimedOrder()
    
    if (not order) then
      HotepCraft.MULEListData.dataItems = {}
      HotepCraft.ToggleUIMule(false)
      return
    end
    
    HotepCraft_UI_mule_Scanning:SetHidden(false)
    HotepCraft_UI_mule_container:SetHidden(true)
    
    local mats = HotepCraft.GetAllMats(order, true)
    
    HotepCraft.MULEListData.allmats = {}
    
    for mattype,mattable in pairs(mats) do
      for matname,n in pairs(mattable) do
        table.insert(HotepCraft.MULEListData.allmats, {n = n, matname = matname, mattype = mattype})
      end
    end
    
    HotepCraft.MULEListData.dataItems = {}
    
    
    msgDebug(zo_strformat("CompileMuleListData INITIALIZED: #allmats: <<1>>", #HotepCraft.MULEListData.allmats))
    
    
    Timer:Once(0.001, HotepCraft.CompileMuleListData, 1)
    return
  end
  
  
  msgDebug(zo_strformat("CALLED: CompileMuleListData(<<1>>)", index))
  
  
  if (#HotepCraft.MULEListData.allmats < index) then   -- done iterating
    HotepCraft.MULEListData.allmats = {}
    HotepCraft_UI_mule_Scanning:SetHidden(true)
    if (type(HotepCraft_UI_mule.LISTHIDDEN) == "nil") then
      HotepCraft_UI_mule_container:SetHidden(false)
    else
      HotepCraft_UI_mule.LISTHIDDEN = false
    end
    HotepCraft.InitMuleWindow(true)
    HotepCraft.MULEListData.mutex = false
    return
  end
  
  
  local x = HotepCraft.MULEListData.allmats[index]
  local n = x.n
  local matname = x.matname
  local mattype = x.mattype
  
  
  msgDebug(matname)
  
  
  local crafterAmt = 0
  
  if (savedVariables.skills.crafterHas[mattype]) then
    if (savedVariables.skills.crafterHas[mattype][matname]) then
      crafterAmt = savedVariables.skills.crafterHas[mattype][matname]
    end
  end
  
  
  local inBank, BankBagId, BankSlot = HotepCraft.FindInBag(BAG_BANK, matname, mattype)
  local inBag, BagBagId, BagSlot = HotepCraft.FindInBag(BAG_BACKPACK, matname, mattype)
  
  local needed = n - inBank - crafterAmt
  
  if (needed < 0) then needed = 0 end
  
  local color = COLOR_GREEN
  if (needed > inBag) then
    color = COLOR_RED
  end
  
  local detail
  
  if (needed == 0) then
    detail = "<<1>><<2>>(x<<3>>): <<4>> on Crafter, <<5>> in Bank, Need: <<6>>|r"
    detail = zo_strformat(detail, COLOR_GREEN, matname, n, crafterAmt, inBank, needed)
  else
    detail = "<<1>><<2>>(x<<3>>):|r "
    detail = zo_strformat(detail, COLOR_MSG, matname, n)
    local x = "<<1>><<2>> on Crafter, <<3>> in Bank, Need: <<4>>, <<5>>Have: <<6>>|r"
    detail = zo_strformat(x, detail, crafterAmt, inBank, needed, color, inBag)
  end
  
  
  local data = {
    mat = detail,
    matname = matname,
    needed = needed,
    inBag = inBag,
    inBank = inBank,
    BankSlot = BankSlot,
    BagSlot = BagSlot,
    BankBagId = BankBagId,
    BagBagId = BagBagId,
    crafter = crafterAmt,
  }
  
  table.insert(HotepCraft.MULEListData.dataItems, data)
  
  Timer:Once(0.001, HotepCraft.CompileMuleListData, (index + 1))
end
-- end HotepCraft.CompileMuleListData(index)


local function HasAnyMules()
  for _,ctype in pairs(Settings.characters) do
    if (ctype == CHAR_TYPE_MULE) then
      return true
    end
  end
  
  return false
end


HotepCraft.ScanCrafter_Mutex = false
---@local timer_ScanCrafter_Mutex @class Timer
local timer_ScanCrafter_Mutex


function HotepCraft.ScanCrafterBackpack(index)
  
  if (not index) then                                 -- before first iteration
    
    if (HotepCraft.ScanCrafter_Mutex) then
      timer_ScanCrafter_Mutex:Start()
      return
    else
      HotepCraft.ScanCrafter_Mutex = true
    end
    
    ---@local order @class ORDER
    local order = HotepCraft.ReturnClaimedOrder()
    
    if (not order or not HasAnyMules()) then
      HotepCraft.MULEListData.dataItems = {}
      savedVariables.skills.crafterHas = {}
      HotepCraft_UI_mule:SetHidden(true)
      HotepCraft.ScanCrafter_Mutex = false
      return
    end
    
    HotepCraft_UI_mule:SetHidden(false)
    HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Progress: 0%|r", COLOR_YELLOW))
    
    local mats = HotepCraft.GetAllMats(order, true)
    
    HotepCraft.MULEListData.allmats = {}
    
    for mattype,mattable in pairs(mats) do
      for matname,n in pairs(mattable) do
        table.insert(HotepCraft.MULEListData.allmats, {n = n, matname = matname, mattype = mattype})
      end
    end
    
    HotepCraft.MULEListData.dataItems = {}
    
    Timer:Once(0.001, HotepCraft.ScanCrafterBackpack, 1)
    return
  end
  
  
  if (#HotepCraft.MULEListData.allmats < index) then   -- done iterating
    HotepCraft.MULEListData.allmats = {}
    HotepCraft_UI_mule:SetHidden(true)
    savedVariables.skills.crafterHas = HotepCraft.MULEListData.dataItems
    HotepCraft.MULEListData.dataItems = {}
    HotepCraft.ScanCrafter_Mutex = false
    return
  end
  
  -- we're iterating    (1 <= index <= #HotepCraft.MULEListData.allmats)
  
  
  if (not timer_ScanCrafter_Mutex.stopped) then  -- abort current scan
    HotepCraft.ScanCrafter_Mutex = false
    return
  end
  
  
  local x = HotepCraft.MULEListData.allmats[index]
  local matname = x.matname
  local mattype = x.mattype
  
  local inBag,_,_ = HotepCraft.FindInBag(BAG_BACKPACK, matname, mattype)
  
  local data = HotepCraft.MULEListData.dataItems
  
  if (not array_key_exists(mattype, data)) then
    data[mattype] = {}
  end
  
  data[mattype][matname] = inBag
  
  local p = math.floor((index * 100) / #HotepCraft.MULEListData.allmats)
  HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Progress: <<2>>%|r", COLOR_YELLOW, p))
  
  Timer:Once(0.002, HotepCraft.ScanCrafterBackpack, (index + 1))
end
-- end HotepCraft.ScanCrafterBackpack(index)


timer_ScanCrafter_Mutex = Timer:New(0.05, HotepCraft.ScanCrafterBackpack, nil, true)


function HotepCraft.UIMuleClick(control, button, upInside)
  -- deposit mat from mule's backback to bank
  
  ---@local data @class MULEDATA
  local data = control.data
  
  if (data.needed == 0) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You don't need any of that|r", COLOR_RED))
    return
  end
  
  local amtToDeposit = data.needed
  
  if (data.needed > data.inBag) then
    if (data.inBag == 0) then
      ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You don't have any of that|r", COLOR_RED))
      return
    else
      amtToDeposit = data.inBag
    end
  end
  
  local freeBankSlot = FindFirstEmptySlotInBag(BAG_BANK)
  local freeSubBankSlot = FindFirstEmptySlotInBag(BAG_SUBSCRIBER_BANK)
  
  local existBankStack, existBankMaxStack
  local canUseBankSlot = false
  
  if (data.BankSlot) then
    existBankStack, existBankMaxStack = GetSlotStackSize(data.BankBagId, data.BankSlot)
    canUseBankSlot = ((existBankMaxStack - existBankStack) >= amtToDeposit)
  end
  
  -- RequestMoveItem(number sourceBag, number sourceSlot, number destBag, number destSlot, number stackCount) 
  
  if (canUseBankSlot) then
    HotepCraft.ToggleUIMule(false);
    EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.AfterUIMuleClick)
    CallSecureProtected("RequestMoveItem", data.BagBagId, data.BagSlot, data.BankBagId, data.BankSlot, amtToDeposit)
  elseif (freeBankSlot) then
    HotepCraft.ToggleUIMule(false);
    EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.AfterUIMuleClick)
    CallSecureProtected("RequestMoveItem", data.BagBagId, data.BagSlot, BAG_BANK, freeBankSlot, amtToDeposit)
  elseif (freeSubBankSlot) then
    HotepCraft.ToggleUIMule(false);
    EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.AfterUIMuleClick)
    CallSecureProtected("RequestMoveItem", data.BagBagId, data.BagSlot, BAG_SUBSCRIBER_BANK, freeSubBankSlot, amtToDeposit)
  else
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>BANK FULL|r", COLOR_RED))
    msgWithName("BANK FULL", COLOR_RED)
    return
  end
end
-- end HotepCraft.UIMuleClick(control, button, upInside)


function HotepCraft.AfterUIMuleClick()
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  
  local done = {}
  
  local updated = function(bagId)
    if (not in_array(bagId, done)) then
      table.insert(done, bagId)
    end
    
    if (#done == 4) then
      SHARED_INVENTORY:UnregisterCallback("FullInventoryUpdate", updated)
      HotepCraft.ToggleUIMule(true)
    end
  end
  
  SHARED_INVENTORY:RegisterCallback("FullInventoryUpdate", updated)
  SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_BACKPACK)
  SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_VIRTUAL)
  SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_BANK)
  SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_SUBSCRIBER_BANK)
end





function HotepCraft.ToggleUISmithing(show)
  
  if (HotepCraft.UI_ItemsList and HotepCraft.UI_ItemsList.masterList and empty(HotepCraft.UI_ItemsList.masterList)) then
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_Smithing)
    return
  end
  
  if (type(show) == "nil") then
    SCENE_MANAGER:ToggleTopLevel(HotepCraft_UI_Smithing)
  elseif (show) then
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_Smithing)
  else
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_Smithing)
  end
end


function HotepCraft.ToggleUIMule(show)
  
  HotepCraft.MULEListData.dataItems = {}
  HotepCraft.InitMuleWindow()
  
  if (type(show) == "nil") then
    SCENE_MANAGER:ToggleTopLevel(HotepCraft_UI_mule)
  elseif (show) then
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_mule)
  else
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_mule)
  end
  
  if (HotepCraft_UI_mule:IsHidden()) then
    HotepCraft.MULEListData.mutex = false
    return
  end
  
  HotepCraft.CompileMuleListData()
end


function HotepCraft.ToggleUICosts(show)
  
  if (type(show) == "nil") then
    SCENE_MANAGER:ToggleTopLevel(HotepCraft_UI_costs)
  elseif (show) then
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_costs)
  else
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_costs)
  end
  
  if (HotepCraft_UI_costs:IsHidden()) then return end
  
  HotepCraft.ToggleUIMain(false)
  HotepCraft.ToggleUIOrderDetail(false)
  
  -- (re)init window
  
  HotepCraft.InitBookkeepingWindow()
end


function HotepCraft.InitSmithingWindow(pro, itemindex)
  HotepCraft.UI_ItemsList = UI_ItemsList:New(HotepCraft_UI_Smithing, true)
  HotepCraft.UI_ItemsList.PROFESSION = pro
  HotepCraft.UI_ItemsList.ITEMINDEX = itemindex
  HotepCraft.UI_ItemsList:RefreshData()
  HotepCraft.UI_ItemsList:SortScrollList()
  HotepCraft.UI_ItemsList:RefreshVisible()
end


function HotepCraft.InitMuleWindow(refresh)
  
  if (not HotepCraft.UI_MuleList) then
    HotepCraft.UI_MuleList = UI_MuleList:New(HotepCraft_UI_mule)
  end
  
  if (refresh) then
    HotepCraft.UI_MuleList:RefreshData()
    HotepCraft.UI_MuleList:RefreshVisible()
  end
end


function HotepCraft.InitBookkeepingWindow()
  HotepCraft.UI_CostsList:RefreshData()
  HotepCraft.UI_CostsList:RefreshVisible()
end


function HotepCraft.GetCostListData()
  
  local dataItems = {}
  
  local MatTypes = {
    items = "Base Mats",
    traits = "Trait Mats",
    styles = "Style Mats",
    improves = "Improvement Mats",
    potents = "Potency Runes",
    essances = "Essence Runes",
    motifs = "Motif Books / Chapters",
  }
  
  local MatIndex = {
    items = 1,
    traits = 2,
    styles = 3,
    improves = 4,
    potents = 5,
    essances = 6,
    motifs = 7,
  }
  
  for mattype,costarr in pairs(Bookkeeping.purchases) do
    
    local h = {
      rowtype = COSTLIST_HEADINGROW,
      subheading = MatTypes[mattype],
      mattype = MatIndex[mattype],
      matname = "",
      idx = 0,
      qtyUsedint = 0,
    }
    
    table.insert(dataItems, h)
    
    ---@local costrec @class COSTREC
    for k,costrec in ipairs(costarr) do
      
      local wd, _ = FormatAchievementLinkTimestamp(costrec.when)
      
      ---@local data @classdef COSTLISTDATA
      local data = {
        rowtype = COSTLIST_ITEMROW,
        idx = k,
        mattype = MatIndex[mattype],
        mattypename = mattype,
        matname = costrec.mat,
        qty = costrec.qty,
        qtyUsed = costrec.qtyUsed,
        when = costrec.when,
        costPer = costrec.costPer,
        total = math.ceil(costrec.qty * costrec.costPer),
        formattedWhen = wd,
        qtyUsedint = costrec.qtyUsed or 0
      }
      
      if (mattype == "motifs") then
        data.qtyUsed = "n/a"
        data.qtyUsedint = 0
      end
      
      table.insert(dataItems, data)
    end
  end
  
  return dataItems
end
-- end HotepCraft.GetCostListData()


function HotepCraft.SetUpAddPurchase(show)
  
  HotepCraft_UI_costsHeaders:SetHidden(show)
  HotepCraft_UI_costsList:SetHidden(show)
  HotepCraft_UI_costs_Button_Add:SetHidden(show)
  HotepCraft_UI_costs_AddEditHeading:SetHidden(not show)
  HotepCraft_UI_costs_MatnameLabel:SetHidden(not show)
  HotepCraft_UI_costs_QtyLabel:SetHidden(not show)
  HotepCraft_UI_costs_CostPerLabel:SetHidden(not show)
  HotepCraft_UI_costs_WhenLabel:SetHidden(not show)
  HotepCraft_UI_costs_mattype:SetHidden(not show)
  HotepCraft_UI_costs_matname:SetHidden(not show)
  HotepCraft_UI_costs_qty:SetHidden(not show)
  HotepCraft_UI_costs_costPer:SetHidden(not show)
  HotepCraft_UI_costs_total:SetHidden(not show)
  HotepCraft_UI_costs_when:SetHidden(not show)
  HotepCraft_UI_costs_Button_Save:SetHidden(not show)
  HotepCraft_UI_costs_Button_Cancel:SetHidden(not show)
  
  HotepCraft_UI_costs_DeleteConfirm:SetHidden(true)
  HotepCraft_UI_costs_Button_Delete:SetHidden(true)
  
  HotepCraft_UI_costs_MatnameDropdown:SetHidden(not show)
  HotepCraft_UI_costs_QtySlider:SetHidden(not show)
  HotepCraft_UI_costs_CostSlider1:SetHidden(not show)
  HotepCraft_UI_costs_CostSlider2:SetHidden(not show)
  HotepCraft_UI_costs_CostSlider3:SetHidden(not show)
  HotepCraft_UI_costs_WhenSlider:SetHidden(not show)
  
  if (show) then
    HotepCraft_UI_costs_MatnameDropdown.data.setFunc(HotepCraft_UI_costs_MatnameDropdown.data.getFunc())
    HotepCraft_UI_costs_QtySlider.data.setFunc(HotepCraft_UI_costs_QtySlider.data.getFunc())
    HotepCraft_UI_costs_CostSlider1.data.setFunc(HotepCraft_UI_costs_CostSlider1.data.getFunc())
    HotepCraft_UI_costs_CostSlider2.data.setFunc(HotepCraft_UI_costs_CostSlider2.data.getFunc())
    HotepCraft_UI_costs_CostSlider3.data.setFunc(HotepCraft_UI_costs_CostSlider3.data.getFunc())
    HotepCraft_UI_costs_WhenSlider.data.setFunc(HotepCraft_UI_costs_WhenSlider.data.getFunc())
    
    HotepCraft_UI_costs_QtySlider.data.tooltipText = HotepCraft_UI_costs_QtySlider.data.tooltip()
    
    HotepCraft_UI_costs_MatnameDropdown:UpdateValue()
    HotepCraft_UI_costs_QtySlider:UpdateValue()
    HotepCraft_UI_costs_CostSlider1:UpdateValue()
    HotepCraft_UI_costs_CostSlider2:UpdateValue()
    HotepCraft_UI_costs_CostSlider3:UpdateValue()
    HotepCraft_UI_costs_WhenSlider:UpdateValue()
  end
end
-- end HotepCraft.SetUpAddPurchase(show)


function HotepCraft.Edit_Cost_Entry(rowControl, button, upInside)
  
  if ((button ~= 1) or not upInside) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  
  ---@local HotepCraft.EDITPURCHASE @class COSTLISTDATA
  HotepCraft.EDITPURCHASE = rowControl.data
  
  HotepCraft.AddPurchase(false)
end
-- end HotepCraft.Edit_Cost_Entry(rowControl, button, upInside)


function HotepCraft.AddPurchase(isNew)
  
  if (isNew) then
    HotepCraft_UI_costs_AddEditHeading:SetText("Adding A New Purchase")
    if (not HotepCraft.EDITPURCHASE or not HotepCraft.EDITPURCHASE.ISNEW) then
      HotepCraft.EDITPURCHASE = {
        mattype = 0,
        mattypename = "",
        matname = "",
        qty = 1,
        qtyUsed = 0,
        when = GetTimeStamp(),
        costPer = 0,
        ISNEW = true,
      }
    end
  else
    local msg = zo_strformat("<<1>>Editing Purchase from <<2>>|r", COLOR_YELLOW, HotepCraft.EDITPURCHASE.formattedWhen)
    HotepCraft_UI_costs_AddEditHeading:SetText(msg)
  end
  
  HotepCraft.SetUpAddPurchase(true)
  
  HotepCraft_UI_costs_MatnameDropdown.data.disabled = (not isNew)
  HotepCraft_UI_costs_MatnameDropdown:UpdateDisabled()
end
-- end HotepCraft.AddPurchase(isNew)


function HotepCraft.CancelAddPurchase()
  HotepCraft.SetUpAddPurchase(false)
--  HotepCraft.EDITPURCHASE = nil
end


function HotepCraft.SaveAddPurchase()
  
  if (not HotepCraft.EDITPURCHASE or not HotepCraft.EDITPURCHASE.mattypename 
                    or not HotepCraft.EDITPURCHASE.matname or not HotepCraft.EDITPURCHASE.costPer
                    or not HotepCraft.EDITPURCHASE.qty or not HotepCraft.EDITPURCHASE.when) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  
  if (HotepCraft.EDITPURCHASE.qty == 0) then
    if (HotepCraft.EDITPURCHASE.idx) then
      HotepCraft_UI_costs_Button_Save:SetHidden(true)
      HotepCraft_UI_costs_DeleteConfirm:SetHidden(false)
      HotepCraft_UI_costs_Button_Delete:SetHidden(false)
    else
      PlaySound(SOUNDS.NEGATIVE_CLICK)
    end
    return
  end
  
  ---@local costrec @class COSTREC
  local costrec = {
    mat = HotepCraft.EDITPURCHASE.matname,
    qty = HotepCraft.EDITPURCHASE.qty,
    costPer = HotepCraft.EDITPURCHASE.costPer,
    when = HotepCraft.EDITPURCHASE.when,
    qtyUsed = HotepCraft.EDITPURCHASE.qtyUsed or 0,
  }
  
  if (HotepCraft.EDITPURCHASE.idx) then
    Bookkeeping.purchases[HotepCraft.EDITPURCHASE.mattypename][HotepCraft.EDITPURCHASE.idx] = costrec
  else
    table.insert(Bookkeeping.purchases[HotepCraft.EDITPURCHASE.mattypename], costrec)
    HotepCraft.ReindexBooks(HotepCraft.EDITPURCHASE.mattypename, HotepCraft.EDITPURCHASE.matname)
  end
  
  if (HotepCraft.EDITPURCHASE.mattypename == "motifs") then
    HotepCraft.RecalcOverhead()
  end
  
  HotepCraft.Books_Profits()
  
  HotepCraft.CancelAddPurchase()
  HotepCraft.InitBookkeepingWindow()
end
-- end HotepCraft.SaveAddPurchase()


function HotepCraft.DeletePurchase()
  if (not HotepCraft.EDITPURCHASE or (type(HotepCraft.EDITPURCHASE.idx) ~= "number") 
                or not HotepCraft.EDITPURCHASE.mattypename or not HotepCraft.EDITPURCHASE.matname) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  
  table.remove(Bookkeeping.purchases[HotepCraft.EDITPURCHASE.mattypename], HotepCraft.EDITPURCHASE.idx)
  HotepCraft.ReindexBooks(HotepCraft.EDITPURCHASE.mattypename, HotepCraft.EDITPURCHASE.matname)
  
  if (HotepCraft.EDITPURCHASE.mattypename == "motifs") then
    HotepCraft.RecalcOverhead()
  end
  
  HotepCraft.CancelAddPurchase()
  HotepCraft.InitBookkeepingWindow()
end


function HotepCraft.RecalcOverhead()
  
  Bookkeeping.motifCosts = 0
  
  ---@local costrec @class COSTREC
  for i,costrec in ipairs(Bookkeeping.purchases.motifs) do
    Bookkeeping.motifCosts = Bookkeeping.motifCosts + math.ceil(costrec.qty * costrec.costPer)
  end
end
-- end HotepCraft.RecalcOverhead(idx)


function HotepCraft.ReindexBooks(mattypename, matname)
  
  Bookkeeping.purchaseIndex[matname] = {}
  
  ---@local costrec @class COSTREC
  for i,costrec in ipairs(Bookkeeping.purchases[mattypename]) do
    if (costrec.mat == matname) then
      table.insert(Bookkeeping.purchaseIndex[matname], i)
    end
  end
end
-- end HotepCraft.ReindexBooks(mattypename, matname)


---
-- @param p @class PROFITREC
-- @param mattype @class string
-- @param check @class boolean  - true to NOT deduct qty from puchase history
-- @return @class number   the (average) unit cost of mat or 0 if no purchases of mat
function HotepCraft.Books_FindCost(p, mattype, check)
  
  local need = p.qty
  local used = 0
  local costPer = false
  
  if (not Bookkeeping.purchaseIndex[p.mat]) then return 0 end
  
  
  for _,idx in ipairs(Bookkeeping.purchaseIndex[p.mat]) do
    ---@local costrec @class COSTREC
    local costrec = Bookkeeping.purchases[mattype][idx]
    local has = costrec.qty - costrec.qtyUsed
    
    if (need <= has) then
      if (not costPer) then
        costPer = costrec.costPer
        if (not check) then costrec.qtyUsed = costrec.qtyUsed + need end
        used = p.qty
        need = 0
      else
        costPer = math.ceil(((costPer * used) + (costrec.costPer * need)) / p.qty)
        if (not check) then costrec.qtyUsed = costrec.qtyUsed + need end
        used = p.qty
        need = 0
      end
    elseif (has > 0) then    -- assert: need > has
      if (not costPer) then
        costPer = costrec.costPer
        if (not check) then costrec.qtyUsed = costrec.qty end
        used = used + has
        need = need - has
      else
        costPer = math.ceil(((costPer * used) + (costrec.costPer * has)) / (used + has))
        if (not check) then costrec.qtyUsed = costrec.qty end
        used = used + has
        need = need - has
      end
    end
    
    msgDebug(zo_strformat("idx: <<1>>: costPer: <<2>>g", idx, costPer))
    
    if (need == 0) then
      return costPer
    end
  end -- for ipairs(Bookkeeping.purchaseIndex[p.mat])
  
  if (costPer) then
    -- assert: 0 < need < p.qty  &  used + need = p.qty
    
    -- consider the remaining (need) qty to be FREE mats
    
    return math.ceil(((costPer * used) + (0 * need)) / p.qty)
  end
  
  return 0
end
-- end HotepCraft.Books_FindCost(mat, mattype)







function HotepCraft.ToggleUIOrderDetail(show)
  
  if (HotepCraft.UI_ItemsList and HotepCraft.UI_ItemsList.ENTERORDER) then return end
  
  if (type(show) == "nil") then
    HotepCraft.ToggleUICosts(false)
    SCENE_MANAGER:ToggleTopLevel(HotepCraft_UI_order)
  elseif (show) then
    HotepCraft.ToggleUICosts(false)
    SCENE_MANAGER:ShowTopLevel(HotepCraft_UI_order)
  else
    SCENE_MANAGER:HideTopLevel(HotepCraft_UI_order)
  end
end


function HotepCraft.UIClaimButton(action)
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  local oldstatus = HotepCraft.UI_OrdersList.SHOWING_TYPE
  
  if (action == "claim") then
    HotepCraft.ClaimOrder(uuid, oldstatus)
    HotepCraft.UI_OrdersList.SHOWING_TYPE = ORDER_STATUS_CLAIMED
    if (HotepCraft.ReClaimOrder()) then
      HotepCraft.ToggleUIOrderDetail(false)
    else
      HotepCraft.InitUIOrderDetails()
    end
    HotepCraft.ScanCrafterBackpack()
  elseif (action == "unclaim") then
    HotepCraft.UnClaimOrder()
    HotepCraft.UI_OrdersList.SHOWING_TYPE = ORDER_STATUS_CLAIMED
    HotepCraft.InitUIOrderDetails()
  end
end


function HotepCraft.ShowMyOrderUI()
  
  if (Settings.characters[HotepCraft.mycharacter] ~= CHAR_TYPE_CRAFTER) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>This Character is not a Crafter|r", COLOR_RED))
    return
  end
  
  if (CurrentClaim.orderindex == 0) then
    HotepCraft.ToggleUIOrderDetail(false)
    return false
  end
  
  if (HotepCraft.UI_ItemsList and (HotepCraft.UI_ItemsList.PROFESSION or HotepCraft.UI_ItemsList.ENTERORDER)) then return false end
  
  HotepCraft.ToggleUIMain(false)
  
  HotepCraft.UI_OrdersList.SHOWING_UUID = CurrentClaim.orderuuid
  HotepCraft.UI_OrdersList.SHOWING_TYPE = ORDER_STATUS_CLAIMED
  
  if (not HotepCraft_UI_order:IsHidden()) then
    HotepCraft.ToggleUIOrderDetail(false)
    return
  end
  
  HotepCraft.InitUIOrderDetails()
  HotepCraft.ToggleUIOrderDetail(true)
end


function HotepCraft.UICSRAdjustButton()
  
  ---@local order @class ORDER 
  local order = HotepCraft.ReturnClaimedOrder()
  
  if (not order) then return end
  
  if (order.customer == HotepCraft.me) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return false
  end
  
  
  HotepCraft_UI_order_Mats1:SetHidden(true)
  HotepCraft_UI_order_Mats2:SetHidden(true)
  HotepCraft_UI_order_Mats2a:SetHidden(true)
  HotepCraft_UI_order_Mats3:SetHidden(true)
  HotepCraft_UI_order_Mats4:SetHidden(true)
  HotepCraft_UI_order_Locations:SetHidden(true)
  HotepCraft_UI_order_MatsHeading:SetHidden(true)
  HotepCraft_UI_order_Button_IDelivered:SetHidden(true)
  
  HotepCraft_UI_order_CSRPrompt1:SetHidden(false)
  HotepCraft_UI_order_CSRPrompt2:SetHidden(false)
  HotepCraft_UI_order_CSRAjustmentContainer:SetHidden(false)
  HotepCraft_UI_order_CSRReasonContainer:SetHidden(false)
  HotepCraft_UI_order_Button_CSR_OK:SetHidden(false)
  HotepCraft_UI_order_Button_CSR_Cancel:SetHidden(false)
end
-- endHotepCraft.UICSRAdjustButton()


function HotepCraft.InitUIOrderDetails()
  
  local uuid = HotepCraft.UI_OrdersList.SHOWING_UUID
  local orderstatus = HotepCraft.UI_OrdersList.SHOWING_TYPE
  
  if (not uuid or not orderstatus) then return end
  
  local i = array_indexof(uuid, OrderDatabase.orders[orderstatus], function (ele) return ele.uuid end)
  
  ---@local order @class ORDER
  local order = OrderDatabase.orders[orderstatus][i]
  
  if (not order) then return end
  
  local od, ot = FormatAchievementLinkTimestamp(order.ordertime)
  local cd, ct = FormatAchievementLinkTimestamp(order.claimtime)
  local sd, st = FormatAchievementLinkTimestamp(order.shiptime)
  
  local isdeliv = (order.shiptime > 0)
  local toolong = ((GetDiffBetweenTimeStamps(GetTimeStamp(), order.claimtime) > CLAIM_TOO_LONG) and not isdeliv)
  local isclaimed = (order.claimtime > 0)
  local myclaim = ((CurrentClaim.orderuuid == uuid) and not isdeliv)
  local icanclaim = ((CurrentClaim.orderindex == 0) and not isdeliv)
  local hasdeposit = false
  local isdeposit = false
  
  if ((order.deposit_reqd ~= nil) and (order.deposit_taken ~= nil)) then
    hasdeposit = ((order.deposit_reqd > 0) and (order.deposit_taken < order.deposit_reqd) and not isdeliv)
    isdeposit = ((order.deposit_reqd > 0) and not isdeliv)
  end
  
  local istrading = (order.TRADINGMATS)
  
  local claim = zo_strformat("<<1>>NOT STARTED|r", COLOR_GREEN)
  local deliv = zo_strformat("<<1>>NOT DELIVERED|r", COLOR_RED)
  
  
  if (isclaimed) then
    if (toolong) then
      claim = zo_strformat("<<1>>STARTED:\n<<2>>\n<<3>>|r", COLOR_RED, cd, ct)
    else
      claim = zo_strformat("<<1>>STARTED:|r\n<<2>>\n<<3>>", COLOR_GREEN, cd, ct)
    end
  end
  
  if (isdeliv) then
    deliv = zo_strformat("<<1>>DELIVERED:|r\n<<2>>\n<<3>>", COLOR_GREEN, sd, st)
  end
  
  
  
  HotepCraft_UI_order_OrderNum:SetText(zo_strformat("Order #: <<1>>", order.ordernumber))
  HotepCraft_UI_order_OrderID:SetText(zo_strformat("ID#: <<1>>", order.uuid))
  HotepCraft_UI_order_Customer:SetText(zo_strformat("Customer: <<1>>", order.customer))
  HotepCraft_UI_order_Comments:SetText(zo_strformat("Comments: <<1>>", order.comments))
  HotepCraft_UI_order_Total:SetText(zo_strformat("Grand Total: <<1>>", order.grandtotal))
--  HotepCraft_UI_order_NumSets:SetText(zo_strformat("# of Sets: <<1>>", order.sets))
  HotepCraft_UI_order_OrderTime:SetText(zo_strformat("<<1>>ORDERED:|r\n<<2>>\n<<3>>", COLOR_GREEN, od, ot))
  HotepCraft_UI_order_ClaimTime:SetText(claim)
  HotepCraft_UI_order_DeliverTime:SetText(deliv)
  HotepCraft_UI_order_ItemsHeading:SetText(zo_strformat("<<1>><<2>> ITEMS|r", COLOR_MSG, #order.items))
  
  
  HotepCraft_UI_order_Button_Claim:SetHidden(true)
  HotepCraft_UI_order_Button_Unclaim:SetHidden(true)
  HotepCraft_UI_order_Button_Deliver:SetHidden(true)
  HotepCraft_UI_order_Button_DoneTrades:SetHidden(true)
  HotepCraft_UI_order_Button_DeleteOrder:SetHidden(true)
  HotepCraft_UI_order_Button_ReturnedMerch:SetHidden(true)
  HotepCraft_UI_order_ReturnedNote:SetHidden(true)
  HotepCraft_UI_order_Button_PAID:SetHidden(true)
  HotepCraft_UI_order_Button_Waive:SetHidden(true)
  HotepCraft_UI_order_DepositInfo:SetHidden(true)
  HotepCraft_UI_order_MatsGetting:SetHidden(true)
  HotepCraft_UI_order_MatsView:SetHidden(true)
  
  HotepCraft_UI_order_CSRPrompt1:SetHidden(true)
  HotepCraft_UI_order_CSRPrompt2:SetHidden(true)
  HotepCraft_UI_order_CSRAjustmentContainer:SetHidden(true)
  HotepCraft_UI_order_CSRReasonContainer:SetHidden(true)
  HotepCraft_UI_order_Button_CSR_OK:SetHidden(true)
  HotepCraft_UI_order_Button_CSR_Cancel:SetHidden(true)
  
  HotepCraft_UI_order_CSRAjustment:SetText(order.adjustment)
  HotepCraft_UI_order_CSRReason:SetText(order.reason)
  
  if (myclaim) then
    HotepCraft_UI_order_Button_CSRAdj:SetHidden(false)
    HotepCraft_UI_order_Button_EditOrder:SetHidden(false)
  else
    HotepCraft_UI_order_Button_CSRAdj:SetHidden(true)
    HotepCraft_UI_order_Button_EditOrder:SetHidden(true)
  end
  
  
  if (isdeposit) then
    local txt = "Deposit Rqd: <<1>>g. Dep. Taken: <<2>>g"
    local color = COLOR_GREEN
    txt = zo_strformat(txt, order.deposit_reqd, order.deposit_taken)
    if (hasdeposit) then
      color = COLOR_RED
    end
    txt = zo_strformat("<<1>><<2>>|r", color, txt)
    HotepCraft_UI_order_DepositInfo:SetText(txt)
    HotepCraft_UI_order_DepositInfo:SetHidden(false)
  end
  
  
  if (not isclaimed or isdeliv or not myclaim) then
    HotepCraft_UI_order_Button_DeleteOrder:SetHidden(false)
  end
  
  
  if (myclaim and CurrentClaim.finished) then
    if (istrading) then
      HotepCraft_UI_order_Button_DoneTrades:SetHidden(false)
    else
      HotepCraft_UI_order_Button_Deliver:SetHidden(false)
    end
  elseif (myclaim) then
    HotepCraft_UI_order_Button_Unclaim:SetHidden(false)
  elseif (icanclaim) then
    HotepCraft_UI_order_Button_Claim:SetHidden(false)
  end
  
  
  HotepCraft.UI_ItemsList = UI_ItemsList:New(HotepCraft_UI_order)
  HotepCraft.UI_ItemsList.PROFESSION = nil
  HotepCraft.UI_ItemsList:RefreshData()
  HotepCraft.UI_ItemsList:SortScrollList()
  HotepCraft.UI_ItemsList:RefreshVisible()
  
  
  local plus = function (list, mattable)
    for k,v in pairs(mattable) do
      table.insert(list, zo_strformat("<<1>> (x <<2>>)", k, v))
    end
  end
  
  
  if (myclaim and CurrentClaim.finished) then
    HotepCraft_UI_order_Mats1:SetHidden(true)
    HotepCraft_UI_order_Mats2:SetHidden(true)
    HotepCraft_UI_order_Mats2a:SetHidden(true)
    HotepCraft_UI_order_Mats3:SetHidden(true)
    HotepCraft_UI_order_Mats4:SetHidden(true)
    HotepCraft_UI_order_Locations:SetHidden(true)
    HotepCraft_UI_order_MatsHeading:SetHidden(true)
    if (istrading) then
      HotepCraft_UI_order_Button_IDelivered:SetHidden(true)
    else
      HotepCraft_UI_order_Button_IDelivered:SetHidden(false)
    end
    HotepCraft_UI_order_PaidInFull:SetHidden(true)
    HotepCraft_UI_order_AmountDue:SetHidden(true)
  elseif (isdeliv) then
    HotepCraft_UI_order_Mats1:SetHidden(true)
    HotepCraft_UI_order_Mats2:SetHidden(true)
    HotepCraft_UI_order_Mats2a:SetHidden(true)
    HotepCraft_UI_order_Mats3:SetHidden(true)
    HotepCraft_UI_order_Mats4:SetHidden(true)
    HotepCraft_UI_order_Locations:SetHidden(true)
    HotepCraft_UI_order_MatsHeading:SetHidden(true)
    HotepCraft_UI_order_Button_IDelivered:SetHidden(true)
    HotepCraft_UI_order_PaidInFull:SetHidden(false)
    HotepCraft_UI_order_AmountDue:SetHidden(true)
    
    
    local pay, due
    
    if (order.paidInFull) then
      pay = zo_strformat("<<1>>Order has been paid in full.|r", COLOR_GREEN)
    else
      pay = zo_strformat("<<1>>Order has NOT YET been paid in full.|r", COLOR_RED)
      HotepCraft_UI_order_Button_ReturnedMerch:SetHidden(false)
    end
    
    HotepCraft_UI_order_PaidInFull:SetText(pay)
    
    
    ---@local WaitRec @class WAITINGCLAIM
    local WaitRec = select(2, array_find(uuid, CurrentClaim.WaitingForMoney, function (ele) return ele.orderuuid end))
    
    if (WaitRec and (WaitRec.paymentDue > 0)) then
      HotepCraft_UI_order_AmountDue:SetHidden(false)
      due = zo_strformat("<<1>>Amount Due: <<2>>.|r", COLOR_MSG, WaitRec.paymentDue)
      HotepCraft_UI_order_AmountDue:SetText(due)
      HotepCraft_UI_order_Button_PAID:SetHidden(false)
    end
    
  else
    HotepCraft_UI_order_Mats1:SetHidden(false)
    HotepCraft_UI_order_Mats2:SetHidden(false)
    HotepCraft_UI_order_Mats2a:SetHidden(false)
    HotepCraft_UI_order_Mats3:SetHidden(false)
    HotepCraft_UI_order_Mats4:SetHidden(false)
    HotepCraft_UI_order_Locations:SetHidden(false)
    HotepCraft_UI_order_MatsHeading:SetHidden(false)
    HotepCraft_UI_order_Button_IDelivered:SetHidden(true)
    HotepCraft_UI_order_PaidInFull:SetHidden(true)
    HotepCraft_UI_order_AmountDue:SetHidden(true)
    
    if (hasdeposit) then
      HotepCraft_UI_order_Button_Waive:SetHidden(false)
      HotepCraft_UI_order_Button_Claim:SetHidden(true)
    elseif (order.RETURNED and not isclaimed) then
      pay = zo_strformat("<<1>>Order HAS BEEN RETURNED.|r", COLOR_PURPLE)
      HotepCraft_UI_order_ReturnedNote:SetText(pay)
      HotepCraft_UI_order_ReturnedNote:SetHidden(false)
    elseif (myclaim and istrading) then
      HotepCraft_UI_order_MatsGetting:SetHidden(false)
      HotepCraft_UI_order_MatsView:SetColor(ROWCOLOR_PURPLE:UnpackRGBA())
      HotepCraft_UI_order_MatsView:SetHidden(false)
    end
    
    ---@local mats @class ORDERMATS
    local mats = HotepCraft.GetAllMats(order, myclaim)
    
    local list = {}
    plus(list, mats.items)
    HotepCraft_UI_order_Mats1:SetText(table.concat(list, ", "))
    HotepCraft_UI_order_Mats1.ToolTipText = IIfAString("items")
    
    list = {}
    plus(list, mats.traits)
    HotepCraft_UI_order_Mats2:SetText(table.concat(list, ", "))
    HotepCraft_UI_order_Mats2.ToolTipText = IIfAString("traits")
    
    list = {}
    plus(list, mats.styles)
    HotepCraft_UI_order_Mats2a:SetText(table.concat(list, ", "))
    HotepCraft_UI_order_Mats2a.ToolTipText = IIfAString("styles")
    
    list = {}
    plus(list, mats.improves)
    HotepCraft_UI_order_Mats3:SetText(table.concat(list, ", "))
    HotepCraft_UI_order_Mats3.ToolTipText = IIfAString("improves")
    
    list = {}
    plus(list, mats.potents)
    plus(list, mats.essances)
    HotepCraft_UI_order_Mats4:SetText(table.concat(list, ", "))
    HotepCraft_UI_order_Mats4.ToolTipText = IIfAString("potents", "essances")
    
    
    local craftinglocs = ""
    
    if (order.sets > 0) then
      list = HotepCraft.GetAllSetLocs(order)
      craftinglocs = zo_strformat("<<1>>SET Crafting Locations: |r", COLOR_MSG) .. table.concat(list, ", ")
    end
    
    HotepCraft_UI_order_Locations:SetText(craftinglocs)
  end
  
end
-- end HotepCraft.InitUIOrderDetails()


function HotepCraft.ShowMatTradesSoFar()
  
  if (not HotepCraft_UI_order_ShowMatsSoFar:IsHidden()) then
    HotepCraft_UI_order_ShowMatsSoFar:SetHidden(true)
    HotepCraft.InitUIOrderDetails()
    return
  end
  
  local MatList = ZO_SortFilterList:Subclass()
  
  MatList.defaults = {}
  MatList.SORT_KEYS = {}
  
  function MatList:New(control)
    ZO_SortFilterList.InitializeSortFilterList(self, control)

    self.masterList = {}

    ZO_ScrollList_AddDataType(self.list, 1, "HotepCraft_UI_order_MatsSoFar_Row", 32, function(control, data) self:SetupOrderRow(control, data) end)

    self.sortFunction = function(listEntry1, listEntry2)
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
      end

    return self
  end
  
  function MatList:SetupOrderRow(rowControl, data)
    rowControl.data = data
    rowControl.text = GetControl(rowControl, "text")
    rowControl.text:SetText(data.text)
    
    ZO_SortFilterList.SetupRow(self, rowControl, data)
  end
  
  function MatList:BuildMasterList()
    self.masterList = {}
    
    ---@local order @class ORDER
    local order = HotepCraft.ReturnClaimedOrder()
    
    if (not order) then return end
    
    for mattype,tradings in pairs(order.MatTrades) do
      if (type(tradings) == "table") then
        ---@local trade @class MatTradeRec
        for _,trade in ipairs(tradings) do
          if (trade.needed > 0) then
            local color, icon
            if (trade.got == 0) then
              color = COLOR_RED
              icon = "EsoUI/Art/Buttons/decline_up.dds"
            elseif (trade.got < trade.needed) then
              color = COLOR_YELLOW
              icon = "/esoui/art/campaign/overview_indexicon_scoring_up.dds"
            else
              color = COLOR_GREEN
              icon = "esoui/art/loot/loot_finesseItem.dds"
            end
            
            local i = zo_strformat("|t28:28:<<1>>:inheritcolor|t |u10:0:: |u", icon)
            local s = "<<4>><<6>>Received <<1>>x |r<<5>><<2>>|r<<4>> of <<3>> needed.|r"
            s = zo_strformat(s, trade.got, trade.mat, trade.needed, color, COLOR_MSG, i)
            
            table.insert(self.masterList, {text = s})
          end
        end
      end
    end
  end
  
  function MatList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    
    for i = 1, #self.masterList do
      local data = self.masterList[i]
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end
  end
  
  
  function MatList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
  end
  
  
  HotepCraft.ShowMatTradesListControl = MatList:New(HotepCraft_UI_order_ShowMatsSoFar)
  
  HotepCraft_UI_order_Mats1:SetHidden(true)
  HotepCraft_UI_order_Mats2:SetHidden(true)
  HotepCraft_UI_order_Mats2a:SetHidden(true)
  HotepCraft_UI_order_Mats3:SetHidden(true)
  HotepCraft_UI_order_Mats4:SetHidden(true)
  HotepCraft_UI_order_Locations:SetHidden(true)
  HotepCraft_UI_order_ShowMatsSoFar:SetHidden(false)
  
  HotepCraft.ShowMatTradesListControl:RefreshData()
  HotepCraft.ShowMatTradesListControl:RefreshVisible()
end
-- end HotepCraft.ShowMatTradesSoFar()


function HotepCraft.MatTradesDone(order, i)
  
  if (not order) then
    order = HotepCraft.ReturnClaimedOrder()
  end
  
  order.TRADINGMATS = false
  
  if (not i) then
    i = array_indexof(order.uuid, CurrentClaim.WaitingForMats, function(ele) return ele.orderuuid end)
  end
  
  if (i > 0) then
    table.remove(CurrentClaim.WaitingForMats, i)
  end
  
  if (not order.originalgrandtotal) then
    order.originalgrandtotal = order.grandtotal
  end
  
  order.grandtotal = order.grandtotal - OT.GDP(PriceList, order, order.MatTrades.MatDiscount)
  
  order.MatTrades = nil
  
  HotepCraft.ToggleUIOrderDetail(false)
end



function HotepCraft.EditClaimedOrder()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  HotepCraft.ToggleUIEnterOrder(true, true)
end


function HotepCraft.SaveClaimedOrder()
  
  if (CurrentClaim.orderindex == 0) then return false end
  
  local i = HotepCraft.ReturnClaimedOrder(true)
  
  if (not i) then return false end
  
  if (#HotepCraft.neworder.order.items == 0) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return false
  end
  
  HotepCraft.neworder.order.customer = HotepCraft_UI_entry_Customer:GetText()
  HotepCraft.neworder.order.comments = HotepCraft_UI_entry_Comments:GetText()
  
  OrderDatabase.orders[ORDER_STATUS_CLAIMED][i] = clone(HotepCraft.neworder.order)
  
  HotepCraft.MailOrderReceipt(true)
  HotepCraft.ToggleUIEnterOrder(false)
  
  HotepCraft.ReClaimOrder()
  HotepCraft.UpdateClaimCraftingTypes()
  
  HotepCraft.ShowMyOrderUI()
end


function HotepCraft.InitUIEnterOrder(editing)
  
  HotepCraft.busy = true
  
  HotepCraft.neworder = clone(NEWORDER_INIT)
  
  local savedentry = false
  
  if (editing) then
    HotepCraft.neworder.order = clone(HotepCraft.ReturnClaimedOrder())
  elseif (HotepCraft.SAVEDENTRY) then
    HotepCraft.neworder.order = clone(HotepCraft.SAVEDENTRY)
    savedentry = true
    HotepCraft.SAVEDENTRY = nil
  else
    HotepCraft.neworder.order = clone(ORDER)
  end
  
  
  HotepCraft.UI_ItemsList = UI_ItemsList:New(HotepCraft_UI_entry, false, true)
  HotepCraft.UI_ItemsList.ENTERORDER = true
  HotepCraft.UI_ItemsList:RefreshData()
  HotepCraft.UI_ItemsList:SortScrollList()
  HotepCraft.UI_ItemsList:RefreshVisible()
  
  if (editing) then
    HotepCraft.neworder.order.guildie = IsAGuildie(HotepCraft.neworder.order.customer)
    HotepCraft_UI_entry_Customer_BG:SetHidden(false)
    HotepCraft_UI_entry_Comments_BG:SetHidden(false)
    HotepCraft_UI_entry_Button_Complete:SetHidden(true)
    HotepCraft_UI_entry_Button_Claim:SetHidden(true)
    HotepCraft_UI_entry_Button_SaveEdit:SetHidden(false)
    HotepCraft_UI_entry_EditNotice:SetHidden(false)
    HotepCraft_UI_entry_Customer:SetEditEnabled(true)
    HotepCraft_UI_entry_Comments:SetEditEnabled(true)
    HotepCraft_UI_entry_Customer:SetText(HotepCraft.neworder.order.customer)
    HotepCraft_UI_entry_Comments:SetText(HotepCraft.neworder.order.comments)
  else
    HotepCraft_UI_entry_Customer_BG:SetHidden(false)
    HotepCraft_UI_entry_Comments_BG:SetHidden(false)
    HotepCraft_UI_entry_Button_Complete:SetHidden(false)
    HotepCraft_UI_entry_Button_Claim:SetHidden(false)
    HotepCraft_UI_entry_Button_SaveEdit:SetHidden(true)
    HotepCraft_UI_entry_EditNotice:SetHidden(true)
    HotepCraft_UI_entry_Customer:SetEditEnabled(true)
    HotepCraft_UI_entry_Comments:SetEditEnabled(true)
    
    if (savedentry) then
      HotepCraft_UI_entry_Customer:SetText(HotepCraft.neworder.order.customer)
      HotepCraft_UI_entry_Comments:SetText(HotepCraft.neworder.order.comments)
      HotepCraft.neworder.order.guildie = IsAGuildie(HotepCraft.neworder.order.customer)
    else
      HotepCraft_UI_entry_Customer:SetText(HotepCraft.me)
      HotepCraft_UI_entry_Comments:SetText("")
      HotepCraft.neworder.order.customer = HotepCraft.me
      HotepCraft.neworder.order.guildie = true
    end
    
    HotepCraft_UI_entry_Button_Claim:SetHidden((CurrentClaim.orderindex > 0))
  end
  local txt = zo_strformat("<<1>><<2>> ITEMS|r (click to edit or remove)", COLOR_MSG, #HotepCraft.neworder.order.items)
  HotepCraft_UI_entry_ItemsHeading:SetText(txt)
  
  if (not HotepCraft.neworder.order.TRADINGMATS) then
    HotepCraft_UI_entry_Button_TradingMats:SetText("|cff00ffNot Providing Mats|r")
    HotepCraft_UI_entry_Button_TradingMats.tooltipText = "Click here if customer |c00ff00will be|r providing mats."
  else
    HotepCraft_UI_entry_Button_TradingMats:SetText("|c00ff00Providing Mats|r")
    HotepCraft_UI_entry_Button_TradingMats.tooltipText = "Click here if customer |cff00ffwill NOT be|r providing mats."
  end
  
  HotepCraft.UIEntry_UpdateTotal()
  
  HotepCraft.UIEntry_InitNewItem(OT.ITEM())
end
-- end HotepCraft.InitUIEnterOrder(editing)


function HotepCraft.UIEntry_ToggleTradeMats()
  if (HotepCraft.neworder.order.TRADINGMATS) then
    HotepCraft.neworder.order.TRADINGMATS = false
    HotepCraft_UI_entry_Button_TradingMats:SetText("|cff00ffNot Providing Mats|r")
    HotepCraft_UI_entry_Button_TradingMats.tooltipText = "Click here if customer |c00ff00will be|r providing mats."
  else
    HotepCraft.neworder.order.TRADINGMATS = true
    HotepCraft_UI_entry_Button_TradingMats:SetText("|c00ff00Providing Mats|r")
    HotepCraft_UI_entry_Button_TradingMats.tooltipText = "Click here if customer |cff00ffwill NOT be|r providing mats."
  end
end


---
-- @param item @class ITEM
-- @return @class nil
function HotepCraft.UIEntry_InitNewItem(item)
  
  if (item and item.ISFEE) then
    HotepCraft.neworder.params.item = clone(item)
    HotepCraft_UI_entry_Button_AddItem:SetHidden((#HotepCraft.neworder.order.items == 12))
    HotepCraft_UI_entry_MaxOrder:SetHidden((#HotepCraft.neworder.order.items < 12))
    HotepCraft_UI_entry_EnterFeeName:SetText(item.FEENAME)
    if (item.price == 0) then
      HotepCraft_UI_entry_EnterFeeAmt:SetText("")
    else
      HotepCraft_UI_entry_EnterFeeAmt:SetText(item.price)
    end
    HotepCraft.UIEntry_DoFeeHides(true)
    return
  else
    HotepCraft.UIEntry_DoFeeHides(false)
  end
  
  
  local old_type = HotepCraft.neworder.params.item.itemtype
  local old_trait = HotepCraft.neworder.params.item.trait
  local old_ench = HotepCraft.neworder.params.item.enchant
  local old_q = HotepCraft.neworder.params.item.improvement
  local old_set = HotepCraft.neworder.params.item.set
  local old_style = HotepCraft.neworder.params.item.style
  
  HotepCraft.neworder.params.item = clone(item)
  
  if (old_type and (old_type ~= "") and (item.itemtype == "")) then
    local aw = OT.ARM_WEAP(old_type)
    HotepCraft.neworder.params.old_aw = aw
    HotepCraft.neworder.params.item.trait = old_trait
    HotepCraft.neworder.params.item.enchant = old_ench
    HotepCraft.neworder.params.item.improvement = old_q
    HotepCraft.neworder.params.item.set = old_set
    HotepCraft.neworder.params.item.style = old_style
  else
    local aw = OT.ARM_WEAP(item.itemtype)
    HotepCraft.neworder.params.old_aw = aw
  end
  
  HotepCraft.UIEntry_UpdateItemChoices()
  HotepCraft.UIEntry_UpdateTraitChoices(item.itemtype)
  HotepCraft.UIEntry_UpdateEnchantChoices(item.itemtype)
  HotepCraft.UIEntry_UpdateQualChoices(HotepCraft.neworder.params.item)
  HotepCraft.UIEntry_UpdateSetChoices()
  HotepCraft.UIEntry_UpdateStyleChoices()
  
  HotepCraft_UI_entry_LevelDropdown:UpdateValue()
  HotepCraft_UI_entry_ItemDropdown:UpdateValue()
  HotepCraft_UI_entry_QualityDropdown:UpdateValue()
  HotepCraft_UI_entry_StyleDropdown:UpdateValue()
  HotepCraft_UI_entry_SetDropdown:UpdateValue()
  HotepCraft_UI_entry_TraitDropdown:UpdateValue()
  HotepCraft_UI_entry_EnchantDropdown:UpdateValue()
  
  HotepCraft_UI_entry_Button_AddItem:SetHidden((#HotepCraft.neworder.order.items == 12))
  HotepCraft_UI_entry_MaxOrder:SetHidden((#HotepCraft.neworder.order.items < 12))
end
-- end HotepCraft.UIEntry_InitNewItem(item)


function HotepCraft.UIEntry_UpdateTotal()
  
  if ((HotepCraft.neworder.order.customer == HotepCraft.me) or HotepCraft.neworder.free) then
    HotepCraft.neworder.order.itemtotal = 0
    HotepCraft.neworder.order.feetotal = 0
    HotepCraft.neworder.order.originalgrandtotal = 0
    HotepCraft.neworder.order.grandtotal = 0
    HotepCraft.neworder.order.adjustment = 0
  else
    local i = 0
    local f = OT.GDP(PriceList, HotepCraft.neworder.order, PriceList.fixedfee)
    local g = OT.GDP(PriceList, HotepCraft.neworder.order, PriceList.fixedfee)
    
    ---@local item @class ITEM
    for _,item in ipairs(HotepCraft.neworder.order.items) do
      i = i + item.price
      f = f + item.fee
      g = g + item.price + item.fee
    end
    
    HotepCraft.neworder.order.itemtotal = i
    HotepCraft.neworder.order.feetotal = f
    
    HotepCraft.neworder.order.originalgrandtotal = g
    HotepCraft.neworder.order.grandtotal = g + HotepCraft.neworder.order.adjustment
  end
  
  HotepCraft.SetDepositAmt(HotepCraft.neworder.order)
  
  if (HotepCraft.neworder.order.deposit_reqd > 0) then
    HotepCraft_UI_entry_Button_Claim:SetHidden(true)
  else
    HotepCraft_UI_entry_Button_Claim:SetHidden((CurrentClaim.orderindex > 0))
  end
  
  HotepCraft.neworder.order.comments = HotepCraft_UI_entry_Comments:GetText()
  HotepCraft_UI_entry_Total:SetText(zo_strformat("Grand Total: <<1>>g", HotepCraft.neworder.order.grandtotal))
end


function HotepCraft.UIEntry_LevelUpdate(lev)
  
  if (not lev) then return end
  
  HotepCraft.neworder.order.level = lev
  
  local list = clone(HotepCraft.neworder.order.items)
  
  HotepCraft.neworder.order.items = {}
  
  
  for k,item in ipairs(list) do
    HotepCraft.UIEntry_AddItem(item)
  end
  
  
  HotepCraft.UIEntry_UpdateItemChoices()
  HotepCraft.UIEntry_UpdateQualChoices(HotepCraft.neworder.params.item)
  HotepCraft.UIEntry_UpdateEnchantChoices(HotepCraft.neworder.params.item.itemtype)
  HotepCraft.UIEntry_UpdateSetChoices()
  HotepCraft.UIEntry_UpdateStyleChoices()
  HotepCraft.UIEntry_UpdateTotal()
  HotepCraft.UI_ItemsList:RefreshData()
  HotepCraft.UI_ItemsList:SortScrollList()
  HotepCraft.UI_ItemsList:RefreshVisible()
end
-- end HotepCraft.UIEntry_LevelUpdate(lev)


function HotepCraft.UIEntry_CustomerUpdate()
  local cust = HotepCraft_UI_entry_Customer:GetText()
  HotepCraft.neworder.order.customer = cust
  HotepCraft.neworder.order.guildie = IsAGuildie(cust)
  
  if (cust == HotepCraft.me) then
    HotepCraft.neworder.free = true
    HotepCraft_UI_entry_OrderTypeDropdown:UpdateValue()
    HotepCraft_UI_entry_Discount:SetHidden(true)
  else
    HotepCraft_UI_entry_Discount:SetHidden(not HotepCraft.neworder.order.guildie)
  end
  
  HotepCraft.UIEntry_LevelUpdate(HotepCraft.neworder.order.level)
end
-- end HotepCraft.UIEntry_CustomerUpdate()


function HotepCraft.UIEntry_AddItem(itemToAdd)
  
  ---@local item @class ITEM
  local item
  
  if (itemToAdd) then
    item = clone(itemToAdd)
  else
    item = clone(HotepCraft.neworder.params.item)
  end
  
  
  if (item.ISFEE) then
    
    if (item.FEENAME == "") then
      ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Fee Name Cannot Be Blank|r", COLOR_PURPLE))
      return
    end
    
    if (item.price == 0) then
      ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Fee Cannot Be Zero|r", COLOR_PURPLE))
      return
    end
    
    table.insert(HotepCraft.neworder.order.items, item)
    
    local txt = zo_strformat("<<1>><<2>> ITEMS|r (click to edit or remove)", COLOR_MSG, #HotepCraft.neworder.order.items)
    HotepCraft_UI_entry_ItemsHeading:SetText(txt)
    
    HotepCraft.neworder.order.comments = HotepCraft_UI_entry_Comments:GetText()
    
    if (not itemToAdd) then
      HotepCraft.UIEntry_UpdateTotal()
      
      HotepCraft.UIEntry_InitNewItem(OT.ITEM())
      
      HotepCraft.UI_ItemsList:RefreshData()
      HotepCraft.UI_ItemsList:SortScrollList()
      HotepCraft.UI_ItemsList:RefreshVisible()
    end
    
    return
  end
  -- endif (item.ISFEE)
  
  if (not item.itemtype or not HotepCraft.neworder.order.level or (item.itemtype == "") or (item.item == 0)) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  
  
  item.profession = OT.PROF(item.itemtype)
  
  
  local aw = OT.ARM_WEAP(item.itemtype)
  
  
  
  
  if ((HotepCraft.neworder.order.customer == HotepCraft.me) or HotepCraft.neworder.free) then
    item.price = 0
    item.fee = 0
  else
    -- calc item price
    
    local pp = OT.GetPriceTable(item.itemtype)
    local prices = PriceList.price[pp]
    local prr = OT.GetTotalUnitsPrice(prices, HotepCraft.neworder.order.level, item.itemtype, item.item)
    
    item.price = OT.GDP(PriceList, HotepCraft.neworder.order, prr)
    
    
    -- calc item fee
    
    item.fee = PriceList.itemfee
    
    if (item.improvement > 0) then
      local pr = OT.GetTotalImproveFee(PriceList.improvefees, item.profession, item.improvement, HotepCraft.improvQty)
      item.fee = item.fee + OT.GDP(PriceList, HotepCraft.neworder.order, pr)
    end
    
    if (item.trait) then
      local pr = PriceList.traitfee[aw][item.trait]
      item.fee = item.fee + OT.GDP(PriceList, HotepCraft.neworder.order, pr)
    end
    
    if (item.set > 0) then
      local pr = PriceList.setfees[item.set]
      item.fee = item.fee + OT.GDP(PriceList, HotepCraft.neworder.order, pr)
    end
    
    if (item.style > 0) then
      local pr = PriceList.stylefees[item.style]
      item.fee = item.fee + OT.GDP(PriceList, HotepCraft.neworder.order, pr)
    end
    
    if (item.enchant > 0) then
      local pr = OT.GetEnchantFee(PriceList, item.itemtype, HotepCraft.neworder.order.level, item.enchant)
      item.fee = item.fee + OT.GDP(PriceList, HotepCraft.neworder.order, pr)
    end
  end
  
  if (HotepCraft.neworder.order.level == OT.RESEARCH_LEVEL) then
    item.enchant = 0
    item.improvement = 0
    item.set = 0
    item.style = 0
  end
  
  table.insert(HotepCraft.neworder.order.items, item)
  
  local txt = zo_strformat("<<1>><<2>> ITEMS|r (click to edit or remove)", COLOR_MSG, #HotepCraft.neworder.order.items)
  HotepCraft_UI_entry_ItemsHeading:SetText(txt)
  
  HotepCraft.neworder.order.comments = HotepCraft_UI_entry_Comments:GetText()
  
  if (not itemToAdd) then
    HotepCraft.UIEntry_UpdateTotal()
    
    HotepCraft.UIEntry_InitNewItem(OT.ITEM())
    
    HotepCraft.UI_ItemsList:RefreshData()
    HotepCraft.UI_ItemsList:SortScrollList()
    HotepCraft.UI_ItemsList:RefreshVisible()
  end
end
-- end HotepCraft.UIEntry_AddItem(itemToAdd)


function HotepCraft.UIEntry_EditItem(control, button, upInside)
  
  local k = control.data.itemindex
  
  local item = clone(HotepCraft.neworder.order.items[k])
  
  table.remove(HotepCraft.neworder.order.items, k)
  
  local txt = zo_strformat("<<1>><<2>> ITEMS|r (click to edit or remove)", COLOR_MSG, #HotepCraft.neworder.order.items)
  HotepCraft_UI_entry_ItemsHeading:SetText(txt)
  
  HotepCraft.UIEntry_UpdateTotal()
  
  HotepCraft.UIEntry_InitNewItem(item)
  
  HotepCraft.UI_ItemsList:RefreshData()
  HotepCraft.UI_ItemsList:SortScrollList()
  HotepCraft.UI_ItemsList:RefreshVisible()
end
-- end HotepCraft.UIEntry_EditItem(control, button, upInside)


function HotepCraft.UIEntry_SubmitOrder(claim)
  
  if (#HotepCraft.neworder.order.items == 0) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return false
  end
  
  if (CurrentClaim.orderindex > 0) then claim = false end
  
  HotepCraft.neworder.order.customer = HotepCraft_UI_entry_Customer:GetText()
  HotepCraft.neworder.order.comments = HotepCraft_UI_entry_Comments:GetText()
  HotepCraft.neworder.order.ordertime = GetTimeStamp()
  
  local OrderStatus
  
  if (claim) then
    OrderStatus = ORDER_STATUS_CLAIMED
  else
    OrderStatus = ORDER_STATUS_WAITING
  end
  
  HotepCraft.FinalizeOrder(true, OrderStatus)
  
  if (claim) then
    HotepCraft.ClaimOrder(HotepCraft.neworder.order.uuid, OrderStatus)
    HotepCraft.ScanCrafterBackpack()
  end
  
  HotepCraft.ToggleUIEnterOrder(false)
  HotepCraft.ToggleUIMain(true, OrderStatus)
end
-- end HotepCraft.UIEntry_SubmitOrder(claim)


function HotepCraft.UIEntry_GenerateItemChoices()
  
  local choices = {}
  local values = {}
  
  
  if (not HotepCraft.neworder.order.level) then
    return choices, values
  end
  
  
  local types = {'light','med','heavy','1h','2h','dstaff','rstaff','bow','shield'}
  local typenames = {'(Light) ', '(Medium) ', '(Heavy) ', '(One Handed) ', '(Two Handed) ', '','','',''}
  
  for j,itemtype in ipairs(types) do
    local pieces, _ = OT.PIECES(itemtype, true)
    
    for k,piece in ipairs(pieces) do
      
      local pp = OT.GetPriceTable(itemtype)
      local prices = PriceList.price[pp]
      
      local price = OT.GetTotalUnitsPrice(prices, HotepCraft.neworder.order.level, itemtype, k)
      price = OT.GDP(PriceList, HotepCraft.neworder.order, price)
      
      local name = zo_strformat("<<1>><<2>> (base price <<3>>g)", typenames[j], piece, price)
      table.insert(choices, name)
      table.insert(values, zo_strformat("<<1>>;<<2>>", itemtype, k))
      
    end   -- end for ipairs(pieces)
    
  end  -- end for ipairs(types)
  
  table.insert(choices, "Flat Fee / surcharge / discount")
  table.insert(values, "X;0")
  
  return choices, values
end
-- end HotepCraft.UIEntry_GenerateItemChoices()


function HotepCraft.UIEntry_GenerateStyleChoices()
  
  local choices = {"No Preference"}
  local values = {0}
  
  
  if (not HotepCraft.neworder.order.level or HotepCraft.neworder.order.level == OT.RESEARCH_LEVEL) then
    return choices, values
  end
  
  
  for i = 1, OT.MOTIFS() do
    local style = OT.MOTIFS(i)
    local fee = PriceList.stylefees[i]
    local str = style.name;
    if (fee > 0) then
      fee = OT.GDP(PriceList, HotepCraft.neworder.order, fee)
      str = zo_strformat("<<1>> (add <<2>>g)", style.name, fee)
    elseif (fee < 0) then
      str = zo_strformat("<<1>><<2>>|r", COLOR_PURPLE, str)
    end
    
    if (style.crown) then
      str = str .. zo_strformat(' <<1>>CROWN-STORE ONLY STYLE|r', COLOR_RED)
    end
    
    table.insert(choices, str)
    table.insert(values, i)
  end
  
  return choices, values
end


function HotepCraft.UIEntry_GenerateSetChoices()
  
  local choices = {"No Set"}
  local values = {0}
  
  
  if (not HotepCraft.neworder.order.level or HotepCraft.neworder.order.level == OT.RESEARCH_LEVEL) then
    return choices, values
  end
  
  
  for i = 1, OT.ARM_SETS() do
    ---@local set @class SETREC
    local set = OT.ARM_SETS(i)
    local fee = PriceList.setfees[i]
    fee = OT.GDP(PriceList, HotepCraft.neworder.order, fee)
    local str = zo_strformat("<<1>> (<<2>> traits)", set.name, set.traits)
    
    if (fee > 0) then
      str = zo_strformat("<<1>> (add <<2>>g)", str, fee)
    elseif (fee < 0) then
      str = zo_strformat("<<1>><<2>>|r", COLOR_PURPLE, str)
    end
    
    if ((fee >= 0) and set.loc.special.dlc and set.loc.special.craft) then
      str = zo_strformat("<<1>><<2>>|r", COLOR_MSG, str)
    end
    
    table.insert(choices, str)
    table.insert(values, i)
  end
  
  return choices, values  
end


function HotepCraft.UIEntry_DoFeeHides(isfee)
  HotepCraft_UI_entry_ChooseQuality:SetHidden(isfee)
  HotepCraft_UI_entry_ChooseStyle:SetHidden(isfee)
  HotepCraft_UI_entry_ChooseSet:SetHidden(isfee)
  HotepCraft_UI_entry_ChooseTrait:SetHidden(isfee)
  HotepCraft_UI_entry_ChooseEnchant:SetHidden(isfee)
  HotepCraft_UI_entry_QualityDropdown:SetHidden(isfee)
  HotepCraft_UI_entry_StyleDropdown:SetHidden(isfee)
  HotepCraft_UI_entry_SetDropdown:SetHidden(isfee)
  HotepCraft_UI_entry_TraitDropdown:SetHidden(isfee)
  HotepCraft_UI_entry_EnchantDropdown:SetHidden(isfee)
  HotepCraft_UI_entry_EnterFeeNameLabel:SetHidden(not isfee)
  HotepCraft_UI_entry_EnterFeeNameContainer:SetHidden(not isfee)
  HotepCraft_UI_entry_EnterFeeAmtLabel:SetHidden(not isfee)
  HotepCraft_UI_entry_EnterFeeAmtContainer:SetHidden(not isfee)
  if (not isfee) then
    HotepCraft_UI_entry_EnterFeeName:SetText("")
    HotepCraft_UI_entry_EnterFeeAmt:SetText("")
  end
end

function HotepCraft.UIEntry_FeeNameUpdate()
  local item = HotepCraft.neworder.params.item
  
  local txt = HotepCraft_UI_entry_EnterFeeName:GetText()
  
  item.FEENAME = txt
end

function HotepCraft.UIEntry_FeeAmtUpdate()
  local item = HotepCraft.neworder.params.item
  
  local txt = HotepCraft_UI_entry_EnterFeeAmt:GetText()
  
  if ((txt ~= "") and (txt ~= "-") and (not txt or not tonumber(txt) or (tonumber(txt) == 0))) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Must be a non-zero Number!|r", COLOR_PURPLE))
    HotepCraft_UI_entry_EnterFeeAmt:SetText("")
    return
  elseif ((txt ~= "") and (txt ~= "-") and tonumber(txt)) then
    item.price = math.floor(tonumber(txt))
    if (tonumber(txt) ~= item.price) then
      HotepCraft_UI_entry_EnterFeeAmt:SetText(tostring(item.price))
    end
  end
end


function HotepCraft.UIEntry_ItemUpdate(choiceValue)
  
  local parts = explode(";", choiceValue)
  
  if ((HotepCraft.neworder.params.item.itemtype ~= "") and (parts[1] ~= "X")) then
    HotepCraft.neworder.params.old_aw = OT.ARM_WEAP(HotepCraft.neworder.params.item.itemtype)
  end
  
  HotepCraft.neworder.params.item.itemtype = parts[1]
  HotepCraft.neworder.params.item.item = tonumber(parts[2])
  
  if (parts[1] == "X") then
    HotepCraft.neworder.params.item.ISFEE = true
    HotepCraft.neworder.params.item.enchant = 0
    HotepCraft.neworder.params.item.fee = 0
    HotepCraft.neworder.params.item.improvement = 0
    HotepCraft.neworder.params.item.profession = 0
    HotepCraft.neworder.params.item.set = 0
    HotepCraft.neworder.params.item.style = 0
    HotepCraft.neworder.params.item.trait = false
    HotepCraft_UI_entry_EnterFeeName:SetText("")
    HotepCraft_UI_entry_EnterFeeAmt:SetText("")
    HotepCraft.UIEntry_DoFeeHides(true)
    return
  else
    HotepCraft.UIEntry_DoFeeHides(false)
  end
  
  HotepCraft.neworder.params.item.profession = OT.PROF(parts[1])
  
--  HotepCraft.neworder.params.item.trait = false
--  HotepCraft.neworder.params.item.enchant = 0
  
  HotepCraft.UIEntry_UpdateTraitChoices(parts[1])
  HotepCraft.UIEntry_UpdateEnchantChoices(parts[1])
  HotepCraft.UIEntry_UpdateQualChoices(HotepCraft.neworder.params.item)
  HotepCraft.UIEntry_UpdateSetChoices()
  HotepCraft.UIEntry_UpdateStyleChoices()
end


function HotepCraft.UIEntry_UpdateItemChoices()
  
  local itemchoices, itemchoicesvalues = HotepCraft.UIEntry_GenerateItemChoices()
  
  HotepCraft_UI_entry_ItemDropdown:UpdateChoices(itemchoices, itemchoicesvalues)
  HotepCraft_UI_entry_ItemDropdown:UpdateValue()
end


function HotepCraft.UIEntry_UpdateStyleChoices()
  
  local choices, values = HotepCraft.UIEntry_GenerateStyleChoices()
  
  HotepCraft_UI_entry_StyleDropdown:UpdateChoices(choices, values)
  HotepCraft_UI_entry_StyleDropdown:UpdateValue()
  HotepCraft_UI_entry_StyleDropdown:SetHidden((HotepCraft.neworder.order.level == OT.RESEARCH_LEVEL))
end


function HotepCraft.UIEntry_UpdateSetChoices()
  
  local choices, values = HotepCraft.UIEntry_GenerateSetChoices()
  
  HotepCraft_UI_entry_SetDropdown:UpdateChoices(choices, values)
  HotepCraft_UI_entry_SetDropdown:UpdateValue()
  HotepCraft_UI_entry_SetDropdown:SetHidden((HotepCraft.neworder.order.level == OT.RESEARCH_LEVEL))
end


function HotepCraft.UIEntry_UpdateTraitChoices(itemtype)
  
  local choices = {"No Trait"}
  local values = {false}
  
  if (itemtype and (itemtype ~= "")) then
    local aw = OT.ARM_WEAP(itemtype)
    
    local traittable
    if (aw == "armor") then
      traittable = ARM_TRAITS
    else
      traittable = WEP_TRAITS
    end
    
    local isort = function(t, a, b)
      return (traittable[a].__i < traittable[b].__i)
    end
    
    for trait,price in spairs(PriceList.traitfee[aw], isort) do
      local pr = OT.GDP(PriceList, HotepCraft.neworder.order, price)
      table.insert(choices, zo_strformat("<<1>> (add <<2>>g)", trait, pr))
      table.insert(values, trait)
    end
    
    if (HotepCraft.neworder.params.old_aw ~= aw) then
      HotepCraft.neworder.params.item.trait = false
    end
  end
  
  HotepCraft_UI_entry_TraitDropdown:UpdateChoices(choices, values)
  HotepCraft_UI_entry_TraitDropdown:UpdateValue()
end


function HotepCraft.UIEntry_UpdateEnchantChoices(itemtype)
  
  local choices = {"No Enchant"}
  local values = {0}
  
  local lev = HotepCraft.neworder.order.level
  
  if (itemtype and (itemtype ~= "") and lev and (lev ~= OT.RESEARCH_LEVEL)) then
    local aw = OT.ARM_WEAP(itemtype)
    
    local glyphs = OT.GLYPHS(aw)
    
    for i,name in pairs(glyphs) do
      local fee = OT.GetEnchantFee(PriceList, itemtype, HotepCraft.neworder.order.level, i)
      fee = OT.GDP(PriceList, HotepCraft.neworder.order, fee)
      table.insert(choices, zo_strformat("<<1>> (add <<2>>g)", name, fee))
      table.insert(values, i)
    end
    
    if (HotepCraft.neworder.params.old_aw ~= aw) then
      HotepCraft.neworder.params.item.enchant = 0
    end
  end
  
  HotepCraft_UI_entry_EnchantDropdown:UpdateChoices(choices, values)
  HotepCraft_UI_entry_EnchantDropdown:UpdateValue()
  HotepCraft_UI_entry_EnchantDropdown:SetHidden((lev == OT.RESEARCH_LEVEL))
end


---
-- @param item @class ITEM
-- @return @class nil
function HotepCraft.UIEntry_UpdateQualChoices(item)
  
  local colors = {
    COLOR_GREEN,
    COLOR_BLUE,
    COLOR_PURPLE,
    COLOR_YELLOW,
  }
  
  local choices = {"Normal/white"}
  local values = {0}
  
  local lev = HotepCraft.neworder.order.level
  
  if (item.itemtype and (item.itemtype ~= "") and lev and (lev ~= OT.RESEARCH_LEVEL) and (item.profession > 0)) then
    local qualnames = OT.PIECES("improve")
    
    for q,qname in ipairs(qualnames) do
      local fee = OT.GetTotalImproveFee(PriceList.improvefees, item.profession, q, HotepCraft.improvQty)
      fee = OT.GDP(PriceList, HotepCraft.neworder.order, fee)
      table.insert(choices, zo_strformat("<<1>><<2>> (add <<3>>g)|r", colors[q], qname, fee))
      table.insert(values, q)
    end
  end
  
  HotepCraft_UI_entry_QualityDropdown:UpdateChoices(choices, values)
  HotepCraft_UI_entry_QualityDropdown:UpdateValue()
  HotepCraft_UI_entry_QualityDropdown:SetHidden((lev == OT.RESEARCH_LEVEL))
end





function HotepCraft.UIEntry_CreateDropdowns()
  
  HotepCraft_UI_entry.data = {}
  
  -- choose Level
  
  local levelchoices = {"Any Level (for research)"}
  local levelmap = {}
  local reversemap = {}
  
  levelmap["Any Level (for research)"] = OT.RESEARCH_LEVEL
  reversemap[OT.RESEARCH_LEVEL] = "Any Level (for research)"
  
  local oldlev = 0
  for i = 1,66 do
    local lev, ret = OT.LEVELS(i, "level", true)
    if (lev > oldlev) then
      oldlev = lev
      table.insert(levelchoices, ret)
      levelmap[ret] = lev
      reversemap[lev] = ret
    end
  end
  
  
  local leveldata = {
    type = "dropdown",
    name = "",
    choices = levelchoices,
    getFunc = function () return reversemap[HotepCraft.neworder.order.level] end,
    setFunc = function (n) HotepCraft.UIEntry_LevelUpdate(levelmap[n]) end,
    reference = "HotepCraft_UI_entry_LevelDropdown",
    scrollable = 15,
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, leveldata)
  
  HotepCraft_UI_entry_LevelDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseLevel, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_LevelDropdown:SetWidth(600)
  HotepCraft_UI_entry_LevelDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_LevelDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Item
  
  local itemchoices, itemchoicesvalues = HotepCraft.UIEntry_GenerateItemChoices()
  
  local itemdata = {
    type = "dropdown",
    name = "",
    choices = itemchoices,
    choicesValues = itemchoicesvalues,
    getFunc = function ()
                return zo_strformat("<<1>>;<<2>>", HotepCraft.neworder.params.item.itemtype, HotepCraft.neworder.params.item.item)
              end,
    setFunc = function (n) HotepCraft.UIEntry_ItemUpdate(n) end,
    reference = "HotepCraft_UI_entry_ItemDropdown",
    scrollable = 15,
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, itemdata)
  
  HotepCraft_UI_entry_ItemDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseItem, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_ItemDropdown:SetWidth(600)
  HotepCraft_UI_entry_ItemDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_ItemDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Quality
  
  local qualdata = {
    type = "dropdown",
    name = "",
    choices = {"Normal/white"},
    choicesValues = {0},
    getFunc = function () return HotepCraft.neworder.params.item.improvement end,
    setFunc = function (n) HotepCraft.neworder.params.item.improvement = n end,
    reference = "HotepCraft_UI_entry_QualityDropdown",
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, qualdata)
  
  HotepCraft_UI_entry_QualityDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseQuality, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_QualityDropdown:SetWidth(600)
  HotepCraft_UI_entry_QualityDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_QualityDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Style
  
  local stylechoices, stylevalues = HotepCraft.UIEntry_GenerateStyleChoices()
  
  local styledata = {
    type = "dropdown",
    name = "",
    choices = stylechoices,
    choicesValues = stylevalues,
    getFunc = function () return HotepCraft.neworder.params.item.style end,
    setFunc = function (n) HotepCraft.neworder.params.item.style = n end,
    reference = "HotepCraft_UI_entry_StyleDropdown",
    scrollable = 15,
    tooltip = "Entries in |cff00ffPurple|r are styles that you |cffffffDO NOT SELL|r",
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, styledata)
  
  HotepCraft_UI_entry_StyleDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseStyle, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_StyleDropdown:SetWidth(600)
  HotepCraft_UI_entry_StyleDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_StyleDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Set
  
  local setchoices, setvalues = HotepCraft.UIEntry_GenerateSetChoices()
  
  local tt1 = "Entries in |cff00ffPurple|r are sets that you |cffff00DO NOT SELL|r\n"
  local tt2 = "Entries in |cff6633Brown|r are sets that |cff0000REQUIRE A DLC|r"
  
  local setdata = {
    type = "dropdown",
    name = "",
    choices = setchoices,
    choicesValues = setvalues,
    getFunc = function () return HotepCraft.neworder.params.item.set end,
    setFunc = function (n) HotepCraft.neworder.params.item.set = n end,
    reference = "HotepCraft_UI_entry_SetDropdown",
    scrollable = 10,
    tooltip = tt1 .. tt2,
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, setdata)
  
  HotepCraft_UI_entry_SetDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseSet, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_SetDropdown:SetWidth(600)
  HotepCraft_UI_entry_SetDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_SetDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Trait
  
  local traitdata = {
    type = "dropdown",
    name = "",
    choices = {"No Trait"},
    choicesValues = {false},
    getFunc = function ()
                if (not HotepCraft.neworder.params.item.trait) then
                  return "No Trait"
                else
                  return HotepCraft.neworder.params.item.trait
                end
              end,
    setFunc = function (n)
                if (n == "No Trait") then
                  HotepCraft.neworder.params.item.trait = false
                else
                  HotepCraft.neworder.params.item.trait = n
                end
              end,
    reference = "HotepCraft_UI_entry_TraitDropdown",
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, traitdata)
  
  HotepCraft_UI_entry_TraitDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseTrait, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_TraitDropdown:SetWidth(600)
  HotepCraft_UI_entry_TraitDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_TraitDropdown.combobox:SetDrawTier(2)
  
  
  -- choose Enchant
  
  local enchdata = {
    type = "dropdown",
    name = "",
    choices = {"No Enchant"},
    choicesValues = {0},
    getFunc = function () return HotepCraft.neworder.params.item.enchant end,
    setFunc = function (n) HotepCraft.neworder.params.item.enchant = n end,
    reference = "HotepCraft_UI_entry_EnchantDropdown",
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, enchdata)
  
  HotepCraft_UI_entry_EnchantDropdown:SetAnchor(TOPLEFT, HotepCraft_UI_entry_ChooseEnchant, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_EnchantDropdown:SetWidth(600)
  HotepCraft_UI_entry_EnchantDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_EnchantDropdown.combobox:SetDrawTier(2)
  
  
  -- order type
  
  local typesdata = {
    type = "dropdown",
    name = "",
    choices = {"Paid Order", "Free Gift", "Paid Order No Deposit"},
    choicesValues = {1, 0, 2},
    getFunc = function ()
                if (HotepCraft.neworder.free) then
                  return 0
                elseif (HotepCraft.neworder.order.NODEPOSIT) then
                  return 2
                else
                  return 1
                end
              end,
    setFunc = function (n)
       HotepCraft.neworder.free = (n == 0)
       HotepCraft.neworder.order.NODEPOSIT = (n == 2)
       HotepCraft.UIEntry_CustomerUpdate()
    end,
    reference = "HotepCraft_UI_entry_OrderTypeDropdown",
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_entry, typesdata)
  
  HotepCraft_UI_entry_OrderTypeDropdown.combobox:SetAnchor(TOPLEFT, HotepCraft_UI_entry_Customer, TOPRIGHT, 5, 0)
  HotepCraft_UI_entry_OrderTypeDropdown.combobox:SetWidth(200)
  HotepCraft_UI_entry_OrderTypeDropdown:SetDrawTier(2)
  HotepCraft_UI_entry_OrderTypeDropdown.combobox:SetDrawTier(2)
  
end
-- end HotepCraft.UIEntry_CreateDropdowns()


function HotepCraft.Books_CreateDropdowns()
  
  HotepCraft_UI_costs.data = {}
  
  ---@local allmats @classdef AllMatList
  local allmats = {
    items = {},        -- simple array of matnames
    traits = {},
    styles = {},
    improves = {},
    potents = {},
    essances = {},
    motifs = {},
  }
  
  local MatIndex = {
    items = 1,
    traits = 2,
    styles = 3,
    improves = 4,
    potents = 5,
    essances = 6,
    motifs = 7,
  }
  
  
  for _,mat in spairs(OT.METALS()) do
    table.insert(allmats.items, mat.matname)
  end
  
  for _,mat in spairs(OT.LCLOTHS()) do
    table.insert(allmats.items, mat.matname)
  end
  
  for _,mat in spairs(OT.MCLOTHS()) do
    table.insert(allmats.items, mat.matname)
  end
  
  for _,mat in spairs(OT.WOODS()) do
    table.insert(allmats.items, mat.matname)
  end
  
  for _,mat in spairs(ARM_TRAITS, eyesort) do
    table.insert(allmats.traits, mat.jewel)
  end
  
  for _,mat in spairs(WEP_TRAITS, eyesort) do
    table.insert(allmats.traits, mat.jewel)
  end
  
  for _,mat in ipairs(OT.MOTIFS("all")) do
    table.insert(allmats.styles, mat.mat)
    table.insert(allmats.motifs, mat.name .. " Book or Chapter")
  end
  
  for _,prof in ipairs(PROFESSIONS) do
     for _,mat in ipairs(RESINS[prof]) do
       table.insert(allmats.improves, mat)
     end
  end
  
  for _,mat in spairs(POTENCY) do
    table.insert(allmats.potents, mat['+'])
    table.insert(allmats.potents, mat['-'])
  end
  
  for _,mat in ipairs(OT.ENCHANTS("weapon")) do
    table.insert(allmats.essances, mat.rune)
  end
  
  for _,mat in ipairs(OT.ENCHANTS("armor")) do
    if (not in_array(mat.rune, allmats.essances)) then
      table.insert(allmats.essances, mat.rune)
    end
  end
  
  
  local MatTypes = {
    items = "Base Mat:",
    traits = "Trait Mat:",
    styles = "Style Mat:",
    improves = "Improvement Mat:",
    potents = "Potency Rune:",
    essances = "Essence Rune:",
    motifs = "Motif Book/Chapter:",
  }
  
  
  local allmatchoices = {}
  local allmatvalues = {}
  
  local matsort = function(t, a, b)
    return (MatIndex[a] < MatIndex[b])
  end
  
  for mattype,mats in spairs(allmats, matsort) do
    table.insert(allmatchoices, zo_strformat("<<1>><<2>>|r", COLOR_YELLOW, MatTypes[mattype]))
    table.insert(allmatvalues, "-;-")
    local matts = clone(mats)
    table.sort(matts)
    for _,matname in ipairs(matts) do
      table.insert(allmatchoices, zo_strformat("<<1>><<2>>|r", COLOR_WHITE, matname))
      table.insert(allmatvalues, zo_strformat("<<1>>;<<2>>", mattype, matname))
    end
  end
  
  
  local update = function(field, textfield, form)
    if (not textfield) then
      textfield = field
    end
    
    field = "HotepCraft_UI_costs_" .. field
    
    local txt = HotepCraft.EDITPURCHASE[textfield]
    
    if (textfield == "mattypename") then
      txt = MatTypes[txt]
    elseif ((textfield == "costPer") or (textfield == "total")) then
      txt = commas(txt)
    end
    
    local control = _G[field]
    
    if (form) then
      txt = zo_strformat(form, txt)
    end
    
    control:SetText(zo_strformat("<<1>><<2>>|r", COLOR_YELLOW, txt))
  end
  -- end local function update
  
  
  -- Material Purchased
  
  local widgetdata = {
    type = "dropdown",
    name = "",
    choices = allmatchoices,
    choicesValues = allmatvalues,
    getFunc = function () return zo_strformat("<<1>>;<<2>>", HotepCraft.EDITPURCHASE.mattypename, HotepCraft.EDITPURCHASE.matname) end,
    setFunc = function (n)
      if (n == "-;-") then
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        HotepCraft_UI_costs_MatnameDropdown:UpdateValue()
        return
      end
      local x = explode(";", n)
      HotepCraft.EDITPURCHASE.mattypename = x[1]
      HotepCraft.EDITPURCHASE.mattype = MatIndex[x[1]]
      HotepCraft.EDITPURCHASE.matname = x[2]
      update("mattype", "mattypename")
      update("matname")
    end,
    reference = "HotepCraft_UI_costs_MatnameDropdown",
    scrollable = 20,
    disabled = false,
  }
  
  LAMCreateControl.dropdown(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_MatnameDropdown.combobox:SetAnchor(TOPLEFT, HotepCraft_UI_costs_MatnameLabel, TOPRIGHT, 5, 0)
  HotepCraft_UI_costs_MatnameDropdown.combobox:SetWidth(300)
  HotepCraft_UI_costs_MatnameDropdown:SetDrawTier(2)
  HotepCraft_UI_costs_MatnameDropdown.combobox:SetDrawTier(2)
  HotepCraft_UI_costs_MatnameDropdown:SetHidden(true)
  
  
  
  -- Quantity Purchased
  
  local widgetdata = {
    type = "slider",
    name = "",
    min = 0,
    max = 200,
    step = 1,
    decimals = 0,
    getFunc = function () return HotepCraft.EDITPURCHASE.qty or 1 end,
    setFunc = function (n)
      HotepCraft.EDITPURCHASE.qty = n
      HotepCraft.EDITPURCHASE.total = math.ceil(HotepCraft.EDITPURCHASE.costPer * HotepCraft.EDITPURCHASE.qty)
      update("qty", nil, "qty: <<1>>")
      update("costPer", nil, "<<1>>g ea.")
      update("total", nil, "<<1>>g total")
    end,
    autoSelect = true,
    tooltip = function()
                if (HotepCraft.EDITPURCHASE.idx) then
                  return "Set to 0 to Delete This Purchase Record."
                else
                  return nil
                end
              end,
    reference = "HotepCraft_UI_costs_QtySlider",
  }
  
  LAMCreateControl.slider(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_QtySlider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_QtyLabel, TOPRIGHT, 5, 0)
  HotepCraft_UI_costs_QtySlider:SetWidth(500)
  HotepCraft_UI_costs_QtySlider.slider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_QtyLabel, TOPRIGHT, 5, 0)
  HotepCraft_UI_costs_QtySlider.slider:SetWidth(500)
  HotepCraft_UI_costs_QtySlider:SetHidden(true)
  
  
  local updt1 = function()
    HotepCraft_UI_costs_CostSlider1:UpdateValue()
  end
  
  local updt2 = function()
    HotepCraft_UI_costs_CostSlider2:UpdateValue()
  end
  
  
  -- Cost Per Each
  
  local widgetdata = {
    type = "slider",
    name = "",
    min = 0,
    max = 990000,
    step = 10000,
    decimals = 0,
    getFunc = function ()
      if (HotepCraft.EDITPURCHASE.costPer) then
        return math.floor(HotepCraft.EDITPURCHASE.costPer / 10000) * 10000
      else
        return 0
      end
    end,
    setFunc = function (n)
      if (not n) then return end
      n = math.floor(n / 10000) * 10000
      if (HotepCraft.EDITPURCHASE.costPer) then
        HotepCraft.EDITPURCHASE.costPer = math.fmod(HotepCraft.EDITPURCHASE.costPer, 10000) + n
      else
        HotepCraft.EDITPURCHASE.costPer = n
      end
      HotepCraft.EDITPURCHASE.total = math.ceil(HotepCraft.EDITPURCHASE.costPer * (HotepCraft.EDITPURCHASE.qty or 1))
      update("costPer", nil, "<<1>>g ea.")
      update("total", nil, "<<1>>g total")
      zo_callLater(updt1, 500)
    end,
    autoSelect = true,
    tooltip = "Use this slider to set cost to the nearest 10,000g",
    reference = "HotepCraft_UI_costs_CostSlider1",
  }
  
  LAMCreateControl.slider(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_CostSlider1:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 0, 0)
  HotepCraft_UI_costs_CostSlider1:SetWidth(300)
  HotepCraft_UI_costs_CostSlider1.slider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 0, 0)
  HotepCraft_UI_costs_CostSlider1.slider:SetWidth(300)
  HotepCraft_UI_costs_CostSlider1:SetHidden(true)
  
  
  local widgetdata = {
    type = "slider",
    name = "",
    min = 0,
    max = 9900,
    step = 100,
    decimals = 0,
    getFunc = function ()
      if (HotepCraft.EDITPURCHASE.costPer) then
        return math.fmod(HotepCraft.EDITPURCHASE.costPer, 10000) - math.fmod(HotepCraft.EDITPURCHASE.costPer, 100)
      else
        return 0
      end
    end,
    setFunc = function (n)
      if (not n) then return end
      n = math.floor(n / 100) * 100
      if (HotepCraft.EDITPURCHASE.costPer) then
        HotepCraft.EDITPURCHASE.costPer = (math.floor(HotepCraft.EDITPURCHASE.costPer / 10000) * 10000) + math.fmod(HotepCraft.EDITPURCHASE.costPer, 100) + n
      else
        HotepCraft.EDITPURCHASE.costPer = n
      end
      HotepCraft.EDITPURCHASE.total = math.ceil(HotepCraft.EDITPURCHASE.costPer * HotepCraft.EDITPURCHASE.qty)
      update("costPer", nil, "<<1>>g ea.")
      update("total", nil, "<<1>>g total")
      zo_callLater(updt2, 500)
    end,
    autoSelect = true,
    tooltip = "Use this slider to set cost to the nearest 100g",
    reference = "HotepCraft_UI_costs_CostSlider2",
  }
  
  LAMCreateControl.slider(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_CostSlider2:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 305, 0)
  HotepCraft_UI_costs_CostSlider2:SetWidth(300)
  HotepCraft_UI_costs_CostSlider2.slider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 305, 0)
  HotepCraft_UI_costs_CostSlider2.slider:SetWidth(300)
  HotepCraft_UI_costs_CostSlider2:SetHidden(true)
  
  
  local widgetdata = {
    type = "slider",
    name = "",
    min = 0,
    max = 99.99,
    step = 0.01,
    decimals = 2,
    getFunc = function ()
      if (HotepCraft.EDITPURCHASE.costPer) then
        return math.fmod(HotepCraft.EDITPURCHASE.costPer, 100)
      else
        return 0
      end
    end,
    setFunc = function (n)
      if (HotepCraft.EDITPURCHASE.costPer) then
        HotepCraft.EDITPURCHASE.costPer = (math.floor(HotepCraft.EDITPURCHASE.costPer / 100) * 100.0000) + n
      else
        HotepCraft.EDITPURCHASE.costPer = n
      end
      HotepCraft.EDITPURCHASE.total = math.ceil(HotepCraft.EDITPURCHASE.costPer * HotepCraft.EDITPURCHASE.qty)
      update("costPer", nil, "<<1>>g ea.")
      update("total", nil, "<<1>>g total")
    end,
    autoSelect = true,
    tooltip = "Use this slider to set cost to the nearest 0.01g",
    reference = "HotepCraft_UI_costs_CostSlider3",
  }
  
  LAMCreateControl.slider(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_CostSlider3:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 610, 0)
  HotepCraft_UI_costs_CostSlider3:SetWidth(460)
  HotepCraft_UI_costs_CostSlider3.slider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_CostPerLabel, TOPRIGHT, 610, 0)
  HotepCraft_UI_costs_CostSlider3.slider:SetWidth(460)
  HotepCraft_UI_costs_CostSlider3:SetHidden(true)
  
  
  
  -- Days Ago Purchased
  
  local widgetdata = {
    type = "slider",
    name = "",
    min = 0,
    max = 365,
    step = 1,
    decimals = 0,
    getFunc = function () return math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(), (HotepCraft.EDITPURCHASE.when or GetTimeStamp())) / (24 * 3600)) end,
    setFunc = function (n)
      HotepCraft.EDITPURCHASE.when = math.floor(GetTimeStamp() - (n * 24 * 3600))
      local _
      HotepCraft.EDITPURCHASE.formattedWhen, _ = FormatAchievementLinkTimestamp(HotepCraft.EDITPURCHASE.when)
      update("when", "formattedWhen", "Purchased: <<1>>")
    end,
    autoSelect = true,
    reference = "HotepCraft_UI_costs_WhenSlider",
  }
  
  LAMCreateControl.slider(HotepCraft_UI_costs, widgetdata)
  
  HotepCraft_UI_costs_WhenSlider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_WhenLabel, TOPRIGHT, 5, 0)
  HotepCraft_UI_costs_WhenSlider:SetWidth(500)
  HotepCraft_UI_costs_WhenSlider.slider:SetAnchor(TOPLEFT, HotepCraft_UI_costs_WhenLabel, TOPRIGHT, 5, 0)
  HotepCraft_UI_costs_WhenSlider.slider:SetWidth(500)
  HotepCraft_UI_costs_WhenSlider:SetHidden(true)
  
end
-- end HotepCraft.Books_CreateDropdowns()



HotepCraft.WayshrineKeybind = {
  active = false,
}


HotepCraft.WayshrineKeybind.Button = {
  name = "",
	keybind = "HOTEPCRAFT_WAYSHRINE",
	callback = HotepCraft.JumpToCraftingWayshrine,
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
}




function HotepCraft.UIAddKeybindWayshrine(show)
  if (show) then
    
    local set = HotepCraft.CanJumpToCraftingWayshrine()
    
    if (not set) then return false end
    
    ---@local setrec @class SETREC
    local setrec = OT.ARM_SETS(set)
    
    HotepCraft.WayshrineKeybind.Button.name = setrec.name
    HotepCraft.WayshrineKeybind.active = true
    
    KEYBIND_STRIP:AddKeybindButton(HotepCraft.WayshrineKeybind.Button)
  else
    HotepCraft.WayshrineKeybind.active = false
    KEYBIND_STRIP:RemoveKeybindButton(HotepCraft.WayshrineKeybind.Button)
  end
end



function HotepCraft.CancelChatOrder(yes)
  SCENE_MANAGER:HideTopLevel(HotepCraft_UI_Timeout)
  
  if (not yes) then
    HotepCraft.busy = false
    HotepCraft.OrderTimeOut()
    local msgs = {'Ordering Session Timed Out. To start another order, whisper "order".'}
    savedVariables:AppendChatLog(msgs)
    ChatQueue:New(7, "wisp", HotepCraft.neworder.order.customer, nil, nil, msgs)
  elseif (timer_ordertimeout) then
    timer_ordertimeout:Start(CHAT_ORDERING_TIMEOUT)
  else
    timer_ordertimeout = Timer:New(CHAT_ORDERING_TIMEOUT, HotepCraft.OrderTimeOut)
  end
end



function HotepCraft.InitUIWindows()
  
  HotepCraft.UI_OrdersList = UI_OrdersList:New(HotepCraft_UI_main)
  HotepCraft.UI_CostsList = UI_CostsList:New(HotepCraft_UI_costs)
  
  local title = "|c3366ffHotep\194\174|r |cff6633Crafting Freelancer|r"
  
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_main, false)
  HotepCraft_UI_main:SetDrawTier(2)
  HotepCraft_UI_main_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_order, false)
  HotepCraft_UI_order:SetDrawTier(2)
  HotepCraft_UI_order_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_Smithing, false)
  HotepCraft_UI_Smithing:SetDrawTier(2)
  HotepCraft_UI_Smithing_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_entry, false)
  HotepCraft_UI_entry:SetDrawTier(2)
  HotepCraft_UI_entry_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_Timeout, false)
  HotepCraft_UI_Timeout:SetDrawTier(2)
  HotepCraft_UI_Timeout_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_ChatError, false)
  HotepCraft_UI_ChatError:SetDrawTier(2)
  HotepCraft_UI_ChatError_WindowTitle:SetText(title)
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_costs, false)
  HotepCraft_UI_costs:SetDrawTier(2)
  HotepCraft_UI_costs_WindowTitle:SetText(title)
  
  
  HotepCraft_UI_main_Button_Books.tooltipText = "Click here to open the Purchasing History"
  HotepCraft_UI_main_OrderListHelp.tooltipText = ""
  
  local qm = "|c0066ff|t30:30:esoui/art/menubar/menubar_help_up.dds|t|r"
  
  HotepCraft_UI_costs_CostPerLabel:SetText("Cost Per Each:     " .. qm)
  
  
  HotepCraft_UI_mule_WindowTitle:SetText(title)
  HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>Scanning your backpack. Please don't log off!|r", COLOR_YELLOW))
  HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Progress: 0%|r", COLOR_YELLOW))
  HotepCraft_UI_mule_Progress:SetHidden(false)
  HotepCraft_UI_mule_container:SetHidden(true)
  HotepCraft_UI_mule_Button_Close:SetHidden(true)
  HotepCraft_UI_mule:SetDimensionConstraints(600, 120, 600, 120)
  HotepCraft_UI_mule:SetHeight(120)
  
  if (Settings.UIMuleWindowX_crafter) then
    HotepCraft_UI_mule:ClearAnchors()
    HotepCraft_UI_mule:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Settings.UIMuleWindowX_crafter, Settings.UIMuleWindowY_crafter)
  end
  
  
  HotepCraft.UIEntry_CreateDropdowns()
  HotepCraft.EDITPURCHASE = {
    mattype = 0,
    mattypename = "",
    matname = "",
    qty = 1,
    qtyUsed = 0,
    when = GetTimeStamp(),
    costPer = 0,
  }
  HotepCraft.Books_CreateDropdowns()
  
  if (Settings.UISmithingWindowX) then
    HotepCraft_UI_Smithing:ClearAnchors()
    HotepCraft_UI_Smithing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Settings.UISmithingWindowX, Settings.UISmithingWindowY)
  end
  
  HotepCraft.MainMenuSwitch(ORDER_STATUS_WAITING)
end
-- end HotepCraft.InitUIWindows()


function HotepCraft.InitUIWindows_Mule()
  
  local title = "|c3366ffHotep\194\174|r |cff6633Crafting Freelancer|r"
  
  SCENE_MANAGER:RegisterTopLevel(HotepCraft_UI_mule, false)
  HotepCraft_UI_mule:SetDrawTier(2)
  HotepCraft_UI_mule_WindowTitle:SetText(title)
  HotepCraft_UI_mule_Progress:SetHidden(true)
  
  if (Settings.UIMuleWindowX) then
    HotepCraft_UI_mule:ClearAnchors()
    HotepCraft_UI_mule:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Settings.UIMuleWindowX, Settings.UIMuleWindowY)
  end
  if (Settings.UIMuleWindowW) then
    HotepCraft_UI_mule:SetWidth(Settings.UIMuleWindowW)
    HotepCraft_UI_mule:SetHeight(Settings.UIMuleWindowH)
    HotepCraft_UI_mule_TopDivider:SetWidth(Settings.UIMuleWindowW + 240)
    HotepCraft_UI_mule_container:SetWidth(Settings.UIMuleWindowW - 20)
    HotepCraft_UI_mule_container:SetHeight(Settings.UIMuleWindowH - 40)
  end
end
-- end HotepCraft.InitUIWindows_Mule()


--function HotepCraft.UI_order_Tier(up)
--  if (up) then
--    HotepCraft_UI_order:SetDrawTier(2)
--    HotepCraft_UI_order_Button_DrawDown:SetHidden(false)
--    HotepCraft_UI_order_Button_DrawUp:SetHidden(true)
--  else
--    HotepCraft_UI_order:SetDrawTier(1)
--    HotepCraft_UI_order_Button_DrawDown:SetHidden(true)
--    HotepCraft_UI_order_Button_DrawUp:SetHidden(false)
--  end
--end

function HotepCraft.Window_Tier_Toggle(control)
  
  local uptex = "/HotepCraftingFreelancer/plusup.dds"
  local downtex = "/HotepCraftingFreelancer/minusdown.dds"
  
  local tlw = control:GetOwningWindow()
  local tier = tlw:GetDrawTier()
  
  if (tier == 2) then
    tlw:SetDrawTier(0)
    tlw:SetDrawLevel(0)
    tlw:SetDrawLayer(0)
    control:SetNormalTexture(uptex)
  else
    tlw:SetDrawTier(2)
    control:SetNormalTexture(downtex)
  end
end
-- end HotepCraft.Window_Tier_Toggle(control)



function HotepCraft.SaveUISmithingWindowPosition()
  Settings.UISmithingWindowX = HotepCraft_UI_Smithing:GetLeft()
  Settings.UISmithingWindowY = HotepCraft_UI_Smithing:GetTop()
end

function HotepCraft.SaveUIMuleWindowPosition()
  if (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_MULE) then
    Settings.UIMuleWindowX = HotepCraft_UI_mule:GetLeft()
    Settings.UIMuleWindowY = HotepCraft_UI_mule:GetTop()
  elseif (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_CRAFTER) then
    Settings.UIMuleWindowX_crafter = HotepCraft_UI_mule:GetLeft()
    Settings.UIMuleWindowY_crafter = HotepCraft_UI_mule:GetTop()
  end
end

function HotepCraft.SaveUIMuleWindowSize()
  
  if (Settings.characters[HotepCraft.mycharacter] ~= CHAR_TYPE_MULE) then return end
  
  Settings.UIMuleWindowW = HotepCraft_UI_mule:GetWidth()
  Settings.UIMuleWindowH = HotepCraft_UI_mule:GetHeight()
  HotepCraft_UI_mule_TopDivider:SetWidth(Settings.UIMuleWindowW + 240)
  HotepCraft_UI_mule_container:SetWidth(Settings.UIMuleWindowW - 20)
  HotepCraft_UI_mule_container:SetHeight(Settings.UIMuleWindowH - 40)
  HotepCraft_UI_mule_container:SetHidden(HotepCraft_UI_mule.LISTHIDDEN)
  HotepCraft_UI_mule.LISTHIDDEN = nil
  HotepCraft.InitMuleWindow(true)
end



function HotepCraft.SlashCancel()
  
  if (not HotepCraft.busy) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are not taking an order|r", COLOR_RED))
    HotepCraft.OrderTimeOut()
    return true
  end
  
  HotepCraft.busy = false
  if (HotepCraft.OrderTimeOut()) then
    msgWithName("Chat ordering canceled.", COLOR_PURPLE)
    local msgs = {'Ordering Session Canceled. To start another order, whisper "order".'}
    ChatQueue:New(7, "wisp", HotepCraft.neworder.order.customer, nil, nil, msgs)
  else
    msgWithName("Price Request canceled.", COLOR_PURPLE)
  end
  return true
end

function HotepCraft.SlashDND()
  disturbme = (not disturbme)
  
  if (HotepCraft_LAM_DND_Checkbox) then
    HotepCraft_LAM_DND_Checkbox:UpdateValue()
  end
  
  local onoff = "OFF"
  local color = COLOR_GREEN
  if (not disturbme) then
    onoff = "ON"
    color = COLOR_RED
  end
  
  msgWithName(zo_strformat("<<1>>Do Not Disturb is|r <<2>><<3>>|r", COLOR_MSG, color, onoff), false)
  
  return true
end

function HotepCraft.SlashRePrompt()
  if (not HotepCraft.SavedChat) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>There is no saved chat prompt|r", COLOR_RED))
    return true
  end
  
  HotepCraft.ChatWithErrorChecking(HotepCraft.SavedChat.timeout, HotepCraft.SavedChat.channel, 
                                  HotepCraft.SavedChat.handle, HotepCraft.SavedChat.callback, 
                                  HotepCraft.SavedChat.failback, HotepCraft.SavedChat.msgs)
  
  return true
end

function HotepCraft.SlashReAnswer()
  if (#HotepCraft.SavedRequests == 0) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>There are no saved requests|r", COLOR_RED))
    return true
  end
  
  if (HotepCraft.busy) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are already busy|r", COLOR_RED))
    return true
  end
  
  ---@local saved @class SAVEDREQUEST
  local saved = table.remove(HotepCraft.SavedRequests, 1)
  
  HotepCraft:OnGotChat(saved.handle, saved.request)
  
  return true
end

function HotepCraft.SlashForcePrice()
  local channel = CHAT_SYSTEM.currentChannel
  local handle = CHAT_SYSTEM.currentTarget
  
  if (HotepCraft.busy) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are already busy|r", COLOR_RED))
    return true
  end
  
  if ((channel ~= CHAT_CHANNEL_WHISPER) or not handle) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are not whispering|r", COLOR_RED))
    return true
  end
  
  HotepCraft.SendPriceList(handle, "price")
  return true
end

function HotepCraft.SlashForceOrder()
  local channel = CHAT_SYSTEM.currentChannel
  local handle = CHAT_SYSTEM.currentTarget
  
  if (HotepCraft.busy) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are already busy|r", COLOR_RED))
    return true
  end
  
  if ((channel ~= CHAT_CHANNEL_WHISPER) or not handle) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are not whispering|r", COLOR_RED))
    return true
  end
  
  HotepCraft:OnGotChat(handle, "order")
  return true
end


function HotepCraft.SlashForceInfo()
  local channel = CHAT_SYSTEM.currentChannel
  local handle = CHAT_SYSTEM.currentTarget
  
  if ((channel ~= CHAT_CHANNEL_WHISPER) or not handle) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>You are not whispering|r", COLOR_RED))
    return true
  end
  
  HotepCraft:OnGotChat(handle, "info")
  return true
end



function HotepCraft.SlashHelp()
  msgWithName(zo_strformat("<<1>>/hotep cancel|r <<2>>= cancel the current chat order|r", COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat("<<1>>/hotep dnd|r <<2>>= toggle Do Not Disturb mode|r", COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat("<<1>>/hotep repeat|r <<2>>= repeat last prompt during chat ordering|r", COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat('<<1>>/hotep respond|r <<2>>= respond to the last ignored "price" or "order" request|r', COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat('<<1>>/hotep forceprice|r <<2>>= act as if player you are currently whispering to said "price"|r', COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat('<<1>>/hotep forceorder|r <<2>>= act as if player you are currently whispering to said "order"|r', COLOR_GREEN, COLOR_MSG), false)
  msgWithName(zo_strformat('<<1>>/hotep forceinfo|r <<2>>= act as if player you are currently whispering to said "info"|r', COLOR_GREEN, COLOR_MSG), false)
  return true
end



-- ****************************************************************************
--                              event handling
-- ****************************************************************************


function HotepCraft.TookAttachedItemsFromMail()
  HotepCraft.MAILITEMSTAKEN = true
end

function HotepCraft.MailBoxClosed()
  ScanningMail = "close"
  HotepCraft.NextScannedMail()
  
  if (HotepCraft.MAILITEMSTAKEN) then
    HotepCraft.MAILITEMSTAKEN = false
    HotepCraft.ScanCrafterBackpack()
  end
end

function HotepCraft.BoughtSomethingFromVendor(eventCode, entryName, entryType)
  if (entryType == STORE_ENTRY_TYPE_ITEM) then
    HotepCraft.BOUGHTSOMETHING = true
  end
end

function HotepCraft.VendorClosed()
  if (HotepCraft.BOUGHTSOMETHING) then
    HotepCraft.BOUGHTSOMETHING = false
    HotepCraft.ScanCrafterBackpack()
  end
end

--function HotepCraft.GotSomeLoot(eventCode, receivedBy, itemName, quantity, soundCategory, lootType)
--  if (lootType == LOOT_TYPE_ITEM) then
--    HotepCraft.LOOTED = true
--  end
--end
--
--function HotepCraft.LootClosed()
--  if (HotepCraft.LOOTED) then
--    HotepCraft.LOOTED = false
--    HotepCraft.ScanCrafterBackpack()
--  end
--end

function HotepCraft.KioskClosed()
  HotepCraft.ScanCrafterBackpack()
end



function HotepCraft.CleanUpOnAisleM()
  local n = #CurrentClaim.WaitingForMats
  local i = 1
  while (i <= n) do
    ---@local order @class ORDER
    local order = HotepCraft.ReturnOrderByUUID(CurrentClaim.WaitingForMats[i].orderuuid)
    if (order and (order.Status ~= ORDER_STATUS_DELIVERED)) then
      i = i + 1
    else
      table.remove(CurrentClaim.WaitingForMats, i)
      n = n - 1
    end
  end
end



function HotepCraft.CleanUpOnAisleD()
  local n = #CurrentClaim.WaitingForDeposit
  local i = 1
  while (i <= n) do
    ---@local order @class ORDER
    local order = HotepCraft.ReturnOrderByUUID(CurrentClaim.WaitingForDeposit[i].orderuuid)
    if (order and (order.Status ~= ORDER_STATUS_DELIVERED)) then
      i = i + 1
    else
      table.remove(CurrentClaim.WaitingForDeposit, i)
      n = n - 1
    end
  end
end



---
-- @param mattrades @class MatTrades    order.MatTrades
-- @param itemLink @class string        itemLink to match
-- @return @class MatTradeRec
-- @return @class table    {key, index}
function HotepCraft.MatchMatTrade(mattrades, itemLink)
  --/script d(GetItemLinkItemType(""))
  --/script d(GetItemLinkTraitInfo(""))
  --/script d(GetItemLinkName(""))
  
  local keys = {
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = "items",
    [ITEMTYPE_CLOTHIER_MATERIAL] = "items",
    [ITEMTYPE_WOODWORKING_MATERIAL] = "items",
    [ITEMTYPE_ARMOR_TRAIT] = "traits",
    [ITEMTYPE_WEAPON_TRAIT] = "traits",
    [ITEMTYPE_STYLE_MATERIAL] = "styles",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "improves",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "improves",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "improves",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "potents",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "essances",
  }
  
  
  local itemType, _ = GetItemLinkItemType(itemLink)
  local key = keys[itemType]
  local itemTrait
  if (key == "traits") then
    itemTrait, _ = GetItemLinkTraitInfo(itemLink)
  end
  local nam = zo_strformat(SI_LINK_FORMAT_ITEM_NAME, GetItemLinkName(itemLink))
  
  
  ---@local trade @class MatTradeRec
  for k,trade in ipairs(mattrades[key]) do
    if ((itemType == trade.itemType) and (zo_strlower(nam) == zo_strlower(trade.mat))
              and (not itemTrait or (itemTrait == trade.itemTrait))) then
      return mattrades[key][k], {key, k}
    end
  end
  
  return nil, nil
end
-- end HotepCraft.MatchMatTrade(mattrades, itemLink)



function HotepCraft.MailScanningWindow(show, msg)
  
  if (not msg) then
    msg = ""
  elseif (not string.find(msg, "|c", 1, true)) then
    msg = zo_strformat("<<1>><<2>>|r", COLOR_YELLOW, msg)
  end
  
  if (show) then
    HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>WAIT!|r <<2>>Scanning Your Mail...|r", COLOR_RED, COLOR_PURPLE))
    HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>** DO NOT TAKE ANY ATTACHMENTS!! **|r", COLOR_PURPLE))
    HotepCraft_UI_mule_Progress:SetHidden(false)
    HotepCraft_UI_mule_Line3:SetText(msg)
    HotepCraft_UI_mule_Line3:SetHidden(false)
    HotepCraft_UI_mule:SetHidden(false)
    HotepCraft_UI_mule:SetDimensionConstraints(600, 200, 600, 200)
    HotepCraft_UI_mule:SetHeight(200)
  else
    HotepCraft_UI_mule_Scanning:SetText(zo_strformat("<<1>>Scanning your backpack. Please don't log off!|r", COLOR_YELLOW))
    HotepCraft_UI_mule_Progress:SetText(zo_strformat("<<1>>Progress: 0%|r", COLOR_YELLOW))
    HotepCraft_UI_mule_Progress:SetHidden(false)
    HotepCraft_UI_mule_Line3:SetText("")
    HotepCraft_UI_mule_Line3:SetHidden(true)
    HotepCraft_UI_mule:SetHidden(true)
    HotepCraft_UI_mule:SetDimensionConstraints(600, 120, 600, 120)
    HotepCraft_UI_mule:SetHeight(120)
  end
end
-- end HotepCraft.MailScanningWindow(show, msg)





function HotepCraft.OnMailReadable(eventCode, mailId)
  
  msgDebug("*** ON MAIL READABLE ***", COLOR_PURPLE)
  msgDebug(zo_strformat("ScanningMail = <<1>>, type: <<2>>", ScanningMail, type(ScanningMail)), COLOR_PURPLE)
  msgDebug("mailId = " .. Id64ToString(mailId), COLOR_PURPLE)
  
  if (ScanningMail ~= "hold") then return end
  
  
  local i = array_indexof(Id64ToString(mailId), HotepCraft.ScannedMailIDs, function(ele) return Id64ToString(ele.mailId) end)
  
  msgDebug(zo_strformat("i = <<1>>, type: <<2>>", i, type(i)), COLOR_PURPLE)
  
  if (i > 0) then
    msgDebug(HotepCraft.ScannedMailIDs[i], COLOR_PURPLE)
    msgDebug(Id64ToString(HotepCraft.ScannedMailIDs[i].mailId), true)
    HotepCraft.ProcessTradeMats(mailId, i)
    return
  end
  
  HotepCraft.NextScannedMail()
end
-- end HotepCraft.OnMailReadable(eventCode, mailId)


function HotepCraft.NextScannedMail()
  
  if ((ScanningMail ~= "hold") and (ScanningMail ~= "close")) then return end
  
  
  if ((#HotepCraft.ScannedMailIDs == 0) or (ScanningMail == "close")) then
    ScanningMail = false
    EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_MAIL_READABLE)
    
    HotepCraft.MailScanningWindow(false)
    
    return
  end
  
  
  ---@local t @class ScannedMailID
  local t = HotepCraft.ScannedMailIDs[1]
  local su = t.subject
  
  su = zo_strformat('<<1>>Please Select the Mail with subject: "|r<<2>><<3>>|r<<1>>"|r', COLOR_YELLOW, COLOR_WHITE, su)
  
  HotepCraft.MailScanningWindow(true, su)
  
end
-- end HotepCraft.NextScannedMail()


---
-- @param order @class ORDER
function HotepCraft.CheckAllTradesDone(order, k)
  
  if (not CurrentClaim.WaitingForMats) then return end
  
  local done = true
  
  for key,mattrades in pairs(order.MatTrades) do
    if (type(mattrades) == "table") then
      ---@local trade @class MatTradeRec
      for _,trade in ipairs(mattrades) do
        if (trade.needed > trade.got) then
          done = false
          break
        end
      end
      
      if (not done) then
        break
      end
    end
  end
  
  if (done) then
    local cus = order.customer
    local on = order.ordernumber
    msgWithName(zo_strformat("<<1>> has sent ALL MATS for order# <<2>>", cus, on), COLOR_GREEN)
    HotepCraft.MatTradesDone(order, k)
  end
  
end
-- end HotepCraft.CheckAllTradesDone(order, k)


---
-- @param mailId    mailID of mail containing mats
-- @param index    index of HotepCraft.ScannedMailIDs
function HotepCraft.ProcessTradeMats(mailId, index)
  
  if (ScanningMail ~= "hold") then return end
  
  HotepCraft.MailScanningWindow(true, "Processing...")
  
  local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)
  
  if (numAttachments < 1) then
    table.remove(HotepCraft.ScannedMailIDs, index)
    HotepCraft.NextScannedMail()
    return
  end
  
  local count = 0
  local attaches = {}
  local tinders = {}
  local valid = true
  ---@local t @class ScannedMailID
  local t = HotepCraft.ScannedMailIDs[index]
  
  if (not AreId64sEqual(t.mailId, mailId) or not CurrentClaim.WaitingForMats) then
    table.remove(HotepCraft.ScannedMailIDs, index)
    HotepCraft.NextScannedMail()
    return
  end
  
  ---@local matwait @class WAITINGTRADES 
  local matwait = CurrentClaim.WaitingForMats[t.k]
  
  if (not matwait) then
    table.remove(HotepCraft.ScannedMailIDs, index)
    HotepCraft.NextScannedMail()
    return
  end
  
  ---@local order @class ORDER
  local order = HotepCraft.ReturnOrderByUUID(matwait.orderuuid)
  
  if (not order) then
    table.remove(HotepCraft.ScannedMailIDs, index)
    error("Waiting for Mats for a Non-Existent order!")
    HotepCraft.NextScannedMail()
    return
  end
  
  
  for i = 1, numAttachments do
    local itemLink = GetAttachedItemLink(mailId, i)
    msgDebug(itemLink)
    local trade, tindex = HotepCraft.MatchMatTrade(order.MatTrades, itemLink)
    
    if (trade) then
      count = count + 1
      local _, stack = GetAttachedItemInfo(mailId, i)
      msgDebug(stack)
      if (stack <= (trade.needed - trade.got)) then
        if (not array_key_exists(tindex, tinders)) then
          tinders[tindex] = clone(trade)
        end
        
        if (stack <= (tinders[tindex].needed - tinders[tindex].got)) then
          table.insert(attaches, {trade, stack})
          tinders[tindex].got = tinders[tindex].got + stack
        else
          valid = false
          break
        end
      else
        valid = false
        break
      end
    else
      valid = false
      break
    end
  end
  
  
  local returnIt = function(mailId)
    
    local fooclose = function()
      EVENT_MANAGER:UnregisterForEvent(HotepCraft.name .. "2", EVENT_MAIL_REMOVED)
      zo_callLater(function() SCENE_MANAGER:ShowBaseScene() end, 500)
      ScanningMail = "close"
      table.remove(HotepCraft.ScannedMailIDs, index)
      HotepCraft.NextScannedMail()
    end
    
    local nam, _, subj = GetMailItemInfo(mailId)
    msgWithName(zo_strformat('Returning mail from <<1>> with subj "<<2>>".', nam, subj), COLOR_PURPLE)
    EVENT_MANAGER:RegisterForEvent(HotepCraft.name .. "2", EVENT_MAIL_REMOVED, fooclose)
    ReturnMail(mailId)
  end
  -- end local function returnIt
  
  local tookItems = function()
    EVENT_MANAGER:UnregisterForEvent(HotepCraft.name .. "2", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
    
    for _,tradestack in ipairs(attaches) do
      ---@local trade @class MatTradeRec
      local trade = tradestack[1]
      local stack = tradestack[2]
      trade.got = trade.got + stack
      local dis = (stack * trade.discPer)
      order.MatTrades.MatDiscount = order.MatTrades.MatDiscount + dis
      local msg = "Received <<1>>x <<2>> from <<3>> for order# <<4>> - <<5>>g discounted."
      msg = zo_strformat(msg, stack, trade.mat, order.customer, order.ordernumber, dis)
      msgWithName(msg, COLOR_GREEN)
    end
    
    HotepCraft.CheckAllTradesDone(order, t.k)
    
    table.remove(HotepCraft.ScannedMailIDs, index)
    HotepCraft.NextScannedMail()
  end
  -- end local function tookItems
  
  if (valid) then
    if ((attachedMoney > 0) or (codAmount > 0)) then
      returnIt(mailId)
      return
    end
    
    EVENT_MANAGER:RegisterForEvent(HotepCraft.name .. "2", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, tookItems)
    msgDebug("TAKING ATTACHMENTS")
    TakeMailAttachedItems(mailId)
    return
  elseif (count > 0) then
    returnIt(mailId)
    return
  end
  
  table.remove(HotepCraft.ScannedMailIDs, index)
  HotepCraft.NextScannedMail()
end
-- end HotepCraft.ProcessTradeMats(mailId, index)


function HotepCraft.ScanMailForMats(e, mailId)
  
  local foo = function()
    HotepCraft.ScanMailForMats(e, mailId)
  end
  
  msgDebug(zo_strformat("CALLED ScanMailForMats(e, <<1>>)", Id64ToString(mailId or 0)), COLOR_PURPLE)
  msgDebug(zo_strformat("ScanningMail = <<1>>", ScanningMail), COLOR_PURPLE)
  
  if (ScanningMail == "hold") then
    zo_callLater(foo, 1000)
    return
  end
  
  if (ScanningMail == "abort") then
    HotepCraft.MailScanningWindow(false)
    return
  end
  
  if (ScanningMail == "no") then return end
  
  if (ScanningMail and not mailId) then return end
  
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_MAIL_READABLE)
  ScanningMail = true
  
  
  if (not mailId) then            -- initial execution
    
    HotepCraft.CleanUpOnAisleM()
    
    local n = GetNumMailItems()
    
    HotepCraft.ScannedMailIDs = {}
    
    msgDebug(zo_strformat("ScannedMailIDs INITIALIZED, n = <<1>>", n), true)
    
    if ((n < 1) or not CurrentClaim.WaitingForMats or (#CurrentClaim.WaitingForMats == 0)) then
      ScanningMail = false
      HotepCraft.MailScanningWindow(false)
      return
    end
    
    HotepCraft.MailScanningWindow(true)
  end
  -- end if initial execution
  
  
  mailId = GetNextMailId(mailId)
  
  if (not mailId) then    -- scanned all the mails
    local OpenMailId = MAIL_INBOX:GetOpenMailId()
    ScanningMail = false
    
    local num = #HotepCraft.ScannedMailIDs
    
    msgDebug(zo_strformat("DONE SCANNING MAILS, num = <<1>>", num), true)
    
    if (num > 0) then
      ScanningMail = "hold"
      EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_MAIL_READABLE, HotepCraft.OnMailReadable)
      
      local i = array_indexof(OpenMailId, HotepCraft.ScannedMailIDs, function(ele) return ele.mailId end)
      
      if (i > 0) then
        HotepCraft.ProcessTradeMats(OpenMailId, i)
        return
      end
      
      HotepCraft.NextScannedMail()
      return
    end
    
    HotepCraft.MailScanningWindow(false)
    
    return
  end
  --end if scanned all the mails
  
  
  local senderDisplayName, _, subject = GetMailItemInfo(mailId)
  local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)
  
  -- check if we're interested in this mail
  
  ---@local matwait @class WAITINGTRADES
  for k,matwait in ipairs(CurrentClaim.WaitingForMats) do
    if ((matwait.customer == senderDisplayName) and (numAttachments > 0)) then
      table.insert(HotepCraft.ScannedMailIDs, {mailId = mailId, k = k, subject = subject})
    end
  end
  
  
  zo_callLater(foo, 150)
end
-- end HotepCraft.ScanMailForMats(e, mailId)


function HotepCraft.StartScanMail(e)
  
  msgDebug("* * * EVENT_MAIL_INBOX_UPDATE * * *", COLOR_PURPLE)
  
  local show = function()
    if (ScanningMail == "start") then
      HotepCraft.MailScanningWindow(true)
    end
  end
  
  local go = function()
    if (ScanningMail == "start") then
      ScanningMail = false
      HotepCraft.ScanMailForMats(e)
    elseif (ScanningMail ~= "no") then
      ScanningMail = false
      HotepCraft.NextScannedMail()
    end
  end
  
  if ((ScanningMail ~= "abort") and (ScanningMail ~= "no")) then
    ScanningMail = "start"
    zo_callLater(show, 150)
    zo_callLater(go, 1125)
  end
end


function HotepCraft.OkToScanMail()
  ScanningMail = false
end

function HotepCraft.DontScanMail()
  ScanningMail = "abort"
  HotepCraft.MailScanningWindow(false)
end





function HotepCraft:Activated_Crafter(otaker)
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
  
  if (not otaker) then
    initSKILLINDEX()
    
    for quality = 1,4 do
      HotepCraft.improvQty(PROFESSION_SMITH, quality)
      HotepCraft.improvQty(PROFESSION_CLOTH, quality)
      HotepCraft.improvQty(PROFESSION_WOOD, quality)
    end
  elseif (savedVariables.skills.improvQty[PROFESSION_SMITH][1] == 0) then
    msgWithName("You must log in with your main crafter at least once before logging into an order-taker character.", COLOR_PURPLE)
    msgWithName("Add-on disabled.", COLOR_RED)
    return
  end
  
  
  HotepToolsLib.SlashHotep:Register("cancel", HotepCraft.SlashCancel)
  HotepToolsLib.SlashHotep:Register("dnd", HotepCraft.SlashDND)
  HotepToolsLib.SlashHotep:Register("repeat", HotepCraft.SlashRePrompt)
  HotepToolsLib.SlashHotep:Register("respond", HotepCraft.SlashReAnswer)
  HotepToolsLib.SlashHotep:Register("forceprice", HotepCraft.SlashForcePrice)
  HotepToolsLib.SlashHotep:Register("forceorder", HotepCraft.SlashForceOrder)
  HotepToolsLib.SlashHotep:Register("forceinfo", HotepCraft.SlashForceInfo)
  HotepToolsLib.SlashHotep:RegisterHelp(HotepCraft.name, HotepCraft.SlashHelp)
  
  
  
  if (otaker) then
    msgWithName("Loaded in Order-Taker Mode.", COLOR_PURPLE)
  else
    msgWithName("Loaded in Crafter Mode.")
  end
  
  HotepCraft.CleanUpOnAisleD()
  HotepCraft.CleanUpOnAisleM()
  
  HotepCraft.InitUIWindows()
  
  if (not otaker) then
    ZO_PreHook(APPLY_ENCHANT, "OnEnchantSelected", HotepCraft.OnEnchantingAnItem)
    ZO_PreHook(APPLY_ENCHANT, "SetupDialog", HotepCraft.OnAboutToEnchant)
    ZO_PreHook(MAIL_SEND, "Send", HotepCraft.OnSendingAMail)
  end
  
  ZO_PreHook(MAIL_INBOX, "OnTakeAttachedMoneySuccess", HotepCraft.OnTakeAttachedMoneySuccess)
  
  
  HotepCraft.VerifySettings(HotepCraft.TheLAMAddonPanel)
  timer_Advert:Start()
--  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, self.GotSomeLoot)
--  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_CLOSED, self.LootClosed)
  
  
  if (not otaker) then
    local fooDoScan = function()
      HotepCraft.ScanCrafterBackpack()
    end
    
    CALLBACK_MANAGER:RegisterCallback(EVENT_MAILREAD_STARTED, HotepCraft.DontScanMail)
    CALLBACK_MANAGER:RegisterCallback(EVENT_MAILREAD_ENDED, HotepCraft.OkToScanMail)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, fooDoScan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADE_SUCCEEDED, fooDoScan)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, self.TookAttachedItemsFromMail)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_CLOSE_MAILBOX, self.MailBoxClosed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BUY_RECEIPT, self.BoughtSomethingFromVendor)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_STORE, self.VendorClosed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_TRADING_HOUSE, self.KioskClosed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_INBOX_UPDATE, self.StartScanMail)
    
    Timer:Once(0.25, self.ScanCrafterBackpack)
  end
  
end
-- end HotepCraft:Activated_Crafter(otaker)


function HotepCraft:Activated_Mule()
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
  msgWithName("Loaded in Mule Mode.")
  HotepCraft.InitUIWindows_Mule()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, self.BankOpened_Mule)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, self.BankClosed_Mule)
end


function HotepCraft.BankOpened_Mule()
  if (CurrentClaim.orderindex > 0) then
    HotepCraft.BANKISOPEN = true
    HotepCraft.ToggleUIMule(true)
  end
end

function HotepCraft.BankClosed_Mule()
  HotepCraft.BANKISOPEN = false
  HotepCraft.ToggleUIMule(false)
end



function HotepCraft:Initialize()
  
  
  ZO_CreateStringId("SI_BINDING_NAME_HOTEPCRAFT_MAIN", "Main Window")
  ZO_CreateStringId("SI_BINDING_NAME_HOTEPCRAFT_MYORDER", "Show My Current Work")
  ZO_CreateStringId("SI_BINDING_NAME_HOTEPCRAFT_WAYSHRINE", "Wayshrine to Set-Crafting Location")
  ZO_CreateStringId("SI_BINDING_NAME_HOTEPCRAFT_ADVERT", "Advertise on CURRENT chat channel")
  
  
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
      if (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_CRAFTER) then
        HotepCraft:Activated_Crafter()
      elseif (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_OT) then
        HotepCraft:Activated_Crafter(true)
      elseif (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_MULE) then
        HotepCraft:Activated_Mule()
      end
    end
  )
  
  
  
  HotepToolsLib:Init()
  
  HotepCraft.LoadSavedSetup()
  
  if (not Settings.characters[HotepCraft.mycharacter]) then
    Settings.characters[HotepCraft.mycharacter] = CHAR_TYPE_NONE
  end
  
  HotepCraft.CreateAddonSettingsPanel()
  
  
  if (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_CRAFTER) then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL, self.OnChatEvent)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, self.OnCraftEventInteract)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, self.OnCraftEventInteractEnd)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_START_FAST_TRAVEL_INTERACTION, self.OnWayshrine)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_FAST_TRAVEL_INTERACTION, self.OnStopWayshrine)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_OPEN_MAILBOX, self.OfferDeliverOrder)
  elseif (Settings.characters[HotepCraft.mycharacter] == CHAR_TYPE_OT) then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL, self.OnChatEvent)
  end
  
end
-- end HotepCraft:Initialize()




function HotepCraft.OnWayshrine()
  if (HotepCraft.CanJumpToCraftingWayshrine()) then
    HotepCraft.UIAddKeybindWayshrine(true)
  end
end

function HotepCraft.OnStopWayshrine()
  HotepCraft.UIAddKeybindWayshrine(false)
end



function HotepCraft.OnCraftEventInteract(eventCode, craftSkill, sameStation)
  if (HotepCraft:OnCraftingOpen(craftSkill)) then
    HotepCraft.LinkJustCrafted = nil
    HotepCraft.UniqueIdImproving = nil
    
    if (craftSkill ~= CRAFTING_TYPE_ENCHANTING) then
      EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_CRAFT_STARTED, HotepCraft.OnCraftEventStarted)
--      EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.OnSingleSlotUpdate)
      EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_CRAFT_COMPLETED, HotepCraft.OnCraftEventCompleteFindSlot)
    end
  end
end


function HotepCraft.OnCraftEventCompleteFindSlot(eventCode, craftSkill)
  
  local improves = function(slotId)
    return HotepCraft:OnImprovedItemInBag(slotId)
  end
  
  
  local creates = function(slotId)
    if (GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_DEFAULT) == HotepCraft.LinkJustCrafted) then
      HotepCraft:OnCraftedItemInBag(slotId)
      return true
    else
      return false
    end
  end
  
  
  local fun = {
    [SMITHING_MODE_CREATION] = creates,
    [SMITHING_MODE_IMPROVEMENT] = improves,
  }
  
  local check = {
    [SMITHING_MODE_CREATION] = HotepCraft.LinkJustCrafted,
    [SMITHING_MODE_IMPROVEMENT] = HotepCraft.UniqueIdImproving,
  }
  
  
  local m = SMITHING.mode
  
  if (not check[m]) then
    return
  end
  
  
  local BC = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
  
  for k, data in pairs(BC) do
    local i = data.slotIndex
    if (i and fun[m](i)) then
      return
    end
  end
end
-- end HotepCraft.OnCraftEventCompleteFindSlot(eventCode, craftSkill)


function HotepCraft.OnCraftEventInteractEnd(eventCode, craftSkill)
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_CRAFT_STARTED)
  EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_CRAFT_COMPLETED)
  HotepCraft:OnCraftingClose()
end


function HotepCraft.OnCraftEventStarted(eventCode, craftSkill)
  if ((CurrentClaim.orderindex > 0) and in_array(craftSkill, CurrentClaim.craftingtypes)) then
    if (in_array(SMITHING.mode, {SMITHING_MODE_CREATION,SMITHING_MODE_IMPROVEMENT})) then
--      EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HotepCraft.OnSingleSlotUpdate)
      HotepCraft:OnCraftingItem(craftSkill)
    end
  end
end



--function HotepCraft.OnSingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
--d("----OnSingleSlotUpdate----")                      -- *************************************************************
--d(SMITHING.mode .. " = " .. SMITHING_MODE_CREATION)
--d(HotepCraft.LinkJustCrafted)                            -- *************************************************************
--d({
--  bagid = bagId,
--  slotId = slotId,
--  isNew = isNewItem,
--  stackCountChange = stackCountChange,
--})
--  
--  
--  if (SMITHING.mode == SMITHING_MODE_IMPROVEMENT) then
--    if ((bagId == BAG_BACKPACK) and (stackCountChange == 0) and not isNewItem) then
--      if (HotepCraft.GetItemUniqueId(BAG_BACKPACK, slotId) == HotepCraft.UniqueIdImproving) then
--        EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
--        HotepCraft:OnImprovedItemInBag(slotId)
--      end
--    end
--  elseif (SMITHING.mode == SMITHING_MODE_CREATION) then
--    if ((bagId == BAG_BACKPACK) and isNewItem and (stackCountChange == 1)) then
--      
--      
--d("----OnSingleSlotUpdate----")
--d(GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT))        -- *************************************************************
--d(HotepCraft.LinkJustCrafted)                            -- *************************************************************
--d(GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT) == HotepCraft.LinkJustCrafted)
--      
--      
--      if (GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT) == HotepCraft.LinkJustCrafted) then
--        EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
--        HotepCraft:OnCraftedItemInBag(slotId)
--      end
--    end
--  end
--end


function HotepCraft.OnSingleSlotUpdateEnchant(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  if ((stackCountChange == 0) and not isNewItem) then
    EVENT_MANAGER:UnregisterForEvent(HotepCraft.name .. "enchant", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    HotepCraft:OnEnchantedItemInBag(bagId, slotId)
  end
end





function HotepCraft.OnChatEvent(eventCode, messageType, fromName, text, isCustomerService, fromDisplayName)
  
  if (isCustomerService) then
    return
  end
  
  if (messageType == CHAT_CHANNEL_WHISPER) then
    
    msgDebug(zo_strformat("WHISPER FROM <<1>>/<<2>>", fromName, fromDisplayName))
    
    if ((type(fromDisplayName) ~= "string") or (string.len(fromDisplayName) < 1) or (string.sub(fromDisplayName, 1, 1) ~= "@")) then
      fromDisplayName = fromName
    end
    
    HotepCraft:OnGotChat(fromDisplayName, text)
  end
end








function HotepCraft.OnAddOnLoaded(event, addonName)
  if (addonName == HotepCraft.name) then
    EVENT_MANAGER:UnregisterForEvent(HotepCraft.name, EVENT_ADD_ON_LOADED)
    math.randomseed(GetTimeStamp())
    HotepCraft:Initialize()
  end
end


EVENT_MANAGER:RegisterForEvent(HotepCraft.name, EVENT_ADD_ON_LOADED, HotepCraft.OnAddOnLoaded)
