---------------
FIXCS.DebugOff = true
--Debug Tool
function FIXCS.Debug(name, ...)
  if FIXCS.DebugOff then return end
  local Tep = {...}
  local Str = ""
  for k,v in ipairs(Tep) do
    if tostring(v) ~= nil then 
      Str = Str..", "..tostring(v)
    else
      Str = Str..", "..type(v)
    end
  end
  d(name..Str)
end
---------------
--Start point
local function OnAddOnLoaded(eventCode, addonName)
  --When addon loaded
  if addonName ~= FIXCS.name then return end
  EVENT_MANAGER:UnregisterForEvent(FIXCS.name, EVENT_ADD_ON_LOADED)
  --For zh special repair
  if GetCVar("language.2") == "zh" then
    SafeAddString(SI_RETRAIT_STATION_CONFIRM_ITEM_RECONSTRUCTION_DESCRIPTION, "确定要重构吗？此举将消耗：", 0)
    SafeAddString(SI_RETRAIT_STATION_CONFIRM_ITEM_RECONSTRUCTION_HEADER, "重构概览", 0)
    SafeAddString(SI_RETRAIT_STATION_PERFORM_RECONSTRUCT, "重构", 0)
    SafeAddString(SI_RETRAIT_STATION_RECONSTRUCT_ACTION, "重构", 0)
    SafeAddString(SI_RETRAIT_STATION_RECONSTRUCT_MODE, "重构", 0)
  end
  --For really loading
  EVENT_MANAGER:RegisterForEvent(FIXCS.name, EVENT_PLAYER_ACTIVATED, FIXCS.Active)
end
---------------
--For get ItemLink from wornitem, references the addon EnglishTooltips.
function FIXCS.GetWornItemLink(equipSlot)
	return GetItemLink(0, equipSlot)
end
---------------
--Loaded truely when player active
function FIXCS.Active()
  --Check version
  if string.find(GetESOFullVersionString(), FIXCS.ESOVersion) == nil then d(FIXCS.Warning) end
  
  FIXCS.Initial()
  --To fix changes of no-name controls and labels when Tooltips clear
  SkillTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ChampionSkillTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ItemTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  PopupTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ComparativeTooltip1:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ComparativeTooltip2:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ZO_SmithingTopLevelCreationPanelResultTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  ZO_SmithingTopLevelImprovementPanelResultTooltip:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  --Compatible with other addons
  if HarvensSkillTooltipMorph1 ~= nil then
    HarvensSkillTooltipMorph1:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
    HarvensSkillTooltipMorph2:SetHandler("OnCleared", FIXCS.TooltipReset, "FIXCS")
  end
----------------------------------
  --To insert functions of Tooltip to find out what will be displayed
  --Tooltip, The way tooltip set itself, Preprocessing of return values, AdjustValue
  --SkillTooltip
  FIXCS.RobTooltip(SkillTooltip, "SetActiveSkill")
  FIXCS.RobTooltip(SkillTooltip, "SetPassiveSkill")
  FIXCS.RobTooltip(SkillTooltip, "SetSkillAbility")
  --ChampionSkillTooltip
  FIXCS.RobTooltip(ChampionSkillTooltip, "SetChampionSkill")
  --ItemTooltip
  FIXCS.RobTooltip(ItemTooltip, "SetLink")
  FIXCS.RobTooltip(ItemTooltip, "SetBagItem", GetItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetWornItem", FIXCS.GetWornItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetItemSetCollectionPieceLink")
  FIXCS.RobTooltip(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetAction", GetSlotItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetItemUsingEnchantment", GetEnchantedItemResultingItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetLootItem", GetLootItemLink)
  FIXCS.RobTooltip(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
  FIXCS.RobSet(ItemTooltip, "SetGenericItemSet") -- Special treat
  --PopupTooltip
  FIXCS.RobTooltip(PopupTooltip, "SetLink")
  --Retrait station
  FIXCS.RobTooltip(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetPendingRetraitItem", GetResultingItemLinkAfterRetrait)
  FIXCS.RobTooltip(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetBagItem", GetItemLink)
	FIXCS.RobTooltip(ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip, "SetItemSetCollectionPieceLink")
  --Craft Station
  FIXCS.RobTooltip(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
	FIXCS.RobTooltip(ZO_SmithingTopLevelImprovementPanelResultTooltip, "SetSmithingImprovementResult", GetSmithingImprovedItemLink)
  --ComparativeTooltip
  ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", FIXCS.ModifyComp)
	ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", FIXCS.ModifyComp)
  
  --Compatible with other addons
  if HarvensSkillTooltipMorph1 ~= nil then
    FIXCS.RobTooltip(HarvensSkillTooltipMorph1, "SetProgressionAbility", GetAbilityProgressionAbilityId, 2)
    FIXCS.RobTooltip(HarvensSkillTooltipMorph1, "SetAbilityId")
    FIXCS.RobTooltip(HarvensSkillTooltipMorph1, "SetSkillLineAbilityId", function(...) local a = ... return a, 1 end)
    FIXCS.RobTooltip(HarvensSkillTooltipMorph2, "SetProgressionAbility", GetAbilityProgressionAbilityId, 2)
    FIXCS.RobTooltip(HarvensSkillTooltipMorph2, "SetAbilityId")
    FIXCS.RobTooltip(HarvensSkillTooltipMorph2, "SetSkillLineAbilityId", function(...) local a = ... return a, 1 end)
  end
-----------------
  --Finish Active
  EVENT_MANAGER:UnregisterForEvent(FIXCS.name, EVENT_PLAYER_ACTIVATED)
end
---------------
--To Get all no-name controls in Tooltips and create label controls
function FIXCS.Initial()
  --Get all no-name controls from different Tooltips
  for key, value in pairs(FIXCS.MagicSpell) do
    FIXCS.FindDescTool(key)
  end
  --To creat control pool
  FIXCS.Pool = ZO_ObjectPool:New(
    function(Pool)
      return ZO_ObjectPool_CreateNamedControl("$(parent)_Label", "FIXCS_Temple_Label", Pool, FIXCS_Location)
    end,
    function(Control)
      Control:SetText("")
      Control:SetWidth(0)
      Control:SetParent(FIXCS_Location)
      Control:SetAnchor(CENTER, FIXCS_Location, CENTER)
      Control:SetHidden(true)
      Control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
    end
  )
end
---------------
--To create enough label
function FIXCS.Label(Num)
  local Tep = {}
  for i = 1, Num do
    Tep[i] = FIXCS.Pool:AcquireObject()
  end
  return Tep
end
---------------
--To get all no-name controls in different Tooltips
function FIXCS.FindDescTool(TooltipName)
  local Tooltip = WINDOW_MANAGER:GetControlByName(TooltipName)
  if Tooltip == nil then return end
  FIXCS.ODC[TooltipName] = {}

  --Let Tooltip create model item
  --Add divider to create start point of GetAnchor
  FIXCS.MagicSpell[TooltipName]()
  ZO_Tooltip_AddDivider(Tooltip)

  FIXCS.ODC[TooltipName][1] = Tooltip.dividerPool.m_Active[#Tooltip.dividerPool.m_Active]
  local i = 1
  while(true) do --Get all controls by repeating getanchor from the bottom divider added at beginning.
    _, _, FIXCS.ODC[TooltipName][i+1] =  FIXCS.ODC[TooltipName][i]:GetAnchor()
    if FIXCS.ODC[TooltipName][i+1] == nil then return end
    i = i + 1
  end
end
---------------
--When Tooltip switch to a new item, restore everything
function FIXCS.TooltipReset(Tooltip, ...)
  local TooltipName = Tooltip:GetName()
  --Reset no-name controls height to 0, and it can be resized by Tooltip next round
  if not FIXCS.LastContorl[TooltipName]["Label"] then return end
  for i = 1, #FIXCS.LastContorl[TooltipName] do
    FIXCS.LastContorl[TooltipName][i]:SetHeight(0)
  end
  for i = 1, #FIXCS.LastContorl[TooltipName]["Label"] do
    local Key = FIXCS.LastContorl[TooltipName]["Label"][i]:GetName():gsub("%D+", "")
    FIXCS.Pool:ReleaseObject(tonumber(Key))
  end
  FIXCS.LastContorl[TooltipName] = {}
end
---------------
--To get what will be displayed and triggle most modifying.
function FIXCS.RobTooltip(Tooltip, RobFunName, PreHandle, AdjustValue)
  local OldFun = Tooltip[RobFunName]
  if OldFun == nil then return end
  
  Tooltip[RobFunName] = function(self, ...)
    --For some special state to adjust index of no-name control
    FIXCS.AdjustValue = AdjustValue or 0
    --For Debug
    FIXCS.Debug(RobFunName, ...)
    --Finish original job and set up all info
    local Result = OldFun(self, ...)
    --Activate subsequent process and pass the display item info
    if PreHandle ~= nil then 
      FIXCS.ModifyCore(self, PreHandle(...))
    else
      FIXCS.ModifyCore(self, ...)
    end
    --Finish
    return Result
  end
end
---------------
--For the kind of only displaying set effect in ItemTooltip
function FIXCS.RobSet(Tooltip, RobFunName)
  local OldFun = Tooltip[RobFunName]
  
  Tooltip[RobFunName] = function(self, ...)
    --For Debug
    FIXCS.Debug(RobFunName, ...)
    local Result = OldFun(self,...)
    FIXCS.ModifySet(self, ...)
    return Result
  end
end

-------------------------------------------
----------------Final step-----------------
-------------------------------------------
function FIXCS.ReplaceDesc(DescControls, Tooltip, TextTable, ColorIndex, ColorPair)
  local TooltipName = Tooltip:GetName()
  local Label = FIXCS.Label(#TextTable)
  --Set Color
  if ColorIndex then 
    for i = 1, #ColorIndex do
      Label[ColorIndex[i]]:SetColor(GetInterfaceColor(ColorPair[1], ColorPair[2]))
    end
  end
  --Hide old, display new
  for i = 1, #TextTable do
    Label[i]:SetParent(Tooltip)
    Label[i]:SetText(TextTable[i])
    Label[i]:SetWidth(Tooltip:GetWidth()-40)
    Label[i]:SetAnchor(CENTER, DescControls[i], CENTER)
    Label[i]:SetHidden(false)

    DescControls[i]:SetHeight(Label[i]:GetHeight())
    DescControls[i]:SetHidden(true)
    --To mark the controls get height changed
    table.insert(FIXCS.LastContorl[TooltipName], DescControls[i]) 
    FIXCS.LastContorl[TooltipName]["Label"] = Label
  end
end

-------------------------------------------
----------------Modify Part----------------
-------------------------------------------

--Apply desc changing, the running core
function FIXCS.ModifyCore(Tooltip, ...)
  local TooltipName = Tooltip:GetName()
  if TooltipName == "SkillTooltip" then FIXCS.ModifySkill(Tooltip, ...) return end
  if TooltipName == "ChampionSkillTooltip" then FIXCS.ModifyCP(Tooltip, ...) return end
  if TooltipName == "ItemTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "PopupTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "ZO_SmithingTopLevelCreationPanelResultTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "ZO_SmithingTopLevelImprovementPanelResultTooltip" then FIXCS.ModifyItem(Tooltip, ...) return end
  if TooltipName == "HarvensSkillTooltipMorph1" or TooltipName == "HarvensSkillTooltipMorph2" then FIXCS.ModifyHISW(Tooltip, ...) return end
  return
end
---------------
--Skill info handle
function FIXCS.ModifySkill(Tooltip, ...)
  --LabelControl will hold new desc
  local TooltipName = Tooltip:GetName() 
  
  --Get New Desc Text and which control contain old desc
  local TextTable = FIXCS.SkillCombo(...)
  if TextTable == nil then return end -- No need to change
  
  --Collect old desc
  local DescControls = FIXCS.SkillDescFind(FIXCS.ODC[TooltipName], 12)
  
  --Replace the old desc
  FIXCS.ReplaceDesc(DescControls, Tooltip, TextTable)
end
---------------
--CP info handle
function FIXCS.ModifyCP(Tooltip, ...)
  local TooltipName = Tooltip:GetName()
  
  local TextTable = FIXCS.CPCombo(...)
  if TextTable == nil then return end -- No need to change
  
  local DescControls = {FIXCS.ODC[TooltipName][8], FIXCS.ODC[TooltipName][6]}
  
  FIXCS.ReplaceDesc(DescControls, Tooltip, TextTable, {2}, {INTERFACE_COLOR_TYPE_SKILLS_ADVISOR, SKILLS_ADVISOR_COLOR_ADVISED})
end
---------------
--Item info handle
function FIXCS.ModifyItem(Tooltip, ...)
  local TooltipName = Tooltip:GetName()
  
  local TextTable, Color = FIXCS.ItemCombo(...)
  if TextTable == nil then return end
  
  local DescControls = FIXCS.ItemDescFind(FIXCS.ODC[TooltipName], #TextTable, 24, 2)
  if DescControls == nil then return end
  
  FIXCS.ReplaceDesc(DescControls, Tooltip, TextTable, Color, {INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED})
end
---------------
--ComparativeTooltip1 info handle
function FIXCS.ModifyComp(Tooltip, gameDataType, ...)
  if gameDataType ~= TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN then return end
  
  local TooltipName = Tooltip:GetName()
  if FIXCS.MatchedComp[TooltipName] == "" then return end
  
  local TextTable, Color = FIXCS.ItemCombo(FIXCS.MatchedComp[TooltipName])
  if TextTable == nil then return end
  
  local DescControls = FIXCS.ItemDescFind(FIXCS.ODC[TooltipName], #TextTable, 24, 2)
  if DescControls == nil then return end
  
  FIXCS.ReplaceDesc(DescControls, Tooltip, TextTable, Color, {INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED})
end
---------------
--ItemTooltip for only set effects
function FIXCS.ModifySet(Tooltip, SetID)
  if FIXCS.ItemFixed[SetID] == nil then return end
  local TooltipName = Tooltip:GetName()
  
  local NewDesc = FIXCS.ItemFixed[SetID]
  local OldDesc = {}
  for i = 1, #NewDesc do
     _, OldDesc[i] = GetItemSetBonusInfo(SetID, i)
  end
  local ReturnDesc = FIXCS.InsertNumber(NewDesc, OldDesc)
  
  local DescControls = FIXCS.ItemDescFind(FIXCS.ODC[TooltipName], #ReturnDesc, 30, 0)
  if DescControls == nil then return end

  FIXCS.ReplaceDesc(DescControls, Tooltip, ReturnDesc)
end
---------------
--Compatible with other addons

--HarvensImprovedSkillsWindow
function FIXCS.ModifyHISW(Tooltip, abilityId, Rank)
  if FIXCS.SkillFixed[abilityId] == nil then return end
  local TooltipName = Tooltip:GetName()
  local rank = Rank or 4
  
  local ReturnDesc = FIXCS.InsertNumber({FIXCS.SkillFixed[abilityId][1]}, {GetAbilityDescription(abilityId, rank)})
  local DescControls = FIXCS.SkillDescFind(FIXCS.ODC[TooltipName], 12)
  
  FIXCS.ReplaceDesc(DescControls, Tooltip, ReturnDesc)
end

--------------------------------------------------
----------------Find right control----------------
--------------------------------------------------

--Tool function
local function IsInTable(value, tbl)
  for k,v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

---------------
--To find the description start line of Skill
function FIXCS.SkillDescFind(Controls, Y1)
  for i = 1, #Controls do
    local OffY1 = select(6, Controls[i]:GetAnchor())
    if OffY1 == Y1 then --12 for normal
      return {Controls[i]}
    end
  end
end

---------------
--To find the description start line of Item
function FIXCS.ItemDescFind(Controls, Num, Y1, Y2)
  local ReturnCT = {}
  local Start = 0
  for i = 2, #Controls do
    local OffY1 = select(6, Controls[i]:GetAnchor())
    local OffY2 = select(6, Controls[i-1]:GetAnchor())
  -- Normal state / No enchant or trait / No enchant, trait or charge bar
  -- 30, 2 for only Set effect
    if IsInTable(OffY1, {Y1, 14, 26}) and OffY2 == Y2 then
      Start = i
      break
    end
  end
  FIXCS.Debug("Desc line: ", Start)
  if Start == 0 then return nil end
  for i = 1, Num do
    table.insert(ReturnCT, Controls[Start - i])
  end
  return ReturnCT
end

---------------
--Start Here
EVENT_MANAGER:RegisterForEvent(FIXCS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)