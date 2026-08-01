local RF = RipFilter or {}

RF.name = "RipFilter"
RF.version = "0.75 alpha"

-- info
local allPlayers = {}     -- 15/04/2019 plan daily basis

-- accumalators
local deathList = {}      -- [name] = 33
local rezList = {}
local kbList = {}
local wipes = 0

-- links
local lastAbilityInfo = 0
local lastName = ""
local lastRecapNo = 0

local fragment = ZO_HUDFadeSceneFragment:New(RF_RECAP)

-- recaps
RF.RecapScrollListManager = RF.RecapScrollList

SLASH_COMMANDS["/rip"] = function() RipFilter:PostList("Killing Blows") end
SLASH_COMMANDS["/ripd"] = function() RipFilter:PostList("Deaths") end
SLASH_COMMANDS["/ripr"] = function() RipFilter:PostList("Resurrections") end
SLASH_COMMANDS["/ripw"] = function() RipFilter:PostSingle("Wipes") end
SLASH_COMMANDS["/ripreset"] = function() RipFilter:Reset("RipFilter has been reset") end
SLASH_COMMANDS["/riprecap"] = function() RipFilter:SetHiddenRecap(not RF_RECAP:IsHidden()) end

SLASH_COMMANDS["/riptest"] = function() RipFilter:Test() end

function RF:Test()
  d(UTOpts)
end

-- debug
RF.AP = allPlayers

function RF:UpdatePlayer(unitTag, unitId)
  local name = GetUnitDisplayName(unitTag)

  -- not sure why it would send "group11" but have a nil name
  -- someone left a group and another joined... there wasnt even 11 players
  if name == nil then return end

  if allPlayers[name] == nil then
    allPlayers[name] = {}
    allPlayers[name].killingBlow = ""
    allPlayers[name].recapList = {}
    table.insert(allPlayers[name].recapList, {})

    local function OnItemSelect(_, choiceText)
      RF.RecapScrollListManager:SelectRecap(name, #allPlayers[name].recapList)
      PlaySound(SOUNDS.POSITIVE_CLICK)
    end

    local comboBox = RF_RECAP_PlayersListStatus.comboBox
    local entry = comboBox:CreateItemEntry(name, OnItemSelect)
    comboBox:AddItem(entry)
    --IsUnitGroupLeader(unitTag)
    --local isDps, isHeal, isTank = GetGroupMemberRoles(unitTag)
  end

  allPlayers[name].unitId = unitId
  allPlayers[name].unitTag = unitTag
end

  -- Always update because unitId and unitTags change
  -- Goal is to either create a fresh row or update an existing one for allPlayers[]
function RF:OnEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
  if self:isValidPlayer(unitTag) or unitTag == "player" then
    self:UpdatePlayer(unitTag, unitId)
  end
end

-- Can accurately find person using GetUnitDisplayName(unitTag)
--
-- does not like self:OutMsg in here !!!
function RF:OnDeathStateChanged(eventCode, unitTag, isDead)

  if isDead and self:isValidPlayer(unitTag) then
    -- update deathlist
    local name = GetUnitDisplayName(unitTag)
    self:UpdateList(name, deathList)

    -- There is a chance OnEffect did not fire before this person died
    -- no unitId
    -- e.g. ninja dies in another zone
    self:UpdatePlayer(unitTag, nil)

    -- begin delayed function
    local funcName = "RFCallLaterFunction" .. name

    EVENT_MANAGER:RegisterForUpdate(funcName, 2000, function()
      local outLine = ""
      local player = allPlayers[name]
      local recapList = player.recapList

      if player.killingBlow == "" then
        --
        local colourA = (GetUnitDisplayName("player") == name) and self.SV.gColourA or self.SV.ngColourA
        local colourB = (GetUnitDisplayName("player") == name) and self.SV.gColourB or self.SV.ngColourB
        local combatList = recapList[#recapList]

        -- Add "unknown attack" to recap (abilityName=Unknown and sourcename=Zone)
        table.insert(combatList, {timestamp=GetTimeString(), abilityId=0, abilityName="Unknown", sourceName=zo_strformat(SI_SOCIAL_LIST_LOCATION_FORMAT, GetUnitZone(unitTag)), hitValue=99999, multipleHits=1, abilityType=-ACTION_RESULT_DAMAGE})

        local recapLink = self:makeLink("RF Recap Link", "[RECAP]", colourA, name, #recapList)
        outLine = recapLink .. " " .. self:Colorize(name, colourB) .. self:Colorize(" died from ", colourA) .. self:Colorize("[Unknown]", colourB)
      else
        outLine = player.killingBlow
      end

      -- next recap
      --recapList[#recapList+1] = {}
      table.insert(allPlayers[name].recapList, {})
      self:OutMsg(outLine)
      player.killingBlow = ""
      EVENT_MANAGER:UnregisterForUpdate(funcName)
    end)

  end
end

-- Returns: string displayName
function RF:GetInfoFromUnitId(unitId)
  for k, v in pairs(allPlayers) do
    if allPlayers[k].unitId == unitId then
      return k
    end
  end
  return false
end

function RF:OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId, targetUnitId, abilityId, overflow)

    -- only check players we know about
  local name = self:GetInfoFromUnitId(targetUnitId)
  if not name then return end
  local recapList = allPlayers[name].recapList

  -- damage recap
  if self.RECAP_ACTION_RESULTS[result] then
    -- Going to add an attack to the most recent recap
    local combatList = recapList[#recapList]    -- most recent/last combatList
    local attackSize = #combatList              -- number of attacks/last attack pos
    local lastAttack = combatList[attackSize]   -- last row of combatList
    local abilityName = GetAbilityName(abilityId) and GetAbilityName(abilityId) or ""

    if result == ACTION_RESULT_KILLED_BY_SUBZONE then
      abilityName = "Environmental Damage"
    end

    if result == ACTION_RESULT_BLOCKED_DAMAGE then
      abilityName = abilityName .. " (Blocking)"
    end

    -- merge shielded attacks
    if attackSize > 0 and lastAttack.abilityType == ACTION_RESULT_DAMAGE_SHIELDED then
      lastAttack.abilityId = abilityId
      lastAttack.abilityName = abilityName ..  " (Shielded)"
      lastAttack.hitValue = -lastAttack.hitValue
      lastAttack.abilityType = -1 -- displays no dmg
      self.RecapScrollListManager:RefreshIfLive()
    else
      -- accumulate repeated attacks
      if attackSize > 0 and self.SV.recapMergeAttacks and lastAttack.abilityId == abilityId then
          lastAttack.hitValue = lastAttack.hitValue + hitValue
          lastAttack.multipleHits = lastAttack.multipleHits + 1
      else
        -- insert new attack
        table.insert(combatList, {timestamp=GetTimeString(), abilityId=abilityId, abilityName=abilityName, sourceName=sourceName, hitValue=hitValue, multipleHits=1, abilityType=result})

        -- limit number of attacks (remove oldest)
        if attackSize > self.SV.recapMaxAttacks then
          table.remove(combatList, 1)
        end

        self.RecapScrollListManager:RefreshIfLive()
      end
    end
  end

  -- killing blows
  if self.DEATH_ACTION_RESULTS[result] then
    local colourA = (GetUnitDisplayName("player") == name) and self.SV.gColourA or self.SV.ngColourA
    local colourB = (GetUnitDisplayName("player") == name) and self.SV.gColourB or self.SV.ngColourB
    local recapLink = self:makeLink("RF Recap Link", "[RECAP]", colourA, name, #recapList)
    local diedFrom =" died from "
    local ability = GetAbilityName(abilityId)
    local abilityLink = self:makeLink("RF Ability Info Link", ability, colourB, abilityId, 0)
    local damageTypeText = self.DAMAGE_TYPE[damageType]

    -- save kb for death event
    allPlayers[name].killingBlow = recapLink .. " " .. self:Colorize(name, colourB) .. self:Colorize(diedFrom, colourA) .. abilityLink .. " " .. self:Colorize(damageTypeText, colourA)

    -- update how many have died from this ability
    self:UpdateList(ability, kbList)
  end
end

-- Recap UI stuff
function RF:InitRecapUI()
  self:SetHiddenRecap(self.SV.recapHidden)
  RF_RECAP:SetWidth(self.SV.recapWidth)
  RF_RECAP:SetHeight(self.SV.recapHeight)
  self:ResizeList()
end

function RF:SetHiddenRecap(hidden)
  if hidden then
    HUD_SCENE:RemoveFragment(fragment)
    HUD_UI_SCENE:RemoveFragment(fragment)
    RF_RECAP:SetHidden(true)
  else
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    RF_RECAP:SetHidden(false)
  end

  self.SV.recapHidden = RF_RECAP:IsHidden()
end

function RF:onMoveStop()
  self.SV.recapTop = RF_RECAP:GetTop();
  self.SV.recapLeft = RF_RECAP:GetLeft();
end

local isResizing = false

function RF:onResizeStart()
  isResizing = true

  -- keep resizing until it has stopped
  EVENT_MANAGER:RegisterForUpdate(self.name.."OnWindowResize", 50, function()
    if isResizing then
      self:ResizeList()
    else
      EVENT_MANAGER:UnregisterForUpdate(self.name.."OnWindowResize")
    end
  end)

end

function RF:onResizeStop()
  isResizing = false
end

function RF:ResizeList()
  self.SV.recapWidth = RF_RECAP:GetWidth()
  self.SV.recapHeight = RF_RECAP:GetHeight()

  -- full or compact mode
  if RF_RECAP:GetWidth() == 640 and RF_RECAP:GetHeight() == 640 then
    self.RecapScrollListManager:SetCompactMode(false)
  else
    self.RecapScrollListManager:SetCompactMode(true)
  end

  -- adjust size of list
  local control = RF_RECAP_Recap_List
  control:SetWidth(RF_RECAP:GetWidth()-10)
  control:SetHeight(RF_RECAP:GetHeight()-115)

  -- refresh list
  self.RecapScrollListManager:RefreshData()
  self.RecapScrollListManager:RefreshFilters()
  self.RecapScrollListManager:ScrollToBottom()
end

-- Links --
function RF.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, data, data2)
  -- show recap
  if linkType == "RF Recap Link" then
    local name = data
    local recapNo = tonumber(data2)

    if lastName == name and lastRecapNo == recapNo then
      lastName = ""
      lastRecapNo = 0
      RF_RECAP:SetHidden(true)
      return true
    end

    lastName = name
    lastRecapNo = recapNo
    RF.RecapScrollListManager:SelectRecap(name, recapNo)
    return true
  end

  -- show ability info
  -- data = abilityid
  if linkType == "RF Ability Info Link" then
    local abilityId = tonumber(data)

    -- toggle
    if abilityId == lastAbilityInfo then
      RIPAI:SetHidden(true)
      lastAbilityInfo = 0
      return true
    end

    RIPAI:SetHidden(false)
    lastAbilityInfo = abilityId

    local MECH_TYPE = {
      [POWERTYPE_HEALTH] = "Health",
      [POWERTYPE_HEALTH_BONUS] = "Health Bonus",
      [POWERTYPE_INVALID] = "Invalid",
      [POWERTYPE_MAGICKA] = "Magicka",
      [POWERTYPE_MOUNT_STAMINA] = "Mount Stamina",
      [POWERTYPE_STAMINA] = "Stamina",
      [POWERTYPE_ULTIMATE] = "Ultimate",
      [POWERTYPE_WEREWOLF] = "Werewolf",
    }
    local cost, mechanic = GetAbilityCost(abilityId)

    RIPAIMechanic:SetText(MECH_TYPE[mechanic] .. " " .. tostring(cost))
    RIPAIIcon:SetTexture(GetAbilityIcon(abilityId))
    RIPAIAbilityName:SetText(GetAbilityName(abilityId))

    RIPAIAbilityTargetDescription:SetText(GetAbilityTargetDescription(abilityId))
    RIPAIDescriptionHeader:SetText(GetAbilityDescriptionHeader(abilityId))
    RIPAIDescription:SetText(GetAbilityDescription(abilityId))

    local miscString = ""

    local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
    channeled = channeled and "true" or "false"

    if channeled then
      miscString = miscString .. "Channel Time: " .. tostring(channelTime) .. "\n"
    end

    if castTime > 0 then
      miscString = miscString .. "Cast Time: " .. tostring(castTime) .. "\n"
    end

    local min, max = GetAbilityRange(abilityId)
    if min > 0 or max > 0 then
      miscString = miscString .. "Range: " .. tostring(min) .. "m - " .. tostring(max) .. "m\n"
    end

    local radius = GetAbilityRadius(abilityId)
    if radius > 0 then
      miscString = miscString .. "Radius: " .. tostring(radius) .. "\n"
    end

    local angleDistance = GetAbilityAngleDistance(abilityId)
    if angleDistance > 0 then
      miscString = miscString .. "Angle Distance: " .. tostring(angleDistance) .. "\n"
    end

    local duration = GetAbilityDuration(abilityId)
    if duration > 0 then
      miscString = miscString .. "Duration: " .. tostring(duration) .. "\n"
    end

    local passive = IsAbilityPassive(abilityId)
    local permanent = IsAbilityPermanent(abilityId)
    local isTankRoleAbility, isHealerRoleAbility, isDamageRoleAbility = GetAbilityRoles(abilityId)

    miscString = passive and miscString .. "Is Passive\n" or ""
    miscString = permanent and miscString .. "Is Permanent\n" or ""
    miscString = isTankRoleAbility and miscString .. "Is Tank Role Ability\n" or ""
    miscString = isHealerRoleAbility and miscString .. "Is Healer Role Ability\n" or ""
    miscString = isDamageRoleAbility and miscString .. "Is Damage Role Ability\n" or ""
    RIPAIMisc:SetText(miscString)

    RIPAIMorph:SetText(GetAbilityNewEffectLines(abilityId))

    return true
  end
end

function RF:UpdateList(name, list)
  list[name] = (list[name] == nil) and 1 or list[name] + 1
end

function RF:OnPlayerReincarnated(eventCode)
  self:OutMsg("---------Wipe---------")
  wipes = wipes + 1
end

function RF:OnResurrectResult(eventCode, targetCharacterName, result, targetDisplayName)
  if targetDisplayName ~= GetUnitDisplayName('player') and result == RESURRECT_RESULT_SUCCESS then
    self:UpdateList(targetDisplayName, rezList)
  end
end

function RF:OnRaidTrialStart(eventCode, trialName, weekly)
  if self.SV.enabled == false then return end -- needed here, unregister doesnt work
  local week = weekly and " WEEKLY" or ""

  self:OutMsg("RipFilter vTrial Started " .. trialName .. week)

  if self.SV.trialStartReset == true then
    self:Reset("")
  end
end

function RF:OnRaidTrialComplete(eventCode, trialName, score, totalTime)
  if self.SV.enabled == false then return end -- needed here, unregister doesnt work
  self:OutMsg("RipFilter vTrial Complete " .. trialName .. " Score: " .. tostring(zo_strformat(SI_NUMBER_FORMAT, ZO_CommaDelimitNumber(score))) .. " Time: " .. self:millisecondsToTime(totalTime))
end

-- RipFilter Tab --
function RF:OutMsg(text)
  if self.SV.ripFeed and self.ChatContainer and self.ChatWindow then
    local defaultColour = "8F8F8F"
    local timeColour = "8F8F8F"
    local output = text

    if not string.match(text, "|c") then
      output = self:Colorize(text, defaultColour)
    end

    output = self:Colorize("[" .. GetTimeString() .. "] ", timeColour) .. output
    self.ChatContainer:AddMessageToWindow(self.ChatWindow, output)
  end
end

function RF:GetRipFeed()
  for k, v in ipairs(CHAT_SYSTEM.containers) do
    for i = 1, #v.windows do
      if v:GetTabName(i) == "RipFilter" then
        return v, v.windows[i], i
      end
    end
  end

  local container = CHAT_SYSTEM.primaryContainer
  if container == nil then return _, _, false end
  local window, key = container.windowPool:AcquireObject()
  window.key = key
  container:AddRawWindow(window, "RipFilter")
  local tabIndex = window.tab.index
  container:SetInteractivity(tabIndex, true)
  container:SetLocked(tabIndex, true)
  container:SetTimestampsEnabled(tabIndex, true)

  for category = 1, GetNumChatCategories() do
    container:SetWindowFilterEnabled(tabIndex, category, false)
  end
  return container, window
end

function RF:InitialiseRipFeed()
  if not self.SV.ripFeed then return end
  if ZO_ChatWindowTabTemplate1 then
    self.ChatContainer, self.ChatWindow = self:GetRipFeed()
  else
    zo_callLater(function() self:InitialiseRipFeed() end, 200)
  end
end

function RF:DeinitialiseRipFeed()
  local _, _, windowIndex = self:GetRipFeed()
  if windowIndex == false then return end
  CHAT_SYSTEM.primaryContainer:RemoveWindow(windowIndex)
end

-- Keybindings --
function RF:PostSingle(name)
  local text = "<RipFilter - " .. name .. "> " .. tostring(wipes)
  CHAT_SYSTEM.textEntry:SetText(text)
  CHAT_SYSTEM:Maximize()
  CHAT_SYSTEM.textEntry:Open()
  CHAT_SYSTEM.textEntry:FadeIn()

  if self.SV.ripFeed then
    self:OutMsg(text)
  end
end

function RF:PostList(listName)
  -- ZO_GenerateCommaSeparatedList


  local LIST_RESULTS = {
    ["Deaths"] = deathList,
    ["Killing Blows"] = kbList,
    ["Resurrections"] = rezList,
  }

  local list = LIST_RESULTS[listName]

  if next(list) == nil then
    self:OutMsg("RipFilter - No " .. listName)
  else
    local text = "<RipFilter - " .. listName .. "> "

    for k, v in self:sort(list, function(t,a,b) return t[b] < t[a] end) do
   	  if self:isEmpty(k) == false then
        text = text .. k .. ": " .. tostring(v) .. ", "
      end
    end

    -- append zero deaths
    if listName == "Deaths" then
      for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
          local name = GetUnitDisplayName(unitTag)
          if list[name] == nil then
            text = text .. name .. ": 0, "
          end
        end
      end
    end

    CHAT_SYSTEM.textEntry:SetText(text)
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()

    if self.SV.ripFeed then
      self:OutMsg(text)
    end
  end
end

function RF:Reset(listName)
  if self.SV.enabled == false then return end

  if listName == "Killing Blows" then
    kbList = {}
    self:OutMsg("RipFilter Killing Blows have been Reset")
  elseif listName == "Resurrections" then
    rezList = {}
    self:OutMsg("RipFilter Resurrections have been Reset")
  elseif listName == "Deaths" then
    deathList = {}
    self:DeinitialiseRipFeed()
    self:InitialiseRipFeed()
    self:OutMsg("RipFilter Deaths have been Reset")
  elseif listName == "Wipes" then
    wipes = 0
    self:OutMsg("RipFilter Wipes have been Reset")
  else
    -- same as init
    RIPAI:SetHidden(true)
    allPlayers = {}
    deathList = {}
    rezList = {}
    kbList = {}
    wipes = 0
    lastAbilityInfo = 0
    lastName = ""
    lastRecapNo = 0
    self.RecapScrollListManager:New(RF_RECAP_Recap_List, allPlayers)

    -- init combo box
    local comboBoxControl = RF_RECAP_PlayersListStatus

    if comboBoxControl.comboBox then
      comboBoxControl.comboBox:ClearItems()
    else
      -- ZO_DisplayNameStatusOpenDropdown
      local comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
      --comboBox:SetHighlightedColor("FF0000")
      comboBoxControl.comboBox = comboBox
    end

    -- init allplayers, recap and combobox with player
    local name = GetUnitDisplayName("player")
    self:UpdatePlayer("player", nil)
    self.RecapScrollListManager:SelectRecap(name, 1)

    self:InitRecapUI()
    self:DeinitialiseRipFeed()
    self:InitialiseRipFeed()
    self:OutMsg(listName)
  end
end

-- Initialisations --
function RF:SetupEvents(toggle)

  if toggle then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RESURRECT_RESULT, function(...) self:OnResurrectResult(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, function(...) self:OnPlayerReincarnated(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RAID_TRIAL_STARTED, function(...) self:OnRaidTrialStart(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RAID_TRIAL_COMPLETE, function(...) self:OnRaidTrialComplete(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, function(...) self:OnDeathStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(...) self:OnEffect(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombat(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, false)
  else
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RESURRECT_RESULT)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_REINCARNATED)
    --EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RAID_TRIAL_STARTED)
    --EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RAID_TRIAL_COMPLETE)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
  end
end

function RF:DeInitialise()
  self:SetHiddenRecap(true)
  RIPAI:SetHidden(true)
  self:DeinitialiseRipFeed()
  self:SetupEvents(false)
end

function RF:Initialise()

  -- find addon version (not version)
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == self.name then
      self.version = manager:GetAddOnVersion(i)
    end
  end

  self.SV = ZO_SavedVars:NewAccountWide("RipFilterSettings", self.version, "Settings", self.defaults)

  RIPAI:ClearAnchors()
  RIPAI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  RF_RECAP:ClearAnchors()
  RF_RECAP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.recapLeft, self.SV.recapTop)
  RF_RECAP_AddonNameVersion:SetText("RipFilter v0." .. tostring(self.version))

  self:Reset("RipFilter " .. self.version .. " enabled")
  self:SetupEvents(true)
end

function RF.OnLoad(event, addonName)
  if addonName ~= RF.name then return end
  EVENT_MANAGER:UnregisterForEvent(RF.name, EVENT_ADD_ON_LOADED, RF.OnLoad)
  RF:InitialiseAddoMenu()
  RF:Initialise()

  ZO_CreateStringId("SI_BINDING_NAME_RF_SHOWHIDE_RECAP", "Show or Hide Recap")
  ZO_CreateStringId("SI_BINDING_NAME_RF_KILLING_BLOW", "Post Killing Blow Count")
  ZO_CreateStringId("SI_BINDING_NAME_RF_RESURRECTIONS", "Post Resurrection Count")
  ZO_CreateStringId("SI_BINDING_NAME_RF_DEATHS", "Post Death Count")
  ZO_CreateStringId("SI_BINDING_NAME_RF_WIPES", "Post Wipe Count")
  ZO_CreateStringId("SI_BINDING_NAME_RF_RESET_KILLING_BLOW", "Reset Killing Blows")
  ZO_CreateStringId("SI_BINDING_NAME_RF_RESET_RESURRECTIONS", "Reset Resurrections")
  ZO_CreateStringId("SI_BINDING_NAME_RF_RESET_DEATHS", "Reset Deaths")
  ZO_CreateStringId("SI_BINDING_NAME_RF_RESET_ALL", "Reset All")
end

EVENT_MANAGER:RegisterForEvent(RF.name, EVENT_ADD_ON_LOADED, RF.OnLoad)
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, RF.HandleClickEvent) --as for Update 4 default ingame GUI uses this event
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, RF.HandleClickEvent)  --this event still can be used, so the best practise is registering both events
