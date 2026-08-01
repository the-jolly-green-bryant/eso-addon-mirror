
local lib = LibStub:NewLibrary("HotepOrderTaker", 1)

if not lib then
  return    -- already loaded and no upgrade necessary
end

local COLOR_HOTEP = "|c3366ff"
local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"
local COLOR_GREEN = "|c00ff00"
local COLOR_BLUE = "|c0066ff"
local COLOR_PURPLE = "|cff00ff"
local COLOR_YELLOW = "|cffff00"


local PROFESSION_SMITH = 1
local PROFESSION_CLOTH = 2
local PROFESSION_WOOD = 3

lib.RESEARCH_LEVEL = -1
lib.RESEARCH_LEVEL_EQUIV = 1

local MAX_CHAT = MAX_TEXT_CHAT_INPUT_CHARACTERS

if (not MAX_CHAT) then
  MAX_CHAT = 200
end

lib.ITEMSTYLE_CWC_COMPAT = -50


local function clone(t, c)
  if (type(t) ~= "table") then return t end
  if (type(c) == "nil") then c = {} end
  if (type(c) ~= "table") then return nil end
  
  for k,v in pairs(t) do
    if (type(v) == "table") then
      c[k] = clone(v)
    else
      c[k] = v
    end
  end
  
  return c
end

local function in_array(ele, t, fun)
  local foo

  if (type(fun) == "function") then
    foo = fun
  else
    foo = function (elem) return elem end
  end

  for k,v in pairs(t) do
    if (foo(v) == ele) then return true end
  end

  return false
end


local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k,_ in pairs(t) do table.insert(keys, k) end
    
    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if (type(order) == "function") then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    
    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


local function eyesort(t, a, b)
  return (t[a].__i < t[b].__i)
end


---
-- @param t @class table
-- @return @class table
local function array_keys(t)
  local keys = {}
  for k,_ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end



local function insert_chop(t, s)
  
  local n = string.len(s)
  
  if (n <= MAX_CHAT) then
    table.insert(t, s)
    return
  end
  
  local i = 1
  local j = MAX_CHAT
  
  while (i <= n) do
    local x = string.sub(s, i, j)
    table.insert(t, x)
    i = i + MAX_CHAT
    j = j + MAX_CHAT
  end
end

lib.insert_chop = insert_chop


local function zip_tables(t1, t2)
  local t = {}
  local n = #t1
  
  for i = 1,n do
    table.insert(t, t1[i])
    table.insert(t, t2[i])
  end
  
  return t
end







local function Locals(HotepCraft)
  return {
    handle = HotepCraft.neworder.order.customer,
    params = HotepCraft.neworder.params,
    order = HotepCraft.neworder.order,
    item = HotepCraft.neworder.params.item,
    validator = HotepCraft.neworder.params.validator,
    resp = HotepCraft.neworder.params.response,
  }
end

--if (false) then
--  Locals().order = ORDER
--  Locals().item = ITEM
-----
----@local NewOrderParams @class NewOrderParams
--  local NewOrderParams
--  Locals().params = NewOrderParams
--end



---
-- @param HotepCraft @class table
-- @param PriceList @class PriceList
-- @return @class nil
local function EditItem(HotepCraft, PriceList)
  local L = Locals(HotepCraft)
  L.params.item = L.order.items[L.params.itemnum]
  L.item = L.params.item
  
  local deduct = function(L, fee)
    L.item.fee = L.item.fee - fee
    L.order.feetotal = L.order.feetotal - fee
    L.order.grandtotal = L.order.grandtotal - fee
  end
  
  
  local hastrait = (not (not L.item.trait))
  local isset = (L.item.set > 0)
  local hasenchant = (L.item.enchant > 0)
  
  if ((L.resp == "1") and (L.item.improvement > 0)) then
    local pr = lib.GetTotalImproveFee(PriceList.improvefees, L.item.profession, L.item.improvement, HotepCraft.improvQty)
    deduct(L, lib.GDP(PriceList, L.order, pr))
    L.item.improvement = 0
    L.params.stage = "whatimprove"
  elseif ((L.resp == "2") and hastrait) then
    local aw = lib.ARM_WEAP(L.item.itemtype)
    local pr = PriceList.traitfee[aw][L.item.trait]
    deduct(L, lib.GDP(PriceList, L.order, pr))
    L.item.trait = false
    L.params.stage = "reviewcheckout"
  elseif ((L.resp == "3") and isset) then
    local pr = PriceList.setfees[L.item.set]
    deduct(L, lib.GDP(PriceList, L.order, pr))
    L.item.set = 0
    L.params.stage = "reviewcheckout"
  elseif ((L.resp == "4") and hasenchant) then
    local pr = lib.GetEnchantFee(PriceList, L.item.itemtype, L.order.level, L.item.enchant)
    deduct(L, lib.GDP(PriceList, L.order, pr))
    L.item.enchant = 0
    L.params.stage = "reviewcheckout"
  elseif (L.resp == "5") then
    local pr = PriceList.stylefees[L.item.style]
    if (pr) then
      deduct(L, lib.GDP(PriceList, L.order, pr))
    end
    L.item.style = 0
    L.params.stage = "whatstyle"
  else
    L.params.editingitem = true
    local where = {"whatimprove", "whattrait", "whatset", "whatenchant"}
    L.params.stage = where[tonumber(L.resp)]
  end
end
-- end EditItem(HotepCraft, PriceList)


local function research(lev)
  return (lev == lib.RESEARCH_LEVEL)
end


local TAIL_LOOP = true
local TAIL_RETURN = false

--[[                                                                            
["stage"] = {                                                                   
  [check] = bool: validate current resp?,                                       
  [chat] = {whisper message, ...},                                              
  [val] = {validator},                                                          
  [fun] = nil or function to run,                                               
  [stage] = "next stage",                                                       
  [tail] = TAIL_LOOP or TAIL_RETURN,                                            
}                                                                               
]]

lib.theOT = {
  ["whatlevel"] = {
    ["check"] = false,
    ["chat"] = {
      'What level items do you want? Say a number between 1-50. (For CP-levels say 50) ' ..
      'If you want the item(s) for research, say 0. ' ..
      'Say "cancel" at any time to cancel your order. ' ..
      'NOTE: If you wish to provide your own crafting materials for a discount, you will ' ..
      'be prompted at the end of the ordering process.'
    },
    ["val"] = {"whatlevel", {0}, {["intrange"] = {0,50}, ["cp"] = "50"}},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setlevel",
      ["back"] = {
        [true] = "setlevel",
        [false] = "setlevel",
      },
    },
  },
  ["setlevel"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ---
-- @param HotepCraft @class HotepCraft
-- @return
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      if (L.resp == "50") then
        L.params.stage = "whatrank"
      else
        L.order.level = tonumber(L.resp)
        if (L.order.level == 0) then
          L.order.level = lib.RESEARCH_LEVEL
        end
        L.params.stage = "setrankorlevel"
        HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whatrank"] = {
    ["check"] = false,
    ["chat"] = {'What CP rank? Say a number between 0 and 160 (If your CP is more than 160, say 160)'},
    ["val"] = {"whatlevel", {0}, {["intrange"] = {0,160}}},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setrank",
      ["back"] = {
        [true] = "setrank",
        [false] = "setrank",
      },
    },
  },
  ["setrank"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      local v = math.floor(tonumber(L.resp) / 10)
      L.order.level = v + 50;
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
    end,
    ["stage"] = "setrankorlevel",
    ["tail"] = TAIL_LOOP,
  },
  ["setrankorlevel"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.itemnum = 1
      L.order.itemtotal = 0
      L.order.adjustment = 0
      L.order.grandtotal = lib.GDP(PriceList, L.order, PriceList.fixedfee)
      L.order.feetotal = lib.GDP(PriceList, L.order, PriceList.fixedfee)
      L.params.checkingout = false
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
    end,
    ["stage"] = "itemwhatkind",
    ["tail"] = TAIL_LOOP,
  },
  ["itemwhatkind"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {"itemwhatkind", {0}, {["list"] = {"armor", "armour", "weapon", "shield"}}},
    ---
    -- @param HotepCraft @class table
    -- @param PriceList @class PriceList
    -- @return @class nil
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      local n = #L.order.items
      if (n == 12) then
        L.params.T.chat = nil
        L.params.stage = "begincheckout"
      else
        L.params.item = lib.ITEM()
        L.item = L.params.item
        L.item.fee = lib.GDP(PriceList, L.order, PriceList.itemfee)
        local OrderFee = lib.GDP(PriceList, L.order, PriceList.fixedfee);
        local msg = "So far, you have <<1>> items in your cart, totaling <<2>>g"
        msg = zo_strformat(msg, n, (L.order.grandtotal - OrderFee))
        L.params.T.chat = {msg}
        if (n > 0) then
          msg = 'To list the items in your cart, say "list"'
          table.insert(L.params.T.chat, msg)
        end
        msg = 'Ordering item # <<1>>: What kind of item? Say "armor", "weapon", or "shield"'
        msg = zo_strformat(msg, L.params.itemnum)
        msg = msg .. zo_strformat(' Say "back" at any time to cancel item #<<1>> and return to this prompt.', L.params.itemnum)
        msg = msg .. zo_strformat(' Say "checkout" at any time to cancel item #<<1>> and proceed to checkout.', L.params.itemnum)
        msg = msg .. ' (To cancel your entire order, say "cancel")'
        insert_chop(L.params.T.chat, msg)
        HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
    Answer = {
      [1] = "setitemkind",
      ['list'] = {
        [true] = "listcart",
        [false] = "listcart",
      },
    },
  },
  ["setitemkind"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp == "armour") then L.resp = "armor" end
      if (L.resp == "armor") then
        L.params.stage = "whatkindarmor"
      elseif (L.resp == "weapon") then
        L.params.stage = "whatkindweapon"
      elseif (L.resp == "shield") then
        L.item.itemtype = L.resp
        L.item.profession = PROFESSION_WOOD
        L.item.item = 1
        local pr = lib.GetTotalUnitsPrice(PriceList.price.woods, L.order.level, L.item.itemtype, 1)
        L.item.price = lib.GDP(PriceList, L.order, pr)
        L.params.stage = "whatimprove"
        if (research(L.order.level)) then
          L.params.stage = "whattrait"
        end
        HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whatkindarmor"] = {
    ["check"] = false,
    ["chat"] = {'What kind of armor? Say "light", "medium", or "heavy"'},
    ["val"] = {"whatkindarmor", {0}, {["list"] = {"light","medium","med","heavy"}}},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setarmortype",
    },
  },
  ["whatkindweapon"] = {
    ["check"] = false,
    ["chat"] = {'What kind of weapon? Say "1h" for Axe, Mace, Sword, or Dagger.  Say "2h" for Battle Axe, Maul, or Greatsword.  Say "dstaff" for Destruction Staffs. Say "rstaff" for a Restoration Staff.  Say "bow" for a Bow.'},
    ["val"] = {"whatkindweapon", {0}, {["list"] = {"1h","2h","dstaff","rstaff","bow"}}},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setweapontype",
    },
  },
  ["setarmortype"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp == "medium") then L.resp = "med" end
      L.item.itemtype = L.resp
      if (L.resp == "heavy") then
        L.item.profession = PROFESSION_SMITH
      else
        L.item.profession = PROFESSION_CLOTH
      end
      L.params.stage = "whatpiece"
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whatpiece"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      local pieces, msg = lib.PIECES(L.item.itemtype)
      local n = #pieces
      msg = string.format(msg, unpack(pieces))
      L.params.T.chat = {}
      insert_chop(L.params.T.chat, msg)
      L.params.T.val = {"whatpiece", {0}, {["intrange"] = {1,n}}}
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setpiece",
    },
  },
  ["setpiece"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.item.item = tonumber(L.resp)
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
      local pp = lib.GetPriceTable(L.item.itemtype)
      local pr = lib.GetTotalUnitsPrice(PriceList.price[pp], L.order.level, L.item.itemtype, L.item.item)
      L.item.price = lib.GDP(PriceList, L.order, pr)
      if (research(L.order.level)) then
        L.params.stage = "whattrait"
      else
        L.params.stage = "whatimprove"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["setweapontype"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.item.itemtype = L.resp
      HotepCraft.msgDebug(zo_strformat("level: <<1>> / Type: <<2>>", L.order.level, type(L.order.level)), (type(L.order.level) == "nil"))
      
      if (L.resp == "1h") then
        L.item.profession = PROFESSION_SMITH
        L.params.stage = "whatpiece"
      elseif (L.resp == "2h") then
        L.item.profession = PROFESSION_SMITH
        L.params.stage = "whatpiece"
      elseif (L.resp == "dstaff") then
        L.item.profession = PROFESSION_WOOD
        L.params.stage = "whatpiece"
      else
        L.item.profession = PROFESSION_WOOD
        L.item.item = 1
        L.item.price = lib.GetTotalUnitsPrice(PriceList.price.woods, L.order.level, L.item.itemtype, 1)
        L.params.stage = "whatimprove"
        if (research(L.order.level)) then
          L.params.stage = "whattrait"
        end
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whatimprove"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {"whatimprove", {0}, {["intrange"] = {1,4}, ["string"] = "no"}},
    ---
    -- @param HotepCraft @class table
    -- @param PriceList @class PriceList
    -- @return @class nil
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.T.chat = {}
      if (not L.params.checkingout) then
        local nam = lib.GetName(L.item, L.order.level, true)
        table.insert(L.params.T.chat, zo_strformat("Item #<<1>>: <<2>> - base price: <<3>>g", L.params.itemnum, nam, L.item.price))
      end
      local pieces, msg = lib.PIECES("improve")
      local feeses = lib.GetImproveFeesPerQual(PriceList, L.order, L.item.profession, HotepCraft.improvQty)
      msg = "Do you want it improved? " .. string.format(msg, unpack(zip_tables(pieces, feeses)))
      insert_chop(L.params.T.chat, msg)
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setimprove",
    },
  },
  ["setimprove"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ---
    -- @param HotepCraft @class table
    -- @param PriceList @class PriceList
    -- @return @class nil
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "no") then
        L.item.improvement = tonumber(L.resp)
        local ifee = lib.GetTotalImproveFee(PriceList.improvefees, L.item.profession, L.item.improvement, HotepCraft.improvQty)
        ifee = lib.GDP(PriceList, L.order, ifee)
        L.item.fee = L.item.fee + ifee
        if (L.params.checkingout) then
          L.order.feetotal = L.order.feetotal + ifee
          L.order.grandtotal = L.order.grandtotal + ifee
        end
      end
      if (L.params.checkingout) then
        L.params.stage = "reviewcheckout"
      else
        L.params.stage = "whattrait"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whattrait"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {"whattrait", {0}, {["intrange"] = {1,9}, ["string"] = "no"}},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.T.chat = {}
      local message = 'Do you want a trait?  Say "no" for none. '
      local i = 0
      local aw = lib.ARM_WEAP(L.item.itemtype)
      for trait,price in pairs(PriceList.traitfee[aw]) do
        i = i + 1
        local fee = lib.GDP(PriceList, L.order, price)
        local msg = zo_strformat('Say "<<1>>" for <<2>> (add <<3>>g). ', i, trait, fee)
        message = message .. msg
      end
      insert_chop(L.params.T.chat, message)
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "settrait",
    },
  },
  ["settrait"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "no") then
        local aw = lib.ARM_WEAP(L.item.itemtype)
        local traits = array_keys(PriceList.traitfee[aw])
        local i = tonumber(L.resp)
        L.item.trait = traits[i]
        local fee = PriceList.traitfee[aw][L.item.trait]
        fee = lib.GDP(PriceList, L.order, fee)
        L.item.fee = L.item.fee + fee
        if (L.params.checkingout) then
          L.order.feetotal = L.order.feetotal + fee
          L.order.grandtotal = L.order.grandtotal + fee
        end
      end
      if (L.params.checkingout) then
        L.params.stage = "reviewcheckout"
      else
        L.params.stage = "whatset"
        if (research(L.order.level)) then
          L.params.stage = "itemconfirm"
        end
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["whatset"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.T.chat = {}
      local message = 'Do you want this to be a set item?  Say "no" for a non-set item. '
      local n = #PriceList.setfees
      local vv = {}
      for i,price in pairs(PriceList.setfees) do
        if (price > -1) then
          local set = lib.ARM_SETS(i)
          local fee = lib.GDP(PriceList, L.order, price)
          local msg = zo_strformat('Say "<<1>>" for <<2>> (add <<3>>g). ', i, set.name, fee)
          table.insert(vv, i)
          message = message .. msg
        end
      end
      insert_chop(L.params.T.chat, message)
      L.params.T.val = {"whatset", {0}, {["numlist"] = vv, ["string"] = "no"}}
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setset",
    },
  },
  ["setset"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "no") then
        L.item.set = tonumber(L.resp)
        local fee = PriceList.setfees[L.item.set]
        fee = lib.GDP(PriceList, L.order, fee)
        L.item.fee = L.item.fee + fee
        if (L.params.checkingout) then
          L.order.feetotal = L.order.feetotal + fee
          L.order.grandtotal = L.order.grandtotal + fee
        end
      end
      if (L.params.checkingout) then
        L.params.stage = "reviewcheckout"
      else
        L.params.stage = "whatstyle"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  
  
  ["whatstyle"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.T.chat = {}
      local message = 'What style do you want this item in? Say "no" for no preference.'
      local n = #PriceList.stylefees
      local vv = {}
      for i,price in pairs(PriceList.stylefees) do
        if (price > -1) then
          local style = lib.MOTIFS(i)
          local fee = lib.GDP(PriceList, L.order, price)
          local msg = zo_strformat(' Say "<<1>>" for <<2>> (add <<3>>g).', i, style.name, fee)
          message = message .. msg
          table.insert(vv, i)
        end
      end
      insert_chop(L.params.T.chat, message)
      L.params.T.val = {"whatstyle", {0}, {["numlist"] = vv, ["string"] = "no"}}
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setstyle",
    },
  },
  ["setstyle"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "no") then
        L.item.style = tonumber(L.resp)
        local fee = PriceList.stylefees[L.item.style]
        fee = lib.GDP(PriceList, L.order, fee)
        L.item.fee = L.item.fee + fee
        if (L.params.checkingout) then
          L.order.feetotal = L.order.feetotal + fee
          L.order.grandtotal = L.order.grandtotal + fee
        end
      end
      if (L.params.checkingout) then
        L.params.stage = "reviewcheckout"
      else
        L.params.stage = "whatenchant"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  
  
  ["whatenchant"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      local message = 'Do you want it enchanted? Say "no" for none. '
      L.params.T.chat = {}
      local aw = lib.ARM_WEAP(L.item.itemtype)
      local glyphs = lib.GLYPHS(aw)
      local n = #glyphs
      for i,name in pairs(glyphs) do
        local fee = lib.GetEnchantFee(PriceList, L.item.itemtype, L.order.level, i)
        fee = lib.GDP(PriceList, L.order, fee)
        local msg = zo_strformat('Say "<<1>>" for <<2>> (add <<3>>g). ', i, name, fee)
        message = message .. msg
      end
      insert_chop(L.params.T.chat, message)
      L.params.T.val = {"whatenchant", {0}, {["intrange"] = {1,n}, ["string"] = "no"}}
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "setenchant",
    },
  },
  ["setenchant"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "no") then
        L.item.enchant = tonumber(L.resp)
        local fee = lib.GetEnchantFee(PriceList, L.item.itemtype, L.order.level, L.item.enchant)
        fee = lib.GDP(PriceList, L.order, fee)
        L.item.fee = L.item.fee + fee
        if (L.params.checkingout) then
          L.order.feetotal = L.order.feetotal + fee
          L.order.grandtotal = L.order.grandtotal + fee
        end
      end
      if (L.params.checkingout) then
        L.params.stage = "reviewcheckout"
      else
        L.params.stage = "itemconfirm"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["itemconfirm"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      local nam = lib.GetName(L.item, L.order.level, true)
      local price = L.item.price + L.item.fee
      local msg = 'Item #<<1>>: <<2>> - final price: <<3>>g.'
      msg = zo_strformat(msg, L.params.itemnum, nam, price)
      L.params.T.chat = {msg}
      table.insert(L.params.T.chat, 'Say "cart" to add to cart. Say "back" to discard item.')
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "confirmeditem",
    },
  },
  ["confirmeditem"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      if (L.resp == "cart") then
        L.params.stage = "addcart"
      else
        L.params.stage = "itemconfirm"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["addcart"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      table.insert(L.order.items, clone(L.item))
      L.order.itemtotal = L.order.itemtotal + L.item.price
      L.order.feetotal = L.order.feetotal + L.item.fee
      L.order.grandtotal = L.order.grandtotal + L.item.price + L.item.fee
      L.params.itemnum = L.params.itemnum + 1
    end,
    ["stage"] = "itemwhatkind",
    ["tail"] = TAIL_LOOP,
  },
    ---
-- @param HotepCraft @class table
-- @param PriceList @class PriceList
-- @return @class nil
  ["begincheckout"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      local n = #L.order.items
      
      if (n == 0) then
        L.params.stage = "AUTOCANCEL"
        return
      end
      
      local x = ""
      if (n == 12) then x = "This is the maximum order." end
      local msg = zo_strformat("You have <<1>> items in your cart. <<2>>", n, x)
      L.params.T.chat = {msg}
      local OrderFee = lib.GDP(PriceList, L.order, PriceList.fixedfee);
      local LaborMsg = ""
      if (OrderFee > 0) then
        LaborMsg = zo_strformat("Labor: <<1>>g. ", OrderFee)
      end
      msg = "Item Total: <<1>>g. Item Fees: <<2>>g. <<3>>Grand Total: <<4>>g."
      msg = zo_strformat(msg, L.order.itemtotal, (L.order.feetotal - OrderFee), LaborMsg, L.order.grandtotal)
      table.insert(L.params.T.chat, msg)
      msg = 'To list the items in your cart, say "list"'
      table.insert(L.params.T.chat, msg)
      msg = zo_strformat("To review, edit, or remove an item, say a number between 1 and <<1>>", n)
      table.insert(L.params.T.chat, msg)
      table.insert(L.params.T.chat, 'To place your order, say "done" at any time. To cancel entire order, say "cancel"')
      L.params.T.val = {"begincheckout", {3,4}, {["intrange"] = {1,n}, ["string"] = 'list'}}
      L.params.checkingout = true
      L.params.editingitem = false
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "wantreview",
      ['list'] = {
        [true] = "listcart",
        [false] = "listcart",
      },
    },
  },
  ["wantreview"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      L.params.itemnum = tonumber(L.resp)
      L.params.item = L.order.items[L.params.itemnum]
    end,
    ["stage"] = "reviewcheckout",
    ["tail"] = TAIL_LOOP,
  },
  ["reviewcheckout"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {"reviewcheckout", {1,3}, {["list"] = {"edit","remove"}}},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      local nam = lib.GetName(L.item, L.order.level, true)
      local des = lib.GetDescr(L.item)
      local price = L.item.price + L.item.fee
      local msg = zo_strformat("Item #<<1>>: <<2>> <<3>>", L.params.itemnum, nam, des)
      L.params.T.chat = {msg}
      msg = "Item price: <<1>>g, Item Fee <<2>>g, Item Total: <<3>>g."
      msg = zo_strformat(msg, L.item.price, L.item.fee, price)
      table.insert(L.params.T.chat, msg)
      msg = 'Say "edit" to edit this item, "remove" to cancel this item, or say "back"'
      table.insert(L.params.T.chat, msg)
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "reviewaction",
    },
  },
  ["reviewaction"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      if (L.resp == "edit") then
        L.params.stage = "wantedititem"
      elseif (L.resp == "remove") then
        L.params.stage = "removeitem"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["wantedititem"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {"wantedititem", {0}, {["intrange"] = {1,5}}},
    ["fun"] = function (HotepCraft)
      local L = Locals(HotepCraft)
      
      local hastrait = (not (not L.item.trait))
      local isset = (L.item.set > 0)
      local hasenchant = (L.item.enchant > 0)
      
      L.params.T.chat = {'Say "1" to change item quality.'}
      local msg = ""
      if (hastrait) then msg = "remove the" else msg = "add a" end
      msg = zo_strformat('Say "2" to <<1>> trait', msg)
      table.insert(L.params.T.chat, msg)
      if (isset) then msg = "non-set" else msg = "set" end
      msg = zo_strformat('Say "3" to make it a <<1>> item', msg)
      table.insert(L.params.T.chat, msg)
      if (hasenchant) then msg = "remove the" else msg = "add an" end
      msg = zo_strformat('Say "4" to <<1>> enchantment', msg)
      table.insert(L.params.T.chat, msg)
      table.insert(L.params.T.chat, 'Say "5" to change the style of this item.')
      table.insert(L.params.T.chat, 'Say "back" to do nothing to this item.')
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "edititem",
    },
  },
  ["edititem"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      EditItem(HotepCraft, PriceList)
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  ["removeitem"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.order.itemtotal = L.order.itemtotal - L.item.price
      L.order.feetotal = L.order.feetotal - L.item.fee
      L.order.grandtotal = L.order.grandtotal - L.item.price - L.item.fee
      table.remove(L.order.items, L.params.itemnum)
      L.params.itemnum = 0
      L.params.item = nil
    end,
    ["stage"] = "begincheckout",
    ["tail"] = TAIL_LOOP,
  },
  ["tradematprompt"] = {
    ["check"] = false,
    ["chat"] = {'Do you want to provide your own crafting materials in exchange for discounts? ' ..
                'Say "Y" for Yes or "N" for No.',
                'If you say yes, you will be mailed a materials list ' ..
                'with quantities needed and per-unit-discounts.'},
    ["val"] = {"tradematprompt", {0}, {["list"] = {'y','n','yes','no'}}},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "tradematanswer",
    },
  },
  ["tradematanswer"] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.order.TRADINGMATS = ((L.resp == "y") or (L.resp == "yes"))
    end,
    ["stage"] = "donecheckout",
    ["tail"] = TAIL_LOOP,
  },
  ["donecheckout"] = {
    ["check"] = false,
    ["chat"] = {'To leave comments with this order, whisper them now, or say "done" again to finalize your order.'},
    ["val"] = {},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "placeorder",
      ["done"] = {
        [true] = "placeorder",
        [false] = nil,
      },
    },
  },
  ["placeorder"] = {
    ["check"] = false,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      if (L.resp ~= "done") then L.order.comments = L.resp end
      L.params.checkingout = false
      L.order.Status = ORDER_STATUS_WAITING
      L.order.ordertime = GetTimeStamp()
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
  },
  
  ["listcart"] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList)
      local L = Locals(HotepCraft)
      L.params.AUTOLOOP = true
      
      local msg = lib.LEVELS(L.order.level, "level", "short")
      L.params.T.chat = {zo_strformat("Level: <<1>>", msg)}
      
      for i,item in ipairs(L.order.items) do
        local nam = lib.GetName(item, L.order.level, "list")
        local des = lib.GetDescr(item)
        local msg = zo_strformat("#<<1>>: <<2>> <<3>>", i, nam, des)
        table.insert(L.params.T.chat, msg)
      end
      
      if (L.params.checkingout) then
        L.params.stage = "begincheckout"
      else
        L.params.stage = "itemwhatkind"
      end
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_LOOP,
  },
  
}

--[[
  [""] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = nil,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "",
    },
  },
  [""] = {
    ["check"] = false,
    ["chat"] = {""},
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList, T)
      local L = Locals(HotepCraft)
    end,
    ["stage"] = nil,
    ["tail"] = TAIL_RETURN,
    Answer = {
      [1] = "",
      ["back"] = {
        [true] = "",
        [false] = "",
      },
    },
  },
  [""] = {
    ["check"] = true,
    ["chat"] = nil,
    ["val"] = {},
    ["fun"] = function (HotepCraft, PriceList, T)
      local L = Locals(HotepCraft)
    end,
    ["stage"] = "",
    ["tail"] = TAIL_LOOP,
    Answer = {
      [1] = "",
      ["done"] = {
        [true] = "",
        [false] = nil,
      },
    },
  },
]]


lib.Validator = function(T, stagenow)
  if (#T.val == 0) then
    return {}
  end
  
  local v2 = clone(T.val[2])
  local val = clone(T.val)
  
  local c
--  local failstage = val[1]
  
--  if (failstage == stagenow) then
    c = clone(T.chat)
--  else
--    c = clone(lib.theOT[failstage].chat)
--  end
  
  if (v2[1] == 0) then
    val[2] = c
  else
    local t = {}
    for _,i in ipairs(v2) do
      table.insert(t, c[i])
    end
    val[2] = t
  end
  
  return val
end


---
-- @param prices @class table
-- @param level @class number
-- @return @class number  price per UNIT of crafting mat
function lib.GetUnitPrice(prices, level)
  local matlevel = 1
  local price = prices[1]
  
  if (level == lib.RESEARCH_LEVEL) then
    level = lib.RESEARCH_LEVEL_EQUIV
  end
  
  for k,_ in spairs(prices) do
    if (k > level) then
      return price
    else
      matlevel = k
      price = prices[k]
    end
  end
  
  return price
end


---
-- @param prices @class table  proper base-price table for item
-- @param level @class number  level of item
-- @param itemtype @class string  item's itemtype
-- @param itemnum @class number   item's item #
-- @return @class number   total base-price for item
function lib.GetTotalUnitsPrice(prices, level, itemtype, itemnum)
  local _,n = lib.LEVELS(level, itemtype, itemnum)
  
  return (n * lib.GetUnitPrice(prices, level))
end


---
-- @param improvefees @class table   Pricelist.improvefees
-- @param profession @class number  item's profession
-- @param quality @class number   item quality
-- @param improvQty @class function   function pointer to improvQty(profession, quality)
-- @return @class number   total fee to improve item to quality
function lib.GetTotalImproveFee(improvefees, profession, quality, improvQty)
  
  local fee = 0
  
  for i = 1, quality do
    local ff = improvefees[profession][i]
    fee = fee + (ff * improvQty(profession, i))
  end
  
  return fee
end


---
-- @param PriceList @class PriceList   The PriceList SavedVar
-- @param order @class ORDER   the order record
-- @param profession @class number  item's profession
-- @param improvQty @class function   function pointer to improvQty(profession, quality)
-- @return @class table   table of fees to improve item to each quality
function lib.GetImproveFeesPerQual(PriceList, order, profession, improvQty)
  local t = {}
  
  for i = 1, 4 do
    local pr = lib.GetTotalImproveFee(PriceList.improvefees, profession, i, improvQty)
    table.insert(t, lib.GDP(PriceList, order, pr))
  end
  
  return t
end


---
-- @param PriceList @class PriceList   The PriceList SavedVar
-- @param itemtype @class string   the item's itemtype
-- @param level @class number    the item's level
-- @param enchant @class number   the enchant number
-- @return @class number  fee for enchanting the item
function lib.GetEnchantFee(PriceList, itemtype, level, enchant)
  
  local aw = lib.ARM_WEAP(itemtype)
  
  local P = PriceList.enchant.pot
  local E = PriceList.enchant.ess[aw]
  
  local lev = lib.NormalizeLevel(P, level)
  
  return P[lev] + E[enchant]
end



---
-- @param PriceList @class PriceList   The PriceList SavedVar
-- @param order @class ORDER   the order record
-- @param price @class number   the price to be discounted
-- @return @class number    the discounted price
function lib.GDP(PriceList, order, price)
  if (not order.guildie) then
    return price
  end
  
  return math.floor(price * ((100 - PriceList.discount) / 100))
end




---
-- @param itemtype @class string
-- @return @class string table subkey for PriceList.price
function lib.GetPriceTable(itemtype)
  local pieces = {
    ['light'] = "lightarm",
    ['med'] = "medarm",
    ['heavy'] = "metals",
    ['1h'] = "metals",
    ['2h'] = "metals",
    ['dstaff'] = "woods",
    ['rstaff'] = "woods",
    ['bow'] = "woods",
    ['shield'] = "woods",
  }
  
  return pieces[itemtype]
end


function lib.PIECES(itemtype, extra)
  local pieces = {
    ['pieces'] = {"chest", "feet", "hands", "head", "legs", "shoulders", "waist"},
    ['light'] = {"Robe", "Shoes", "Gloves", "Hat", "Breeches", "Epaulets", "Sash", "Jerkin"},
    ['med'] = {"Jack", "Boots", "Bracers", "Helmet", "Guards", "Arm Cops", "Belt"},
    ['heavy'] = {"Cuirass", "Sabatons", "Gauntlets", "Helm", "Greaves", "Pauldron", "Girdle"},
    ['light_'] = {"Robe (chest)", "Shoes (feet)", "Gloves (hands)", "Hat (head)", "Breeches (legs)", "Epaulets (shoulders)", "Sash (waist)", "Jerkin (chest)"},
    ['med_'] = {"Jack (chest)", "Boots (feet)", "Bracers (hands)", "Helmet (head)", "Guards (legs)", "Arm Cops (shoulders)", "Belt (waist)"},
    ['heavy_'] = {"Cuirass (chest)", "Sabatons (feet)", "Gauntlets (hands)", "Helm (head)", "Greaves (legs)", "Pauldron (shoulders)", "Girdle (waist)"},
    ['1h'] = {"Axe", "Mace", "Sword", "Dagger"},
    ['2h'] = {"Battle Axe", "Maul", "Greatsword"},
    ['dstaff'] = {"Flame Staff", "Frost Staff", "Lightning Staff"},
    ['rstaff'] = {"Restoration Staff"},
    ['bow'] = {"Bow"},
    ['shield'] = {"Shield"},
    ['improve'] = {"Fine/green", "Superior/blue", "Epic/purple", "Legendary/gold"},
  }
  
  local prompts = {
    ['light'] = "Say 1 for %s, 2 for %s, 3 for %s, 4 for %s, 5 for %s, 6 for %s, 7 for %s, 8 for %s",
    ['med'] = "Say 1 for %s, 2 for %s, 3 for %s, 4 for %s, 5 for %s, 6 for %s, 7 for %s",
    ['heavy'] = "Say 1 for %s, 2 for %s, 3 for %s, 4 for %s, 5 for %s, 6 for %s, 7 for %s",
    ['1h'] = "Say 1 for %s, 2 for %s, 3 for %s, 4 for %s",
    ['2h'] = "Say 1 for %s, 2 for %s, 3 for %s",
    ['dstaff'] = "Say 1 for %s, 2 for %s, 3 for %s",
    ['improve'] = 'Say "no" for normal, 1 for %s (add %sg), 2 for %s (add %sg), 3 for %s (add %sg), 4 for %s (add %sg)',
  }
  
  local itype = itemtype
  
  if (extra and in_array(itype, {'light', 'med', 'heavy'})) then
    itype = itype .. '_'
  end
  
  
  return pieces[itype], prompts[itemtype]
end


function lib.ARM_WEAP(itemtype)
  if (in_array(itemtype, {"light", "med", "heavy", "shield"})) then
    return "armor"
  else
    return "weapon"
  end
end


function lib.PROF(itemtype)
  if (in_array(itemtype, {'heavy','1h','2h'})) then
    return PROFESSION_SMITH
  elseif (in_array(itemtype, {'med','light'})) then
    return PROFESSION_CLOTH
  else
    return PROFESSION_WOOD
  end
end


---
-- @param item @class ITEM
-- @param level @class number
-- @param plain @class boolean
-- @return @class string
function lib.GetName(item, level, plain)
  
  if (item.ISFEE) then
    return item.FEENAME
  end
  
  
  local lev
  local mat
  
  if (level == lib.RESEARCH_LEVEL) then
    lev = "Any Level (for research)"
    mat = ""
  else
    lev = lib.LEVELS(level, "level")
    mat = lib.GetMat(item, level, true) .. " "
  end
  
  local pieces, _ = lib.PIECES(item.itemtype)
  local nam = pieces[item.item]
  
  if (plain and (plain == "list")) then
    if (in_array(item.itemtype, {'light','med','heavy','1h','2h'})) then
      lev = item.itemtype
    else
      lev = ''
    end
    pieces, _ = lib.PIECES(item.itemtype, true)
    nam = pieces[item.item]
    mat = ''
  end
  
  if (item.style == 0) then
    return zo_strformat("<<1>> <<2>><<3>>", lev, mat, nam)
  else
    local style = lib.MOTIFS(item.style)
    local sname = style.name
    if (style.crown and not plain) then
      sname = zo_strformat("|cff0000*<<1>>*|r", sname)
    end
    return zo_strformat("<<1>> <<2>><<3>> [<<4>>]", lev, mat, nam, sname)
  end
  
end
-- end lib.GetName(item, level, plain)



---
-- @param item @class ITEM
-- @param level @class number
-- @param itemname @class boolean
-- @return @class string
function lib.GetMat(item, level, itemname)
  local mat
  
  if (item.profession == PROFESSION_SMITH) then
    mat = lib.METALS(level)
  elseif (item.profession == PROFESSION_CLOTH) then
    if (item.itemtype == "med") then
      mat = lib.MCLOTHS(level)
    else
      mat = lib.LCLOTHS(level)
    end
  elseif (item.profession == PROFESSION_WOOD) then
    mat = lib.WOODS(level)
  end
  
  if (itemname and mat.itemname) then
    return mat.itemname
  else
    return mat.matname
  end
end



---
-- @param item @class ITEM
-- @return @class string
function lib.GetDescr(item)
  
  if (item.ISFEE) then
    return ""
  end
  
  local t = {}
  local improve = lib.PIECES("improve")
  table.insert(improve, 1, "Normal/white")
  table.insert(t, improve[item.improvement + 1])
  if (item.trait) then
    table.insert(t, item.trait)
  else
    table.insert(t, "No Trait")
  end
  if (item.set > 0) then
    local set = lib.ARM_SETS(item.set)
    table.insert(t, set.name)
  else
    table.insert(t, "Non-Set")
  end
  if (item.enchant > 0) then
    local aw = lib.ARM_WEAP(item.itemtype)
    local glyphs = lib.GLYPHS(aw)
    table.insert(t, zo_strformat("<<1>> Enchant", glyphs[item.enchant]))
  else
    table.insert(t, "No Enchant")
  end
  
  return table.concat(t, ", ")
end


---
-- @return @class ITEM
function lib.ITEM()
  local t = {
    profession = 0,
    itemtype = "",
    item = 0,
    improvement = 0,
    trait = false,
    set = 0,
    style = 0,
    enchant = 0,
    price = 0,
    fee = 0,
    ISFEE = false,
    FEENAME = "",
    mats = {
      items = {},         -- array of @class PROFITREC
      traits = {},
      styles = {},
      improves = {},
      potents = {},
      essances = {},
    },
  }
  
  return t
end



function lib.ENCHANTS(aw)
  local enchants = {
    armor = {
      {
        glyph = "Health",
        rune = "Oko",
        potency = "+",
        Header = "Maximum Health Enchantment",
      },
      
      {
        glyph = "Magicka",
        rune = "Makko",
        potency = "+",
        Header = "Maximum Magicka Enchantment",
      },
      
      {
        glyph = "Stamina",
        rune = "Deni",
        potency = "+",
        Header = "Maximum Stamina Enchantment",
      },
      
      {
        glyph = "Prismatic Defense",
        rune = "Hakeijo",
        potency = "+",
        Header = "Multi-Effect Enchantment",
      },
      
    },
    weapon = {
      {
        glyph = "Flame",
        rune = "Rakeipa",
        potency = "+",
        Header = "Fiery Weapon Enchantment",
      },
      
      {
        glyph = "Frost",
        rune = "Dekeipa",
        potency = "+",
        Header = "Frozen Weapon Enchantment",
      },
      
      {
        glyph = "Shock",
        rune = "Meip",
        potency = "+",
        Header = "Charged Weapon Enchantment",
      },
      
      {
        glyph = "Hardening",
        rune = "Deteri",
        potency = "+",
        Header = "Hardening Enchantment",
      },
      
      {
        glyph = "Foulness",
        rune = "Haoko",
        potency = "+",
        Header = "Befouled Weapon Enchantment",
      },
      
      {
        glyph = "Poison",
        rune = "Kuoko",
        potency = "+",
        Header = "Poisoned Weapon Enchantment",
      },
      
      {
        glyph = "Weapon Damage",
        rune = "Okori",
        potency = "+",
        Header = "Weapon Damage Enchantment",
      },
      
      {
        glyph = "Absorb Health",
        rune = "Oko",
        potency = "-",
        Header = "Life Drain Enchantment",
      },
      
      {
        glyph = "Absorb Magicka",
        rune = "Makko",
        potency = "-",
        Header = "Absorb Magicka Enchantment",
      },
      
      {
        glyph = "Absorb Stamina",
        rune = "Deni",
        potency = "-",
        Header = "Absorb Stamina Enchantment",
      },
      
      {
        glyph = "Crushing",
        rune = "Deteri",
        potency = "-",
        Header = "Crusher Enchantment",
      },
      
      {
        glyph = "Prismatic Onslaught",
        rune = "Hakeijo",
        potency = "-",
        Header = "Enchantment",
      },
      
      {
        glyph = "Decrease Health",
        rune = "Okoma",
        potency = "-",
        Header = "Decrease Health Enchantment",
      },
      
      {
        glyph = "Weakening",
        rune = "Okori",
        potency = "-",
        Header = "Weakening Enchantment",
      },
      
    },
  }
  
  return enchants[aw]
end


function lib.GLYPHS(aw)
  local arr = lib.ENCHANTS(aw)
  local t = {}
  
  for _,r in ipairs(arr) do
    table.insert(t, r.glyph)
  end
  
  return t
end


function lib.ESSENCE(aw, i)
  local arr = lib.ENCHANTS(aw)
  
  if (type(i) == "number") then
    return arr[i]
  else
    return arr
  end
end


function lib.MOTIFS(i)
  local styles = {
    -- 1
    {
      name = "Altmer (High Elf)",
      mat = "Adamantite",
      Type = ITEMSTYLE_RACIAL_HIGH_ELF,
    },
    
    -- 2
    {
      name = "Dunmer (Dark Elf)",
      mat = "Obsidian",
      Type = ITEMSTYLE_RACIAL_DARK_ELF,
    },
    
    -- 3
    {
      name = "Bosmer (Wood Elf)",
      mat = "Bone",
      Type = ITEMSTYLE_RACIAL_WOOD_ELF,
    },
    
    -- 4
    {
      name = "Nord",
      mat = "Corundum",
      Type = ITEMSTYLE_RACIAL_NORD,
    },
    
    -- 5
    {
      name = "Breton",
      mat = "Molybdenum",
      Type = ITEMSTYLE_RACIAL_BRETON,
    },
    
    -- 6
    {
      name = "Redguard",
      mat = "Starmetal",
      Type = ITEMSTYLE_RACIAL_REDGUARD,
    },
    
    -- 7
    {
      name = "Khajiit",
      mat = "Moonstone",
      Type = ITEMSTYLE_RACIAL_KHAJIIT,
    },
    
    -- 8
    {
      name = "Orc",
      mat = "Manganese",
      Type = ITEMSTYLE_RACIAL_ORC,
    },
    
    -- 9
    {
      name = "Argonian",
      mat = "Flint",
      Type = ITEMSTYLE_RACIAL_ARGONIAN,
    },
    
    -- 10
    {
      name = "Imperial",
      mat = "Nickel",
      Type = ITEMSTYLE_RACIAL_IMPERIAL,
    },
    
    -- 11
    {
      name = "Ancient Elf",
      mat = "Palladium",
      Type = ITEMSTYLE_AREA_ANCIENT_ELF,
    },
    
    -- 12
    {
      name = "Barbaric",
      mat = "Bronze",
      Type = ITEMSTYLE_AREA_REACH,
    },
    
    -- 13
    {
      name = "Primal",
      mat = "Argentum",
      Type = ITEMSTYLE_ENEMY_PRIMITIVE,
    },
    
    -- 14
    {
      name = "Daedric",
      mat = "Daedra Heart",
      Type = ITEMSTYLE_ENEMY_DAEDRIC,
    },
    
    -- 15
    {
      name = "Dwemer",
      mat = "Dwemer Frame",
      Type = ITEMSTYLE_AREA_DWEMER,
    },
    
    -- 16
    {
      name = "Glass",
      mat = "Malachite",
      Type = ITEMSTYLE_GLASS,
    },
    
    -- 17
    {
      name = "Xivkyn",
      mat = "Charcoal of Remorse",
      Type = ITEMSTYLE_AREA_XIVKYN,
    },
    
    -- 18
    {
      name = "Akaviri",
      mat = "Goldscale",
      Type = ITEMSTYLE_AREA_AKAVIRI,
    },
    
    -- 19
    {
      name = "Mercenary",
      mat = "Laurel",
      Type = ITEMSTYLE_UNDAUNTED,
    },
    
    -- 20
    {
      name = "Ancient Orc",
      mat = "Cassiterite",
      Type = ITEMSTYLE_AREA_ANCIENT_ORC,
    },
    
    -- 21
    {
      name = "Trinimac",
      mat = "Auric Tusk",
      Type = ITEMSTYLE_DEITY_TRINIMAC,
    },
    
    -- 22
    {
      name = "Malacath",
      mat = "Potash",
      Type = ITEMSTYLE_DEITY_MALACATH,
    },
    
    -- 23
    {
      name = "Outlaw",
      mat = "Rogue's Soot",
      Type = ITEMSTYLE_ORG_OUTLAW,
    },
    
    -- 24
    {
      name = "Aldmeri Dominion",
      mat = "Eagle Feather",
      Type = ITEMSTYLE_ALLIANCE_ALDMERI,
    },
    
    -- 25
    {
      name = "Daggerfall Covenant",
      mat = "Lion Fang",
      Type = ITEMSTYLE_ALLIANCE_DAGGERFALL,
    },
    
    -- 26
    {
      name = "Ebonheart Pact",
      mat = "Dragon Scute",
      Type = ITEMSTYLE_ALLIANCE_EBONHEART,
    },
    
    -- 27
    {
      name = "Soul-Shriven",
      mat = "Azure Plasm",
      Type = ITEMSTYLE_AREA_SOUL_SHRIVEN,
    },
    
    -- 28
    {
      name = "Abah's Watch",
      mat = "Polished Shilling",
      Type = ITEMSTYLE_ORG_ABAHS_WATCH,
    },
    
    -- 29
    {
      name = "Thieves Guild",
      mat = "Fine Chalk",
      Type = ITEMSTYLE_ORG_THIEVES_GUILD,
    },
    
    -- 30
    {
      name = "Assassins League",
      mat = "Tainted Blood",
      Type = ITEMSTYLE_ORG_ASSASSINS,
    },
    
    -- 31
    {
      name = "Dro-m'Athra",
      mat = "Defiled Whiskers",
      Type = ITEMSTYLE_ENEMY_DROMOTHRA,
    },
    
    -- 32
    {
      name = "Dark Brotherhood",
      mat = "Black Beeswax",
      Type = ITEMSTYLE_ORG_DARK_BROTHERHOOD,
    },
    
    -- 33
    {
      name = "Minotaur",
      mat = "Oxblood Fungus",
      Type = ITEMSTYLE_ENEMY_MINOTAUR,
    },
    
    -- 34
    {
      name = "Order of the Hour",
      mat = "Pearl Sand",
      Type = ITEMSTYLE_DEITY_AKATOSH,
    },
    
    -- 35
    {
      name = "Yokudan",
      mat = "Ferrous Salts",
      Type = ITEMSTYLE_AREA_YOKUDAN,
    },
    
    -- 36
    {
      name = "Skinchanger",
      mat = "Wolfsbane Incense",
      Type = ITEMSTYLE_HOLIDAY_SKINCHANGER,
    },
    
    -- 37
    {
      name = "Draugr",
      mat = "Pristine Shroud",
      Type = ITEMSTYLE_ENEMY_DRAUGR,
    },
    
    -- 38
    {
      name = "Celestial",
      mat = "Star Sapphire",
      Type = ITEMSTYLE_RAIDS_CRAGLORN,
    },
    
    -- 39
    {
      name = "Hollowjack",
      mat = "Amber Marble",
      Type = ITEMSTYLE_HOLIDAY_HOLLOWJACK,
    },
    
    -- 40
    {
      name = "Grim Harlequin",
      mat = "Grinstones",
      Type = ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN,
      crown = true,
    },
    
    -- 41
    {
      name = "Ra Gada",
      mat = "Ancient Sandstone",
      Type = ITEMSTYLE_AREA_RA_GADA,
    },
    
    -- 42
    {
      name = "Morag Tong",
      mat = "Boiled Carapace",
      Type = ITEMSTYLE_ORG_MORAG_TONG,
    },
    
    -- 43
    {
      name = "Ebony",
      mat = "Night Pumice",
      Type = ITEMSTYLE_EBONY,
    },
    
    -- 44
    {
      name = "Silken Ring",
      mat = "Distilled Slowsilver",
      Type = ITEMSTYLE_ENEMY_SILKEN_RING,
    },
    
    -- 45
    {
      name = "Mazzatun",
      mat = "Leviathan Scrimshaw",
      Type = ITEMSTYLE_ENEMY_MAZZATUN,
    },
    
    -- 46
    {
      name = "Frostcaster",
      mat = "Stalhrim Shard",
      Type = ITEMSTYLE_HOLIDAY_FROSTCASTER,
      crown = true,
    },
    
    -- 47
    {
      name = "Buoyant Armiger",
      mat = "Volcanic Viridian",
      Type = ITEMSTYLE_ORG_BUOYANT_ARMIGER,
    },
    
    -- 48
    {
      name = "Ashlander",
      mat = "Ash Canvas",
      Type = ITEMSTYLE_AREA_ASHLANDER,
    },
    
    -- 49
    {
      name = "Militant Ordinator",
      mat = "Lustrous Sphalerite",
      Type = ITEMSTYLE_ORG_ORDINATOR,
    },
    
    -- 50
    {
      name = "Telvanni",
      mat = "Wrought Ferrofungus",
      Type = ITEMSTYLE_ORG_TELVANNI,
    },
    
    -- 51
    {
      name = "Hlaalu",
      mat = "Refined Bonemold Resin",
      Type = ITEMSTYLE_ORG_HLAALU,
    },
    
    -- 52
    {
      name = "Redoran",
      mat = "Polished Scarab Elytra",
      Type = ITEMSTYLE_ORG_REDORAN,
    },
    
    -- 53
    {
      name = "Bloodforge",
      mat = "Bloodroot Flux",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 54
    {
      name = "Dreadhorn",
      mat = "Minotaur Bezoar",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 55
    {
      name = "Apostle",
      mat = "Tempered Brass",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 56
    {
      name = "Ebonshadow",
      mat = "Tenebrous Cord",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 57
    {
      name = "Worm Cult",
      mat = "Desecrated Grave Soil",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 58
    {
      name = "Fang Lair",
      mat = "Dragon Bone",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 59
    {
      name = "Scalecaller",
      mat = "Infected Flesh",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 60
    {
      name = "Psijic",
      mat = "Vitrified Malondo",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 61
    {
      name = "Sapiarch",
      mat = "Culanda Lacquer",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 62
    {
      name = "Pyandonean",
      mat = "Sea Serpent Hide",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 63
    {
      name = "Tsaisci",
      mat = "Snake Fang",
      crown = true,
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 64
    {
      name = "Dremora",
      mat = "Warrior's Heart Ashes",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 65
    {
      name = "Huntsman",
      mat = "Bloodscent Dew",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 66
    {
      name = "Silver Dawn",
      mat = "Argent Pelt",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 67
    {
      name = "Welkynar",
      mat = "Gryphon Plume",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 68
    {
      name = "Dead-Water",
      mat = "Crocodile Leather",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 69
    {
      name = "Elder Argonian",
      mat = "Hackwing Plumage",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 70
    {
      name = "Honor Guard",
      mat = "Red Diamond Seal",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 71
    {
      name = "Coldsnap",
      mat = "Goblin-cloth Scrap",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 72
    {
      name = "Meridian",
      mat = "Auroran Dust",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 73
    {
      name = "Anequina",
      mat = "Shimmering Sand",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 74
    {
      name = "Pellitine",
      mat = "Dragonthread",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 75
    {
      name = "Sunspire",
      mat = "Frost Embers",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 76
    {
      name = "Dragonguard",
      mat = "Gilding Salts",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 77
    {
      name = "Stags of Z'en",
      mat = "Oath Cord",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 78
    {
      name = "Moongrave Fane",
      mat = "Blood of Sahrotnax",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 79
    {
      name = "Refabricated",
      mat = "Polished Rivets",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 80
    {
      name = "Shield of Senchal",
      mat = "Carmine Shieldsilk",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
    -- 81
    {
      name = "New Moon Priest",
      mat = "Aeonstone Shard",
      Type = lib.ITEMSTYLE_CWC_COMPAT,
    },
    
  }
  
  
  if (type(i) == "number") then
    return styles[i]
  elseif (i == "all") then
    return styles
  else
    return #styles
  end
end
-- end lib.MOTIFS(i)


function lib.ARM_SETS(i)
  local sets = {
    -- 1
    {
      name = "Death's Wind",
      traits = 2,
      loc = {
        ad = {
          zone = "Auridon",
          craft = "Eastshore islets camp",
          way = "Vulkhel Guard Wayshrine",
        },
        dc = {
          zone = "Glenumbra",
          craft = "Chillhouse",
          way = "Wyrd Tree Wayshrine",
        },
        ep = {
          zone = "Stonefalls",
          craft = "Armature's upheaval",
          way = "Brothers of Strife Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 2
    {
      name = "Night's Silence",
      traits = 2,
      loc = {
        ad = {
          zone = "Auridon",
          craft = "Hightide keep",
          way = "Skywatch Wayshrine",
        },
        dc = {
          zone = "Glenumbra",
          craft = "Mesanthano's tower",
          way = "Hag Fen Wayshrine",
        },
        ep = {
          zone = "Stonefalls",
          craft = "Steamfont cavern",
          way = "Davon's Watch Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 3
    {
      name = "Ashen Grip",
      traits = 2,
      loc = {
        ad = {
          zone = "Auridon",
          craft = "Beacon falls",
          way = "Firsthold Wayshrine,College Wayshrine",
        },
        dc = {
          zone = "Glenumbra",
          craft = "Par Molag",
          way = "Crosswych Wayshrine",
        },
        ep = {
          zone = "Stonefalls",
          craft = "Magmaflow overlook",
          way = "Ashen Road Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 4
    {
      name = "Torug's Pact",
      traits = 3,
      loc = {
        ad = {
          zone = "Grahtwood",
          craft = "Fisherman's isle",
          way = "Haven Wayshrine",
        },
        dc = {
          zone = "Stormhaven",
          craft = "Hammerdeath workshop",
          way = "Firebrand Keep Wayshrine,Pariah Abbey Wayshrine,Wayrest Wayshrine",
        },
        ep = {
          zone = "Deshaan",
          craft = "Lake hlaalu retreat",
          way = "West Narsis Wayshrine,Obsidian Gorge Wayshrine,Quarantine Serk Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 5
    {
      name = "Twilight's Embrace",
      traits = 3,
      loc = {
        ad = {
          zone = "Grahtwood",
          craft = "Vineshade lodge",
          way = "Elden Root Wayshrine,Haven Wayshrine",
        },
        dc = {
          zone = "Stormhaven",
          craft = "Windrige warehouse",
          way = "Alcaire Castle Wayshrine,Firebrand Keep Wayshrine",
        },
        ep = {
          zone = "Deshaan",
          craft = "Avayan's farm",
          way = "Tal'Deic Grounds Wayshrine,Eidolon's Hollow Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 6
    {
      name = "Armor of the Seducer",
      traits = 3,
      loc = {
        ad = {
          zone = "Grahtwood",
          craft = "Temple of the eight",
          way = "Gil-Var-Delle Wayshrine",
        },
        dc = {
          zone = "Stormhaven",
          craft = "Fisherman's island",
          way = "Dro'dara Plantation Wayshrine,Wayrest Wayshrine",
        },
        ep = {
          zone = "Deshaan",
          craft = "Berezan's mine",
          way = "Mzithumz Wayshrine,Mournhold Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 7
    {
      name = "Trial By Fire",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Wrothgar",
          dlc = "Orsinium",
          craft = "Malacath statue",
          way = "Shatul Wayshrine,Orsinium Wayshrine",
        },
      },
    },
    
    -- 8
    {
      name = "Magnus' Gift",
      traits = 4,
      loc = {
        ad = {
          zone = "Greenshade",
          craft = "Arananga",
          way = "Labyrinth Wayshrine",
        },
        dc = {
          zone = "Rivenspire",
          craft = "Vaewind ede",
          way = "Northpoint Wayshrine,Staging Grounds Wayshrine",
        },
        ep = {
          zone = "Shadowfen",
          craft = "Xal Haj-ei shrine",
          way = "Stormhold Wayshrine,Bogmother Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 9
    {
      name = "Hist Bark",
      traits = 4,
      loc = {
        ad = {
          zone = "Greenshade",
          craft = "Rootwatch tower",
          way = "Serpent's Grotto Wayshrine",
        },
        dc = {
          zone = "Rivenspire",
          craft = "Trader's Rest",
          way = "Oldgate Wayshrine,Hoarfrost Downs Wayshrine",
        },
        ep = {
          zone = "Shadowfen",
          craft = "Hatchling's crown",
          way = "Percolating Mire Wayshrine,Hissmir Wayshrine,Hatching Pools Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 10
    {
      name = "Whitestrake's Retribution",
      traits = 4,
      loc = {
        ad = {
          zone = "Greenshade",
          craft = "Lenalda pond",
          way = "Verrant Morass Wayshrine,Moonhenge Wayshrine",
        },
        dc = {
          zone = "Rivenspire",
          craft = "Westwind lighthouse",
          way = "Northpoint Wayshrine",
        },
        ep = {
          zone = "Shadowfen",
          craft = "Weeping wamasu falls",
          way = "Venomous Fens Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 11
    {
      name = "Vampire's Kiss",
      traits = 5,
      loc = {
        ad = {
          zone = "Malabal Tor",
          craft = "Matthild's last venture",
          way = "Dra'Bul Wayshrine,Ilayas Ruins Wayshrine",
        },
        dc = {
          zone = "Alik'r Desert",
          craft = "Artisan's oasis",
          way = "Kulati Mines Wayshrine,Bergama Wayshrine",
        },
        ep = {
          zone = "Eastmarch",
          craft = "Crimson Kada's crafting cavern",
          way = "Fort Amol Wayshrine,Wittestadr Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 12
    {
      name = "Song Of Lamae",
      traits = 5,
      loc = {
        ad = {
          zone = "Malabal Tor",
          craft = "Sleepy senche overlook",
          way = "Abamath Wayshrine,Valeguard Wayshrine",
        },
        dc = {
          zone = "Alik'r Desert",
          craft = "Rkulftzel",
          way = "Sep's Spine Wayshrine,Leki's Blade Wayshrine,Kulati Mines Wayshrine",
        },
        ep = {
          zone = "Eastmarch",
          craft = "Tinkerer Tobin's workshop",
          way = "Logging Camp Wayshrine,Kynesgrove Wayshrine,Jorunn's Stand Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 13
    {
      name = "Alessia's Bulwark",
      traits = 5,
      loc = {
        ad = {
          zone = "Malabal Tor",
          craft = "Chancel of divine entreaty",
          way = "Vulkwasten Wayshrine,Wilding Vale Wayshrine,Valeguard Wayshrine",
        },
        dc = {
          zone = "Alik'r Desert",
          craft = "Alezer kotu",
          way = "Divad's Chagrin Mine Wayshrine,Morwha's Bounty Wayshrine,Sentinel Wayshrine",
        },
        ep = {
          zone = "Eastmarch",
          craft = "Hammerhome",
          way = "Jorunn's Stand Wayshrine,Logging Camp Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 14
    {
      name = "Noble's Conquest",
      traits = 5,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Imperial City",
          dlc = "Imperial City",
          craft = "Noble district",
          way = "",
        },
      },
    },
    
    -- 15
    {
      name = "Tava's Favor",
      traits = 5,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Hew's Bane",
          dlc = "Thieves Guild",
          craft = "Forebear's junction",
          way = "No Shira Citadel Wayshrine",
        },
      },
    },
    
    -- 16
    {
      name = "Kvatch Gladiator",
      traits = 5,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Gold Coast",
          dlc = "Dark Brotherhood",
          craft = "Marja's mill",
          way = "Kvatch Wayshrine,Gold Coast Wayshrine,Anvil Wayshrine",
        },
      },
    },
    
    -- 17
    {
      name = "Night Mother's Gaze",
      traits = 6,
      loc = {
        ad = {
          zone = "Reaper's March",
          craft = "Old town cavern",
          way = "Fort Grimwatch Wayshrine,Arenthia Wayshrine",
        },
        dc = {
          zone = "Bangkorai",
          craft = "Silaseli ruins",
          way = "Eastern Evermore Wayshrine,Halcyon Lake Wayshrine",
        },
        ep = {
          zone = "The Rift",
          craft = "Eldbjorg's hideway",
          way = "Nimalten Wayshrine,Northwind Mine Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 18
    {
      name = "Law of Julianos",
      traits = 6,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Wrothgar",
          dlc = "Orsinium",
          craft = "Boreal forge",
          way = "Great Bay Wayshrine,Siege Road Wayshrine,Frostbreak Ridge Wayshrine",
        },
      },
    },
    
    -- 19
    {
      name = "Willow's Path",
      traits = 6,
      loc = {
        ad = {
          zone = "Reaper's March",
          craft = "Greenspeaker's grove",
          way = "Vinedusk Wayshrine,Fort Grimwatch Wayshrine,Rawl'kha Wayshrine",
        },
        dc = {
          zone = "Bangkorai",
          craft = "Viridian hideaway",
          way = "Troll's Toothpick Wayshrine",
        },
        ep = {
          zone = "The Rift",
          craft = "Smokefrost vigil",
          way = "Skald's Retreat Wayshrine,Riften Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 20
    {
      name = "Hunding's Rage",
      traits = 6,
      loc = {
        ad = {
          zone = "Reaper's March",
          craft = "Broken arch",
          way = "Moonmont Wayshrine,Willowgrove Wayshrine,Rawl'kha Wayshrine",
        },
        dc = {
          zone = "Bangkorai",
          craft = "Wether's cleft",
          way = "Old Tower Wayshrine",
        },
        ep = {
          zone = "The Rift",
          craft = "Trollslayer gully",
          way = "Honrich Tower Wayshrine,Skald's Retreat Wayshrine",
        },
        special = {
          zone = "",
          dlc = "",
          craft = nil,
          way = "",
        },
      },
    },
    
    -- 21
    {
      name = "Redistributor",
      traits = 7,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Imperial City",
          dlc = "Imperial City",
          craft = "Arboretum district",
          way = "",
        },
      },
    },
    
    -- 22
    {
      name = "Clever Alchemist",
      traits = 7,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Hew's Bane",
          dlc = "Thieves Guild",
          craft = "No shira workshop",
          way = "No Shira Citadel Wayshrine",
        },
      },
    },
    
    -- 23
    {
      name = "Varen's Legacy",
      traits = 7,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Gold Coast",
          dlc = "Dark Brotherhood",
          craft = "Strid river artisan's camp",
          way = "Strid River Wayshrine,Anvil Wayshrine",
        },
      },
    },
    
    -- 24
    {
      name = "Kagrenac's Hope",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Fighter's Guild",
          dlc = nil,
          craft = "Earth forge",
          way = "The Earth Forge,Rawl'kha Wayshrine,Riften Wayshrine,Evermore Wayshrine",
        },
      },
    },
    
    -- 25
    {
      name = "Orgnum's Scales",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Fighter's Guild",
          dlc = nil,
          craft = "Earth forge: pressure room 3",
          way = "The Earth Forge,Rawl'kha Wayshrine,Riften Wayshrine,Evermore Wayshrine",
        },
      },
    },
    
    -- 26
    {
      name = "Eyes Of Mara",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Mage's Guild",
          dlc = nil,
          craft = "Eyevea",
          way = "Eyevea,Rawl'kha Wayshrine,Riften Wayshrine,Evermore Wayshrine",
        },
      },
    },
    
    -- 27
    {
      name = "Shalidor's Curse",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Mage's Guild",
          dlc = nil,
          craft = "Eyevea",
          way = "Eyevea Wayshrine,Rawl'kha Wayshrine,Riften Wayshrine,Evermore Wayshrine",
        },
      },
    },
    
    -- 28
    {
      name = "Oblivion's Foe",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Coldharbour",
          dlc = nil,
          craft = "Font of schemes",
          way = "Haj Uxith Wayshrine,Hollow City Wayshrine",
        },
      },
    },
    
    -- 29
    {
      name = "Spectre's Eye",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Coldharbour",
          dlc = nil,
          craft = "Deathspinner's lair",
          way = "Everfull Flagon Wayshrine,Court of Contempt Wayshrine",
        },
      },
    },
    
    -- 30
    {
      name = "Way Of The Arena",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Craglorn",
          dlc = nil,
          craft = "Lanista's waystation",
          way = "Seeker's Archive Wayshrine,Belkarth Wayshrine",
        },
      },
    },
    
    -- 31
    {
      name = "Twice-Born Star",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Craglorn",
          dlc = nil,
          craft = "Atelier of the twice-born star",
          way = "Skyreach Wayshrine,Valley of Scars Wayshrine,Dragonstar Wayshrine,Belkarth Wayshrine",
        },
      },
    },
    
    -- 32
    {
      name = "Armor Master",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Imperial City",
          dlc = "Imperial City",
          craft = "Memorial district",
          way = "",
        },
      },
    },
    
    -- 33
    {
      name = "Morkuldin",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Wrothgar",
          dlc = "Orsinium",
          craft = "Morkuldin forge",
          way = "Shatul Wayshrine,Two Rivers Wayshrine,Icy Shore Wayshrine",
        },
      },
    },
    
    -- 34
    {
      name = "Eternal Hunt",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Hew's Bane",
          dlc = "Thieves Guild",
          craft = "The lost pavilion",
          way = "Abah's Landing Wayshrine",
        },
      },
    },
    
    -- 35
    {
      name = "Pelinal's Aptitude",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Gold Coast",
          dlc = "Dark Brotherhood",
          craft = "Colovian revolt forge yard",
          way = "Gold Coast Wayshrine,Anvil Wayshrine,Kvatch Wayshrine",
        },
      },
    },
    
    -- 36
    {
      name = "Assassin's Guile",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Vvardenfell",
          dlc = "*MORROWIND*",
          craft = "Marandus",
          way = "Suran Wayshrine",
        },
      },
    },
    
    -- 37
    {
      name = "Shacklebreaker",
      traits = 6,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Vvardenfell",
          dlc = "*MORROWIND*",
          craft = "Zergonipal",
          way = "Valley of the Wind Wayshrine",
        },
      },
    },
    
    -- 38
    {
      name = "Daedric Trickery",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Vvardenfell",
          dlc = "*MORROWIND*",
          craft = "Randas Ancestral Tomb",
          way = "West Gash Wayshrine",
        },
      },
    },
    
    -- 39
    {
      name = "Innate Axiom",
      traits = 2,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Clockwork City",
          dlc = "Clockwork City",
          craft = "The Refurbishing Yard",
          way = "Clockwork Crossroads Wayshrine",
        },
      },
    },
    
    -- 40
    {
      name = "Fortified Brass",
      traits = 4,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Clockwork City",
          dlc = "Clockwork City",
          craft = "Restricted Brassworks",
          way = "Clockwork Crossroads Wayshrine",
        },
      },
    },
    
    -- 41
    {
      name = "Mechanical Acuity",
      traits = 6,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Clockwork City",
          dlc = "Clockwork City",
          craft = "Pavillion of Artifice",
          way = "Clockwork Crossroads Wayshrine",
        },
      },
    },
    
    -- 42
    {
      name = "Adept Rider",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Summerset",
          dlc = "*Summerset*",
          craft = "Shimmerene Dockworks",
          way = "Eldbur Ruins Wayshrine",
        },
      },
    },
    
    -- 43
    {
      name = "Sload's Semblance",
      traits = 6,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Artaeum",
          dlc = "*Summerset*",
          craft = "Artaeum's Craftworks",
          way = "Artaeum Wayshrine",
        },
      },
    },
    
    -- 44
    {
      name = "Noctournal's Favor",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Summerset",
          dlc = "*Summerset*",
          craft = "Augury Basin",
          way = "Lillandril Wayshrine,Ebon Stadmont Wayshrine,The Crystal Tower Wayshrine",
        },
      },
    },
    
    -- 45
    {
      name = "Naga Shaman",
      traits = 2,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Murkmire",
          dlc = "Murkmire",
          craft = "Deep Swamp Forge",
          way = "Dead-Water Wayshrine,Blackrose Prison Wayshrine",
        },
      },
    },
    
    -- 46
    {
      name = "Might of the Lost Legion",
      traits = 4,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Murkmire",
          dlc = "Murkmire",
          craft = "Ruined Village",
          way = "Blackrose Prison Wayshrine,Bright-Throat Wayshrine",
        },
      },
    },
    
    -- 47
    {
      name = "Grave-Stake Collector",
      traits = 7,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Murkmire",
          dlc = "Murkmire",
          craft = "Sweet Breeze Overlook",
          way = "Dead-Water Wayshrine,Bright-Throat Wayshrine,Blackrose Prison Wayshrine",
        },
      },
    },
    
    -- 48
    {
      name = "Vastarie's Tutelage",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Elsweyr",
          dlc = "*Elsweyr*",
          craft = "Rimmen Masterworks",
          way = "Rimmen Wayshrine",
        },
      },
    },
    
    -- 49
    {
      name = "Coldharbour's Favorite",
      traits = 5,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Elsweyr",
          dlc = "*Elsweyr*",
          craft = "Valenwood Border Artisan Camp",
          way = "Scar's End Wayshrine",
        },
      },
    },
    
    -- 50
    {
      name = "Senche-raht's Grit",
      traits = 8,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Elsweyr",
          dlc = "*Elsweyr*",
          craft = "Starlight Adeptorium",
          way = "Star Haven Wayshrine,Riverhold Wayshrine",
        },
      },
    },
    
    -- 51
    {
      name = "Ancient Dragonguard",
      traits = 6,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Southern Elsweyr",
          dlc = "Dragonhold",
          craft = "Dragonguard Sanctuary",
          way = "Dragonguard Sanctuary",
        },
      },
    },
    
    -- 52
    {
      name = "Daring Corsair",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Southern Elsweyr",
          dlc = "Dragonhold",
          craft = "Cat's Claw Station",
          way = "South Guard Ruins Wayshrine",
        },
      },
    },
    
    -- 53
    {
      name = "New Moon Acolyte",
      traits = 9,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Southern Elsweyr",
          dlc = "Dragonhold",
          craft = "Fur-Forge Cove",
          way = "Black Heights Wayshrine,Pridehome Wayshrine",
        },
      },
    },
    
    -- 54
    {
      name = "Dauntless Combatant",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Cyrodiil",
          dlc = "",
          craft = "Cropsford",
          way = "",
        },
      },
    },
    
    -- 55
    {
      name = "Unchained Aggressor",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Cyrodiil",
          dlc = "",
          craft = "Bruma",
          way = "",
        },
      },
    },
    
    -- 56
    {
      name = "Critical Riposte",
      traits = 3,
      loc = {
        ad = {
          zone = "",
          craft = nil,
          way = "",
        },
        dc = {
          zone = "",
          craft = nil,
          way = "",
        },
        ep = {
          zone = "",
          craft = nil,
          way = "",
        },
        special = {
          zone = "Cyrodiil",
          dlc = "",
          craft = "Vlastarus",
          way = "",
        },
      },
    },
    
  }
  
  
  if (type(i) == "number") then
    if (i == 0) then
      return false
    else
      return sets[i]
    end
  else
    return #sets
  end
end


function lib.LEVELS(level, itemtype, itemnum)
  local levels = {
    [1] = {
      champion = 0,
      ['1h'] = {3, 3, 3, 2},
      ['2h'] = {5, 5, 5},
      ['bow'] = {3},
      ['dstaff'] = {3,3,3},
      ['rstaff'] = {3},
      ['shield'] = {6},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {7,5,5,5,6,5,5},
    },
    
    [4] = {
      champion = 0,
      ['1h'] = {4, 4, 4, 3},
      ['2h'] = {6, 6, 6},
      ['bow'] = {4},
      ['dstaff'] = {4,4,4},
      ['rstaff'] = {4},
      ['shield'] = {7},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {8,6,6,6,7,6,6},
    },
    
    [6] = {
      champion = 0,
      ['1h'] = {5,5,5,4},
      ['2h'] = {7,7,7},
      ['bow'] = {5},
      ['dstaff'] = {5,5,5},
      ['rstaff'] = {5},
      ['shield'] = {8},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {9,7,7,7,8,7,7},
    },
    
    [8] = {
      champion = 0,
      ['1h'] = {6,6,6,5},
      ['2h'] = {8,8,8},
      ['bow'] = {6},
      ['dstaff'] = {6,6,6},
      ['rstaff'] = {6},
      ['shield'] = {9},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {10,8,8,8,9,8,8},
    },
    
    [10] = {
      champion = 0,
      ['1h'] = {7,7,7,6},
      ['2h'] = {9,9,9},
      ['bow'] = {7},
      ['dstaff'] = {7,7,7},
      ['rstaff'] = {7},
      ['shield'] = {10},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {11,9,9,9,10,9,9},
    },
    
    [12] = {
      champion = 0,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [14] = {
      champion = 0,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [16] = {
      champion = 0,
      ['1h'] = {4,4,4,3},
      ['2h'] = {6,6,6},
      ['bow'] = {4},
      ['dstaff'] = {4,4,4},
      ['rstaff'] = {4},
      ['shield'] = {7},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {8,6,6,6,7,6,6},
    },
    
    [18] = {
      champion = 0,
      ['1h'] = {5,5,5,4},
      ['2h'] = {7,7,7},
      ['bow'] = {5},
      ['dstaff'] = {5,5,5},
      ['rstaff'] = {5},
      ['shield'] = {8},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {9,7,7,7,8,7,7},
    },
    
    [20] = {
      champion = 0,
      ['1h'] = {6,6,6,5},
      ['2h'] = {8,8,8},
      ['bow'] = {6},
      ['dstaff'] = {6,6,6},
      ['rstaff'] = {6},
      ['shield'] = {9},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {10,8,8,8,9,8,8},
    },
    
    [22] = {
      champion = 0,
      ['1h'] = {7,7,7,6},
      ['2h'] = {9,9,9},
      ['bow'] = {7},
      ['dstaff'] = {7,7,7},
      ['rstaff'] = {7},
      ['shield'] = {10},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {11,9,9,9,10,9,9},
    },
    
    [24] = {
      champion = 0,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [26] = {
      champion = 0,
      ['1h'] = {5,5,5,4},
      ['2h'] = {7,7,7},
      ['bow'] = {5},
      ['dstaff'] = {5,5,5},
      ['rstaff'] = {5},
      ['shield'] = {8},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {9,7,7,7,8,7,7},
    },
    
    [28] = {
      champion = 0,
      ['1h'] = {6,6,6,5},
      ['2h'] = {8,8,8},
      ['bow'] = {6},
      ['dstaff'] = {6,6,6},
      ['rstaff'] = {6},
      ['shield'] = {9},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {10,8,8,8,9,8,8},
    },
    
    [30] = {
      champion = 0,
      ['1h'] = {7,7,7,6},
      ['2h'] = {9,9,9},
      ['bow'] = {7},
      ['dstaff'] = {7,7,7},
      ['rstaff'] = {7},
      ['shield'] = {10},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {11,9,9,9,10,9,9},
    },
    
    [32] = {
      champion = 0,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [34] = {
      champion = 0,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [36] = {
      champion = 0,
      ['1h'] = {6,6,6,5},
      ['2h'] = {8,8,8},
      ['bow'] = {6},
      ['dstaff'] = {6,6,6},
      ['rstaff'] = {6},
      ['shield'] = {9},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {10,8,8,8,9,8,8},
    },
    
    [38] = {
      champion = 0,
      ['1h'] = {7,7,7,6},
      ['2h'] = {9,9,9},
      ['bow'] = {7},
      ['dstaff'] = {7,7,7},
      ['rstaff'] = {7},
      ['shield'] = {10},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {11,9,9,9,10,9,9},
    },
    
    [40] = {
      champion = 0,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [42] = {
      champion = 0,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [44] = {
      champion = 0,
      ['1h'] = {10,10,10,9},
      ['2h'] = {12,12,12},
      ['bow'] = {10},
      ['dstaff'] = {10,10,10},
      ['rstaff'] = {10},
      ['shield'] = {13},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {14,12,12,12,13,12,12},
    },
    
    [46] = {
      champion = 0,
      ['1h'] = {7,7,7,6},
      ['2h'] = {9,9,9},
      ['bow'] = {7},
      ['dstaff'] = {7,7,7},
      ['rstaff'] = {7},
      ['shield'] = {10},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {11,9,9,9,10,9,9},
    },
    
    [48] = {
      champion = 0,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [50] = {
      champion = 0,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [51] = {
      champion = 10,
      ['1h'] = {8,8,8,7},
      ['2h'] = {10,10,10},
      ['bow'] = {8},
      ['dstaff'] = {8,8,8},
      ['rstaff'] = {8},
      ['shield'] = {11},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {12,10,10,10,11,10,10},
    },
    
    [52] = {
      champion = 20,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [53] = {
      champion = 30,
      ['1h'] = {10,10,10,9},
      ['2h'] = {12,12,12},
      ['bow'] = {10},
      ['dstaff'] = {10,10,10},
      ['rstaff'] = {10},
      ['shield'] = {13},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {14,12,12,12,13,12,12},
    },
    
    [54] = {
      champion = 40,
      ['1h'] = {9,9,9,8},
      ['2h'] = {11,11,11},
      ['bow'] = {9},
      ['dstaff'] = {9,9,9},
      ['rstaff'] = {9},
      ['shield'] = {12},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {13,11,11,11,12,11,11},
    },
    
    [55] = {
      champion = 50,
      ['1h'] = {10,10,10,9},
      ['2h'] = {12,12,12},
      ['bow'] = {10},
      ['dstaff'] = {10,10,10},
      ['rstaff'] = {10},
      ['shield'] = {13},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {14,12,12,12,13,12,12},
    },
    
    [56] = {
      champion = 60,
      ['1h'] = {11,11,11,10},
      ['2h'] = {13,13,13},
      ['bow'] = {11},
      ['dstaff'] = {11,11,11},
      ['rstaff'] = {11},
      ['shield'] = {14},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {15,13,13,13,14,13,13},
    },
    
    [57] = {
      champion = 70,
      ['1h'] = {10,10,10,9},
      ['2h'] = {12,12,12},
      ['bow'] = {10},
      ['dstaff'] = {10,10,10},
      ['rstaff'] = {10},
      ['shield'] = {13},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {14,12,12,12,13,12,12},
    },
    
    [58] = {
      champion = 80,
      ['1h'] = {11,11,11,10},
      ['2h'] = {13,13,13},
      ['bow'] = {11},
      ['dstaff'] = {11,11,11},
      ['rstaff'] = {11},
      ['shield'] = {14},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {15,13,13,13,14,13,13},
    },
    
    [59] = {
      champion = 90,
      ['1h'] = {11,11,11,10},
      ['2h'] = {13,13,13},
      ['bow'] = {11},
      ['dstaff'] = {11,11,11},
      ['rstaff'] = {11},
      ['shield'] = {14},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {15,13,13,13,14,13,13},
    },
    
    [60] = {
      champion = 100,
      ['1h'] = {12,12,12,11},
      ['2h'] = {14,14,14},
      ['bow'] = {12},
      ['dstaff'] = {12,12,12},
      ['rstaff'] = {12},
      ['shield'] = {15},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {16,14,14,14,15,14,14},
    },
    
    [61] = {
      champion = 110,
      ['1h'] = {13,13,13,12},
      ['2h'] = {15,15,15},
      ['bow'] = {13},
      ['dstaff'] = {13,13,13},
      ['rstaff'] = {13},
      ['shield'] = {16},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {17,15,15,15,16,15,15},
    },
    
    [62] = {
      champion = 120,
      ['1h'] = {14,14,14,13},
      ['2h'] = {16,16,16},
      ['bow'] = {14},
      ['dstaff'] = {14,14,14},
      ['rstaff'] = {14},
      ['shield'] = {17},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {18,16,16,16,17,16,16},
    },
    
    [63] = {
      champion = 130,
      ['1h'] = {15,15,15,14},
      ['2h'] = {17,17,17},
      ['bow'] = {15},
      ['dstaff'] = {15,15,15},
      ['rstaff'] = {15},
      ['shield'] = {18},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {19,17,17,17,18,17,17},
    },
    
    [64] = {
      champion = 140,
      ['1h'] = {16,16,16,15},
      ['2h'] = {18,18,18},
      ['bow'] = {16},
      ['dstaff'] = {16,16,16},
      ['rstaff'] = {16},
      ['shield'] = {19},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {20,18,18,18,19,18,18},
    },
    
    [65] = {
      champion = 150,
      ['1h'] = {11,11,11,10},
      ['2h'] = {14,14,14},
      ['bow'] = {12},
      ['dstaff'] = {12,12,12},
      ['rstaff'] = {12},
      ['shield'] = {14},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {15,13,13,13,14,13,13},
    },
    
    [66] = {
      champion = 160,
      ['1h'] = {110,110,110,100},
      ['2h'] = {140,140,140},
      ['bow'] = {120},
      ['dstaff'] = {120,120,120},
      ['rstaff'] = {120},
      ['shield'] = {140},
      ['light'] = {},
      ['med'] = {},
      ['heavy'] = {150,130,130,130,140,130,130},
    },
    
  }
  
  
  local ret
  
  local lev = lib.NormalizeLevel(levels, level);
  
  ret = levels[lev]
  
  ret.med = clone(ret.heavy)
  ret.light = clone(ret.heavy)
  ret.light[8] = ret.light[1]
  
  if (itemtype) then
    if (itemtype == "level") then
      if (lev > 50) then
        if (itemnum) then
          if (itemnum == "short") then
            return zo_strformat("CP <<1>>", levels[lev].champion)
          else
            return lev, zo_strformat("Level 50, CP <<1>>", levels[lev].champion)
          end
        else
          return zo_strformat("Level 50, CP <<1>>", levels[lev].champion)
        end
      else
        if (itemnum and (type(itemnum) == "boolean")) then
          return lev, zo_strformat("Level <<1>>", lev)
        else
          return zo_strformat("Level <<1>>", lev)
        end
      end
    end
    
    ret = levels[lev][itemtype]
    
    if (itemnum) then
      ret = levels[lev][itemtype][itemnum]
    end
  end
  
  return lev, ret
end



function lib.METALS(level)
  local metals = {
    [1] = {
      matname = "Iron",
      itemname = nil,
    },
    [16] = {
      matname = "Steel",
      itemname = nil,
    },
    [26] = {
      matname = "Orichalcum",
      itemname = nil,
    },
    [36] = {
      matname = "Dwarven",
      itemname = nil,
    },
    [46] = {
      matname = "Ebony",
      itemname = nil,
    },
    [51] = {
      matname = "Calcinium",
      itemname = nil,
    },
    [54] = {
      matname = "Galatite",
      itemname = nil,
    },
    [57] = {
      matname = "Quicksilver",
      itemname = nil,
    },
    [59] = {
      matname = "Voidstone",
      itemname = "Voidsteel",
    },
    [65] = {
      matname = "Rubedite",
      itemname = nil,
    },
  }
  
  
  if (not level) then return metals end
  
  local lev = lib.NormalizeLevel(metals, level);
  
  return metals[lev]
end


function lib.WOODS(level)
  local woods = {
    [1] = {
      matname = "Maple",
    },
    [16] = {
      matname = "Oak",
    },
    [26] = {
      matname = "Beech",
    },
    [36] = {
      matname = "Hickory",
    },
    [46] = {
      matname = "Yew",
    },
    [51] = {
      matname = "Birch",
    },
    [54] = {
      matname = "Ash",
    },
    [57] = {
      matname = "Mahogany",
    },
    [59] = {
      matname = "Nightwood",
    },
    [65] = {
      matname = "Ruby Ash",
    },
  }
  
  
  if (not level) then return woods end
  
  local lev = lib.NormalizeLevel(woods, level);
  
  return woods[lev]
end


function lib.LCLOTHS(level)
  local cloths = {
    [1] = {
      matname = "Jute",
      itemname = "Homespun",
    },
    [16] = {
      matname = "Flax",
      itemname = "Linen",
    },
    [26] = {
      matname = "Cotton",
      itemname = nil,
    },
    [36] = {
      matname = "Spidersilk",
      itemname = nil,
    },
    [46] = {
      matname = "Ebonthread",
      itemname = nil,
    },
    [51] = {
      matname = "Kresh Fiber",
      itemname = "Kresh",
    },
    [54] = {
      matname = "Iron Thread",
      itemname = nil,
    },
    [57] = {
      matname = "Silverweave",
      itemname = nil,
    },
    [59] = {
      matname = "Void Cloth",
      itemname = "Shadowspun",
    },
    [65] = {
      matname = "Ancestor Silk",
      itemname = nil,
    },
  }
  
  
  if (not level) then return cloths end
  
  local lev = lib.NormalizeLevel(cloths, level);
  
  return cloths[lev]
end


function lib.MCLOTHS(level)
  local cloths = {
    [1] = {
      matname = "Rawhide",
      itemname = nil,
    },
    [16] = {
      matname = "Hide",
      itemname = nil,
    },
    [26] = {
      matname = "Leather",
      itemname = nil,
    },
    [36] = {
      matname = "Thick Leather",
      itemname = "Full Leather",
    },
    [46] = {
      matname = "Fell Hide",
      itemname = "Fell",
    },
    [51] = {
      matname = "Topgrain Hide",
      itemname = "Brigandine",
    },
    [54] = {
      matname = "Iron Hide",
      itemname = "Ironhide",
    },
    [57] = {
      matname = "Superb Hide",
      itemname = "Superb",
    },
    [59] = {
      matname = "Shadowhide",
      itemname = nil,
    },
    [65] = {
      matname = "Rubedo Leather",
      itemname = nil,
    },
  }
  
  
  if (not level) then return cloths end
  
  local lev = lib.NormalizeLevel(cloths, level);
  
  return cloths[lev]
end


---
-- @param t @class table
-- @param level @class number
-- @return @class number
function lib.NormalizeLevel(t, level)
  local lev = 0
  
  if (level == lib.RESEARCH_LEVEL) then
    return lib.RESEARCH_LEVEL_EQUIV
  end
  
  
  for k,_ in spairs(t) do
    if (k > level) then
      break
    else
      lev = k
    end
  end
  
  return lev
end
