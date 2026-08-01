-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


local backupGamepadIcons = {}

-- store the gamepad icons
-- to work correctly this must be called:
--    1. in gamepad mode
--    2. when the gamepad mode was enabled our myIsInGamepadPreferredMode was not in effect
--    3. after the switch the default UI had a chance to initalize 
--        (you can't make the switch and then immediatly call this, you need to wait for the gamepad change event)
function ADCUI:getGamepadIcons()
  for _, control in ipairs(self.const.CONTROLS_TO_BACKUP) do
    backupGamepadIcons[control] = control:GetText()
  end

  -- quickslot button text
  local button = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1)
  ADCUI.vars.backupActionButtonIcons[button.buttonText] = button.buttonText:GetText()

  -- action button texts
  -- we ignore the last button, which is the ultimate button and has no text
  for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
    button = ZO_ActionBar_GetButton(i)
    ADCUI.vars.backupActionButtonIcons[button.buttonText] = button.buttonText:GetText()
  end
  
  self.vars.isGamepadKeysInitialized = true
end

-- load the stored gamepad icons
function ADCUI:setGamepadIcons()
  for control, text in pairs(backupGamepadIcons) do
    control:SetText(text)
  end
end

local isReticleAdjusted = false

-- configure UI elements for gamepad
function ADCUI:setGamepadUISettings()
  LORE_READER.PCKeybindStripDescriptor = LORE_READER.gamepadKeybindStripDescriptor          -- enables gamepad controls when reading books
  KEYBIND_STRIP_STANDARD_STYLE.alwaysPreferGamepadMode = true                               -- change default button style to the gamepad version
  QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor[2].keybind = "UI_SHORTCUT_SECONDARY"        -- switch show quest location to X
  table.insert(QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor, {                             -- build an extra keybind for the original keyboard keybind so that they both work
    name = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP) .. "_keyboard",
    keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP",
    callback = QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor[2].callback,
    ethereal = true,  -- hide this since we just want the functionality but not the button clutter
    isAddedByADCUI = true,
  })
  ZONE_STORIES_KEYBOARD.keybindStripDescriptor.keybind = "UI_SHORTCUT_SECONDARY"            -- switch more info to X
  GUILD_HOME.keybindStripDescriptor[1].keybind = "UI_SHORTCUT_LEFT_STICK"                   -- switch leave guild to left stick click
  PLAYER_INVENTORY.bankWithdrawTabKeybindButtonGroup[3].keybind = "UI_SHORTCUT_LEFT_STICK"  -- switch stack all to left stick click
  PLAYER_INVENTORY.bankDepositTabKeybindButtonGroup[2].keybind = "UI_SHORTCUT_LEFT_STICK"
  PLAYER_INVENTORY.houseBankWithdrawTabKeybindButtonGroup[1].keybind = "UI_SHORTCUT_LEFT_STICK"
  PLAYER_INVENTORY.houseBankDepositTabKeybindButtonGroup[1].keybind = "UI_SHORTCUT_LEFT_STICK"
  LOCK_PICK.keybindStripDescriptor[4].alignment = KEYBIND_STRIP_ALIGN_RIGHT
  
  -- adjust horizontal positioning of reticle labels since they're too far off to the right
  if not isReticleAdjusted then
    local _, point, relTo, relPoint, offsetX, offsetY = ZO_ReticleContainerInteractKeybindButtonKeyLabel:GetAnchor()
    ZO_ReticleContainerInteractKeybindButtonKeyLabel:ClearAnchors()
    ZO_ReticleContainerInteractKeybindButtonKeyLabel:SetAnchor(point, relTo, relPoint, offsetX+5, offsetY)
    local _, point, relTo, relPoint, offsetX, offsetY = ZO_ReticleContainerInteractKeybindButtonNameLabel:GetAnchor()
    ZO_ReticleContainerInteractKeybindButtonNameLabel:ClearAnchors()
    ZO_ReticleContainerInteractKeybindButtonNameLabel:SetAnchor(point, relTo, relPoint, offsetX-7, offsetY)
    isReticleAdjusted = true
  end
end

local backupLoreReaderKeyboardKeybind = LORE_READER.PCKeybindStripDescriptor

-- restore UI elements for keyboard
function ADCUI:setKeyboardUISettings()
  LORE_READER.PCKeybindStripDescriptor = backupLoreReaderKeyboardKeybind
  KEYBIND_STRIP_STANDARD_STYLE.alwaysPreferGamepadMode = false
  QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor[2].keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP"
  if (QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor[#QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor].isAddedByADCUI) then
    table.remove(QUEST_JOURNAL_KEYBOARD.keybindStripDescriptor) -- we added this manually, now we take it back
  end
  ZONE_STORIES_KEYBOARD.keybindStripDescriptor.keybind = "UI_SHORTCUT_REPORT_PLAYER"
  GUILD_HOME.keybindStripDescriptor[1].keybind = "UI_SHORTCUT_NEGATIVE"
  PLAYER_INVENTORY.bankWithdrawTabKeybindButtonGroup[3].keybind = "UI_SHORTCUT_STACK_ALL"
  PLAYER_INVENTORY.bankDepositTabKeybindButtonGroup[2].keybind = "UI_SHORTCUT_STACK_ALL"
  PLAYER_INVENTORY.houseBankWithdrawTabKeybindButtonGroup[1].keybind = "UI_SHORTCUT_STACK_ALL"
  PLAYER_INVENTORY.houseBankDepositTabKeybindButtonGroup[1].keybind = "UI_SHORTCUT_STACK_ALL"
  
  if isReticleAdjusted then
    local _, point, relTo, relPoint, offsetX, offsetY = ZO_ReticleContainerInteractKeybindButtonKeyLabel:GetAnchor()
    ZO_ReticleContainerInteractKeybindButtonKeyLabel:ClearAnchors()
    ZO_ReticleContainerInteractKeybindButtonKeyLabel:SetAnchor(point, relTo, relPoint, offsetX-5, offsetY)
    local _, point, relTo, relPoint, offsetX, offsetY = ZO_ReticleContainerInteractKeybindButtonNameLabel:GetAnchor()
    ZO_ReticleContainerInteractKeybindButtonNameLabel:ClearAnchors()
    ZO_ReticleContainerInteractKeybindButtonNameLabel:SetAnchor(point, relTo, relPoint, offsetX+7, offsetY)
    isReticleAdjusted = false
  end
end