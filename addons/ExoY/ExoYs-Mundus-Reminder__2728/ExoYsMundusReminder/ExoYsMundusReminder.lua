EMR = {}
EMR.name = "ExoYsMundusReminder"
EMR.version = "1.3"
EMR.author = "@Exoy94 (PC/EU)"


function EMR.OnAddOnLoaded(event, addonName)
  if addonName == EMR.name then
    EMR.Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_ADD_ON_LOADED, EMR.OnAddOnLoaded)

function EMR.Initialize()
  EMR.LoadSaveVariables()
  EMR.AddonMenu()
  EMR.RestoreNotification()
  if EMR.savedVariables.normal or EMR.savedVariables.veteran or EMR.savedVariables.ava then EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_PLAYER_ACTIVATED, EMR.Delay) end
  if EMR.savedVariables.queueParty then EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, EMR.PartyQueue) end
  if EMR.savedVariables.queueAVA then EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_CAMPAIGN_QUEUE_JOINED, EMR.AVAQueue) end
  if EMR.savedVariables.duelStart then EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_DUEL_COUNTDOWN, EMR.DuelStarting) end
  if EMR.savedVariables.duelInv then
    EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_DUEL_INVITE_RECEIVED, EMR.DuelRequest)
    EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_DUEL_INVITE_SENT, EMR.DuelRequest)
  end
  if EMR.savedVariables.group then EVENT_MANAGER:RegisterForEvent(EMR.name, EVENT_GROUP_MEMBER_JOINED, EMR.JoinedGroup) end
end

function EMR.LoadSaveVariables()

  local defaultSV = {
      uiLeft = CENTER,
      uiTop = CENTER,
      --Font
      fontPathNo = 3,
      fontColor = {1, 1, 1, 1},
      fontSize = 40,
      fontOutlineNo = 2,
      uiScale = 1,
      bgColor = {0, 0, 0, 0.7},
      duration= 5,
      normal = true,
      veteran = true,
      ava = true,
      group = true,
      queueParty = true,
      queueAVA = true,
      duelInv = true,
      duelStart = true,
    }

  EMR.savedVariables = ZO_SavedVars:NewAccountWide("EMRSV", 1, nil, defaultSV)
  EMR.outlines = fontOutlines
  EMR.duration = EMR.savedVariables.duration
end

------------------
-- Notifications
------------------

local fontPaths = {
  [1] = "EsoUI/Common/Fonts/Univers57.otf",
  [2] = "EsoUI/Common/Fonts/Univers67.otf",
  [3] = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
  [4] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
  [5] = "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
}

local fontOutlines = {
  [1] = "soft-shadow-thick",
  [2] = "soft-shadow-thin",
  [3] = "thick-outline",
}

function EMR.OnIndicatorMoveStop()
  EMR.savedVariables.uiLeft = EMR_Mundus_Notification:GetLeft()
  EMR.savedVariables.uiTop = EMR_Mundus_Notification:GetTop()
end

function EMR.UpdateNotification()
  local control = EMR_Mundus_Notification
  local label = EMR_Mundus_Notification_Label
  local background = EMR_Mundus_Notification_Background

  fontPath = fontPaths[EMR.savedVariables.fontPathNo]
  outline = fontOutlines[EMR.savedVariables.fontOutlineNo]

  label:SetColor(unpack(EMR.savedVariables.fontColor))
  label:SetScale(EMR.savedVariables.uiScale)

  label:SetFont(fontPath .. "|" .. EMR.savedVariables.fontSize .. "|" .. outline)


  local width = label:GetTextWidth()
  local height = label:GetTextHeight()

  control:SetDimensions(width, height)

  local bgWidth = EMR.savedVariables.uiScale*(width + 0.5*EMR.savedVariables.fontSize)
  local bgHeight = EMR.savedVariables.uiScale*height
  background:SetDimensions(bgWidth, bgHeight)
  background:SetCenterColor(unpack(EMR.savedVariables.bgColor))
end

function EMR.RestoreNotification()
  EMR_Mundus_Notification:ClearAnchors()
  EMR_Mundus_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, EMR.savedVariables.uiLeft, EMR.savedVariables.uiTop)
  EMR.UpdateNotification()
end

function EMR.ShowNotification(time)
  local wait = time * 1000
  EMR:RefreshMundus()
  EMR_Mundus_Notification:SetHidden(false)
  zo_callLater(function() EMR.HideNotification() end, wait)
end

function EMR.HideNotification()
  EMR_Mundus_Notification:SetHidden(true)
end

----

function EMR.AVAQueue()
  EMR.ShowNotification(EMR.duration)
end

function EMR.DuelStarting()
  EMR.ShowNotification(2)
end

function EMR.DuelRequest()
  EMR.ShowNotification(EMR.duration)
end

function EMR.LocationCheck()
  if EMR.savedVariables.normal then
    if GetCurrentZoneDungeonDifficulty() == 1 then
      EMR.ShowNotification(EMR.duration)
    end
  end
  if EMR.savedVariables.veteran then
    if GetCurrentZoneDungeonDifficulty() == 2 then
      EMR.ShowNotification(EMR.duration)
      --EVENT_MANAGER:RegisterForUpdate(EMR.Name, 3000, EMR.Delay)
    end
  end
  if EMR.savedVariables.ava then
    if IsPlayerInAvAWorld() or IsInImperialCity() then
      EMR.ShowNotification(EMR.duration)
    end
  end
end

function EMR.Delay()
    local newLocation = EMR.LocationChange()
    if newLocation then
      zo_callLater(function() EMR.LocationCheck() end, 1500)
    end
end

function EMR.LocationChange()
  local oldZone = nil
  local newZone = GetUnitZoneIndex("player")
  if EMR.currentZone ~= nil then
    oldZone = EMR.currentZone
  end
  EMR.currentZone = GetUnitZoneIndex("player")
  if oldZone == newZone then
    --d('zone gleich geblieben')
    return false
  else
    --x^^d('neue Zone')
    return true
  end

end

function EMR.PartyQueue(event, status)
  if status == 0 then EMR.HideNotification() end
  if status == 1 then EMR.ShowNotification(EMR.duration) end
end

function EMR.JoinedGroup(_, _, displayName)
  if displayName == GetUnitDisplayName("player") then EMR.ShowNotification(EMR.duration) end
end

---Mundus

function EMR.RefreshMundus()

  local MundusID =
    {
    [13979] = 'Apprentice', --Lehrling
    [13984] = 'Shadow', --Schatten
    [13975] = 'Thief', --Dieb
    [13982] = 'Atronach', --Attronach
    [13943] = 'Mage', --Magier
    [13981] = 'Lover', --Liebenden
    [13980] = 'Ritual', --Ritual
    [13940] = 'Warrior', --Krieger
    [13974] = 'Serpent', --Schlange
    [13977] = 'Steed', --Schlachtross
    [13985] = 'Tower', --Turm
    [13978] = 'Lord', --Fürst
    [13976] = 'Lady', --Fürstin
    }

  local skills = EMR.ListSkills()
  local mundusName = "No Mundus!"
  for i, skillID in pairs(skills) do
    if MundusID[skillID] ~= nil then
      mundusName = MundusID[skillID]
    end
  end
  EMR_Mundus_Notification_Label:SetText(mundusName)
end

function EMR.ListSkills()
  local activeSkills = {}
  for i=1, (GetNumBuffs("player")) ,1 do
    local _, _, _, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
    activeSkills[#activeSkills+1] = abilityId
  end
  return activeSkills
end

-----------------
-- Port Feature
-----------------

--function EMR.Port()
--    JumpToSpecificHouse(displayName, houseID)
--end

---------------
-- Development
---------------

-- function EMR.Test()
--  d(EMR.currentZone)
--  if EMR.currentZone ~= nil then
--    d("nicht nil")
--  end
-- end

--function EMR.Visible()
--  EMR_Mundus_Notification:SetHidden(false)
--end

--SLASH_COMMANDS["/mtest"] = EMR.Test
--SLASH_COMMANDS["/ui"] = EMR.Visible
--SLASH_COMMANDS["/mundus"] = EMR.RefreshMundus
