CStuffTracker = {
  name = "CompanionStuffTracker",
  version = "1.2.3",
  author = "VisioTempus",
  showDebug = false,
  currentCompanion = 0,
  showCompanion = 0,
  companionStuff = {},
  companionRole = {},
  savedVariables = {
    companionStuff = {},
    companionRole = {},
  },
  
  -- GetActiveCompanionLevelInfo()      Returns: integer level, integer currentExperience 
  -- GetActiveCompanionRapport()      Returns: integer rapport 
  -- GetMaximumRapport()
  -- Rapport par perso (à voir si utile)
  -- S'abonner à l'event changement de niveau pour mettre à jour la valeur
  
  -- Companion Ids :
  --  1 = Bastian
  --  2 = Mirri
  --  5 = Ember
  --  6 = Isobel
  --  8 = Sharp
  --  9 = Azander
  --  12 = Tanlorin
  --  13 = Zerith-var
  companions = {
    ["Bastian"] = 1,
    ["Mirri"] = 2,
    ["Ember"] = 5,
    ["Isobel"] = 6,
    ["Sharp"] = 8,
    ["Azander"] = 9,
    ["Tanlorin"] = 12,
    ["Zerith"] = 13,
  },
  
  companionsListById = {
    [1] = 1,
    [2] = 2,
    [5] = 3,
    [6] = 4,
    [8] = 5,
    [9] = 6,
    [12] = 7,
    [13] = 8,
  },
  
  companionQuestId = {
    [1] = 6626,
    [2] = 6648,
    [5] = 6771,
    [6] = 6760,
    [8] = 7017,
    [9] = 7020,
    [12] = 7186,
    [13] = 7194,
  },
  
  roles = {
    ["Tank"] = 1,
    ["Heal"] = 2,
    ["DPS"] = 3
  },
  
  textureRole = {
    "|t32:32:/esoui/art/lfg/lfg_tank_up.dds|t ",
    "|t32:32:/esoui/art/lfg/lfg_healer_up.dds|t ",
    "|t32:32:/esoui/art/lfg/lfg_dps_up.dds|t "
  },

}

function CStuffTracker.RestorePosition()

  if not CStuffTracker.savedVariables.left or not CStuffTracker.savedVariables.top then
    return
  end

  local left = CStuffTracker.savedVariables.left
  local top = CStuffTracker.savedVariables.top
 
  CStuffTrackerControl:ClearAnchors()
  CStuffTrackerControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function CStuffTracker.Initialize()

  CStuffTracker.showDebug = false

  -- Event when companion stuff is updated.
  EVENT_MANAGER:RegisterForEvent(CStuffTracker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CStuffTracker.OnCompanionStuffChanged)
  EVENT_MANAGER:AddFilterForEvent(CStuffTracker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)
  
  -- Event when companion is activated (successfully summoned).
  EVENT_MANAGER:RegisterForEvent(CStuffTracker.name, EVENT_COMPANION_ACTIVATED, CStuffTracker.OnCompanionActivated)

  CStuffTracker.savedVariables = ZO_SavedVars:NewAccountWide("CompanionStuffTrackerSavedVariables", 1, nil, {
    companionStuff = {},
    companionRole = {}
  })
  
  CStuffTrackerControl:SetHandler("OnMoveStop", function(control)
    CStuffTracker.savedVariables.left = CStuffTrackerControl:GetLeft()
    CStuffTracker.savedVariables.top = CStuffTrackerControl:GetTop()
  end)
  
  if CStuffTracker.savedVariables.companionStuff then
    CStuffTracker.companionStuff = CStuffTracker.savedVariables.companionStuff
  else
    for name, value in pairs(companions) do
      CStuffTracker.savedVariables.companionStuff[value] = {}
      CStuffTracker.companionStuff[value] = {}
    end
  end
  
  if CStuffTracker.savedVariables.companionRole then
    CStuffTracker.companionRole = CStuffTracker.savedVariables.companionRole
  else
    for name, value in pairs(companions) do
      CStuffTracker.savedVariables.companionRole[value] = {}
      CStuffTracker.companionRole[value] = {}
    end
  end
  
  CStuffTracker.RestorePosition()

  -- Placerholder text of companion's name label.
  CStuffTrackerControlCompanionName:SetText("-")

  -- Update companion's label name if a companion is active
  currentCompanion = GetActiveCompanionDefId()
  local name = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(GetCompanionCollectibleId(currentCompanion))
  if name ~= nil and HasActiveCompanion() then 
    -- Change companion name in label.
    CStuffTrackerControlCompanionName:SetText(name:GetFormattedName())
    
    -- List the companion stuff
    CStuffTracker.ListCompanionStuff(currentCompanion, true)
  end
  
  CStuffTrackerControlTank:SetHandler("OnClicked", function() CStuffTracker.AssignRole(CStuffTracker.showCompanion, CStuffTracker.roles["Tank"]) end)
  CStuffTrackerControlHeal:SetHandler("OnClicked", function() CStuffTracker.AssignRole(CStuffTracker.showCompanion, CStuffTracker.roles["Heal"]) end)
  CStuffTrackerControlDPS:SetHandler("OnClicked", function() CStuffTracker.AssignRole(CStuffTracker.showCompanion, CStuffTracker.roles["DPS"]) end)
  
  CStuffTrackerControlClose:SetHandler("OnClicked", CStuffTracker.CloseWindow)
  
  CStuffTrackerControlDonate:SetHidden(GetWorldName() ~= "EU Megaserver")
  CStuffTrackerControlDonate:SetText(GetString(COMPANIONSTUFFTRACKER_DONATE))
  CStuffTrackerControlDonate:SetHandler("OnClicked", CStuffTracker.Donate)
  
  -- Debug window
  CSTClearDebug:SetHandler("OnClicked", function(self) CSTDebug:SetText("") end)
  CSTDebug:SetHidden(not CStuffTracker.showDebug)
  CSTClearDebug:SetHidden(not CStuffTracker.showDebug)
  -- End debug window
  
  -- Create companion buttons.
  for companion, id in pairs(CStuffTracker.companions) do
    CStuffTracker.UpdateNameLabel(id)
  end
  
  local lsc = LibSlashCommander
  if lsc then
    local cmd = lsc:Register("/cstracker", CStuffTracker.ToggleWindow, GetString(SI_BINDING_NAME_COMPANIONSTUFFTRACKER_OPEN_WINDOW))
    
    local sub_debug = cmd:RegisterSubCommand()
    sub_debug:AddAlias("debug")
    sub_debug:SetCallback(function()
      CStuffTracker.showDebug = not CStuffTracker.showDebug
      CSTDebug:SetHidden(not CStuffTracker.showDebug)
      CSTClearDebug:SetHidden(not CStuffTracker.showDebug)
    end)
    sub_debug:SetDescription("Debug mode")
    
  else
  
    SLASH_COMMANDS["/cstracker"] = function(input)
      local cmd = input:match("(.-)$")
      if(cmd and cmd ~= "") then
        if cmd == "debug" then
          CStuffTracker.showDebug = not CStuffTracker.showDebug
          CSTDebug:SetHidden(not CStuffTracker.showDebug)
          CSTClearDebug:SetHidden(not CStuffTracker.showDebug)
        end
      else
        CStuffTracker.ToggleWindow()
      end
    end
	  
  end

end

-- Build and display or hide the tooltip if control node is hovered or exited.
function CStuffTracker.SetTooltip(control, link)

  control:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(ItemTooltip, control, TOP, 0, 0)
    if not link then
      SetTooltipText(ItemTooltip, "-")
    else
      ItemTooltip:SetLink(link)
    end
  end)
  
  control:SetHandler("OnMouseExit", function(self)
    ClearTooltip(ItemTooltip)
  end)
  
end

function CStuffTracker.AssignRole(companionId, role)
  
  CStuffTracker.companionRole[companionId] = role
  CStuffTracker.savedVariables.companionRole[companionId] = role
  
  CStuffTracker.UpdateNameLabel(companionId)
    
end

function CStuffTracker.ListCompanionStuff(companionId, liveView)

  CStuffTrackerControlCompanionName:SetText(zo_strformat("<<C:1>>", GetCompanionName(companionId)))
  
  CStuffTracker.showCompanion = companionId
  
  local firstRingDisplayed = false
  local firstWeaponDisplayed = false
  
  -- Clean the list. Used in case we are removing stuff from companion.
  CStuffTracker.CleanList(companionId)
  
  local items = {}
  
  if liveView then
  
    -- As this is the liveview content will be updated so clean saved state.
    CStuffTracker.savedVariables.companionStuff[companionId] = {}
    CStuffTracker.companionStuff[companionId] = {}
  
    local slotBagPack = ZO_GetNextBagSlotIndex(BAG_COMPANION_WORN)
    while slotBagPack do
      local itemLink = GetItemLink(BAG_COMPANION_WORN, slotBagPack)
      local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_COMPANION_WORN, slotBagPack)
      
      -- If item is a ring or a one hand weapon allow to add many times in the table otherwise
      -- if there's two items with same trait it's considered as the same item.
      if not CStuffTracker.IsItemInArray(items, itemLink) or (equipType == EQUIP_TYPE_RING) or (equipType == EQUIP_TYPE_ONE_HAND) then
        table.insert(items, {icon, itemLink, equipType})
      end
      
      slotBagPack = ZO_GetNextBagSlotIndex(BAG_COMPANION_WORN, slotBagPack)
    end
  else
    if not CStuffTracker.companionStuff[companionId] then return end
    items = CStuffTracker.companionStuff[companionId]
  end
  
  local cpt = 1

  -- Browse the companion stuff.
  while cpt <= table.getn(items) do

    local icon = items[cpt][1]
    local itemLink = items[cpt][2]
    local equipType = items[cpt][3]
    
    CSTDebug:SetText(CSTDebug:GetText() .. " \nLink " .. itemLink .. " \nEquip type " .. equipType .. "\nFirst weapon " .. tostring(firstWeaponDisplayed ).. " \nFirst ring " .. tostring(firstRingDisplayed))

    -- Head
    if equipType == EQUIP_TYPE_HEAD then
      CStuffTrackerControlHead:SetText("|t32:32:" .. icon .. "|t" .. itemLink) 
      CStuffTracker.SetTooltip(CStuffTrackerControlHead, itemLink)
      
    -- Shoulders
    elseif equipType == EQUIP_TYPE_SHOULDERS then
      CStuffTrackerControlShoulders:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlShoulders, itemLink)
      
    -- Hands
    elseif equipType == EQUIP_TYPE_HAND then
      CStuffTrackerControlHand:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlHand, itemLink)
      
    -- Legs
    elseif equipType == EQUIP_TYPE_LEGS then
      CStuffTrackerControlLegs:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlLegs, itemLink)
      
    -- Chest
    elseif equipType == EQUIP_TYPE_CHEST then
      CStuffTrackerControlChest:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlChest, itemLink)
      
    -- Waist
    elseif equipType == EQUIP_TYPE_WAIST then
      CStuffTrackerControlWaist:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlWaist, itemLink)
      
    -- Feet
    elseif equipType == EQUIP_TYPE_FEET then
      CStuffTrackerControlFeet:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlFeet, itemLink)
      
    -- Neck
    elseif equipType == EQUIP_TYPE_NECK then
      CStuffTrackerControlNecklace:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlNecklace, itemLink)
      
    -- Ring 1
    elseif equipType == EQUIP_TYPE_RING and not firstRingDisplayed then
      CStuffTrackerControlRing1:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      firstRingDisplayed = true
      CStuffTracker.SetTooltip(CStuffTrackerControlRing1, itemLink)
      
    -- Ring 2
    elseif equipType == EQUIP_TYPE_RING and firstRingDisplayed then
      CStuffTrackerControlRing2:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlRing2, itemLink)
      
    -- One hand 1
    elseif (equipType == EQUIP_TYPE_ONE_HAND and not firstWeaponDisplayed) or equipType == EQUIP_TYPE_MAIN_HAND then
      CStuffTrackerControlWeapon1:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      firstWeaponDisplayed = true
      CStuffTracker.SetTooltip(CStuffTrackerControlWeapon1, itemLink)

    -- One hand 2
    elseif (equipType == EQUIP_TYPE_ONE_HAND and firstWeaponDisplayed) or equipType == EQUIP_TYPE_OFF_HAND then
      CStuffTrackerControlWeapon2:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlWeapon2, itemLink)

    -- Two hand
    elseif equipType == EQUIP_TYPE_TWO_HAND then
      CStuffTrackerControlWeapon1:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTrackerControlWeapon2:SetText("|t32:32:" .. icon .. "|t" .. itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlWeapon1, itemLink)
      CStuffTracker.SetTooltip(CStuffTrackerControlWeapon2, itemLink)
    end

    cpt = cpt + 1
	
	-- Save data if live view as table has been cleaned
	if liveView then
	  table.insert(CStuffTracker.companionStuff[companionId], {icon, itemLink, equipType})
	  table.insert(CStuffTracker.savedVariables.companionStuff[companionId], {icon, itemLink, equipType})
	end

  end

end

function CStuffTracker.CleanList(companionId)
  CStuffTrackerControlHead:SetText("-") 
  CStuffTracker.SetTooltip(CStuffTrackerControlHead, nil)
  CStuffTrackerControlShoulders:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlShoulders, nil)
  CStuffTrackerControlHand:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlHand, nil)
  CStuffTrackerControlLegs:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlLegs, nil)
  CStuffTrackerControlChest:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlChest, nil)
  CStuffTrackerControlWaist:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlWaist, nil)
  CStuffTrackerControlFeet:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlFeet, nil)
  CStuffTrackerControlNecklace:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlNecklace, nil)
  CStuffTrackerControlRing1:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlRing1, nil)
  CStuffTrackerControlRing2:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlRing2, nil)
  CStuffTrackerControlWeapon1:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlWeapon1, nil)
  CStuffTrackerControlWeapon2:SetText("-")
  CStuffTracker.SetTooltip(CStuffTrackerControlWeapon2, nil)
end

function CStuffTracker.OnCompanionStuffChanged()

  currentCompanion = GetActiveCompanionDefId()
  local name = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(GetCompanionCollectibleId(currentCompanion))
  if name ~= nil and HasActiveCompanion() then 
    -- List the companion stuff
    CStuffTracker.ListCompanionStuff(currentCompanion, true)
  end
  
end

function CStuffTracker.OnCompanionActivated(eventCode, companionId)

  if companionId == nil or not HasActiveCompanion() then return end

  -- Clean previous label
  CStuffTracker.ResetNameLabels()

  CStuffTrackerControlCompanionName:SetText("-")

  local name = GetCompanionName(companionId)
  if name ~= nil then
    CStuffTracker.ListCompanionStuff(companionId, true)
  end
  
  currentCompanion = companionId
  
  CStuffTracker.UpdateNameLabel(companionId)

end

function CStuffTracker.GetCompanionControlNode(companionId)
  -- Companion Ids :
  --  1 = Bastian
  --  2 = Mirri
  --  5 = Ember
  --  6 = Isobel
  --  8 = Sharp
  --  9 = Azander
  --  12 = Tanlorin
  --  13 = Zerith-var
  
  local controlNode
  if companionId == 1 then controlNode = CStuffTrackerControlBastian
  elseif companionId == 2 then controlNode = CStuffTrackerControlMirri
  elseif companionId == 5 then controlNode = CStuffTrackerControlEmber
  elseif companionId == 6 then controlNode = CStuffTrackerControlIsobel
  elseif companionId == 8 then controlNode = CStuffTrackerControlSharp
  elseif companionId == 9 then controlNode = CStuffTrackerControlAzander
  elseif companionId == 12 then controlNode = CStuffTrackerControlTanlorin
  elseif companionId == 13 then controlNode = CStuffTrackerControlZerith end
  
  return controlNode
end

function CStuffTracker.UpdateNameLabel(companionId)

  local controlNode = CStuffTracker.GetCompanionControlNode(companionId)
  
  local nameLabel = "-"
  if currentCompanion == companionId then 
    nameLabel = "* " .. string.format("|cFF0000%s|", zo_strformat("<<C:1>>", GetCompanionName(companionId)))
  else
    nameLabel = zo_strformat("<<C:1>>", GetCompanionName(companionId))
  end
  
  local lockIcon = ""
  -- Retrieve the information about companion quest to know if companion is available or not. If companion not available questName == ""
  local questName, questType = GetCompletedQuestInfo(CStuffTracker.companionQuestId[companionId])
  if not IsCollectibleUnlocked(GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, CStuffTracker.companionsListById[companionId])) or
      questName == "" then
    lockIcon = "|t32:32:esoui/art/progression/lock.dds|t "
  end
  
  if CStuffTracker.companionRole[companionId] then
    controlNode:SetText(CStuffTracker.textureRole[CStuffTracker.companionRole[companionId]] .. lockIcon .. nameLabel)
  else
    controlNode:SetText(lockIcon .. nameLabel)
  end
  
  controlNode:SetHandler("OnClicked", function()
    CStuffTracker.ListCompanionStuff(companionId, (HasActiveCompanion() and currentCompanion == companionId))
  end)

end

function CStuffTracker.ResetNameLabels()
  CStuffTrackerControlBastian:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Bastian"]))
  CStuffTrackerControlMirri:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Mirri"]))
  CStuffTrackerControlEmber:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Ember"]))
  CStuffTrackerControlIsobel:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Isobel"]))
  CStuffTrackerControlSharp:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Sharp"]))
  CStuffTrackerControlAzander:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Azander"]))
  CStuffTrackerControlTanlorin:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Tanlorin"]))
  CStuffTrackerControlZerith:SetText(CStuffTracker.getCompanionButtonName(CStuffTracker.companions["Zerith"]))
end

function CStuffTracker.getCompanionButtonName(companionId)

  local companionRole = ""
  local companionUnlocked = ""
  local companionName = zo_strformat("<<C:1>>", GetCompanionName(companionId))

  if CStuffTracker.companionRole[companionId] then
    companionRole = CStuffTracker.textureRole[CStuffTracker.companionRole[companionId]]
  end
  
  if not IsCollectibleUnlocked(GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, CStuffTracker.companionsListById[companionId])) then
    companionUnlocked = "|t32:32:esoui/art/progression/lock.dds|t "
  end
  
  return companionRole .. companionUnlocked .. companionName

end

function CStuffTracker.CloseWindow()
  SCENE_MANAGER:HideTopLevel(CStuffTrackerControl)
end

function CStuffTracker.ToggleWindow()
  SCENE_MANAGER:ToggleTopLevel(CStuffTrackerControl)
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function CStuffTracker.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CStuffTracker.name then
    CStuffTracker.Initialize()
    SCENE_MANAGER:RegisterTopLevel(CStuffTrackerControl, false)
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(CStuffTracker.name, EVENT_ADD_ON_LOADED)
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(CStuffTracker.name, EVENT_ADD_ON_LOADED, CStuffTracker.OnAddOnLoaded)


function CStuffTracker.Donate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(CStuffTracker.FillMailWindow, 200)
end



function CStuffTracker.FillMailWindow()

	local headerString = GetString(isDonation and SI_COMBAT_METRICS_DONATE_GOLD_HEADER or SI_COMBAT_METRICS_FEEDBACK_MAIL_HEADER)

	ZO_MailSendToField:SetText("@VisioTempus")
	ZO_MailSendSubjectField:SetText(string.format("Donation"))
	ZO_MailSendBodyField:TakeFocus()

	QueueMoneyAttachment(5000)
	--ZO_MailSendSendCurrency:OnBeginInput()

end


-- Utility method for checking the content of an array in LUA
-- Array contains an array of :
--  [1] = item icon
--  [2] = item link
--  [3] = equipement type
-- So we need to check in the [2] of item object argument.
function CStuffTracker.IsItemInArray(array, item)
  for key, value in ipairs(array) do
    if value[2] == item then
      return true
    end
  end
  return false
end