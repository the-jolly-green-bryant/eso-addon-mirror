--
-- Section 1: Initialization of variables
--
local WPamA = WPamA
WPamA.OldShowMode = WPamA.ModeCount
WPamA.SI_TOOLTIP_ITEM_NAME = GetString(SI_TOOLTIP_ITEM_NAME)
WPamA.ChmPoints = GetPlayerChampionPointsEarned()
--
-- Section 2: Simple functions
--
function WPamA.SF_Nvl(a, b) if a == nil then return b end return a end
function WPamA.SF_NvlN(a, b) if a ~= nil then return a elseif b ~= nil then return b else return "nil" end end
function WPamA.SF_BoolToStr(val) if val == nil then return "Nil" elseif val then return "True" end return "False" end
function WPamA.SF_Msg(txt, method, addts)
  local s = "|c88aaff" .. WPamA.Name
  if addts == true then
    s = s .. " [" .. GetTimeStamp() .. "]"
  end
  s = s .. ":|r " .. txt
  if (method == true or method == nil) and CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer and CHAT_SYSTEM.primaryContainer.currentBuffer then
    CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage(s) 
  else
    d(s)
  end
end
local nvl = WPamA.SF_NvlN
local msg = WPamA.SF_Msg
local BoolToStr = WPamA.SF_BoolToStr
--
-- Section 3: Support functions
--
function WPamA.ShadowySupplierOption(value)
  if value then
  --== Set a value to the corresponding variable ==--
    if type(value) ~= "number" then return end
    if WPamA.CurChar.ShSupplier.Mode == 2 then
      WPamA.CurChar.ShSupplier.Option = value -- current char var
    else
      WPamA.SV_Main.AutoTakeDBSupplies = value -- account var
    end
  else
  --== Get a value from the corresponding variable ==--
    if WPamA.CurChar.ShSupplier.Mode == 2 then
      return WPamA.CurChar.ShSupplier.Option or 1 -- current char var
    else
      return WPamA.SV_Main.AutoTakeDBSupplies or 1 -- account var
    end
  end
end -- ShadowySupplierOption end

function WPamA:PostScreenAnnounceMessage(messageText, scaCategory, scaType, scaIcon)
  if not messageText then return end
  if type(scaCategory) ~= "number" then scaCategory = CSA_CATEGORY_SMALL_TEXT end
  if type(scaType) ~= "number" then scaType = CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT end
  local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(scaCategory)
  messageParams:SetCSAType(scaType)
  messageParams:SetText(messageText)
  if type(scaIcon) == "string" then
    messageParams:SetIconData(scaIcon)
    messageParams:MarkSuppressIconFrame()
  end
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end -- PostScreenAnnounceMessage end

function WPamA:PostChatMessage(messageText, chatChannel)
  if type(chatChannel) ~= "number" then chatChannel = CHAT_CATEGORY_SYSTEM end
--  messageText = messageText and "true" or "false"
  local isChatNotReady = (not self.isPlayerActive) or KEYBOARD_CHAT_SYSTEM:IsHidden() -- ZO_GetChatSystem():IsHidden()
  if isChatNotReady then
    self:AddDelayedChatMessage(messageText, chatChannel)
    return
  end
  ---
  if CHAT_SYSTEM.primaryContainer then
    CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(messageText, chatChannel)
  else -- no chat container - use d() func instead
    d(messageText)
  end
end -- PostChatMessage end

function WPamA:CurrencyToStr(val)
  if type(val) ~= "number" then val = 0 end
  local ValueThreshold = self.SV_Main.CurrencyValueThreshold or 99999
  if val <= ValueThreshold then return val end
  local i = 0
  while val > ValueThreshold do
    val = zo_floor(val / 1000)
    i = i + 1
  end
  local pref = self.i18n.MetricPrefix[i]
  return zo_strformat("<<1>><<2>><<3>>", val, (pref ~= nil) and " " or "^x", pref or i)
end

function WPamA:CanUseItemInBag(bagId, slotIndex)
  local usableItem, onlyFromActionSlot = IsItemUsable(bagId, slotIndex)
  if usableItem and (not onlyFromActionSlot) then
    local interactableItem = CanInteractWithItem(bagId, slotIndex)
    local secUntilEnd = GetItemCooldownInfo(bagId, slotIndex)
    local hasCooldown = secUntilEnd > 0
    if interactableItem and (not hasCooldown) then return true end
  end
  return false
end -- CanUseItemInBag end

function WPamA:GetItemSlotInBag(requiredBagId, requiredItemId)
  local slotItem = false
  local slotId = ZO_GetNextBagSlotIndex(requiredBagId, nil)
  while slotId do
    local itemId = GetItemId(requiredBagId, slotId)
    -- local itemType, specialType = GetItemType(requiredBagId, slotId)
    -- local icon, stack = GetItemInfo(requiredBagId, slotId)
    if itemId == requiredItemId then
      slotItem = slotId
      break
    end
    slotId = ZO_GetNextBagSlotIndex(requiredBagId, slotId)
  end
  return slotItem -- slot Num or false if item not found
end -- GetItemSlotInBag end

function WPamA:UseCollectibleItem(collectibleId)
  if type(collectibleId) ~= "number" then return end
  local isUnlocked = IsCollectibleUnlocked(collectibleId)
  local isActive = IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
  local isUsable = IsCollectibleUsable(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
--d( zo_strformat("UNL:<<1>> / ACT:<<2>> / USBL:<<3>>",
--                isUnlocked and "T" or "F", isActive and "T" or "F", isUsable and "T" or "F") )
  if isUnlocked and (not isActive) then
    if isUsable then
      UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) -- GAMEPLAY_ACTOR_CATEGORY_COMPANION
    end
  end
   --[[
   esoui/art/icons/u43_tool_infinitearchive.dds
   local name = GetCollectibleName(collectibleId)
   local icon = GetCollectibleIcon(collectibleId)
   local isOwned = IsCollectibleOwnedByDefId(collectibleId)

   GetCollectibleInfo(collectibleId)
   Returns: *string* name, *string* description, *textureName* icon, *textureName* deprecatedLockedIcon,
   *bool* unlocked, *bool* purchasable, *bool* isActive, *CollectibleCategoryType* categoryType, *string* hint
   --]]
end -- UseCollectibleItem end

function WPamA:UpdToday()
  local c, t = self.Consts, self.Today
  local currTS = GetTimeStamp()
  if (t.TS == nil) or (t.TS + c.SecInDay <= currTS) then
    --- Today 00:00 UTC by local OS time ---
    local osTime = os.date("*t")
    osTime.hour, osTime.min, osTime.sec = 0, 0, 0
    t.DayLoc00 = os.time(osTime)
    t.DayUTC00 = t.DayLoc00 + c.TimeZone
    ---
    local diffRealmHours = c.RealmsDailyReset[c.RealmIndex] or 0
    t.TS = t.DayUTC00 + c.SecInHour * diffRealmHours -- Daily Reset TS at 03|10:00 UTC
    if currTS < t.TS then t.TS = t.TS - c.SecInDay end
    ---
    t.W = GetDayOfTheWeekIndex(t.TS)
    local diffDays = (t.W - 2 + 7) % 7
    t.WeekUTC00 = t.DayUTC00 - c.SecInDay * (diffDays + 1)
----    t.WeekUTC00 = t.DayUTC00 - c.SecInDay * t.W
    t.WTS = t.WeekUTC00 + c.SecInDay + c.SecInHour * diffRealmHours -- Weekly Reset TS on Tuesday at 03|10:00 UTC
    if currTS < t.WTS then t.WTS = t.WTS - c.SecInWeek end
    t.Diff = zo_floor(GetDiffBetweenTimeStamps(t.TS, c.BaseTimeStamp) / c.SecInDay)

    --- In-game day Start and End at local time ---
    t.DayStart = t.TS
    t.DayEnd   = t.TS + c.SecInDay
    t.WeekStart = t.DayStart - c.SecInDay * diffDays
    t.WeekEnd   = t.WeekStart + c.SecInWeek
    t.WeekReset = t.WeekEnd -- Weekly Reset TS on Tuesday (03|10:00 UTC at local time zone)
    if t.WeekReset > (currTS + c.SecInWeek) then t.WeekReset = t.WeekReset - c.SecInWeek end

    --- In-game season Start and End at local time ---
    t.SeasonStart, t.SeasonEnd = 0, 0
    local remainTime = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_SEASONAL)
    if remainTime > 0 then
      t.SeasonEnd = currTS + remainTime
      t.SeasonEnd = 10 * zo_round(t.SeasonEnd / 10) -- stabilization of second deviations
      --t.SeasonStart = ??
    end
    ---
    local secUntilDayEnd = t.DayEnd - GetTimeStamp() + 1
    EVENT_MANAGER:RegisterForUpdate(WPamA.Name .. "DayEnd", 1000 * secUntilDayEnd,
       function()
         EVENT_MANAGER:UnregisterForUpdate(WPamA.Name .. "DayEnd")
         WPamA.OnEndeavorUpdated(EVENT_TIMED_ACTIVITIES_UPDATED)
         WPamA:UpdWindowInfo()
       end )
  end -- no TS yet or outdated TS
end -- UpdToday end

--[[
GetDayOfTheWeekIndex(*deprecated_timestamp_64* _timestamp_)
Returns: *integer* _weekdayIndex_

GetSecondsSinceMidnight()
Returns: *integer* _secondsSinceMidnight_

GetDateElementsFromTimestamp(*deprecated_timestamp_64* _timestamp_)
Returns: *integer* _year_, *integer* _month_, *integer* _day_

GetTimestampForStartOfDate(*integer* _year_, *integer* _month_, *integer* _day_, *bool* _inLocalTime_)
Returns: *deprecated_timestamp_64* _timestamp_

GetTimeUntilNextDailyLoginRewardClaimS()
Returns: *integer* _secondsUntilNextRewardClaim_
--]]

function WPamA:GetNextUTC00TS()
  self:UpdToday()
  return self.Today.DayUTC00 + self.Consts.SecInDay
end

function WPamA:GetNextDailyResetTS()
  self:UpdToday()
  if GetTimeUntilNextDailyLoginRewardClaimS() > 0 then
    local dlrTS = GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS()
    dlrTS = 10 * zo_round(dlrTS / 10) -- stabilization of second deviations
    if dlrTS ~= self.Today.DayEnd then return dlrTS end
  end
  if self.Today.DayEnd then return self.Today.DayEnd end
  return self.Today.TS + self.Consts.SecInDay
end

function WPamA:GetNextWeeklyResetTS()
--  return GetTimeStamp() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_WEEKLY)
--  self:UpdToday()
  if self.Today.WeekReset then return self.Today.WeekReset end
  return self.Today.WTS + self.Consts.SecInWeek
end

function WPamA:CheckToday(timeTS)
  if not timeTS then return false end
--  self:UpdToday()
  local t = self.Today
  if t.DayEnd then return (t.DayStart <= timeTS) and (timeTS < t.DayEnd) end
  if t.TS then return (t.TS <= timeTS) and (timeTS < (t.TS + self.Consts.SecInDay)) end
  return false
end

function WPamA:CheckOutOfWeek(timeTS)
  if not timeTS then return true end
  local t = self.Today
  if t.WeekStart then return timeTS < t.WeekStart end
  if t.WTS then return timeTS < t.WTS end
  return true
end

function WPamA:CheckOutOfDay(timeTS)
  if not timeTS then return true end
--  self:UpdToday()
  local t = self.Today
  if t.DayStart then return timeTS < t.DayStart end
  if t.TS then return timeTS < t.TS end
  return true
end

function WPamA:DifTSToStr(Diff, needSetPeriod, Interval, isAlwaysShowSeconds)
  if Diff == nil then return "" end
  local c, z, t = self.Consts, 0, ""
  local s = 0
  if Interval == 1 then
    s = c.SecInDay - Diff
  elseif Interval == 2 then
    s = c.SecInWeek - Diff
  else
    s = Diff
  end
  if s >= 0 then
    if s < c.SecInMin then
      if s < 10 then t = "00:00:0" .. s else t = "00:00:" .. s end
      if needSetPeriod and self.Mode67PeriodUpd > 0  then self.Mode67PeriodUpd = 0 end
    else
      if needSetPeriod and self.Mode67PeriodUpd > 59 then self.Mode67PeriodUpd = 59 end
      if s >= c.SecInDay then
        z = zo_floor(s / c.SecInDay)
        s = s % c.SecInDay
        t = z .. self.i18n.DayMarker .." "
      end
      z = zo_floor(s / c.SecInHour)
      s = s % c.SecInHour
      if z < 10 then t = t .. "0" end
      t = t .. z ..":"
      z = zo_floor(s / c.SecInMin)
      if z < 10 then t = t .. "0" end
      t = t .. z
      if isAlwaysShowSeconds then
        s = s % c.SecInMin
        t = t .. ":"
        if s < 10 then t = t .. "0" end
        t = t .. s
      end
    end
  end
  return t
end

local DateFormatter = {
      -- <<1>> = dd  <<2>> = mm  <<3>> = yy  <<4>> = time
   [0] = "<<3>>-<<2>>-<<1>><<4>>", -- yy-mm-dd time
   [3] = "<<1>>.<<2>>.<<3>><<4>>", -- dd.mm.yy time
   [4] = "<<3>>/<<2>>/<<1>><<4>>", -- yy/mm/dd time
   [5] = "<<1>>.<<2>>.<<3>><<4>>", -- dd.mm.yy time
   [6] = "<<2>>/<<1>><<4>><<3>>",  -- mm/dd time
   [7] = "<<1>>.<<2>><<4>><<3>>"   -- dd.mm time
}

function WPamA:TimestampToStr(tmst, dfr, sht)
  if sht == nil then sht = self.SV_Main.ShowTime end
  local date, time = FormatAchievementLinkTimestamp(tmst)
  --- SV.DateFrmt, i18n.DateFrmt : 1 default:m.d.yyyy; 2:yyyy-mm-dd; 3:dd.mm.yyyy;
  --- 4:yyyy/mm/dd; 5:dd.mm.yy; 6:mm/dd; 7:dd.mm
  local df = dfr or self.SV_Main.DateFrmt or self.i18n.DateFrmt or 1
  if (df < 1) or (df > #self.i18n.DateFrmtList) then df = 1 end
  if sht then
    time = " " .. string.sub(time, 1, 5)
  else
    time = ""
  end
  if df == 1 then
    return date .. time
  end
-- Get date string
  local yy, mm, dd = GetDateElementsFromTimestamp(tmst)
  yy = tostring(yy)
  mm = tostring(mm)
  dd = tostring(dd)
-- Align the length to 2 symbols
  if string.len(mm) == 1 then mm = "0" .. mm end
  if string.len(dd) == 1 then dd = "0" .. dd end
-- Date string formatting
  if df == 5 then yy = string.sub(yy, 3, 4) end
  if df > 5  then yy = "" end
  return zo_strformat(DateFormatter[df] or DateFormatter[0], dd, mm, yy, time)
end

function WPamA:Debug(Txt, Force)
  local g = self.SV_Debug
  local l = g ~= nil and g.IsDebugMode
  if Force ~= nil or l then
    if l then
      local Lang = GetCVar('Language.2')
      table.insert(g.Log, self:TimestampToStr(GetTimeStamp(),2,true) .. "> " .. Txt .. "; Lang: " .. Lang .. "; Serv: " .. self.Consts.Realms[self.Consts.RealmIndex])
    end
    msg(Txt, false, true)
  end
end

function WPamA:GetColor(num)
  local clr = self.TbColors
  if type(num) ~= "number" then num = 5 end
  if not clr[num] then num = 5 end
  return clr[num].r, clr[num].g, clr[num].b, clr[num].a
end

function WPamA:LoadTbColors()
  local Mdl = self.Colors.Mdl
  for i = 1, #Mdl do
    local addColor = { r = 1, g = 1, b = 1, a = 1 }
    if Mdl[i] then
      if string.len( Mdl[i] ) >= 6 then
        local rhex, ghex, bhex = string.sub(Mdl[i], 1, 2), string.sub(Mdl[i], 3, 4), string.sub(Mdl[i], 5, 6)
        addColor.r = tonumber(rhex, 16)/255
        addColor.g = tonumber(ghex, 16)/255
        addColor.b = tonumber(bhex, 16)/255
        if string.len( Mdl[i] ) >= 8 then
          local ahex = string.sub(Mdl[i], 7, 8)
          addColor.a = tonumber(ahex, 16)/255
        end
      end
    end
    table.insert(self.TbColors, addColor)
  end
end

function WPamA:InitInvtItemTT()
  local LNK = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"
  local i18n = self.i18n
  for _, v in pairs(self.Inventory.InvtItem) do
    if type(v.TT) == "number" then
      if type(v.TTs) == "string" then
        i18n.ToolTip[v.TT] = v.TTs
      elseif type(v.link) == "string" then
        local itemName = GetItemLinkName( zo_strformat(LNK, v.link) )
        itemName = itemName:gsub("%^.+", "")
        if type(v.TTf) == "string" then itemName = itemName:gsub(v.TTf, "") end
        i18n.ToolTip[v.TT] = itemName
      end
    end
  end
end

function WPamA:InitLoreBookMode()
  local n = GetNumLoreCategories()
  local MS = WPamA.ModeSettings[34]
  local TT = WPamA.i18n.ToolTip
  for i = 1, 3 do
    if i <= n then
      local categoryName, _ = GetLoreCategoryInfo(i)
      MS.HdT[i] = nvl(categoryName,"")
      local k = MS.BTT[i]
      if k ~= nil then
        TT[k] = categoryName
      end
    else
      MS.HdT[i] = ""
    end
  end
end

function WPamA:HasPetSummonedBySkillId(AbilityId)
  if type(AbilityId) ~= "number" then return false end
  local strf = zo_strformat
  local petName = strf(SI_COLLECTIBLE_NAME_FORMATTER, GetAbilityName(AbilityId) or "")
  for i = 1, MAX_PET_UNIT_TAGS do
    local petTag = "playerpet" .. i
    if DoesUnitExist(petTag) then
      local unitName = strf(SI_COLLECTIBLE_NAME_FORMATTER, GetUnitName(petTag))
      if unitName == petName then
        return true
      end
    end
  end
  return false
end
--
-- Section 4: Radial menu support functions
--
WPamA.RadMenuClass = ZO_InteractiveRadialMenuController:Subclass()

function WPamA.RadMenuClass:New(...)
  return ZO_InteractiveRadialMenuController.New(self, ...)
end

function WPamA.RadMenuClass:PrepareForInteraction()
  -- not ready conditions
  if IsUnitInCombat("player") then return false end
--  if SCENE_MANAGER:IsInUIMode() then return false end
  if not SCENE_MANAGER:IsShowing("hud") then return false end
  -- show menu when ready
  return true
end

function WPamA.RadMenuClass:SetupEntryControl(entryControl, modeIndex)
  ZO_SetupSelectableItemRadialMenuEntryTemplate(entryControl, false, nil) -- (template, selected, stackCount)
end

local function GetTabNameIcon(numMode)
  local WL = WPamA.i18n.Wind
  local MS = WPamA.ModeSettings[numMode]
  local icon = MS.FavRadMenuIcon or WPamA.Consts.FavRadPlaceholder
  local TB = WL[MS.WinInd].Tab[MS.TabInd]
  return TB.N .. nvl(TB.A,""), icon
end
-- Passing "Test" in name will just set the label to "Test" in white
-- Passing {"Test", {r = 1, g = 0, b = 0}} will set the label to "Test" in the color red
-- AddEntry(name, inactiveIcon, activeIcon, callback, data)
function WPamA.RadMenuClass:PopulateMenu()
  local MV, MO, i = WPamA.SV_Main.isModeVisible, WPamA.ModeOrder, 1
  for k = 0, WPamA.ModeCount - 1 do
    local n = MO[k]
    if n and MV[n] then
      local modeName, modeIcon = GetTabNameIcon(n)
      self.menu:AddEntry(modeName, modeIcon, modeIcon, function() WPamA.ChangeUIMode(n) end, i)
      i = i + 1
    end
  end
end
--
-- Section 5: Delayed chat messages support functions
--
local DelayedChatMessagesArray = {} -- [index] = {string | number MessageText, nilable ChatChannel}

function WPamA:IsDelayedChatMessage()
  return #DelayedChatMessagesArray > 0
end

function WPamA:AddDelayedChatMessage(messageText, chatChannel)
  if messageText then
    if type(chatChannel) ~= "number" then chatChannel = CHAT_CATEGORY_SYSTEM end
    table.insert(DelayedChatMessagesArray, {MessageText = messageText, ChatChannel = chatChannel})
  end
end
---- /script WPamA:AddDelayedChatMessage("-=- Test -=-")

local function PostDelayedMessagesToChat()
  local isChatNotReady = (not WPamA.isPlayerActive) or KEYBOARD_CHAT_SYSTEM:IsHidden() -- ZO_GetChatSystem():IsHidden()
  WPamA.Consts.ChatSystemReadyCheck = WPamA.Consts.ChatSystemReadyCheck - 1
  if (not isChatNotReady) or (WPamA.Consts.ChatSystemReadyCheck < 1) then
    EVENT_MANAGER:UnregisterForUpdate(WPamA.Name .. "DldChtMsg")
    WPamA.Consts.ChatSystemReadyCheck = nil
  end
  if isChatNotReady then return end
  ---
  for ind = 1, #DelayedChatMessagesArray do
    if DelayedChatMessagesArray[ind].MessageText then
      WPamA:PostChatMessage(DelayedChatMessagesArray[ind].MessageText, DelayedChatMessagesArray[ind].ChatChannel)
    end
  end
  DelayedChatMessagesArray = {}
end

function WPamA:PostDelayedChatMessages()
  if not self:IsDelayedChatMessage() then return end
  self.Consts.ChatSystemReadyCheck = 15
  EVENT_MANAGER:RegisterForUpdate(WPamA.Name .. "DldChtMsg", 3000, PostDelayedMessagesToChat)
end

--[[
function WPamA:GetScaledIcon(Texture, Size, Color)
  Texture = Texture or " "
  Size = Size or 18
  if type(Color) ~= "number" then
  end

--function ZO_ColorizeString(r, g, b, string)
--    return string.format("|c%.2x%.2x%.2x%s|r", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), string)
--end

--grn=ZO_ColorDef:New(  0,  1,  0, 1), --#00ff00  //(  0,255,  0)  //(  0/255,255/255,  0/255,1)
--ico=grn:Colorize(zo_iconFormatInheritColor("/esoui/art/icons/poi/poi_delve_complete. dds"))
--WPamA.Colors.ColumnHdr:Colorize( zo_iconFormatInheritColor("esoui/art/characterwindow/gearslot_head. dds") )
--GetItemQualityColor(ITEM_DISPLAY_QUALITY_LEGENDARY):Colorize( zo_iconFormatInheritColor("esoui/art/characterwindow/gearslot_head. dds", 28, 28) )

-- local SMALL_KEEP_ICON_STRING = zo_iconFormatInheritColor("EsoUI/Art/AvA/AvA_tooltipIcon_keep. dds", 32, 32)

--r, g, b = zo_saturate(r + INCREASE_AMOUNT), zo_saturate(g + INCREASE_AMOUNT), zo_saturate(b + INCREASE_AMOUNT)
--  local icon = ""
  return string.format("|t%d:%d:%s|t", Size, Size, Texture)
end
--]]
