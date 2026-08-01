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

--------------------------------
BAF.OnSale = {}
--Get Onsale weapon pack
function BAF.OnSalePack()
  BAF.OnSale = {}
  for a = 1, 30 do
    for b = 1, 30 do
      for c = 1, 30 do
        local ID = GetMarketProductPresentationIds(MARKET_DISPLAY_GROUP_CROWN_STORE, a, b, c)
        if ID ~= 0 then table.insert(BAF.OnSale, ID) end
      end
    end
  end
end

--Just for debug
--/script BetterDungonFinder.PackScan("Arms Pack")
function BAF.PackScan(String)
  for i = 0, 60000 do
    local Name = GetMarketProductDisplayName(i)
    if Name ~= "" and string.find(Name, String) then d(i..": "..Name) end
  end
end

--------------------------------
--Today undaunted dungeons
BAF.TodayUndaunted = {} 
--/script BetterDungonFinder.OnDailyU()
function BAF.OnDailyU(Stamp)
  BAF.TodayUndaunted = {}
  local Cycle_1 = {
    2,    --01 Fungal Grotto I
    300,  --02 The Banished Cells II
    5,    --03 Darkshade Caverns I
    303,  --04 Elden Hollow II
    6,    --05 Wayrest Sewers I
    316,  --06 Spindleclutch II
    4,    --07 The Banished Cells I
    18,   --08 Fungal Grotto II
    3,    --09 Spindleclutch I
    308,  --10 Darkshade Caverns II
    7,    --11 Elden Hollow I
    22,   --12 Wayrest Sewers II
  }
  local Cycle_2 = {
    16,   --01 Selene's Web
    322,  --02 City of Ash II
    9,    --03 Crypt of Hearts I
    12,   --04 Volenfell
    14,   --05 Blessed Crucible
    11,   --06 Direfrost Keep
    17,   --07 Vaults of Madness
    317,  --08 Crypt of Hearts II
    10,   --09 City of Ash I
    13,   --10 Tempest Island
    15,   --11 Blackheart Haven
    8,    --12 Arx Corinium
  }
  
  local Cycle_3 = {
    289,  293,  --01, 02 Imperial City Prison, Ruins of Mazzatun
    288,  295,  --03, 04 White-Gold Tower, Cradle of Shadows
    324,  368,  --05, 06 Bloodroot Forge, Falkreath Hold
    420,  418,  --07, 08 Fang Lair, Scalecaller Peak
    426,  428,  --09, 10 Moon Hunter Keep, March of Sacrifices
    435,  433,  --11, 12 Depths of Malatar, Frostvault
    494,  496,  --13, 14 Moongrave Fane, Lair of Maarselok
    503,  505,  --15, 16 Icereach, Unhallowed Grave
    507,  509,  --17, 18 Stone Garden, Castle Thorn
    591,  593,  --19, 20 Black Drake Villa, The Cauldron
    595,  597,  --21, 22 Red Petal Bastion, The Dread Cellar
    599,  601,  --23, 24 Coral Aerie, Shipwright's Regret
    608,  610,  --25, 26 Earthen Root Enclave, Graven Deep
    613,  615,  --27, 28 Bal Sunnar, Scrivener's Hall
    638,  640,  --29, 30 Oathsworn Pit, Bedlam Veil
    855,  857,  --31, 32 Exiled Redoubt, Lep Seclusa
    1037, 1039, --33, 34 Naj-Caldeesh, Black Gem Foundry
  }
  
  --2025.08.18 UTC 15:03
  local StartTime, StartIndex = 1755529389, {11, 11, 21}
  
  local NextUpdateTime = Stamp or (GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS())
  local Days = math.floor((NextUpdateTime - StartTime) / (24 * 3600))
  local Index = function(Number, Table)
    local Tep = Number % (#Table)
    if Tep == 0 then
      return Table[#Table]
    else
      return Table[Tep]
    end
  end

  table.insert(BAF.TodayUndaunted, Index((StartIndex[1] + Days), Cycle_1))
  table.insert(BAF.TodayUndaunted, Index((StartIndex[2] + Days), Cycle_2))
  table.insert(BAF.TodayUndaunted, Index((StartIndex[3] + Days), Cycle_3))
  
  if Stamp then
    for i = 1, 3 do
      d(GetActivityName(BAF.TodayUndaunted[i]))
    end
  end
end

--------------------------------
--Fill the dungeonList with info
function BAF.DungeonUpdate()
	BAF.UD = {}
  BAF.OnSalePack()
  BAF.OnDailyU()
	for i = 1, #BAF.BD do
    BAF.BD[i]["Availability"] = BAF.DungeonCheck(BAF.BD[i]["nId"], BAF.BD[i]["vId"])
    BAF.BD[i]["Gear"] = BAF.GearCount(BAF.BaseDungeonInfo[i][4])
    BAF.BD[i]["HM"] = BAF.DungeonAchi(BAF.BaseDungeonInfo[i][5])
    BAF.BD[i]["SR"] = BAF.DungeonAchi(BAF.BaseDungeonInfo[i][6])
    BAF.BD[i]["ND"] = BAF.DungeonAchi(BAF.BaseDungeonInfo[i][7])
    BAF.BD[i]["Tri"] = BAF.DungeonAchi(BAF.BaseDungeonInfo[i][8])
    BAF.BD[i]["SK"] = BAF.DungeonSkill(BAF.BaseDungeonInfo[i][9])
    BAF.BD[i]["IsGetUQ"] = BAF.DungeonUndaunted(BAF.BaseDungeonInfo[i][10])
    BAF.BD[i]["IsTodayU"] = IsInTable(BAF.BD[i]["nId"], BAF.TodayUndaunted)
    BAF.BD[i]["IsRich"] = BAF.DungeonRich(BAF.BaseDungeonInfo[i][11])
    if BAF.BD[i]["IsGetUQ"] then table.insert(BAF.UD, BAF.BD[i]) end
  end
	for i = 1, #BAF.DD do
    BAF.DD[i]["Availability"] = BAF.DungeonCheck(BAF.DD[i]["nId"], BAF.DD[i]["vId"])
    BAF.DD[i]["Gear"] = BAF.GearCount(BAF.DLCDungeonInfo[i][4])
    BAF.DD[i]["HM"] = BAF.DungeonAchi(BAF.DLCDungeonInfo[i][5])
    BAF.DD[i]["SR"] = BAF.DungeonAchi(BAF.DLCDungeonInfo[i][6])
    BAF.DD[i]["ND"] = BAF.DungeonAchi(BAF.DLCDungeonInfo[i][7])
    BAF.DD[i]["Tri"] = BAF.DungeonAchi(BAF.DLCDungeonInfo[i][8])
    BAF.DD[i]["SK"] = BAF.DungeonSkill(BAF.DLCDungeonInfo[i][9])
    BAF.DD[i]["IsGetUQ"] = BAF.DungeonUndaunted(BAF.DLCDungeonInfo[i][10])
    BAF.DD[i]["IsTodayU"] = IsInTable(BAF.DD[i]["nId"], BAF.TodayUndaunted)
    BAF.DD[i]["IsRich"] = BAF.DungeonRich(BAF.DLCDungeonInfo[i][11])
    if BAF.DD[i]["IsGetUQ"] then table.insert(BAF.UD, BAF.DD[i]) end
	end
end

--Check the available of dungeon by level and dlc
function BAF.DungeonCheck(nID, vID)
-- 0, none; 1, n; 2, n + v
-- DLC Check
  local RequiredDLC = GetRequiredActivityCollectibleId(nID)
  if RequiredDLC ~= 0 then
    if IsESOPlusSubscriber() or IsCollectibleOwnedByDefId(RequiredDLC) then else return 0 end
  end
-- Level Check
	local nAvailability = DoesPlayerMeetActivityLevelRequirements(nID)
	local vAvailability = DoesPlayerMeetActivityLevelRequirements(vID)
  if nAvailability == false then return 0 end
  if vAvailability == false then return 1 end
-- Both Available
  return 2
end

--Check the Skill point of dungeon by quest status
function BAF.DungeonSkill(QuestID)
  --GetCompletedQuestInfo(integer questId)
  --Returns: string name, QuestType questType
  local QuestName, QuestStatus = GetCompletedQuestInfo(QuestID)
  if QuestStatus == 5 then --Done and submit
    return true
  else
    return false
  end
end

--Check the HM achievement of dungeon
function BAF.DungeonAchi(AchievementID)
  --GetAchievementInfo(integer achievementId)
  --return:string name, string description, integer points, textureName icon, bool completed, string date, string time
  if AchievementID == nil then return 2 end
  local _, _, _, _, Finished = GetAchievementInfo(AchievementID)
  if Finished == true then
    return 1
  else
    return 0
  end
end

--Look for undaunted dungeon via quest matching
--Theoretically suitable for any language, but only en and zh were tested.
--The quest name had to include the full name of dungeon.
--Worried about the diff of I/II, when it replaced with other symbol to denote 1/2
function BAF.DungeonUndaunted(QuestID)
  for i = 1,25 do --Look for all quests in bag
    if GetJournalQuestType(i) == 15 then --Undaunted quest type
      local _, _, _, Step = GetJournalQuestInfo(i)
      --string questName, string backgroundText, string activeStepText, integer activeStepType, 
      --string activeStepTrackerOverrideText, bool completed, bool tracked, integer questLevel, 
      --bool pushed, integer questType, ZoneDisplayType zoneDisplayType
      if Step == 1 then  --Undone Undaunted quest
        if GetJournalQuestName(i) == GetQuestName(QuestID) then -- Match the Dungeon-related undauted quest
          return true
        end
      end
    end
  end
  return false
end

--To auto switch quest tracked
function BAF.AutoStitchUQ()
  --Patch for Marking chests after ReloadUI
  BAF.MarkChests()
  --
  if BAF.savedVariables.Auto_Switch == false or IsUnitInDungeon("player") == false then return end
  local ZoneId = GetUnitWorldPosition("player")
  local QuestID
  for i = 1, #BAF.BaseDungeonInfo do
    if ZoneId == BAF.BaseDungeonInfo[i][3] then
      QuestID = BAF.BaseDungeonInfo[i][10]
      break
    end
  end
  for i = 1, #BAF.DLCDungeonInfo do
    if ZoneId == BAF.DLCDungeonInfo[i][3] then
      QuestID = BAF.DLCDungeonInfo[i][10]
      break
    end
  end
  if not QuestID then return end
  for i = 1, 25 do
    if GetJournalQuestType(i) == 15 then -- Only check Undaunted quest
      if GetJournalQuestName(i) == GetQuestName(QuestID) then
        FOCUSED_QUEST_TRACKER:ForceAssist(i)
        return
      end
    end
  end
end

--Double check for leaving dungeons when holding skill point quest
local OldQTE = ExitInstanceImmediately
function BAF.DoubleCheckPTE()
  if BAF.savedVariables.DoubleCQTE then
    ExitInstanceImmediately = function()
      local nowZoneId =  GetUnitWorldPosition("player")
      local relatedQuestId
      for i = 1, #BAF.BaseDungeonInfo do
        if nowZoneId == BAF.BaseDungeonInfo[i][3] then relatedQuestId = BAF.BaseDungeonInfo[i][9] end
      end
      for i = 1, #BAF.DLCDungeonInfo do
        if nowZoneId == BAF.DLCDungeonInfo[i][3] then relatedQuestId = BAF.DLCDungeonInfo[i][9] end
      end
      --No related skill quests in this zone
      if not relatedQuestId or not HasQuest(relatedQuestId) then OldQTE() return end
      --Double Check Dialog Register
      if not ESO_Dialogs["BetterDungeonFinder_DoubleCheckQTE"] then
        ESO_Dialogs["BetterDungeonFinder_DoubleCheckQTE"] = {
          canQueue = true,
          title = {text = "BDF"},
          mainText = {text = BAFLang_SI.DIALOG_DoubelCQTE_MT},
          buttons = {
            {
              text = GetString(SI_EXIT_BUTTON),
              callback = function(dialog) OldQTE() return end,
            },
            {
              text = SI_DIALOG_CANCEL,
              callback =  function(dialog) return end,
            },
          }
        }
      end
      ZO_Dialogs_ShowDialog("BetterDungeonFinder_DoubleCheckQTE", nil, {mainTextParams = {GetQuestName(relatedQuestId)}})
    end
  else
    ExitInstanceImmediately = OldQTE
  end
end

--Look for dungeon droping style according to onsale armor pack.
local RichPatch = { --Some pack have two Id
  [6218] = 6236,
  [6216] = 6231,
  [6214] = 6226,
}

function BAF.DungeonRich(PackID)
  for i = 1, #BAF.OnSale do
    if PackID == BAF.OnSale[i] then return true end
  end
  if RichPatch[PackID] then
    return BAF.DungeonRich(RichPatch[PackID])
  end
  return false
end

--Count the total number of sets and unlocks
function BAF.GearCount(SetIDs)
  if SetIDs == nil then return end
  local GearUnlock = 0
  local GearTotal = 0
  local GearUnlockS = 0
  local GearShoulder = 0
  for i = 1, #SetIDs do
    local total = GetNumItemSetCollectionPieces(SetIDs[i])
    local unlock = GetNumItemSetCollectionSlotsUnlocked(SetIDs[i])
    GearTotal = GearTotal + total
    GearUnlock = GearUnlock + unlock
    if total == 6 then
      GearShoulder = GearShoulder + 3
      for j = 4, 6 do
        if IsItemSetCollectionPieceUnlocked(GetItemSetCollectionPieceInfo(SetIDs[i], j)) then
          GearUnlockS = GearUnlockS + 1
        end
      end
    end
  end
  if BAF.savedVariables.Hide_Shoulder then
    return {GearUnlock - GearUnlockS, GearTotal - GearShoulder}
  else
    return {GearUnlock, GearTotal}
  end
end

--Done with LibSets to open stickbook
function BAF.OpenCollection(Button)
  local Name = Button:GetName()
  local ZoneID = 0
  local index = Name:gsub("%D+", "")
  if string.find(Name, "BD_") then ZoneID = BAF.BD[tonumber(index)]["zoneId"] end
  if string.find(Name, "DD_") then ZoneID = BAF.DD[tonumber(index)]["zoneId"] end
  if string.find(Name, "UD_") then ZoneID = BAF.UD[tonumber(index)]["zoneId"] end

  local Categoryid = LibSets.GetItemSetCollectionCategoryIds(ZoneID)
  if not Categoryid then
    d("[BDF] Something Wrong With LibSets")
    return 
  end
  local Categorydata = LibSets.GetItemSetCollectionCategoryData(Categoryid[1])
  if Categorydata ~= nil then
    LibSets.OpenItemSetCollectionBookOfCategoryData(Categorydata)
    BAF.ShowWindow()
    return
  end
  d("[BDF] Something Wrong With LibSets")
end

--To open AchievementPopup
function BAF.AchievementPopup(Control)
  local Name = Control:GetName()
  local index = Name:gsub("%D+", "")
  local DungeonInfo = {}
  if string.find(Name, "BD_") then DungeonInfo = BAF.BD[tonumber(index)]["Raw"] end
  if string.find(Name, "DD_") then DungeonInfo = BAF.DD[tonumber(index)]["Raw"] end
  if string.find(Name, "UD_") then DungeonInfo = BAF.UD[tonumber(index)]["Raw"] end
  
  local AId = 0
  local StyleTable = {}

  if string.find(Name, "_HM") then AId = DungeonInfo[5] end
  if string.find(Name, "_SR") then AId = DungeonInfo[6] end
  if string.find(Name, "_ND") then AId = DungeonInfo[7] end
  if string.find(Name, "_TR") then AId = DungeonInfo[8] end
  if string.find(Name, "_Title") then
    AId = DungeonInfo[12]
    --Something wrong with progress function, do it by my own
    for i = 1, 14 do
      local Desc, IsGet = GetAchievementCriterion(AId, i) 
      if IsGet == 1 then
        StyleTable[i] = "|cFFFFFF"..Desc.."|r"
      else
        StyleTable[i] = "|c666666"..Desc.."|r"
      end
    end
  end
  
  if AId == nil or AId == 0 then return end
  if tonumber(index)%12 > 6 or tonumber(index)%12 == 0 then
    InitializeTooltip(PopupTooltip, Control, BOTTOM, 0, 0, TOP)
  else
    InitializeTooltip(PopupTooltip, Control, TOP, 0, 0, BOTTOM)
  end
  PopupTooltip:SetAchievement(AId)
  --For Style Master
  if StyleTable[1] ~= nil then
    local FixedIndex = {8, 12, 5, 7, 2, 9, 3, 1, 10, 6, 14, 11, 4, 13}
    PopupTooltip:AddLine("")
    for i = 1, #FixedIndex do
      PopupTooltip:AddLine(StyleTable[FixedIndex[i]])
    end
  end
end