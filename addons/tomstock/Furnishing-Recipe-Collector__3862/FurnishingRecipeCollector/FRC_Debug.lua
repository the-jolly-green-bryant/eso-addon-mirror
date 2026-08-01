FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector

local tos = tostring

--[[
  Global Window Events
]]
function FRC.GuiDebugOnResizeStop()
  FRC.GuiDebugSaveFrameInfo()
  if FRC.isDebugGuiLoading == true then
    return
  end
end
function FRC.GuiDebugSaveFrameInfo(calledFrom)
  --functions hooked from GUI can't be local
  local gui_s = FRC.savedVariables["guiDebug"]

  gui_s.lastX = FRC_DebugGUI:GetLeft()
  gui_s.lastY = FRC_DebugGUI:GetTop()
  gui_s.width = FRC_DebugGUI:GetWidth()
  gui_s.height = FRC_DebugGUI:GetHeight()
end
function FRC.RestoreDebugPosition()
  local control = FRC_DebugGUI
  local gui_s = FRC.savedVariables["guiDebug"]
  local left = gui_s.lastX
  local top = gui_s.lastY

  control:SetHeight(gui_s.height)
  control:SetWidth(gui_s.width)

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
--[[
    Global functions used by other addon callbacks or XML
]]
function FRC.FRC_DebugToggle()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ToggleTopLevel(FRC_DebugGUI)
end
function FRC.FRC_DebugShow()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ShowTopLevel(FRC_DebugGUI)
end

function FRC.FRC_DebugRefresh()
  local editCtrl = FRC_DebugGUI_Edit
  editCtrl:Clear()
  editCtrl:SetMaxInputChars(100000)

  local items = {}

  for slotId=0, GetBagSize(BAG_BACKPACK) do
    local itemId = GetItemId(BAG_BACKPACK, slotId)
    if itemId ~= 0 then
      local itemLink = GetItemLink(BAG_BACKPACK, slotId)
      local vItemId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing = FRC.GetRecipeDetail(itemLink)

      if vRecipeItemLinkId ~= nil then
        table.insert(items, {name = vItemName, id = vItemId})
      end
    end
  end
  -- Sort the items by name
  table.sort(items, function(a, b) return a.name < b.name end)

  for _, item in ipairs(items) do
    editCtrl:SetText(editCtrl:GetText() .. string.char(10) ..
        item.id .. ", -- " .. item.name)
  end
end

function FRC.InitDebugGui()
  local control = FRC_DebugGUI

  FRC.RestoreDebugPosition()

  SCENE_MANAGER:RegisterTopLevel(control, false)
end
