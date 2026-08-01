local obj, db, lom, msg = Snoop

function obj.Setup(addon)
  if addon ~= "Snoop" then return end

  obj.Defaults = {
    gold       = true,
    loot       = true,
    show       = IsESOPlusSubscriber(),
    count      = true,
    craft      = true,
    party      = true,
    goldR      = 1,
    goldG      = 1,
    goldB      = 0.3,
    lostR      = 1,
    lostG      = 0,
    lostB      = 0,
    lootR      = 0.2,
    lootG      = 1.0,
    lootB      = 0.6,
    partyR     = 0,
    partyG     = 0.4,
    partyB     = 0.7,
    craftR     = 0.9,
    craftG     = 0.8,
    craftB     = 0.7
  }

  SnoopSettings = SnoopSettings or obj.Defaults
  db            = SnoopSettings
  lom           = LibStub:GetLibrary("LibOmniMessage-3.0")


  EVENT_MANAGER:RegisterForEvent("Snoop_Gold",  EVENT_MONEY_UPDATE,    obj.GoldPrint)
  EVENT_MANAGER:RegisterForEvent("Snoop_Loot",  EVENT_LOOT_RECEIVED,   obj.LootPrint)
  EVENT_MANAGER:RegisterForEvent("Snoop_Craft", EVENT_CRAFT_COMPLETED, obj.CraftPrint)

  if obj.SetupMenu  then obj.SetupMenu(db)  end
  if obj.SetupSlash then obj.SetupSlash(db) end

  EVENT_MANAGER:UnregisterForEvent("Snoop_Load")
end

function obj.GoldPrint(_, newMoney, oldMoney)
  if newMoney == oldMoney or not db.gold then return end

  local goldState  = (newMoney > oldMoney) and (newMoney - oldMoney) or (oldMoney - newMoney)
  local textState  = (newMoney > oldMoney) and obj.strings.gained    or obj.strings.lost
  local colorState = (newMoney > oldMoney) and "gold" or "lost"
  local texture    = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
  colorState       = obj.HexFromRGB(db[colorState.."R"], db[colorState.."G"], db[colorState.."B"])

  lom:Send("|c<<LOM-GOLDCOLOR>><<LOM-GOLDTEXT>>:<<LOM-CLEAR>> <<LOM-GOLDNUM>><<LOM-TEXTURE>>", {GOLDCOLOR=colorState, CLEAR=lom.clearColor, GOLDTEXT=textState, GOLDNUM=goldState, TEXTURE=texture})
end

function obj.LootPrint(_, lootedBy, itemLink, quantity, _, lootType, isPlayer, isCrafted)
  if lootType == 2 then return end

  if (isPlayer and db.loot) or isCrafted then
    local lootColor = obj.HexFromRGB(db[(isCrafted and "craft" or "loot").."R"], db[(isCrafted and "craft" or "loot").."G"], db[(isCrafted and "craft" or "loot").."B"])

    lom:Send("|c<<LOM-LOOTCOLOR>><<LOM-LOOTED>>:<<LOM-CLEAR>> [<<LOM-ITEMLINK>>]"..(isCrafted and "" or "<<LOM-BLUE>> x <<LOM-CLEAR>><<LOM-ITEMCOUNT>>"), {LOOTCOLOR=lootColor, BLUE="|cccccff", CLEAR=lom.clearColor, LOOTED=obj.strings[(isCrafted and "crafted" or "looted")], ITEMLINK=itemLink, ITEMCOUNT=quantity})

    if db.count then
      local inBag, inBank, inCraft = GetItemLinkStacks(itemLink) 
      local bagTexture             = "|t16:16:/esoui/art/tooltips/icon_bag.dds|t"
      local bankTexture            = "|t16:16:/esoui/art/tooltips/icon_bank.dds|t"
      local craftTexture           = "|t16:16:/esoui/art/hud/loothistory_icon_craftbag.dds|t"

      lom:Send("|c<<LOM-LOOTCOLOR>><<LOM-COUNT>>:<<LOM-CLEAR>><<LOM-BAGTEXTURE>><<LOM-BAG>> <<LOM-BLUE>>/<<LOM-CLEAR>><<LOM-BANKTEXTURE>> <<LOM-BANK>> <<LOM-BLUE>>"..(db.show and "/<<LOM-CLEAR>><<LOM-CRAFTTEXTURE>><<LOM-CRAFT>>" or "<<LOM-CLEAR>>"), {LOOTCOLOR=lootColor, BLUE="|cccccff", CLEAR=lom.clearColor, COUNT=obj.strings.counted, BAG=inBag, BANK=inBank, CRAFT=inCraft, BAGTEXTURE=bagTexture, BANKTEXTURE=bankTexture, CRAFTTEXTURE=craftTexture})
    end

  elseif not isPlayer and db.party then
    local partyColor = obj.HexFromRGB(db.partyR, db.partyG, db.partyB)

    lom:Send("|c<<LOM-PARTYCOLOR>><<LOM-LOOTER>> <<LOM-LOOTED>>:<<LOM-CLEAR>> [<<LOM-ITEMLINK>>]<<LOM-BLUE>> x <<LOM-CLEAR>><<LOM-ITEMCOUNT>>", {PARTYCOLOR=partyColor, CLEAR=lom.clearColor, BLUE="|cccccff", LOOTED=obj.strings.looted:lower(), ITEMLINK=itemLink, ITEMCOUNT=quantity, LOOTER=lootedBy:gsub("%^%a+", "")})
  end
end

function obj.CraftPrint()
  if not db.craft then return end

  local itemLink       = GetLastCraftingResultItemLink()
  local _, _, quantity = GetLastCraftingResultItemInfo()

  if not itemLink then return end

  obj.LootPrint(nil, nil, itemLink, quantity, nil, 0, true, true)
end

function obj.DecToHex(numberRGB)
  numberRGB       = numberRGB * 255
  local stringRGB = ""
  local stringHex = "0123456789abcdef"
  local numberMod

  while numberRGB > 0 do
    numberMod = math.fmod(numberRGB, 16) + 1
    stringRGB = stringHex:sub(numberMod, numberMod)..stringRGB
    numberRGB = math.floor(numberRGB / 16)
  end

  return (stringRGB == "" and "00") or (#stringRGB < 2 and "0"..stringRGB) or stringRGB
end

function obj.HexFromRGB(r, g, b)
  return obj.DecToHex(r)..obj.DecToHex(g)..obj.DecToHex(b)
end

EVENT_MANAGER:RegisterForEvent("Snoop_Load", EVENT_ADD_ON_LOADED, function(_, addon) obj.Setup(addon) end)