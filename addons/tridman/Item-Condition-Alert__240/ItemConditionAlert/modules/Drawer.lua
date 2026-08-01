local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.Drawer = {}

local function ItemDialogue(button)
  if (button.type == ItemConditionAlert.TYPE_WEAPON) then
    ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag = BAG_WORN, index = button.slotId})
  else
    ZO_Dialogs_ShowDialog("REPAIR_ITEM", {bag = BAG_WORN, index = button.slotId})
  end
end

function ItemConditionAlert.Drawer:Draw(icon, name, dx, dy, state, slot, condition, type, Ignoreautoswitch)
  local BD = WINDOW_MANAGER:GetControlByName(name.."_Backdrop")
  local BUTTON = WINDOW_MANAGER:GetControlByName(name.."_Button")
  local OUTLINE = WINDOW_MANAGER:GetControlByName(name.."_Outline")
  local label = WINDOW_MANAGER:GetControlByName(name.."_Label")
  local texture = WINDOW_MANAGER:GetControlByName(name)
  
  local activeweapon = GetActiveWeaponPairInfo()
  
  --Draw UI-Elements if they do not already exist 
  if (not BD) then
    BD = WINDOW_MANAGER:CreateControl(name.."_Backdrop", ItemConditionAlertTopControl, CT_TEXTURE)
	  BD:SetDimensions(ItemConditionAlert.windowSizeX, ItemConditionAlert.windowSizeY)
    BD:SetAnchor(CENTER,ItemConditionAlertTopControl,CENTER, dx + ItemConditionAlert.offsetX , dy + ItemConditionAlert.offsetY)
    BD:SetTexture([[/esoui/art/ava/ava_seigecontrols_bg.dds]])
  end
  if (not BUTTON) then
    BUTTON = WINDOW_MANAGER:CreateControl(name.."_Button", BD, CT_BUTTON)
    BUTTON:SetDimensions(ItemConditionAlert.outlineSize, ItemConditionAlert.outlineSize)
    BUTTON:SetAnchor(TOPLEFT, BD, TOPLEFT, ItemConditionAlert.windowPaddingX, ItemConditionAlert.windowPaddingY)
    BUTTON:SetHandler("OnClicked", ItemDialogue)
    BUTTON:SetHidden(true)
    BUTTON.slotId = slot
    BUTTON.type =type 
  end
  if (not OUTLINE) then
    OUTLINE = WINDOW_MANAGER:CreateControl(name.."_Outline", BD, CT_TEXTURE)
    OUTLINE:SetDimensions(ItemConditionAlert.outlineSize, ItemConditionAlert.outlineSize)
	  OUTLINE:SetAnchor(TOPLEFT, BD, TOPLEFT, ItemConditionAlert.windowPaddingX, ItemConditionAlert.windowPaddingY)
    OUTLINE:SetTexture("ItemConditionAlert/images/outline.dds")
    OUTLINE:SetHidden(true)
  end
  if (not label) then
    label = WINDOW_MANAGER:CreateControl(name.."_Label", BD, CT_LABEL)
    label:SetAnchor(BOTTOMRIGHT, OUTLINE, BOTTOMRIGHT, -10, -15)
    label:SetDrawLayer(1)
    label:SetFont("ZoFontGameSmall")
    label:SetDimensions(50, 10)
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetHidden(true)
    
  end
  if (not texture) then
    texture = WINDOW_MANAGER:CreateControl(name, BD, CT_TEXTURE)
    texture:SetDimensions(ItemConditionAlert.iconSize, ItemConditionAlert.iconSize)
    texture:SetAnchor(CENTER, OUTLINE, CENTER)
    texture:SetHidden(true)
    
  end
  
  --Reset Anchor position if redraw flag is set
  if ItemConditionAlert.FLAG_REDRAW then
    BD:SetAnchor(CENTER,ItemConditionAlertTopControl,CENTER, dx + ItemConditionAlert.offsetX, dy + ItemConditionAlert.offsetY)
  end
  
  texture:SetTexture(icon)
  label:SetText(tostring(condition .. "%"))
  
  --Set Visibility according to state and configuration
  if
  (
    ((
      (((slot == EQUIP_SLOT_MAIN_HAND)   or (slot == EQUIP_SLOT_OFF_HAND))   and (activeweapon == 1))  -- Is it part of the active Main Weaponset?
      or (((slot == EQUIP_SLOT_BACKUP_MAIN) or (slot == EQUIP_SLOT_BACKUP_OFF)) and (activeweapon == 2))  -- Or is it part of the active Backup Weaponset?
      or (type == ItemConditionAlert.TYPE_ARMOR)                                                                         -- Or is is it an Armor part? 
    ) and (condition > -1))
    or ((Ignoreautoswitch) and (condition > -1))
  )
  then
    if ((type == ItemConditionAlert.TYPE_ARMOR) and (state >= ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.sv.VisibilityThreshold]))
    or ((type == ItemConditionAlert.TYPE_WEAPON)  and (state >= ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.sv.WeaponVisibThreshold]))
    or (ItemConditionAlert.sv.Nothreshold)
    then
      BD:SetHidden(false)
      BUTTON:SetHidden(false)
      OUTLINE:SetHidden(false)
      if ItemConditionAlert.sv.Percentage then label:SetHidden(false)
      else label:SetHidden(true)
      end
      texture:SetHidden(false)
    else
      BD:SetHidden(true)
      BUTTON:SetHidden(true)
      OUTLINE:SetHidden(true)
      label:SetHidden(true)
      texture:SetHidden(true)
    end
  else
    BD:SetHidden(true)
    BUTTON:SetHidden(true)
    OUTLINE:SetHidden(true)
    label:SetHidden(true)
    texture:SetHidden(true)
  end
  
  --Set outline color according to state
  if(state == ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.ItemStates[1]]) then
    OUTLINE:SetColor(1, 1, 1, 1)
  elseif(state == ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.ItemStates[2]]) then
    OUTLINE:SetColor(0, 1, 0, 1) 
  elseif(state == ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.ItemStates[3]]) then
    OUTLINE:SetColor(1, 1, 0, 1)
  elseif(state == ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.ItemStates[4]]) then
    OUTLINE:SetColor(1, .784, 0, 1)
  elseif(state == ItemConditionAlert.SlotItem.ItemState[ItemConditionAlert.ItemStates[5]]) then
    OUTLINE:SetColor(1, 0, 0, 1)
  else
    OUTLINE:SetColor(0, 0, 0, 1)
  end
  
end