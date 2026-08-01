---------------
--To insert number from old desc to new desc
function FIXCS.InsertNumber(NewDescT, OldDescT)
  local ReturnT = {}
  for a = 1, #NewDescT do
    if NewDescT[a] == "" then
      ReturnT[a] = OldDescT[a]
    else
      local NumString = {}
      for word in string.gmatch(OldDescT[a], "|c......%d+%.?%d?%d?|r") do
        table.insert(NumString, word)
      end
      local TepString = NewDescT[a]
      for b = 1, #NumString do
        while(string.find(TepString, "【"..b.."】")) do
          TepString = string.gsub(TepString,"【"..b.."】", NumString[b])
        end
      end
      ReturnT[a] = TepString
    end
  end
  return ReturnT
end
---------------
--To deal with skill info
function FIXCS.SkillCombo(...)
  --Skill info
  local SType, SSubType, SIndex, Morph, _,_,_,_,_,_,_,_,_, Soid = ...
  local abilityId = Soid or GetSpecificSkillAbilityInfo(SType, SSubType, SIndex, Morph, 1)
  --For Debug
  FIXCS.Debug("Skill", GetAbilityName(abilityId), abilityId)
  --Read skill new info
  if FIXCS.SkillFixed[abilityId] == nil then return end
  
  return FIXCS.InsertNumber({FIXCS.SkillFixed[abilityId][1]}, {GetAbilityDescription(abilityId)})
end
---------------
--To deal with cp info
function FIXCS.CPCombo(CPId, NowPoint, FullPoint,...)
  --Read cp new info
  FIXCS.Debug("CP", GetChampionSkillName(CPId), CPId)
  if FIXCS.CPFixed[CPId] == nil then return end
  
  local NewDesc = FIXCS.CPFixed[CPId]
  local OldDesc = {}
  OldDesc[1] = GetChampionSkillDescription(CPId, NowPoint)
  OldDesc[2] = GetChampionSkillCurrentBonusText(CPId, NowPoint)
  
  return FIXCS.InsertNumber(NewDesc, OldDesc)
end
---------------
--To deal with Item info
function FIXCS.ItemCombo(ItemLink)
  local HasSet, _, _, Normal, _, SetID, Perfect = GetItemLinkSetInfo(ItemLink)
  FIXCS.CompCombo(ItemLink)
  --For Debug
  FIXCS.TestLink = ItemLink
  FIXCS.Debug("Item", ItemLink, SetID)
  --Need change?
  if HasSet == false then return end
  if FIXCS.ItemFixed[SetID] == nil then return end
  
  --String handle
  local NewDesc = FIXCS.ItemFixed[SetID]
  local OldDesc = {}
  local Color = {}
  for i = 1, #NewDesc do
    _, OldDesc[i] = GetItemLinkSetBonusInfo(ItemLink, false, i)
  end
  local ReturnDesc = FIXCS.InsertNumber(NewDesc, OldDesc)
  --Num of wearing gear handle
  for i = 1, #ReturnDesc do
    local Num, _, IsPerfect = GetItemLinkSetBonusInfo(ItemLink, true, i)
    if IsPerfect then
      if Num > Perfect then table.insert(Color,i) end
    else
      if Num > (Normal + Perfect) then table.insert(Color,i) end
    end
  end

  return ReturnDesc, Color
end
---------------
--Prepare itemlink for Comparating
function FIXCS.CompCombo(ItemLink)
  FIXCS.MatchedComp = {["ComparativeTooltip1"] = "", ["ComparativeTooltip2"] = ""}
  --Weapon
  if GetItemLinkWeaponType(ItemLink) ~= 0 then
    local _,_,_, IsMain = GetWornItemInfo(0,4)
    local _,_,_, IsMain2 = GetWornItemInfo(0,5)
    if IsMain or IsMain2 then
      if GetItemLink(0, 4) ~= "" then
        FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 4)
        FIXCS.MatchedComp["ComparativeTooltip2"] = GetItemLink(0, 5)
      else
        FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 5)
      end
    else
      if GetItemLink(0, 20) ~= "" then
        FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 20)
        FIXCS.MatchedComp["ComparativeTooltip2"] = GetItemLink(0, 21)
      else
        FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 21)
      end
    end
  end
  --Other slots
  local ArmorType = GetItemLinkEquipType(ItemLink)
  if ArmorType == 1 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 0) end
  if ArmorType == 2 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 1) end
  if ArmorType == 3 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 2) end
  if ArmorType == 4 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 3) end
  if ArmorType == 8 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 6) end
  if ArmorType == 13 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 16) end
  if ArmorType == 9 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 8) end
  if ArmorType == 10 then FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 9) end
  --Ring
  if ArmorType == 12 then
    if GetItemLink(0, 11) ~= "" then
      FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 11)
      FIXCS.MatchedComp["ComparativeTooltip2"] = GetItemLink(0, 12)
    else
      FIXCS.MatchedComp["ComparativeTooltip1"] = GetItemLink(0, 12)
    end
  end
end