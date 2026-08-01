local BAF = BetterDungonFinder
--Tool Function
local function IsInTable(value, tbl)
  for k,v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

--------------------
--Set everything in UI
function BAF.D2C(Control, List)
  if Control == nil or List == nil then return end
  --Child controls
  local Title = Control:GetNamedChild("_Title")
  local Gear = Control:GetNamedChild("_Gears")
  local Norm = Control:GetNamedChild("_N")
  local Vera = Control:GetNamedChild("_V")
  local SK =  Control:GetNamedChild("_SK")
  local HM = Control:GetNamedChild("_HM")
  local SR = Control:GetNamedChild("_SR")
  local ND = Control:GetNamedChild("_ND")
  local TR = Control:GetNamedChild("_TR")
  local BG = Control:GetNamedChild("_BG")
  --Title
  Title:SetText(List["Name"]:gsub("%^.*", ""))
  if List["IsTodayU"] then Title:SetColor(0.255, 0.412, 1) else Title:SetColor(1, 1, 1) end
  Title:ClearAnchors()
  if BAF.savedVariables.Window_Left then
    Title:SetAnchor(BOTTOMLEFT, Control, CENTER, -66 + BAF.savedVariables.Window_LeftV, 14)
  else
    Title:SetAnchor(BOTTOM, Control, CENTER, 5 + BAF.savedVariables.Window_LeftV, 14)
  end
  --Gear
  if List["Gear"][1] == List["Gear"][2] then Gear:SetText("100%") else Gear:SetText(List["Gear"][1].." / "..List["Gear"][2]) end
  if List["IsRich"] then Gear:SetColor(0.698, 0.4, 1) else Gear:SetColor(1, 1, 1) end
  --Background
  BG:SetTexture("/BetterDungeonFinder/src/pic/BG_"..List["nId"]..".dds")
  BG:SetAlpha(BAF.savedVariables.AlphaLow)
  --Icon
  if List["SK"] then SK:SetAlpha(1) else SK:SetAlpha(0.3) end
  if List["HM"] == 1 then HM:SetAlpha(1) else HM:SetAlpha(0.3) end
  if List["SR"] == 1 then SR:SetAlpha(1) else SR:SetAlpha(0.3) end
  if List["ND"] == 1 then ND:SetAlpha(1) else ND:SetAlpha(0.3) end
  if List["Tri"] == 2 then
    if List["HM"] == 1 and List["SR"] == 1 and List["ND"] == 1 then 
      TR:SetHidden(false)
      TR:SetAlpha(1.0)
    else
      TR:SetHidden(true)
    end
  end
  if List["Tri"] == 0 then
    TR:SetHidden(false)
    TR:SetAlpha(0.3)
  end
  if List["Tri"] == 1 then
    TR:SetHidden(false)
    TR:SetAlpha(1)
  end
  --Button
  Norm:SetHidden(false)
  Vera:SetHidden(true)
  if List["Availability"] == 2 then
    Vera:SetHidden(false)
  elseif List["Availability"] == 0 then
    Norm:SetHidden(true)
  end
  --FastTravelNode
  Norm.FTN = {List["TravelIndex"], false}
  Vera.FTN = {List["TravelIndex"], true}
  --Whole show
  Control:SetHidden(false)
end

--Core of window change
function BAF.WindowUpdate()
  --For dungeon refresh
  for i = 1, #BAF.BDC do BAF.D2C(BAF.BDC[i], BAF.BD[i]) end
  for i = 1, #BAF.DDC do BAF.D2C(BAF.DDC[i], BAF.DD[i]) end
  --for Undauted Dungeon
  BAF.UndauntedWindowUpdate()
  BAF.RoleRefresh()
  BAF.RewardRefresh()
  BAF.CDRefresh()
  BAF.SavedRefresh()
end

--Refresh the daily reward
function BAF.RewardRefresh()
  if IsActivityEligibleForDailyReward(LFG_ACTIVITY_DUNGEON) then
    BAFRan_N:SetAlpha(1)
    BAFRan_V:SetAlpha(1)
  else
    BAFRan_N:SetAlpha(0.2)
    BAFRan_V:SetAlpha(0.2)
  end
  if IsActivityEligibleForDailyReward(LFG_ACTIVITY_BATTLE_GROUND_CHAMPION) 
    or IsActivityEligibleForDailyReward(LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL) 
    or IsActivityEligibleForDailyReward(LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION) 
  then
    BAFRan_BG:SetAlpha(1)
  else
    BAFRan_BG:SetAlpha(0.2)
  end
end

--Refresh the current role in controls showing
function BAF.RoleRefresh()
  local Role = GetSelectedLFGRole() -- dd:1 H:4 T:2
  BAFRole_T:SetState(BSTATE_NORMAL)
  BAFRole_H:SetState(BSTATE_NORMAL)
  BAFRole_D:SetState(BSTATE_NORMAL)
  if Role == 1 then BAFRole_D:SetState(BSTATE_PRESSED) return end
  if Role == 4 then BAFRole_H:SetState(BSTATE_PRESSED) return end
  if Role == 2 then BAFRole_T:SetState(BSTATE_PRESSED) return end
  d("BDF: Something Wrong with Role Change.")
end

--Refresh the cooldown of queue
function BAF.CDRefresh()
  --Dungeon
  local Tep = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_ACTIVITY_STARTED)
  if Tep > 0 then
    EVENT_MANAGER:RegisterForUpdate("BDF_CDRefresh_1", 1000, BAF.CDRefresh)
    local String = FormatTimeSeconds(Tep, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    BAFWindow_CD:SetText(String)
    BAFWindow_Queue:SetHidden(true)
    BAFWindow_CD:SetHidden(false)
  else
    EVENT_MANAGER:UnregisterForUpdate("BDF_CDRefresh_1")
    BAFWindow_Queue:SetHidden(false)
    BAFWindow_CD:SetHidden(true)
  end
  --BG
  local Tep2 = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_DESERTED)
  if Tep2 > 0 then
    EVENT_MANAGER:RegisterForUpdate("BDF_CDRefresh_2", 1000, BAF.CDRefresh)
    local String = FormatTimeSeconds(Tep2, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    BAFWindow_CD2:SetText(String)
    BAFRan_BG:SetHidden(true)
    BAFWindow_CD2:SetHidden(false)
  else
    EVENT_MANAGER:UnregisterForUpdate("BDF_CDRefresh_2")
    BAFRan_BG:SetHidden(false)
    BAFWindow_CD2:SetHidden(true)
  end
end

--Saved Bar
local SBControls = {}
function BAF.SavedRefresh()
  --Reset
  for i = 1, #SBControls do
    SBControls[i].BAFIndex = nil
    SBControls[i]:SetHidden(true)
  end
  --Fill with Info
  local List = BAF.savedVariables.SavedList
  for i = 1, #List do
    if not SBControls[i] then
      local TopLevel = WINDOW_MANAGER:GetControlByName("BAFTopLevel")
      SBControls[i] = CreateControlFromVirtual(
        "BAFSavedBar_"..i, 
        TopLevel, 
        "BAFSavedBar"
      )
      SBControls[i]:SetAnchor(BOTTOMLEFT, TopLevel, BOTTOMRIGHT, 5, (1 - i)*45)
    end
    SBControls[i]:SetHidden(false)
    SBControls[i].BAFIndex = i
    SBControls[i]:SetText("    "..List[i]["Name"])
  end
end

--Undaunted dungeon info should be infused in right Control(1~3) and update
function BAF.UndauntedWindowUpdate()
  for i = 1, 3 do
    BAF.UDC[i]:SetHidden(true) --Hidden Vacant control
    local Norm = BAF.UDC[i]:GetNamedChild("_N")
    local Vera = BAF.UDC[i]:GetNamedChild("_V")
    Norm:SetState(BSTATE_NORMAL)
    Vera:SetState(BSTATE_NORMAL)
    if BAF.UD[i] ~= nil then
      BAF.D2C(BAF.UDC[i], BAF.UD[i])
      --When undaunted dungeon changed via quest completion, press the buttons again of the rest undone dungeon
      if IsInTable(BAF.UD[i]["nId"], BAF.SD) then Norm:SetState(BSTATE_PRESSED) end
      if IsInTable(BAF.UD[i]["vId"], BAF.SD) then Vera:SetState(BSTATE_PRESSED) end
    end
  end
  BAF.SelectDungeonUpdate()
end

--According to the status of button, Find the dungeon selected.
function BAF.SelectDungeonUpdate()
  BAF.SD = {}
  for i = 1, #BAF.BDC do  -- check base dungeon button state
    BAF.CheckButton(BAF.BDC[i], BAF.BD[i])
  end
  for i = 1, #BAF.DDC do  -- check dlc dungeon button state
    BAF.CheckButton(BAF.DDC[i], BAF.DD[i])
  end
  for i = 1, #BAF.UDC do  -- check unduanted dungeon button state
    BAF.CheckButton(BAF.UDC[i], BAF.UD[i])
  end
  if BAF.SD == nil then return end
  BAFWindow_Empty:SetText(BAFLang_SI.BUTTON_Empty.." ("..#BAF.SD..")") -- Fill the text in empty button
end

--Which Button is pressed
function BAF.CheckButton(Control, List)
  local Norm = Control:GetNamedChild("_N")
  local Vera = Control:GetNamedChild("_V")
  local BG = Control:GetNamedChild("_BG")
  BG:SetAlpha(BAF.savedVariables.AlphaLow)
  if List == nil then return end
  
  if Norm:GetState() == 1 then
    BG:SetAlpha(BAF.savedVariables.AlphaHigh)
    if not IsInTable(List["nId"], BAF.SD) then -- avoid repeat adding
      table.insert(BAF.SD, List["nId"])
    end
  end
  
  if Vera:GetState() == 1 then
    BG:SetAlpha(BAF.savedVariables.AlphaHigh)
    if not IsInTable(List["vId"], BAF.SD) then -- avoid repeat adding
      table.insert(BAF.SD, List["vId"])
    end
  end
end

--Press Buttons
function BAF.PressButton(ActivityIDs)
  local CheckList = {}
  for i = 1, #ActivityIDs do
    CheckList[ActivityIDs[i]] = true
  end
  --Base Dungeons
  for i = 1, #BAF.BD do
    if CheckList[BAF.BD[i]["nId"]] then BAF.BDC[i]:GetNamedChild("_N"):SetState(BSTATE_PRESSED) end
    if CheckList[BAF.BD[i]["vId"]] then BAF.BDC[i]:GetNamedChild("_V"):SetState(BSTATE_PRESSED) end
  end
  --DLC Dungeons
  for i = 1, #BAF.DD do
    if CheckList[BAF.DD[i]["nId"]] then BAF.DDC[i]:GetNamedChild("_N"):SetState(BSTATE_PRESSED) end
    if CheckList[BAF.DD[i]["vId"]] then BAF.DDC[i]:GetNamedChild("_V"):SetState(BSTATE_PRESSED) end
  end
  BAF.SelectDungeonUpdate()
end

--Select all the dungeon with sk left
function BAF.AllSK()
  for i = 1, #BAF.BD do
    if BAF.BD[i]["SK"] == false and BAF.BD[i]["Availability"] > 0 then
      local Norm = BAF.BDC[i]:GetNamedChild("_N")
      Norm:SetState(BSTATE_PRESSED)
    end
  end
  for i = 1, #BAF.DD do
    if BAF.DD[i]["SK"] == false and BAF.DD[i]["Availability"] > 0 then
      local Norm = BAF.DDC[i]:GetNamedChild("_N")
      Norm:SetState(BSTATE_PRESSED)
    end
  end
  BAF.SelectDungeonUpdate()
end