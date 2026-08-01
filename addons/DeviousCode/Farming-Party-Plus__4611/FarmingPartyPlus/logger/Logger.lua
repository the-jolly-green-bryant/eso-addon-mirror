local Addon = FarmingPartyPlus
local Logger = ZO_Object:Subclass()

Addon.Classes.Logger = Logger

function Logger:Finalize()
end

local function GetItemIcon(itemLink, lootType)
  local icon = ''
  if lootType == LOOT_TYPE_COLLECTIBLE then
    local collectibleId = GetCollectibleIdFromLink(itemLink)
    local _, _, collectibleIcon = GetCollectibleInfo(collectibleId)
    icon = collectibleIcon
  else
    local itemIcon = GetItemLinkInfo(itemLink)
    icon = itemIcon or ''
  end
  icon = icon ~= '' and ('|t16:16:' .. icon .. '|t ') or ''
  return icon
end

local function CreateTimestamp()
  local timeString = GetTimeString()
  local hours, minutes, seconds = timeString:match('([^%:]+):([^%:]+):([^%:]+)')
  local month, day, year = GetDateStringFromTimestamp(GetTimeStamp()):match('(%d+).(%d+).(%d+)')

  local timestamp = FarmingPartyPlus.Settings:GetSettings().logWindow.timestampFormat
  local replace = {
    DD = day,
    MM = month,
    YYYY = year,
    HH = hours,
    mm = minutes,
    ss = seconds
  }

  return zo_strformat('|cFFFFFF<<1>>|r', timestamp:gsub('%a+', replace))
end

local function BuildItemText(itemLink, quantity, totalValue, lootType, priceSourceLabel)
  local icon = GetItemIcon(itemLink, lootType)
  local displayQuantity = math.abs(quantity)
  local displayTotalValue = math.abs(totalValue)
  local valueColor = quantity < 0 and 'FF5555' or 'FFFFFF'
  local itemValueText = ''
  if FarmingPartyPlus.Settings:DisplayLootValue() then
    itemValueText = zo_strformat(' - |c' .. valueColor .. '<<1>>|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t', FarmingPartyPlus.FormatNumber(displayTotalValue))
    if FarmingPartyPlus.Settings:DisplayLootPriceSource() and priceSourceLabel ~= nil and priceSourceLabel ~= '' then
      itemValueText = itemValueText .. ' - ' .. priceSourceLabel
    end
  end
  local itemText

  if displayQuantity == 1 then
    itemText = zo_strformat(icon .. itemLink .. itemValueText)
  else
    itemText = zo_strformat(icon .. itemLink .. ' |cFFFFFFx' .. displayQuantity .. '|r' .. itemValueText)
  end

  return itemText
end

local function EmitLootMessage(lootMessage)
  if FarmingPartyPlus.Settings:DisplayInChat() then
    CHAT_SYSTEM:AddMessage(lootMessage)
  end

  local timestamp = FarmingPartyPlus.Settings:ShowWindowTimestamp() and CreateTimestamp() or ''
  FarmingPartyPlusWindowBuffer:AddMessage(timestamp .. ' ' .. lootMessage, 255, 255, 0, 1)
end

function Logger:LogLootItem(looterName, lootedByPlayer, itemLink, quantity, totalValue, lootType, priceSourceLabel)
  if tonumber(quantity) == nil or tonumber(quantity) == 0 then
    return
  end

  local itemText = BuildItemText(itemLink, quantity, totalValue, lootType, priceSourceLabel)

  local lootMessage
  if quantity < 0 then
    if not lootedByPlayer then
      if not FarmingPartyPlus.Settings:DisplayGroupLoot() then
        return
      end
      lootMessage = zo_strformat('|cFFFFFF<<1>>|r |cCC8844processed|r <<2>>', looterName, itemText)
    else
      if not FarmingPartyPlus.Settings:DisplayOwnLoot() then
        return
      end
      lootMessage = zo_strformat('|cCC8844Processed|r <<1>>', itemText)
    end
  elseif not lootedByPlayer then
    if not FarmingPartyPlus.Settings:DisplayGroupLoot() then
      return
    end
    lootMessage = zo_strformat('|cFFFFFF<<1>>|r |c228B22received|r <<2>>', looterName, itemText)
  else
    if not FarmingPartyPlus.Settings:DisplayOwnLoot() then
      return
    end
    lootMessage = zo_strformat('|c228B22Received|r <<1>>', itemText)
  end

  EmitLootMessage(lootMessage)
end

function Logger:LogStackFound(looterName, lootedByPlayer, itemLink, quantity, totalValue, lootType, priceSourceLabel)
  if tonumber(quantity) == nil or tonumber(quantity) <= 0 then
    return
  end

  local itemText = BuildItemText(itemLink, quantity, totalValue, lootType, priceSourceLabel)
  local lootMessage

  if not lootedByPlayer then
    if not FarmingPartyPlus.Settings:DisplayGroupLoot() then
      return
    end
    lootMessage = zo_strformat('|cFFFFFF<<1>>|r |c66B3FFstack found|r <<2>>', looterName, itemText)
  else
    if not FarmingPartyPlus.Settings:DisplayOwnLoot() then
      return
    end
    lootMessage = zo_strformat('|c66B3FFStack Found|r <<1>>', itemText)
  end

  EmitLootMessage(lootMessage)
end
