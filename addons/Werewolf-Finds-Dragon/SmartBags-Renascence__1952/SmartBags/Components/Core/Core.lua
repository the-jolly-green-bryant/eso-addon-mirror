local obj, db = SmartBags

function obj.Setup(addon)
  if addon ~= "SmartBags" then return end

  obj.Defaults = {
    mode       = 1,
    unlock     = true,
    auto       = true,
    smart      = true,
    warn       = 80,
    alpha      = 1.0,
    wndMainX   = 79.699921,
    wndMainY   = 85.441338,
    baseR      = 0.572549,
    baseG      = 0.827451,
    baseB      = 1,
    warnR      = 0.905882,
    warnG      = 1,
    warnB      = 0.223529,
    fullR      = 1,
    fullG      = 0,
    fullB      = 0.003922
  }

  SmartBagsSettings = SmartBagsSettings or obj.Defaults

  db = SmartBagsSettings

  EVENT_MANAGER:UnregisterForEvent("SmartBagsLoad")
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsOpenBank",    EVENT_CLOSE_BANK,                   obj.HandleBank)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsCloseBank",   EVENT_OPEN_BANK,                    obj.HandleBank)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsBuyBank",     EVENT_INVENTORY_BUY_BANK_SPACE,     obj.UpdateBar)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsBuyBag",      EVENT_INVENTORY_BUY_BAG_SPACE,      obj.UpdateBar)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsZoneChannel", EVENT_ZONE_CHANNEL_CHANGED,         obj.UpdateBar)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsSlotUpdate",  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, obj.UpdateBar)
  EVENT_MANAGER:RegisterForEvent(  "SmartBagsPushed",      EVENT_ACTION_LAYER_PUSHED,          obj.panelState)

  SmartBagsUI:ClearAnchors()  
  SmartBagsUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, db.wndMainX, db.wndMainY)  
  SmartBagsUI:SetAlpha(db.alpha or 1.0)
  SmartBagsUI:SetHidden(false)

  if obj.SetupMenu  then obj.SetupMenu(db)  end
  if obj.SetupSlash then obj.SetupSlash(db) end

  SmartBagsUI:SetMovable(db.unlock)
  
  obj.barMain  = CreateControlFromVirtual("SmartBagsUI_Bag_PB", SmartBagsUI, "SmartBagsUI_Bag_ProgressBar")
  obj.barRight = CreateControlFromVirtual("SmartBagsUI_Bag_PBR", SmartBagsUI, "SmartBagsUI_Bag_ProgressBarRight")
  obj.modeIcon = CreateControlFromVirtual("BankBagIcon", SmartBagsUI, "SmartBagsUI_BankBagIcon")

  ZO_PreHook(ZO_PlayerInventory,     "SetHidden", obj.panelState)
  ZO_PreHook(ZO_CraftBag,            "SetHidden", obj.panelState)
  ZO_PreHook(ZO_PlayerBank,          "SetHidden", obj.panelState)
  ZO_PreHook(ZO_HouseBank,           "SetHidden", obj.panelState)
  ZO_PreHook(ZO_StoreWindow,         "SetHidden", obj.panelState)
  ZO_PreHook(ZO_SmithingTopLevel,    "SetHidden", obj.panelState)
  ZO_PreHook(ZO_AlchemyTopLevel,     "SetHidden", obj.panelState)
  ZO_PreHook(ZO_ProvisionerTopLevel, "SetHidden", obj.panelState)
  ZO_PreHook(ZO_EnchantingTopLevel,  "SetHidden", obj.panelState)
  ZO_PreHook(ZO_PlayerBank,          "SetHidden", obj.AutoBank)
  ZO_PreHook(ZO_HouseBank,           "SetHidden", obj.AutoBank)

  obj.UpdateBar()  
end

function obj.panelState(frame, state)
  if db.auto and frame == ZO_CraftBag then
    db.mode = 1
    obj.UpdateBar()
  end

  if db.smart then
    if obj.override then
      state = false

    elseif state ~= true and state ~= false then
      return
    end

    if windexAddon then windexAddon.noSmartBagsToggle = not state end

    if SmartBagsUI then SmartBagsUI:SetHidden(state) end
  end
end

function obj.AutoBank(_, state)
  if not db.auto then return end

  db.mode = state == false and 1 or 2

  obj.UpdateBar()
end

function obj.UpdateBar()
  if not db then return end

  local bag         = (db.mode == 1 and 1) or obj.bagID or ((not obj.bagID and db.mode == 2) and 2) or 1
  local used, total = obj.GetBagSlotsData(bag)

  obj.MainProgressBarUpdate(used, total)
  SmartBagsUIShowBagInfo:SetText(string.format("%s", string.format("%s", string.format(obj.SlotsColorCode(used, total)))))
  SmartBagsUIShowMoneyInfo:SetText(obj.MoneyColorCode(obj.FormatMoney(db.mode == 1 and GetCurrentMoney() or GetBankedMoney())))    
  obj.modeIcon:SetTexture("SmartBags/Components/Textures/"..string.format(db.mode)..".dds")
end

function obj.MainProgressBarUpdate(val, max)
  if not val or not max then return end

  local width = (295 / tonumber(max)) * tonumber(val)
  local state = (max == val and "full") or ((val / max * 100) >= db.warn and "warn") or "base"

  if db.smart then
    obj.override = state == "full"
  end

  obj.barMain:SetColor( db[state.."R"], db[state.."G"], db[state.."B"])
  obj.barRight:SetColor(db[state.."R"], db[state.."G"], db[state.."B"])
  obj.barMain:SetDimensions(width, 11)
  obj.barRight:ClearAnchors()
  obj.barRight:SetAnchor(RIGHT, obj.barMain, RIGHT, 11)
end

function obj.GetBagSlotsData(bag)
  local bagNotEmptySlots, bagSlots = GetNumBagUsedSlots(bag), GetBagUseableSize(bag)

  if bag == 2 and IsESOPlusSubscriber() then
    bagNotEmptySlots = bagNotEmptySlots + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
    bagSlots         = bagSlots         + GetBagUseableSize(BAG_SUBSCRIBER_BANK)
  end

  return bagNotEmptySlots, bagSlots
end

function obj.OnMouseDown(button)
  if button == 2 then obj.ToggleMode() end

  SmartBagsUI:SetMovable((button == 1 and db.unlock))
end

function obj.ToggleMode()
  db.mode = (db.mode == 1 and 2) or (db.mode == 2 and 1)

  obj.UpdateBar()
end

function obj.HandleBank(_, bag)
  obj.bagID = bag

  obj.ToggleMode()
end

function obj.FormatMoney(money)
  money = tostring(money)

  if money ~= "0" then
    local left, num, right = money:match("^([^%d]*%d)(%d*)(.-)$")
    money                  = left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
  end
  
  return money
end

function obj.Color(text, color)
  return ("|c%s%s|r"):format(color, text)
end

function obj.SlotsColorCode(slots, maxSlots)
  local slotsColor, maxSlotsColor

  if slots == maxSlots then
    slotsColor    = "ff0000"
    maxSlotsColor = "ff0000"

  elseif (slots - maxSlots > 0) and (slots - maxSlots <= 20) then
    slotsColor    = "ffa500"
    maxSlotsColor = "ffa500"

  else
    slotsColor    = "ffffff"
    maxSlotsColor = "ffffff"
  end

  return ("%s/%s"):format(obj.Color(slots, slotsColor), obj.Color(maxSlots, maxSlotsColor))
end

function obj.MoneyColorCode(money)
  return obj.Color(money, (money == 0 and "ff0000" or "ffffff"))
end

function obj.OnMoveStop()
  db.wndMainX = SmartBagsUI:GetLeft()
  db.wndMainY = SmartBagsUI:GetTop()
end

EVENT_MANAGER:RegisterForEvent("SmartBagsLoad", EVENT_ADD_ON_LOADED, function(_, addon) obj.Setup(addon) end)