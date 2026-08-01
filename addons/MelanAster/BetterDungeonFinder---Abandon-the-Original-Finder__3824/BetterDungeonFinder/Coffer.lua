local BAF = BetterDungonFinder

local OldFun = ItemTooltip.SetStoreItem
ItemTooltip.SetStoreItem = function(self, ...)
  local result = OldFun(self, ...)
  if BAF and BAF.savedVariables.CofferHelper then
    local itemLink = GetStoreItemLink(...)
    local itemId = GetItemLinkItemId(itemLink)
    local textList = BAF.CofferTooltipText(itemId)
    if textList[1] then 
      self:AddLine("") 
      for i = 1, #textList do
        self:AddLine(textList[i])
      end
    end
  end
  return result
end

function BAF.CofferTooltipText(itemId)
  local setIds = BAF.CofferInfo[itemId]
  local cofferIds = BAF.RandomCofferInfo[itemId]
  local textList = {}
  --1 key Coffer
  if cofferIds then
    local rUnlock, rTotal = 0, 0
    for i = 1, #cofferIds do
      local cofferName = GetItemLinkName("|H0:item:"..cofferIds[i]..":30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
      local text, cUnlock, cTotal = BAF.CofferTooltipText(cofferIds[i])
      rUnlock = rUnlock + cUnlock
      rTotal = rTotal + cTotal
      if cUnlock == cTotal then
        table.insert(textList, cofferName.." |c008000100%|r")
      else
        table.insert(textList, cofferName.." |cFF0000"..cUnlock.." / "..cTotal.."|r")
      end
    end
    if rUnlock == rTotal then
      table.insert(textList, "\r\n|c008000100%|r")
    else
      local keyEXP = rTotal/(rTotal - rUnlock)
      local keyText = ""
      if keyEXP > 8 then
        keyText = "|cFF0000"..string.format("%.2f", keyEXP).."|r"
      else
        keyText = "|c008000"..string.format("%.2f", keyEXP).."|r"
      end
      table.insert(textList, 
        "\r\n|t16:16:esoui/art/guild/history/guildhistory_unlock_up.dds|t "..rUnlock.." / "..rTotal.."\r\n"..
        keyText..
        " |t16:16:esoui/art/currency/undauntedkey_64.dds|t / |t16:16:esoui/art/guild/history/guildhistory_unlock_up.dds|t"
      )
    end
    return textList
  end
  --8 key Coffer
  if setIds then
    local cUnlock, cTotal = 0, 0
    for i = 1, #setIds do
      cTotal = cTotal + 3
      local sUnlock = 0
      for j = 4, 6 do
        if IsItemSetCollectionPieceUnlocked(GetItemSetCollectionPieceInfo(setIds[i], j)) then
          sUnlock = sUnlock + 1
        end
      end
      cUnlock = cUnlock + sUnlock
      if sUnlock == 3 then
        table.insert(textList, GetItemSetName(setIds[i]).." |c008000100%|r")
      else
        table.insert(textList, GetItemSetName(setIds[i]).." |cFF0000"..sUnlock.." / 3|r")
      end
    end
    return textList, cUnlock, cTotal
  end
  return textList
end