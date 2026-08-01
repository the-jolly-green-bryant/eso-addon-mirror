-------------------------------------------------------------------------------
-- Crafted Icon Module
-- Displays a crafted icon on consumable items that were player-crafted.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Localized Globals
-------------------------------------------------------------------------------
local GetItemCreatorName = GetItemCreatorName
local GetItemLink = GetItemLink
local InitializeTooltip = InitializeTooltip
local InformationTooltip = InformationTooltip
local IsItemLinkCrafted = IsItemLinkCrafted
local zo_strformat = zo_strformat
local ZO_PostHook = ZO_PostHook

local GAFE = GroupActivityFinderExtensions

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local CRAFTED_ICON_TEXTURE = "esoui/art/icons/poi/poi_crafting_complete.dds"

-------------------------------------------------------------------------------
-- Module Declaration
-------------------------------------------------------------------------------
local CraftedIcon = {}

-------------------------------------------------------------------------------
-- Private Functions
-------------------------------------------------------------------------------

--- Sets the crafted icon on items that were player-crafted.
--- @param control any The inventory row control
--- @param slot table The slot data containing bag and slot info
local function SetCraftedIcon(control, slot)
  local traitInfoControl = control:GetNamedChild("TraitInfo")
  if not traitInfoControl then
    return
  end

  local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
  if not itemLink then
    return
  end

  local isCrafted = IsItemLinkCrafted(itemLink)

  if isCrafted then
    -- No need to clear icons, native implementation should have already done that
    -- and we don't want to clear native icons
    traitInfoControl:AddIcon(CRAFTED_ICON_TEXTURE)
    traitInfoControl:Show()

    -- Store creator name for tooltip hook
    traitInfoControl.craftedByName = GetItemCreatorName(slot.bagId,
      slot.slotIndex)
  else
    traitInfoControl.craftedByName = nil
  end
end

--- Hook for ZO_InventorySlot_TraitInfo_OnMouseEnter to add crafted by line.
--- @param control any The TraitInfo control
local function OnTraitInfoMouseEnter(control)
  local creatorName = control.craftedByName
  if not creatorName or creatorName == "" then
    return
  end

  -- Check if tooltip was initialized by native function (has trait info)
  -- If not, initialize it ourselves for crafted items without traits
  local slotData = control:GetParent().dataEntry.data
  local traitInformation = slotData.traitInformation

  if not traitInformation or traitInformation == ITEM_TRAIT_INFORMATION_NONE then
    InitializeTooltip(InformationTooltip, control, TOPRIGHT, -10, 0, TOPLEFT)
  end

  InformationTooltip:AddLine(
    zo_strformat("Crafted by: <<1>>", ZO_SELECTED_TEXT:Colorize(creatorName)),
    "",
    ZO_NORMAL_TEXT:UnpackRGB()
  )
end

--- Hooks the native trait info tooltip function.
local function InitTooltipHook()
  ZO_PostHook("ZO_InventorySlot_TraitInfo_OnMouseEnter", OnTraitInfoMouseEnter)
end

-------------------------------------------------------------------------------
-- Public Functions
-------------------------------------------------------------------------------

--- Initializes the Crafted Icon module.
function CraftedIcon.Init()
  GAFE.InventorySlotHooks.RegisterCallback(SetCraftedIcon)
  InitTooltipHook()
end

-------------------------------------------------------------------------------
-- Module Registration
-------------------------------------------------------------------------------
GAFE.CraftedIcon = CraftedIcon
