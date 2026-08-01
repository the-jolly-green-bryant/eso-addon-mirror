----------------------------
local BAF = BetterDungonFinder
--Default setting for controls position and lock
BAF.XML_Default = {
  FirstTime = true,
  
  Window_Point = 128,
  Window_rPoint = 128,
  Window_OffsetX = 0,
  Window_OffsetY = 0,
  Window_Lock = false,
  Window_Left = false,
  Window_LeftV = 0,
  
  Button_Point = 128,
  Button_rPoint = 128,
  Button_OffsetX = 0,
  Button_OffsetY = -200,
  Button_Lock = false,
  Button_Hide = false,
  
  Pure_Black = false,
  Auto_Switch = true,
  AutoConfirm = 0,
  DoubleCQTE = true,
  
  Mark_Chest = true,
  Icon_Chest = "/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds",
  Size_Cheset = 128,
  Share_Chest = true,

  AutoUDQ = true,
  UDQDelay = 300,
  Hide_Shoulder = false,
  CofferHelper = true,

  BGSound = true,
  BGSoundC = false,
  AlertSound = 14,

  AlphaLow = 0.2,
  AlphaHigh = 0.9,
  
  BDSort = {},
  DDSort = {},
  
  SavedList = {},
  ChestList = {},
}
--Start point
local function OnAddOnLoaded(eventCode, addonName)
  --When BAF loaded
  if addonName ~= BAF.name then return end
	EVENT_MANAGER:UnregisterForEvent(BAF.name, EVENT_ADD_ON_LOADED)
  
  --Get account setting
  BAF.savedVariables = ZO_SavedVars:NewAccountWide("BetterActivityFinder_Vars", 1, nil, BAF.XML_Default, GetWorldName())
  BAF.Initial()
  
  --Close with error, and reset it
  if BAF.savedVariables.BGSoundC then
    SetSetting(SETTING_TYPE_AUDIO, 12, 0)
    BAF.savedVariables.BGSoundC = false
  end
  
  --keybind string
  ZO_CreateStringId("SI_BINDING_NAME_BDF_OPEN", BAFLang_SI.KEYBIND)
  
  --RegisterEvent
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, BAF.QueueStatus)
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, BAF.CDRefresh)
  SCENE_MANAGER:RegisterTopLevel(BAFTopLevel, locksUIMode)
  SCENE_MANAGER:RegisterCallback("SceneStateChanged", BAF.UDQCore)
  
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_ZONE_CHANGED, BAF.ZoneChanged)
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_CLIENT_INTERACT_RESULT, BAF.AddMarkChest)
  
  --[[
  --LibDataShare
  if LibDataShare then
    BAF.ShareData = LibDataShare:RegisterMap("BetterDungeonFinder", 38, BAF.HandleDataShareReceived)
    EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_PLAYER_COMBAT_STATE, BAF.SendChestMarkerData)
  end
  ]]
  
  --LibGroupBroadcast
  if LibGroupBroadcast then
    local LGB = LibGroupBroadcast
    BAF.ShareHandler = LGB:RegisterHandler(BAF.name)
    BAF.ShareHandler:SetDisplayName(BAF.name)
    BAF.ShareProtocol = BAF.ShareHandler:DeclareProtocol(100, BAF.name)
    BAF.ShareProtocol:AddField(LGB.CreateNumericField("zoneId", {minValue = 1, maxValue = 10000}))
    BAF.ShareProtocol:AddField(LGB.CreateArrayField(
      LGB.CreateNumericField("xyz", {minValue = 0, maxValue = 999999}), {maxLength = 120}
    ))
    BAF.ShareProtocol:OnData(BAF.HandleDataShareReceived)
    BAF.ShareProtocol:Finalize({
      isRelevantInCombat = false,
      replaceQueuedMessages = false,
    })
    EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_PLAYER_COMBAT_STATE, BAF.SendChestMarkerData)
  end
  
  --Can get info from crown store now?
  BAF.OnSalePack() 
  if BAF.OnSale[1] == nil then
    EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_PLAYER_ACTIVATED, BAF.FirstActived)
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", BAF.CrownLoad)
    return
  end
  --If need to load crown store info, delay the register of SwitchingQuest
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_PLAYER_ACTIVATED, BAF.AutoStitchUQ)
end
----------------------------
--  The info of crown store
----------------------------
--Open crown store when could
function BAF.FirstActived()
  ShowMarketProduct(0) -- open crown market
  EVENT_MANAGER:UnregisterForEvent(BAF.name, EVENT_PLAYER_ACTIVATED)
  --Register the SwitchQuest function
  EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_PLAYER_ACTIVATED, BAF.AutoStitchUQ)
  --FirstTime display
  if BAF.savedVariables.FirstTime then
    d(BAFLang_SI.FirstTime)
    BAF.savedVariables.FirstTime = false
  end
end
--Close crown store and get info for RichFinder
--Display annoucement according to daily reward
function BAF.CrownLoad(scene,_,newstate)
  if scene == SCENE_MANAGER.scenes.market and newstate == SCENE_SHOWING then
    SCENE_MANAGER:Hide("market") -- hide crown market
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", BAF.CrownLoad)
    --The load of crown store info may cover the display of annoucement.
    --If daily reward not get, show annoucement again.
    local ShouldGet = GetNumClaimableDailyLoginRewardsInCurrentMonth() - math.modf(GetTimeUntilNextDailyLoginMonthS()/86400) 
    if GetDailyLoginNumRewardsClaimedInMonth() ~= ShouldGet then --(CanGet - Dayleft) = shoudget =? already get
      SCENE_MANAGER:Show("marketAnnouncement")
    end
  end
end
----------------------------
--        Initial
----------------------------
function BAF.Initial()
  --initialize everything
  BAF.DungeonSort()
  BAF.DungeonInitial()
  BAF.ControlsInitial()
  BAF.WindowInitial()
  BAF.DoubleCheckPTE()
  --RegisterAddonMenu and update lock
  BAF.buildMenu()
end
----------------------------
--Resort the dungeonList
function BAF.DungeonSort()
  for i = 1, #BAF.BaseDungeonInfo do
    if not BAF.savedVariables.BDSort[i] then
      BAF.savedVariables.BDSort[i] = i
    end
  end
  for i = 1, #BAF.DLCDungeonInfo do
    if not BAF.savedVariables.DDSort[i] then
      BAF.savedVariables.DDSort[i] = i
    end
  end
  local BD = {unpack(BAF.BaseDungeonInfo)}
  local DD = {unpack(BAF.DLCDungeonInfo)}
  for i = 1, #BAF.BaseDungeonInfo do
    BAF.BaseDungeonInfo[i] = BD[BAF.savedVariables.BDSort[i]]
  end
  for i = 1, #BAF.DLCDungeonInfo do
    BAF.DLCDungeonInfo[i] = DD[BAF.savedVariables.DDSort[i]]
  end
end
----------------------------
--Structure the dungeonList
function BAF.DungeonInitial()
	for i = 1, #BAF.BaseDungeonInfo do
		BAF.BD[i]= {
      ["Raw"] = BAF.BaseDungeonInfo[i], 
      ["Name"] = GetActivityName(BAF.BaseDungeonInfo[i][1]), 
      ["nId"] = BAF.BaseDungeonInfo[i][1],
      ["vId"] = BAF.BaseDungeonInfo[i][2],
      ["zoneId"] = GetActivityZoneId(BAF.BaseDungeonInfo[i][1]),
      ["Style"] = BAF.BaseDungeonInfo[i][12],
      ["TravelIndex"] = BAF.BaseDungeonInfo[i][13],
		}
	end
	for i = 1, #BAF.DLCDungeonInfo do
		BAF.DD[i]= {
      ["Raw"] = BAF.DLCDungeonInfo[i], 
      ["Name"] = GetActivityName(BAF.DLCDungeonInfo[i][1]), 
      ["nId"] = BAF.DLCDungeonInfo[i][1],
      ["vId"] = BAF.DLCDungeonInfo[i][2],
      ["zoneId"] = GetActivityZoneId(BAF.DLCDungeonInfo[i][1]),
      ["Style"] = BAF.DLCDungeonInfo[i][12],
      ["TravelIndex"] = BAF.DLCDungeonInfo[i][13],
		}
    if BAF.DD[i]["Name"] == "" then BAF.DD[i] = nil end
	end
  BAF.DungeonUpdate()
end
----------------------------
--Reset controls by savedvariables
function BAF.ControlsInitial()
    --Reset the position of controls
  BAFTopLevel:ClearAnchors()
  BAFTriggle_Button:ClearAnchors()
  BAFTopLevel:SetAnchor (
    BAF.savedVariables.Window_Point,
    GuiRoot,
    BAF.savedVariables.Window_rPoint,
    BAF.savedVariables.Window_OffsetX,
    BAF.savedVariables.Window_OffsetY
  )
  BAFTriggle_Button:SetAnchor (
    BAF.savedVariables.Button_Point,
    GuiRoot,
    BAF.savedVariables.Button_rPoint,
    BAF.savedVariables.Button_OffsetX,
    BAF.savedVariables.Button_OffsetY
  )
  --Reset the status of controls
  BAFTopLevel:SetHidden(true)
  BAFTriggle_Button:SetHidden(BAF.savedVariables.Button_Hide)
  BAFPureBlack:SetHidden(not BAF.savedVariables.Pure_Black)
end

--Create Controls from virtuals temple
function BAF.WindowInitial()
  for i = 1, #BAF.BD do
    if BAF.BD[i] ~= nil then
      BAF.BDC[i] = CreateControlFromVirtual(
        "BD_"..i, 
        WINDOW_MANAGER:GetControlByName("BAFWindow_Base"), 
        "BAFSingleDungeon"
      )
      BAF.BDC[i]:SetHidden(false)
    end
  end
  for i = 1, #BAF.DD do
    if BAF.DD[i] ~= nil then
      BAF.DDC[i] = CreateControlFromVirtual(
        "DD_"..i, 
        WINDOW_MANAGER:GetControlByName("BAFWindow_DLC"), 
        "BAFSingleDungeon"
      )
      BAF.DDC[i]:SetHidden(false)
    end
  end
  --It's different for Unduanted dungeon. Need to change info included in existing controls.
  for i =1 ,3 do
    BAF.UDC[i] = CreateControlFromVirtual(
        "UD_"..i, 
        WINDOW_MANAGER:GetControlByName("BAFWindow_Unduanted"), 
        "BAFSingleDungeon"
      )
    BAF.UDC[i]:SetHidden(false)
  end
  BAF.WindowPositionSet()
  BAF.WindowUpdate()
end
----------------------------
-- The size of Dungeon Name
----------------------------
--Make the dungeon title the right size for different languages, when label Initial
function BAF.LabelFont(Label)
  if BAFFontSize ~= "" then Label:SetFont(CustomFontSizeForDungeon) return end
  if GetCVar("language.2") == "zh" then Label:SetFont("BAFWinH3") return end
  if GetCVar("language.2") == "de" then Label:SetFont("BAFWinH5") return end
  if GetCVar("language.2") == "fr" then Label:SetFont("BAFWinH5") return end
  if GetCVar("language.2") == "ru" then Label:SetFont("BAFWinH5") return end
  if GetCVar("language.2") == "es" then Label:SetFont("BAFWinH5") return end
end
----------------------------
--Tool fun
local function InRange(x, z, Table)
  if Table == nil then return false end
  if x > Table[1] and x < Table[3] and z > Table[2] and z < Table[4] then 
    return true 
  end
  return false
end
--Work fun
local Old = INTERACTION.FinalizeChatterOptions
function BAF.FirstChatter()
  local Type = ZO_ChatterOption1.optionType
  if Type == 600 then
    INTERACTION.FinalizeChatterOptions = Old
    INTERACTION:CloseChatter()
    return
  end
  zo_callLater(function() INTERACTION:HandleChatterOptionClicked(ZO_ChatterOption1) end, BAF.savedVariables.UDQDelay)
end
--Auto Get/Finish UD Quest
function BAF.UDQCore(scene, _, newstate)
  if not BAF.savedVariables.AutoUDQ then return end
  if scene.name == "interact" and newstate == SCENE_HIDING then INTERACTION.FinalizeChatterOptions = Old end
  if scene.name ~= "interact" or newstate ~= SCENE_SHOWN or IsInteractingWithMyAssistant() then return end
  local Map, x, _, z = GetUnitWorldPosition("player")
  if InRange(x, z, BAF.UDRange[Map]) and INTERACTION.optionCount == 3 then
    INTERACTION.FinalizeChatterOptions = function(...)
      local Result = Old(...)
      BAF.FirstChatter()
      return Result
    end
    SelectChatterOption(1)
  end
end
-- Start Here
EVENT_MANAGER:RegisterForEvent(BAF.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)