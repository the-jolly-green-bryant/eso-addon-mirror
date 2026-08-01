-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- [Dialogs]

-- override ZO_Dialogs_ShowDialog to force gamepad buttons
-- we do this by reverting our override function back to the original during dialog creation, then switching back after the call
-- this seems to keep the keyboard dialog and just switch out the buttons to the gamepad ones
local originalZOShowDialog = _G["ZO_Dialogs_ShowDialog"]
local function myShowDialog(name, data, textParams, isGamepad)
  if not ADCUI:shouldUseGamepadButtons() then
    return originalZOShowDialog(name, data, textParams, isGamepad)
  end
  
  ADCUI:setGamepadPreferredModeOverrideState(false)
  local dialog = originalZOShowDialog(name, data, textParams, isGamepad)
  ADCUI:setGamepadPreferredModeOverrideState(true)

  return dialog
end
_G["ZO_Dialogs_ShowDialog"] = myShowDialog


-- [Quickslot Radial Manager]

-- override QuickslotSlotRadialManager:StartInteraction() to force gamepad buttons
-- except when using the gamepad UI this should always return the keyboard version
local function myQuickslotSlotRadialManager_StartInteraction(self)
  self.gamepad = ADCUI:shouldUseGamepadUI()

  if self.gamepad then
    QUICKSLOT_RADIAL_GAMEPAD:StartInteraction()
  else
    QUICKSLOT_RADIAL_KEYBOARD:StartInteraction()
  end
end
QUICKSLOT_RADIAL_MANAGER["StartInteraction"] = myQuickslotSlotRadialManager_StartInteraction


-- [Stall All Button Mapping]

-- hook button group add to adjust controls for the store scene
-- we have to do this for store and inventory scenes because their classes don't expose the descriptor structures globally

-- adjust stack all to be compatable with gamepad controls or revert them back to keyboard
local function setStackAllKeybind(keybindButtonGroupDescriptor)
  for _, keybindButtonDescriptor in ipairs(keybindButtonGroupDescriptor) do
    if ADCUI:originalIsInGamepadPreferredMode() then -- set override
      if not keybindButtonDescriptor.modByADCUI and (keybindButtonDescriptor.keybind == "UI_SHORTCUT_STACK_ALL") then
        keybindButtonDescriptor.keybind = "UI_SHORTCUT_LEFT_STICK"
        keybindButtonDescriptor.modByADCUI = true
      end
    else                                -- revert override
      if (keybindButtonDescriptor.keybind == "UI_SHORTCUT_LEFT_STICK") then
        keybindButtonDescriptor.keybind = "UI_SHORTCUT_STACK_ALL"
        keybindButtonDescriptor.modByADCUI = false
      end
    end
  end
end

local function onAddOrUpdateKeybindButtonGroup(self, keybindButtonGroupDescriptor, stateIndex)
  local settings = ADCUI:getSettings()  -- this is important, if you call ADCUI:shouldUseGamepadButtons you get NOT BOUND in keyboard mode
  if not keybindButtonGroupDescriptor or not settings or not settings.useGamepadButtons then
    return
  end

  local sceneName = SCENE_MANAGER:GetCurrentSceneName()
  if not sceneName or (sceneName ~= "store") and (sceneName ~= "inventory") and (sceneName ~= "fence_keyboard") then
    return
  end

  setStackAllKeybind(keybindButtonGroupDescriptor)
end

ZO_PreHook(KEYBIND_STRIP, "AddKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)
ZO_PreHook(KEYBIND_STRIP, "UpdateKeybindButtonGroup", onAddOrUpdateKeybindButtonGroup)


-- [World Map]

-- reset the map view to keyboard default instead of centering on player
ZO_WorldMapManager:RegisterCallback("Showing", function()
  local map = ZO_WorldMap_GetPanAndZoom()
  map:AddTargetOffsetDelta(0, 0)
end)

-- this fixes the first time map is opened
WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
  if not ADCUI:originalIsInGamepadPreferredMode() or (newState ~= SCENE_SHOWN) then
    return
  end

  local map = ZO_WorldMap_GetPanAndZoom()
  map:AddTargetOffsetDelta(0, 0)
end)

-- [Player Attribute Bars]

local originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged = PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"]
local function myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false)
  originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged(self)
  ADCUI:setGamepadPreferredModeOverrideState(true)
end


-- [Action Bar]
-- note: contains a lot of modified code from actionbutton.lua to force gamepad mode behavior

-- override ZO_PlatformStyle but only for calls from ActionButton
local originalZO_PlatformStyle_Apply = ZO_PlatformStyle["Apply"]
local function myZO_PlatformStyle_Apply(self)
  if not self.keyboardStyle or (self.keyboardStyle.showWeaponSwapButton == nil) or not ADCUI:originalIsInGamepadPreferredMode() then
    return originalZO_PlatformStyle_Apply(self)
  end

  ADCUI:setGamepadPreferredModeOverrideState(false)
  self.applyFunction(self.gamepadStyle)
  ADCUI:setGamepadPreferredModeOverrideState(true)
end

-- override ZO_GetPlatformTemplate but only for calls from ActionButton
local originalZO_GetPlatformTemplate = _G["ZO_GetPlatformTemplate"]
local function myZO_GetPlatformTemplate(baseTemplate)
  if not ADCUI:originalIsInGamepadPreferredMode() or 
     (baseTemplate ~= "ZO_ActionButton") and (baseTemplate ~= "ZO_UltimateActionButton") then
    return originalZO_GetPlatformTemplate(baseTemplate)
  else
    return baseTemplate .. "_Gamepad_Template"
  end
end

-- override ZO_ActionSlot_SetupSlot but only for calls from ActionButton
local originalZO_ActionSlot_SetupSlot = _G["ZO_ActionSlot_SetupSlot"]
local function myZO_ActionSlot_SetupSlot(iconControl, buttonControl, icon, normalFrame, downFrame, cooldownIconControl)
  if not ADCUI:originalIsInGamepadPreferredMode() or not buttonControl:GetName():find("ActionButton") then
    originalZO_ActionSlot_SetupSlot(iconControl, buttonControl, icon, normalFrame, downFrame, cooldownIconControl)
  else
    originalZO_ActionSlot_SetupSlot(iconControl, buttonControl, icon, "", "", cooldownIconControl)
  end
end

local originalActionButton_Clear = ActionButton["Clear"]
local function myActionButton_Clear(self)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_Clear(self)
  end

  if self.buttonType == ACTION_BUTTON_TYPE_LOCKED then
    self.slot:SetHidden(true)
  else
    ZO_ActionSlot_ClearSlot(self.icon, self.button, "", "", self.cooldownIcon)
  end
  self.hasAction = false
  self.button.actionId = nil
  self.cooldownEdge:SetHidden(true)
  self.countText:SetText("")
end

local originalActionButton_UpdateUsable = ActionButton["UpdateUsable"]
local function myActionButton_UpdateUsable(self)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_UpdateUsable(self)
  end

  local isShowingCooldown = self.showingCooldown
  local usable = false
  if not self.useFailure and not isShowingCooldown then
    usable = true
  end

  local slotId = self:GetSlot()
  local slotType = GetSlotType(slotId)
  local stackEmpty = false
  if slotType == ACTION_TYPE_ITEM then
    local stackCount = GetSlotItemCount(slotId)
    if stackCount <= 0 then
        stackEmpty = true
        usable = false
    end
  end
    
  local useDesaturation = isShowingCooldown and not useFailure or stackEmpty
    
  if usable ~= self.usable or useDesaturation ~= self.useDesaturation then
    self.usable = usable
    self.useDesaturation = useDesaturation

    ZO_ActionSlot_SetUnusable(self.icon, not usable, useDesaturation)
  end
end

local originalActionButton_SetCooldownIconAnchors = ActionButton["SetCooldownIconAnchors"]
local function myActionButton_SetCooldownIconAnchors(self, inCooldown)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_SetCooldownIconAnchors(self, inCooldown)
  end

  self.icon:ClearAnchors()
  self.cooldownEdge:SetHidden(not inCooldown)

  if inCooldown then
    self.icon:SetAnchor(BOTTOMLEFT, self.flipCard)
    self.icon:SetAnchor(BOTTOMRIGHT, self.flipCard)
  else
    self.icon:SetAnchor(CENTER, self.flipCard)
  end
end

-- runs continuously during cooldown such as after using a collectible item
local originalActionButton_RefreshCooldown = ActionButton["RefreshCooldown"]
local function myActionButton_RefreshCooldown(self)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_RefreshCooldown(self)
  end

  local remain, duration = GetSlotCooldownInfo(self:GetSlot())
  local percentComplete = (1 - remain/duration)

  self:SetCooldownHeight(percentComplete)
  self.icon.percentComplete = percentComplete
end

-- last call after action is used
local originalActionButton_UpdateCooldown = ActionButton["UpdateCooldown"]
local function myActionButton_UpdateCooldown(self, options)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_UpdateCooldown(self, options)
  end

  local slotnum = self:GetSlot()
  local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotnum)
  local isInCooldown = duration > 0
  local slotType = GetSlotType(slotnum)
  local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
  local showCooldown = isInCooldown and (g_showGlobalCooldown or not global or showGlobalCooldownForCollectible)

  self.cooldown:SetHidden(not showCooldown)

  local updateChromaQuickslot = slotType ~= ACTION_TYPE_ABILITY and ZO_RZCHROMA_EFFECTS

  if showCooldown then
    self.cooldown:StartCooldown(remain, duration, CD_TYPE_RADIAL, nil, NO_LEADING_EDGE)
    if self.cooldownCompleteAnim.animation then
      self.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
    end

    if not self.itemQtyFailure then
      self.icon:SetDesaturation(0)
    end
    self.cooldown:SetHidden(true)
    if not self.showingCooldown then
      self:SetNeedsAnimationParameterUpdate(true)
      self:PlayAbilityUsedBounce()
    end

    self.slot:SetHandler("OnUpdate", function() self:RefreshCooldown() end)
    if updateChromaQuickslot then
      ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
    end
  else
    if self.showingCooldown then
      -- This ability was in a non-global cooldown, and now the cooldown is over...play animation and sound
      if options ~= FORCE_SUPPRESS_COOLDOWN_SOUND then
        PlaySound(SOUNDS.ABILITY_READY)
      end

      self.cooldownCompleteAnim.animation = self.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
      local anim = self.cooldownCompleteAnim.animation

      self.cooldownCompleteAnim:SetHidden(false)
      self.cooldown:SetHidden(false)

      anim:SetImageData(16,1)
      anim:SetFramerate(30)
      anim:GetTimeline():PlayFromStart()

      if updateChromaQuickslot then
        ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
      end
    end

    self.icon.percentComplete = 1
    self.slot:SetHandler("OnUpdate", nil)
    self.cooldown:ResetCooldown()
  end

  if showCooldown ~= self.showingCooldown then
    self.showingCooldown = showCooldown

    if self.showingCooldown then
      ZO_ContextualActionBar_AddReference()
    else
      ZO_ContextualActionBar_RemoveReference()
    end

    self:UpdateActivationHighlight()
    self:SetCooldownHeight(self.icon.percentComplete)
    self:SetCooldownIconAnchors(showCooldown)
  end

  local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
  self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

  self.isGlobalCooldown = global
  self:UpdateUsable()
end

local originalActionButton_ApplyStyle = ActionButton["ApplyStyle"]  
local function myActionButton_ApplyStyle(self, template)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_ApplyStyle(self, template)
  end

  ApplyTemplateToControl(self.slot, template)

  self.button:SetNormalTexture("")
  self.button:SetPressedTexture("")
  self.countText:SetFont("ZoFontGamepadBold27")
  self:ApplyFlipAnimationStyle()

  local decoration = self.slot:GetNamedChild("Decoration")
  if decoration then
    decoration:SetHidden(true)
  end

  local slotnum = self:GetSlot()
  local slotType = GetSlotType(slotnum)

  local cooldownHeight = 1

  if self.showingCooldown then 
    self.cooldown:SetHidden(true)

    local remain = GetSlotCooldownInfo(slotnum)
    self:PlayAbilityUsedBounce(500 + remain)
    cooldownHeight = self.icon.percentComplete
    if not self.itemQtyFailure then
      self.icon:SetDesaturation(0)
    end
  end

  self:UpdateUsable()
end

local originalActionButton_SetupFlipAnimation = ActionButton["SetupFlipAnimation"]
local function myActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return originalActionButton_SetupFlipAnimation(self, OnStopHandlerFirst, OnStopHandlerLast)
  end

  local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("HotbarSwapAnimation", self.flipCard)
  timeline:GetFirstAnimation():SetHandler("OnStop", function(animation) OnStopHandlerFirst(animation, self) end)
  timeline:GetLastAnimation():SetHandler("OnStop", function(animation) OnStopHandlerLast(animation, self) end)
  timeline:SetHandler("OnPlay", function()
    if self:GetSlot() ~= ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
      self.icon:ClearAnchors()
      self.icon:SetAnchor(TOPLEFT, self.flipCard)
      self.icon:SetAnchor(BOTTOMRIGHT, self.flipCard)
    end
  end)
  timeline:SetHandler("OnStop", function() 
    if self:GetSlot() ~= ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
      self.icon:ClearAnchors()
      self.icon:SetAnchor(CENTER, self.flipCard)
    end
  end)
  self.hotbarSwapAnimation = timeline

  self:ApplyFlipAnimationStyle()
end

-- we don't have access to SetUltimateMeter, but we do have access to the last function call it makes so we redo its gamepad code here
local originalActionButton_HideKeys = ActionButton["HideKeys"]
local function myActionButton_HideKeys(self, hide)
  if not ADCUI:originalIsInGamepadPreferredMode() or (self:GetSlot() ~= ACTION_BAR_ULTIMATE_SLOT_INDEX + 1) then
    return originalActionButton_HideKeys(self, hide)
  end

  local ultimateFillLeftTexture = GetControl(self.slot, "FillAnimationLeft")
  local ultimateFillRightTexture = GetControl(self.slot, "FillAnimationRight")
  local ultimateFillFrame = GetControl(self.slot, "Frame")
  local ultimateMax = GetSlotAbilityCost(self:GetSlot())

  if IsSlotUsed(self:GetSlot()) then
    if GetUnitPower("player", POWERTYPE_ULTIMATE) >= ultimateMax then
      ultimateFillFrame:SetHidden(false)
      ultimateFillLeftTexture:SetHidden(false)
      ultimateFillRightTexture:SetHidden(false)
    else
      local barTexture = GetControl(self.slot, "UltimateBar")
      local leadingEdge = GetControl(self.slot, "LeadingEdge")
      barTexture:SetHidden(true)
      leadingEdge:SetHidden(true)
      ultimateFillLeftTexture:SetHidden(false)
      ultimateFillRightTexture:SetHidden(false)
      ultimateFillFrame:SetHidden(false)
    end
  end

  self.leftKey:SetHidden(false)
  self.rightKey:SetHidden(false)
end

-- play the bounce animation because the default handler we can't access
local function onActionSlotAbilityUsed(_, slotNum)
  if not ADCUI:originalIsInGamepadPreferredMode() then
    return
  end

  local btn = ZO_ActionBar_GetButton(slotNum)
  if btn then
    btn:PlayAbilityUsedBounce()
  end
end

-- adjust settings after ActionBar:ApplyStyle()
local function onGamepadModeChanged_ActionBar(eventCode, gamepadPreferred)
  if not gamepadPreferred then
    return
  end

  local ultimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
  ultimateButton:SetShowBindingText(false)

  -- quickslot and action button texts
  for control, text in pairs(ADCUI.vars.backupActionButtonIcons) do
    control:SetText(text)
  end
end

-- for some reason once we set the flip animations we have to keep updating every gamepad mode change
-- if registered once then never unregister
local function onGamepadModeChanged_ActionBarFlipAnimation()
  local function OnSwapAnimationHalfDone(animation, button)
    button:HandleSlotChanged()
  end
  local function OnSwapAnimationDone(animation, button)
    button.noUpdates = false
  end

  -- setup flip animation
  for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
    local button = ZO_ActionBar_GetButton(slotNum)
    button:SetupFlipAnimation(OnSwapAnimationHalfDone, OnSwapAnimationDone)
  end
end

local registeredOnce = false

function ADCUI:setGamepadActionBarOverrideState(state)
  if state then
    PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"] = myZO_PlayerAttributeBars_OnGamepadPreferredModeChanged
    ZO_PlatformStyle["Apply"] = myZO_PlatformStyle_Apply
    _G["ZO_GetPlatformTemplate"] = myZO_GetPlatformTemplate
    _G["ZO_ActionSlot_SetupSlot"] = myZO_ActionSlot_SetupSlot
    ActionButton["Clear"] = myActionButton_Clear
    ActionButton["UpdateUsable"] = myActionButton_UpdateUsable
    ActionButton["SetCooldownIconAnchors"] = myActionButton_SetCooldownIconAnchors
    ActionButton["RefreshCooldown"] = myActionButton_RefreshCooldown
    ActionButton["UpdateCooldown"] = myActionButton_UpdateCooldown
    ActionButton["ApplyStyle"] = myActionButton_ApplyStyle
    ActionButton["SetupFlipAnimation"] = myActionButton_SetupFlipAnimation
    ActionButton["HideKeys"] = myActionButton_HideKeys

    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_ABILITY_USED, onActionSlotAbilityUsed)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged_ActionBar)

    if not registeredOnce then
      EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBarFlipAnimation", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged_ActionBarFlipAnimation)
      registeredOnce = true
    end
  else
    PLAYER_ATTRIBUTE_BARS["OnGamepadPreferredModeChanged"] = originalZO_PlayerAttributeBars_OnGamepadPreferredModeChanged
    ZO_PlatformStyle["Apply"] = originalZO_PlatformStyle_Apply
    _G["ZO_GetPlatformTemplate"] = originalZO_GetPlatformTemplate
    _G["ZO_ActionSlot_SetupSlot"] = originalZO_ActionSlot_SetupSlot
    ActionButton["Clear"] = originalActionButton_Clear
    ActionButton["UpdateUsable"] = originalActionButton_UpdateUsable
    ActionButton["SetCooldownIconAnchors"] = originalActionButton_SetCooldownIconAnchors
    ActionButton["RefreshCooldown"] = originalActionButton_RefreshCooldown
    ActionButton["UpdateCooldown"] = originalActionButton_UpdateCooldown
    ActionButton["ApplyStyle"] = originalActionButton_ApplyStyle
    ActionButton["SetupFlipAnimation"] = originalActionButton_SetupFlipAnimation
    ActionButton["HideKeys"] = originalActionButton_HideKeys

    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_ACTION_SLOT_ABILITY_USED)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME .. "_ActionBar", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
  end
end
