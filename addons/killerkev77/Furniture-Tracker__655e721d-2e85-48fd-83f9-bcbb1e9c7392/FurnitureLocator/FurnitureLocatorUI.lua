--[[
Furniture Locator - UI (Milestone 3a: minimal proof-of-wiring)

Goal of THIS version: prove the addon can create its own on-screen window,
toggle it via SCENE_MANAGER, and render real data from
FurnitureLocator_Data.lua -- nothing more yet.

Deliberately NOT included yet (next milestones):
  - Controller D-pad navigation / selection (this uses a single scrolling
    text label, not a real ZO_ParametricScrollList)
  - Icons per row
  - Full list (capped to MAX_PREVIEW_ITEMS to avoid text-length issues)

All constructs below (WINDOW_MANAGER:CreateTopLevelWindow/CreateControl,
CT_LABEL/CT_BACKDROP, SetAnchor, ZO_Scene:New, ZO_SimpleSceneFragment,
SCENE_MANAGER:Toggle) are confirmed directly from Zenimax's own
"MyFirstAddon" tutorial and the ESOUI wiki's Scene/Fragment docs -- not
guessed from memory, given how the housing-scan guesses went last time.
]]

FurnitureLocatorUI = {}
local this = FurnitureLocatorUI

local ADDON_PACKAGE_NAME = "FurnitureLocator"
local MAX_PREVIEW_ITEMS = 15 -- fewer lines fit at readable console font size

function this.Initialize()
  this.window = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureLocatorWindow")
  this.window:SetDimensions(900, 900)
  this.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  this.window:SetHidden(true)

  this.background = WINDOW_MANAGER:CreateControl("FurnitureLocatorWindowBG", this.window, CT_BACKDROP)
  this.background:SetAnchorFill(this.window)
  this.background:SetCenterColor(0, 0, 0, 0.85)
  this.background:SetEdgeColor(1, 1, 1, 0.4)

  this.titleLabel = WINDOW_MANAGER:CreateControl("FurnitureLocatorTitle", this.window, CT_LABEL)
  this.titleLabel:SetFont("ZoFontGamepad42")
  this.titleLabel:SetAnchor(TOP, this.window, TOP, 0, 20)
  this.titleLabel:SetText("Furniture Locator (preview)")

  this.listLabel = WINDOW_MANAGER:CreateControl("FurnitureLocatorList", this.window, CT_LABEL)
  this.listLabel:SetFont("ZoFontGamepad27")
  this.listLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
  this.listLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  this.listLabel:SetAnchor(TOPLEFT, this.titleLabel, BOTTOMLEFT, 0, 20)
  this.listLabel:SetAnchor(BOTTOMRIGHT, this.window, BOTTOMRIGHT, -20, -20)

  -- ZO_SimpleSceneFragment ties the window's visibility to the scene below,
  -- so SCENE_MANAGER handles showing/hiding it rather than us doing it manually.
  this.fragment = ZO_SimpleSceneFragment:New(this.window)

  this.scene = ZO_Scene:New("FurnitureLocatorScene", SCENE_MANAGER)
  this.scene:AddFragment(this.fragment)
end

-- Pulls the current data and writes a short text preview into the window.
-- Capped at MAX_PREVIEW_ITEMS -- this is NOT the final scrollable list,
-- just enough to confirm real data renders correctly on screen.
function this.Refresh()
  local items = FurnitureLocator.GetAllOwnedItems()
  local lines = {}

  local count = math.min(#items, MAX_PREVIEW_ITEMS)
  for i = 1, count do
    local item = items[i]
    local firstLocation = item.locations[1]
    local locationText = firstLocation and firstLocation.name or "?"
    table.insert(lines, string.format("%s - %s", tostring(item.name), locationText))
  end

  if #items > MAX_PREVIEW_ITEMS then
    table.insert(lines, string.format("...and %d more (full scrollable list is the next milestone)", #items - MAX_PREVIEW_ITEMS))
  end

  if #items == 0 then
    table.insert(lines, "No owned furniture found yet -- check bag, bank, or vault, or /flist to verify data.")
  end

  this.listLabel:SetText(table.concat(lines, "\n"))
end

function this.Toggle()
  this.Refresh()
  SCENE_MANAGER:Toggle("FurnitureLocatorScene")
end

local function OnAddOnLoaded(_, addOnName)
  if addOnName ~= ADDON_PACKAGE_NAME then
    return
  end
  this.Initialize()
  EVENT_MANAGER:UnregisterForEvent("FurnitureLocatorUI", EVENT_ADD_ON_LOADED)

  SLASH_COMMANDS["/flocator"] = this.Toggle
  d("Furniture Locator UI loaded. Type /flocator to open/close the preview window.")
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorUI", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
